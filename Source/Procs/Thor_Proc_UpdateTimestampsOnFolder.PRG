Lparameters tcFolder, tlSubFolders

Local loShellApp As 'Shell.Application'
Local laFiles[1], lcFile, lcFolder, lcRelatedFile, lcSCCFile, lcSubFolder, ldFileDate
Local ldLastSCCFileDate, lnFileCount, lnI, loMainFile, loNameSpace, loRelatedFile, loSCCFile

Do Case
	Case Pcount() = 0
		lcFolder = Addbs (Curdir())
	Case Directory (tcFolder)
		lcFolder = Addbs (tcFolder)
	Otherwise
		? 'Folder ' + tcFolder + ' not found.'
		Return Execscript (_Screen.cThorDispatcher, 'Result=', .F.)
Endcase

lnFileCount	= Adir (laFiles, lcFolder + '*.*', '', 1)
loShellApp	= Createobject ('Shell.Application')

For lnI = 1 To lnFileCount

	lcFile = lcFolder + Alltrim (laFiles[lnI, 1])
	If Not Inlist (Upper(Justext (lcFile)), 'SCX', 'VCX', 'FRX')
		Loop
	Endif

	ldFileDate = Execscript (_Screen.cThorDispatcher, 'Thor_Proc_GetMaxTimeStamp', lcFile)
	If Empty (ldFileDate)
		Loop
	Endif

	*--- Determine the date of the last SCC file, if present ----
	lcSCCFile = Left (lcFile, Len (lcFile) - 1) + 'A'  && Translate 'SCX' to 'SCA' and so on.

	If File (lcSCCFile)
		loNameSpace		  = loShellApp.NameSpace (Justpath (lcSCCFile))
		loSCCFile		  = loNameSpace.ParseName (Justfname (lcSCCFile))
		ldLastSCCFileDate = loSCCFile.ModifyDate
	Else
		ldLastSCCFileDate = {//::}
	Endif

	*-- If last SCC file date is greater than the date of any record in the table, stick with compiled date
	*-- (is don't apply Max(TimeStamp) as determined above.)
	*-- This can be the case if rows have been deleted from table and it looks older than it really is
	If ldLastSCCFileDate > ldFileDate
		Loop
	Else
		*-- Update the date of Main file to be the Max of (TimeStampe) as determined above ------
		loNameSpace			  = loShellApp.NameSpace (Justpath (lcFile))
		loMainFile			  = loNameSpace.ParseName (Justfname (lcFile))
		loMainFile.ModifyDate = ldFileDate && Update

		*-- Update the related file date
		lcRelatedFile			 = Left (lcFile, Len (lcFile) - 1) + 'T'  && Translate 'SCX' to 'SCT' and so on.
		loNameSpace				 = loShellApp.NameSpace (Justpath (lcRelatedFile))
		loRelatedFile			 = loNameSpace.ParseName (Justfname (lcRelatedFile))
		loRelatedFile.ModifyDate = ldFileDate
	Endif

Next lnI

If tlSubFolders
	lnFileCount = Adir (laFiles, lcFolder + '*.*', 'D', 1)
	For lnI = 1 To lnFileCount

		If Not 'D' $ laFiles[lnI, 5]
			Loop
		Endif

		If Not Empty (Chrtran (laFiles[lnI, 1], '.', ''))
			lcSubFolder = lcFolder + Alltrim (laFiles[lnI, 1])
			?lcSubFolder
			Execscript (_Screen.cThorDispatcher, 'THOR_PROC_UPDATETIMESTAMPSONFOLDER', lcSubFolder, tlSubFolders)
		Endif
	Next lnI
Endif

Return Execscript (_Screen.cThorDispatcher, 'Result=', .T.)

