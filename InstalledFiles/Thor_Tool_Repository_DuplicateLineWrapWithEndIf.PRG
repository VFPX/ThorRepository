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
		.AppID 		 = 'ThorRepository'
		Text To .Description Noshow
Duplicates the highlighted statement(s) and wraps with IF / ELSE / ENDIF.

If nothing is highlighted, wraps the current statement.

The cursor is placed after the IF.
		Endtext
		* For public tools, such as PEM Editor, etc.
		.Source	  = 'Thor Repository'
		.Category = 'Code|Highlighted text|Wrap text'
		.Author	  = 'Jim Nelson'
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
	Local lcTextOfLine, lnCurrentLineStart, lnCursorPosition, lnFollowingLineStart, lnSelEnd, lnSelStart
	Local loEditorWin, loHighlightedText

	loHighlightedText = Execscript(_Screen.cThorDispatcher, 'class= HighlightedText from Thor_Proc_HighlightedText.PRG', 'Statement', .T.)
	If Not Empty(m.loHighlightedText.cError)
		Messagebox(m.loHighlightedText.cError, 16, 'Error', 0)
		Return
	Endif

	loEditorWin = Execscript(_Screen.cThorDispatcher, 'class= editorwin from pemeditor')
	* locate the active editor window; exit if none active
	If m.loEditorWin.GetEnvironment(25) <= 0
		Return
	Endif

	* current cursor position
	lnSelStart = m.loEditorWin.GetSelStart()
	lnSelEnd   = m.loEditorWin.GetSelEnd()
	* find the start of the current line
	lnCurrentLineStart = m.loEditorWin.SkipLine(m.lnSelStart, 0)
	* and of the following line
	lnFollowingLineStart = m.loEditorWin.SkipLine(m.lnSelEnd, 0)
	If m.lnFollowingLineStart < m.lnSelEnd  Or m.lnCurrentLineStart = m.lnFollowingLineStart
		lnFollowingLineStart = m.loEditorWin.SkipLine(m.lnSelEnd, 1)
	Endif
	* Get the desired text
	lcTextOfLine = m.loEditorWin.GetString(m.lnCurrentLineStart, m.lnFollowingLineStart - 1)
	* Modify the text to be inserted (wrapping, indenting)
	lnCursorPosition = -1
	ModifySelectedText(m.loEditorWin, @m.lcTextOfLine, @m.lnCursorPosition, m.lnCurrentLineStart)
	* Select the current line
	m.loEditorWin.Select(m.lnCurrentLineStart, m.lnFollowingLineStart)
	* Paste in the line
	m.loEditorWin.Paste(m.lcTextOfLine)
	* Move the cursor
	If m.lnCursorPosition >= 0
		m.loEditorWin.SetInsertionPoint(m.lnCursorPosition)
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


