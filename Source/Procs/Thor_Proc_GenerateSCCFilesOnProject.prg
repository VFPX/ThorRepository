Lparameters tcProject

Local loShellApp As 'Shell.Application'
Local lcFile, lcNewFileContents, lcProject, lcProjectFiles, lcSCCFilename, lcSafety, ldMainFileDate
Local ldSCCFileDate, lnReturn, loFile, loNameSpace

lcProjectFiles = 'csrProjectFiles'
loShellApp	   = Createobject ('Shell.Application')

If Empty (tcProject) And _vfp.Projects.Count # 0
	lcProject = _vfp.ActiveProject.Name
Else
	lcProject = tcProject
Endif

If Empty (lcProject) Or Not File (lcProject)
	Execscript (_Screen.cThorDispatcher, 'Result=', .F.)
	Return .F.
Endif

Execscript (_Screen.cThorDispatcher, 'Thor_Proc_GetFilesFromProjectForScc', lcProject, lcProjectFiles)

If Not Used (lcProjectFiles)
	Execscript (_Screen.cThorDispatcher, 'Result=', .F.)
	Return .F.
Else
	Select (lcProjectFiles)
Endif

? 'Generating SCCTextX files in ' + lcProject

lcSafety = Set ('Safety')
Set Safety Off

Scan
	lcFile		  = Alltrim (filename)
	lcSCCFilename = GetSCCFilename (lcFile)

	*-- Get DateTime of main file -----------------------------------------
	loNameSpace	   = loShellApp.NameSpace (Justpath (lcFile))
	loFile		   = loNameSpace.ParseName (Justfname (lcFile))
	ldMainFileDate = loFile.ModifyDate

	*-- Get date on SCC file, so we can compare to main file
	If File (lcSCCFilename)
		loNameSpace	  = loShellApp.NameSpace (Justpath (lcSCCFilename))
		loFile		  = loNameSpace.ParseName (Justfname (lcSCCFilename))
		ldSCCFileDate = loFile.ModifyDate
	Else
		ldSCCFileDate = {//::}
	Endif

	If ldSCCFileDate = ldMainFileDate
		Loop
	Endif

	? ' * ' + JustFname(Strtran(lcSCCFilename, Chr(0), '')) 

	Do Case
		Case 'dbc' $ Lower (lcFile)
			GenerateDbc (loFile.Name)
		Otherwise
			lnReturn = Execscript (_Screen.cThorDispatcher, 'Thor_Proc_SccTextX', lcFile)
	Endcase

	If lnReturn < 0
		? '   >>> Error generating file.'
		Loop
	Endif

	*-- Need to strip out any NULL characters [Chr(0)] so Mercurial source control won't think it's a binary file.
	lcNewFileContents = Strtran (Filetostr (lcSCCFilename), Chr(0), Chr(126))
	Strtofile (lcNewFileContents, lcSCCFilename, 4)

	*-- Set date on SCC file to match the file from which it was generated
	loNameSpace		  = loShellApp.NameSpace (Justpath (lcSCCFilename ))
	loFile			  = loNameSpace.ParseName (Justfname (lcSCCFilename ))
	loFile.ModifyDate = ldMainFileDate && The date of the main file, which we read above

Endscan

Set Safety &lcSafety

Execscript (_Screen.cThorDispatcher, 'Result=', .T.)
Return .T.



*------------------------------------------------------------------
Procedure GetSCCFilename (tcFile)

	Local lcSCCFilename

	lcSCCFilename = Upper (Strtran (Upper (tcFile), '.SCX', '.SCA'))
	lcSCCFilename = Strtran (lcSCCFilename, '.VCX', '.VCA')
	lcSCCFilename = Strtran (lcSCCFilename, '.FRX', '.FRA')
	lcSCCFilename = Strtran (lcSCCFilename, '.DBC', '.DBA')

	Return lcSCCFilename

	*-----------------------------------------------------------------------------------------------
Procedure GenerateDbc (tcFile)

	Local lcFinalFilename, lcFxpFile, lcGenDbc, lcOutputFile

	Close Databases All
	Open Database (tcFile)

	lcGenDbc		= Addbs (Home(1)) + 'Tools\GenDBC\GenDbc.prg'
	lcOutputFile	= Lower (tcFile + '.gendbc.prg')
	lcFxpFile		= Strtran (lcOutputFile, '.prg', '.fxp')
	lcFinalFilename	= Strtran (Lower (lcOutputFile), '.dbc.gendbc.prg', '.dba')

	Delete File (lcFinalFilename)&& Delete current SSC ascii file

	Do (lcGenDbc) With (lcOutputFile)

	Try
		Delete File (lcFxpFile) && I do not want to keep the fxp file around
		Rename (lcOutputFile) To (lcFinalFilename)
	Catch
	Endtry

Endproc
