Lparameters lxParam1
****************************************************************
****************************************************************
* Standard prefix for all tools for Thor, allowing this tool to
*   tell Thor about itself.
If Pcount() = 1								;
		And 'O' = Vartype(lxParam1)			;
		And 'thorinfo' = Lower(lxParam1.Class)
	With lxParam1
		.Prompt      = [Move line to top of window]
		Text To .Description Noshow
Moves the current line to the top of the editor window.
		Endtext
		.Category = 'Code|Miscellaneous'
		.Author	  = 'Jim Nelson'
		.Sort = 20
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
	Execscript(_Screen.cThorDispatcher, 'THOR_PROC_SELECTTEXT')
Endproc
