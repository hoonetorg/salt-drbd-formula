# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "drbd/map.jinja" import drbd with context %}

{% for resource, resource_data in drbd.resources.items()|sort %}

  {% for volume, volume_data in resource_data.volumes.items()|sort %}
    {% set init_done = salt['grains.get']('drbd:resources:' + resource|string + ':' + volume|string + ':init', False) %}
# resource={{resource}}, volume={{volume}}, init_done={{ init_done }}
    {% if not init_done %}

drbd_resources_md__{{ resource }}_{{ volume }}_create_md:
  cmd.run:
  #{{drbd.version}}
  {% if drbd.version in [ '8' ] %}
    - name: drbdadm --verbose -- --force create-md {{ resource }}/{{ volume }}
  {% elif drbd.version in [ '9' ] %}
    - name: drbdadm --verbose --max-peers=31 -- --force create-md {{ resource }}/{{ volume }}
  {% endif %}
    - unless: drbdadm --verbose -- dstate {{ resource }}/{{ volume }}
    - require_in:
      - cmd: drbd_resources_md__md_done
    {% endif %}
  {% endfor %}
{% endfor %}

drbd_resources_md__md_done:
  cmd.run:
    - name: true
    - unless: true
