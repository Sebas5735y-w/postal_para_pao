# Postal para Pao 💌

App de Flutter que le manda a Pao una cartita diaria a las **7:50 am**, con
temática de correo antiguo: sobre, sello de cera que se rompe con un toque,
postal con matasellos, y un álbum donde se guardan todas las cartas que ya
abrió. Trae **240 mensajes** distintos que rotan al azar sin repetirse hasta
agotar el ciclo completo (y ahí se vuelve a barajar).

Además tiene:
- 🔥 **Racha de días** — cuenta cuántos días seguidos ha abierto su carta,
  visible como badge en la barra superior.
- Animación suave (fade + slide) al revelar la postal, y vibración corta
  al romper el sello.
- Ícono propio de la app (sello de cera con la "P", sobre papel kraft).

Este repo trae solo el código Dart (`lib/`), `pubspec.yaml`, los assets del
ícono, y un `codemagic.yaml` que genera el APK en la nube — **no necesitas
instalar Flutter en tu computadora** para conseguir el instalable.

---

## Opción A (recomendada): generar el APK con Codemagic, sin instalar nada

### 1. Sube este proyecto a GitHub

```bash
cd postal_para_pao
git init
git add .
git commit -m "Postal para Pao - primera versión"
git branch -M main
git remote add origin https://github.com/TU_USUARIO/postal_para_pao.git
git push -u origin main
```

(Crea antes el repo vacío en https://github.com/new — puede ser privado,
así solo tú lo ves.)

### 2. Conecta el repo en Codemagic

1. Entra a https://codemagic.io/ y crea una cuenta (puedes usar tu cuenta
   de GitHub para entrar directo).
2. "Add application" → elige **GitHub** → autoriza acceso → selecciona el
   repo `postal_para_pao`.
3. Codemagic va a detectar el `codemagic.yaml` que ya está en el repo y
   va a ofrecer el workflow **"Postal para Pao - APK"**. Selecciónalo.
4. Dale a **Start new build** (rama `main`).

### 3. Espera el build y descarga el APK

El build tarda unos 5-10 minutos la primera vez. Cuando termine (✅ verde),
entra al build → pestaña **Artifacts** → descarga el `.apk`.

### 4. Instálalo en el celular de Pao

Mándale el `.apk` por WhatsApp o Drive. Al abrirlo, Android va a pedir
activar "Instalar apps de fuentes desconocidas" — lo acepta y listo, queda
instalada como cualquier app.

> 💡 Cada vez que quieras actualizar mensajes o algo del diseño: edita el
> código, haz `git push`, y en Codemagic dale **Start new build** de nuevo
> (o actívale el trigger automático en cada push, en Settings → Triggering).

---

## Opción B: generar el APK tú mismo con Flutter instalado

Si en algún momento prefieres compilarlo localmente:

1. Instala Flutter: https://docs.flutter.dev/get-started/install
2. Dentro de la carpeta del proyecto:
   ```bash
   flutter create --platforms=android .
   flutter pub get
   dart run flutter_launcher_icons
   ```
3. Agrega los permisos en `android/app/src/main/AndroidManifest.xml`
   (dentro de `<manifest>`, antes de `<application>`):
   ```xml
   <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
   <uses-permission android:name="android.permission.USE_EXACT_ALARM"/>
   <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
   <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
   ```
4. Compila:
   ```bash
   flutter build apk --release
   ```
   El archivo queda en `build/app/outputs/flutter-apk/app-release.apk`.

---

## Cómo cambiar cosas

- **Hora de la notificación**: en `lib/main.dart`, la línea
  `notifications.scheduleDaily(hour: 7, minute: 50)`.
- **Agregar/editar mensajes**: en `lib/data/messages.dart`, cada uno es un
  `LoveMessage(id: ..., text: '...')`. Solo agrega más a la lista, no hay
  límite. Los IDs deben ser únicos.
- **Colores**: todo el estilo vintage postal vive en `lib/theme/app_theme.dart`
  (`AppColors`).
- **Firma al final de cada postal** ("— con cariño, Sebas"): en
  `lib/widgets/postcard.dart`.
- **Ícono de la app**: cambia `assets/images/app_icon.png` (1024x1024) y
  `assets/images/app_icon_foreground.png` (versión con fondo transparente,
  para el ícono adaptativo de Android), luego vuelve a correr
  `dart run flutter_launcher_icons` (esto ya pasa solo en cada build de
  Codemagic).

## Notas técnicas

- Las notificaciones son **locales** (no necesitan servidor ni internet):
  se programan en el propio celular con `flutter_local_notifications` y se
  repiten todos los días a la misma hora.
- El mensaje del día se calcula de forma **determinística por día** y se
  guarda en `shared_preferences`, así que la notificación y lo que se ve al
  abrir la app siempre coinciden, sin importar si la abre antes o después
  de las 7:50.
- El "sello roto" también se guarda, así que si cierra y abre la app de
  nuevo el mismo día, ve la carta ya abierta en vez del sobre otra vez.
- La racha (🔥) cuenta días consecutivos donde abrió la carta, contando
  hacia atrás desde hoy; se corta apenas hay un día sin abrir.
- `android/` e `ios/` **no están versionados a propósito** (ver
  `.gitignore`) — Codemagic los genera en cada build con
  `flutter create --platforms=android .`, así el repo se mantiene liviano
  y solo con el código que de verdad importa.
- Todo funciona sin conexión a internet una vez instalada la app (salvo la
  primera vez que carga las tipografías de Google Fonts; si prefieres que
  funcione 100% offline desde el día uno, puedo cambiarlas por fuentes
  empaquetadas localmente — solo dime).
