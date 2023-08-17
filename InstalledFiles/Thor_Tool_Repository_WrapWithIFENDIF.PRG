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
		.Prompt		 = 'Wrap text with IF / ELSE / ENDIF'
		.AppID 		 = 'ThorRepository'
		Text to .Description NoShow
Wraps highlighted statement(s) with IF / ELSE / ENDIF.

If nothing is highlighted, wraps the current statement.

The cursor is placed after the IF.

		EndText
		* For public tools, such as PEM Editor, etc.
		.Source		 = 'Thor Repository'
		.Category	 = 'Code|Highlighted text|Wrap text'
		.Author		 = 'Jim Nelson'
		.Link		 = 'http://vfpx.codeplex.com/wikipage?title=Thor%20EditorWindow%20Object'
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

	Local laLines[1], lcExtraIndent, lcFirstLine, lcIndent, lcLine, lcNewClipText, lnI, lnLineCount

	lnLineCount	= Alines (laLines, lcClipText)
	lcFirstLine	= laLines(1)
	lcIndent	= Left (lcFirstLine, At (Getwordnum (lcFirstLine, 1), lcFirstLine) - 1)

	lcNewClipText	 = lcIndent + FixCommandCase('If ')
	lnCursorPosition = loEditorWin.GetSelStart() + Len (lcNewClipText)
	lcExtraIndent	 = GetNormalIndentation()
	For lnI = 1 To lnLineCount
		lcLine = laLines (lnI)
		Do Case
			Case Empty (lcLine)
				lcNewClipText = lcNewClipText + ccCR
			Case lcLine = lcIndent
				lcNewClipText = lcNewClipText + ccCR + lcIndent + lcExtraIndent + Substr (lcLine, 1 + Len (lcIndent))
			Otherwise
				lcNewClipText = lcNewClipText + ccCR + lcLine
		Endcase
	Endfor && lnI = 1 To lnLineCount

	lcNewClipText = lcNewClipText + ccCR + lcIndent + FixCommandCase('Else') + ccCR
	lcNewClipText = lcNewClipText + ccCR
	lcNewClipText = lcNewClipText + lcIndent + FixCommandCase('EndIf') + ccCR

	lcClipText    = lcNewClipText

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
