# Copyright 2017 Louis Bettens


from collections import namedtuple

version_info = namedtuple('version', 'prefix major minor patch suffix')(
    prefix='',
    major=1,
    minor=0,
    patch=2,
    suffix='pypi',
)

version = '%(major)d.%(minor)d.%(patch)d' % version_info._asdict()

if version_info.prefix:
    version = '%s-%s' % (version_info.prefix, version)

if version_info.suffix:
    version = '%s-%s' % (version, version_info.suffix)

