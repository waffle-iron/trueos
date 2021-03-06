export RESOURCEDIR=/home/brd/pkg/tests/frontend
export OS=`uname -s`
export PATH=$(atf_get_srcdir)/../../src/:${PATH}
#export LD_LIBRARY_PATH=$(atf_get_srcdir)/../../libpkg/.libs/
#export DYLD_LIBRARY_PATH=$(atf_get_srcdir)/../../libpkg/.libs/
export INSTALL_AS_USER=yes
export PKG_DBDIR=.
export NO_TICK=yes
jailed=$(sysctl -n security.jail.jailed 2>/dev/null || :)
if [ "$jailed" = "1" ]; then
	export JAILED="[`hostname`] "
fi
if [ "${OS}" = "Linux" ]; then
	export PROGNAME="lt-pkg"
else
	export PROGNAME="pkg"
fi

tests_init()
{
	TESTS="$@"
	export TESTS
	for t; do
		case " ${CLEANUP:-ENOCLEANUP} " in
		*\ $t\ *) atf_test_case $t cleanup ;;
		*) atf_test_case $t ;;
		esac
	done
}

atf_init_test_cases() {
	for t in ${TESTS}; do
		atf_add_test_case $t
	done
}

atf_skip_on() {
	if [ "${OS}" = "$1" ]; then
		shift
		atf_skip "$@"
	fi
}

new_pkg() {
	cat << EOF > $1.ucl
name: $2
origin: $2
version: "$3"
maintainer: test
categories: [test]
comment: a test
www: http://test
prefix: ${4}
abi: "*"
desc: <<EOD
This is a test
EOD
EOF
}

new_manifest() {
	cat << EOF > +MANIFEST
name: "$1"
origin: $1"
version: "$2"
arch: "freebsd:*"
maintainer: "test"
prefix: "${3}"
www: "http://test"
comment: "a test"
desc: "This is a test"
EOF
}
