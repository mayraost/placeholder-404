# placeholder-404

Minimaler nginx-Container, der alle Anfragen mit **404** beantwortet und die
fancy Placeholder-Seite inkl. Impressum ausliefert. Läuft in Coolify als
Fallback-Applikation für ungenutzte Domains:

- `mosthi.de` / `*.mosthi.de`
- `mostheimer.de` / `*.mostheimer.de`

Vom Coolify-Proxy (Traefik) schlagen spezifische App-Router vor der Wildcard —
nur ungenutzte Hostnames sehen diese 404-Seite.

Dateien:

| Datei        | Zweck                                   |
| ------------ | --------------------------------------- |
| `404.html`   | Placeholder-Seite inkl. Impressum       |
| `nginx.conf` | alles 404 außer der internen 404-Seite  |
| `Dockerfile` | nginx Image, exakt gepinnt (mit Digest) |
