# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "drbd9/map.jinja" import drbd9 with context %}

{% for resource, resource_data in drbd9.resources.items()|sort %}
drbd9_resources_up__{{ resource }}_up:
  cmd.run:
    - name: drbdadm --verbose -- up {{ resource }}
    - unless: drbdadm --verbose -- cstate {{ resource }}
    #- require:
    #  - FIXME
{% endfor %}
