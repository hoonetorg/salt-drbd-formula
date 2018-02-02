# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "drbd9/map.jinja" import drbd9 with context %}

drbd9_install__pkg:
  pkg.installed:
    - pkgs: {{ drbd9.pkgs }}
