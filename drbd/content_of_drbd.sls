# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "drbd/map.jinja" import drbd with context %}

/tmp/drbd.yaml:
  file.managed:
    - contents: |
        {{drbd|yaml(False)|indent(8)}}
