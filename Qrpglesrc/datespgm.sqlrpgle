**FREE

//=====================================================================
// Programa: FECHACONV
// Descripción: Ejemplos de conversiones DATE/TIMESTAMP en RPG ILE Free
// Autor: IBM Bob
// Fecha: 2026-01-26
//=====================================================================

Ctl-Opt DftActGrp(*No) ActGrp(*New) Option(*SrcStmt:*NoDebugIO);

// Declaración de variables para DATE
Dcl-S fechaDate Date;
Dcl-S fechaChar Char(10);
Dcl-S fechaCharISO Char(10);
Dcl-S fechaCharUSA Char(10);
Dcl-S fechaCharEUR Char(10);
Dcl-S fechaDecimal Packed(8:0);
Dcl-S fechaNumeric Zoned(8:0);

// Declaración de variables para TIMESTAMP
Dcl-S fechaTimestamp Timestamp;
Dcl-S timestampChar Char(26);
Dcl-S timestampChar19 Char(19);
Dcl-S timestampDecimal Packed(20:0);
Dcl-S timestampNumeric Zoned(14:0);

// Variables para componentes de fecha
Dcl-S anio Packed(4:0);
Dcl-S mes Packed(2:0);
Dcl-S dia Packed(2:0);
Dcl-S hora Packed(2:0);
Dcl-S minuto Packed(2:0);
Dcl-S segundo Packed(2:0);

// Variables SQL
Dcl-S sqlDate Date;
Dcl-S sqlTimestamp Timestamp;
Dcl-S sqlChar Char(26);

//=====================================================================
// SECCIÓN 1: CONVERSIONES DE DATE A OTROS FORMATOS
//=====================================================================

// 1.1 - Obtener fecha actual
fechaDate = %Date();

// 1.2 - DATE a CHAR (formato ISO: YYYY-MM-DD)
fechaCharISO = %Char(fechaDate);
// Resultado: '2026-01-26'

// 1.3 - DATE a CHAR con formato específico
fechaCharUSA = %Char(fechaDate : *USA);  // MM/DD/YYYY
fechaCharEUR = %Char(fechaDate : *EUR);  // DD.MM.YYYY
// Resultado USA: '01/26/2026'
// Resultado EUR: '26.01.2026'

// 1.4 - DATE a DECIMAL (formato YYYYMMDD)
fechaDecimal = %Dec(%Char(fechaDate : *ISO0) : 8 : 0);
// Resultado: 20260126

// 1.5 - DATE a NUMERIC (formato YYYYMMDD)
fechaNumeric = %Int(%Char(fechaDate : *ISO0));
// Resultado: 20260126

// 1.6 - Extraer componentes de DATE
anio = %Subdt(fechaDate : *Years);
mes = %Subdt(fechaDate : *Months);
dia = %Subdt(fechaDate : *Days);

//=====================================================================
// SECCIÓN 2: CONVERSIONES DE TIMESTAMP A OTROS FORMATOS
//=====================================================================

// 2.1 - Obtener timestamp actual
fechaTimestamp = %Timestamp();

// 2.2 - TIMESTAMP a CHAR (formato completo: 26 caracteres)
timestampChar = %Char(fechaTimestamp);
// Resultado: '2026-01-26-16.33.45.123456'

// 2.3 - TIMESTAMP a CHAR (19 caracteres, sin microsegundos)
timestampChar19 = %Char(fechaTimestamp : *ISO0);
// Resultado: '2026-01-26-16.33.45'

// 2.4 - TIMESTAMP a DECIMAL (formato YYYYMMDDHHMMSSnnnnnn)
timestampDecimal = %Dec(%Char(fechaTimestamp : *ISO0) : 20 : 0);
// Resultado: 20260126163345123456

// 2.5 - TIMESTAMP a NUMERIC (formato YYYYMMDDHHMMSS)
timestampNumeric = %Int(%Char(%Timestamp() : *ISO0));
// Resultado: 20260126163345

// 2.6 - Extraer componentes de TIMESTAMP
anio = %Subdt(fechaTimestamp : *Years);
mes = %Subdt(fechaTimestamp : *Months);
dia = %Subdt(fechaTimestamp : *Days);
hora = %Subdt(fechaTimestamp : *Hours);
minuto = %Subdt(fechaTimestamp : *Minutes);
segundo = %Subdt(fechaTimestamp : *Seconds);

//=====================================================================
// SECCIÓN 3: CONVERSIONES ENTRE DATE Y TIMESTAMP
//=====================================================================

// 3.1 - DATE a TIMESTAMP
fechaTimestamp = %Timestamp(fechaDate);
// Resultado: '2026-01-26-00.00.00.000000'

// 3.2 - TIMESTAMP a DATE
fechaDate = %Date(fechaTimestamp);
// Resultado: '2026-01-26'

//=====================================================================
// SECCIÓN 4: CONVERSIONES DESDE CHAR/DECIMAL A DATE/TIMESTAMP
//=====================================================================

// 4.1 - CHAR a DATE (formato ISO)
fechaChar = '2026-01-26';
fechaDate = %Date(fechaChar : *ISO);

// 4.2 - CHAR a DATE (formato USA)
fechaCharUSA = '01/26/2026';
fechaDate = %Date(fechaCharUSA : *USA);

// 4.3 - DECIMAL a DATE (formato YYYYMMDD)
fechaDecimal = 20260126;
fechaDate = %Date(%Char(fechaDecimal) : *ISO0);

// 4.4 - CHAR a TIMESTAMP
timestampChar = '2026-01-26-16.33.45.123456';
fechaTimestamp = %Timestamp(timestampChar);

// 4.5 - DECIMAL a TIMESTAMP (formato YYYYMMDDHHMMSSnnnnnn)
timestampDecimal = 20260126163345123456;
fechaTimestamp = %Timestamp(%Char(timestampDecimal));

//=====================================================================
// SECCIÓN 5: SQL EMBEBIDO - CONVERSIONES CON FUNCIONES SQL
//=====================================================================

// 5.1 - Obtener fecha/hora actual con SQL
Exec SQL
  SELECT CURRENT_DATE, CURRENT_TIMESTAMP
  INTO :sqlDate, :sqlTimestamp
  FROM SYSIBM.SYSDUMMY1;

// 5.2 - TIMESTAMP a CHAR con formato específico (SQL)
Exec SQL
  SELECT CHAR(CURRENT_TIMESTAMP, ISO)
  INTO :sqlChar
  FROM SYSIBM.SYSDUMMY1;
// Resultado: '2026-01-26-16.33.45.123456'

// 5.3 - Extraer componentes con SQL
Exec SQL
  SELECT YEAR(CURRENT_DATE),
         MONTH(CURRENT_DATE),
         DAY(CURRENT_DATE)
  INTO :anio, :mes, :dia
  FROM SYSIBM.SYSDUMMY1;

// 5.4 - TIMESTAMP a DATE con SQL
Exec SQL
  SELECT DATE(CURRENT_TIMESTAMP)
  INTO :sqlDate
  FROM SYSIBM.SYSDUMMY1;

// 5.5 - Formatear fecha con VARCHAR_FORMAT (DB2 for i 7.3+)
Exec SQL
  SELECT VARCHAR_FORMAT(CURRENT_TIMESTAMP, 'YYYY-MM-DD HH24:MI:SS')
  INTO :sqlChar
  FROM SYSIBM.SYSDUMMY1;
// Resultado: '2026-01-26 16:33:45'

// 5.6 - CHAR a TIMESTAMP con TO_TIMESTAMP (SQL)
Exec SQL
  SELECT TIMESTAMP('2026-01-26', '16:33:45')
  INTO :sqlTimestamp
  FROM SYSIBM.SYSDUMMY1;

// 5.7 - DECIMAL a DATE con SQL
Exec SQL
  SELECT DATE(DIGITS(20260126))
  INTO :sqlDate
  FROM SYSIBM.SYSDUMMY1;

// 5.8 - Conversión con CAST
Exec SQL
  SELECT CAST(CURRENT_TIMESTAMP AS CHAR(26)),
         CAST(CURRENT_DATE AS CHAR(10))
  INTO :timestampChar, :fechaChar
  FROM SYSIBM.SYSDUMMY1;

//=====================================================================
// SECCIÓN 6: OPERACIONES COMUNES CON FECHAS
//=====================================================================

// 6.1 - Sumar días a una fecha
fechaDate = %Date() + %Days(30);

// 6.2 - Restar meses a una fecha
fechaDate = %Date() - %Months(3);

// 6.3 - Diferencia entre fechas (en días)
Dcl-S diasDiferencia Packed(7:0);
diasDiferencia = %Diff(fechaDate : %Date() : *Days);

// 6.4 - Sumar horas a un timestamp
fechaTimestamp = %Timestamp() + %Hours(5);

// 6.5 - Calcular edad en años
Dcl-S fechaNacimiento Date;
Dcl-S edad Packed(3:0);
fechaNacimiento = %Date('1990-05-15' : *ISO);
edad = %Diff(%Date() : fechaNacimiento : *Years);

//=====================================================================
// SECCIÓN 7: CASOS DE USO COMUNES EN PRODUCCIÓN
//=====================================================================

// 7.1 - Convertir timestamp de base de datos a formato legible
// Entrada: TIMESTAMP de DB2
// Salida: 'DD/MM/YYYY HH:MM:SS'
Dcl-S fechaFormateada Char(19);
fechaFormateada = %Char(%Date(fechaTimestamp) : *EUR) + ' ' +
                  %Char(%Subdt(fechaTimestamp : *Hours) : 2) + ':' +
                  %Char(%Subdt(fechaTimestamp : *Minutes) : 2) + ':' +
                  %Char(%Subdt(fechaTimestamp : *Seconds) : 2);
// Resultado: '26.01.2026 16:33:45'

// 7.2 - Convertir fecha numérica legacy (YYYYMMDD) a DATE
Dcl-S fechaLegacy Packed(8:0);
fechaLegacy = 20260126;
fechaDate = %Date(%Char(fechaLegacy) : *ISO0);

// 7.3 - Convertir fecha numérica legacy (MMDDYYYY) a DATE
Dcl-S fechaLegacyUSA Packed(8:0);
Dcl-S fechaCharTemp Char(8);
fechaLegacyUSA = 01262026;
fechaCharTemp = %Char(fechaLegacyUSA);
fechaDate = %Date(%Subst(fechaCharTemp:5:4) + '-' +
                  %Subst(fechaCharTemp:1:2) + '-' +
                  %Subst(fechaCharTemp:3:2) : *ISO);

// 7.4 - Timestamp a formato para archivo log
Dcl-S logTimestamp Char(23);
logTimestamp = %Char(%Date(fechaTimestamp) : *ISO) + ' ' +
               %Char(%Time(fechaTimestamp) : *HMS);
// Resultado: '2026-01-26 16:33:45'

// 7.5 - Validar si una fecha es válida
Dcl-S fechaValida Ind;
Monitor;
  fechaDate = %Date('2026-02-30' : *ISO);
  fechaValida = *On;
On-Error;
  fechaValida = *Off;
EndMon;

*InLR = *On;
Return;

