      **free
       ctl-opt copyright('Mario Salgado');
       ctl-opt dftactgrp(*no) alwnull(*usrctl) ACTGRP(*NEW);
       ctl-opt option(*srcstmt:*showcpy:*expdds);
       ctl-opt Expropts(*Resdecpos);
       ctl-opt datfmt(*ymd);
       ctl-opt DATEDIT(*YMD);

       dcl-f pagurlpf   disk(*ext) usage(*input) keyed;
       dcl-f scusuarios disk(*ext) usage(*input) keyed;
       dcl-s Url  Varchar(70);
       dcl-s Cod  Packed(5:0) Inz(2);
       dcl-s Usuario  Char(10) Inz(*Blanks);
       dcl-s RedUser  Varchar(20);
       dcl-s Part1    Char(9);
       dcl-s Part2    Char(22) Inz('\AS400\Trasladocum.bat');
       dcl-s Windows  VarChar(256);

       dcl-ds Pgm psds qualified ;
        Proc char(10) ;             // Module or main procedure name
        StsCde zoned(5) ;           // Status code
        PrvStsCde zoned(5) ;        // Previous status
        SrcLineNbr char(8) ;        // Source line number
        Routine char(8) ;           // Name of the RPG routine
        Parms zoned(3) ;            // Number of parms passed to program
        ExceptionType char(3) ;     // Exception type
        ExceptionNbr char(4) ;      // Exception number
        Exception char(7) samepos(ExceptionType) ;
        Reserved1 char(4) ;         // Reserved
        MsgWrkArea char(30) ;       // Message work area
        PgmLib char(10) ;           // Program library
        ExceptionData char(80) ;    // Retrieved exception data
        Rnx9001Exception char(4) ;  // Id of exception that caused RNX9001
        LastFile1 char(10) ;        // Last file operation occurred on
        Unused1 char(6) ;           // Unused
        DteEntered char(8) ;        // Date entered system
        StrDteCentury zoned(2) ;    // Century of job started date
        LastFile2 char(8) ;         // Last file operation occurred on
        LastFileSts char(35) ;      // Last file used status information
        JobName char(10) ;          // Job name
        JobUser char(10) ;          // Job user
        JobNbr zoned(6) ;           // Job number
        StrDte zoned(6) ;           // Job started date
        PgmDte zoned(6) ;           // Date of program running
        PgmTime zoned(6) ;          // Time of program running
        CompileDte char(6) ;        // Date program was compiled
        CompileTime char(6) ;       // Time program was compiled
        CompilerLevel char(4) ;     // Level of compiler
        SrcFile char(10) ;          // Source file name
        SrcLib char(10) ;           // Source file library
        SrcMbr char(10) ;           // Source member name
        ProcPgm char(10) ;          // Program containing procedure
        ProcMod char(10) ;          // Module containing procedure
        SrcLineNbrBin bindec(2) ;   // Source line number as binary
        LastFileStsBin bindec(2) ;  // Source id matching positions 228-235
        User char(10) ;             // Current user
        ExtErrCode int(10) ;        // External error code
        IntoElements int(20) ;      // Elements set by XML-INTO or DATA-INTO (7.3)
          InternalJobId char(16) ;    // Internal job id (7.3 TR6)
          SysName char(8) ;           // System name (7.3 TR6)
       end-ds ;

       dcl-pr QCMDEXC extpgm ;
        *n char(1024) options(*varsize) const ;
        *n packed(15:5) const ;
       end-pr ;

       dcl-s Command varchar(1024);
       dcl-s Length packed(15:5);

       dcl-pr sleep int(10) extproc('sleep') ;
       *n uns(10) value ;
       end-pr ;

       dcl-pr usleep int(10) extproc('usleep') ;
       *n uns(10) value ;
       end-pr ;

        Command = 'CLRPFM QTEMP/' + File ;
        QCMDEXC(Command:%len(%trimr(Command)));


        Usuario = pgm.user;
        Exsr S1process;
        CargaMasiva();
        *Inlr = *on;
        Return;
           Begsr S1Process;
           Chain Usuario scusuarios;
            If %Found(scusuarios);
            RedUser = USRRED;
            Endif;
           Chain Cod pagurlpf;
            Clear Part1;
            Clear Windows;
            If %Found(pagurlpf);
            Url = urldire;
            Part1 = %Subst(Url:1:9);
            Clear Url;
            Windows = %Trim(RedUser) + Part2;
            Url = Part1 + %Trim(Windows);
            Endif;
            wCmdString = 'STRPCO PCTA(*NO)';

            Monitor;
            pQCmdExc(wCmdString:
            %len(%trim(wCmdString)) );
            On-error;
            Endmon;

            wCommand =
            'start' + ' ' + %Trim(Url);
            wCmdString = 'strpccmd pccmd('''
            + %trim(wCommand)
            + ''') pause(*NO)';
            pQCmdExc(wCmdString:
            %len(%trim(wCmdString)) );
            Sleep(2);
            Endsr;
