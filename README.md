# placeholder-404

Minimaler nginx-Container, der alle Anfragen mit **404** beantwortet und eine
Platzhalterseite im Design von **mostheimer.de** ausliefert (inkl. Impressum).
Läuft in Coolify als Fallback-Applikation für ungenutzte Domains:

- `mosthi.de` / `*.mosthi.de`
- `mostheimer.de` / `*.mostheimer.de`

Vom Coolify-Proxy (Traefik) schlagen spezifische App-Router vor der Wildcard —
nur ungenutzte Hostnames sehen diese 404-Seite.

## Seite

Nachbau der mostheimer-404 („Dark Industrial"): Dot-Grid-Hintergrund, Hairline-
Card, Mono-Statuszeile „HTTP 404 · Not Found" mit Fehler-Punkt, Space-Grotesk-
Headline, Primary-Button. **Kein Header**, Footer nur als Copyright-Zeile.

| Merkmal    | Umsetzung                                                                  |
| ---------- | -------------------------------------------------------------------------- |
| Tokens     | 1:1 aus `mostheimer/src/app/globals.css` (`@theme` + `.light`)             |
| Farbschema | Dark = Default (`:root`), `@media (prefers-color-scheme: light)` → Hell    |
| Fonts      | Space Grotesk + JetBrains Mono, **self-hosted** (`fonts/*.woff2`, OFL 1.1) |
| Dot-Grid   | `radial-gradient` in CSS, kein Bild                                        |
| JavaScript | keins                                                                      |
| Build      | keiner — statisches HTML + eine CSS-Datei                                  |

Dark ist Default, weil mostheimer selbst Dark-first ist (`:root` ist dort immer
dunkel, `.light` schaltet hell). Eine nackte 404 ohne Theme-Toggle folgt der
Systempräferenz, startet aber dunkel.

## Dateien

| Datei        | Zweck                                                  |
| ------------ | ------------------------------------------------------ |
| `404.html`   | Platzhalterseite inkl. Impressum                       |
| `style.css`  | Design-Tokens + Styles, referenziert `/fonts/*`        |
| `fonts/`     | Selbst gehostete woff2 (Space Grotesk, JetBrains Mono) |
| `nginx.conf` | alles 404 außer der internen 404-Seite + Assets        |
| `Dockerfile` | nginx Image, exakt gepinnt (mit Digest)                |

## Routen

| Pfad                         | Antwort                        |
| ---------------------------- | ------------------------------ |
| `/` und beliebige Pfade      | `404` + `404.html`             |
| `/style.css`                 | `200 text/css` (`max-age=600`) |
| `/fonts/*.woff2`             | `200 font/woff2` (`immutable`) |
| alles andere (z. B. favicon) | `404` + `404.html`             |

`404.html` setzt `Cache-Control: no-store` und strikte Security-Header
(`nosniff`, `X-Frame-Options: DENY`, restriktive CSP ohne JS).

## Lokal testen

```bash
docker build -t placeholder-404:test .
docker run --rm -p 127.0.0.1:3599:3000 placeholder-404:test
curl -i http://127.0.0.1:3599/        # 404 + Seite
curl -i http://127.0.0.1:3599/style.css
```

## Fonts

Space Grotesk und JetBrains Mono stehen unter der SIL Open Font License 1.1
(siehe `fonts/OFL.md`). Die woff2-Dateien stammen aus dem Google-Fonts-Repo
(`ofl/spacegrotesk`, `ofl/jetbrainsmono`); es wird zur Laufzeit **kein**
Google-CDN kontaktiert.
