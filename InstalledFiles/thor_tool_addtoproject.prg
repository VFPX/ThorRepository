Lparameters lxParam1

#Define CR Chr[13]
#Define TIMEOUT 4 && ... seconds

****************************************************************
****************************************************************
* Standard prefix for all tools for Thor, allowing this tool to
*   tell Thor about itself.

If Pcount() = 1								;
		And 'O' = Vartype (m.lxParam1)		;
		And 'thorinfo' == Lower (m.lxParam1.Class)

	With m.lxParam1

		* Required
		.Prompt	= 'Add current file (SCX/VCX/PRG) to active project'
		.AppID	= 'ThorRepository'

		.Category = 'Code'
		.Author	  = 'JRN'
		* .Link = 'https://github.com/VFPX/ThorRepository/blob/master/docs/AddToProject.md'
	Endwith

	Return m.lxParam1
Endif

If Pcount() = 0
	Do ToolCode
Else
	Do ToolCode With m.lxParam1
Endif

Return

****************************************************************
****************************************************************
* Normal processing for this tool begins here.                  
Procedure ToolCode
	Lparameters lxParam1

	Local laObjects[1], laSelObj[1], lcFName, lcFileName, lcFullFileName, lcProjectName, lcPrompt
	Local lnChoice, loEditorWin, loProject

	If _vfp.Projects.Count = 0
		Messagebox('No project open')
		Return
	Endif
	loProject	  = _vfp.ActiveProject
	lcProjectName = Justfname(m.loProject.Name)
	If ' ' $ m.lcProjectName 
		lcProjectName = ['] + lcProjectName + [']
	EndIf 

	loEditorWin = Execscript(_Screen.cThorDispatcher, 'Thor_Proc_EditorWin')
	Do Case
		Case m.loEditorWin.GetEnvironment(25) = 1 && PRG
			lcFileName	= m.loEditorWin.GetTitle()
			If File(m.lcFileName)
				lcFullFileName = Fullpath(m.lcFileName)
			Else
				Messagebox('File "' + m.lcFileName + '" not found')
				Return
			Endif
		Case Aselobj(laSelObj, 3) # 0 && SCX or VCX
			lcFullFileName = m.laSelObj[2]
		Otherwise
			Messagebox('Nothing to do')
			Return
	Endcase

	lcFName = Justfname(m.lcFullFileName)
	If ' ' $ m.lcFName 
		lcFname = ['] + lcFname + [']
	EndIf 
	If Type([loProject.Files.Item(lcFullFileName)]) # 'O'
		lcPrompt = [Add ] + m.lcFName + CR + [     to project ] + m.lcProjectName + [?]
		lnChoice = Execscript(_Screen.cThorDispatcher, 'Thor_Proc_Messagebox', m.lcPrompt, 3)
		If m.lnChoice = 'Y'
			m.loProject.Files.Add(m.lcFullFileName)
			lcPrompt = m.lcFName + [ added.]
			Execscript(_Screen.cThorDispatcher, 'Thor_Proc_Messagebox', m.lcPrompt, 0, 'FYI', TIMEOUT)
		Endif
	Else
		lcPrompt = m.lcFName  + CR + [     already in project ] + m.lcProjectName
		lcPrompt = m.lcPrompt + CR + CR + [Remove it?]
		lnChoice = Execscript(_Screen.cThorDispatcher, 'Thor_Proc_Messagebox', m.lcPrompt, 13)
		If m.lnChoice = 'Y'
			m.loProject.Files(m.lcFullFileName).Remove()
			lcPrompt = m.lcFName + [ Removed.]
			Execscript(_Screen.cThorDispatcher, 'Thor_Proc_Messagebox', m.lcPrompt, 0, 'FYI', TIMEOUT)
		Endif
	Endif

Endproc


