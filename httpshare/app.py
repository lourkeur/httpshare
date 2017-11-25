# Copyright 2017 Louis Bettens


import os, pkgutil, sys
import os.path as path
from os.path import abspath, dirname

import bottle
from bottle import abort, redirect, request, response, route, static_file


if sys.version_info < (3,):
    input = raw_input

def confirm(prompt):
    answer = input(prompt + '? [y/n] ')
    return answer in ('Yes', 'yes', 'y')

class Template(bottle.SimpleTemplate):
    def search(self, name, lookup=[]):
        for ext in self.extensions:
            filename = '%s.%s' % (name, ext)
            try:
                self.source = pkgutil.get_data('httpshare', filename)
            except EnvironmentError:
                continue
            return filename

def template(name, *args, **kwargs):
    return bottle.template(name, *args, template_adapter=Template, **kwargs)

@route(('/share/', '/share/<resourcepath:path>'), ('GET', 'POST'))
def share(resourcepath=''):
    config = request.app.config
    directory = config['httpshare.directory'] or '.'
    # the two next lines are taken from bottle.static_file
    root = path.join(abspath(directory), '')
    resource = abspath(path.join(root, resourcepath)) if resourcepath else root

    if not resource.startswith(root):
        abort(403, "Access denied.")
    elif not path.exists(resource):
        abort(404, "File does not exist.")
    elif path.isdir(resource) and request.method == 'GET':
        entries = os.listdir(resource)
        if not config['httpshare.all']:
            entries = [ent for ent in entries if not ent.startswith('.')]
        for i in range(len(entries)):
            if path.isdir(path.join(resource, entries[i])):
                entries[i] += '/'
        entries.sort(key=lambda ent: (
                1 if ent.endswith('/') else 2,
                ent.lower(),
                ))
        index = 'normal_index' if resourcepath else 'home_index'
        response.body = template(index, path=resourcepath, entries=entries)
        return response
    elif request.method == 'GET':
        return static_file(
                resourcepath, root,
                download=True,
                )
    elif path.isdir(resource) and request.method == 'POST':
        payload = request.files['payload']
        if not confirm('Accept incoming file {} in {}'.format(payload.filename, resource)):
            abort(403, 'Upload denied by owner.')
        try:
            payload.save(resource)
        except IOError:
            destination = path.join(resource, payload.filename)
            if not path.isfile(destination):
                # no reason to try again with overwriting on.
                raise
            if not confirm('Really overwrite {}'.format(destination)):
                abort(403, 'Upload denied by owner.')
            payload.save(resource, overwrite=True)
        redirect('')
    else:
        abort(405, 'Unsupported method.')

@route('/')
def home():
    redirect('/share/')

@route('/license')
def license():
    txt = pkgutil.get_data('__main__', 'LICENSE.txt').decode('ascii')
    response.body = template('license_page', txt=txt)
    return response
