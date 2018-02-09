# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "drbd9/map.jinja" import drbd9 with context %}
{% set node_ids = salt['pillar.get']('drbd9:nodes').keys()|sort %}
{% set admin_node_id = node_ids[0] %}
{% set my_id = grains['id'] %}
# node_ids: {{node_ids}}
# admin_node_id: {{admin_node_id}}
# my_id: {{my_id}}



{% for resource, resource_data in drbd9.resources.items()|sort %}

{% set resource_up = { 'bring_up': False } %}

  {% for volume, volume_data in resource_data.volumes.items()|sort %}
    {% set init_done = salt['grains.get']('drbd9:resources:' + resource|string + ':' + volume|string + ':init', False) %}
# resource={{resource}}, volume={{volume}}, init_done={{ init_done }}
    {% if not init_done %}
      {% do resource_up.update( { 'bring_up': True } ) %}
    {% endif %}
  {% endfor %}

#resource_up: {{ resource_up }}

  {% if resource_up.get('bring_up', False) %}
drbd9_resources_up__{{ resource }}_up:
  cmd.run:
    - name: drbdadm --verbose -- up {{ resource }}
    - unless: drbdadm --verbose -- cstate {{ resource }}
    #- require:
    #  - FIXME

    {% if my_id not in [ admin_node_id ] %}
      {% for volume, volume_data in resource_data.volumes.items()|sort %}
drbd9_resources_up__{{ resource }}_{{ volume }}_set_grain_successful:
  grains.present:
    - name: drbd9:resources:{{ resource }}:{{ volume }}:init
    - value: True
    - require:
      - cmd: drbd9_resources_up__{{ resource }}_up
      {% endfor %}
    {% endif %}
  {% endif %}

{% endfor %}

drbd9_resources_up__empty_sls_prevent_error:
  cmd.run:
    - name: true
    - unless: true
