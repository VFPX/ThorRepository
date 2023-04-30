Lparameters lxParam1

#Define CR Chr[13]

****************************************************************
****************************************************************
* Standard prefix for all tools for Thor, allowing this tool to
*   tell Thor about itself.

If Pcount() = 1								;
		And 'O' = Vartype (m.lxParam1)		;
		And 'thorinfo' == Lower (m.lxParam1.Class)

	With m.lxParam1

		* Required
		.Prompt		   = 'Add current file (SCX/VCX/PRG) to active project'

		.Category = 'Code'
		.Author	  = 'JRN'
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

	Local laSelObj[1], lcFName, lcFullFileName, lcProjectName, lcPrompt, lnChoice, loEditorWin
	Local loProject, loTop, loWindows

	If _vfp.Projects.Count = 0
		Messagebox('No project open')
		Return
	Endif
	loProject	  = _vfp.ActiveProject
	lcProjectName = Justfname(m.loProject.Name)

	If Aselobj(laSelObj, 3) # 0 && SCX or VCX
		lcFullFileName = m.laSelObj[2]
	Else && PRG
		loEditorWin	= Execscript(_Screen.cThorDispatcher, 'Thor_Proc_EditorWin')
		loWindows	= m.loEditorWin.GetOpenWindows()
		loTop		= m.loWindows[1]
		If m.loTop.NWHandleType = 1 And File(m.loTop.WindowName)
			lcFullFileName = Fullpath(m.loTop.WindowName)
		Else
			Messagebox('File not found')
			Return
		Endif
	Endif && Aselobj(laSelObj, 3) # 0

	lcFName = Justfname(m.lcFullFileName)
	If Type([loProject.Files.Item(lcFullFileName)]) # 'O'
		lcPrompt = [Add "] + m.lcFName + [" to project "] + m.lcProjectName + ["?]
		lnChoice = Messagebox(m.lcPrompt, 3 + 32)
		If m.lnChoice = 6
			m.loProject.Files.Add(m.lcFullFileName)
			lcPrompt = ["] + m.lcFName + [" added.]
			Messagebox(m.lcPrompt, 64)
		Endif
	Else
		lcPrompt = ["] + m.lcFName + [" already in project "] + m.lcProjectName + ["]
		lcPrompt = lcPrompt + CR + CR + [Remove it?]
		lnChoice = Messagebox(m.lcPrompt, 3 + 32)
		If m.lnChoice = 6
			m.loProject.Files(m.lcFullFileName).Remove()
			lcPrompt = ["] + m.lcFName + [" Removed.]
			Messagebox(m.lcPrompt, 64)
		Endif
	Endif

Endproc


