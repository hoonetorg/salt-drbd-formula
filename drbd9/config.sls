# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "drbd9/map.jinja" import drbd9 with context %}

{% for key, value in drbd9.conf.sysctl.items()|sort %}
drbd9_config__sysctl_{{ key }}:
  sysctl.present:
    - name: '{{ key }}'
    - value: {{ value }}
    - config: {{ drbd9.sysctl_dir }}/{{ drbd9.sysctl_file }}
{% endfor %}

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
