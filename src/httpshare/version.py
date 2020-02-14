# Copyright 2020 Louis Bettens


from collections import namedtuple

version_info = namedtuple('version', 'major minor patch suffix')(
    major=1,
    minor=0,
    patch=7,
    suffix='dev',
)

version = '%(major)d.%(minor)d.%(patch)d' % version_info._asdict()

if version_info.suffix:
    version = '%s-%s' % (version, version_info.suffix)
