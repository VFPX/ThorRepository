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
		.Prompt		 = 'Highlight parentheses'
		Text to .Description NoShow
Highlights text between matching parentheses (including the parentheses).

Repeated usage highlights the next outer set of parentheses.
		EndText
		* For public tools, such as PEM Editor, etc.
		.Source	  = 'Thor Repository'
		.Category = 'Code|Highlighting text'
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
	Local lcChar, lcClipText, lcMatchChar, lcOldClipText, lnBegin, lnCursorPosition, lnEnd, lnLastByte
	Local lnParens, lnStartPosition, loEditorWin

	loEditorWin = Execscript (_Screen.cThorDispatcher, 'class= editorwin from pemeditor')
	* locate the active editor window; exit if none active
	If loEditorWin.GetEnvironment(25) <= 0
		Return
	Endif

	lnStartPosition	= loEditorWin.GetSelStart()
	lnParens		= 0
	For lnBegin = lnStartPosition - 1 To 0 Step - 1
		lcChar = loEditorWin.GetCharacter (lnBegin)
		Do Case
			Case lcChar = '('
				lnParens = lnParens + 1
				If lnParens = 1
					Exit
				Endif
			Case lcChar = ')'
				lnParens = lnParens - 1
			Case lcChar $ ['"]
				For lnBegin = lnBegin - 1 To 0 Step - 1
					lcMatchChar = loEditorWin.GetCharacter (lnBegin)
					If lcMatchChar = lcChar
						Exit
					Endif
				Endfor
			Case lcChar $ ']'
				For lnBegin = lnBegin - 1 To 0 Step - 1
					lcMatchChar = loEditorWin.GetCharacter (lnBegin)
					If lcMatchChar = '['
						Exit
					Endif
				Endfor
		Endcase
	Endfor && lnBegin = lnStartPosition - 1 To 0

	lnLastByte = loEditorWin.GetFileSize()
	lnParens   = 0
	For lnEnd = lnStartPosition To lnLastByte
		lcChar = loEditorWin.GetCharacter (lnEnd)
		Do Case
			Case lcChar = '('
				lnParens = lnParens + 1
			Case lcChar = ')'
				lnParens = lnParens - 1
				If lnParens = -1
					Exit
				Endif
			Case lcChar $ ['"]
				For lnEnd = lnEnd + 1 To lnLastByte
					lcMatchChar = loEditorWin.GetCharacter (lnEnd)
					If lcMatchChar = lcChar
						Exit
					Endif
				Endfor
			Case lcChar $ '['
				For lnEnd = lnEnd + 1 To lnLastByte
					lcMatchChar = loEditorWin.GetCharacter (lnEnd)
					If lcMatchChar = ']'
						Exit
					Endif
				Endfor
		Endcase
	Endfor && lnEnd = lnStartPosition + 1 To lnLastByte

	loEditorWin.Select (lnBegin, lnEnd + 1)

	Return
Endproc


