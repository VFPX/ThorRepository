Lparameters tcProject, tcCursor, tlIncludeDBFs


Local lcProjectPath

If Empty (tcProject) And _vfp.Projects.Count # 0
	lcProject = _vfp.ActiveProject.Name
Else
	lcProject = tcProject
Endif

If Empty (lcProject) Or Not File (lcProject)
	? 'Project ' + tcProject + ' not found.'
	Execscript (_Screen.cThorDispatcher, 'Result=', .F.)
	Return .F.
Endif

lcProjectPath = Justpath(lcProject)

tcCursor = Evl(tcCursor, 'Query')

*-- In the below Query, records of type 'W' are Projects Hooks, and they cannot be processed 
Select Left(Name, 254) As filename, {//:} as LastChange ;
	From (lcproject) ;
	Where Type <> 'H' And ;
	Justext(Lower(Name)) $ 'scx vcx frx mnx lbx ' + Iif(tlIncludeDBFs, 'dbf ', '');
	Into Cursor (tcCursor) Readwrite

lcProjectPath = Justpath(lcproject)

lcMissingFiles = ''

Scan
	If !(Lower(lcProjectPath) $ Lower(filename))
		lcFileWithFullPath = FullPath(filename, Addbs(lcProjectPath))
		Replace filename With lcFileWithFullPath In (tcCursor)
	Endif

	If File(filename) && Remove file from cursor if it can't be found
		Replace LastChange with Fdate(filename, 1)
	Else 
		Delete Next 1
		lcMissingFiles = filename + Chr(13)
	Endif

EndScan

Select * From (tcCursor) Where deleted() = .f. order by 1 Into Cursor (tcCursor)

If !Empty(lcMissingFiles)
		MessageBox(lcMissingFiles, 16, 'Inaccessible Files:')
Endif

*-- Close the Project Cursor ------------------
Use In Strtran(Justfname(lcproject), ' ', '_') 

Select (tcCursor)

Execscript (_Screen.cThorDispatcher, 'Result=', .t.)
Return .t. 