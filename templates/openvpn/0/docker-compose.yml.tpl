version: '2'
services:
  openvpn-rancherlocal-data:
    labels:
      io.rancher.container.start_once: 'true'
      {{- if .Values.SC_LABEL_VALUE }}
      io.rancher.scheduler.affinity:host_label: ${SC_LABEL_VALUE}
      {{- end }}
    entrypoint:
    - /bin/true
    image: busybox
    volumes:
    - /etc/openvpn/
    volume_driver: ${STORAGE_DRIVER}  
  openvpn-rancherlocal-server:
    ports:
    - 1194:1194/tcp
    environment:
      AUTH_METHOD: rancherlocal
      AUTH_RANCHERLOCAL_URL: ${AUTH_RANCHERLOCAL_URL}/v1/token
      CERT_COUNTRY: ${CERT_COUNTRY}
      CERT_PROVINCE: ${CERT_PROVINCE}
      CERT_CITY: ${CERT_CITY}
      CERT_ORG: ${CERT_ORG}
      CERT_EMAIL: ${CERT_EMAIL}
      CERT_OU: ${CERT_OU}
      REMOTE_IP: ${REMOTE_HOST}
      REMOTE_PORT: ${REMOTE_PORT}
      VPNDNS_SERVER: ${VPNDNS_SERVER}
      VPNPOOL_NETWORK: ${VPNPOOL_NETWORK}
      VPNPOOL_CIDR: ${VPNPOOL_CIDR}
      VPNINT_DOMAIN: ${VPNINT_DOMAIN}
      OPENVPN_EXTRACONF: ${OPENVPN_EXTRACONF}
    labels:
      io.rancher.sidekicks: openvpn-rancherlocal-data
      {{- if .Values.VPNINT_DOMAIN }}
      io.rancher.service.external_dns_fqdn: ${VPNINT_DOMAIN}
      {{- end }}
      {{- if .Values.SC_LABEL_VALUE }}
      io.rancher.scheduler.affinity:host_label: ${SC_LABEL_VALUE}
      {{- end }}
      io.rancher.container.pull_image: always
    image: registry.vxcontrol.com:8443/rancher-openvpn:1.1
    domainname: ${REMOTE_HOST}
    privileged: true
    volumes_from:
    - openvpn-rancherlocal-data
