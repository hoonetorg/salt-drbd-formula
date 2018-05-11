# -*- coding: utf-8 -*-
# vim: ft=sls
#### resize
##### on all nodes
# lvresize -L <new_meta_size>MiB /dev/<drbd.resource_pool_meta>/<resource>_<volume>_meta
# zfs set volsize=<new_size>MiB <drbd.resource_pool>/<resource>_<volume>
##### on one node
# drbdadm -- --assume-clean resize <resource>/<volume>

{% from "drbd/map.jinja" import drbd with context %}

{% for resource, resource_data in drbd.resources.items()|sort %}

  {% for volume, volume_data in resource_data.volumes.items()|sort %}

drbd_resources_prep__{{ resource }}_create_disk_{{ volume }}:
    {% if drbd.resource_type in [ 'zvol' ] %}
  cmd.run:
    - name: zfs create -s -b4k -V {{volume_data.size}}MiB {{drbd.resource_pool}}/{{ resource }}_{{ volume }}
    - unless: zfs list {{drbd.resource_pool}}/{{ resource }}_{{ volume }}
    - require_in:
      - cmd: drbd_resources_prep__{{resource}}_{{volume}}_prep_done

      {% if volume_data.opts is defined and volume_data.opts %}
        {% for volumeopt, volumeopt_data in volume_data.opts.items()|sort %}
drbd_resources_{{ resource }}_{{volume}}_{{volumeopt}}:
  cmd.run:
    - name: zfs set {{volumeopt}}={{volumeopt_data}} {{drbd.resource_pool}}/{{ resource }}_{{ volume }}
    - unless: test "`zfs get -H -p -o value {{volumeopt}} {{drbd.resource_pool}}/{{ resource }}_{{ volume }}`" == "{{volumeopt_data}}"
    - require:
      - cmd: drbd_resources_prep__{{ resource }}_create_disk_{{ volume }}
    - require_in:
      - cmd: drbd_resources_prep__{{resource}}_{{volume}}_prep_done
         {% endfor %}
      {% endif %}
    {% endif %}
    
    {% if volume_data.get('meta_disk', False) %}
drbd_resources_prep__{{ resource }}_create_meta_disk_{{ volume }}:
      {% if drbd.resource_type_meta in [ 'lvm' ] %}
         {% set meta_disk_size = ( ( ( ( ( volume_data.size|int * 2048) / ( 2 ** 18 ) ) * 8 * 31 ) + 72 ) / 2048 ) %}
  lvm.lv_present:
    - name: {{ resource }}_{{ volume }}_meta
    - vgname: {{ drbd.resource_pool_meta }}
    - size: {{ meta_disk_size|round(method='ceil')|int }}MiB
    # size = ( ( ( ( {{ volume_data.size|int }}MiB * 2048 [convert MiB to sectors] ) / ( 2 ** 18 ) * 8 * 31 [max number of peers] ) + 72 ) / 2048 [convert sectors to MiB]) = {{ meta_disk_size }} |round(method='ceil')|int = {{ meta_disk_size|round(method='ceil')|int }}
    - require_in:
      - cmd: drbd_resources_prep__{{resource}}_{{volume}}_prep_done
      {% endif %}
    {% endif %}

drbd_resources_prep__{{resource}}_{{volume}}_prep_done:
  cmd.run:
    - name: true
    - unless: true
    - require_in:
      - cmd: drbd_resources_prep__prep_done

  {% endfor %}
{% endfor %}

drbd_resources_prep__prep_done:
  cmd.run:
    - name: true
    - unless: true
