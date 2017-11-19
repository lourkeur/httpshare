#!/bin/bash

# make the ZIP Application for release.
# This script uses the contents of the current commit. (NOT the worktree neither the index)
# Incidentally, this script doesn't require any version of Python to be installed.

time=$(git show -s --format='%at' HEAD)
(
exec >httpshare.pyz
echo '#!/usr/bin/env python'
# we pass HEAD: instead of HEAD so that no file comment is added to the archive.
# This is because Python doesn't want file comments in PyZ files.
env TZ='' \
faketime "@$time" \
git archive --format=zip HEAD: '**.py' '**.stpl' LICENSE.txt
)
chmod +x httpshare.pyz
