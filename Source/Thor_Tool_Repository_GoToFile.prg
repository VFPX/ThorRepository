Lparameters lxParam1

****************************************************************
****************************************************************
* Standard prefix for all tools for Thor, allowing this tool to
*   tell Thor about itself.

If Pcount() = 1						  ;
		And 'O' = Vartype (lxParam1)  ;
		And 'thorinfo' = Lower (lxParam1.Class)

	With lxParam1

		* Required
		.Prompt	 = 'Go To File' && used when tool appears in a menu
		.Summary = 'Dialog to quickly select file to open.'

		* Optional
		.Description   = 'Displays a dialog with a filter box to quickly select a file to open from the Active Project.' && a more complete description; may be lengthy, including CRs, etc
		.StatusBarText = ''

		* These are used to group and sort tools when they are displayed in menus or the Thor form
		.Source	  = 'Thor Repository'
		.Category = 'Go To'

		* For public tools, such as PEM Editor, etc.
		.Version = '2011-06-20'
		.Author	 = 'Matt Slay'
		.CanRunAtStartUp = .F.

	Endwith

	Return lxParam1
Endif

Do ToolCode

Return

****************************************************************
****************************************************************

Procedure ToolCode (lcThisFolder)

	Local lcFormFileName
	lcFormFileName = Execscript (_Screen.cThorDispatcher, 'Full Path=Thor_Tool_Repository_GoToFile.SCX')
	Do Form (lcFormFileName)

Endproc