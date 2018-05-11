# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "drbd/map.jinja" import drbd with context %}

drbd_install__pkg:
  pkg.installed:
    - pkgs: {{ drbd.pkgs }}

drbd_install__drbdmigrate:
  file.managed:
    - name: /usr/local/sbin/drbdmigrate
    - source: salt://drbd/files/drbdmigrate
    - mode: 755
    - user: root
    - group: root

### FIXME 
#drbd_install__drbdtop:
#curl -L -o /usr/local/sbin/drbdtop https://github.com/LINBIT/drbdtop/releases/download/v0.1/drbdtop-linux-amd64 && chmod +x /usr/local/sbin/drbdtop
