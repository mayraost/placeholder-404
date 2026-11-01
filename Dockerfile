# Exact pin incl. digest per dependency-pinning policy
FROM nginx:1.29.8-alpine3.23@sha256:5616878291a2eed594aee8db4dade5878cf7edcb475e59193904b198d9b830de

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY 404.html /srv/placeholder/404.html

EXPOSE 3000

CMD ["nginx", "-g", "daemon off;"]
