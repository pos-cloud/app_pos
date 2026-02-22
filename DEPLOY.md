# Deploy a Google Play Store

## 1. Generar el keystore (solo la primera vez)

Ejecutá en la **raíz del proyecto**:

```bash
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Te va a pedir:
- **Contraseña** del keystore (guardala bien)
- **Nombre y apellido**, organización, ciudad, etc.
- **Contraseña** de la key (podés usar la misma que el keystore)

> ⚠️ **Importante:** Guardá el keystore (`upload-keystore.jks`) y las contraseñas en un lugar seguro. Si los perdés, no vas a poder actualizar la app en Play Store.

## 2. Configurar key.properties

Copiá el archivo de ejemplo:

```bash
cp android/key.properties.example android/key.properties
```

Editá `android/key.properties` y completá con tus datos:

```properties
storePassword=TU_PASSWORD_DEL_KEYSTORE
keyPassword=TU_PASSWORD_DE_LA_KEY
keyAlias=upload
storeFile=../../upload-keystore.jks
```

- `storePassword` y `keyPassword`: las contraseñas que usaste al crear el keystore
- `keyAlias`: debe ser `upload` (o el alias que hayas usado)
- `storeFile`: ruta relativa al keystore (si está en la raíz del proyecto, dejala como está)

## 3. Build del App Bundle

```bash
flutter build appbundle
```

El archivo se genera en: `build/app/outputs/bundle/release/app-release.aab`

## 4. Subir a Play Store

1. Entrá a [Google Play Console](https://play.google.com/console)
2. Creá la app (si es la primera vez) o seleccioná la existente
3. Andá a **Producción** (o **Prueba interna/cerrada** para probar primero)
4. **Crear nueva versión** → subí el archivo `app-release.aab`
5. Completá los datos requeridos (descripción, capturas, política de privacidad, etc.)
6. Enviá a revisión

---

## Build APK (para instalar directamente en dispositivos)

Si querés generar una APK para probar en dispositivos sin pasar por Play Store:

```bash
flutter build apk --release
```

Se genera en: `build/app/outputs/flutter-apk/app-release.apk`
