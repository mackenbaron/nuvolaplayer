export NUVOLA_WEB_APPS_DIR="web_apps"
export DIORITE_LOG_MESSAGE_CHANNEL="yes"
export DIORITE_DUPLEX_CHANNEL_FATAL_TIMEOUT="yes"
export LD_LIBRARY_PATH="build:$LD_LIBRARY_PATH"

if [ -e /etc/fedora-release ]; then
    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/lib64"
    export PKG_CONFIG_PATH="/usr/local/lib64/pkgconfig:/usr/lib64/pkgconfig"
fi

prompt_prefix='\[\033[1;33m\]Nuvola\[\033[00m\]'
[[ "$PS1" = "$prompt_prefix"* ]] || export PS1="$prompt_prefix $PS1"
unset prompt_prefix

mk_symlinks()
{
    build_datadir="./build/share/nuvolaplayer3"
    mkdir -p "$build_datadir"
    datadirs="www"
    for datadir in $datadirs; do
	if [ ! -e "${build_datadir}/${datadir}" ]; then
	    ln -sv "../../../data/$datadir" "$build_datadir"
	fi
    done 
}

reconf()
{
    python3 ./waf -v distclean configure \
	    --tiliado-oauth2-server="http://localhost:8000" \
	    --tiliado-oauth2-client-id="OEGTluvgDaNH8lPXcN3gkVVTU2aRJBwjmSJDUa8Q" \
	    --tiliado-oauth2-client-secret="uCZvxvarVjfqR0qFZ3d2As1x8xcKjSCZyBQhjMo45UmRd3SUpEXrLCqByU8x1h35VcLQHzRttKbOcinFecEvk8lTHAx5SLGXA5jjnxq83sLWnoB9eQ0T1eRauyo6MSmh" \
	    $WAF_CONFIGURE "$@"
}

rebuild()
{
	python3 ./waf -v distclean configure build \
	    --tiliado-oauth2-server="http://localhost:8000" \
	    --tiliado-oauth2-client-id="OEGTluvgDaNH8lPXcN3gkVVTU2aRJBwjmSJDUa8Q" \
	    --tiliado-oauth2-client-secret="uCZvxvarVjfqR0qFZ3d2As1x8xcKjSCZyBQhjMo45UmRd3SUpEXrLCqByU8x1h35VcLQHzRttKbOcinFecEvk8lTHAx5SLGXA5jjnxq83sLWnoB9eQ0T1eRauyo6MSmh" \
	    $WAF_CONFIGURE "$@"
}

run()
{
	mk_symlinks
	python3 ./waf -v && XDG_DATA_DIRS=build/share:/usr/share:/usr/local/share \
	NUVOLA_LIBDIR=build build/nuvolaplayer3 -D "$@"

}

dbus()
{
	mk_symlinks
	python3 ./waf -v && XDG_DATA_DIRS=build/share:/usr/share:/usr/local/share \
	NUVOLA_LIBDIR=build build/apprunner -D -N eu.tiliado.NuvolaCdk -a "$@"
}

debug_dbus()
{
	mk_symlinks
	python3 ./waf -v && XDG_DATA_DIRS=build/share:/usr/share:/usr/local/share \
	NUVOLA_LIBDIR=build gdb --args build/apprunner -D -N eu.tiliado.NuvolaCdk -a "$@"
}

ctl()
{
    python3 ./waf -v && XDG_DATA_DIRS=build/share:/usr/share:/usr/local/share \
    NUVOLA_LIBDIR=build build/nuvolaplayer3ctl -D "$@"
}

debug()
{
	mk_symlinks
	python3 ./waf -v && XDG_DATA_DIRS=build/share:/usr/share:/usr/local/share \
	NUVOLA_LIBDIR=build gdb --args build/nuvolaplayer3 -D "$@"
}

debug_criticals()
{
	mk_symlinks
	python3 ./waf -v && XDG_DATA_DIRS=build/share:/usr/share:/usr/local/share \
	NUVOLA_LIBDIR=build G_DEBUG=fatal-criticals \
	gdb  --args build/nuvolaplayer3 -D "$@"
}

debug_app_runner()
{
	mk_symlinks
	python3 ./waf -v && XDG_DATA_DIRS=build/share:/usr/share:/usr/local/share \
	NUVOLA_LIBDIR=build NUVOLA_APP_RUNNER_GDB_SERVER='localhost:9090' build/nuvolaplayer3 -D "$@"
}

debug_app_runner_criticals()
{
	mk_symlinks
	python3 ./waf -v && XDG_DATA_DIRS=build/share:/usr/share:/usr/local/share \
	NUVOLA_LIBDIR=build G_DEBUG=fatal-criticals NUVOLA_APP_RUNNER_GDB_SERVER='localhost:9090' \
	build/nuvolaplayer3 -D "$@"
}

debug_app_runner_join()
{
	mk_symlinks
	echo Wait for App Runner process to start, then type "'target remote localhost:9090'" and "'continue'"
	libtool --mode=execute gdb build/apprunner
}

debug_web_worker()
{
	mk_symlinks
	python3 ./waf -v && XDG_DATA_DIRS=build/share:/usr/share:/usr/local/share \
	NUVOLA_LIBDIR=build NUVOLA_WEB_WORKER_SLEEP=30 build/nuvolaplayer3 -D "$@"
}

debug_web_worker_criticals()
{
	mk_symlinks
	python3 ./waf -v && XDG_DATA_DIRS=build/share:/usr/share:/usr/local/share \
	NUVOLA_LIBDIR=build G_DEBUG=fatal-criticals NUVOLA_WEB_WORKER_SLEEP=30 \
	build/nuvolaplayer3 -D "$@"
}

watch_and_build()
{
	while true; do inotifywait -e delete -e create -e modify -r src; sleep 1; ./waf; done
}

build_webgen_doc()
{
    (cd doc; webgen -i . -t theme)
}

build_js_doc()
{
    ./nuvolajsdoc.py
    while true; do inotifywait -e delete -e create -e modify -r src/mainjs doc/theme/templates/jsdoc.html; sleep 1; ./nuvolajsdoc.py; done
}

ulimit -c unlimited
