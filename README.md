# 🖥️ IBM i Source Repository

Repositorio centralizado de fuentes del ecosistema **IBM i (AS/400)** desarrollados en **RPGLE/SQLRPGLE Free Format** siguiendo estándares modernos de programación ILE.

## 📁 Estructura del Repositorio

```
├── qrpglesrc/        → Programas RPGLE / SQLRPGLE
├── qclsrc/           → Programas CL / CLLE
├── qddsrc/           → Display Files (DSPF), Printer Files (PRTF), Logical Files (LF)
├── qddssrc/          → Physical Files (PF) y definiciones DDS
├── qsqlsrc/          → Fuentes SQL (tablas, vistas, procedimientos, funciones)
├── qsrvsrc/          → Binder Source (STRPGMEXP/ENDPGMEXP) para Service Programs
├── qcmdsrc/          → Definiciones de comandos (CMD)
├── qmnusrc/          → Menús (MNUDDS)
├── docs/             → Documentación técnica del proyecto
└── scripts/          → Scripts de compilación y utilidades
```

## 🛠️ Estándares de Desarrollo

| Estándar | Descripción |
|---|---|
| **Nomenclatura** | CamelCase para variables, procedimientos, cursores e indicadores |
| **Formato** | Free Format obligatorio (RPGLE moderno) |
| **SQL** | DB2 for i nativo — sin sintaxis de otros motores |
| **Manejo de errores** | SQLSTATE verificado después de cada EXEC SQL |
| **Cursores** | Patrón DECLARE → OPEN → FETCH (DOW) → CLOSE siempre |
| **Indicadores** | Prohibido uso de *INxx — usar indicadores con nombre |

## ⚙️ CTL-OPT Estándar

```rpgle
CTL-OPT OPTION(*NODEBUGIO *SRCSTMT)
        DFTACTGRP(*NO)
        ACTGRP(*CALLER)
        DATFMT(*ISO)
        TIMFMT(*ISO)
        DECEDIT('0.')
        EXPROPTS(*RESDECPOS);
```

## 🔧 Entorno

- **Plataforma:** IBM i 7.5 (compatible con 7.4)
- **IDE:** Visual Studio Code + Code for i
- **CCSID:** 284 (Spanish EBCDIC)
- **Contexto:** Entorno bancario de alta disponibilidad

## 📝 Convención de Commits

```
feat: nueva funcionalidad
fix: corrección de bug
refactor: mejora de código sin cambio funcional
docs: cambios en documentación
build: cambios en compilación o scripts
```

**Ejemplos:**
```
feat: agregar procedimiento de validación de tarjetas
fix: corregir cursor en consulta de clientes
refactor: migrar QCMDEXC a QSYS2.QCMDEXC en SQL
docs: actualizar documentación de service programs
```

## 🚀 Flujo de Trabajo

1. Editar el fuente en IBM i vía **Code for i**
2. Guardar cambios en el AS/400 (`Ctrl + S`)
3. Descargar el miembro a la carpeta correspondiente del repo local
4. Ejecutar:
   ```bash
   git add .
   git commit -m "feat: descripción del cambio"
   git push
   ```

## 📄 Licencia

Uso interno — Todos los derechos reservados.
