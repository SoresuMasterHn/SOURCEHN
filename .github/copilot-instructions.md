# Instrucciones de contexto para GitHub Copilot

Este archivo proporciona el contexto de programación personal que GitHub Copilot debe tomar como base al generar sugerencias de código en este repositorio.

---

## Contexto del proyecto

Este repositorio es un cliente Git para **IBM i** (AS/400). El objetivo es gestionar código fuente alojado en la plataforma IBM i desde herramientas modernas de control de versiones.

---

## Plataforma y lenguajes principales

- **IBM i (AS/400 / iSeries)** — plataforma de destino.
- **RPG IV / RPGLE / SQLRPGLE** — lenguaje principal para lógica de negocio.
- **CL (Control Language) / CLLE** — automatización de tareas y flujos de trabajo en IBM i.
- **SQL (DB2 for i)** — acceso a datos embebido en RPGLE o en scripts SQL.
- **COBOL** — módulos legados que deben mantenerse compatibles.

---

## Convenciones de codificación

### RPG IV / RPGLE
- Usar formato **libre** (`**FREE`) siempre que sea posible.
- Declarar todas las variables con palabras clave explícitas (`DCL-S`, `DCL-DS`, `DCL-PR`, `DCL-PI`).
- Evitar el uso de indicadores numéricos (`*IN01` … `*IN99`); preferir variables booleanas con nombre descriptivo.
- Los nombres de variables, procedimientos y subrutinas deben ser **descriptivos** y en **español o inglés técnico**, sin abreviaturas crípticas.
- Siempre manejar errores con `%ERROR`, `%STATUS` o mediante monitores de errores (`MONITOR / ON-ERROR / ENDMON`).
- Los procedimientos de servicio deben documentarse con comentarios de propósito, parámetros y valor de retorno.

### CL / CLLE
- Un programa CL por responsabilidad (no mezclar múltiples funciones en un solo programa).
- Declarar todas las variables al inicio del programa.
- Usar `SNDPGMMSG` para mensajes de error y diagnóstico en lugar de mensajes genéricos.

### SQL (DB2 for i)
- Usar **SQL embebido** (`EXEC SQL … END-EXEC`) dentro de RPGLE.
- Preferir **vistas** y **procedimientos almacenados** sobre SQL ad hoc.
- Siempre verificar `SQLSTATE` / `SQLCODE` después de cada sentencia SQL embebida.
- Nombrar tablas y campos en **MAYÚSCULAS** tal como existen en el sistema IBM i.

---

## Estructura del repositorio

```
/
├── .github/
│   └── copilot-instructions.md   ← este archivo
├── QRPGLESRC/                    ← fuentes RPG IV en formato libre
├── QCLLESRC/                     ← fuentes CL
├── QSQLSRC/                      ← scripts y vistas SQL
├── QCBLLESRC/                    ← fuentes COBOL
└── README.md
```

> Los nombres de las carpetas reflejan los nombres de librería estándar en IBM i.

---

## Estilo de comentarios

- Los comentarios deben estar en **español**.
- Usar `//` para comentarios en línea en RPGLE libre.
- Documentar la cabecera de cada programa/módulo con:
  - Propósito
  - Autor
  - Fecha de creación
  - Historial de cambios

Ejemplo:

```rpgle
**FREE
// ============================================================
// Programa  : CALCIVA
// Propósito : Calcula el IVA aplicable a una factura.
// Autor     : HN
// Creado    : 2024-01-15
// Cambios   :
//   2024-03-10 - HN - Se agrega soporte para tasa reducida.
// ============================================================
```

---

## Prácticas de control de versiones

- Un **commit por cambio lógico** (no agrupar múltiples correcciones en un solo commit).
- Mensajes de commit en español, descriptivos y en tiempo presente: `"Agrega validación de RFC"`.
- Usar ramas con el formato: `feature/<descripcion>`, `fix/<descripcion>`, `hotfix/<descripcion>`.

---

## Lo que Copilot debe priorizar

1. **Seguridad y manejo de errores** — nunca omitir la verificación de errores.
2. **Legibilidad** — código claro y autodocumentado es mejor que código compacto.
3. **Compatibilidad con IBM i** — no sugerir código que dependa de APIs o librerías no disponibles en IBM i.
4. **Español** — comentarios, nombres de variables de negocio y mensajes de usuario en español.
5. **Estándares del proyecto** — seguir las convenciones definidas en este archivo.
