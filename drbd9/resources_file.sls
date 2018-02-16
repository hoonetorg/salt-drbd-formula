# -*- coding: utf-8 -*-
# vim: ft=sls
### FIXME 
#### diskless node

{% from "drbd9/map.jinja" import drbd9 with context %}

{% for resource, resource_data in drbd9.resources.items()|sort %}

drbd9_resources_file__{{ resource }}_resfile:
  file.managed:
    - name: /etc/drbd.d/{{ resource }}.res
    - source: salt://drbd9/files/res.jinja
    - template: jinja
    - context:
      resource:      {{ resource|json }}
      resource_data: {{ resource_data|json }}
    - mode: 644
    - user: root
    - group: root
    - require_in:
      - cmd: drbd9_resources_file__{{resource}}_file_done

drbd9_resources_file__{{resource}}_file_done:
  cmd.run:
    - name: true
    - unless: true
    - require_in:
      - cmd: drbd9_resources_file__file_done

{% endfor %}

drbd9_resources_file__file_done:
  cmd.run:
    - name: true
    - unless: true
