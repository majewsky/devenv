#!/usr/bin/perl

sub _entry {
    my @args = @_;

    # check that $B and $S are available
    die '$B and/or $S not set; exiting'
        unless exists $ENV{B} and exists $ENV{S};

    # disambiguate command word
    my $command = shift @args;
    my %commands = (
        make            => \&make,
        cmake           => \&cmake,
        cmake_install   => \&cmake_install,
        cmake_uninstall => \&cmake_uninstall,
        qmake           => \&qmake,
    );
    die qq{unknown command "$command", exiting}
        unless $commands{$command};
    exit $commands{$command}->(@args);
}

############################################################
# utility library

sub make_args {
    return (
        '-j' . ($ENV{NUMCPUCORES} + 1),
    );
}

sub check_run {
    return (system @_) == 0;
}

sub goto_build_dir {
    unless (-d $ENV{B}) {
        check_run("mkdir", "-p", $ENV{B})
            or die 'could not create build directory, exiting';
    }
    chdir($ENV{B});
}

sub goto_source_dir {
    chdir($ENV{S});
}

############################################################
# public interface commands

sub make {
    my @args = @_;

    if (-d "$ENV{S}/.tup") {
        goto_source_dir();
        check_run('tup', 'upd') or return 1;
        return 0;
    }

    if (-f "$ENV{B}/Makefile") {
        goto_build_dir();
    } else {
        goto_source_dir();
    }
    check_run('make', make_args(), @args) or return 1;
    return 0;
}

sub cmake {
    my @args = @_;
    goto_build_dir();

    if (! -f 'CMakeCache.txt' && -f "$ENV{S}/CMakeLists.txt") {
        # "build.pl cmake" is run for the first time
        my $msg = 'No CMake cache found. Initialize CMake now?';
        my $result = check_run('dialog', '--yesno', $msg, 5, 50);
        if ($result) {
            # give @args to cmake to initialize build
            check_run(
                qw(cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo),
                @args, $ENV{S}
            ) or return 1;
        } else {
            # suppress future questions by touching CMakeCache.txt
            open FILE, 'CMakeCache.txt' or return 1;
        }
    } elsif (@args) {
        # "build.pl cmake" is re-run -> update CMake configuration
        check_run('cmake', @args, '.') or return 1;
    }

    return make();
}

sub cmake_install {
    my $exitcode = &cmake; # NOTE: @_ consumed here
    return $exitcode if $exitcode;

    goto_build_dir();

    # check which make target to use for installing
    open MF, 'Makefile' or die "could not open Makefile: $!";
    my $target = 'install';
    while (<MF>) {
        if (m{^install/fast}) {
            $target = 'install/fast';
            last;
        }
    }
    close MF;

    check_run('make', make_args(), $target) or return 1;
    return 0;
}

sub cmake_uninstall {
    # NOTE: @_ unused

    goto_build_dir();
    check_run('make', make_args(), 'uninstall') or return 1;
    return 0;
}

sub qmake {
    my @args = @_;
    goto_build_dir();

    # run qmake for initialization or to update settings
    my @project_files = <$ENV{S}/*.pro>;
    if (@args || (!-f 'Makefile' && @project_files)) {
        check_run('qmake', @args, $ENV{S}) or return 1;
    }

    return make();
}

# this must be the last line
_entry(@ARGV);
