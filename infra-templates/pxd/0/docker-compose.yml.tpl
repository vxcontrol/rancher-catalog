pxd:
  labels:
    io.rancher.container.dns: 'true'
    io.rancher.container.hostname_override: container_name
    io.rancher.scheduler.affinity:container_label_ne: io.rancher.stack_service.name=$${stack_name}/$${service_name}
    {{- if .Values.SC_LABEL_VALUE }}
    io.rancher.scheduler.affinity:host_label: ${SC_LABEL_VALUE}
    {{- end }}
    io.rancher.container.pull_image: always
  image: registry.vxcontrol.com:8443/pxd:edge
  container_name: px
  ipc: host
  net: host
  privileged: true
  environment:
    CLUSTER_ID: ${CLUSTER_ID}
    KVDB: ${KVDB}
    HDR_DIR: ${HEADER_DIR}
    USE_DISKS: ${USE_DISKS}
    ENABLE_ATTR_CACHE: true
  external_links:
    - ${ETCD_SERVICE_LB}:etcd
    - ${ETCD_SERVICE_SERVERS}:etcd_s
  volumes:
     - /dev:/dev
     - ${HEADER_DIR}:${HEADER_DIR}
     - /run/docker/plugins:/run/docker/plugins
     - /var/lib/osd:/var/lib/osd:shared
     - /etc/pwx:/etc/pwx
     - /opt/pwx/bin:/export_bin
     - /var/run/docker.sock:/var/run/docker.sock
     - /var/cores:/var/cores
     - /proc:/hostproc
  command: -c ${CLUSTER_ID} -k ${KVDB} ${USE_DISKS}
