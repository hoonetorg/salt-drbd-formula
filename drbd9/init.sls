# -*- coding: utf-8 -*-
# vim: ft=sls

include:
  - drbd9.install
  - drbd9.config
  - drbd9.service

extend:
  drbd9_config__conffile:
    file:
      - require:
        - pkg: drbd9_install__pkg
  drbd9_service__service:
    service:
      - watch:
        - file: drbd9_config__conffile
      - require:
        - pkg: drbd9_install__pkg

