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
		.Prompt		 = 'Highlight Current Statement'
		.AppID 		 = 'ThorRepository'
		Text To .Description Noshow
Highlights the current (possibly multiple line) statement.

The cursor may be anywhere in the statement.
		Endtext
		* For public tools, such as PEM Editor, etc.
		.Source			 = 'Thor Repository'
		.Category		 = 'Code|Highlighting text'
		.Author			 = 'Jim Nelson'
		.CanRunAtStartUp = .F.
	Endwith

	Return m.lxParam1
Endif


Do ToolCode

Return


****************************************************************
****************************************************************
* Normal processing for this tool begins here.

#Define CR               	Chr(13)
#Define LF               	Chr(10)
#Define CRLF             	Chr(13)+Chr(10)
#Define Tab				    Chr(9)

Procedure ToolCode

	Local lcClipText, loHighlightedText

	loHighlightedText = Execscript(_Screen.cThorDispatcher, 'class= HighlightedText from Thor_Proc_HighlightedText.PRG', 'Statement', .T.)
	If Not Empty(m.loHighlightedText.cError)
		Messagebox(m.loHighlightedText.cError, 16, 'Error', 0)
		Return
	Endif

	lcClipText = m.loHighlightedText.cHighLightedText
Endproc


