#!/usr/bin/python

import os, os.path as op, pwd, re, socket, sys, subprocess as sp

def catFile(file):
    """ Returns the content of the given file. No exception handling. """
    try:
        return "".join(open(file).readlines())
    except IOError:
        return ""

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
        if commit == "" and op.exists(op.join(gitDir, "packed-refs")):
            packedRefs = open(op.join(gitDir, "packed-refs")).readlines()
            packedRefs = map(str.strip, packedRefs)
            for packedRef in packedRefs:
                if packedRef.endswith(refSpec):
                    commit = packedRef[0:40]
                    break
    else:
        # current HEAD is detached
        branchSpec = colored("no branch", "1;41")
        commit = headRef

    if commit == "": # before initial commit
        branchSpec = branchSpec + colored(" before initial commit", "1;30")
        extraInfo = "on %s" % (branchSpec)
    else:
        extraInfo = "on %s at %s" % (branchSpec, commit[0:7])
    return basePath, subPath, extraInfo

def toInt(string, default):
    try:
        return int(string)
    except ValueError: # not a number literal
        return int(default)

# start writing, define shorthand for sys.stdout.write
stdoutBuffer = ""
def ssw(string):
    string = str(string)
    global stdoutBuffer
    stdoutBuffer += string
    sys.stdout.write(string)

# find username and hostname
username = pwd.getpwuid(os.getuid())[0]
hostname = socket.gethostname()
if hostname.endswith(".site"):
    hostname = hostname[:-5]
elif hostname.endswith(".local"):
    hostname = hostname[:-6]
elif hostname == "vserver3190":
    hostname = "bethselamin.de"

# select color for hostname, skip username display for my most common non-root user
commonUser    = os.environ.get("PRETTYPROMPT_COMMONUSER", "stefan")
hostnameColor = os.environ.get("PRETTYPROMPT_HOSTCOLOR",  "0;33")

# print username (with different color for some contexts)
if username != commonUser:
    usernameColor = { "root": "0;1;41" }.get(username, "0")
    ssw(colored(username, usernameColor) + "@")

# print hostname with different color for most hosts
ssw(colored(hostname, hostnameColor))

# print terminal (esp. for identifiying screen)
termName = os.environ["TERM"]
if termName == "xterm-256color":
    ssw(" ")
else:
    ssw("-" + termName + " ")

# find root build directory (used for displaying cwd inside build tree in condensed form)
buildRoot = os.environ["BUILD_ROOT"]
if buildRoot != "":
    buildRoot = op.realpath(buildRoot)

# method to shorten home directory to "~"
def stripHome(path):
    h = os.environ.get("HOME")
    hh = h + "/"
    if path.startswith(hh):
        return path[len(hh):]
    if path.startswith(h):
        return path[len(h):]
    else:
        return path

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
        ssw(colored(stripHome(basePath), "1;36"))
    else:
        ssw(colored(stripHome(basePath) + "/", "1;36") + colored(subPath, "1;31"))
    ssw(" " + colored("could not stat cwd", "1;41"))

# is cwd in build tree? -> if so, print and process source dir instead
if buildRoot == "":
    isBuildDir = False
else:
    rel = op.relpath(cwd, buildRoot)
    isBuildDir = not rel.startswith("..")
    if isBuildDir:
        cwd = op.normpath("/" + rel)

# check if cwd is in a repo?
if cwdExists:
    isRepo = False

    try:
        repoBase, repoPath, repoStatus = recognizeGitRepo(cwd)
        isRepo = True
    except NotARepoException:
        pass

    # print cwd, builddir markers and repo status (if any)
    buildDirMarker = colored("BUILD", "1;35")
    if isBuildDir:
        ssw(buildDirMarker + " ")
    if not isRepo:
        ssw(colored(stripHome(cwd), "1;36"))
    else:
        if repoPath == "":
            ssw(colored(stripHome(repoBase), "1;36"))
        else:
            repoPath = repoPath.rstrip("/")
            ssw(colored(stripHome(repoBase) + "/", "0;36") + colored(repoPath, "1;36"))
        ssw(" " + repoStatus)

# display currently selected cloud (if any)
cloudKey = os.environ.get("CURRENT_OS_CLOUD", "")
if cloudKey != "":
    ssw(colored(" on cloud " + cloudKey, "0;37"))

# how many actual characters have been written?
colorSpecRx = "\033\\[[^m]*m"
printedStr = "".join(re.split(colorSpecRx, stdoutBuffer))
printedLen = len(printedStr)
if not printedStr.endswith(" "):
    ssw(" ")
    printedLen += 1
# draw separation line using terminal width
try:
    termWidth = int(sys.argv[1])
except:
    termWidth = 0
if printedLen < termWidth:
    ssw(colored("-" * (termWidth - printedLen), "1"))

# final prompt: shell name and shell level
shellName = os.environ["PRETTYPROMPT_SHELL"]
shellLevel = toInt(os.environ["SHLVL"], 1)
if "zsh" in shellName:
    shellLevel += 1
shortenedShellName = { "zsh": "Z", "bash": "B" }.get(shellName, shellName)

ssw("\n%s%i$ " % (shortenedShellName, shellLevel))

# DEBUG
ssw("\n")
