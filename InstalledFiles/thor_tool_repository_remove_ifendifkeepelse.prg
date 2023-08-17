Lparameters lxParam1

****************************************************************
****************************************************************
* Standard prefix for all tools for Thor, allowing this tool to
*   tell Thor about itself.

Local laHandles[1], laLines[1], laObjectInfo[1], lcFirstLine, lcIndent, lcNewCliptext, lcOldClipText
Local lcSourceFileName, lcThisFolder, lcWindowName, lcWonTop, llHasFocus, lnI, lnLineCount
Local lnMatchIndex, lnWindowCount, loThisForm, loWindow, loWindows
If Pcount() = 1                       ;
		And 'O' = Vartype (lxParam1)  ;
		And 'thorinfo' = Lower (lxParam1.Class)

	With lxParam1

		* Required
		.Prompt      = 'Remove IF/ENDIF (keeping Else Code)'
		.AppID       = 'ThorRepository'
		Text to .Description NoShow
Collapses an IF/ENDIF control structure, keeping the code between ELSE / ENDIF.
		EndText
		* For public tools, such as PEM Editor, etc.
		.Source      = 'Thor Repository'
		.Category    = 'Code|Highlighted text'
		.Author      = 'Jim Nelson'
		.Sort        = 10
		.Link        = 'http://vfpx.codeplex.com/wikipage?title=Thor%20EditorWindow%20Object'
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

	If Execscript(_Screen.cThorDispatcher, 'thor_proc_highlightifendif')

		Execscript(_Screen.cThorDispatcher, 'Thor_Proc_Remove_IFENDIF', .T.)

	Endif

Endproc

