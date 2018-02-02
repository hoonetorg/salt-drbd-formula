# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "drbd9/map.jinja" import drbd9 with context %}

drbd9_service__service:
  service.{{ drbd9.service.state }}:
    - name: {{ drbd9.service.name }}
{% if drbd9.service.state in [ 'running', 'dead' ] %}
    - enable: {{ drbd9.service.enable }}
{% endif %}

