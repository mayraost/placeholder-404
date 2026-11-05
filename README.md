# placeholder-404

Minimaler nginx-Container, der alle Anfragen mit **404** beantwortet und eine
Platzhalterseite im Design von **mostheimer.de** ausliefert (inkl. Impressum).
Läuft in Coolify als Fallback-Applikation für ungenutzte Domains:

- `mosthi.de` / `*.mosthi.de`
- `mostheimer.de` / `*.mostheimer.de`

Vom Coolify-Proxy (Traefik) schlagen spezifische App-Router vor der Wildcard —
nur ungenutzte Hostnames sehen diese 404-Seite.

## Seite

Nachbau der mostheimer-404 („Dark Industrial") — **Stand 05.11.2026 live
vermessen**, nicht aus Tailwind-Klassen geraten. Dot-Grid-Hintergrund,
Hairline-Card, Mono-Statuszeile „HTTP 404 · Not Found" mit Fehler-Punkt,
Space-Grotesk-Headline, Primary-Button.

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
| `style.css`  | Design-Tokens + Styles, referenziert `/fonts/*`        |
| `fonts/`     | Selbst gehostete woff2 (Space Grotesk, JetBrains Mono) |
| `nginx.conf` | alles 404 außer der internen 404-Seite + Assets        |
| `Dockerfile` | nginx Image, exakt gepinnt (mit Digest)                |

Das Impressum sitzt **in der Karte**, weil § 5 DDG eine leicht erkennbare
Anbieterkennzeichnung verlangt — auch auf einer Fehlerseite. Der Footer bleibt
deshalb die reine Copyright-Zeile.

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
