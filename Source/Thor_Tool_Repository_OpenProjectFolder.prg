Lparameters lxParam1

****************************************************************
****************************************************************
* Standard prefix for all tools for Thor, allowing this tool to
*   tell Thor about itself.

If Pcount() = 1								;
		And 'O' = Vartype (lxParam1)		;
		And 'thorinfo' = Lower (lxParam1.Class)

	With lxParam1

		* Required
		.Prompt		 = 'Open Directory in Explorer'
		Text To .Description Noshow
Opens Windows Explorer for a selected folder. A popup menu presents choices between the folder for the active project (if any), the current directory, and the 9 most recent MRU directories.
		Endtext
		* Optional
		.StatusBarText = 'Open Directory in Explorer'

		* For public tools, such as PEM Editor, etc.
		.Source			 = 'Thor Repository'
		.Author			 = 'Matt Slay'
		.Category		 = 'Settings & Misc.'
		.CanRunAtStartUp = .F.
	Endwith

	Return lxParam1
Endif

Do ToolCode

Return


****************************************************************
****************************************************************
* Normal processing for this tool begins here.                  
Procedure ToolCode

	* ContextMenu home page = http://vfpx.codeplex.com/wikipage?title=Thor%20Framework%20ContextMenu
	Local loContextMenu As ContextMenu Of 'C:\VISUAL FOXPRO\PROGRAMS\MyThor\Thor\Source\Thor_Menu.vcx'
	Local loTools As Pemeditor_tools Of 'c:\visual foxpro\programs\MyThor\thor\tools\apps\pem editor\source\peme_tools.vcx'
	Local lcName, lcPath, lcPathPrompt, lcProjectPath, lnI, loMRUs

	loContextMenu = Execscript(_Screen.cThorDispatcher, 'Class= ContextMenu')

	* tools home page = http://vfpx.codeplex.com/wikipage?title=thor%20tools%20object
	loTools = Execscript(_Screen.cThorDispatcher, 'Class= tools from pemeditor')

	* --------------------------------------------------------------------------------
	For lnI = 1 To _vfp.Projects.Count
		lcName		 = loTools.DiskFileName(_vfp.Projects[lnI].Name)
		lcPath		 = Justpath (lcName)
		lcPathPrompt = AbbreviatePath(lcPath) + ' (' + Justfname(lcName) + ')'
		If lnI = 1
			lcPathPrompt = '\<Active Project: ' + lcPathPrompt
		Endif
		loContextMenu.AddMenuItem(lcPathPrompt, , , , , lcPath)
	Endfor

	* --------------------------------------------------------------------------------
	lcPath		 = Justpath(loTools.DiskFileName(Sys(5) + Curdir()))
	lcPathPrompt = lcPath
	loContextMenu.AddMenuItem('\<Current Directory: ' + lcPathPrompt, , , , , lcPath)
	loContextMenu.AddMenuItem()

	* --------------------------------------------------------------------------------
	loMRUs = loTools.GetMRUList('MRUT')
	
	For lnI = 1 To Min(9, loMRUs.Count)
		lcPath       = loMRUs.Item[lnI]
		If '\' = Right(lcPath, 1)
			lcPath		 = loTools.DiskFileName(Left(lcPath, Len(lcPath) - 1))
		Else
			lcPath		 = loTools.DiskFileName(lcPath)
		Endif

		Do Case
			Case ':' $ lcPath

			Case lcPath = '\'
				lcPath = Sys(5) + lcPath
			Otherwise
				lcPath = Sys(5) + '\' + lcPath
		Endcase

		lcPathPrompt = AbbreviatePath(lcPath)
		loContextMenu.AddMenuItem('\<' + Transform(lnI) + ' ' + lcPathPrompt, , , , , lcPath)
	Endfor

	* --------------------------------------------------------------------------------
	If loContextMenu.Activate()
		lcPath = loContextMenu.Parameters
		Execscript(_Screen.cThorDispatcher, 'Thor_Proc_OpenFolder', lcPath)
	Endif

Endproc


Procedure AbbreviatePath(lcPath)
	Local lcRelative

	lcRelative = Sys(2014, lcPath)
	If Len(lcPath) <= Len(lcRelative)		;
			Or ':' $ lcRelative				;
			Or '..\..\..\' $ lcRelative
		lcRelative = lcPath
	Endif

	Return lcRelative

Endproc
