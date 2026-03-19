PGM        PARM(&SERVIDOR &USUARIO &PASSWORD &CARPETA)

/* Parámetros de entrada */
DCL        VAR(&SERVIDOR) TYPE(*CHAR) LEN(50)
DCL        VAR(&USUARIO) TYPE(*CHAR) LEN(20)
DCL        VAR(&PASSWORD) TYPE(*CHAR) LEN(20)
DCL        VAR(&CARPETA) TYPE(*CHAR) LEN(100)

/* Variables de trabajo */
DCL        VAR(&FTPCMD) TYPE(*CHAR) LEN(50)
DCL        VAR(&FTPOUT) TYPE(*CHAR) LEN(50)

/* Nombres de archivos temporales */
CHGVAR     VAR(&FTPCMD) VALUE('QTEMP/FTPCMD')
CHGVAR     VAR(&FTPOUT) VALUE('QTEMP/FTPOUT')

/* Crear archivo de comandos FTP */
OVRDBF     FILE(INPUT) TOFILE(&FTPCMD) +
           OVRSCOPE(*CALLLVL)

/* Escribir comandos FTP al archivo */
CALL       PGM(QCMDEXC) PARM('CPYF FROMFILE(QTEMP/FTPCMD) +
           TOFILE(*PRINT)' 50)

/* Crear el archivo de comandos FTP */
CRTPF      FILE(QTEMP/FTPCMD) RCDLEN(200) +
           MAXMBRS(*NOMAX) SIZE(*NOMAX)

/* Agregar comandos FTP */
ADDPFM     FILE(QTEMP/FTPCMD) MBR(FTPCMD)

/* Escribir comandos al archivo usando CPYFRMSTMF o similar */
/* Aquí usaremos un enfoque alternativo con OVRDBF */

OVRDBF     FILE(OUTPUT) TOFILE(QTEMP/FTPCMD) +
           MBR(FTPCMD) OVRSCOPE(*CALLLVL)

/* Ejecutar FTP */
FTP        RMTSYS(&SERVIDOR) +
           FTPCMD(QTEMP/FTPCMD) +
           OUTPUT(QTEMP/FTPOUT)

/* Procesar el archivo de salida */
/* Aquí puedes leer QTEMP/FTPOUT para obtener la lista */

DLTOVR     FILE(*ALL) LVL(*)

ENDPGM

