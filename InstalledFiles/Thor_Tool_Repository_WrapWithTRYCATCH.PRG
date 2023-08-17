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
		.Prompt		 = 'Wrap text with Try / Catch'
		.AppID 		 = 'ThorRepository'
		Text To .Description Noshow
Wraps highlighted statement(s) with TRY / CATCH / ENDTRY.

If nothing is highlighted, wraps the current statement.

The cursor is placed on the line after Catch.
		Endtext
		* For public tools, such as PEM Editor, etc.
		.Source			 = 'Thor Repository'
		.Category		 = 'Code|Highlighted text|Wrap text'
		.Author			 = 'Jim Nelson'
		.Link			 = 'http://vfpx.codeplex.com/wikipage?title=Thor%20EditorWindow%20Object'
		.CanRunAtStartUp = .F.
	Endwith

	Return m.lxParam1
Endif

Do ToolCode

Return


****************************************************************
****************************************************************
* Normal processing for this tool begins here.
Procedure ToolCode

	* get the object which manages the editor window
	* see	http://vfpx.codeplex.com/wikipage?title=Thor%20EditorWindow%20Object
	Local lcClipText, lnCursorPosition, loEditorWin, loHighlightedText

	loEditorWin = Execscript (_Screen.cThorDispatcher, 'class= editorwin from pemeditor')

	loHighlightedText = Execscript(_Screen.cThorDispatcher, 'class= HighlightedText from Thor_Proc_HighlightedText.PRG', 'Statement', .T.)
	If Not Empty(m.loHighlightedText.cError)
		Messagebox(m.loHighlightedText.cError, 16, 'Error', 0)
		Return
	Endif
	lcClipText = m.loHighlightedText.cHighLightedText

	lnCursorPosition = -1
	ModifySelectedText (m.loEditorWin, @m.lcClipText, @m.lnCursorPosition)

	****************************************************************
	* This final block of code pastes in the modification (in <lcNewCliptext>)
	m.loEditorWin.Paste (m.lcClipText)

	If m.lnCursorPosition >= 0
		m.loEditorWin.SetInsertionPoint (m.lnCursorPosition)
	Endif

	Return
Endproc


Procedure ModifySelectedText (loEditorWin, lcClipText, lnCursorPosition)
	* Parameters:
	*	lcCliptext:  		Currently selected (or highlighted) text
	* 	lnCursorPosition: 	Where to place the cursor when done (Passed in by reference)

	#Define ccTab  		Chr(9)
	#Define ccCR		Chr(13)

	Local laLines[1], lcExtraIndent, lcFirstLine, lcIndent, lcLine, lcNewCliptext, lnI, lnLineCount

	lnLineCount	= Alines (laLines, m.lcClipText)
	lcFirstLine	= m.laLines(1)
	lcIndent	= Left (m.lcFirstLine, At (Getwordnum (m.lcFirstLine, 1), m.lcFirstLine) - 1)

	lcNewCliptext = m.lcIndent + FixCommandCase('Try ')
	lcExtraIndent = GetNormalIndentation()
	For lnI = 1 To m.lnLineCount
		lcLine = m.laLines (m.lnI)
		Do Case
			Case Empty (m.lcLine)
				lcNewCliptext = m.lcNewCliptext + ccCR
			Case m.lcLine = m.lcIndent
				lcNewCliptext = m.lcNewCliptext + ccCR + m.lcIndent + m.lcExtraIndent + Substr (m.lcLine, 1 + Len (m.lcIndent))
			Otherwise
				lcNewCliptext = m.lcNewCliptext + ccCR + m.lcLine
		Endcase
	Endfor && lnI = 1 To lnLineCount

	lcNewCliptext	 = m.lcNewCliptext + ccCR + m.lcIndent + FixCommandCase('Catch to ') + 'loException'
	lcNewCliptext	 = m.lcNewCliptext + ccCR + m.lcIndent + m.lcExtraIndent
	lnCursorPosition = m.loEditorWin.GetSelStart() + Len (m.lcNewCliptext)
	lcNewCliptext	 = m.lcNewCliptext + ccCR
	lcNewCliptext	 = m.lcNewCliptext + m.lcIndent + FixCommandCase('EndTry') + ccCR

	lcClipText    = m.lcNewCliptext

	Return

Endproc


Procedure GetNormalIndentation
	If Execscript (_Screen.cThorDispatcher, 'Thor_Proc_BeautifyOption', 4) = 1
		Return ccTab
	Else
		Return Space (Execscript (_Screen.cThorDispatcher, 'Thor_Proc_BeautifyOption', 3))
	Endif
Endproc


Procedure FixCommandCase(lcCommand)
	Return Execscript(_Screen.cThorDispatcher, 'Thor_Proc_FixCommandCase', m.lcCommand)
Endproc
