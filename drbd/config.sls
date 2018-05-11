# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "drbd/map.jinja" import drbd with context %}

{% for key, value in drbd.get('conf', {}).get('sysctl', {}).items()|sort %}
drbd_config__sysctl_{{ key }}:
  sysctl.present:
    - name: '{{ key }}'
    - value: {{ value }}
    - config: {{ drbd.sysctl_dir }}/{{ drbd.sysctl_file }}
{% endfor %}

drbd_config__conffile:
  file.managed:
    - name: {{ drbd.conffile }}
    - source: salt://drbd/files/global_common.conf.jinja
    - template: jinja
    - context:
      confdict: {{drbd|json}}
    - mode: 644
    - user: root
    - group: root
