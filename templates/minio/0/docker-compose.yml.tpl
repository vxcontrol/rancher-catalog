version: '2'
services:
  minio-server:
    tty: true
    image: registry.vxcontrol.com:8443/minio:v0.5.0
    volumes:
      - minio-scheduler-setting:/opt/scheduler
    {{- if eq (printf "%.1s" .Values.VOLUME_DRIVER) "/" }}
      {{- range $idx, $e := atoi .Values.MINIO_DISKS | until }}
      - ${VOLUME_DRIVER}/${DISK_BASE_NAME}{{$idx}}:/data/disk{{$idx}}
      {{- end}}
    {{- else}}
       {{- range $idx, $e := atoi .Values.MINIO_DISKS | until }}
      - minio-data-{{$idx}}:/data/disk{{$idx}}
      {{- end}}
    {{- end}}
    environment:
      - MINIO_CONFIG_accesskey=${MINIO_ACCESS_KEY}
      - MINIO_CONFIG_secretkey=${MINIO_SECRET_KEY}
      - CONFD_BACKEND=${CONFD_BACKEND}
      - CONFD_NODES=${CONFD_NODES}
      - CONFD_PREFIX_KEY=${CONFD_PREFIX}
      {{- range $idx, $e := atoi .Values.MINIO_DISKS | until }}
      - MINIO_DISKS_{{$idx}}=disk{{$idx}}
      {{- end}}
    labels:
      io.rancher.scheduler.affinity:container_label_soft_ne: io.rancher.stack_service.name=$${stack_name}/$${service_name}
      io.rancher.container.hostname_override: container_name
      io.rancher.sidekicks: rancher-cattle-metadata
  rancher-cattle-metadata:
    network_mode: none
    labels:
      io.rancher.scheduler.affinity:container_label_soft_ne: io.rancher.stack_service.name=$${stack_name}/$${service_name}
      io.rancher.container.hostname_override: container_name
      io.rancher.container.start_once: "true"
    image: webcenter/rancher-cattle-metadata:1.0.1
    volumes:
      - minio-scheduler-setting:/opt/scheduler
  minio-lb:
    image: rancher/lb-service-haproxy:v0.9.1
    expose:
      - 9000:9000/tcp
    links:
      - minio-server:minio-server
    labels:
      io.rancher.container.agent.role: environmentAdmin,agent
      io.rancher.container.agent_service.drain_provider: 'true'
      io.rancher.container.create_agent: 'true'

volumes:
  minio-scheduler-setting:
    driver: local
    per_container: true
  {{- if ne (printf "%.1s" .Values.VOLUME_DRIVER) "/" }}
    {{- range $idx, $e := atoi .Values.MINIO_DISKS | until }}
  minio-data-{{$idx}}:
    per_container: true
    driver: ${VOLUME_DRIVER}
    {{- end}}
  {{- end}}
