# Copyright 2017 Louis Bettens


'''
Allow other people on the same network to access a local directory using an
ephemeral http service.  Allows file uploading with local confirmation, and
prints a QRCode at startup.

Usage:
    httpshare [--directory=<directory>] [--address=<address>] [-a | --all]

Options:
    --directory=<directory>
        Specify a directory to share.  Default: current directory
    --address=<address>
        Specify the network address to serve. Default: guess based on
        how the internet is reached.
    -a --all
        include hidden files, like ls -a.
'''


import wsgiref.simple_server
import os
import socket
import sys
import contextlib

import bottle
import docopt
import qrcode

from httpshare import version
app = bottle.load_app('httpshare.app')

print('httpshare version {}'.format(version))

options = docopt.docopt(__doc__)

addr = options['--address']
if addr is None:
    # sockets aren't context managers in Python 2.7
    with contextlib.closing(socket.socket()) as s:
        s.connect(('google.com', 80))
        addr = s.getsockname()[0]

app.config.update('httpshare',
    directory=options['--directory'],
    all=options['--all'],
)

httpd = wsgiref.simple_server.make_server(addr, 0, app)
url = 'http://{}:{}'.format(addr, httpd.server_port)

if sys.stdout.isatty():
    q = qrcode.QRCode()
    q.add_data(url)
    try:
        q.print_ascii(tty=True)
    except UnicodeError:
        q.print_tty()
print(url)

try:
    httpd.serve_forever()
except KeyboardInterrupt:
    pass
