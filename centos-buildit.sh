#!/bin/bash
newcontainer=$(buildah from scratch)
scratchmnt=$(buildah mount $newcontainer)
yum -y install --installroot $scratchmnt --releasever=7 httpd sudo certbot python2-certbot-apache python2-certbot-dns-route53 python2-jmespath python2-botocore python-boto3 python2-futures
buildah run $newcontainer groupadd certbot -g 2000
buildah run $newcontainer useradd certbot -u 2000 -g 2000
buildah run $newcontainer chgrp certbot /var/www/html
buildah run $newcontainer chmod 775 /var/www/html
echo "certbot  ALL=(ALL)       NOPASSWD: /usr/sbin/httpd" > $scratchmnt/etc/sudoers.d/certbot
#echo "certbot  ALL=(ALL)       NOPASSWD: ALL" > $scratchmnt/etc/sudoers.d/certbot
buildah run $newcontainer chmod 400 /etc/sudoers.d/certbot
buildah run $newcontainer mv /etc/httpd/conf.d/ssl.conf /etc/httpd/conf.d/ssl.conf.bak

# Not functional, just to make the image smaller
yum --installroot $scratchmnt clean all
cat << 'FINIT' > $scratchmnt/del-stuff
#!/bin/bash
for langs in $(localedef --list-archive | grep -v -i ^en);do
   localedef $langs --delete-from-archive
done
mv /usr/lib/locale/locale-archive /usr/lib/locale/locale-archive.tmpl
build-locale-archive
rm -rf /var/lib/yum/*
rm -rf /var/cache/yum/*
rm -rf /usr/share/doc/*
rm -rf /usr/share/backgrounds/*
for dirs in $(find /usr/share/locale/ -maxdepth 1 -type d | grep -v /usr/share/locale/en_ | grep -v /usr/share/locale/$);do
   rm -rf $dirs
done
FINIT
buildah run $newcontainer chmod +x /del-stuff
buildah run $newcontainer /del-stuff
buildah run $newcontainer /bin/rm /del-stuff
# End Not functional, just to make the image smaller

buildah config -p 80 -p 443 $newcontainer
buildah config --cmd "/home/certbot/./runit.sh" $newcontainer
buildah config --user 2000:2000 $newcontainer
buildah umount $newcontainer
buildah commit --squash $newcontainer my-certbot:latest
buildah rm $newcontainer
