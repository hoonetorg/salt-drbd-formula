# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "drbd9/map.jinja" import drbd9 with context %}

drbd9_install__pkg:
  pkg.installed:
    - pkgs: {{ drbd9.pkgs }}

drbd9_install__drbdmigrate:
  file.managed:
    - name: /usr/local/sbin/drbdmigrate
    - source: salt://drbd9/files/drbdmigrate
    - mode: 755
    - user: root
    - group: root

### FIXME 
#drbd9_install__drbdtop:
#curl -L -o /usr/local/sbin/drbdtop https://github.com/LINBIT/drbdtop/releases/download/v0.1/drbdtop-linux-amd64 && chmod +x /usr/local/sbin/drbdtop
