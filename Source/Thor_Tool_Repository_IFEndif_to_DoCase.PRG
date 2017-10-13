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
		.Prompt      = 'Change IF/ENDIF in highlighted text to DO CASE'
		Text to .Description NoShow
Change the IF / ENDIF in the highlighted lines of text to a DO CASE.

The lines between IF /ELSE go within the first CASE statement, those between ELSE / ENDIF go after OtherWise.  The cursor is placed after the second CASE statement.
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

	#Define ccTab  	Chr(9)
	#Define ccCR	Chr(13)

	Local laLines[1], lcFirstLine, lcFirstWord, lcIndent, lcLine, lcNewCliptext, llElse, lnI, lnIFCount
	Local lnLineCount
	lnLineCount = Alines (laLines, lcClipText)
	lcFirstLine = laLines(1)
	lcIndent    = Left (lcFirstLine, At (Getwordnum (lcFirstLine, 1), lcFirstLine) - 1)

	lcNewCliptext = ''
	lnIFCount     = 0
	For lnI = 1 To lnLineCount
		lcLine      = laLines (lnI)
		lcFirstWord = Upper (Getwordnum (lcLine, 1))
		Do Case
			Case lnIFCount = 0
				If lcFirstWord == 'IF'
					lcNewCliptext = lcNewCliptext + lcIndent + 'Do Case' + ccCR  ;
						+ ccTab + Strtran (lcLine, 'IF', 'Case', 1, 1, 1) + ccCR
					lnIFCount = 1
					llElse    = .F.
				Else
					lcNewCliptext = lcNewCliptext + lcLine + ccCR
				Endif lcFirstWord == 'IF'

			Case lnIFCount = 1
				Do Case
					Case lcFirstWord == 'IF'
						lnIFCount     = lnIFCount + 1
						lcNewCliptext = lcNewCliptext + ccTab + lcLine + ccCR
					Case lcFirstWord == 'ELSE'
						llElse           = .T.
						lcNewCliptext    = lcNewCliptext + ccTab + lcIndent + 'Case '
						lnCursorPosition = loEditorWin.GetSelStart() + Len (lcNewCliptext)
						lcNewCliptext    = lcNewCliptext + ccCR + ccTab + lcIndent + 'Otherwise ' + ccCR
					Case lcFirstWord == 'ENDIF'
						If Not llElse
							lcNewCliptext    = lcNewCliptext + ccTab + lcIndent + 'Case '
							lnCursorPosition = loEditorWin.GetSelStart() + Len (lcNewCliptext)
							lcNewCliptext    = lcNewCliptext + ccCR + ccTab + lcIndent + 'Otherwise ' + ccCR
						Endif Not llElse
						lcNewCliptext = lcNewCliptext + lcIndent + 'Endcase' + ccCR
					Otherwise
						lcNewCliptext = lcNewCliptext + ccTab + lcLine + ccCR
				Endcase

			Otherwise
				Do Case
					Case lcFirstWord == 'IF'
						lnIFCount = lnIFCount + 1
					Case lcFirstWord == 'ENDIF'
						lnIFCount = lnIFCount - 1
				Endcase
				lcNewCliptext = lcNewCliptext + ccTab+ lcLine + ccCR

		Endcase

	Endfor

	lcClipText = lcNewCliptext

	Return

Endproc

