* This class is used to access and/or modify the currently highlighted text in a code window
* Property <cHighlightedText> contains the highlighted text.
* It can be replaced by using method <PasteText>
* The position of the cursor can be moved from the beginning of the highlighted text
* by using method <ResetInsertionPoint>

#Define ccTab  		Chr(9)
#Define ccCR		Chr(13)
#Define ccLF    	Chr(10)

Define Class CommentText As Session OlePublic

	cClipText		= ''
	nCursorPosition	= 0
	cCommentString	= '*!* '

	Procedure Init
		Local lcCommentString
		lcCommentString	= Execscript(_Screen.cThorDispatcher, 'Thor_Proc_GetRegistryOption.prg', 'EditorCommentString') + ' '
		If Left(Ltrim(lcCommentString), 1) # '*'
			lcCommentString   = '*!* '
		Endif
		This.cCommentString = lcCommentString
	Endproc


	Procedure Error
		Lparameters nError, cMethod, nLine
	Endproc


	Procedure AddComments(lcClipText, lcInsertLineText)
		* Parameters:
		*	lcCliptext:  		Currently selected (or highlighted) text
		* 	lnCursorPosition: 	Where to place the cursor when done (Passed in by reference)

		Local laLines[1], lcCommentString, lcFirstLine, lcIndent, lcLine, lcNewClipText, lcNewText, lcText
		Local lnI, lnLineCount
		lcCommentString	= This.cCommentString

		lnLineCount	= Alines(laLines, lcClipText)
		lcFirstLine	= laLines(1)
		lcIndent	= Left(lcFirstLine, At(Getwordnum(lcFirstLine, 1), lcFirstLine) - 1)

		lcNewClipText = This.FormatPrefixLines(lcInsertLineText, lcIndent, lcCommentString)

		This.nCursorPosition = Len(lcNewClipText)
		For lnI = 1 To lnLineCount
			lcLine = laLines(lnI)
			Do Case
				Case Empty(lcLine)
					lcNewText = ''
				Case lcLine = lcIndent
					lcNewText = lcIndent + lcCommentString + Substr(lcLine, 1 + Len(lcIndent))
				Otherwise
					lcNewText = lcCommentString + lcLine
			Endcase
			lcNewClipText = lcNewClipText + Iif(Empty(lcNewClipText), '', ccCR) + lcNewText
		Endfor && lnI = 1 To lnLineCount

		lcClipText = lcNewClipText + ccCR

		This.cClipText = lcClipText

	Endproc


	Procedure DuplicateComments(lcClipText, lcBeginningLines, lcEndingLines)
		* Parameters:
		*	lcCliptext:  		Currently selected (or highlighted) text
		* 	lnCursorPosition: 	Where to place the cursor when done (Passed in by reference)

		Local laLines[1], lcCommentString, lcFirstLine, lcIndent, lcLine, lcNewClipText, lcNewText
		Local lcResultClipText, lcText, lnI, lnLineCount
		lcCommentString	= This.cCommentString

		lnLineCount	= Alines(laLines, lcClipText)
		lcFirstLine	= laLines(1)
		lcIndent	= Left(lcFirstLine, At(Getwordnum(lcFirstLine, 1), lcFirstLine) - 1)

		lcNewClipText = This.FormatPrefixLines(lcBeginningLines, lcIndent, lcCommentString)

		For lnI = 1 To lnLineCount
			lcLine = laLines(lnI)
			Do Case
				Case Empty(lcLine)
					lcNewText = ''
				Case lcLine = lcIndent
					lcNewText = lcIndent + lcCommentString + Substr(lcLine, 1 + Len(lcIndent))
				Otherwise
					lcNewText = lcCommentString + lcLine
			Endcase
			lcNewClipText = lcNewClipText + Iif(Empty(lcNewClipText), '', ccCR) + lcNewText
		Endfor && lnI = 1 To lnLineCount

		lcNewClipText		 = lcNewClipText + ccCR
		This.nCursorPosition = Len(lcNewClipText)

		lcResultClipText = lcNewClipText + lcClipText 
		If 0 # Len(lcEndingLines)
			 lcResultClipText = lcResultClipText + This.FormatPrefixLines(lcEndingLines, lcIndent, lcCommentString) + ccCR
		EndIf 

		This.cClipText = lcResultClipText

	Endproc


	Procedure RemoveComments(lcClipText, lcNewLineText)
		* Parameters:
		*	lcCliptext:  		Currently selected (or highlighted) text
		* 	lnCursorPosition: 	Where to place the cursor when done (Passed in by reference)


		Local lcCommentString, lcNewLineText, loThor

		lcCommentString	= This.cCommentString

		lcClipText = Strtran(lcClipText, lcCommentString, '')
		If Right(lcCommentString, 1) = ' '
			lcClipText = Strtran(lcClipText, Trim(lcCommentString) + ccTab, '')
		Endif

		If Not Empty(lcNewLineText)
			If '<' $ lcNewLineText
				lcNewLineText = Left(lcNewLineText, At('<', lcNewLineText) - 1)
			Endif
			If Ltrim(lcClipText, 1, ' ', ccTab) = Alltrim(lcNewLineText)
				lcClipText = Substr(Strtran(lcClipText, ccCR + ccLF, ccCR), 1 + At(ccCR, lcClipText))
			Endif
		Endif

		This.cClipText = lcClipText

		Return

	Endproc


	Procedure FormatPrefixLines(lcText, lcIndent, lcCommentString)

		Local lcLine, lcNewText, lnI
		For lnI = 1 To Alines(laLines, lcText)
			lcLine	  = laLines[lnI]
			lcNewText = Iif(lnI = 1, '', lcNewText + ccCR)		;
				+ Iif(Empty(lcLine), '', lcIndent + lcCommentString + lcLine)
		Endfor

		Return lcNewText

	Endproc

Enddefine

