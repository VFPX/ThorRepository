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
	cHighLightedText   = ''
	cError			   = ''
	cCommentedText	   = ''
	nCursorPosition	   = -1
	nSelStart		   = 0
	oEditorWin		   = .Null.
	nWordStart		   = 0
	nWordEnd		   = 0

	Procedure Init
		Lparameters lcIfNothingHighlighted, llCommandWindowOK
		This.GetHighlightedText (m.lcIfNothingHighlighted, m.llCommandWindowOK)
	Endproc


	Procedure Error
		Lparameters nError, cMethod, nLine
	Endproc


	Procedure GetHighlightedText
		Lparameters lcIfNothingHighlighted, llCommandWindowOK
	
		Local lcChar, lcHighLightedText, lcNextText, lcPreviousText, lnBegin, lnCurrentLineStart, lnEnd
		Local lnEndPosition, lnFollowingLineStart, lnNextLineStart, lnPosition, lnPreviousLineStart
		Local lnSelEnd, lnSelStart, lnStartPosition
	
		This.cError = ''
	
		* get the object which manages the editor window
		* see	http://vfpx.codeplex.com/wikipage?title=Thor%20EditorWindow%20Object
		* editorwin home page = http://vfpx.codeplex.com/wikipage?title=thor%20editorwindow%20object
		This.oEditorWin = Execscript(_Screen.cThorDispatcher, 'Thor_Proc_EditorWin')
		
		If This.oEditorWin.GetEnvironment(25) <= Iif (m.llCommandWindowOK, -1, 0)
			This.cError = 'Not an edit window'
			Return
		Endif
	
		This.cOriginalClipboard = _Cliptext
		* copy highlighted text into clipboard
		This.oEditorWin.Copy()
		This.nSelStart		  = This.oEditorWin.GetSelStart()
		This.cHighLightedText = _Cliptext
		lcIfNothingHighlighted = Evl(lcIfNothingHighlighted, '?')
	
		Do Case
			Case m.lcIfNothingHighlighted = 'Whole Line'
				lnSelStart = This.nSelStart
				* find the start of the current line
				lnCurrentLineStart = This.oEditorWin.SkipLine (m.lnSelStart, 0)
				* and of the following line
				lnSelEnd = This.oEditorWin.GetSelEnd()
				If Right (This.cHighLightedText, 1) $ ccCR + ccLF
					lnFollowingLineStart = m.lnSelEnd
				Else
					lnFollowingLineStart = This.oEditorWin.SkipLine (m.lnSelEnd, 1)
				Endif
				* Mark the desired text
				This.oEditorWin.Select (m.lnCurrentLineStart, m.lnFollowingLineStart)
				This.nSelStart = m.lnCurrentLineStart
				This.oEditorWin.Copy()
				This.cHighLightedText = _Cliptext
	
			Case m.lcIfNothingHighlighted = 'Word' And Empty (This.cHighLightedText)
				lnSelStart		= This.nSelStart
				This.nWordStart	= m.lnSelStart
				This.nWordEnd	= m.lnSelStart
	
				lnPosition		  = m.lnSelStart
				lcHighLightedText = ''
				Do While .T.
					lcChar = This.oEditorWin.GetCharacter (m.lnPosition)
					If This.IsNameChar (m.lcChar)
						lcHighLightedText = m.lcHighLightedText + m.lcChar
						lnPosition		  = m.lnPosition + 1
						This.nWordEnd	  = m.lnPosition
					Else
						Exit
					Endif
				Enddo
	
				*** JRN 2010-04-02 : add in preceding characters
				For lnPosition = m.lnSelStart - 1 To 0 Step - 1
					lcChar = This.oEditorWin.GetCharacter (m.lnPosition)
					If This.IsNameChar (m.lcChar)
						lcHighLightedText = m.lcChar + m.lcHighLightedText
						This.nWordStart	  = m.lnPosition
					Else
						Exit
					Endif
				Endfor
				This.cHighLightedText = m.lcHighLightedText
	
			Case m.lcIfNothingHighlighted = 'Line' And Empty (This.cHighLightedText)
				lnSelStart = This.nSelStart
				* find the start of the current line
				lnCurrentLineStart = This.oEditorWin.SkipLine (m.lnSelStart, 0)
				* and of the following line
				lnFollowingLineStart = This.oEditorWin.SkipLine (m.lnSelStart, 1)
				* Mark the desired text
				This.oEditorWin.Select (m.lnCurrentLineStart, m.lnFollowingLineStart)
				This.nSelStart = m.lnCurrentLineStart
				This.oEditorWin.Copy()
				This.cHighLightedText = _Cliptext
	
			Case m.lcIfNothingHighlighted = 'All' And Empty (This.cHighLightedText)
				This.oEditorWin.Select (0, 1000000)
				This.oEditorWin.Copy()
				This.cHighLightedText = _Cliptext
	
			Case m.lcIfNothingHighlighted = 'Statement' And Empty (This.cHighLightedText)
				* ================================================================================ 
				lnStartPosition	   = This.oEditorWin.GetSelStart()
				lnCurrentLineStart = This.oEditorWin.GetLineStart(m.lnStartPosition, 0)
				*  Assert Date() > Date(2023, 1, 15) + 2 Message 'JRN - '
				* look for prior continuation lines
				Do While m.lnCurrentLineStart > 0
					lnPreviousLineStart	= This.oEditorWin.GetLineStart(m.lnCurrentLineStart, -1)
					lcPreviousText		= This.oEditorWin.GetString(m.lnPreviousLineStart, m.lnCurrentLineStart - 1)
					If This.IsContinuationLine(m.lcPreviousText)
						lnCurrentLineStart = m.lnPreviousLineStart
					Else
						Exit
					Endif
				Enddo
				lnBegin = m.lnCurrentLineStart
				Do While This.oEditorWin.GetCharacter(m.lnBegin) $ CRLF
					lnBegin = m.lnBegin + 1
				Enddo
	
				* ================================================================================ 
				lnEndPosition	   = This.oEditorWin.GetSelEnd()
				lnCurrentLineStart = This.oEditorWin.GetLineStart(m.lnEndPosition, 0)
				If lnEndPosition > lnCurrentLineStart 
					* and following continuation lines
					Do While m.lnCurrentLineStart < This.oEditorWin.GetFileSize()
						lnNextLineStart	   = This.oEditorWin.GetLineStart(m.lnCurrentLineStart, 1)
						lcNextText		   = This.oEditorWin.GetString(m.lnNextLineStart, m.lnCurrentLineStart - 1)
						lnCurrentLineStart = m.lnNextLineStart
						If Not This.IsContinuationLine(m.lcNextText)
							Exit
						Endif
					Enddo
				Endif
				lnEnd = m.lnCurrentLineStart && - 1
				Do While This.oEditorWin.GetCharacter(m.lnEnd) $ CRLF
					lnEnd = m.lnEnd - 1
				Enddo
	
				* ================================================================================ 
				This.oEditorWin.Select (m.lnBegin - 1, m.lnEnd + 1)
				This.oEditorWin.Copy()
				This.cHighLightedText = _Cliptext
	
			Case Not Empty (This.cHighLightedText)
	
			Case Empty (m.lcIfNothingHighlighted)
				This.cError = 'Nothing highlighted'
	
			Otherwise
				Error 'Parameter error'
	
		Endcase
		_Cliptext = This.cOriginalClipboard
	
		Return Empty (This.cError)
	Endproc
					
	
	Procedure PasteText
			Lparameters tcPasteText
		This.oEditorWin.Paste (m.tcPasteText)
		Return
	Endproc


	Procedure SelectText(lnStartPosition, lnEndPosition)
		This.oEditorWin.Select(m.lnStartPosition, m.lnEndPosition)
		Return
	Endproc


	Procedure ResetInsertionPoint
		Lparameters tnOffset
		This.oEditorWin.SetInsertionPoint (m.tnOffset + This.nSelStart)
	Endproc


	Procedure IsNameChar
		Lparameters lcChar

		Return Isalpha (m.lcChar) Or Isdigit (m.lcChar) Or m.lcChar = '_'
	Endproc


	Procedure IsContinuationLine(lcLine)
		Local lcComments, lcTrimmed
	
		lcComments = '&' + '&'
		If m.lcComments $ m.lcLine
			lcLine = Left(m.lcLine, At(m.lcComments, m.lcLine) - 1)
		Endif
		lcTrimmed = Trim(m.lcLine, 1, ccCR, ccLF, ccTab, ' ')
		Return ';' = Right(m.lcTrimmed, 1) And Not Empty(m.lcTrimmed)
	Endproc
	
Enddefine


 