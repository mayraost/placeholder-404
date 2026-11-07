# placeholder-404

Minimaler nginx-Container, der alle Anfragen mit **404** beantwortet und eine
Platzhalterseite im Design von **mostheimer.de** ausliefert (inkl. Impressum).
Läuft in Coolify als Fallback-Applikation für ungenutzte Domains:

- `mosthi.de` / `*.mosthi.de`
- `mostheimer.de` / `*.mostheimer.de`

Vom Coolify-Proxy (Traefik) schlagen spezifische App-Router vor der Wildcard —
nur ungenutzte Hostnames sehen diese 404-Seite.

**Ausnahme: die Site-Hosts selbst.** Fällt die App hinter `mostheimer.de` bzw.
`www.mostheimer.de` aus (Container gestoppt, Crash-Loop, Deploy-Fenster),
übernimmt dieser Container und antwortet mit **503** + Wartungsseite statt 404:
der Host ist belegt, nur der Ursprung fehlt. Am Cloudflare-Edge ist das der
Unterschied zwischen „30 Tage gecachtes 404" (SEO-Schaden, Host gilt als
gelöscht) und `stale-if-error`, das die letzte gute Kopie weiterliefert.

## Seite

Nachbau der mostheimer-404 („Dark Industrial") — **Stand 05.11.2026 live
vermessen**, nicht aus Tailwind-Klassen geraten. Dot-Grid-Hintergrund,
Hairline-Card, Mono-Statuszeile „HTTP 404 · Not Found" mit Fehler-Punkt,
Space-Grotesk-Headline, Primary-Button.

`503.html` ist dieselbe Seite mit Wartungs-Copy („Gerade nicht erreichbar.",
deutsch + ein englischer Satz) — gleiche Klassen, gleiches Design, keine
zusätzlichen Styles.

Bewusste Abweichungen von der Vorlage (nur diese zwei):

- **Kein Header** — die Seite gehört zu keinem aktiven Projekt.
- **Footer nur als Copyright-Zeile** — hier gibt es keinen Consent-Mechanismus,
  also auch keinen „Cookie-Einstellungen"-Link.

| Merkmal    | Umsetzung                                                                  |
| ---------- | -------------------------------------------------------------------------- |
| Tokens     | 1:1 aus `mostheimer/src/app/globals.css` (`@theme` + `.light`)             |
| Farbschema | Dark = Default (`:root`), `@media (prefers-color-scheme: light)` → Hell    |
| Fonts      | Space Grotesk + JetBrains Mono, **self-hosted** (`fonts/*.woff2`, OFL 1.1) |
| Dot-Grid   | `radial-gradient` in CSS, kein Bild                                        |
| JavaScript | keins                                                                      |
| Build      | keiner — statisches HTML + eine CSS-Datei                                  |

### Geometrie-Parität (gegen die Live-404 gemessen)

| Element  | Wert                                                                                  |
| -------- | ------------------------------------------------------------------------------------- |
| Card     | `max-width: 32rem` · `border-radius: 8px` · `padding: 32px` · **kein** `box-shadow`   |
| Headline | `2.25rem/2.5rem` · `700` · `letter-spacing: -0.025em` · `margin-bottom: 12px`         |
| Label    | `text-error` · JetBrains Mono `12px` · uppercase · `margin-bottom: 1rem`              |
| Button   | `border-radius: 6px` · `min-height: 44px` · `padding: 0 24px` · Mono `12px` uppercase |

Dark ist Default, weil mostheimer selbst Dark-first ist (`:root` ist dort immer
dunkel, `.light` schaltet hell). Eine nackte 404 ohne Theme-Toggle folgt der
Systempräferenz, startet aber dunkel.

### Bekannte, übernommene Eigenheit

Im Hell-Modus erreicht der Button-Text (`#f8fafc` auf `#059669`) 3.60:1 und
Primary-Links (`#059669` auf `#ffffff`) 3.77:1 — unter WCAG AA für Normaltext
(4.5:1). Beide Werte sind **1:1 aus mostheimer übernommen** (dort identisch
gemessen), damit die Seite wie ihre Vorlage aussieht. Beide Textsorten sind
groß/fett gesetzt und erfüllen damit AA-Large (3:1). Eine Korrektur müsste
zentral im mostheimer-Design-System passieren, nicht nur hier.

## Dateien

| Datei        | Zweck                                                  |
| ------------ | ------------------------------------------------------ |
| `404.html`   | Platzhalterseite inkl. Impressum                       |
| `503.html`   | Wartungsseite für die Site-Hosts (gleiches Design)     |
| `style.css`  | Design-Tokens + Styles, referenziert `/fonts/*`        |
| `fonts/`     | Selbst gehostete woff2 (Space Grotesk, JetBrains Mono) |
| `nginx.conf` | 404/503-Routing, sonst nur Assets                      |
| `Dockerfile` | nginx Image, exakt gepinnt (mit Digest)                |

Das Impressum sitzt **in der Karte**, weil § 5 DDG eine leicht erkennbare
Anbieterkennzeichnung verlangt — auch auf einer Fehlerseite. Der Footer bleibt
deshalb die reine Copyright-Zeile.

## Routen

| Pfad                              | Host                                 | Antwort                                         |
| --------------------------------- | ------------------------------------ | ----------------------------------------------- |
| `/` und beliebige Pfade           | `mostheimer.de`, `www.mostheimer.de` | `503` + `503.html` (`no-store`, `X-Robots-Tag`) |
| `/` und beliebige Pfade           | alle anderen                         | `404` + `404.html`                              |
| `/style.css`                      | jeder                                | `200 text/css` (`max-age=600`)                  |
| `/fonts/*.woff2`                  | jeder                                | `200 font/woff2` (`immutable`)                  |
| `/404.html`, `/503.html` (direkt) | jeder                                | `404` + `404.html` (beide `internal`)           |
| alles andere (z. B. favicon)      | jeder                                | `404` + `404.html`                              |

Die Host-Unterscheidung passiert in `location /` über zwei `if ($host = …)`
mit ausschließlich `return 503` — `$host` ist immer lowercase und ohne Port.
Assets bleiben host-unabhängig `200`, sonst wäre die 503-Seite ungestylt.

`404.html` und `503.html` setzen `Cache-Control: no-store` und strikte
Security-Header (`nosniff`, `X-Frame-Options: DENY`, restriktive CSP ohne JS);
die 503 zusätzlich `X-Robots-Tag: noindex, nofollow`.

## Lokal testen

```bash
docker build -t placeholder-404:test .
docker run --rm -p 127.0.0.1:3599:3000 placeholder-404:test

# Statusmatrix (Host-Header, ohne echten DNS)
curl -s -o /dev/null -w '%{http_code}\n' -H 'Host: mostheimer.de'     http://127.0.0.1:3599/  # 503
curl -s -o /dev/null -w '%{http_code}\n' -H 'Host: www.mostheimer.de' http://127.0.0.1:3599/  # 503
curl -s -o /dev/null -w '%{http_code}\n' -H 'Host: foo.example'       http://127.0.0.1:3599/  # 404
curl -sI -H 'Host: mostheimer.de' http://127.0.0.1:3599/ | grep -i cache-control                # no-store
```

## Fonts

Space Grotesk und JetBrains Mono stehen unter der SIL Open Font License 1.1
(siehe `fonts/OFL.md`). Die woff2-Dateien stammen aus dem Google-Fonts-Repo
(`ofl/spacegrotesk`, `ofl/jetbrainsmono`); es wird zur Laufzeit **kein**
Google-CDN kontaktiert.
