**FREE
Dcl-F FTPCMD DISK(*EXT) USAGE(*OUTPUT) USROPN;

Dcl-Pi *N;
  pServidor Char(50);
  pUsuario Char(20);
  pPassword Char(20);
  pCarpeta Char(100);
End-Pi;

Dcl-Ds FTPCMD_Rec ExtName('FTPCMD') End-Ds;

Open FTPCMD;

// Escribir comandos FTP
LINEA = %Trim(pUsuario);
Write FTPCMD_Rec;

LINEA = %Trim(pPassword);
Write FTPCMD_Rec;

LINEA = 'cd ' + %Trim(pCarpeta);
Write FTPCMD_Rec;

LINEA = 'ls MCL*';
Write FTPCMD_Rec;

LINEA = 'quit';
Write FTPCMD_Rec;

Close FTPCMD;

*INLR = *ON;

