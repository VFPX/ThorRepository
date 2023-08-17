Lparameters lxParam1

****************************************************************
****************************************************************
* Standard prefix for all tools for Thor, allowing this tool to
*   tell Thor about itself.

If Pcount() = 1								;
		And 'O' = Vartype (m.lxParam1)		;
		And 'thorinfo' = Lower (m.lxParam1.Class)

	With m.lxParam1

		* Required
		.Prompt		 = 'BeautifyX Current Procedure'
		.AppID 		 = 'ThorRepository'
		
		Text To .Description Noshow Textmerge
Runs BeautifyX on the current procedure.

Moves the first line of the procedure to the top of the edit window.    
		Endtext

		* Optional

		* For public tools, such as PEM Editor, etc.
		.Source			 = 'Code'
	Endwith

	Return m.lxParam1
Endif

****************************************************************
****************************************************************
* Normal processing for this tool begins here.    

Do ToolCode With m.lxParam1
Return


Procedure ToolCode(lxParam1)
	Execscript(_Screen.cThorDispatcher, 'Thor_Proc_HighlightControlStructure', .T.) && second parameter highlights the entire procedure
	Execscript(_Screen.cThorDispatcher, 'Thor_Tool_PEME_BeautifyX')
	Execscript(_Screen.cThorDispatcher, 'Thor_Tool_Repository_MoveLineToTop')
Endproc
