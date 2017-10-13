Lparameters lcScope

Local loPackProject As 'clsPackProject'
loPackProject = Newobject('clsPackProject')

Do Case
	Case Empty(m.lcScope)
		Execscript(_Screen.cThorDispatcher, 'Thor_Proc_ScopeProcessor', m.loPackProject)
	Case Vartype(m.lcScope) = 'L' && = .T.
		If _vfp.Projects.Count > 0
			Execscript(_Screen.cThorDispatcher, 'Thor_Proc_ScopeProcessor', m.loPackProject, _vfp.ActiveProject.Name)
		Endif
	Otherwise 
		Execscript(_Screen.cThorDispatcher, 'Thor_Proc_ScopeProcessor', m.loPackProject, m.lcScope)
Endcase

Return



Define Class clsPackProject As Custom

	lSearchOncePerVCX = .T.

	Procedure Process(toData)

		*-- The passed toData object will contain cFilename and the propertied from the
		*-- entire Rowfrom the table (if it was a scx, vcx, frx).
		*-- If it was a prg, it will contain the entire prg code in the cCode property.

		Local lcExtension, lcFileName, loException

		lcFileName	= m.toData.cFileName		
		lcExtension	= Upper(Justext(m.lcFileName))

		If Right(m.lcExtension, 1) = 'X'
			Use && assumes file is currently open
			Try
				Use (m.lcFileName) Exclusive
				Pack
			Catch To m.loException

			Endtry
			Use
		Endif

	Endproc


EndDefine
