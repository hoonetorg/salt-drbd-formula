# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "drbd9/map.jinja" import drbd9 with context %}

{% for resource, resource_data in drbd9.resources.items()|sort %}
  {% for volume, volume_data in resource_data.volumes.items()|sort %}
drbd9_resources_init__{{ resource }}_{{ volume }}_new_current_uuid:
  cmd.run:
    - name: drbdadm --verbose -- --clear-bitmap new-current-uuid  {{ resource }}/{{ volume }}
    - unless: drbdadm -- get-gi {{ resource }}/{{ volume }} |grep -w -v '000000000000000[0-9]:0000000000000000:0000000000000000:0000000000000000:0:0:0:0:0:0:0:1:1:0:0:1'
    #- require:
    #  - FIXME
  {% endfor %}
{% endfor %}
