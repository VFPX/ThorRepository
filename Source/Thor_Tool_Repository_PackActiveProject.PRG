Lparameters lxParam1

****************************************************************
****************************************************************
* Standard prefix for all tools for Thor, allowing this tool to
*   tell Thor about itself.

If Pcount() = 1								;
		And 'O' = Vartype(m.lxParam1)		;
		And 'thorinfo' == Lower(m.lxParam1.Class)

	With m.lxParam1

		* Required
		.Prompt		   = 'Pack VCXs, SCXs, etc. from a project or folder'

		* Optional
		Text To .Description Noshow && a description for the tool
Prompts for a project or folder to search, and packs all VCXs, SCXs, etc.
		Endtext
		.StatusBarText	 = ''
		.CanRunAtStartUp = .F.

		* These are used to group and sort tools when they are displayed in menus or the Thor form
		.Category = 'Applications' && creates categorization of tools; defaults to .Source if empty
		.Link     = 'https://vfpx.codeplex.com/wikipage?title=Thor%20TWEeT%2024'

		* For public tools, such as PEM Editor, etc.
		.Author	   = 'Jim Nelson'

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

	Execscript(_Screen.cThorDispatcher, 'Thor_Proc_PackProject.prg')

Endproc
