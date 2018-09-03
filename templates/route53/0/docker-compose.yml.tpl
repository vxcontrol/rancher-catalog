# notemplating
route53:
  image: registry.vxcontrol.com:8443/external-dns:v0.7.9
  command: -provider=route53
  expose:
    - 1000
  environment:
    AWS_ACCESS_KEY: ${AWS_ACCESS_KEY}
    AWS_SECRET_KEY: ${AWS_SECRET_KEY}
    ROOT_DOMAIN: ${ROOT_DOMAIN}
    ROUTE53_ZONE_ID: ${ROUTE53_ZONE_ID}
    NAME_TEMPLATE: ${NAME_TEMPLATE}
    TTL: ${TTL}
    ROUTE53_MAX_RETRIES: ${ROUTE53_MAX_RETRIES}
  labels:
    io.rancher.container.create_agent: "true"
    io.rancher.container.agent.role: "external-dns"
    {{- if .Values.SC_LABEL_VALUE }}
    io.rancher.scheduler.affinity:host_label: ${SC_LABEL_VALUE}
    {{- end }}
  volumes:
    - /var/lib/rancher:/var/lib/rancher
