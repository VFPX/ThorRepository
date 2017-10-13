Lparameters tcProject

Local loShellApp As 'Shell.Application'
Local lcFile, lcProject, lcProjectFiles, lcRelatedFile, lcSCCFile, ldFileDate, ldLastSCCFileDate
Local lnSelect, loMainFile, loNameSpace, loRelatedFile, loSCCFile

lnSelect = Select()

lcProjectFiles = 'csrProjectFiles'

loShellApp = Createobject('Shell.Application')

Do Case
	Case Pcount() = 0 And _vfp.Projects.Count # 0
		lcProject = _vfp.ActiveProject.Name
	Case File(tcProject)
		lcProject = tcProject
	Otherwise
		? 'Project ' + tcProject + ' not found.'
		Execscript(_Screen.cThorDispatcher, 'Result=', .F.)
		Return .F.
Endcase

Execscript(_Screen.cThorDispatcher, 'Thor_Proc_GetFilesFromProjectForScc', lcProject, lcProjectFiles)

If Not Used(lcProjectFiles)
	? 'Error creating project files cursor for project ' + lcProject
	Select(lnSelect)
	Return Execscript(_Screen.cThorDispatcher, 'Result=', .F.)
Else
	Select(lcProjectFiles)
Endif

Scan

	lcFile = Alltrim(filename, 0, ' ', Chr[0])
	If Justext(Lower(lcFile)) $ 'mnx'
		Loop
	Endif

	ldFileDate = Execscript(_Screen.cThorDispatcher, 'Thor_Proc_GetMaxTimeStamp', lcFile)
	If Empty(ldFileDate)
		Loop
	Endif

	*--- Determine the date of the last SCC file, if present ----
	lcSCCFile = Left(lcFile, Len(lcFile) - 1) + 'A'  && Translate 'SCX' to 'SCA' and so on.

	If File(lcSCCFile)
		loNameSpace		  = loShellApp.NameSpace(Justpath(lcSCCFile))
		loSCCFile		  = loNameSpace.ParseName(Justfname(lcSCCFile))
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
		loNameSpace			  = loShellApp.NameSpace(Justpath(lcFile))
		loMainFile			  = loNameSpace.ParseName(Justfname(lcFile))
		loMainFile.ModifyDate = ldFileDate && Update

		*-- Update the related file date
		lcRelatedFile			 = Left(lcFile, Len(lcFile) - 1) + 'T'  && Translate 'SCX' to 'SCT' and so on.
		loNameSpace				 = loShellApp.NameSpace(Justpath(lcRelatedFile))
		loRelatedFile			 = loNameSpace.ParseName(Justfname(lcRelatedFile))
		loRelatedFile.ModifyDate = ldFileDate
	Endif

Endscan

Select(lnSelect)
Return Execscript(_Screen.cThorDispatcher, 'Result=', .T.)



