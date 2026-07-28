<div align="center">

# taylor

**The first mobility platform built exclusively for women — verified female passengers and drivers.**

Raspberry `#FF3E81` · Poppins · Safety · Freedom · Empowerment · Innovation · Social Impact

</div>

---

> 🇬🇧 **English** below · 🇪🇸 **Español** más abajo → [Ir a la versión en español](#-español)

---

## 🇬🇧 English

### What is Taylor?

Taylor is a ride-hailing app reimagined around **safety for women**. It connects women passengers with **verified female drivers**, and adds a B2B layer for companies that send their staff home safely after night shifts. The tone is protective but modern — the product communicates *protection, never fear*.

It is a single mobile app with **three modes**:

- **Passenger** — request a ride, live map and GPS, address search with real suggestions, three tiers (Taylor Go / Pro / Max), live driver tracking, trip history, and a Safety tab (SOS, share live location, emergency contacts).
- **Driver** — go online, receive ride requests with an acceptance countdown, slide-to-confirm the trip lifecycle, and see daily/weekly earnings with a transparent commission breakdown.
- **Business (B2B)** — a dashboard that answers one question: *did everyone get home?* Recurring night-shift scheduling, a live "Tonight" board ordered by urgency, and a team roster — all while protecting each employee's exact home address.

### Tech stack

| Layer | Technology |
|---|---|
| **Framework** | Flutter + Dart — cross-platform (Android & iOS, single codebase) |
| **State** | Riverpod |
| **Navigation** | go_router (with soft page transitions) |
| **Maps & location** | Google Maps SDK (`google_maps_flutter`), `geolocator` (live GPS), Google Places API (destination search) |
| **Real-time backend** | Firebase — Cloud Firestore (cross-device ride dispatch) |
| **Notifications** | `flutter_local_notifications` (FCM transport on the roadmap) |
| **Design** | Custom design system, glassmorphism ("liquid glass"), Lottie + custom `CustomPainter` animations |
| **i18n** | Device-language localization (English / Spanish) with country flags |

**AI on the roadmap:** identity verification (face + document recognition) is designed into the onboarding flow and planned on a vision/multimodal model such as Google Gemini, together with a KYC provider.

**AI-assisted development:** the codebase is built by the founding team using AI coding tools (Cursor, Claude) integrated directly into the development environment — allowing a lean team to ship at high velocity.

### Demo access

The app runs fully in a **simulated mode** — no backend required to explore it.

| Access | Credentials |
|---|---|
| Passenger (demo) | `test@taylor.com` / `Taylor123` |
| Business (demo) | Company code `Taylor123` |

The demo account signs in already verified and includes an approved driver profile, so you can explore **both sides** of the product from a single login: **Account → Driver mode**.

### Getting started

```bash
flutter pub get
flutter gen-l10n
flutter run --dart-define=MAPS_API_KEY=YOUR_GOOGLE_MAPS_KEY
```

> The Google Maps API key is **never** committed — it's read from `android/local.properties` (git-ignored). Without a key the app still builds and runs; only the map renders gray.

Verified with Flutter 3.44.7 / Dart 3.12.2 on Android (Pixel 7, API 36). iOS builds require a Mac with Xcode.

### Status

Passenger, driver and business flows are **written, compiled and verified** running on device/emulator; `flutter analyze` is clean and the suite passes (`flutter test`). What remains is mostly backend wiring — real dispatch matching, payments (via a processor SDK such as Stripe/Conekta), KYC integration, and remote push (FCM). These points are marked in the code.

---

## 🇪🇸 Español

### ¿Qué es Taylor?

Taylor es una app de movilidad reinventada alrededor de la **seguridad de las mujeres**. Conecta a pasajeras con **conductoras verificadas**, y suma una capa B2B para empresas que mandan a su personal a casa de forma segura tras el turno de noche. El tono es protector pero moderno — el producto comunica *protección, nunca miedo*.

Es una sola app móvil con **tres modos**:

- **Pasajera** — pedir viaje, mapa y GPS en vivo, búsqueda de direcciones con sugerencias reales, tres categorías (Taylor Go / Pro / Max), seguimiento de la conductora en vivo, historial y una pestaña de Seguridad (SOS, compartir ubicación en vivo, contactos de emergencia).
- **Conductora** — ponerse en línea, recibir solicitudes con cuenta regresiva, confirmar el ciclo del viaje **deslizando**, y ver las ganancias del día y la semana con el desglose de comisión transparente.
- **Empresa (B2B)** — un panel que responde a una sola pregunta: *¿ya llegaron todas?* Programación recurrente de turnos nocturnos, un tablero "Hoy" en vivo ordenado por urgencia, y un padrón de equipo — todo protegiendo la dirección exacta de cada empleada.

### Stack tecnológico

| Capa | Tecnología |
|---|---|
| **Framework** | Flutter + Dart — multiplataforma (Android e iOS, una sola base de código) |
| **Estado** | Riverpod |
| **Navegación** | go_router (con transiciones suaves) |
| **Mapas y ubicación** | Google Maps SDK (`google_maps_flutter`), `geolocator` (GPS en vivo), Google Places API (búsqueda de destinos) |
| **Backend en tiempo real** | Firebase — Cloud Firestore (despacho de viajes entre dispositivos) |
| **Notificaciones** | `flutter_local_notifications` (transporte FCM en el roadmap) |
| **Diseño** | Sistema de diseño propio, glassmorphism ("liquid glass"), animaciones Lottie + `CustomPainter` |
| **i18n** | Localización por idioma del dispositivo (inglés / español) con banderas |

**IA en el roadmap:** la verificación de identidad (reconocimiento de rostro + documento) está diseñada dentro del onboarding y planeada sobre un modelo de visión/multimodal como Google Gemini, junto con un proveedor de KYC.

**Desarrollo asistido por IA:** el código lo construye el equipo fundador con herramientas de asistencia (Cursor, Claude) integradas en el entorno de desarrollo — lo que permite a un equipo reducido avanzar a gran velocidad.

### Acceso de demostración

La app corre completamente en **modo simulado** — no necesita backend para explorarla.

| Acceso | Credenciales |
|---|---|
| Pasajera (demo) | `test@taylor.com` / `Taylor123` |
| Empresa (demo) | Código `Taylor123` |

La cuenta demo entra ya verificada e incluye un perfil de conductora aprobado, así que puedes recorrer **ambos lados** del producto desde un solo login: **Cuenta → Modo conductora**.

### Puesta en marcha

```bash
flutter pub get
flutter gen-l10n
flutter run --dart-define=MAPS_API_KEY=TU_CLAVE_DE_GOOGLE_MAPS
```

> La API key de Google Maps **nunca** se versiona — se lee de `android/local.properties` (ignorado por git). Sin clave la app compila y arranca igual; solo el mapa sale en gris.

Verificado con Flutter 3.44.7 / Dart 3.12.2 en Android (Pixel 7, API 36). Compilar a iOS requiere una Mac con Xcode.

### Estado

Los flujos de pasajera, conductora y empresa están **escritos, compilados y verificados** corriendo en dispositivo/emulador; `flutter analyze` está limpio y la suite pasa (`flutter test`). Lo que falta es principalmente cableado de backend — matching real de despacho, pagos (con el SDK de un procesador como Stripe/Conekta), integración de KYC y push remoto (FCM). Esos puntos están marcados en el código.

---

<div align="center">
<sub>© Taylor — la primera plataforma de movilidad exclusiva para mujeres.</sub>
</div>
