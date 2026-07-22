# Taylor

La primera plataforma de movilidad exclusiva para mujeres — pasajeras y
conductoras verificadas. App móvil en Flutter, para Android y iOS.

> **Estado actual:** Fases 1 (pasajera), 2 (conductora) y 3 (panel empresarial)
> escritas, **compiladas y verificadas corriendo en un emulador Android**
> (Pixel 7, API 36). `flutter analyze` sin incidencias.

---

## Identidad

Tomada del brand book y del documento de identidad de marca:

| | |
|---|---|
| **Primario** | Raspberry Pink `#FF3E81` |
| **Acento** | Razzmatazz Red `#D81B60` |
| **Texto/oscuro** | Obsidian Black `#1A1A1A` |
| **Base** | Pure White `#FFFFFF` |
| **Tipografía** | Poppins |
| **Valores** | Safety · Freedom · Empowerment · Innovation · Social Impact |
| **Tono** | Seguro, empoderador, cálido, empático — nunca basado en el miedo |

El arquetipo de la marca es *protectora pero moderna*. Eso tiene una
consecuencia concreta en la UI: el rojo de emergencia (`TaylorColors.emergency`)
se usa **solo** en el botón SOS. Todo lo demás relacionado con seguridad usa el
verde sereno de "verificada". La app comunica protección, no alarma.

---

## Puesta en marcha

### 1. Instalar herramientas

> **Ojo:** no existe paquete de Flutter en winget (`Google.Flutter` no se
> encuentra; solo está `Google.DartSDK`, que no sirve). La instalación oficial
> en Windows es por git.

```powershell
# Flutter SDK — clonar el canal stable
git clone -b stable https://github.com/flutter/flutter.git "$env:USERPROFILE\flutter"

# Android Studio (para el emulador)
winget install --id=Google.AndroidStudio -e
```

Añade `%USERPROFILE%\flutter\bin` al PATH del usuario, o invoca el binario por
ruta completa. La primera ejecución descarga el Dart SDK:

```powershell
& "$env:USERPROFILE\flutter\bin\flutter.bat" --version
```

Android Studio **no descarga el SDK de Android** hasta que se abre su interfaz.
Para hacerlo sin GUI, se instalan las command-line tools y se usa `sdkmanager`
(ver `flutter doctor` para confirmar que quedó bien).

Para compilar a iOS hace falta un Mac con Xcode. Windows solo produce Android.

### Versiones verificadas

Este proyecto se compiló y analizó con:

| | |
|---|---|
| Flutter | 3.44.7 (stable) |
| Dart | 3.12.2 |
| JDK | Temurin 21 |
| Android SDK | 36 (build-tools 36.0.0) |
| Emulador probado | Pixel 7, API 36, x86_64 |

### No pongas el proyecto dentro de OneDrive

Este proyecto vivía en `OneDrive\Documents\taylorappcode` y se movió a
`C:\dev\taylor` a propósito.

OneDrive sincroniza a la nube **cada artefacto de compilación**. La carpeta
`build/` sola llegó a 2.08 GB frente a 1.3 MB de código fuente real: miles de
archivos que cambian en cada `flutter build` y que OneDrive sube una y otra vez.
Consume ancho de banda, duplica espacio y ralentiza las compilaciones por la
contención de archivos.

Regla general: el código fuente puede vivir donde quieras; los directorios de
build, no. Si insistes en tener el proyecto en OneDrive, al menos excluye
`build/`, `.dart_tool/` y `android/.gradle/` de la sincronización.

### Si compilas en un equipo con poca RAM

`android/gradle.properties` está ajustado a `-Xmx1536m` y `org.gradle.parallel=false`.

El template de Flutter genera `-Xmx8G -XX:MaxMetaspaceSize=4G`, pensado para
una máquina de 16 GB. En un equipo de ~6 GB eso **no falla al arrancar** —la JVM
solo reserva espacio virtual— sino a mitad de `assembleDebug`, con
`Out of Memory Error` y un `hs_err_pid*.log`. Parece un fallo de compilación y
no lo es.

Además, **no ejecutes el emulador mientras compilas** en equipos así: se comen
~2 GB y provocan el mismo crash. Compila primero, arranca el emulador después.

Si desarrollas en 16 GB o más, sube a `-Xmx4G` y reactiva `parallel` — la build
será bastante más rápida.

### 2. Generar las carpetas de plataforma

Este repositorio contiene `lib/`, `assets/` y la configuración, pero **no** las
carpetas `android/` e `ios/`. Se generan con:

```bash
cd C:\dev\taylor
flutter create --org app.taylor --project-name taylor --platforms=android,ios .
```

El comando respeta los archivos que ya existen, así que no pisará el código.

### 3. Dependencias y localizaciones

```bash
flutter pub get
flutter gen-l10n
```

`flutter gen-l10n` genera `lib/l10n/app_localizations.dart` a partir de los
`.arb`. Ese archivo **no** está en el repositorio y la app no compila sin él.

### 4. Fuentes y animaciones

Coloca los `.ttf` de Poppins en `assets/fonts/` y los Lottie en
`assets/lottie/`. Ver los README de cada carpeta.

### 5. Ejecutar

```bash
flutter run
```

---

## Configurar Firebase

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

Esto genera `lib/firebase_options.dart`. Después, descomenta en `lib/main.dart`:

```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

En la consola de Firebase hay que habilitar **Authentication → Google** y, para
iOS, **Apple**. Sign in with Apple además requiere activar la capacidad en
Xcode y registrar el Service ID en el portal de Apple Developer.

**La app funciona sin Firebase**: la cuenta de demostración y el código de
empresa se resuelven localmente, antes de tocar la red. Eso es deliberado —
permite enseñar el producto a clientes sin depender de infraestructura.

---

## Configurar Google Maps

Necesitas una API key con **Maps SDK for Android** y **Maps SDK for iOS**
habilitados en Google Cloud Console. La cuenta requiere método de pago, aunque
el uso de mapas móviles cae dentro del nivel gratuito con holgura.

**Android** — ya está cableado. La clave se lee de `android/local.properties`,
que no se versiona. Solo tienes que añadir la línea:

```properties
MAPS_API_KEY=tu_api_key_aqui
```

`android/app/build.gradle.kts` la inyecta en el manifiesto como
`manifestPlaceholders`. Si el archivo no existe o falta la clave, se usa cadena
vacía: **la app compila y arranca igual, solo que el mapa sale en gris.** Es
deliberado — quien clone el repositorio no debería toparse con una build rota.

**iOS** — en `ios/Runner/AppDelegate.swift`:

```swift
GMSServices.provideAPIKey("TU_API_KEY")
```

Restringe la key por huella de app (SHA-1 en Android, bundle ID en iOS) antes de
publicar. Una key sin restricciones expuesta en un APK se factura a tu cuenta.

**SHA-1 de la clave de depuración de este equipo** (para restringir la key
durante el desarrollo):

```
B8:DE:92:8A:70:5A:10:E8:05:95:88:6B:9C:F5:F8:22:98:2B:EA:95
```

Nombre de paquete: `app.taylor.taylor`. La huella de release será distinta —
se genera al crear el keystore de firma.

### Permisos

Ya están declarados en `AndroidManifest.xml` (ubicación, cámara, internet) y en
`ios/Runner/Info.plist`.

Las descripciones de iOS explican **para qué** se usa cada permiso, no solo que
se usa: Apple rechaza en revisión las descripciones genéricas. Si añades un
permiso nuevo, mantén ese criterio.

---

## Notificaciones

La capa de notificaciones separa **presentación** de **transporte**, y eso es
deliberado: hoy funciona sin backend y se puede demostrar completa; mañana FCM
se enchufa sin tocar ni una llamada existente.

- `lib/core/notifications/taylor_notifications.dart` — presentación (canales,
  prioridad, acciones, sonido). Es quien decide **cómo** se ve un aviso.
- `lib/core/notifications/notification_router.dart` — qué hace la app cuando se
  toca. Independiente de quién originó la notificación.

### Los canales están separados por motivo, no por modo

En Android la usuaria puede silenciar cada canal por separado. Si todo viviera
en un canal, alguien que silencia los resúmenes de su empresa dejaría también de
recibir un SOS. **Regla al añadir uno nuevo: si silenciarlo puede poner a
alguien en riesgo, va en su propio canal.**

| Canal | Importancia | Para |
|---|---|---|
| `taylor_ride_request` | Máxima | Viaje entrante (conductora). Único con `fullScreenIntent` |
| `taylor_trip_status` | Alta | Conductora asignada / llegando (pasajera) |
| `taylor_safety` | Máxima | SOS, ubicación en vivo compartida |
| `taylor_business` | Alta | No-show, todas en casa |

### Detalles que importan

- **Los permisos se piden en contexto, no al arrancar.** El de notificaciones
  se solicita cuando la conductora se pone en línea, no en el primer segundo de
  la app — ahí es cuando la petición se explica sola y se acepta.
- La solicitud de viaje usa `timeoutAfter` igual a la ventana de aceptación: si
  caduca, la notificación se retira sola. Dejarla colgada llevaría a aceptar un
  viaje ya reasignado.
- Los IDs de notificación son fijos por tipo, no incrementales: un aviso nuevo
  **reemplaza** al anterior en vez de apilarse.
- Compartir ubicación en vivo muestra una notificación persistente. No es
  decorativa — ese estado consume batería y expone dónde estás, así que nunca
  debe poder quedarse encendido sin que se vea.

### Activar push remoto (FCM)

> **No añadas Firebase antes de tener el proyecto creado.** El plugin
> `com.google.gms.google-services` **aborta la compilación** si no encuentra
> `google-services.json`. No es un aviso: la build falla.

1. Crea el proyecto en Firebase y ejecuta `flutterfire configure`.
2. Coloca `android/app/google-services.json` (y `ios/Runner/GoogleService-Info.plist`).
3. Descomenta en `pubspec.yaml` el bloque de Firebase y añade `firebase_messaging`.
4. En `android/settings.gradle.kts`, añade el plugin:
   `id("com.google.gms.google-services") version "4.4.2" apply false`
   y aplícalo en `android/app/build.gradle.kts`.
5. Descomenta `Firebase.initializeApp()` en `lib/main.dart`.
6. Crea el handler de mensajes. **Debe llamar a los métodos que ya existen** en
   `TaylorNotifications` — no reimplementar la presentación:

```dart
FirebaseMessaging.onMessage.listen((message) {
  final data = message.data;
  if (data['type'] == 'ride_request') {
    TaylorNotifications.instance.showRideRequest(
      requestId: data['requestId'],
      passengerName: data['passengerName'],
      fare: data['fare'],
      pickupAddress: data['pickup'],
    );
  }
});
```

7. Para iOS hacen falta además certificados APNs y una Mac.

El handler en segundo plano (`onBackgroundMessage`) debe ser una función
top-level anotada con `@pragma('vm:entry-point')`, o Android la elimina al
compilar en release.

## Cuentas de prueba

| Acceso | Credenciales |
|---|---|
| Pasajera (demo) | `test@taylor.com` / `Taylor123` |
| Empresa (demo) | Código `Taylor123` |

Ambas están definidas en `lib/data/demo_data.dart` y **no** tocan Firebase.
Borrar ese archivo desactiva el modo demo por completo.

La cuenta demo entra ya verificada, así que va directo a Inicio. Para recorrer
el onboarding de seguridad completo, entra con Google/Apple: cualquier cuenta
nueva arranca en `VerificationStage.registered` y pasa por los cinco pasos.

La cuenta demo además viene con **perfil de conductora aprobado**, para poder
enseñar los dos lados del producto sin cerrar sesión: Cuenta → *Modo conductora*.
En producción son roles independientes; esto es una comodidad de exhibición.

### Recorrido de demostración del modo conductora

1. Entra con la cuenta demo → Cuenta → **Modo conductora**.
2. Activa el interruptor **En línea**.
3. A los ~3 s entra una solicitud con cuenta regresiva de 15 s. Acéptala (o
   déjala caducar para ver que vuelve a la cola).
4. Desliza *ya llegué* → *iniciar viaje* → *terminar*.
5. Aparece el resumen con el desglose de comisión. En **Ganancias** ves el
   acumulado del día y la semana.

### Recorrido de demostración del panel empresarial

1. En el login, toca **Business** → introduce `Taylor123`.
2. Aterrizas en **Hoy**: los traslados de la noche en vivo. La lista está
   ordenada por urgencia, no alfabéticamente — primero quien no se presentó,
   luego quien sigue fuera, al final quien ya llegó.
3. Espera unos segundos: los traslados avanzan solos y el banner superior pasa
   de rojo (requiere atención) a rosa (en camino) a verde (todas en casa).
4. En **Agenda** edita o crea una programación recurrente; en **Equipo**
   agrega o desactiva empleadas.

---

## Arquitectura

```
lib/
├── app/            router (go_router), shells de pasajera y conductora, modo
├── core/
│   ├── theme/      colores, tipografía, tema, motion, espaciado
│   ├── widgets/    glass surface, nav bar flotante, logo, campo de teléfono
│   └── locale/     selección de idioma persistida
├── data/           modelos, estado de sesión, datos de demostración
├── features/
│   ├── splash/     apertura animada
│   ├── auth/       login, demo, business (código + solicitud)
│   ├── onboarding/ los 5 pasos de verificación
│   ├── home/       mapa, pedir viaje, buscando conductora, viaje activo
│   ├── trips/      historial
│   ├── safety/     SOS, avisar amigas, ubicación en vivo, contactos
│   ├── account/    perfil, wallet, ayuda, configuración
│   ├── driver/     modo conductora completo + solicitud de alta
│   └── business/   panel empresarial: hoy, agenda, equipo, cuenta
└── l10n/           app_es.arb, app_en.arb
```

**Una sola app, dos modos.** Uber separa pasajera y conductora en dos
aplicaciones; Taylor no. La tesis de la marca es una comunidad cerrada de
mujeres verificadas, y obligar a una segunda descarga rompería esa continuidad
y duplicaría la superficie de verificación. `appModeProvider` decide el modo y
`Routes.isDriverRoute` protege el lado de conductora: solo entra quien tiene
`DriverApplicationStatus.approved`, y el guard vive en el router, no en la
pantalla.

**El modo conductora se usa al volante**, y eso cambia el diseño: controles más
grandes, una sola acción posible por estado, y las acciones irreversibles se
confirman **deslizando** en lugar de tocando (`SlideToConfirm`) — un botón se
pulsa sin querer al dejar el teléfono en el soporte, un arrastre no.

**El panel empresarial responde a una sola pregunta**: *¿ya llegaron todas?* La
responsabilidad de una empresa que manda a su personal a casa de noche no
termina cuando suben al coche, termina cuando llegan. Por eso la pestaña por
defecto es "Hoy" y no "Agenda", y por eso la lista se ordena por urgencia.

### Límite de privacidad del panel B2B

La empresa ve **el estado** del traslado de cada empleada, no su domicilio. En
`Employee` se guarda `homeArea` (zona: "Coyoacán") y nunca la dirección exacta;
esa la registra la empleada en su propia cuenta y solo la conocen Taylor y la
conductora asignada.

Es una decisión de producto, no un detalle técnico: sin esa asimetría, la
herramienta que protege a las empleadas se convierte en una de vigilancia
laboral, y ninguna de ellas la aceptaría. Si alguien pide "que se vea dónde vive
cada quien", la respuesta correcta es no.

**Estado**: Riverpod. `SessionController` es el único sitio que decide si
alguien puede pedir un viaje; el `redirect` de go_router lee de ahí, así que
ninguna pantalla puede saltarse la verificación navegando directo.

**Idioma**: la app sigue al dispositivo por defecto. En Configuración se puede
fijar uno, con la bandera del país correspondiente, y la elección persiste.

---

## Lo que falta

Alcance de las Fases 1 y 2, y lo que queda deliberadamente fuera:

**Simulado, pendiente de backend real**
- Despacho de viajes: `DriverController` genera una solicitud con temporizador.
  Sustituir `_scheduleIncomingRequest` por una suscripción push; el resto de la
  clase no cambia. Falta también el matching real por proximidad.
- Ganancias: `DriverProfile.earnings` viene de datos de demostración. Los pagos
  y las dispersiones necesitan integración con el procesador.
- Navegación paso a paso: `ActiveTripPanel` lanza la app de mapas del sistema
  con un `geo:` URI. Una navegación embebida requeriría el SDK de navegación.
- Verificación de identidad: los pasos de documento, rostro y antecedentes
  animan el flujo pero no llaman a ningún proveedor. Hay que integrar un
  servicio de KYC (Veriff, Sumsub, Incode) y `google_mlkit_face_detection` para
  la prueba de vida. Los puntos exactos están marcados con comentarios.
- Asignación de conductora: `RideController` usa temporizadores. Sustituir por
  una suscripción a Firestore; el resto de la app observa `Trip` y no cambia.
- Ubicación en vivo: la pestaña de Seguridad comparte un enlace fijo. Falta el
  stream de `geolocator` escribiendo posiciones y una vista web para recibirlas.
- Pagos: `WalletScreen` lista métodos pero no captura tarjetas. **La captura
  debe hacerse con el SDK del procesador** (Stripe, Conekta), que tokeniza los
  datos sin que la app los toque. No implementar un formulario de tarjeta propio.

**Panel B2B: simulado**
- Los traslados de la noche avanzan por temporizador en `TonightRidesController`.
  Sustituir por un stream de Firestore; `tonightSummaryProvider` y las pantallas
  no cambian.
- Los traslados ya se **materializan** desde las series de la Agenda
  (`RideMaterializer`), pero quien la invoca es la app al iniciar sesión. En
  producción hace falta un job diario en el servidor que los genere aunque
  nadie abra la app — hoy, si la coordinadora no entra, no existen.
- Facturas: la fila existe pero no descarga nada.

**Notificaciones: presentación lista, transporte pendiente**
- Los canales, prioridades, acciones y el enrutado al tocar están completos y
  funcionando. Lo que falta es el transporte remoto (FCM), que requiere
  proyecto Firebase — ver *Activar push remoto*.
- Mientras tanto, una solicitud de viaje solo llega si la app está viva. Con la
  app cerrada por el sistema no hay nada que la despierte: eso lo resuelve FCM
  y **es el bloqueador real para lanzar el modo conductora**.

**No empezado**
- Modo "seguir conduciendo" con encadenado de viajes.
- Viajes programados en la pestaña Viajes (`l10n.tripsUpcoming` existe sin usar).
- Tests de widget de las pantallas; hoy se cubren los controladores.

## Tests

```bash
flutter test
```

76 tests. Mientras no se pueda verificar en dispositivo físico, son el
sustituto — y han pagado su coste: destaparon tres bugs reales que ninguna
pantalla mostraba.

| Archivo | Cubre |
|---|---|
| `session_controller_test` | Login demo y B2B, embudo de verificación, perfil |
| `driver_controller_test` | Disponibilidad, solicitudes, fases del viaje |
| `business_controller_test` | Padrón, programaciones, fusión de traslados |
| `chat_controller_test` | Aislamiento del chat por viaje |
| `ride_lifecycle_test` | Ciclo del viaje de pasajera |
| `ride_materializer_test` | Series recurrentes → traslados, conflictos |
| `verification_stage_test` | Monotonía del embudo |
| `accessibility_test` | Contraste, áreas táctiles, etiquetas |
| `lottie_asset_test` | Que los Lottie parsean |

### Dos cosas que aprendimos escribiéndolos

**Los fallos silenciosos son el patrón dominante de este proyecto.** Ninguno de
los tres bugs encontrados producía un error visible: el viaje se quedaba
esperando, el interruptor no respondía, la notificación no salía. Por eso los
tests apuntan a invariantes de estado y no a "no lanza excepción".

**Nada de lo que rodea al flujo principal puede tumbarlo.** Una excepción del
plugin de notificaciones rompía la máquina de estados del viaje. La regla
resultante —las notificaciones son una mejora, nunca un requisito— está
implementada en `TaylorNotifications`, que garantiza no lanzar nunca.

## Accesibilidad

`test/accessibility_test.dart` verifica tres cosas sobre las pantallas
principales, sin necesidad de dispositivo: que todo lo pulsable tenga etiqueta
para lectores de pantalla, que las áreas táctiles alcancen 48 dp en Android y
44 en iOS, y que el texto cumpla el contraste de WCAG AA.

**Ejecuta estos tests antes de tocar colores.** Existen porque encontraron un
problema real y sistémico que nadie habría visto a ojo.

### El rosa de marca no sirve como color de texto

`#FF3E81` sobre blanco da **3.36:1**. WCAG AA exige 4.5:1 para texto de tamaño
normal. Estaba en botones de texto, chips y etiquetas — incluido *"Llamar a la
policía"*, justo el texto que alguien necesita encontrar de noche y con prisa.

La solución no fue cambiar la marca, sino usar el segundo color oficial del
brand book, que da 5.4:1:

| Color | Uso |
|---|---|
| `raspberry` `#FF3E81` | Rellenos, iconos, texto **grande** (≥24 px) |
| `brandText` `#D81B60` | Texto de tamaño normal sobre fondo claro |

La regla está documentada en `TaylorColors.brandText`. En modo oscuro se
mantiene `raspberry`: sobre superficie oscura sí tiene contraste de sobra.

Se ajustaron también el gris de texto secundario (4.17:1 → pasa) y el
degradado del login, que se solapaba con el titular y lo dejaba en 2.8:1.

## Materialización de traslados B2B

`RideMaterializer` convierte las programaciones recurrentes de la Agenda
("lunes a viernes a las 22:00") en los traslados concretos de un día. Es una
función **pura y determinista**, y eso importa por dos razones:

- **Idempotencia.** Los identificadores se derivan de (fecha, serie, empleada),
  no se generan al azar. Volver a materializar la misma noche —al abrir la app,
  tras editar una serie, al volver de segundo plano— produce los mismos ids, y
  `TonightRidesController.materialize` fusiona en vez de reemplazar. Un
  traslado que ya va en camino conserva su estado.
- **Testabilidad.** Es lógica de negocio con casos límite reales, cubierta por
  12 tests.

### Una empleada en dos programaciones

No se resuelve en silencio. Gana la salida más temprana —llegar antes a casa
nunca es peor— pero el conflicto se **reporta** y se notifica a la
coordinadora: es ella quien sabe cuál de las dos series es la correcta, y
necesita poder corregir la Agenda.

Descartar uno de los traslados sin avisar la dejaría creyendo que alguien
tiene transporte a una hora que no es.

### Bajas de empleadas

El filtro de empleadas activas se aplica **en la materialización**, no después.
Una empleada dada de baja a media noche conserva el traslado que ya tenía en
marcha; simplemente no se le genera uno nuevo al día siguiente.

## Cierre de viaje

El ciclo de la pasajera va `searching → driverAssigned → driverArriving →
inProgress → completed`, y **el viaje sigue siendo el viaje activo después de
llegar**: es la calificación —o descartarla— lo que lo cierra, no la llegada al
destino. Esa distinción es la que permite mostrar la tarjeta de calificación
sin haber perdido ya los datos del trayecto.

### Una calificación baja es una señal de seguridad

A partir de 3 estrellas o menos, la tarjeta ofrece explícitamente escalar a
seguridad en lugar de limitarse a bajar un promedio. En una plataforma cuyo
argumento es la seguridad, la calificación es el único canal estructurado por
el que alguien puede decir que algo salió mal.

El texto dice que lo revisa un equipo humano y no un algoritmo porque es
verdad, y porque es exactamente la diferencia que la marca promete. **Si algún
día deja de ser verdad, hay que cambiar el texto** — no al revés.

Las etiquetas positivas se limpian al bajar la calificación: enviar "amable" y
2 estrellas a la vez es una señal contradictoria que nadie sabría interpretar.
