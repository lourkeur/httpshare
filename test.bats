#!/usr/bin/env bats

# Simple regression tests.

expected_homepage () {
cat <<END
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<html>
    <head>
        <title>httpshare &mdash; Q&amp;D LAN file sharing</title>
    </head>
    <body>
        <h1>Welcome!</h1>
<p>
  You've reached an ephemeral file sharing service launched on a computer near you.
  You can click on directories to browse them, click on files to download them, or use the form at the bottom to upload files.
</p><p>
  This program:
  <a href='/license'>License</a>
  <a href='https://github.com/lourkeur/httpshare'>Development</a>
</p>
<hr/>
<ul>
    <li><a href='b/'>b/</a></li>
    <li><a href='a'>a</a></li>
</ul>
<hr/>
<form enctype='multipart/form-data', method='post'>
  <input type='file', name='payload' />
  <input type='submit', value='OK' />
</form>

    </body>
</html>
END
}

expected_index () {
cat <<END
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<html>
    <head>
        <title>httpshare &mdash; b/</title>
    </head>
    <body>
        <h1>b/</h1>
<ul>
    <li><a href='c'>c</a></li>
</ul>
<hr/>
<form enctype='multipart/form-data', method='post'>
  <input type='file', name='payload' />
  <input type='submit', value='OK' />
</form>

    </body>
</html>
END
}

expected_license_page () {
cat <<END
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<html>
    <head>
        <title>httpshare &mdash; License</title>
    </head>
    <body>
        <pre>
zlib License

Copyright 2017 Louis Bettens

This software is provided &#039;as-is&#039;, without any express or implied warranty.
In no event will the authors be held liable for any damages arising from the
use of this software.

Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute it
freely, subject to the following restrictions:

1. The origin of this software must not be misrepresented; you must not
   claim that you wrote the original software. If you use this software
   in a product, an acknowledgment in the product documentation would be
   appreciated but is not required.
2. Altered source versions must be plainly marked as such, and must not be
   misrepresented as being the original software.
3. This notice may not be removed or altered from any source distribution.

</pre>


    </body>
</html>
END
}

if [ -z "$PYTHON" ]; then
  PYTHON=python
fi

wait_till () {
local tries=0
until "$@"; do
  if ((++tries > 10)); then
    return 1
  fi
  sleep 1
done
}

setup () {
tempdir=$(mktemp -d -p "$BATS_TMPDIR" httpshare.XXXXXX)
cd "$tempdir"
mkdir share
echo "content of a" >share/a
mkdir share/b
echo "content of b/c" >share/b/c
server_dir="$tempdir/share"
server_log="$tempdir/server.log"
exec {into_server_log}>"$server_log"
coproc server (PYTHONUNBUFFERED=y httpshare --address=127.0.0.1 --directory "$server_dir" >&$into_server_log 2>&1)
  found_url () {
    server_url=$(grep '^http://' "$server_log")
    [ -n "$server_url" ]
  }
wait_till found_url
}

yes_server () {
  local question="$1"
  asked () {
    [ "$(tail -n 1 "$server_log")" = "$question? [y/n] " ]
  }
  wait_till asked
  echo >&$into_server_log  # add an eol after the prompt
  echo y >&${server[1]}
}

teardown () {
kill $server_PID
echo "server output:"
cat "$server_log"
echo
cd
rm -rf "$tempdir"
}

@test "homepage displays" {
diff -u <(expected_homepage) <(curl -s -L "$server_url")
}

@test "homepage is the root of the shared directory" {
diff -u <(expected_homepage) <(curl -s "$server_url/share/")
}

@test "correct subdirectory listing" {
diff -u <(expected_index) <(curl -s "$server_url/share/b/")
}

@test "download" {
[ "$(curl -s "$server_url/share/b/c")" = "content of b/c" ]
}

@test "upload a new file" {
echo "content of b/e" > e
curl -s -F "payload=@e" "$server_url/share/b/" &
[ ! -e "$server_dir/b/e" ]
yes_server "Accept incoming file e in $server_dir/b"
created () {
[ -e "$server_dir/b/e" ]
}
wait_till created
[ "$(cat "$server_dir/b/e")" = "content of b/e" ]
[ "$(curl -s "$server_url/share/b/e")" = "content of b/e" ]
}

@test "upload over an existing file" {
echo "new content of b/c" >c
curl -s -F "payload=@c" "$server_url/share/b/" &
[ "$(cat "$server_dir/b/c")" = "content of b/c" ]
yes_server "Accept incoming file c in $server_dir/b"
[ "$(cat "$server_dir/b/c")" = "content of b/c" ]
yes_server "Really overwrite $server_dir/b/c"
overwritten () {
[ "$(cat "$server_dir/b/c")" = "new content of b/c" ]
}
wait_till overwritten
[ "$(curl -s "$server_url/share/b/c")" = "new content of b/c" ]
}

@test "no escaping the root directory" {
diff -u <(expected_homepage) <(curl -s -L "$server_url/share/a/../../../..")
}

@test "license page" {
diff -u <(expected_license_page) <(curl -s -L "$server_url/license")
}
