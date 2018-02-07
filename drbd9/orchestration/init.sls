#!jinja|yaml
{%- set node_ids = salt['pillar.get']('drbd9:nodes').keys() -%}
{%- set admin_node_id = node_ids[0] -%}

# node_ids: {{node_ids|json}}
# admin_node_id: {{admin_node_id}}

drbd9_orchestration__install:
  salt.state:
    - tgt: {{node_ids|json}}
    - tgt_type: list
    - expect_minions: True
    - saltenv: {{saltenv}}
    - sls: drbd9
    - require_in:
      - salt: drbd9_orchestration__resources

drbd9_orchestration__resources:
  salt.state:
    - tgt: {{node_ids|json}}
    - tgt_type: list
    - expect_minions: True
    - saltenv: {{saltenv}}
    - sls: drbd9.resources
    - require_in:
      - salt: drbd9_orchestration__resources_up

drbd9_orchestration__resources_up:
  salt.state:
    - tgt: {{node_ids|json}}
    - tgt_type: list
    - expect_minions: True
    - saltenv: {{saltenv}}
    - sls: drbd9.resources_up
    - require_in:
      - salt: drbd9_orchestration__resources_init

drbd9_orchestration__resources_init:
  salt.state:
    - tgt: {{admin_node_id}}
    - expect_minions: True
    - saltenv: {{saltenv}}
    - sls: drbd9.resources_init
