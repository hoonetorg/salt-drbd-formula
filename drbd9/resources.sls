# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "drbd9/map.jinja" import drbd9 with context %}

{% for resource, resource_data in drbd9.resources.items()|sort %}

  {% for volume, volume_data in resource_data.volumes.items()|sort %}

drbd9_resources__{{ resource }}_create_disk_{{ volume }}:
    {% if drbd9.resource_type in [ 'zvol' ] %}
  cmd.run:
    - name: zfs create -s -b4k -V {{volume_data.size}}MiB {{drbd9.resource_pool}}/{{ resource }}_{{ volume }}
    - unless: zfs list {{drbd9.resource_pool}}/{{ resource }}_{{ volume }}
    #- require:
    #  - FIXME

      {% if volume_data.opts is defined and volume_data.opts %}
        {% for volumeopt, volumeopt_data in volume_data.opts.items()|sort %}
drbd9_resources_{{ resource }}_{{volume}}_{{volumeopt}}:
  cmd.run:
    - name: zfs set {{volumeopt}}={{volumeopt_data}} {{drbd9.resource_pool}}/{{ resource }}_{{ volume }}
    - unless: test "`zfs get -H -p -o value {{volumeopt}} {{drbd9.resource_pool}}/{{ resource }}_{{ volume }}`" == "{{volumeopt_data}}"
    - require:
      - cmd: zfs__pool_import_{{pool}}
         {% endfor %}
      {% endif %}
    {% endif %}
    
    {% if volume_data.get('meta_disk', False) %}
drbd9_resources__{{ resource }}_create_meta_disk_{{ volume }}:
      {% if drbd9.resource_type_meta in [ 'lvm' ] %}
         {% set meta_disk_size = ( ( ( ( ( volume_data.size|int * 2048) / ( 2 ** 18 ) ) * 8 * 31 ) + 72 ) / 2048 ) %}
  lvm.lv_present:
    - name: {{ resource }}_{{ volume }}_meta
    - vgname: {{ drbd9.resource_pool_meta }}
    - size: {{ meta_disk_size|round(method='ceil')|int }}MiB
    # size = ( ( ( ( {{ volume_data.size|int }}MiB * 2048 [convert MiB to sectors] ) / ( 2 ** 18 ) * 8 * 31 [max number of peers] ) + 72 ) / 2048 [convert sectors to MiB]) = {{ meta_disk_size }} |round(method='ceil')|int = {{ meta_disk_size|round(method='ceil')|int }}
    #- require:
    #  - FIXME
      {% endif %}
    {% endif %}
  {% endfor %}

drbd9_resources__{{ resource }}_resfile:
  file.managed:
    - name: /etc/drbd.d/{{ resource }}.res
    - source: salt://drbd9/files/res.jinja
    - template: jinja
    - context:
      resource:      {{ resource|json }}
      resource_data: {{ resource_data|json }}
      nodes:         {{ drbd9.nodes|json }}
    - mode: 644
    - user: root
    - group: root


  {% for volume, volume_data in resource_data.volumes.items()|sort %}
    {% set init_done = salt['grains.get']('drbd9:resources:' + resource|string + ':' + volume|string + ':init', False) %}
# resource={{resource}}, volume={{volume}}, init_done={{ init_done }}
    {% if not init_done %}

drbd9_resources__{{ resource }}_{{ volume }}_create_md:
  cmd.run:
    - name: drbdadm --verbose -- --force create-md {{ resource }}/{{ volume }}
    - unless: drbdadm --verbose -- dstate {{ resource }}/{{ volume }}
    #- require:
    #  - FIXME

    {% endif %}
  {% endfor %}
{% endfor %}

drbd9_resources__empty_sls_prevent_error:
  cmd.run:
    - name: true
    - unless: true
