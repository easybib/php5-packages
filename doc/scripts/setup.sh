#!/bin/sh

# stop asking questions!
export DEBIAN_FRONTEND=noninteractive

apt-get update -y
apt-get install -y python-software-properties
add-apt-repository ppa:easybib/ppa
add-apt-repository ppa:easybib/test
apt-get install -y build-essential devscripts ubuntu-dev-tools debhelper dh-make diff patch cdbs quilt gnupg fakeroot lintian pbuilder piuparts 
apt-get install -y git-core gnupg vim

####begin pbuilderrc
cat << 'EOF' >/home/vagrant/.pbuilderrc
AUTO_DEBSIGN=yes

UBUNTU_SUITES=("precise" "maverick" "lucid" "karmic" "jaunty" "hardy")
UBUNTU_MIRROR="de.archive.ubuntu.com"

# lucid wählen falls keine Angabe verwendet wird
: ${DIST:="lucid"}
# Architektur amd64 setzen, falls keine angegeben ist
: ${ARCH:="amd64"}

NAME="$DIST"
#include easybib-ppa in mirrors list to build with dependencies to php5-easybib packages
OTHERMIRROR="deb http://ppa.launchpad.net/easybib/test/ubuntu $DIST main"

NAME="$DIST"
#include easybib-ppa in mirrors list to build with dependencies to php5-easybib packages
OTHERMIRROR="deb http://ppa.launchpad.net/easybib/ppa/ubuntu $DIST main"

if [ -n "${ARCH}" ]; then
    NAME="$NAME-$ARCH"
    DEBOOTSTRAPOPTS=("--arch" "$ARCH" "${DEBOOTSTRAPOPTS[@]}")
fi

BASETGZ="$HOME/pbuilder/$NAME-base.tgz"
DISTRIBUTION="$DIST"
BUILDRESULT="$HOME/pbuilder/$NAME/result/"
APTCACHE="$HOME/pbuilder/$NAME/aptcache/"
BUILDPLACE="$HOME/pbuilder/build/"

echo $BASETGZ

if $(echo ${UBUNTU_SUITES[@]} | grep -q $DIST); then
    MIRRORSITE="http://$UBUNTU_MIRROR/ubuntu/"
    COMPONENTS="main restricted universe multiverse"
else
    echo "Unknown distribution: $DIST"
    exit 1
fi
EOF
##############
##end pbuilderrc
##############
sudo -u vagrant

mkdir -p /home/vagrant/pbuilder/build
mkdir -p /home/vagrant/pbuilder/lucid-i386
mkdir -p /home/vagrant/pbuilder/lucid-amd64

chown -R vagrant /home/vagrant/pbuilder

su -c "sudo pbuilder create" vagrant
su -c "ARCH=i386 sudo pbuilder create" vagrant 
