# Copyright 2019 Louis Bettens


import sys

if sys.version_info < (3,):
    from urlparse import ParseResult, SplitResult, parse_qs, parse_qsl, urldefrag, urljoin, urlparse, urlsplit, urlunparse, urlunsplit
    from urllib import quote, quote_plus, unquote, unquote_plus, urlencode
else:
    from urllib.parse import ParseResult, SplitResult, parse_qs, parse_qsl, quote, quote_plus, unquote, unquote_plus, urldefrag, urlencode, urljoin, urlparse, urlsplit, urlunparse, urlunsplit
