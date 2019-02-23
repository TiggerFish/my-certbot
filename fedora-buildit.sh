#!/bin/bash
newcontainer=$(buildah from scratch)
scratchmnt=$(buildah mount $newcontainer)
dnf -y install --setopt install_weak_deps=false --installroot $scratchmnt --releasever=29 httpd hostname sudo certbot python3-certbot-apache python3-certbot-dns-route53 python3-jmespath python3-botocore python3-boto3
buildah run $newcontainer groupadd certbot -g 2000
buildah run $newcontainer useradd certbot -u 2000 -g 2000
buildah run $newcontainer chgrp certbot /var/www/html
buildah run $newcontainer chmod 775 /var/www/html
echo "certbot  ALL=(ALL)       NOPASSWD: /usr/sbin/httpd" > $scratchmnt/etc/sudoers.d/certbot
#echo "certbot  ALL=(ALL)       NOPASSWD: ALL" > $scratchmnt/etc/sudoers.d/certbot
buildah run $newcontainer chmod 400 /etc/sudoers.d/certbot
buildah run $newcontainer /usr/libexec/httpd-ssl-gencerts
# Not functional, just to make the image smaller
echo 'for langs in $(localedef --list-archive | grep -v -i ^en); do localedef $langs --delete-from-archive;done' > $scratchmnt/del-langs
buildah run $newcontainer bash /del-langs
buildah run $newcontainer /bin/rm /del-langs
buildah run $newcontainer mv /usr/lib/locale/locale-archive /usr/lib/locale/locale-archive.tmpl
buildah run $newcontainer build-locale-archive
dnf --installroot $scratchmnt clean all
buildah run $newcontainer rm -rf /var/cache/dnf/*
# End Not functional, just to make the image smaller
buildah config -p 80 -p 443 $newcontainer
buildah config --cmd "/home/certbot/./runit.sh" $newcontainer
buildah config --user 2000:2000 $newcontainer
buildah umount $newcontainer
buildah commit --squash $newcontainer my-certbot:latest
buildah rm $newcontainer
