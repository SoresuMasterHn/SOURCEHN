**FREE

//=====================================================================
// SECCIÓN 8: CONVERSIONES UTC Y ZONAS HORARIAS
//=====================================================================

// 8.1 - Definición de archivo físico con campo TIMESTAMP
Dcl-F LOGFILE Usage(*Output) Keyed;

// Estructura del archivo físico LOGFILE
// Campo: LOGID (PK) - Packed(10:0)
// Campo: LOGTIMESTAMP - Timestamp
// Campo: LOGUTC - Timestamp
// Campo: LOGMESSAGE - Char(100)

// Variables para manejo de UTC
Dcl-S timestampLocal Timestamp;
Dcl-S timestampUTC Timestamp;
Dcl-S timestampUTCChar Char(26);
Dcl-S offsetHoras Packed(3:0);
Dcl-S offsetMinutos Packed(3:0);
// Américas
Dcl-C UTC_HONDURAS    Const(-6);  // UTC-6 (CST)
Dcl-C UTC_MEXICO_CITY Const(-6);  // UTC-6 (CST)
Dcl-C UTC_NEW_YORK    Const(-5);  // UTC-5 (EST)
Dcl-C UTC_LOS_ANGELES Const(-8);  // UTC-8 (PST)
Dcl-C UTC_SAO_PAULO   Const(-3);  // UTC-3 (BRT)

// Europa
Dcl-C UTC_LONDON      Const(0);   // UTC+0 (GMT)
Dcl-C UTC_PARIS       Const(1);   // UTC+1 (CET)
Dcl-C UTC_MOSCOW      Const(3);   // UTC+3 (MSK)

// Asia
Dcl-C UTC_DUBAI       Const(4);   // UTC+4 (GST)
Dcl-C UTC_MUMBAI      Const(5.5); // UTC+5:30 (IST)
Dcl-C UTC_SHANGHAI    Const(8);   // UTC+8 (CST)
Dcl-C UTC_TOKYO       Const(9);   // UTC+9 (JST)


// 8.2 - Obtener timestamp actual en hora local
timestampLocal = %Timestamp();
// Resultado: '2026-01-26-10.55.39.123456' (Hora local Honduras UTC-6)

// 8.3 - Convertir hora local a UTC (Honduras = UTC-6)
offsetHoras = -6;  // Honduras está 6 horas detrás de UTC
timestampUTC = timestampLocal - %Hours(offsetHoras);
// Resultado: '2026-01-26-16.55.39.123456' (Hora UTC)

// 8.4 - Método alternativo: Calcular offset dinámicamente
// Obtener offset del sistema
Dcl-S offsetSistema Packed(5:0);
Exec SQL
  SELECT CURRENT_TIMEZONE
  INTO :offsetSistema
  FROM SYSIBM.SYSDUMMY1;
// offsetSistema contiene minutos de diferencia con UTC

// Convertir minutos a horas y minutos
offsetHoras = offsetSistema / 60;
offsetMinutos = %Rem(offsetSistema : 60);

// 8.5 - Convertir UTC a hora local
timestampLocal = timestampUTC + %Hours(6);  // Para Honduras UTC-6

//=====================================================================
// SECCIÓN 9: LEER/ESCRIBIR UTC EN ARCHIVOS FÍSICOS
//=====================================================================

// 9.1 - Escribir timestamp UTC en archivo físico
Dcl-S logId Packed(10:0);
Dcl-S logMessage Char(100);

logId = 1;
timestampLocal = %Timestamp();
timestampUTC = timestampLocal - %Hours(6);  // Convertir a UTC
logMessage = 'Registro de prueba con UTC';

// Escribir en archivo físico
LOGID = logId;
LOGTIMESTAMP = timestampLocal;
LOGUTC = timestampUTC;
LOGMESSAGE = logMessage;
Write LOGFILE;

// 9.2 - Leer timestamp UTC desde archivo físico y convertir a local
Dcl-F LOGFILE2 Usage(*Input) Keyed;

Chain logId LOGFILE2;
If %Found(LOGFILE2);
  timestampUTC = LOGUTC;
  timestampLocal = timestampUTC + %Hours(6);  // Convertir UTC a local
EndIf;

//=====================================================================
// SECCIÓN 10: CONVERSIONES UTC CON SQL EMBEBIDO
//=====================================================================

// 10.1 - Insertar timestamp UTC en tabla
Exec SQL
  INSERT INTO LOGFILE (LOGID, LOGTIMESTAMP, LOGUTC, LOGMESSAGE)
  VALUES (:logId,
          CURRENT_TIMESTAMP,
          CURRENT_TIMESTAMP - 6 HOURS,
          :logMessage);

// 10.2 - Leer y convertir UTC a local con SQL
Exec SQL
  SELECT LOGUTC + 6 HOURS,
         LOGTIMESTAMP
  INTO :timestampLocal, :timestampUTC
  FROM LOGFILE
  WHERE LOGID = :logId;

// 10.3 - Usar función TIMESTAMP_FORMAT para parsear UTC
Dcl-S utcString Char(20);
utcString = '2026-01-26T16:55:39Z';  // Formato ISO 8601 UTC

Exec SQL
  SELECT TIMESTAMP_FORMAT(:utcString, 'YYYY-MM-DD"T"HH24:MI:SS"Z"')
  INTO :timestampUTC
  FROM SYSIBM.SYSDUMMY1;

// 10.4 - Convertir timestamp a formato UTC ISO 8601
Exec SQL
  SELECT VARCHAR_FORMAT(LOGUTC, 'YYYY-MM-DD"T"HH24:MI:SS"Z"')
  INTO :utcString
  FROM LOGFILE
  WHERE LOGID = :logId;
// Resultado: '2026-01-26T16:55:39Z'

//=====================================================================
// SECCIÓN 11: CASOS DE USO PRÁCTICOS CON UTC
//=====================================================================

// 11.1 - Función para convertir local a UTC
Dcl-Proc ConvertirLocalAUTC;
  Dcl-PI *N Timestamp;
    pTimestampLocal Timestamp Const;
    pOffsetHoras Packed(3:0) Const;
  End-PI;

  Return pTimestampLocal - %Hours(pOffsetHoras);
End-Proc;

// 11.2 - Función para convertir UTC a local
Dcl-Proc ConvertirUTCALocal;
  Dcl-PI *N Timestamp;
    pTimestampUTC Timestamp Const;
    pOffsetHoras Packed(3:0) Const;
  End-PI;

  Return pTimestampUTC + %Hours(pOffsetHoras);
End-Proc;

// 11.3 - Uso de las funciones
timestampLocal = %Timestamp();
timestampUTC = ConvertirLocalAUTC(timestampLocal : 6);

// Escribir en archivo con UTC
LOGID = 2;
LOGTIMESTAMP = timestampLocal;
LOGUTC = timestampUTC;
LOGMESSAGE = 'Usando funciones de conversión';
Write LOGFILE;

// 11.4 - Parsear diferentes formatos UTC
Dcl-S utcISO8601 Char(24);
Dcl-S utcRFC3339 Char(25);

// Formato ISO 8601: 2026-01-26T16:55:39Z
utcISO8601 = '2026-01-26T16:55:39Z';
timestampUTC = %Timestamp(%Replace('-' : %Subst(utcISO8601:1:19) : 11 : 1));

// Formato RFC 3339: 2026-01-26T16:55:39.123Z
utcRFC3339 = '2026-01-26T16:55:39.123Z';
timestampUTC = %Timestamp(%Replace('-' : %Subst(utcRFC3339:1:23) : 11 : 1));

// 11.5 - Convertir timestamp a diferentes zonas horarias
Dcl-S timestampNY Timestamp;    // New York (UTC-5)
Dcl-S timestampLondon Timestamp; // London (UTC+0)
Dcl-S timestampTokyo Timestamp;  // Tokyo (UTC+9)

timestampUTC = %Timestamp();
timestampNY = timestampUTC - %Hours(5);
timestampLondon = timestampUTC;
timestampTokyo = timestampUTC + %Hours(9);

//=====================================================================
// SECCIÓN 12: VALIDACIÓN Y MANEJO DE ERRORES UTC
//=====================================================================

// 12.1 - Validar formato UTC antes de convertir
Dcl-S utcValido Ind;
Dcl-S utcInput Char(20);

utcInput = '2026-01-26T16:55:39Z';

Monitor;
  // Intentar parsear el formato UTC
  timestampUTC = %Timestamp(%Replace('-' : %Subst(utcInput:1:19) : 11 : 1));
  utcValido = *On;
On-Error;
  utcValido = *Off;
  // Manejar error de formato inválido
EndMon;

// 12.2 - Comparar timestamps en diferentes zonas horarias
Dcl-S timestamp1Local Timestamp;
Dcl-S timestamp2Local Timestamp;
Dcl-S timestamp1UTC Timestamp;
Dcl-S timestamp2UTC Timestamp;
Dcl-S sonIguales Ind;

timestamp1Local = %Timestamp('2026-01-26-10.55.39.000000');
timestamp2Local = %Timestamp('2026-01-26-11.55.39.000000');

// Convertir ambos a UTC para comparación correcta
timestamp1UTC = ConvertirLocalAUTC(timestamp1Local : 6);
timestamp2UTC = ConvertirLocalAUTC(timestamp2Local : 5);

sonIguales = (timestamp1UTC = timestamp2UTC);

//=====================================================================
// SECCIÓN 13: INTEGRACIÓN CON APIs Y SERVICIOS WEB
//=====================================================================

// 13.1 - Preparar timestamp para envío a API REST (formato ISO 8601)
Dcl-S jsonTimestamp Char(24);

timestampUTC = ConvertirLocalAUTC(%Timestamp() : 6);
jsonTimestamp = %Char(%Date(timestampUTC) : *ISO) + 'T' +
                %Char(%Time(timestampUTC) : *HMS0) + 'Z';
// Resultado: '2026-01-26T16:55:39Z'

// 13.2 - Parsear respuesta de API con timestamp UTC
Dcl-S apiResponse Char(24);
apiResponse = '2026-01-26T16:55:39Z';

// Extraer componentes
Dcl-S fechaParte Char(10);
Dcl-S horaParte Char(8);

fechaParte = %Subst(apiResponse : 1 : 10);
horaParte = %Subst(apiResponse : 12 : 8);

timestampUTC = %Timestamp(fechaParte + '-' + horaParte);
timestampLocal = ConvertirUTCALocal(timestampUTC : 6);

// 13.3 - Actualizar registro con timestamp UTC desde API
Exec SQL
  UPDATE LOGFILE
  SET LOGUTC = :timestampUTC,
      LOGTIMESTAMP = :timestampLocal
  WHERE LOGID = :logId;

