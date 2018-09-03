# notemplating
cloudflare:
  image: registry.vxcontrol.com:8443/external-dns:v0.7.9
  command: -provider=cloudflare
  expose: 
   - 1000
  environment:
    CLOUDFLARE_EMAIL: ${CLOUDFLARE_EMAIL}
    CLOUDFLARE_KEY: ${CLOUDFLARE_KEY}
    ROOT_DOMAIN: ${ROOT_DOMAIN}
    NAME_TEMPLATE: ${NAME_TEMPLATE}
    TTL: ${TTL}
  labels:
    io.rancher.container.create_agent: "true"
    io.rancher.container.agent.role: "external-dns"
    {{- if .Values.SC_LABEL_VALUE }}
    io.rancher.scheduler.affinity:host_label: ${SC_LABEL_VALUE}
    {{- end }}
  volumes:
    - /var/lib/rancher:/var/lib/rancher
