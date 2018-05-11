# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "drbd/map.jinja" import drbd with context %}
{% set node_ids = drbd.nodes.keys()|sort %}
{% set admin_node_id = node_ids[0] %}
{% set my_id = grains['id'] %}
# node_ids: {{node_ids}}
# admin_node_id: {{admin_node_id}}
# my_id: {{my_id}}



{% for resource, resource_data in drbd.resources.items()|sort %}

{% set resource_up = { 'bring_up': False } %}

  {% for volume, volume_data in resource_data.volumes.items()|sort %}
    {% set init_done = salt['grains.get']('drbd:resources:' + resource|string + ':' + volume|string + ':init', False) %}
# resource={{resource}}, volume={{volume}}, init_done={{ init_done }}
    {% if not init_done %}
      {% do resource_up.update( { 'bring_up': True } ) %}
    {% endif %}
    {% if volume_data.get('fstype', False) %}
      {% set initfs_done = salt['grains.get']('drbd:resources:' + resource|string + ':' + volume|string + ':initfs', False) %}
# resource={{resource}}, volume={{volume}}, initfs_done={{ initfs_done }}
      {% if not initfs_done %}
        {% do resource_up.update( { 'bring_up': True } ) %}
      {% endif %}
    {% endif %}
  {% endfor %}

#resource_up: {{ resource_up }}

  {% if resource_up.get('bring_up', False) %}
drbd_resources_up__{{ resource }}_up:
  cmd.run:
    - name: drbdadm --verbose -- up {{ resource }}
    - unless: drbdadm --verbose -- cstate {{ resource }} 

drbd_resources_up__{{ resource }}_adjust:
  cmd.run:
    - name: drbdadm --verbose -- adjust {{ resource }}
    - onlyif: test -n "`drbdadm -d --verbose -- adjust  {{ resource }}`"

    {% if my_id not in [ admin_node_id ] %}
      {% for volume, volume_data in resource_data.volumes.items()|sort %}
        {% set init_done = salt['grains.get']('drbd:resources:' + resource|string + ':' + volume|string + ':init', False) %}
        {% if not init_done %}
drbd_resources_up__{{ resource }}_{{ volume }}_set_grain_successful:
  grains.present:
    - name: drbd:resources:{{ resource }}:{{ volume }}:init
    - value: True
    - require:
      - cmd: drbd_resources_up__{{ resource }}_up
      - cmd: drbd_resources_up__{{ resource }}_adjust
        {% endif %}

        {% if volume_data.get('fstype', False) %}
          {% set initfs_done = salt['grains.get']('drbd:resources:' + resource|string + ':' + volume|string + ':initfs', False) %}
          {% if not initfs_done %}
drbd_resources_up__{{ resource }}_{{ volume }}_set_grain_fs_successful:
  grains.present:
    - name: drbd:resources:{{ resource }}:{{ volume }}:initfs
    - value: True
    - require:
      - cmd: drbd_resources_up__{{ resource }}_up
      - cmd: drbd_resources_up__{{ resource }}_adjust
          {% endif %}
        {% endif %}

      {% endfor %}
    {% endif %}

  {% endif %}

{% endfor %}

drbd_resources_up__empty_sls_prevent_error:
  cmd.run:
    - name: true
    - unless: true
