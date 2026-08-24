# CaffeinateBar

[![CI](https://github.com/delineas/caffeinate-bar/actions/workflows/ci.yml/badge.svg)](https://github.com/delineas/caffeinate-bar/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/delineas/caffeinate-bar)](https://github.com/delineas/caffeinate-bar/releases)
[![macOS](https://img.shields.io/badge/macOS-11%2B-black)](https://github.com/delineas/caffeinate-bar)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

App de barra de menús de macOS para evitar que el Mac se duerma. Un solo fichero Swift,
sin dependencias: envuelve el `caffeinate` que ya viene con el sistema.

English version [here](README.md).

## Qué hace

- Icono de taza en la barra: llena = activo, vacía = inactivo.
- Duraciones: indefinido, 15 min, 30 min, 1 h, 2 h, 5 h y 8 h (jornada).
- Cuenta atrás en el menú y en el tooltip; el icono se pone naranja en los últimos 10 minutos.
- Opción "Mantener la pantalla encendida" (flag `-d`), que se recuerda entre sesiones.
- Localizada en inglés y español — añadir idiomas cuesta dos ficheros (ver [Localización](#localización)).
- Sin icono en el Dock (`LSUIElement`).
- Si la app se cierra o casca, `caffeinate` muere con ella (`-w <pid>`): no deja procesos huérfanos.
- Binario universal (Apple Silicon + Intel), firmado ad-hoc.

## Instalar

Descarga la última versión desde [Releases](https://github.com/delineas/caffeinate-bar/releases),
descomprime y arrastra `CaffeinateBar.app` a `/Applications`. Lánzala y busca la taza
en la barra de menús. Para arrancarla al iniciar sesión, añádela en
Ajustes del Sistema → General → Ítems de inicio.

O compílala tú mismo:

```sh
Scripts/build.sh
open build/CaffeinateBar.app
```

Necesitas las Command Line Tools de Xcode (`xcode-select --install`).

## Uso

| Elemento del menú | Qué hace |
|---|---|
| Activar / Desactivar | Arranca o para la sesión anti-sueño |
| Duración | Elige el timeout; la cuenta atrás se ve en el menú y el tooltip |
| Mantener la pantalla encendida | Evita también que se duerma la pantalla |
| Salir | Para `caffeinate` y cierra la app |

## Desarrollo

```
Sources/CaffeinateBar/   Código de la app (un solo fichero)
Resources/               Localizable.strings + icono de la app
Scripts/build.sh         Compila, empaqueta, firma y auto-testea
Scripts/make_icon.sh     Regenera el icono de la app
```

Comandos útiles:

```sh
Scripts/build.sh --universal          # binario arm64 + x86_64
Scripts/build.sh --version 1.2.3      # inyecta la versión
Scripts/make_icon.sh                  # regenera Resources/AppIcon.icns
```

El build ejecuta un self-test (flag `--selftest` del binario) que comprueba el formato
del reloj, el umbral de aviso, la localización del bundle y el ciclo de vida real de
`caffeinate`. Sale con código distinto de cero si algo falla, así que sirve como
compuerta de CI.

### Localización

La app lee `Localizable.strings` del bundle. Para añadir un idioma:

1. Crea `Resources/<idioma>.lproj/Localizable.strings` (copia el inglés como base).
2. Añade `<string><idioma></string>` a `CFBundleLocalizations` en `Scripts/build.sh`.
3. Recompila. macOS elige el idioma automáticamente según las preferencias del sistema.

### Releases

Las releases son totalmente automáticas — la guía completa está en
[docs/RELEASING.md](docs/RELEASING.md) (en inglés). Resumen:

1. Etiqueta: `git tag v1.2.3 && git push origin v1.2.3`
2. GitHub Actions compila el binario universal, lo empaqueta con `ditto` y publica
   una GitHub Release con el zip y sus checksums SHA256.

## Contribuir

Los PRs son bienvenidos. Mantén el espíritu de un solo fichero sin dependencias:
ni frameworks ni paquetes externos. Ejecuta `Scripts/build.sh` antes de enviar —
CI tiene que seguir en verde. Ver [CONTRIBUTING.md](CONTRIBUTING.md).

## Licencia

[MIT](LICENSE) © Daniel Primo
