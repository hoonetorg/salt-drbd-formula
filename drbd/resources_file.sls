# -*- coding: utf-8 -*-
# vim: ft=sls
### FIXME 
#### diskless node

{% from "drbd/map.jinja" import drbd with context %}

{% for resource, resource_data in drbd.resources.items()|sort %}

drbd_resources_file__{{ resource }}_resfile:
  file.managed:
    - name: /etc/drbd.d/{{ resource }}.res
    - source: salt://drbd/files/res.jinja
    - template: jinja
    - context:
      resource:      {{ resource|json }}
      resource_data: {{ resource_data|json }}
    - mode: 644
    - user: root
    - group: root
    - require_in:
      - cmd: drbd_resources_file__file_done

{% endfor %}

drbd_resources_file__file_done:
  cmd.run:
    - name: true
    - unless: true
