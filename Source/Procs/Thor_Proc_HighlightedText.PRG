* This class is used to access and/or modify the currently highlighted text in a code window
* Property <cHighlightedText> contains the highlighted text.
* It can be replaced by using method <PasteText>
* The position of the cursor can be moved from the beginning of the highlighted text
* by using method <ResetInsertionPoint>

#Define ccTab  		Chr(9)
#Define ccCR		Chr(13)
#Define ccLF		Chr(10)

Define Class HighlightedText As Session OlePublic

	cOriginalClipboard = ''
	cHighlightedText   = ''
	cError			   = ''
	cCommentedText	   = ''
	nCursorPosition	   = -1
	nSelStart		   = 0
	oEditorWin		   = .Null.
	nWordStart		   = 0
	nWordEnd		   = 0

	Procedure Init
		Lparameters lcIfNothingHighlighted, llCommandWindow
		This.GetHighlightedText (lcIfNothingHighlighted, llCommandWindow)
	Endproc


	Procedure Error
		Lparameters nError, cMethod, nLine
	Endproc


	Procedure GetHighlightedText
		Lparameters lcIfNothingHighlighted, llCommandWindow

		Local lcChar, lcHighlightedText, lnCurrentLineStart, lnFollowingLineStart, lnPosition, lnSelEnd
		Local lnSelStart
		This.cError = ''

		* get the object which manages the editor window
		* see	http://vfpx.codeplex.com/wikipage?title=Thor%20EditorWindow%20Object
		* editorwin home page = http://vfpx.codeplex.com/wikipage?title=thor%20editorwindow%20object
		This.oEditorWin = Execscript (_Screen.cThorDispatcher, 'class= editorwin from pemeditor')

		If This.oEditorWin.GetEnvironment(25) <= Iif (llCommandWindow, -1, 0)
			This.cError = 'No Active Window Exists.'
		Else
			This.cOriginalClipboard = _Cliptext
			* copy highlighted text into clipboard
			This.oEditorWin.Copy()
			This.nSelStart		  = This.oEditorWin.GetSelStart()
			This.cHighlightedText = _Cliptext
			_Cliptext			  = This.cOriginalClipboard

			Do Case
				Case lcIfNothingHighlighted = 'Whole Line'
					lnSelStart = This.nSelStart
					* find the start of the current line
					lnCurrentLineStart = This.oEditorWin.SkipLine (lnSelStart, 0)
					* and of the following line
					lnSelEnd = This.oEditorWin.GetSelEnd()
					If Right (This.cHighlightedText, 1) $ ccCR + ccLF
						lnFollowingLineStart = lnSelEnd
					Else
						lnFollowingLineStart = This.oEditorWin.SkipLine (lnSelEnd, 1)
					Endif
					* Mark the desired text
					This.oEditorWin.Select (lnCurrentLineStart, lnFollowingLineStart)
					This.nSelStart = lnCurrentLineStart
					This.oEditorWin.Copy()
					This.cHighlightedText = _Cliptext
					_Cliptext			  = This.cOriginalClipboard

				Case Empty (This.cHighlightedText)
					Do Case
						Case Empty (lcIfNothingHighlighted)
							This.cError = 'No Text is Highlighted'
						Case lcIfNothingHighlighted = 'Word'
							lnSelStart		= This.nSelStart
							This.nWordStart	= m.lnSelStart
							This.nWordEnd	= m.lnSelStart
							
							lnPosition		  = lnSelStart
							lcHighlightedText = ''
							Do While .T.
								lcChar = This.oEditorWin.GetCharacter (lnPosition)
								If This.IsNameChar (lcChar)
									lcHighlightedText = lcHighlightedText + lcChar
									lnPosition		  = lnPosition + 1
									This.nWordEnd	  = lnPosition
								Else
									Exit
								Endif
							Enddo

							*** JRN 2010-04-02 : add in preceding characters
							For lnPosition = lnSelStart - 1 To 0 Step - 1
								lcChar = This.oEditorWin.GetCharacter (lnPosition)
								If This.IsNameChar (lcChar)
									lcHighlightedText = lcChar + lcHighlightedText
									This.nWordStart	  = lnPosition
								Else
									Exit
								Endif
							Endfor
							This.cHighlightedText = lcHighlightedText

						Case lcIfNothingHighlighted = 'Line'
							lnSelStart = This.nSelStart
							* find the start of the current line
							lnCurrentLineStart = This.oEditorWin.SkipLine (lnSelStart, 0)
							* and of the following line
							lnFollowingLineStart = This.oEditorWin.SkipLine (lnSelStart, 1)
							* Mark the desired text
							This.oEditorWin.Select (lnCurrentLineStart, lnFollowingLineStart)
							This.nSelStart = lnCurrentLineStart
							This.oEditorWin.Copy()
							This.cHighlightedText = _Cliptext
							_Cliptext			  = This.cOriginalClipboard

						Case lcIfNothingHighlighted = 'All'
							This.oEditorWin.Select (0, 1000000)
							This.oEditorWin.Copy()
							This.cHighlightedText = _Cliptext
							_Cliptext			  = This.cOriginalClipboard

					Endcase
			Endcase
		Endif
		Return Empty (This.cError)
	Endproc


	Procedure PasteText
		Lparameters tcPasteText
		This.oEditorWin.Paste (tcPasteText)
		Return
	Endproc


	Procedure SelectText(lnStartPosition, lnEndPosition)
		This.oEditorWin.Select(lnStartPosition, lnEndPosition)
		Return
	Endproc


	Procedure ResetInsertionPoint
		Lparameters tnOffset
		This.oEditorWin.SetInsertionPoint (tnOffset + This.nSelStart)
	Endproc

	Procedure IsNameChar
		Lparameters lcChar

		Return Isalpha (lcChar) Or Isdigit (lcChar) Or lcChar = '_'
	Endproc

Enddefine


