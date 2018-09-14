version: '2'
services:
  etcd:
    image: registry.vxcontrol.com:8443/etcd:v3.3.8
    labels:
        io.rancher.scheduler.affinity:host_label_soft: etcd=true
        io.rancher.scheduler.affinity:container_label_ne: io.rancher.stack_service.name=$${stack_name}/$${service_name}
        {{- if .Values.SC_LABEL_VALUE }}
        io.rancher.scheduler.affinity:host_label: ${SC_LABEL_VALUE}
        {{- end }}
        io.rancher.sidekicks: data
    environment:
        RANCHER_DEBUG: '${RANCHER_DEBUG}'
        EMBEDDED_BACKUPS: '${EMBEDDED_BACKUPS}'
        BACKUP_PERIOD: '${BACKUP_PERIOD}'
        BACKUP_RETENTION: '${BACKUP_RETENTION}'
        ETCD_ELECTION_TIMEOUT: 5000
    volumes:
    - ${BACKUP_LOCATION}:/data-backup
    volumes_from:
    - data
    external_links:
    - etcd-lb:loadbalancer
  data:
    image: busybox
    command: /bin/true
    volumes:
    - pdata-{{.Stack.Name}}:/pdata
    volume_driver: ${STORAGE_DRIVER}
    labels:
      io.rancher.container.start_once: 'true'
      {{- if .Values.SC_LABEL_VALUE }}
      io.rancher.scheduler.affinity:host_label: ${SC_LABEL_VALUE}
      {{- end }}
  etcd-lb:
    expose:
    - 2379:2379/tcp
    tty: true
    image: rancher/load-balancer-service
    links:
    - etcd:etcd
    stdin_open: true
    {{- if .Values.SC_LABEL_VALUE }}
    labels:
      io.rancher.scheduler.affinity:host_label: ${SC_LABEL_VALUE}
    {{- end }}
