#!/usr/bin/python2

import pwd, os, os.path as op, socket, sys, subprocess as sp

def catFile(file):
    """ Returns the content of the given file. No exception handling. """
    return "".join(open(file).readlines())

def colored(string, color):
    """ Wraps a string in terminal escape sequences to activate given color. """
    return "\033[%sm%s\033[0m" % (color, string)

class NotARepoException(Exception):
    pass

def recognizeGitRepo(path):
    """ Returns a triple of repo path, path in repo, and repo status.
        E.g. ("/foo", "bar", "on branch master at 631d7a2") for
        path == "/foo/bar" and os.path.exists("/foo/.git").

        Throws NotARepoException if .git cannot be found.
    """
    basePath = op.realpath(path)
    subPath = ""
    # find Git repo
    while not op.exists(op.join(basePath, ".git")):
        # ascend in directory hierarchy if possible
        basePath, newSubDir = op.split(basePath)
        subPath = op.join(newSubDir, subPath)
        # root directory reached? -> not in Git repo
        if newSubDir == "":
            raise NotARepoException

    # determine current branch and commit
    gitDir = op.join(basePath, ".git")
    headRef = catFile(op.join(gitDir, "HEAD")).strip()
    if headRef.startswith("ref: refs/"):
        refSpec = headRef[5:]
        headRef2 = headRef[10:]
        if headRef2.startswith("heads/"):
            # current HEAD is a branch
            branch = headRef2[6:]
        else:
            # current HEAD is a remote or tag -> include type specification
            branch = headRef2
        branchSpec = "branch " + branch
        # read corresponding file to find commit
        commit = catFile(op.join(gitDir, refSpec)).strip()
        if commit == "":
            packedRefs = open(op.join(gitDir, "packed-refs")).readlines()
            packedRefs = map(str.strip(), packedRefs)
            for packedRef in packedRefs:
                if packedRef.endswith(refSpec):
                    commit = packedRef[0:40]
                    break
    else:
        # current HEAD is detached
        branchSpec = colored("no branch", "1;41")
        commit = headRef

    return basePath, subPath, "on %s at %s" % (branchSpec, commit[0:7])

def recognizeSvnRepo(path):
    """ Like recognizeGitRepo, but for SVN repos. Repo status message looks like
        "on revision 42".

        Throws NotARepoException if .svn cannot be found.
    """
    basePath = op.realpath(path)
    subPath = ""
    # find SVN repo
    if not op.exists(op.join(basePath, ".svn")):
        raise NotARepoException
    while op.exists(op.join(op.dirname(basePath), ".svn")):
        # ascend in directory hierarchy as far as possible
        basePath, newSubDir = op.split(basePath)
        subPath = op.join(newSubDir, subPath)

    # ask `svn info` for revision
    svnInfoOutput = sp.Popen(["svn", "info"], cwd=path, stdout=sp.PIPE).communicate()[0]
    for line in svnInfoOutput.splitlines():
        if line.startswith("Revision: "):
            revision = line[10:]

    return basePath, subPath, "at revision %s" % revision

def toInt(string, default):
    try:
        return int(string)
    except ValueError: # not a number literal
        return int(default)

# start printing
ssw = sys.stdout.write

# print username
username = pwd.getpwuid(os.getuid())[0]
usernameColor = {"root": "0;1;41"}.get(username, "0")
ssw(colored(username, usernameColor))

# print hostname with different color for most hosts
hostname = socket.gethostname()
if hostname.endswith(".site"):
    hostname = hostname[:-5]
elif hostname.endswith(".local"):
    hostname = hostname[:-6]
elif hostname == "vserver3190":
    hostname = "bethselamin.de"

hostnameColor = {
    "magrathea":   "0;32",
    "maximegalon": "0;31",
    "preliumtarn": "0;35"
}.get(hostname, "0;33")
ssw("@" + colored(hostname, hostnameColor))

# print terminal (esp. for identifiying screen)
ssw("-" + os.environ["TERM"] + " ")

# find root build directory (used for displaying cwd inside build tree in condensed form)
buildRoot = op.realpath(os.environ["BUILD_ROOT"])

# find cwd, does it exist?
try:
    cwd = op.realpath(os.getcwd())
    cwdExists = True
except OSError:
    cwd = os.environ.get("PWD")
    cwdExists = False
    # find last existing parent directory and display similar to repo, but with red alert color
    basePath, subPath = cwd, ""
    while not op.exists(basePath):
        basePath, newSubDir = op.split(basePath)
        subPath = op.join(newSubDir, subPath)
    subPath = subPath.rstrip("/")
    if subPath == "":
        ssw(colored(basePath, "1;36"))
    else:
        ssw(colored(basePath + "/", "1;36") + colored(subPath, "1;31"))
    ssw(" " + colored("could not stat cwd", "1;41"))

# is cwd in build tree? -> if so, print and process source dir instead
rel = op.relpath(cwd, buildRoot)
isBuildDir = not rel.startswith("..")
if isBuildDir:
    cwd = "/" + rel

# check if cwd is in a repo?
if cwdExists:
    isRepo = False

    try:
        repoBase, repoPath, repoStatus = recognizeGitRepo(cwd)
        isRepo = True
    except NotARepoException:
        try:
            repoBase, repoPath, repoStatus = recognizeSvnRepo(cwd)
            isRepo = True
        except NotARepoException:
            pass

    # print cwd, builddir markers and repo status (if any)
    buildDirMarker = colored("BUILD", "1;35")
    if isBuildDir:
        ssw(buildDirMarker + " ")
    if not isRepo:
        ssw(colored(cwd, "1;36"))
    else:
        if repoPath == "":
            ssw(colored(repoBase, "1;36"))
        else:
            repoPath = repoPath.rstrip("/")
            ssw(colored(repoBase + "/", "0;36") + colored(repoPath, "1;36"))
        ssw(" " + repoStatus)

# final prompt: shell name and shell level
shellName = os.environ["PRETTYPROMPT_SHELL"]
shellLevel = toInt(os.environ["SHLVL"], 1)
if "zsh" in shellName:
    shellLevel += 1

ssw("\n%s%i$ " % (shellName, shellLevel))

# DEBUG
ssw("\n")
