# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "drbd9/map.jinja" import drbd9 with context %}

/tmp/drbd9.yaml:
  file.managed:
    - contents: |
        {{drbd9|yaml(False)|indent(8)}}
