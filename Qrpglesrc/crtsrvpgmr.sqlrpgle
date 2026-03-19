**FREE
// =====================================================================
// Program: CREASRVPGM - MARIO SALGADO
// Description: Interactive Module Compilation System
// Features: Library/File/Member selection, Validation, Compilation
//           F4 Prompt support, Error handling, Real-time feedback
// =====================================================================
Ctl-Opt DftActGrp(*No) ActGrp(*New) Option(*SrcStmt:*NoDebugIO)
        BndDir('QC2LE');

// Display File
Dcl-F CRTSRVPGMD WorkStn IndDs(Indicators) SFile(LIBSFL:RRN1)
                                           SFile(FILESFL:RRN2)
                                           SFile(MBRSFL:RRN3)
                                           SFile(MSGSFL:RRN4);

// Indicators Data Structure
Dcl-Ds Indicators;
  Exit           Ind Pos(03);
  Prompt         Ind Pos(04);
  Refresh        Ind Pos(05);
  Search         Ind Pos(06);
  Cancel         Ind Pos(12);
  LibSflDsp      Ind Pos(91);
  LibSflDspCtl   Ind Pos(92);
  LibSflClr      Ind Pos(93);
  LibSflEnd      Ind Pos(94);
  FileSflDsp     Ind Pos(95);
  FileSflDspCtl  Ind Pos(96);
  FileSflClr     Ind Pos(97);
  FileSflEnd     Ind Pos(98);
  MbrSflDsp      Ind Pos(85);
  MbrSflDspCtl   Ind Pos(86);
  MbrSflClr      Ind Pos(87);
  MbrSflEnd      Ind Pos(88);
  SflNxtChg      Ind Pos(99);
  LibProtect     Ind Pos(60);
  LibError       Ind Pos(61);
  FileProtect    Ind Pos(62);
  FileError      Ind Pos(63);
  MbrProtect     Ind Pos(64);
  MbrError       Ind Pos(65);
  OptError       Ind Pos(66);
  TgtLibError    Ind Pos(67);
  StatusHi       Ind Pos(68);
  StatusErr      Ind Pos(69);
  ConfirmErr     Ind Pos(70);
  ResultSuccess  Ind Pos(71);
  ResultError    Ind Pos(72);
  PaseNotFound   Ind Pos(80);
End-Ds;

// API Error Data Structure
Dcl-Ds QUSEC;
  QUSBPRV Int(10) Inz(%Size(QUSEC));
  QUSBAVL Int(10);
  QUSEI   Char(7);
  QUSERVED Char(1);
  QUSED01 Char(256);
End-Ds;

// Object Description Structure
Dcl-Ds OBJD0100 Qualified;
  BytesReturned Int(10);
  BytesAvail Int(10);
  ObjName Char(10);
  ObjLib Char(10);
  ObjType Char(10);
  ObjOwner Char(10);
  ObjDomain Char(2);
  ObjCrtDTS Char(13);
  ObjChgDTS Char(13);
End-Ds;

// Library List Entry Structure
Dcl-Ds LibEntry Qualified Dim(250);
  LibName Char(10);
  LibType Char(10);
End-Ds;

// Work Variables
Dcl-S RRN1 Packed(4:0);
Dcl-S RRN2 Packed(4:0);
Dcl-S RRN3 Packed(4:0);
Dcl-S RRN4 Packed(4:0);
Dcl-S LibCount Int(10);
Dcl-S FileCount Int(10);
Dcl-S MbrCount Int(10);
Dcl-S CmdString Char(2000);
Dcl-S MsgText Char(256);
Dcl-S JobName Char(28);
Dcl-S CompileSuccess Ind;
Dcl-S SelectedLib Char(10);
Dcl-S SelectedFile Char(10);
Dcl-S SelectedMbr Char(10);
Dcl-S ValidLib Ind;
Dcl-S ValidFile Ind;
Dcl-S ValidMbr Ind;
Dcl-S i Int(10);
Dcl-S Found Ind;
Dcl-S CSRROW Packed(3:0);
Dcl-S CSRCOL Packed(3:0);

// SQL Host Variables for cursors
Dcl-S SQL_Library Char(10) CCSID(284);
Dcl-S SQL_File    Char(10) CCSID(284);
Dcl-S SQL_NumPase Char(10) CCSID(284);
Dcl-S SQL_TempLib Char(10) CCSID(284);

// SQL Options and Cursor Declarations
Exec SQL SET OPTION COMMIT = *NONE, CLOSQLCSR = *ENDMOD;

// Declare cursors at global level using global host variables
Exec SQL DECLARE C1LIB CURSOR FOR
  SELECT CAST(SYSTEM_SCHEMA_NAME AS CHAR(10))
  FROM QSYS2.LIBRARY_LIST_INFO
  WHERE TYPE IN ('USER', 'SYSTEM')
  ORDER BY ORDINAL_POSITION;

Exec SQL DECLARE C2SRC CURSOR FOR
  SELECT CAST(SYSTEM_TABLE_NAME AS CHAR(10)),
         CAST(SYSTEM_TABLE_SCHEMA AS CHAR(10)),
         CAST(COALESCE(TABLE_TEXT, ' ') AS CHAR(50))
  FROM QSYS2.SYSTABLES
  WHERE SYSTEM_TABLE_SCHEMA = :SQL_Library
    AND TABLE_TYPE = 'P'
    AND SYSTEM_TABLE_NAME LIKE 'Ñ%'
  ORDER BY SYSTEM_TABLE_NAME;

Exec SQL DECLARE C2PASE CURSOR FOR
  SELECT CAST(SYSTEM_TABLE_NAME AS CHAR(10)),
         CAST(SYSTEM_TABLE_SCHEMA AS CHAR(10)),
         CAST(COALESCE(TABLE_TEXT, ' ') AS CHAR(50))
  FROM QSYS2.SYSTABLES
  WHERE SYSTEM_TABLE_SCHEMA = :SQL_Library
    AND TABLE_TYPE = 'P'
    AND SYSTEM_TABLE_NAME LIKE 'Ñ%'
    AND UPPER(TABLE_TEXT) LIKE CONCAT('%', CONCAT(TRIM(:SQL_NumPase), '%'))
  ORDER BY SYSTEM_TABLE_NAME;

Exec SQL DECLARE C3MBR CURSOR FOR
  SELECT CAST(SYSTEM_TABLE_MEMBER AS CHAR(10)),
         CAST(COALESCE(SOURCE_TYPE, ' ') AS CHAR(10)),
         CAST(COALESCE(PARTITION_TEXT, ' ') AS CHAR(50))
  FROM QSYS2.SYSPARTITIONSTAT
  WHERE SYSTEM_TABLE_SCHEMA = :SQL_Library
    AND SYSTEM_TABLE_NAME = :SQL_File
  ORDER BY SYSTEM_TABLE_MEMBER;

// API Prototypes
Dcl-PR QUSRJOBI ExtPgm('QUSRJOBI');
  RcvVar Char(32767) Options(*VarSize);
  RcvVarLen Int(10) Const;
  Format Char(8) Const;
  QualJobName Char(26) Const;
  IntJobID Char(16) Const;
  ErrorCode Char(32767) Options(*VarSize);
End-PR;

Dcl-PR QUSROBJD ExtPgm('QUSROBJD');
  RcvVar Char(32767) Options(*VarSize);
  RcvVarLen Int(10) Const;
  Format Char(8) Const;
  QualObjName Char(20) Const;
  ObjType Char(10) Const;
  ErrorCode Char(32767) Options(*VarSize);
End-PR;

Dcl-PR QtmhRdStin ExtProc('QtmhRdStin');
  Buffer Pointer Value;
  BufLen Int(10) Const;
  BytesRead Int(10);
  ErrorCode Char(32767) Options(*VarSize);
End-PR;

// Ejecución de comandos CL via QSYS2.QCMDEXC (no requiere prototipo)

// =====================================================================
// Main Processing
// =====================================================================
Main();
*InLR = *On;
Return;

// =====================================================================
// Main Procedure
// =====================================================================
Dcl-Proc Main;

  Initialize();

  DoU Exit;
    DisplayMainPanel();

    If Exit;
      Leave;
    EndIf;

    If Prompt;
      HandlePrompt();
    ElseIf Refresh;
      Initialize();
    ElseIf Not Cancel;
      ProcessCompilation();
    EndIf;
  EndDo;

End-Proc;

// =====================================================================
// Initialize Program
// =====================================================================
Dcl-Proc Initialize;

  // Set program name and date/time
  PGMNAM = 'CRTSRVPGM';
  CURDATE = %Int(%Char(%Date():*EUR0));
  CURTIME = %Dec(%Time());

  // Initialize fields
  INLIB = *Blanks;
  NUMPASE = *Blanks;
  INSRCF = *Blanks;
  INMBR = *Blanks;
  CRTOPT = '1';
  TGTLIB = '*CURLIB';
  DBGVIEW = '*SOURCE';
  OPTIMIZE = '*NONE';
  GENLVL = 10;
  STATUS = 'Ready';

  // Initialize cursor position (0 = default)
  CSRROW = 0;
  CSRCOL = 0;

  // Clear all error indicators
  ClearErrorIndicators();

  // Load library list
  LoadLibraryList();

End-Proc;

// =====================================================================
// Display Main Panel
// =====================================================================
Dcl-Proc DisplayMainPanel;

  CURDATE = %Int(%Char(%Date():*EUR0));
  CURTIME = %Dec(%Time());

  // Protect INSRCF field if NUMPASE is filled
  If Not IsFieldEmpty(NUMPASE);
    FileProtect = *On;
    FileError = *Off;  // Don't show error, just protect
  Else;
    // Allow user to modify any field - unprotect all
    LibProtect = *Off;
    FileProtect = *Off;
    MbrProtect = *Off;
    // Sync input field with output field when not protected
    INSRCFI = INSRCF;
  EndIf;

  // Set cursor position if specified (0 means default)
  // ##ROW and ##COL are set by selection procedures

  ExFmt MAINPNL;

  // Sync input field back to output field
  If Not FileProtect;
    INSRCF = INSRCFI;
  EndIf;

  // Auto-validate fields when user enters data directly (without F4)
  If Not Prompt and Not Exit and Not Cancel and Not Refresh;
    ValidateFieldsOnInput();
  EndIf;

End-Proc;

// =====================================================================
// Validate Fields On Input (Auto-validation)
// =====================================================================
Dcl-Proc ValidateFieldsOnInput;

  // Clear previous error indicators
  ClearErrorIndicators();

  // Validate library if entered
  If INLIB <> *Blanks;
    If Not ValidateLibrary(INLIB);
      STATUS = 'Library ' + %Trim(INLIB) + ' not found in library list';
      LibError = *On;
      StatusErr = *On;
    Else;
      // Library is valid, show success
      LibProtect = *Off;
      STATUS = 'Library ' + %Trim(INLIB) + ' is valid';
      StatusHi = *On;
    EndIf;
  EndIf;

  // Check if user entered NUMPASE and INSRCFI manually (not allowed)
  If Not IsFieldEmpty(NUMPASE) and Not IsFieldEmpty(INSRCFI);
    // User tried to enter both - show error
    STATUS = 'No puede ingresar Archivo cuando usa Número de pase. Use F4';
    FileError = *On;
    StatusErr = *On;
    INSRCF = *Blanks;  // Clear the invalid entry
    INSRCFI = *Blanks;
    // Validate source file if library and file are entered (and no NUMPASE)
  ElseIf Not IsFieldEmpty(INLIB) and Not IsFieldEmpty(INSRCF) and
         IsFieldEmpty(NUMPASE);
    If Not ValidateSourceFile(INLIB:INSRCF);
      STATUS = 'Source file ' + %Trim(INSRCF) + ' not found in ' +
               %Trim(INLIB);
      FileError = *On;
      StatusErr = *On;
    Else;
      // Source file is valid
      FileProtect = *Off;
      STATUS = 'Source file ' + %Trim(INSRCF) + ' is valid';
      StatusHi = *On;
    EndIf;
  EndIf;

  // Validate member if all three are entered
  If INLIB <> *Blanks and INSRCF <> *Blanks and INMBR <> *Blanks;
    If Not ValidateMember(INLIB:INSRCF:INMBR);
      STATUS = 'Member ' + %Trim(INMBR) + ' not found in ' +
               %Trim(INLIB) + '/' + %Trim(INSRCF);
      MbrError = *On;
      StatusErr = *On;
    Else;
      // Member is valid, ready to compile
      MbrProtect = *Off;
      STATUS = 'Ready to compile ' + %Trim(INLIB) + '/' +
               %Trim(INSRCF) + '(' + %Trim(INMBR) + ')';
      StatusHi = *On;
    EndIf;
  EndIf;

End-Proc;

// =====================================================================
// Load Library List
// =====================================================================
Dcl-Proc LoadLibraryList;
  Dcl-S CmdStr Char(500);
  Dcl-S LibListStr Char(2750);
  Dcl-S Pos Int(10);
  Dcl-S NextPos Int(10);
  Dcl-S TempLib Char(10) CCSID(284);

  LibCount = 0;

  // Get library list using DSPLIBL
  CmdStr = 'DSPLIBL OUTPUT(*PRINT)';

  Monitor;
    // FIX-002: Cierre defensivo antes de abrir
    Exec SQL CLOSE C1LIB;

    Exec SQL OPEN C1LIB;

    // FIX-002: Validar SQLCODE despues de OPEN
    If SQLCODE <> 0;
      STATUS = 'Error al obtener lista de bibliotecas';
      StatusErr = *On;
      // Fallback
      LibCount = 1;
      LibEntry(1).LibName = 'QGPL';
      LibEntry(1).LibType = '*USER';
      Return;
    EndIf;

    Exec SQL FETCH C1LIB INTO :SQL_TempLib;

    DoW SQLCODE = 0;
      LibCount += 1;
      LibEntry(LibCount).LibName = SQL_TempLib;

      // Determine library type
      If LibCount <= 15;
        LibEntry(LibCount).LibType = '*SYSTEM';
      Else;
        LibEntry(LibCount).LibType = '*USER';
      EndIf;

      Exec SQL FETCH C1LIB INTO :SQL_TempLib;
    EndDo;

    Exec SQL CLOSE C1LIB;

  On-Error;
    // Fallback: Add common libraries
    LibCount = 1;
    LibEntry(1).LibName = 'QGPL';
    LibEntry(1).LibType = '*USER';
  EndMon;

End-Proc;

// =====================================================================
// Handle F4 Prompt
// =====================================================================
Dcl-Proc HandlePrompt;

  // Smart logic: Show prompt for the next empty field in sequence
  // Order: Library -> NumPase -> File -> Member
  // If NumPase is filled, File field is protected (no F4)

  // If library is empty, show library list
  If IsFieldEmpty(INLIB);
    ShowLibraryList();

    // If library is filled and NumPase is filled, show filtered source files
  ElseIf Not IsFieldEmpty(INLIB) and Not IsFieldEmpty(NUMPASE) and
         IsFieldEmpty(INSRCF);
    ShowSourceFilesByPase(INLIB:NUMPASE);
    // After selecting file with NumPase, automatically show members
    If Not IsFieldEmpty(INSRCF);
      ShowMembers(INLIB:INSRCF);
    EndIf;

    // If library and file are filled and member is empty, show member list
  ElseIf Not IsFieldEmpty(INLIB) and Not IsFieldEmpty(INSRCF) and
         IsFieldEmpty(INMBR);
    ShowMembers(INLIB:INSRCF);

    // If library is filled but NumPase is empty and file is empty, show all
  ElseIf Not IsFieldEmpty(INLIB) and IsFieldEmpty(NUMPASE) and
         IsFieldEmpty(INSRCF);
    ShowSourceFiles(INLIB);

    // All fields filled - show member list (allow re-selection)
  Else;
    ShowMembers(INLIB:INSRCF);
  EndIf;

End-Proc;

// =====================================================================
// Show Library List Selection
// =====================================================================
Dcl-Proc ShowLibraryList;
  Dcl-S Selected Ind;
  Dcl-S SearchStr Char(10);

  Selected = *Off;
  SearchStr = *Blanks;

  DoU Selected or Cancel;
    // Clear and load subfile
    LibSflClr = *On;
    Write LIBCTL;
    LibSflClr = *Off;

    RRN1 = 0;

    For i = 1 to LibCount;
      // Apply search filter if specified
      If SearchStr <> *Blanks;
        If %Scan(%Trim(SearchStr):LibEntry(i).LibName) = 0;
          Iter;
        EndIf;
      EndIf;

      RRN1 += 1;
      LIBNAME = LibEntry(i).LibName;
      LIBTYPE = LibEntry(i).LibType;
      LIBTEXT = GetLibraryText(LIBNAME);
      OPT = ' ';
      Write LIBSFL;
    EndFor;

    If RRN1 > 0;
      LibSflDsp = *On;
      LibSflDspCtl = *On;
      LibSflEnd = *On;
    EndIf;

    SRCHLIB = SearchStr;
    ExFmt LIBCTL;

    If Cancel or Exit;
      Leave;
    EndIf;

    If Search;
      SearchStr = SRCHLIB;
      Iter;
    EndIf;

    If Refresh;
      LoadLibraryList();
      SearchStr = *Blanks;
      Iter;
    EndIf;

    // Check for selection
    ReadC LIBSFL;
    DoW Not %Eof;
      If OPT = '1';
        INLIB = LIBNAME;
        Selected = *On;
        // Set cursor to source file field (row 6, col 2)
        CSRROW = 6;
        CSRCOL = 2;
        Leave;
      EndIf;
      ReadC LIBSFL;
    EndDo;
  EndDo;

  LibSflDsp = *Off;
  LibSflDspCtl = *Off;

End-Proc;

// =====================================================================
// Show Source Files
// =====================================================================
Dcl-Proc ShowSourceFiles;
  Dcl-Pi *N;
    pLibrary Char(10) Const;
  End-Pi;

  Dcl-S Selected Ind;
  Dcl-S LoadData Ind;

  Selected = *Off;
  FileCount = 0;
  LoadData = *On;

  DoU Selected or Cancel;
    // Load subfile data only when needed
    If LoadData;
      // Clear and load subfile
      FileSflClr = *On;
      Write FILECTL;
      FileSflClr = *Off;

      RRN2 = 0;

      // Query source physical files
      SQL_Library = pLibrary;

      // FIX-002: Cierre defensivo antes de abrir
      Exec SQL CLOSE C2SRC;

      Exec SQL OPEN C2SRC;

      // FIX-002: Validar SQLCODE despues de OPEN
      If SQLCODE <> 0;
        STATUS = 'Error cursor archivos SQLCODE='
               + %Char(SQLCODE);
        StatusErr = *On;
        LoadData = *Off;
        Iter;
      EndIf;

      Exec SQL FETCH C2SRC INTO :SRCFILE, :SRCLIB, :SRCTEXT;

      DoW SQLCODE = 0;
        RRN2 += 1;
        FOPT = ' ';
        Write FILESFL;
        FileCount += 1;

        Exec SQL FETCH C2SRC INTO :SRCFILE, :SRCLIB, :SRCTEXT;
      EndDo;

      Exec SQL CLOSE C2SRC;

      LoadData = *Off;
    EndIf;

    If RRN2 > 0;
      FileSflDsp = *On;
      FileSflDspCtl = *On;
      FileSflEnd = *On;
    EndIf;

    SELLIB = pLibrary;
    ExFmt FILECTL;

    If Cancel or Exit;
      Leave;
    EndIf;

    If Refresh;
      LoadData = *On;
      Iter;
    EndIf;

    // Check for selection
    ReadC FILESFL;
    DoW Not %Eof;
      If FOPT = '1';
        INSRCF = SRCFILE;
        Selected = *On;
        // Set cursor to member field (row 7, col 2)
        CSRROW = 7;
        CSRCOL = 2;
        Leave;
      EndIf;
      ReadC FILESFL;
    EndDo;
  EndDo;

  FileSflDsp = *Off;
  FileSflDspCtl = *Off;

End-Proc;

// =====================================================================
// Show Source Files By Pase
// =====================================================================
Dcl-Proc ShowSourceFilesByPase;
  Dcl-Pi *N;
    pLibrary Char(10) Const;
    pNumPase Char(10) Const;
  End-Pi;

  Dcl-S Selected Ind;
  Dcl-S LoadData Ind;

  Selected = *Off;
  FileCount = 0;
  LoadData = *On;

  DoU Selected or Cancel;
    // Load subfile data only when needed
    If LoadData;
      // Clear and load subfile
      FileSflClr = *On;
      Write FILECTL;
      FileSflClr = *Off;

      RRN2 = 0;

      // Query source physical files filtered by NumPase
      // Format: PN-XXXXXXX where XXXXXXX is the pase number
      SQL_Library = pLibrary;
      SQL_NumPase = %Trim(pNumPase);

      Exec SQL CLOSE C2PASE;

      Exec SQL OPEN C2PASE;

      // Validar SQLCODE despues de OPEN
      If SQLCODE <> 0;
        FileSflDsp = *Off;
        FileSflDspCtl = *Off;
        STATUS = 'Error al buscar pase SQLCODE=' + %Char(SQLCODE);
        StatusErr = *On;
        Leave;
      EndIf;

      Exec SQL FETCH C2PASE INTO :SRCFILE, :SRCLIB, :SRCTEXT;

      DoW SQLCODE = 0;
        RRN2 += 1;
        FOPT = ' ';
        Write FILESFL;
        FileCount += 1;

        Exec SQL FETCH C2PASE INTO :SRCFILE, :SRCLIB, :SRCTEXT;
      EndDo;

      Exec SQL CLOSE C2PASE;

      LoadData = *Off;
    EndIf;

    If RRN2 > 0;
      FileSflDsp = *On;
      FileSflDspCtl = *On;
      FileSflEnd = *On;
      PaseNotFound = *Off;
    Else;
      // Sin resultados: no mostrar subfile, regresar al panel principal
      FileSflDsp = *Off;
      FileSflDspCtl = *Off;
      STATUS = 'Pase ' + %Trim(pNumPase) + ' no existe';
      StatusErr = *On;
      PaseNotFound = *On;
      Leave;
    EndIf;

    SELLIB = pLibrary;
    ExFmt FILECTL;

    If Cancel or Exit;
      Leave;
    EndIf;

    If Refresh;
      LoadData = *On;
      Iter;
    EndIf;

    // Check for selection
    ReadC FILESFL;
    DoW Not %Eof;
      If FOPT = '1';
        INSRCF = SRCFILE;
        Selected = *On;
        // Protect INSRCF field when NumPase is used
        FileProtect = *On;
        Leave;
      EndIf;
      ReadC FILESFL;
    EndDo;
  EndDo;

  FileSflDsp = *Off;
  FileSflDspCtl = *Off;

End-Proc;

// =====================================================================
// Show Members
// =====================================================================
Dcl-Proc ShowMembers;
  Dcl-Pi *N;
    pLibrary Char(10) Const;
    pFile Char(10) Const;
  End-Pi;

  Dcl-S Selected Ind;
  Dcl-S QualFile Char(20);
  Dcl-S LoadData Ind;

  Selected = *Off;
  MbrCount = 0;
  LoadData = *On;
  QualFile = %Trim(pFile) + '       ' + %Trim(pLibrary);

  DoU Selected or Cancel;
    // Load subfile data only when needed
    If LoadData;
      // Clear and load subfile
      MbrSflClr = *On;
      Write MBRCTL;
      MbrSflClr = *Off;

      RRN3 = 0;

      // Query members
      SQL_Library = pLibrary;
      SQL_File = pFile;

      // FIX-002: Cierre defensivo antes de abrir
      Exec SQL CLOSE C3MBR;

      Exec SQL OPEN C3MBR;

      // Validar SQLCODE despues de OPEN
      If SQLCODE <> 0;
        MbrSflDsp = *Off;
        MbrSflDspCtl = *Off;
        STATUS = 'Error al leer miembros SQLCODE=' + %Char(SQLCODE);
        StatusErr = *On;
        Leave;
      EndIf;

      Exec SQL FETCH C3MBR INTO :MBRNAME, :MBRTYPE, :MBRTEXT;

      DoW SQLCODE = 0;
        RRN3 += 1;
        MOPT = ' ';
        Write MBRSFL;
        MbrCount += 1;

        Exec SQL FETCH C3MBR INTO :MBRNAME, :MBRTYPE, :MBRTEXT;
      EndDo;

      Exec SQL CLOSE C3MBR;

      LoadData = *Off;
    EndIf;

    If RRN3 > 0;
      MbrSflDsp = *On;
      MbrSflDspCtl = *On;
      MbrSflEnd = *On;
    Else;
      // Sin miembros: no mostrar subfile, regresar al panel principal
      MbrSflDsp = *Off;
      MbrSflDspCtl = *Off;
      STATUS = 'No hay miembros en ' + %Trim(pFile);
      StatusErr = *On;
      Leave;
    EndIf;

    SELFIL = pFile;
    SELLIBB = pLibrary;
    ExFmt MBRCTL;

    If Cancel or Exit;
      Leave;
    EndIf;

    If Refresh;
      LoadData = *On;
      Iter;
    EndIf;

    // Check for selection
    ReadC MBRSFL;
    DoW Not %Eof;
      If MOPT = '1';
        INMBR = MBRNAME;
        Selected = *On;
        // Set cursor to compilation option field (row 12, col 2)
        CSRROW = 12;
        CSRCOL = 2;
        Leave;
      EndIf;
      ReadC MBRSFL;
    EndDo;
  EndDo;

  MbrSflDsp = *Off;
  MbrSflDspCtl = *Off;

End-Proc;

// =====================================================================
// Process Compilation
// =====================================================================
Dcl-Proc ProcessCompilation;

  // Clear error indicators
  ClearErrorIndicators();

  // Validate inputs
  If Not ValidateInputs();
    Return;
  EndIf;

  // Show confirmation
  If Not ShowConfirmation();
    Return;
  EndIf;

  // Show progress window
  ShowProgress('Compiling module...');

  // Perform compilation
  Select;
    When CRTOPT = '1';
      CompileModule();
    When CRTOPT = '2';
      CompileProgram();
    When CRTOPT = '3';
      CompileServiceProgram();
  EndSl;

  // Show results
  ShowResults();

End-Proc;

// =====================================================================
// Validate Inputs
// =====================================================================
Dcl-Proc ValidateInputs;
  Dcl-Pi *N Ind End-Pi;

  Dcl-S Valid Ind;

  Valid = *On;

  // Validate library
  If INLIB = *Blanks;
    STATUS = 'Library is required';
    LibError = *On;
    StatusErr = *On;
    Valid = *Off;
  Else;
    If Not ValidateLibrary(INLIB);
      STATUS = 'Library ' + %Trim(INLIB) + ' not found in library list';
      LibError = *On;
      StatusErr = *On;
      Valid = *Off;
    EndIf;
  EndIf;

  // Validate source file
  If INSRCF = *Blanks;
    STATUS = 'Source file is required';
    FileError = *On;
    StatusErr = *On;
    Valid = *Off;
  Else;
    If Not ValidateSourceFile(INLIB:INSRCF);
      STATUS = 'Source file ' + %Trim(INSRCF) + ' not found';
      FileError = *On;
      StatusErr = *On;
      Valid = *Off;
    EndIf;
  EndIf;

  // Validate member
  If INMBR = *Blanks;
    STATUS = 'Member is required';
    MbrError = *On;
    StatusErr = *On;
    Valid = *Off;
  Else;
    If Not ValidateMember(INLIB:INSRCF:INMBR);
      STATUS = 'Member ' + %Trim(INMBR) + ' not found';
      MbrError = *On;
      StatusErr = *On;
      Valid = *Off;
    EndIf;
  EndIf;

  // Validate compilation option
  If CRTOPT <> '1' and CRTOPT <> '2' and CRTOPT <> '3';
    STATUS = 'Invalid compilation option';
    OptError = *On;
    StatusErr = *On;
    Valid = *Off;
  EndIf;

  // Validate target library
  If TGTLIB = *Blanks;
    STATUS = 'Target library is required';
    TgtLibError = *On;
    StatusErr = *On;
    Valid = *Off;
  EndIf;

  Return Valid;

End-Proc;

// =====================================================================
// Clear Error Indicators - Utility Function
// =====================================================================
Dcl-Proc ClearErrorIndicators;

  LibError = *Off;
  FileError = *Off;
  MbrError = *Off;
  OptError = *Off;
  TgtLibError = *Off;
  StatusErr = *Off;
  StatusHi = *Off;
  PaseNotFound = *Off;

End-Proc;

// =====================================================================
// Check if Field is Empty - Utility Function
// =====================================================================
Dcl-Proc IsFieldEmpty;
  Dcl-Pi *N Ind;
    pField Char(10) Const;
  End-Pi;

  Return (pField = *Blanks or %Trim(pField) = '');

End-Proc;

// =====================================================================
// Validate Library
// =====================================================================
Dcl-Proc ValidateLibrary;
  Dcl-Pi *N Ind;
    pLibrary Char(10) Const;
  End-Pi;

  Dcl-S i Int(10);

  For i = 1 to LibCount;
    If LibEntry(i).LibName = pLibrary;
      Return *On;
    EndIf;
  EndFor;

  Return *Off;

End-Proc;

// =====================================================================
// Validate Source File
// =====================================================================
Dcl-Proc ValidateSourceFile;
  Dcl-Pi *N Ind;
    pLibrary Char(10) Const;
    pFile Char(10) Const;
  End-Pi;

  Dcl-S QualObj Char(20);

  QualObj = pFile + pLibrary;

  Monitor;
    QUSROBJD(OBJD0100:%Size(OBJD0100):'OBJD0100':QualObj:'*FILE':QUSEC);

    If QUSBAVL = 0;
      Return *On;
    EndIf;
  On-Error;
    Return *Off;
  EndMon;

  Return *Off;

End-Proc;

// =====================================================================
// Validate Member
// =====================================================================
Dcl-Proc ValidateMember;
  Dcl-Pi *N Ind;
    pLibrary Char(10) Const;
    pFile Char(10) Const;
    pMember Char(10) Const;
  End-Pi;

  Dcl-S MbrExists Char(1);

  Monitor;
    Exec SQL SELECT '1' INTO :MbrExists
      FROM QSYS2.SYSPARTITIONSTAT
      WHERE SYSTEM_TABLE_SCHEMA = :pLibrary
        AND SYSTEM_TABLE_NAME = :pFile
        AND SYSTEM_TABLE_MEMBER = :pMember
      FETCH FIRST 1 ROW ONLY;

    If SQLCODE = 0;
      Return *On;
    EndIf;

  On-Error;
    // SQL error occurred, return false
    Return *Off;
  EndMon;

  Return *Off;

End-Proc;

// =====================================================================
// Show Confirmation
// =====================================================================
Dcl-Proc ShowConfirmation;
  Dcl-Pi *N Ind End-Pi;

  CNFMSG1 = 'Compile: ' + %Trim(INMBR);
  CNFMSG2 = 'From: ' + %Trim(INSRCF) + '/' + %Trim(INLIB);

  Select;
    When CRTOPT = '1';
      CNFMSG3 = 'Type: Module';
    When CRTOPT = '2';
      CNFMSG3 = 'Type: Program';
    When CRTOPT = '3';
      CNFMSG3 = 'Type: Service Program';
  EndSl;

  CNFRESP = ' ';
  ConfirmErr = *Off;

  DoU CNFRESP = 'Y' or CNFRESP = 'y' or
      CNFRESP = 'N' or CNFRESP = 'n';
    ExFmt CONFIRM;

    If Cancel or Exit;
      Return *Off;
    EndIf;

    If CNFRESP <> 'Y' and CNFRESP <> 'y' and
       CNFRESP <> 'N' and CNFRESP <> 'n';
      ConfirmErr = *On;
    EndIf;
  EndDo;

  If CNFRESP = 'Y' or CNFRESP = 'y';
    Return *On;
  Else;
    Return *Off;
  EndIf;

End-Proc;

// =====================================================================
// Show Progress
// =====================================================================
Dcl-Proc ShowProgress;
  Dcl-Pi *N;
    pMessage Char(66) Const;
  End-Pi;

  PRGMSG1 = pMessage;
  PRGMSG2 = 'Library: ' + %Trim(INLIB);
  PRGMSG3 = 'Source File: ' + %Trim(INSRCF);
  PRGMSG4 = 'Member: ' + %Trim(INMBR);
  PRGMSG5 = 'Target Library: ' + %Trim(TGTLIB);
  PRGMSG6 = 'Debug View: ' + %Trim(DBGVIEW);

  Write PROGRESS;

End-Proc;

// =====================================================================
// Compile Module
// =====================================================================
Dcl-Proc CompileModule;

  // Add compilation libraries
  AddCompilationLibraries();

  CmdString = 'CRTSQLRPGI OBJ(' + %Trim(TGTLIB) + '/' + %Trim(INMBR) +
              ') SRCFILE(' + %Trim(INLIB) + '/' + %Trim(INSRCF) +
              ') SRCMBR(' + %Trim(INMBR) +
              ') COMMIT(*NONE)' +
              ' OBJTYPE(*MODULE)' +
              ' OPTION(*EVENTF *XREF *NOSECLVL)' +
              ' DBGVIEW(*SOURCE)' +
              ' CLOSQLCSR(*ENDMOD)' +
              ' OUTPUT(*PRINT)';

  Exec SQL CALL QSYS2.QCMDEXC(:CmdString);
  If SQLCODE = 0;
    CompileSuccess = *On;
    STATUS = 'Module compiled successfully';
    StatusHi = *On;
  Else;
    CompileSuccess = *Off;
    STATUS = 'Compilation failed - check job log';
    StatusErr = *On;
  EndIf;

  // Remove compilation libraries
  RemoveCompilationLibraries();

End-Proc;

// =====================================================================
// Compile Program
// =====================================================================
Dcl-Proc CompileProgram;

  Dcl-S BndSrcFile Char(10) Inz;

  // Add compilation libraries
  AddCompilationLibraries();

  // Build binding source file name: replace last 3 chars with 'SRV'
  BndSrcFile = %Subst(INSRCF:1:%Len(%Trim(INSRCF))-3) + 'SRV';

  // Create binding source using RTVBNDSRC
  CmdString = 'RTVBNDSRC SRVPGM(' + %Trim(INLIB) + '/' + %Trim(INMBR) +
              ') SRCFILE(' + %Trim(INLIB) + '/' + %Trim(BndSrcFile) +
              ') MBROPT(*REPLACE)';

  Exec SQL CALL QSYS2.QCMDEXC(:CmdString);
  If SQLCODE = 0;
    CompileSuccess = *On;
    STATUS = 'Binding source created successfully';
    StatusHi = *On;
  Else;
    CompileSuccess = *Off;
    STATUS = 'Binding source creation failed - check job log';
    StatusErr = *On;
  EndIf;

  // Remove compilation libraries
  RemoveCompilationLibraries();

End-Proc;

// =====================================================================
// Compile Service Program
// =====================================================================
Dcl-Proc CompileServiceProgram;

  Dcl-S TextDesc Char(50);

  // Add compilation libraries
  AddCompilationLibraries();

  // Build text description
  TextDesc = 'Programa Servicio de ' + %Trim(INMBR);

  // Create service program
  CmdString = 'CRTSRVPGM SRVPGM(' + %Trim(TGTLIB) + '/' + %Trim(INMBR) +
              ') MODULE(' + %Trim(TGTLIB) + '/' + %Trim(INMBR) +
              ') SRCFILE(*LIBL/QSRVSRC)' +
              ' SRCMBR(*SRVPGM)' +
              ' EXPORT(*ALL)' +
              ' ACTGRP(*CALLER)' +
              ' TEXT(''' + %Trim(TextDesc) + ''')';

  Exec SQL CALL QSYS2.QCMDEXC(:CmdString);
  If SQLCODE = 0;
    CompileSuccess = *On;
    STATUS = 'Service program created successfully';
    StatusHi = *On;
  Else;
    CompileSuccess = *Off;
    STATUS = 'Service program creation failed - check job log';
    StatusErr = *On;
  EndIf;

  // Remove compilation libraries
  RemoveCompilationLibraries();

End-Proc;

// =====================================================================
// Show Results
// =====================================================================
Dcl-Proc ShowResults;

  If CompileSuccess;
    ResultSuccess = *On;
    ResultError = *Off;
    RESMSG1 = 'Compilation completed successfully!';
    RESMSG2 = '';
    RESMSG3 = 'Object: ' + %Trim(INMBR);
    RESMSG4 = 'Library: ' + %Trim(TGTLIB);
    RESMSG5 = 'Source: ' + %Trim(INSRCF) + '/' + %Trim(INLIB);
    RESMSG6 = 'Member: ' + %Trim(INMBR);
    RESMSG7 = '';

    Select;
      When CRTOPT = '1';
        RESMSG8 = 'Type: Module';
      When CRTOPT = '2';
        RESMSG8 = 'Type: Bound Program';
      When CRTOPT = '3';
        RESMSG8 = 'Type: Service Program';
    EndSl;

  Else;
    ResultSuccess = *Off;
    ResultError = *On;
    RESMSG1 = 'Compilation failed!';
    RESMSG2 = '';
    RESMSG3 = 'Object: ' + %Trim(INMBR);
    RESMSG4 = 'Library: ' + %Trim(TGTLIB);
    RESMSG5 = 'Source: ' + %Trim(INSRCF) + '/' + %Trim(INLIB);
    RESMSG6 = 'Member: ' + %Trim(INMBR);
    RESMSG7 = '';
    RESMSG8 = 'Please check the job log for detailed error messages.';

  EndIf;

  ExFmt RESULTS;

End-Proc;

// =====================================================================
// Add Compilation Libraries
// =====================================================================
Dcl-Proc AddCompilationLibraries;

  // Se ignoran errores si las bibliotecas no existen
  CmdString = 'ADDLIBLE LIB(RPGUNIT) POSITION(*FIRST)';
  Exec SQL CALL QSYS2.QCMDEXC(:CmdString);
  CmdString = 'ADDLIBLE LIB(QDEVTOOLS) POSITION(*FIRST)';
  Exec SQL CALL QSYS2.QCMDEXC(:CmdString);

End-Proc;

// =====================================================================
// Remove Compilation Libraries
// =====================================================================
Dcl-Proc RemoveCompilationLibraries;

  // Se ignoran errores si las bibliotecas no estaban en lista
  CmdString = 'RMVLIBLE LIB(QDEVTOOLS)';
  Exec SQL CALL QSYS2.QCMDEXC(:CmdString);
  CmdString = 'RMVLIBLE LIB(RPGUNIT)';
  Exec SQL CALL QSYS2.QCMDEXC(:CmdString);

End-Proc;

// =====================================================================
// Get Library Text
// =====================================================================
Dcl-Proc GetLibraryText;
  Dcl-Pi *N Char(50);
    pLibrary Char(10) Const;
  End-Pi;

  Dcl-S LibText Char(50);

  Exec SQL SELECT COALESCE(CAST(SCHEMA_TEXT AS VARCHAR(50)), ' ')
    INTO :LibText
    FROM QSYS2.SYSSCHEMAS
    WHERE SYSTEM_SCHEMA_NAME = :pLibrary
    FETCH FIRST 1 ROW ONLY;

  If SQLCODE = 0;
    Return LibText;
  Else;
    Return ' ';
  EndIf;

End-Proc;

