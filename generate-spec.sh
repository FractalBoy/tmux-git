#!/bin/sh

# Use GITHUB_TOKEN if available for authentication
if [ -n "$GITHUB_TOKEN" ]; then
    AUTH_HEADER="Authorization: token $GITHUB_TOKEN"
else
    AUTH_HEADER=""
fi

git_commit_sha=$(curl -H "$AUTH_HEADER" -s https://api.github.com/repos/tmux/tmux/commits/master | jq -r .sha | cut -c1-8)
tmux_version=$(curl -s https://raw.githubusercontent.com/tmux/tmux/master/configure.ac | awk -F'next-' '/AC_INIT/ { print $2 }' | sed 's/)//')

cat > tmux.spec <<EOF
Name:           tmux
Version:        ${tmux_version}
Release:        1.git${git_commit_sha}%{?dist}
Summary:        Terminal multiplexer

License:        ISC
URL:            https://github.com/tmux/tmux

Source0:        https://github.com/tmux/tmux/archive/refs/heads/master.zip

Conflicts:      tmux

BuildRequires:  unzip
BuildRequires:  gcc
BuildRequires:  make
BuildRequires:  bison
BuildRequires:  libevent-devel
BuildRequires:  ncurses-devel
BuildRequires:  utf8proc-devel
BuildRequires:  libutempter-devel
BuildRequires:  jemalloc-devel
BuildRequires:  autoconf
BuildRequires:  automake
BuildRequires:  pkgconf-pkg-config

%description
tmux git snapshot (tracks tmux/tmux master).
Git commit: ${git_commit_sha}

%prep
%setup -q -n tmux-master

%build
sh ./autogen.sh
%configure
%make_build

%install
%make_install

%files
%license COPYING
%doc README*
%{_bindir}/tmux
%{_mandir}/man1/tmux.1*

%changelog
* Mon Dec 22 2025 Marc Reisner <reisner.marc@gmail.com> - ${tmux_version}-1.git${git_commit_sha}
- Git snapshot build
EOF
