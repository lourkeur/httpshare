#!/bin/bash -e

# interactive script to use to update the subrepos branch in the httpshare repo.
# This solves 2 problems in particular:
# - git-subrepo doesn't work on linked working trees
# - I don't have git-subrepo in my .bashrc

GIT_SUBREPO=~/misc/git-subrepo
TEMP_REPO=$(mktemp -d /tmp/httpshare-subrepos.XXXXX)
cleanup () {
    rm -rf "$TEMP_REPO"
}
shell_in_temprepo () {
  rcfile () {
    cat <<EOF
. ~/.bashrc
. $GIT_SUBREPO/.rc
EOF
  }
  (cd "$TEMP_REPO" && bash --rcfile <(rcfile) -i) || true
}

trap cleanup EXIT
git clone -s . "$TEMP_REPO" -b subrepos

fmt <<EOF
You will drop in a shell inside a temporary repository.
Use 'git subrepo pull' to update the subrepos.
Exit the shell when done.
EOF
shell_in_temprepo

git -C "$TEMP_REPO" push origin +subrepos || {
    fmt <<EOF
'git push' to the original repo failed.
You will drop in an emergency shell.
Try saving your changes some other way.
When you exit this shell, the temporary repository will be deleted.
EOF
  shell_in_temprepo
}
