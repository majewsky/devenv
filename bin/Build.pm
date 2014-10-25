use strict; use warnings;

# TODO: add the following pseudo-buckets:
# 1. one that uses an invalid install location (e.g. "/invalid/prefix"), and
#    enables build methods that don't have installing logic (e.g. tup, LaTeX)
# 2. one that installs to /usr/local (like with the old "mk" commands; with the
#    added advantage that the pseudo-bucket contains a definite list of stuff
#    installed to /usr or /usr/local without pacman)
# TODO: add support for tup (configure = tup init, build = tup upd, install = ?)
# TODO: add introspection command for buckets and source trees, e.g.
# 1. Print source tree root, bucket and build method for this source tree dir.
# 2. Print source trees registered with this bucket.

package Build::Config;

our $bucket_dir = "$ENV{HOME}/buckets";

package Build::Functions;

use File::Spec::Functions qw(rel2abs abs2rel splitpath);

BEGIN {
    # this environment variable we need definitely
    die '$BUILD_ROOT not set; exiting' unless exists $ENV{BUILD_ROOT};
}

sub build_dir {
    my $path = shift || $ENV{PWD};
    my $rel_path = abs2rel($path, $ENV{BUILD_ROOT});
    if (substr($rel_path, 0, 2) eq '..') {
        return $ENV{BUILD_ROOT} . rel2abs($path);
    } else {
        return rel2abs($path);
    }
}

sub source_dir {
    my $path = shift || $ENV{PWD};
    my $rel_path = abs2rel($path, $ENV{BUILD_ROOT});
    if (substr($rel_path, 0, 2) ne '..') {
        $path =~ s/^\Q$ENV{BUILD_ROOT}\E//;
    }
    return $path;
}

sub mkpath {
    my $path = shift;
    return system('mkdir', '-p', $path) == 0;
}

sub equal_dirs {
    my ($a, $b) = @_;
    $a =~ s{/+$}{};
    $b =~ s{/+$}{};
    return $a eq $b;
}

sub parent_dir {
    my ($path) = @_;
    $path =~ s{/+$}{};
    $path = (splitpath($path))[1];
    $path =~ s{/+$}{};
    return $path;
}

package Build::Bucket;

use Carp;
use File::Spec::Functions qw(rel2abs abs2rel);

sub new {
    my ($class, $bucket) = @_;
    croak 'empty bucket name' unless $bucket;
    croak 'invalid bucket name' unless $bucket =~ m{^[A-Za-z0-9-_+]*$};

    my $path = "$Build::Config::bucket_dir/$bucket";
    my @source_trees;

    if (-d $path) {
        # read list of source trees for bucket
        if (open PATHS, '<', "$path/.buildbucket") {
            @source_trees = grep {$_} map {chomp;$_} <PATHS>;
            close PATHS;
        }
    } else {
        # create new bucket
        print "Creating new bucket $bucket...\n";
        unless (Build::Functions::mkpath($path)) {
            die "Could not create bucket $bucket\n, exiting";
        }
    }

    return bless {
        name  => $bucket,
        path  => $path,
        trees => \@source_trees,
    }, $class;
}

sub path { +shift->{path} }

sub contains_source {
    my ($self, $path) = @_;

    for my $root (@{ $self->{trees} }) {
        my $rel_path = abs2rel($path, $root);
        if ($rel_path eq '.' || substr($rel_path, 0, 2) ne '..') {
            return $root;
        }
    }
    return;
}

sub add_source {
    my ($self, $path) = @_;
    return 0 if $self->contains_source($path);

    open PATHS, '>>', "$self->{path}/.buildbucket"
        or die "Could not write into bucket: $!";
    print PATHS "$path\n";
    close PATHS;
    return 1;
}

sub run_command {
    my ($self, @command) = @_;
    my $path = $self->{path};

    my $env_path = $ENV{PATH} // '';
    my $env_ldlp = $ENV{LD_LIBRARY_PATH} // '';
    my $env_pkgp = $ENV{PKG_CONFIG_PATH} // '';
    my $env_qtpp = $ENV{QT_PLUGIN_PATH} // '';
    my $env_xdgd = $ENV{XDG_DATA_DIRS} // '';
    my $env_xdgc = $ENV{XDG_CONFIG_DIRS} // '';
    my %new_env = (
        PATH            => "$path/bin:$env_path",
        LD_LIBRARY_PATH => "$path/lib:$env_ldlp",
        PKG_CONFIG_PATH => "$path/lib/pkgconfig:$path/share/pkgconfig:$env_pkgp",
        QT_PLUGIN_PATH  => "$path/lib/kde5/plugins:$path/lib/kde4/plugins", # :$env_qtpp", --> not in KF5
        KDEDIR          => $path,
        KDEDIRS         => $path,
        ACLOCAL         => "aclocal -I $path/share/aclocal",
        XDG_DATA_DIRS   => "$path/share:$env_xdgd",
        XDG_CONFIG_DIRS => "$path/etc/xdg:$env_xdgc",
    );

    my %old_env;
    while (my ($name, $value) = each %new_env) {
        $old_env{$name} = $ENV{$name};
        $ENV{$name} = $value;
    }
    my $exit_code = system(@command);
    while (my ($name, $value) = each %old_env) {
        $ENV{$name} = $value;
    }
    return $exit_code;
}

package Build::Source;

use Carp;
use Cwd;

sub new {
    my ($class, $path) = @_;
    croak 'empty source path' unless $path;
    croak 'invalid source path' unless -d $path;
    $path = Build::Functions::source_dir($path);

    my ($tree_bucket, $tree_root);

    # is this source tree already registered with a bucket?
    my @bucket_paths = <$Build::Config::bucket_dir/*>;
    for my $bucket_name (@bucket_paths) {
        next unless -d $bucket_name;
        $bucket_name =~ s{^.*/}{};
        my $bucket = new Build::Bucket($bucket_name);
        $tree_root = $bucket->contains_source($path);
        if ($tree_root) {
            $tree_bucket = $bucket;
            last;
        }
    }

    unless ($tree_bucket) {
        $tree_root = $path;
        print "This source tree is not in any bucket. Add it to one?\n\n";
        print "\tBucket identifier: ";
        chomp ($tree_bucket = <STDIN>);
        print "\n";
        $tree_bucket = new Build::Bucket($tree_bucket);
        $tree_bucket->add_source($tree_root);
    }

    return bless {
        bucket => $tree_bucket,
        root   => $tree_root,
        path   => $path,
    } => $class;
}

sub bucket { +shift->{bucket} }

sub method {
    my ($self) = @_;
    return $self->{method} //= $self->_find_method();
}

sub _find_method {
    my ($self) = @_;
    my $root = $self->{root};

    return 'cmake'   if -f "$root/CMakeLists.txt";
    return 'qmake'   if <$root/*.pro>;
    return 'amake-s' if -f "$root/autogen.sh" or -f "$root/configure";
    return 'make-s'  if -f "$root/Makefile" or -f "$self->{path}/Makefile";
}

sub is_configured {
    my ($self) = @_;
    my $method = $self->method;

    # builds in source tree
    return 1 if $method eq 'make-s';
    if ($method eq 'amake-s') {
        return -f "$self->{root}/Makefile";
    }

    # out-of-source builds
    my $build_root = Build::Functions::build_dir($self->{root});
    return (-f "$build_root/Makefile" or -f "$build_root/build.ninja");
}

sub force_configure {
    my ($self, @args) = @_;
    $self->{force_configure} = 1;
    $self->configure(@args);
    $self->{force_configure} = 0;
}

sub configure { # first of three building steps
    my ($self, @args) = @_;

    # already configured and no args given? -> nothing to do, return success
    unless ($self->{force_configure}) {
        return 1 if $self->is_configured and @args == 0;
    }

    my $method = $self->method;
    my $build_root = Build::Functions::build_dir($self->{root});
    my $cwd = Cwd::cwd();

    if ($method eq 'cmake') {
        if (not -f 'CMakeCache.txt') {
            # initial configuration -> need to add some defaults to @args
            unshift @args, '-DCMAKE_BUILD_TYPE=RelWithDebInfo';
            # install prefix is pushed instead of unshifted because we don't
            # want @args to override it
            push @args, '-DCMAKE_INSTALL_PREFIX=' . $self->bucket->path;
        }
        Build::Functions::mkpath($build_root) or die 'could not create build root';
        chdir $build_root;
        my $exit_code = $self->bucket->run_command('cmake', @args, $self->{root});
        chdir $cwd;
        return $exit_code == 0;
    }

    elsif ($method eq 'qmake') {
        Build::Functions::mkpath($build_root) or die 'could not create build root';
        chdir $build_root;
        # TODO: use $self->bucket->path
        my $exit_code = $self->bucket->run_command('qmake', @args, $self->{root});
        chdir $cwd;
        return $exit_code == 0;
    }

    elsif ($method eq 'amake-s') {
        my $root = $self->{root};
        my $configurer = "$self->{root}/autogen.sh";
        $configurer = "$self->{root}/configure" unless -f $configurer;
        push @args, '--prefix=' . $self->bucket->path;
        chdir $root;
        my $exit_code = $self->bucket->run_command($configurer, @args);
        chdir $cwd;
        return $exit_code == 0;
    }

    die 'we should not get to this point in the code, exiting';
}

sub _find_nearest_make_builddir {
    my ($self) = @_;
    return Build::Functions::source_dir($self->{path})
        if $self->method eq 'make-s' or $self->method eq 'amake-s';

    # Start from the build dir for the selected path, and ascend until a
    # Makefile is found (but stop at the source tree root). Returns the build
    # directory where a Makefile has been found.
    my $build_path = Build::Functions::build_dir($self->{path});
    my $build_root = Build::Functions::build_dir($self->{root});

    # starting from $build_path, ascend until a Makefile is found
    # (but not further than $build_root)
    until (Build::Functions::equal_dirs($build_path, $build_root)) {
        last if -f "$build_path/Makefile" or -f "$build_path/build.ninja";
        $build_path = Build::Functions::parent_dir($build_path);
    }
    return $build_path;
}

sub build { # second of three building steps
    my ($self, @args) = @_;

    my $cwd = Cwd::cwd();
    my $build_dir = $self->_find_nearest_make_builddir();

    # adjust to number of CPU cores (defaults to -j1 if $NUMCPUCORES is not set)
    unshift @args, ('-j' . ($ENV{NUMCPUCORES} + 1));

    chdir $build_dir;
    my $exit_code;
    if (-f "$build_dir/build.ninja") {
        $exit_code = $self->bucket->run_command('ninja', @args);
    } else {
        $exit_code = $self->bucket->run_command('make', @args);
    }
    chdir $cwd;
    return $exit_code == 0;
}

sub update { # runs two of three building steps (configure-build, not install!)
    my ($self) = @_;

    unless ($self->is_configured) {
        my $success = $self->configure;
        return 0 unless $success;
    }
    return $self->build;
}

sub install {
    my ($self) = @_;
    my $cwd = Cwd::cwd();
    my $build_dir = $self->_find_nearest_make_builddir();

    # find which install target to use (CMake-based KDE projects generate an
    # "install/fast" target which is, well, faster)
    my $target = 'install';
    if (open MF, '<', "$build_dir/Makefile") {
        while (<MF>) {
            if (m{^install/fast}) {
                $target = 'install/fast';
                last;
            }
        }
        close MF;
    }

    # adjust to number of CPU cores (defaults to -j1 if $NUMCPUCORES is not set)
    my @args = ('-j' . ($ENV{NUMCPUCORES} + 1));

    chdir $build_dir;
    my $exit_code;
    if (-f "$build_dir/build.ninja") {
        $exit_code = $self->bucket->run_command('ninja', @args, $target);
    } else {
        $exit_code = $self->bucket->run_command('make', @args, $target);
    }
    chdir $cwd;
    return $exit_code == 0;
}

1;
__END__
