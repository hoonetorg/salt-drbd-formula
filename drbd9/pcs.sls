# -*- coding: utf-8 -*-
# vim: ft=sls
{%- from "drbd9/map.jinja" import drbd9 with context %}

{% set pcs = drbd9.get('pcs', {}) %}

{% if pcs.drbd9_cib is defined and pcs.drbd9_cib %}
drbd9_pcs__cib_present_{{pcs.drbd9_cib}}:
  pcs.cib_present:
    - cibname: {{pcs.drbd9_cib}}
{% endif %}

{% if 'resources' in pcs %}
{% for resource, resource_data in pcs.resources.items()|sort %}
drbd9_pcs__resource_present_{{resource}}:
  pcs.resource_present:
    - resource_id: {{resource}}
    - resource_type: "{{resource_data.resource_type}}"
    - resource_options: {{resource_data.resource_options|json}}
{% if pcs.drbd9_cib is defined and pcs.drbd9_cib %}
    - require:
      - pcs: drbd9_pcs__cib_present_{{pcs.drbd9_cib}}
    - require_in:
      - pcs: drbd9_pcs__cib_pushed_{{pcs.drbd9_cib}}
    - cibname: {{pcs.drbd9_cib}}
{% endif %}
{% endfor %}
{% endif %}

{% if 'constraints' in pcs %}
{% for constraint, constraint_data in pcs.constraints.items()|sort %}
drbd9_pcs__constraint_present_{{constraint}}:
  pcs.constraint_present:
    - constraint_id: {{constraint}}
    - constraint_type: "{{constraint_data.constraint_type}}"
    - constraint_options: {{constraint_data.constraint_options|json}}
{% if pcs.drbd9_cib is defined and pcs.drbd9_cib %}
    - require:
      - pcs: drbd9_pcs__cib_present_{{pcs.drbd9_cib}}
    - require_in:
      - pcs: drbd9_pcs__cib_pushed_{{pcs.drbd9_cib}}
    - cibname: {{pcs.drbd9_cib}}
{% endif %}
{% endfor %}
{% endif %}

{% if pcs.drbd9_cib is defined and pcs.drbd9_cib %}
drbd9_pcs__cib_pushed_{{pcs.drbd9_cib}}:
  pcs.cib_pushed:
    - cibname: {{pcs.drbd9_cib}}
{% endif %}

drbd9_pcs__empty_sls_prevent_error:
  cmd.run:
    - name: true
    - unless: true
