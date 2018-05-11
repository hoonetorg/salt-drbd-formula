# -*- coding: utf-8 -*-
# vim: ft=sls

include:
  - drbd.install
  - drbd.config
  - drbd.service

extend:
  drbd_config__conffile:
    file:
      - require:
        - pkg: drbd_install__pkg
  drbd_service__service:
    service:
      - require:
        - file: drbd_config__conffile
      - require:
        - pkg: drbd_install__pkg

