Lparameters lxParam1

****************************************************************
****************************************************************
* Standard prefix for all tools for Thor, allowing this tool to
*   tell Thor about itself.

Local laHandles[1], laLines[1], laObjectInfo[1], lcClipText, lcFirstLine, lcIndent, lcNewCliptext
Local lcOldClipText, lcSourceFileName, lcThisFolder, lcWindowName, lcWonTop, llHasFocus
Local lnCursorPosition, lnI, lnLineCount, lnMatchIndex, lnWindowCount, loEditorWin, loThisForm
Local loWindow, loWindows
If Pcount() = 1						  ;
		And 'O' = Vartype (lxParam1)  ;
		And 'thorinfo' = Lower (lxParam1.Class)

	With lxParam1

		* Required
		.Prompt		 = 'Insert blank lines around control structures'
		Text to .Description NoShow
Insures that this a blank line before and after each control structure (IF / ENDIF, DO CASE / ENDCASE), etc.
		EndText

		* For public tools, such as PEM Editor, etc.
		.Source	  = 'Thor Repository'
		.Category = 'Code|Inserting text'
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

	Local lcClipText, lcNewCliptext, lcOldClipText, lnSelEnd, lnSelStart, loEditorWin

	* get the object which manages the editor window
	* see	http://vfpx.codeplex.com/wikipage?title=Thor%20EditorWindow%20Object
	loEditorWin = Execscript (_Screen.cThorDispatcher, 'class= editorwin from pemeditor')
	* locate the active editor window; exit if none active
	If loEditorWin.GetEnvironment(25) <= 0
		Return
	Endif

	lcOldClipText = _Cliptext
	lnSelStart	  = loEditorWin.GetSelStart()
	lnSelEnd	  = loEditorWin.GetSelEnd()
	If lnSelStart = lnSelEnd
		loEditorWin.Select(0, 1000000)
	Endif

	* copy highlighted text into clipboard
	loEditorWin.Copy()
	lcClipText = _Cliptext

	lcNewCliptext = ModifyTextBlock (lcClipText)

	****************************************************************
	* This final block of code pastes in the modification (in <lcNewCliptext>)
	loEditorWin.Paste (lcNewCliptext)
	loEditorWin.Select (lnSelStart, lnSelEnd)
	_Cliptext = lcOldClipText

	Return
Endproc


Procedure ModifyTextBlock (tcClipText)

	#Define ccTab  	Chr(9)
	#Define ccCR	Chr(13)

	#Define ccCODE 			'C'
	#Define ccBEGINBLOCK 	'B'
	#Define ccCOMMENT 		'*'
	#Define ccENDBLOCK 		'E'
	#Define ccBLANK         ' '

	Local laLines[1], lcLastLineType, lcLine, lcNewCliptext, lnI, lnLineCount
	lnLineCount	   = Alines (laLines, tcClipText)
	lcLastLineType = '?'
	lcNewCliptext  = ''
	
	For lnI = 1 To lnLineCount
		lcLine = Alltrim(laLines[lnI], 1, ' ', ccTab)
		Do Case
			Case Empty (lcLine)
				lcLastLineType = ccBLANK
			Case lcLine = '*' Or lcLine = '&' + '&'
				If lcLastLineType = ccENDBLOCK
					lcNewCliptext = lcNewCliptext + ccCR
				Endif
				lcLastLineType = ccCOMMENT
			Case Inlist (Upper (Getwordnum (lcLine, 1) + ' '), 'IF ', 'CASE ', 'OTHERWISE ', 'FOR ', 'TRY ', 'WITH ') ;
					Or (Upper (Getwordnum (lcLine, 1)) == 'DO' And Inlist (Upper (Getwordnum (lcLine, 2)) + ' ', 'CASE ', 'WHILE '))
				If lcLastLineType # ccBLANK And lcLastLineType # ccCOMMENT 
					lcNewCliptext = lcNewCliptext + ccCR
				Endif
				lcLastLineType = ccBEGINBLOCK
			Case Inlist (Upper (Getwordnum (lcLine, 1) + ' '), 'ENDIF ', 'END ', 'ENDFOR', 'ENDCASE', 'NEXT', 'ENDTRY', 'ENDWITH')
				If lcLastLineType = ccENDBLOCK
					lcNewCliptext = lcNewCliptext + ccCR
				Endif
				lcLastLineType = ccENDBLOCK
			Otherwise
				If lcLastLineType = ccENDBLOCK
					lcNewCliptext = lcNewCliptext + ccCR
				Endif
				lcLastLineType = ccCODE
		Endcase
		lcNewCliptext = lcNewCliptext + laLines[lnI] + ccCR
	Endfor && lnI = 1 To lnLineCount
	Return lcNewCliptext
Endproc
