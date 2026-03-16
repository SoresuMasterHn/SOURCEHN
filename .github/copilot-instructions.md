# Instrucciones para GitHub Copilot – SOURCEHN

Este repositorio contiene código fuente para IBM i (AS/400) desarrollado principalmente en **RPGLE**, **CLLE** y **SQL embebido (DB2 for i)**. Todos los comentarios, nombres de variables de negocio e identificadores descriptivos deben estar en **español**.

---

## Cómo cambiar una variable en múltiples lugares al mismo tiempo en Visual Studio Code

Visual Studio Code ofrece varias formas de renombrar o editar una variable simultáneamente en uno o varios archivos.

### 1. Renombrar símbolo (F2) — recomendado para RPGLE con extensiones

Si tienes instalada una extensión con soporte de lenguaje para RPGLE (por ejemplo, **IBM i Development Pack** o **Code for IBM i**), puedes usar la función de renombrado semántico:

1. Coloca el cursor sobre el nombre de la variable que deseas cambiar.
2. Presiona **F2**.
3. Escribe el nuevo nombre y presiona **Enter**.

VS Code actualizará todas las referencias a esa variable dentro del archivo (y en otros archivos del proyecto si la extensión lo soporta).

---

### 2. Seleccionar todas las ocurrencias (Ctrl + Shift + L)

Este método selecciona todas las coincidencias exactas del texto seleccionado en el archivo actual:

1. Selecciona el nombre de la variable con el ratón o el teclado.
2. Presiona **Ctrl + Shift + L** (Windows/Linux) o **Cmd + Shift + L** (macOS).
3. Se activa el modo de **multicursor**: todos los lugares donde aparece esa cadena quedan seleccionados.
4. Escribe el nuevo nombre; el cambio se aplica en todos los lugares al mismo tiempo.

---

### 3. Seleccionar siguiente ocurrencia (Ctrl + D)

Útil cuando solo quieres cambiar algunas ocurrencias, no todas:

1. Selecciona el nombre de la variable.
2. Presiona **Ctrl + D** (Windows/Linux) o **Cmd + D** (macOS) para añadir la siguiente ocurrencia a la selección.
3. Repite hasta seleccionar todas las ocurrencias que desees modificar.
4. Escribe el nuevo nombre.

---

### 4. Buscar y reemplazar en el archivo (Ctrl + H)

Para reemplazos masivos con más control:

1. Presiona **Ctrl + H** (Windows/Linux) o **Cmd + H** (macOS).
2. En el campo **Buscar**, escribe el nombre actual de la variable.
3. En el campo **Reemplazar**, escribe el nuevo nombre.
4. Usa la opción **Palabra completa** (icono `[ab]`) para evitar reemplazos parciales.
5. Haz clic en **Reemplazar todo** o en **Reemplazar** para ir uno a uno.

---

### 5. Buscar y reemplazar en todo el proyecto (Ctrl + Shift + H)

Para renombrar en múltiples archivos del repositorio:

1. Presiona **Ctrl + Shift + H** (Windows/Linux) o **Cmd + Shift + H** (macOS).
2. Completa los campos **Buscar** y **Reemplazar**.
3. Filtra por tipo de archivo si es necesario (por ejemplo, `*.rpgle`, `*.clle`).
4. Haz clic en **Reemplazar todo**.

---

## Convenciones de este repositorio

- **Plataforma destino:** IBM i (AS/400)
- **Lenguajes principales:** RPGLE (formato libre y fijo), CLLE, SQL embebido (DB2 for i)
- **Idioma de comentarios e identificadores:** Español
- **Extensiones recomendadas:** IBM i Development Pack, Code for IBM i
