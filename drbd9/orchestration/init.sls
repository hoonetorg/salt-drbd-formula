#!jinja|yaml
{%- set node_ids = salt['pillar.get']('drbd9:nodes').keys() -%}
{%- set admin_node_id = node_ids[0] -%}
{%- set node_ids_disk = [] -%}
{%- set node_ids_diskless = [] -%}
{%- for node, node_data in salt['pillar.get']('drbd9:nodes').items() -%}
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


drbd9_orchestration__clean_cache:
  cmd.run:
    - name: |

        salt-run cache.clear_all tgt='*' && \
        salt '*' saltutil.sync_all && \
        echo
        #rm /var/cache/salt/master/minions/*/*

drbd9_orchestration__install:
  salt.state:
    - tgt: {{node_ids|json}}
    - tgt_type: list
    - expect_minions: True
    - saltenv: {{saltenv}}
    - sls: drbd9
    - require_in:
      - salt: drbd9_orchestration__resources_prep

drbd9_orchestration__resources_prep:
  salt.state:
    - tgt: {{node_ids_disk|json}}
    - tgt_type: list
    - expect_minions: True
    - saltenv: {{saltenv}}
    - sls: drbd9.resources_prep
    - require_in:
      - salt: drbd9_orchestration__resources_file

drbd9_orchestration__resources_file:
  salt.state:
    - tgt: {{node_ids|json}}
    - tgt_type: list
    - expect_minions: True
    - saltenv: {{saltenv}}
    - sls: drbd9.resources_file
    - require_in:
      - salt: drbd9_orchestration__resources_md

drbd9_orchestration__resources_md:
  salt.state:
    - tgt: {{node_ids_disk|json}}
    - tgt_type: list
    - expect_minions: True
    - saltenv: {{saltenv}}
    - sls: drbd9.resources_md
    - require_in:
      - salt: drbd9_orchestration__resources_up

drbd9_orchestration__resources_up:
  salt.state:
    - tgt: {{node_ids_disk|json}}
    - tgt_type: list
    - expect_minions: True
    - saltenv: {{saltenv}}
    - sls: drbd9.resources_up
    - require_in:
      - salt: drbd9_orchestration__resources_init

drbd9_orchestration__resources_init:
  salt.state:
    - tgt: {{node_ids_disk|json}}
    - tgt_type: list
    - expect_minions: True
    - saltenv: {{saltenv}}
    - sls: drbd9.resources_init
    - require_in:
      - salt: drbd9_orchestration__resources_fs

drbd9_orchestration__resources_fs:
  salt.state:
    - tgt: {{node_ids_disk|json}}
    - tgt_type: list
    - expect_minions: True
    - saltenv: {{saltenv}}
    - sls: drbd9.resources_fs
    - require_in:
      - salt: drbd9_orchestration__pcs

drbd9_orchestration__pcs:
  salt.state:
    - tgt: {{admin_node_id}}
    - expect_minions: True
    - saltenv: {{saltenv}}
    - sls: drbd9.pcs
