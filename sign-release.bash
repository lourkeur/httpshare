#!/bin/bash -e

# maintenance script to update the release signature.
# Invoke right before sending into CI for release.

./make_zipapp.py
gpg -ba httpshare.pyz
