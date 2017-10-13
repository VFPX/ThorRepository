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
		.Prompt		 = 'Wrap text with Try / Catch'
		Text to .Description NoShow
Wraps highlighted lines of text with Try / Catch / EndTry

The cursor is placed on the line after Catch.
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
	Local lcClipText, lcOldClipText, lnCursorPosition, loEditorWin
	loEditorWin = Execscript (_Screen.cThorDispatcher, 'class= editorwin from pemeditor')
	* locate the active editor window; exit if none active
	If loEditorWin.GetEnvironment(25) <= 0
		Return
	Endif

	lcOldClipText = _Cliptext
	* copy highlighted text into clipboard
	loEditorWin.Copy()
	lcClipText = _Cliptext
	If Empty (lcClipText)
		Return
	Endif

	lnCursorPosition = -1
	ModifySelectedText (loEditorWin, @lcClipText, @lnCursorPosition)

	****************************************************************
	* This final block of code pastes in the modification (in <lcNewCliptext>)
	loEditorWin.Paste (lcClipText)

	If lnCursorPosition >= 0
		loEditorWin.SetInsertionPoint (lnCursorPosition)
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

	lcNewClipText	 = lcIndent + 'Try '
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

	lcNewClipText = lcNewClipText + ccCR + lcIndent + 'Catch to loException' 
	lcNewClipText = lcNewClipText + ccCR + lcIndent + lcExtraIndent	
	lnCursorPosition = loEditorWin.GetSelStart() + Len (lcNewClipText)
	lcNewClipText = lcNewClipText + ccCR
	lcNewClipText = lcNewClipText + lcIndent + 'EndTry' + ccCR

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

