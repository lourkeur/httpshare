#!/usr/bin/env python

import sys
if sys.version_info < (3, 5):
    sys.exit("Python 3.5+ required for zipapp")


import tempfile, zipapp, zipfile

TIMESTAMP = (1980, 1, 1, 0, 0, 0)
COMPRESSION = zipfile.ZIP_DEFLATED
INTERPRETER = '/usr/bin/env python'


with tempfile.TemporaryFile() as temp1, \
     tempfile.TemporaryFile() as temp2:
    zipapp.create_archive('src/', main='httpshare:main', target=temp1)
    temp1.seek(0)
    with zipfile.ZipFile(temp1, 'r') as z1, \
         zipfile.ZipFile(temp2, 'w') as z2:
        for ent in sorted(z1.namelist()):
            z2.writestr(zipfile.ZipInfo(ent, TIMESTAMP), z1.read(ent), COMPRESSION)
    temp2.seek(0)
    zipapp.create_archive(temp2, interpreter=INTERPRETER, target='httpshare.pyz')
