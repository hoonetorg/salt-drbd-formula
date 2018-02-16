# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "drbd9/map.jinja" import drbd9 with context %}

{% for resource, resource_data in drbd9.resources.items()|sort %}

  {% for volume, volume_data in resource_data.volumes.items()|sort %}
    {% set init_done = salt['grains.get']('drbd9:resources:' + resource|string + ':' + volume|string + ':init', False) %}
# resource={{resource}}, volume={{volume}}, init_done={{ init_done }}
    {% if not init_done %}

drbd9_resources_md__{{ resource }}_{{ volume }}_create_md:
  cmd.run:
    - name: drbdadm --verbose --max-peers=31 -- --force create-md {{ resource }}/{{ volume }}
    - unless: drbdadm --verbose -- dstate {{ resource }}/{{ volume }}
    - require_in:
      - cmd: drbd9_resources_md__md_done
    {% endif %}
  {% endfor %}
{% endfor %}

drbd9_resources_md__md_done:
  cmd.run:
    - name: true
    - unless: true
