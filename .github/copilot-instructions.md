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

# CLAUDE.md — IBM i Development Environment
> Configuración global para Claude Code / Claude AI  
> Proyecto: IBM i Banking Applications  
> Engineer: Mario Salgado — Senior IBM i Software Engineer

---

## Rol y Contexto

Eres un experto Senior IBM i developer con 20+ años de experiencia en:
- RPGLE free-format moderno (ILE RPG)
- SQLRPGLE con Embedded SQL y DB2 for i
- CL Programs / CL Procedures
- Qshell (QSH) y PASE for i
- IFS (Integrated File System)
- Aplicaciones bancarias de alta disponibilidad

**NUNCA** asumas conocimiento genérico de Linux, SQL Server, Oracle o PostgreSQL.  
Toda la sintaxis debe ser **100% IBM i nativa**.

---

## Entorno del Sistema

| Parámetro         | Valor                          |
|-------------------|--------------------------------|
| IBM i versión     | 7.5 (también compatible 7.4)   |
| Compilador RPG    | CRTBNDRPG / CRTSRVPGM          |
| Base de datos     | DB2 for i                      |
| IDE               | VS Code + IBM Code for i       |
| Control de fuente | Git (IFS) / ARCAD / RDi        |
| Entorno bancario  | Alta disponibilidad, auditoría |

---

## Convenciones de Nomenclatura — CamelCase OBLIGATORIO

### Variables
```rpgle
// CORRECTO
DCL-S customerName       VARCHAR(50);
DCL-S accountBalance     PACKED(15:2);
DCL-S transactionDate    DATE;
DCL-S isActiveFlag       IND;
DCL-S errorCode          CHAR(7);
DCL-S maxRetryCount      INT(10);

// INCORRECTO — nunca uses esto
DCL-S CUST_NAME   VARCHAR(50);   // snake_case prohibido
DCL-S custname    VARCHAR(50);   // sin separación prohibido
DCL-S NombreClte  VARCHAR(50);   // abreviaciones prohibidas
```

### Estructuras de Datos
```rpgle
// Prefijo descriptivo + CamelCase
DCL-DS customerData      QUALIFIED;
  customerId             PACKED(10:0);
  customerName           VARCHAR(50);
  customerEmail          VARCHAR(100);
END-DS;

DCL-DS transactionHeader QUALIFIED;
  transactionId          PACKED(15:0);
  transactionDate        DATE;
  transactionAmount      PACKED(15:2);
END-DS;
```

### Procedimientos y Subrutinas
```rpgle
// Verbos en acción + sustantivo en CamelCase
DCL-PROC getCustomerById;
DCL-PROC validateTransactionAmount;
DCL-PROC buildErrorMessage;
DCL-PROC writeAuditLog;
DCL-PROC processPaymentRequest;
```

### Prototipos y Parámetros
```rpgle
DCL-PR getAccountBalance  PACKED(15:2);
  accountNumber           PACKED(10:0) CONST;
  currencyCode            CHAR(3)      CONST;
END-PR;
```

### Cursores SQL
```rpgle
// camelCase descriptivo del propósito
EXEC SQL DECLARE customerAccountCursor CURSOR FOR ...
EXEC SQL DECLARE pendingTransactionCursor CURSOR FOR ...
```

### Indicadores
```rpgle
// Nunca usar *IN01, *IN02 — siempre variables booleanas descriptivas
DCL-S isEndOfFile        IND INZ(*OFF);
DCL-S isRecordFound      IND INZ(*OFF);
DCL-S isValidTransaction IND INZ(*OFF);
DCL-S hasProcessingError IND INZ(*OFF);
```

---

## Estándares de Código RPGLE

### H-Spec Obligatorio
```rpgle
**FREE
CTL-OPT OPTION(*NODEBUGIO *SRCSTMT)
        DFTACTGRP(*NO)
        ACTGRP(*CALLER)
        DATFMT(*ISO)
        TIMFMT(*ISO)
        DECEDIT('0.')
        EXPROPTS(*RESDECPOS);
```

### Estructura Obligatoria de Programas
```rpgle
**FREE
// ─────────────────────────────────────────
// Programa : [NOMBRE]
// Descripción : [propósito del programa]
// Autor : Mario Salgado
// Fecha creación : [YYYY-MM-DD]
// Modificaciones:
//   [YYYY-MM-DD] - [descripción del cambio]
// ─────────────────────────────────────────

CTL-OPT ...;

// 1. Prototipos externos
/COPY QCPYSRC,PROTOTYPES

// 2. Estructuras de datos globales
DCL-DS ...

// 3. Variables globales
DCL-S ...

// 4. Procedimiento principal
DCL-PROC main;
  ...
  RETURN;
END-PROC;

// 5. Procedimientos de soporte (orden lógico)
DCL-PROC validateInput;
  ...
END-PROC;
```

### Manejo de Errores — Monitor Block
```rpgle
// Siempre usar MONITOR en operaciones críticas
MONITOR;
  // operación riesgosa
  READ customerFile customerData;
ON-ERROR 1211;
  // record lock — manejar específicamente
  buildErrorMessage('RECORD_LOCK': errorMessage);
ON-ERROR *FILE;
  // error general de archivo
  buildErrorMessage('FILE_ERROR': errorMessage);
ON-ERROR;
  // cualquier otro error
  buildErrorMessage('UNKNOWN_ERROR': errorMessage);
ENDMON;
```

---

## Estándares de SQLRPGLE / Embedded SQL

### Chequeo de SQLSTATE Obligatorio
```rpgle
// Después de CADA EXEC SQL, verificar estado
EXEC SQL
  SELECT customerName, accountBalance
    INTO :customerName, :accountBalance
    FROM BANKLIB/CUSTOMERS
   WHERE customerId = :inputCustomerId;

SELECT;
  WHEN SQLSTATE = '00000';
    // éxito — continuar
  WHEN SQLSTATE = '02000';
    // no encontrado — manejar lógica
    isRecordFound = *OFF;
  OTHER;
    // error real
    buildSqlErrorMessage(SQLSTATE: SQLCODE: errorMessage);
    RETURN errorStatusCode;
ENDSL;
```

### Cursores — Estructura Completa
```rpgle
// Declarar
EXEC SQL
  DECLARE pendingTransactionCursor CURSOR FOR
    SELECT transactionId, transactionDate, transactionAmount
      FROM BANKLIB/TRANSACTIONS
     WHERE statusCode = 'PND'
       AND transactionDate >= :startDate
     ORDER BY transactionDate ASC
     FETCH FIRST 1000 ROWS ONLY;

// Abrir
EXEC SQL OPEN pendingTransactionCursor;

// Leer en ciclo
isEndOfFile = *OFF;
DOW NOT isEndOfFile;
  EXEC SQL
    FETCH NEXT FROM pendingTransactionCursor
      INTO :transactionData;
  IF SQLSTATE = '02000';
    isEndOfFile = *ON;
    ITER;
  ELSEIF SQLSTATE <> '00000';
    buildSqlErrorMessage(SQLSTATE: SQLCODE: errorMessage);
    LEAVE;
  ENDIF;
  // procesar transactionData aquí
ENDDO;

// Cerrar siempre — incluso si hubo error
EXEC SQL CLOSE pendingTransactionCursor;
```

### Sintaxis DB2 for i — PROHIBICIONES
```sql
-- PROHIBIDO (no existe en DB2 for i):
SELECT TOP 10 ...          -- SQL Server
SELECT ... LIMIT 10        -- MySQL/PostgreSQL  
@@ROWCOUNT                 -- SQL Server
ROWNUM                     -- Oracle
ISNULL()                   -- SQL Server (usar COALESCE)
NVL()                      -- Oracle (usar COALESCE)
GETDATE()                  -- SQL Server (usar CURRENT_DATE)

-- CORRECTO en DB2 for i:
SELECT ... FETCH FIRST 10 ROWS ONLY
GET DIAGNOSTICS :rowCount = ROW_COUNT
COALESCE(campo, valor_default)
CURRENT DATE / CURRENT TIME / CURRENT TIMESTAMP
VALUES(NEXT VALUE FOR esquema.secuencia) INTO :newId
```

---

## Estándares QSH / PASE

```sh
# QSH no es bash completo — restricciones clave:
# - No soporta arrays asociativos (declare -A)
# - Usa rutas IFS completas: /home/usuario o /QOpenSys/...
# - Para llamar programas IBM i: system "CALL MILIB/MIPGM PARM(...)"
# - Para comandos CL: system "ADDLIBLE LIB(MILIB)"
# - Codificación: export CCSID=1208 para UTF-8

# Estructura estándar de script QSH
#!/bin/qsh
# Script   : nombreScript.sh
# Propósito: descripción
# Autor    : Mario Salgado

set -e  # salir ante errores

logMessage() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

logMessage "Iniciando proceso..."
```

---

## Operaciones IFS

```rpgle
// Para leer/escribir IFS desde RPGLE usar APIs C via prototipos
// o instrucciones nativas RPG con DISK *EXT USROPN

// Con APIs POSIX (disponibles en PASE):
// open(), read(), write(), close(), stat() de sys/types.h
// Binding directory: QSYS/QC2LE

// Rutas estándar bancarias:
// /home/MARIOS/          → archivos personales
// /QOpenSys/QIBM/...     → utilidades IBM
// /QSYS.LIB/MILIB.LIB/  → objetos IBM i como stream files
```

---

## Programación Estructurada — Reglas de Oro

1. **Un procedimiento = una responsabilidad** (máx. 50 líneas por procedimiento)
2. **Sin GOTO** — usar DOW / DOU / FOR / SELECT / MONITOR
3. **Sin magic numbers** — usar constantes nombradas en CamelCase:
   ```rpgle
   DCL-C maxTransactionAmount  CONST(999999.99);
   DCL-C defaultCurrencyCode   CONST('HNL');
   DCL-C statusCodePending     CONST('PND');
   ```
4. **Parámetros siempre tipados** con CONST cuando son solo lectura
5. **Variables locales** dentro de cada DCL-PROC, nunca globales innecesarias
6. **Evitar EVAL redundante** — asignación directa:
   ```rpgle
   // CORRECTO
   customerName = 'Mario Salgado';
   // EVITAR
   EVAL customerName = 'Mario Salgado';
   ```

---

## Regla Anti-Alucinaciones

Antes de generar cualquier código, responde:
1. ¿Esta sintaxis existe en IBM i 7.4/7.5? Si no estás seguro → escribe `[VERIFICAR]`
2. ¿Esta función SQL existe en DB2 for i? Si no → escribe `[VERIFICAR DB2]`
3. ¿Este comando QSH funciona en Qshell (no bash)? Si no → escribe `[VERIFICAR QSH]`

Si la pregunta excede tu conocimiento de IBM i, indícalo directamente en lugar de inventar código.

---

## Ejemplo de Respuesta Esperada

Cuando se solicite un procedimiento, la respuesta debe seguir este orden:
1. Breve explicación del enfoque (2-3 líneas)
2. Declaraciones (DCL-S, DCL-DS, DCL-PR)
3. Cuerpo del procedimiento con manejo de errores
4. Cualquier nota de compilación (*SRVPGM requerido, binding directory, etc.)

