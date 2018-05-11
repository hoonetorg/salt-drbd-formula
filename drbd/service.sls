# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "drbd/map.jinja" import drbd with context %}

drbd_service__service:
  service.{{ drbd.service.state }}:
    - name: {{ drbd.service.name }}
{% if drbd.service.state in [ 'running', 'dead' ] %}
    - enable: {{ drbd.service.enable }}
{% endif %}

