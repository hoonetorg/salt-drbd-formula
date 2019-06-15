#!jinja|yaml
{%- set node_ids = salt['pillar.get']('drbd:nodes').keys() -%}
{%- set admin_node_id = node_ids[0] -%}
{%- set node_ids_disk = [] -%}
{%- set node_ids_diskless = [] -%}
{%- for node, node_data in salt['pillar.get']('drbd:nodes').items() -%}
  {%- if node_data.get('diskless', False) -%}
    {%- do node_ids_diskless.append(node) -%} 
  {%- else -%}
    {%- do node_ids_disk.append(node) -%} 
  {%- endif -%}
{%- endfor -%}
     

# node_ids: {{node_ids|json}}
# admin_node_id: {{admin_node_id}}
# node_ids_disk: {{node_ids_disk|json}}
# node_ids_diskless: {{node_ids_diskless|json}}

#salt-run cache.clear_all tgt="{{node_ids|join(',')}}" tgt_type="list"
drbd_orchestration__clear_all:
  salt.runner:
    - name: cache.clear_all
    - tgt: {{node_ids|json}}
    - tgt_type: list
    - require_in:
      - salt: drbd_orchestration__sync_all

#salt -L '{{node_ids|join(',')}}' saltutil.sync_all
drbd_orchestration__sync_all:
  salt.function:
    - name: saltutil.sync_all
    - tgt: {{node_ids|json}}
    - tgt_type: list
    - require_in:
      - salt: drbd_orchestration__install

#FIXME: rm /var/cache/salt/master/minions/*/*

drbd_orchestration__install:
  salt.state:
    - tgt: {{node_ids|json}}
    - tgt_type: list
    - expect_minions: True
    - saltenv: {{saltenv}}
    - sls: drbd
    - require_in:
      - salt: drbd_orchestration__resources_prep

drbd_orchestration__resources_prep:
  salt.state:
    - tgt: {{node_ids_disk|json}}
    - tgt_type: list
    - expect_minions: True
    - saltenv: {{saltenv}}
    - sls: drbd.resources_prep
    - require_in:
      - salt: drbd_orchestration__resources_file

drbd_orchestration__resources_file:
  salt.state:
    - tgt: {{node_ids|json}}
    - tgt_type: list
    - expect_minions: True
    - saltenv: {{saltenv}}
    - sls: drbd.resources_file
    - require_in:
      - salt: drbd_orchestration__resources_md

drbd_orchestration__resources_md:
  salt.state:
    - tgt: {{node_ids_disk|json}}
    - tgt_type: list
    - expect_minions: True
    - saltenv: {{saltenv}}
    - sls: drbd.resources_md
    - require_in:
      - salt: drbd_orchestration__resources_up

drbd_orchestration__resources_up:
  salt.state:
    - tgt: {{node_ids_disk|json}}
    - tgt_type: list
    - expect_minions: True
    - saltenv: {{saltenv}}
    - sls: drbd.resources_up
    - require_in:
      - salt: drbd_orchestration__resources_init

drbd_orchestration__resources_init:
  salt.state:
    - tgt: {{node_ids_disk|json}}
    - tgt_type: list
    - expect_minions: True
    - saltenv: {{saltenv}}
    - sls: drbd.resources_init
    - require_in:
      - salt: drbd_orchestration__resources_fs

drbd_orchestration__resources_fs:
  salt.state:
    - tgt: {{node_ids_disk|json}}
    - tgt_type: list
    - expect_minions: True
    - saltenv: {{saltenv}}
    - sls: drbd.resources_fs
    - require_in:
      - salt: drbd_orchestration__pcs

drbd_orchestration__pcs:
  salt.state:
    - tgt: {{admin_node_id}}
    - expect_minions: True
    - saltenv: {{saltenv}}
    - sls: drbd.pcs
