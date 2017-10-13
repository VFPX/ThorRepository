Lparameters tcProject, tlForceIt

Local loShellApp As 'Shell.Application'
Local lcFile, lcFoxBin2PRG, lcFoxBin2PRGFolder, lcNewFileContents, lcProject, lcProjectFiles
Local lcSCCFilename, lcSafety, lcSourceCursor, ldMainFileDate, ldSCCFileDate, loFile, loNameSpace

* --------------------------------------------------------------------------------
* Have to be able to identify where the EXE lives
lcFoxBin2PRGFolder = Execscript( _Screen.cThorDispatcher, 'Thor_Proc_GetFoxBin2PrgFolder' )
If Empty( m.lcFoxBin2PRGFolder )
	Messagebox('FoxBin2Prg folder not found and not selected.')
	Return
Endif
lcFoxBin2PRG = Addbs(m.lcFoxBin2PRGFolder ) + 'foxbin2prg.exe'

* --------------------------------------------------------------------------------
* Parameter tcProject can be 
*		an alias of a cursor with a field <FileName>
*		the full path name of a project
*		empty to mean the current project
If Not Empty(m.tcProject) And Vartype(m.tcProject) = 'C' And Used(m.tcProject)

	lcProjectFiles = m.tcProject
	Wait 'Generating FoxBin2PRG files' Window Nowait At 20, 60

Else

	If Empty (m.tcProject) And _vfp.Projects.Count # 0
		lcProject = _vfp.ActiveProject.Name
	Else
		lcProject = m.tcProject
	Endif

	If Empty (m.lcProject) Or Not File (m.lcProject)
		Return Execscript (_Screen.cThorDispatcher, 'Result=', .F.)
	Endif

	lcSourceCursor = 'csrSource'
	Execscript (_Screen.cThorDispatcher, 'Thor_Proc_GetFilesFromProjectForScc', m.lcProject, m.lcSourceCursor, .T.)

	If Not Used (m.lcSourceCursor )
		Return Execscript (_Screen.cThorDispatcher, 'Result=', .F.)
	Endif

	lcProjectFiles = 'csrProjectFiles'
	Select  FileName,													;
			Upper(Padr(Justfname(FileName), 60))    As  cJustFName		;
		From (m.lcSourceCursor)											;
		Order By cJustFName												;
		Into Cursor (m.lcProjectFiles)
	Wait 'Generating FoxBin2PRG files in ' + Justfname(m.lcProject) Window Nowait At 20, 60

Endif

* -------------------------------------------------------------------------------- 
* and away we go

lcSafety = Set ('Safety')
Set Safety Off

loShellApp	   = Createobject ('Shell.Application')

Scan
	lcFile		  = Alltrim (FileName)
	If Justext(Lower(m.lcFile)) $ 'mnx'
		Loop
	Endif
	lcSCCFilename = GetSCCFilename (m.lcFile)

	If Upper(Justext(m.lcFile)) == 'DBF'
		loNameSpace	   = m.loShellApp.NameSpace (Justpath (m.lcFile))
		loFile		   = m.loNameSpace.ParseName (Justfname (m.lcFile))
		ldMainFileDate = m.loFile.ModifyDate
	Else
		ldMainFileDate = Local_Proc_GetMaxTimeStamp(m.lcFile, .T.)
		If Empty(m.ldMainFileDate )
			ldMainFileDate = Datetime(2001, 1, 1)
		Endif
	Endif
		

	*-- Get date on SCC file, so we can compare to main file
	If File (m.lcSCCFilename)
		loNameSpace	  = m.loShellApp.NameSpace (Justpath (m.lcSCCFilename))
		loFile		  = m.loNameSpace.ParseName (Justfname (m.lcSCCFilename))
		ldSCCFileDate = m.loFile.ModifyDate
	Else
		ldSCCFileDate = {//::}
	Endif

	If m.ldSCCFileDate = m.ldMainFileDate And m.tlForceIt = .F.
		Loop
	Endif

	Wait Justfname(Strtran(m.lcFile, Chr(0), '')) Window Nowait At 20, 60

	Do (m.lcFoxBin2PRG) With m.lcFile

	*-- Need to strip out any NULL characters [Chr(0)] so Mercurial source control won't think it's a binary file.
	lcNewFileContents = Strtran (Filetostr (m.lcSCCFilename), Chr(0), Chr(126))
	Strtofile (m.lcNewFileContents, m.lcSCCFilename, 0)

	*-- Set date on SCC file to match the file from which it was generated
	loNameSpace		  = m.loShellApp.NameSpace (Justpath (m.lcSCCFilename ))
	loFile			  = m.loNameSpace.ParseName (Justfname (m.lcSCCFilename ))
	loFile.ModifyDate = m.ldMainFileDate && The date of the main file, which we read above

Endscan

Set Safety &lcSafety

Wait Clear

Use in (Select ('csrProjectFiles'))
Use in (Select ('csrSource')) 

Return Execscript (_Screen.cThorDispatcher, 'Result=', .T.)



*------------------------------------------------------------------
Procedure GetSCCFilename (tcFile)

	Local lcSCCFilename

	lcSCCFilename = m.tcFile
	lcSCCFilename = Strtran (m.lcSCCFilename, '.SCX', '.SC2', 1, 1, 1)
	lcSCCFilename = Strtran (m.lcSCCFilename, '.VCX', '.VC2', 1, 1, 1)
	lcSCCFilename = Strtran (m.lcSCCFilename, '.FRX', '.FR2', 1, 1, 1)
	lcSCCFilename = Strtran (m.lcSCCFilename, '.MNX', '.MN2', 1, 1, 1)
	lcSCCFilename = Strtran (m.lcSCCFilename, '.LBX', '.LB2', 1, 1, 1)
	lcSCCFilename = Strtran (m.lcSCCFilename, '.DBF', '.DB2', 1, 1, 1)

	Return m.lcSCCFilename
Endproc


*-----------------------------------------------------------------------------------------------
Procedure GenerateDbc (tcFile)

	Local lcFinalFilename, lcFXPFile, lcGenDbc, lcOutPutFile

	Close Databases All
	Open Database (m.tcFile)

	lcGenDbc		= Addbs (Home(1)) + 'Tools\GenDBC\GenDbc.prg'
	lcOutPutFile	= Lower (m.tcFile + '.gendbc.prg')
	lcFXPFile		= Strtran (m.lcOutPutFile, '.prg', '.fxp')
	lcFinalFilename	= Strtran (Lower (m.lcOutPutFile), '.dbc.gendbc.prg', '.dba')

	Delete File (m.lcFinalFilename)&& Delete current SSC ascii file

	Do (m.lcGenDbc) With (m.lcOutPutFile)

	Try
		Delete File (m.lcFXPFile) && I do not want to keep the fxp file around
		Rename (m.lcOutPutFile) To (m.lcFinalFilename)
	Catch
	Endtry

Endproc


* -------------------------------------------------------------------------------- 
* -------------------------------------------------------------------------------- 
* Following code duplicates Thor Procedure <Thor_Proc_GetMaxTimeStamp>
* to avoid the overhead of calling Execscript(_Screen.cThorDispatcher
Procedure Local_Proc_GetMaxTimeStamp
	Lparameters tcFile, tlOffset

	* Selects the max timestamp row from a table, converts it to DateTime
	* tlOffset = .T. to offset this time by the number of records found,
	*    so that creation of text files (FoxBin2PRG) can use this
	*    to learn if a file has changed.

	Local laMaxDateTime[1], lcCursor, lcDateTime, lcFileDate, ldFileDate

	lcCursor = 'csrGetMaxTimeStamp'

	If Used(m.lcCursor)
		Use In (m.lcCursor)
	Endif

	*-- Open the table, read the max date of any row in the table ----------
	Use (m.tcFile) Again In 0 Alias &lcCursor Shared
	Select Max(Timestamp), Sum(Iif(Deleted(), 0, 1)) From (m.lcCursor) Into Array laMaxDateTime
	If m.laMaxDateTime > 0
		*!* *{ MJP -- 2014/12/01 13:38:22 - Begin
		*!* lcDateTime = Local_Proc_ConvertTimeStamp(m.laMaxDateTime[1])
		*!* ldFileDate = Ctot(m.lcDateTime)
		ldFileDate = Local_Proc_ConvertTimeStamp(m.laMaxDateTime[1])
		*!* *} MJP -- 2014/12/01 13:38:22 - End
		If m.tlOffset
			ldFileDate = m.ldFileDate - 2 * m.laMaxDateTime[2]
		Endif
	Else
		*!* *{ MJP -- 2014/12/01 13:38:39 - Begin
		* This variable name is wrong, and Date type is being generated
		* rather than a DateTime as in the main part of the IF..ENDIF.
		*!* lcFileDate = {//}
		ldFileDate = {//::}
		*!* *} MJP -- 2014/12/01 13:38:39 - End
	Endif
	Use In (m.lcCursor)

	*Execscript (_Screen.cThorDispatcher, 'Result=', m.ldFileDate )
	Return m.ldFileDate

Endproc



* -------------------------------------------------------------------------------- 
* -------------------------------------------------------------------------------- 
* Following code duplicates Thor Procedure <Thor_Proc_GetMaxTimeStamp>
* to avoid the overhead of calling Execscript(_Screen.cThorDispatcher
Procedure Local_Proc_ConvertTimeStamp

	*  Thor_Proc_TimeStampToDateTime
	*
	*  AUTHOR: Richard A. Schummer            September 1994
	*
	*  Integrted with Thor 2011-11-04 by Matt Slay
	*
	*
	*  COPYRIGHT (c) 1994-2001    Richard A. Schummer
	*     42759 Flis Dr  
	*     Sterling Heights, MI  48314-2850
	*     RSchummer@CompuServe.com
	*
	*  METHOD DESCRIPTION: 
	*     This procedure handles the conversion of the FoxPro TIMESTAMP field to 
	*     a readable (and understandable) date and time.  The procedure will return
	*     the date/time in three formats based on the cStyle parameter.  Timestamp 
	*     field is a 32-bit (numeric compressed) system that the FoxPro development
	*     team created to save on file space in the projects, screens, reports, and
	*     label databases.  This field is used to determine if objects need to be 
	*     recompiled (project manager), or syncronized across platforms (screens,
	*     reports, and labels).
	* 
	*  CALLING SYNTAX: 
	*     <variable> = Local_Proc_ConvertTimeStamp(<nTimeStamp>)
	*
	*     Sample:
	*     ltDateTime = Local_Proc_ConvertTimeStamp(TimeStamp)
	* 
	*  INPUT PARAMETERS: 
	*     nTimeStamp = Required field, must be numeric, no check to verify the
	*                  data passed is valid FoxPro Timestamp, just be sure it is
	*!* MJP -- Removed 2014/12/01 13:28:23
	*!* *     cStyle     = Not required (defaults to "DATETIME"), must be character, 
	*!* *                  and must be one of the following:
	*!* *                   "DATETIME" will return the date/time in MM/DD/YY HH:MM:SS
	*!* *                   "DATE"     will return the date in MM/DD/YY format
	*!* *                   "TIME"     will return the time in HH:MM:SS format
	*
	*  OUTPUT PARAMETERS:
	*!* *{ MJP -- 2014/12/01 13:29:54 - Begin
	*!* *     lcRetval    = The date/time (in requested format) is returned in 
	*!* *                   character type.  Must be converted and parsed to be
	*!* *                   used as date type.
	*     ltRetval    = The date/time as a VFP DateTime value
	*!* *} MJP -- 2014/12/01 13:29:54 - End
	*


	*=============================================================
	* Tried to use this FFC class, but it sometimes gave an error:
	* This.oFrxCursor.GetTimeStampString(timestamp)
	*=============================================================


	*-- MJP -- 12/01/2014 01:30:46 PM
	Lparameter tnTimeStamp	&&, tcStyle

	Local ltRetVal, 		;	&& lcRetVal
		lnYear,				;
		lnMonth,			;
		lnDay,				;
		lnHour,				;
		lnMinute,			;
		lnSecond

	If Type('tnTimeStamp') # 'N'          &&  Timestamp must be numeric
		Wait Window 'Time stamp passed is not numeric'
		Return ''
	Endif

	If m.tnTimeStamp = 0                     &&  Timestamp is zero until built in project
		Return 'Not built into App'
	Endif

	*!* MJP -- Removed 2014/12/01 13:31:12
	*!* If Type('tcStyle') # 'C'              &&  Default return style to both date and time
	*!* 	tcStyle = 'DATETIME'
	*!* Endif

	*!* If Not Inlist(Upper(m.tcStyle), 'DATE', 'TIME', 'DATETIME')
	*!* 	Wait Window 'Style parameter must be DATE, TIME, or DATETIME'
	*!* 	Return ''
	*!* Endif

	lnYear	= ((m.tnTimeStamp / (2 ** 25) + 1980))
	lnMonth	= ((m.lnYear - Int(m.lnYear)    ) * (2 ** 25)) / (2 ** 21)
	lnDay	= ((m.lnMonth - Int(m.lnMonth)  ) * (2 ** 21)) / (2 ** 16)

	lnHour	 = ((m.lnDay - Int(m.lnDay)      ) * (2 ** 16)) / (2 ** 11)
	lnMinute = ((m.lnHour - Int(m.lnHour)    ) * (2 ** 11)) / (2 ** 05)
	lnSecond = ((m.lnMinute - Int(m.lnMinute)) * (2 ** 05)) * 2       &&  Multiply by two to correct
	&&  truncation problem built in
	&&  to the creation algorithm
	&&  (Source: Microsoft Tech Support)

	*!* MJP -- Removed 2014/12/01 13:32:47
	*!* lcRetVal = ''

	*!* If 'DATE' $ Upper(m.tcStyle)
	*!* 	*< 4-Feb-2001 Fixed to display date in machine designated format (Regional Settings)
	*!* 	*< lcRetVal = lcRetVal + RIGHT("0"+ALLTRIM(STR(INT(lnMonth))),2) + "/" +		;
	*!* 	*<                       RIGHT("0"+ALLTRIM(STR(INT(lnDay))),2)   + "/" +		;
	*!* 	*<                       RIGHT("0"+ALLTRIM(STR(INT(lnYear))), IIF(SET("CENTURY") = "ON", 4, 2))

	*!* 	*< RAS 23-Nov-2004, change to work around behavior change in VFP 9.
	*!* 	*< lcRetVal = lcRetVal + DTOC(DATE(lnYear, lnMonth, lnDay))
	*!* 	lcRetVal = m.lcRetVal + Dtoc(Date(Int(m.lnYear), Int(m.lnMonth), Int(m.lnDay)))
	*!* Endif

	*!* If 'TIME' $ Upper(m.tcStyle)
	*!* 	lcRetVal = m.lcRetVal + Iif('DATE' $ Upper(m.tcStyle), ' ', '')
	*!* 	lcRetVal = m.lcRetVal + Right('0' + Alltrim(Str(Int(m.lnHour))), 2)   + ':' +		;
	*!* 		Right('0' + Alltrim(Str(Int(m.lnMinute))), 2) + ':' +							;
	*!* 		Right('0' + Alltrim(Str(Int(m.lnSecond))), 2)
	*!* Endif

	*!* Return m.lcRetVal

	* Just take the Date/Time elements and generate a DateTime value
	* as the return value.
	ltRetVal = DATETIME( Int(m.lnYear), Int(m.lnMonth), Int(m.lnDay), Int(m.lnHour), Int(m.lnMinute), Int(m.lnSecond) )

	RETURN m.ltRetVal

EndProc

