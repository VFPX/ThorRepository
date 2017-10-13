Lparameters lxParam1

****************************************************************
****************************************************************
* Standard prefix for all tools for Thor, allowing this tool to
*   tell Thor about itself.

If Pcount() = 1								;
		And 'O' = Vartype(lxParam1)			;
		And 'thorinfo' = Lower(lxParam1.Class)

	With lxParam1

		* Required
		.Prompt		 = 'Duplicate line(s) and wrap with IF/ELSE/ENDIF'
		Text To .Description Noshow
Duplicates the current line(s) and wraps with IF / ELSE / ENDIF

The cursor is placed after the IF
		Endtext
		* For public tools, such as PEM Editor, etc.
		.Source	  = 'Thor Repository'
		.Category = 'Code|Highlighted text|Wrap text'
		.Author	  = 'Jim Nelson'
		.Link	  = 'http://vfpx.codeplex.com/wikipage?title=Thor%20EditorWindow%20Object'
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

	* get the object which manages the editor window
	* see	http://vfpx.codeplex.com/wikipage?title=Thor%20EditorWindow%20Object
	Local lcClipText, lcOldClipText, lnCursorPosition, loEditorWin
	loEditorWin = Execscript(_Screen.cThorDispatcher, 'class= editorwin from pemeditor')
	* locate the active editor window; exit if none active
	If loEditorWin.GetEnvironment(25) <= 0
		Return
	Endif

	* current cursor position
	lnSelStart = loEditorWin.GetSelStart()
	lnSelEnd   = loEditorWin.GetSelEnd()
	* find the start of the current line
	lnCurrentLineStart = loEditorWin.SkipLine(lnSelStart, 0)
	* and of the following line
	lnFollowingLineStart = loEditorWin.SkipLine(lnSelEnd, 0)
	If lnFollowingLineStart < lnSelEnd  or lnCurrentLineStart = lnFollowingLineStart
		lnFollowingLineStart = loEditorWin.SkipLine(lnSelEnd, 1)
	EndIf 
	* Get the desired text
	lcTextOfLine = loEditorWin.GetString(lnCurrentLineStart, lnFollowingLineStart - 1)
	* Modify the text to be inserted (wrapping, indenting)
	lnCursorPosition = -1
	ModifySelectedText(loEditorWin, @lcTextOfLine, @lnCursorPosition, lnCurrentLineStart)
	* Select the current line
	loEditorWin.Select(lnCurrentLineStart, lnFollowingLineStart)
	* Paste in the line
	loEditorWin.Paste(lcTextOfLine)
	* Move the cursor
	If lnCursorPosition >= 0
		loEditorWin.SetInsertionPoint(lnCursorPosition)
	Endif

	Return
Endproc


Procedure ModifySelectedText(loEditorWin, lcClipText, lnCursorPosition, lnCurrentLineStart)
	* Parameters:
	*	lcCliptext:  		Currently selected (or highlighted) text
	* 	lnCursorPosition: 	Where to place the cursor when done (Passed in by reference)

	#Define ccTab  		Chr(9)
	#Define ccCR		Chr(13)

	Local laLines[1], lcExtraIndent, lcFirstLine, lcIndent, lcLine, lcNewClipText, lcResult, lnI
	Local lnLineCount

	lnLineCount	= Alines(laLines, lcClipText)
	lcFirstLine	= laLines(1)
	lcIndent	= Left(lcFirstLine, At(Getwordnum(lcFirstLine, 1), lcFirstLine) - 1)

	lcResult		 = lcIndent + 'If '
	lnCursorPosition = lnCurrentLineStart + Len(lcResult)
	lcNewClipText	 = ''
	lcExtraIndent	 = GetNormalIndentation()
	For lnI = 1 To lnLineCount
		lcLine = laLines(lnI)
		Do Case
			Case Empty(lcLine)
				lcNewClipText = lcNewClipText + ccCR
			Case lcLine = lcIndent
				lcNewClipText = lcNewClipText + ccCR + lcIndent + lcExtraIndent + Substr(lcLine, 1 + Len(lcIndent))
			Otherwise
				lcNewClipText = lcNewClipText + ccCR + lcLine
		Endcase
	Endfor && lnI = 1 To lnLineCount

	lcResult = lcResult + lcNewClipText + ccCR + lcIndent + 'Else' 
	lcResult = lcResult + lcNewClipText + ccCR
	lcResult = lcResult + lcIndent + 'EndIf' + ccCR

	lcClipText    = lcResult

	Return

Endproc


Procedure GetNormalIndentation
	If Execscript(_Screen.cThorDispatcher, 'Thor_Proc_BeautifyOption', 4) = 1
		Return ccTab
	Else
		Return Space(Execscript(_Screen.cThorDispatcher, 'Thor_Proc_BeautifyOption', 3))
	Endif
Endproc


