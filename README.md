# divisor_cuenta: vibe coding vs. SDD

Práctica de la semana 7 de Programación Asistida de Aplicaciones (USFQ): la misma app
Flutter, un **divisor de cuenta** de una sola pantalla, construida dos veces desde el
mismo commit inicial.

| Rama | Qué tiene |
|---|---|
| `main` | el proyecto base de Flutter sin tocar, más la entrega: `respuestas.md`, `bitacora.md`, `DECISIONS.md`, `MY_STEPS.md`, `DIGEST.pdf` |
| `vibe` | la app hecha a partir de una sola frase, más 2 correcciones |
| `sdd` | la app hecha con GitHub Spec Kit: constitución, spec, plan, tareas, código y 33 pruebas |

```text
9555fb2 proyecto base de flutter, sin tocar   (main)
   ├── vibe: 2 commits
   └── sdd: 15 commits (instrucciones → Spec Kit → constitución → spec → plan →
            tareas → implement → converge → pruebas)
```

## Requisitos

- Flutter estable (probado con Flutter 3.47 y Dart 3.13). Revisa con `flutter doctor`.
- Para correr en Android: Android Studio con el Android SDK.
- No hace falta ninguna API key ni cuenta.

## Instalar y correr la versión SDD

```bash
git checkout sdd
flutter pub get
flutter run -d chrome     # o -d macos, o un teléfono conectado
```

## Probar

```bash
git checkout sdd
flutter test --reporter expanded   # 33 pruebas en verde
flutter analyze                    # No issues found!
```

Las verificaciones de SOLID y la explicación de cada archivo están en el `README.md` de
la rama `sdd`.

## Probar la versión vibe

```bash
git checkout vibe
flutter pub get
flutter test        # 12 pruebas propias
flutter run -d chrome
```

## Dónde leer qué

| Quiero… | Abre |
|---|---|
| las respuestas de la entrega | `respuestas.md` |
| la tabla de métricas y qué pasó paso a paso | `bitacora.md` |
| por qué se decidió cada cosa | `DECISIONS.md` |
| lo que me falta hacer a mí | `MY_STEPS.md` |
| entender el código (versión profunda y versión para niños) | `DIGEST.pdf` |
| la spec, el plan y las tareas | rama `sdd`, carpeta `specs/001-divisor-cuenta/` |
| las reglas del proyecto | rama `sdd`, `.specify/memory/constitution.md` |
