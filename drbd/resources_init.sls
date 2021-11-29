# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "drbd/map.jinja" import drbd with context %}

{% set node_ids = drbd.nodes.keys()|sort %}
{% set admin_node_id = node_ids[0] %}
{% set my_id = grains['id'] %}
# node_ids: {{node_ids}}
# admin_node_id: {{admin_node_id}}
# my_id: {{my_id}}

{% if my_id in [ admin_node_id ] %}

{% for resource, resource_data in drbd.resources.items()|sort %}
  {% for volume, volume_data in resource_data.volumes.items()|sort %}
    {% set init_done = salt['grains.get']('drbd:resources:' + resource|string + ':' + volume|string + ':init', False) %}
# resource={{resource}}, volume={{volume}}, init_done={{ init_done }}
      {% if not init_done %}

drbd_resources_init__{{ resource }}_{{ volume }}_new_current_uuid:
  cmd.run:
    - name: drbdadm --verbose -- --clear-bitmap new-current-uuid  {{ resource }}/{{ volume }}
  {% if drbd.version in [ '8' ] %}
    - unless: drbdadm -- get-gi {{ resource }}/{{ volume }} |grep -w -v '000000000000000[0-9]:0000000000000000:0000000000000000:0000000000000000:0:0:0:1:0:1:0'
  {% elif drbd.version in [ '9' ] %}
    - unless: drbdadm -- get-gi {{ resource }}/{{ volume }} |grep -w -v '000000000000000[0-9]:0000000000000000:0000000000000000:0000000000000000:0:0:0:0:0:0:0:1:1:0:0:1'
  {% endif %}


drbd_resources_init__{{ resource }}_{{ volume }}_set_grain_successful:
  grains.present:
    - name: drbd:resources:{{ resource }}:{{ volume }}:init
    - value: True
    - require:
      - cmd: drbd_resources_init__{{ resource }}_{{ volume }}_new_current_uuid

      {% endif %}
    {% endfor %}
  {% endfor %}

{% endif %}

drbd_resources_init__empty_sls_prevent_error:
  cmd.run:
    - name: "true"
    - unless: "true"

