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
		.AppID 		   = 'ThorRepository'

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

	Local laSelObj[1], lcFName, lcFileName, lcFullFileName, lcProjectName, lcPrompt, lnChoice
	Local loEditorWin, loProject

	If _vfp.Projects.Count = 0
		Messagebox('No project open')
		Return
	Endif
	loProject	  = _vfp.ActiveProject
	lcProjectName = Justfname(m.loProject.Name)

	loEditorWin	= Execscript (_Screen.cThorDispatcher, 'class= editorwin from pemeditor')
	Do Case
		Case m.loEditorWin.GetEnvironment(25) = 10 && SCX or VCX
			lcFullFileName = m.laSelObj[2]
		Case m.loEditorWin.GetEnvironment(25) = 1 && PRG
			lcFileName	= m.loEditorWin.GetTitle()
			If File(m.lcFileName)
				lcFullFileName = Fullpath(m.lcFileName)
			Else
				Messagebox('File "' + m.lcfilename + '" not found')
				Return
			Endif
		Otherwise
			Messagebox('Nothing to do')
			Return
	Endcase

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
		lcPrompt = m.lcPrompt + CR + CR + [Remove it?]
		lnChoice = Messagebox(m.lcPrompt, 3 + 32)
		If m.lnChoice = 6
			m.loProject.Files(m.lcFullFileName).Remove()
			lcPrompt = ["] + m.lcFName + [" Removed.]
			Messagebox(m.lcPrompt, 64)
		Endif
	Endif

Endproc


