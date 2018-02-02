# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "drbd9/map.jinja" import drbd9 with context %}

drbd9_config__conffile:
  file.managed:
    - name: {{ drbd9.conffile }}
    - source: salt://drbd9/files/global_common.conf.jinja
    - template: jinja
    - context:
      confdict: {{drbd9|json}}
    - mode: 644
    - user: root
    - group: root
