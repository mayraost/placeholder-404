# Exact pin incl. digest per dependency-pinning policy
# 1.30.7: fixes CVE-2026-123633 + CVE-2026-123007 (HTTP/2 RCE, CVSS 9.2)
FROM nginx:1.30.7-alpine3.24@sha256:bef154735288bc38d99fac41ae63730684bcc661503673a04a0f9bc526ba8598

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY 404.html /srv/placeholder/404.html
COPY 503.html /srv/placeholder/503.html
COPY style.css /srv/placeholder/style.css
COPY fonts/ /srv/placeholder/fonts/

EXPOSE 3000

CMD ["nginx", "-g", "daemon off;"]
