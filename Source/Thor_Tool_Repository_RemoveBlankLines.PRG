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
		.Prompt		 = 'Remove blank lines'
		.Description = 'Removes all blank lines in code window.'

		* For public tools, such as PEM Editor, etc.
		.Source		 = 'Thor Repository'
		.Category	 = 'Code|Highlighted Text'
		.Author		 = 'Andrew Nickless'
		.Link		 = 'http://vfpx.codeplex.com/wikipage?title=Thor%20EditorWindow%20Object'
		.CanRunAtStartUp = .F.
	Endwith

	Return lxParam1
Endif

If Pcount() = 0
	Do ToolCode
Else
	Do ToolCode With lxParam1
Endif

Return


****************************************************************
****************************************************************
* Normal processing for this tool begins here.                  
Procedure ToolCode

	Local lcClipText, lcOldClipText, lnCursorPosition, loEditorWin, loHighlightedText

	loHighlightedText = Execscript (_Screen.cThorDispatcher, 'class= HighlightedText from Thor_Proc_HighlightedText.PRG', 'All')
	If Not Empty (loHighlightedText.cError)
		Messagebox (loHighlightedText.cError, 16, 'Error', 0)
		Return
	Endif

	lcClipText = RemoveBlankLines(loHighlightedText.cHighLightedText)

	loHighlightedText.PasteText (lcClipText)
	loHighlightedText.ResetInsertionPoint (lnCursorPosition)

	Return
Endproc


****************************************************************
* Remove all blank lines
Procedure RemoveBlankLines (lcClipText)
	* Parameters:
	*             lcCliptext:                            Currently selected (or highlighted) text

	#Define ccCR                     Chr(13)

	Local laLines[1], lcLine, lcNewCliptext, lnI, lnLineCount

	lcNewCliptext = ''
	lnLineCount	  = Alines (laLines, lcClipText)

	For lnI = 1 To lnLineCount
		lcLine = laLines (lnI)
		If Not Empty (lcLine)
			If lnI # lnLineCount
				lcNewCliptext = lcNewCliptext + lcLine + ccCR
			Else
				lcNewCliptext = lcNewCliptext + lcLine
			Endif
		Endif
	Endfor && lnI = 1 To lnLineCount
	lcClipText    = lcNewCliptext

	Return lcClipText

Endproc
