# CaffeinateBar

App de barra de menús de macOS para evitar que el Mac se duerma. Un solo fichero Swift,
sin dependencias: envuelve el `caffeinate` que ya viene con el sistema.

![menu bar](https://img.shields.io/badge/macOS-11%2B-black) ![swift](https://img.shields.io/badge/Swift-single%20file-orange)

## Qué hace

- Icono de taza en la barra: llena = activo, vacía = inactivo.
- Duraciones: indefinido, 15 min, 30 min, 1 h, 2 h, 5 h y 8 h (jornada).
- Cuenta atrás en el menú y en el tooltip; el icono se pone naranja en los últimos 10 minutos.
- Opción "Mantener la pantalla encendida" (flag `-d`), que se recuerda entre sesiones.
- Sin icono en el Dock (`LSUIElement`).
- Si la app se cierra o casca, `caffeinate` muere con ella (`-w <pid>`): no deja procesos huérfanos.

## Instalar

```sh
./build.sh
open CaffeinateBar.app
```

`build.sh` compila con `swiftc`, genera el bundle `.app` con su `Info.plist` y ejecuta el
self-test antes de dar el OK. Necesitas las Command Line Tools de Xcode (`xcode-select --install`).

Para dejarla instalada de verdad: `cp -r CaffeinateBar.app /Applications/` y añádela en
Ajustes → General → Ítems de inicio.

## Test

```sh
./CaffeinateBar.app/Contents/MacOS/CaffeinateBar --selftest
```

Comprueba el formato del reloj, el umbral de aviso y que `caffeinate` arranca y se detiene
de verdad. Sale con código 1 si algo falla, así que vale para CI.

## Notas

- `build.sh` compila para `x86_64-apple-macosx11.0`. En Apple Silicon funciona vía Rosetta;
  para binario nativo cambia el `-target` a `arm64-apple-macosx11.0` (o quítalo para compilar
  para tu arquitectura).
- El binario no va firmado. Si Gatekeeper protesta: clic derecho → Abrir.
