Lparameters lxParam1

****************************************************************
****************************************************************
* Standard prefix for all tools for Thor, allowing this tool to
*   tell Thor about itself.

If Pcount() = 1								;
		And 'O' = Vartype (lxParam1)		;
		And 'thorinfo' == Lower (lxParam1.Class)

	With lxParam1

		* Required
		.Prompt		   = 'Remove WITH/ENDWITH' && used in menus

		* Optional
		Text To .Description Noshow && a description for the tool
Use this tool when the cursor is inside an WITH/ENDWITH block to remove the WITH and ENDWITH statements and to modify all references to names beginning with a period.

The original reason for this tool was to correct code that had a RETURN between WITH and ENDWITH, a no-no that causes C5 errors, but need not be used only for this case.
		Endtext
		.StatusBarText	 = ''
		.CanRunAtStartUp = .F.

		* These are used to group and sort tools when they are displayed in menus or the Thor form
		.Category      = 'Code|WITH/ENDWITH' && creates categorization of tools; defaults to .Source if empty

		* For public tools, such as PEM Editor, etc.
		.Author        = 'Jim Nelson'

	Endwith

	Return lxParam1
Endif

If Pcount() = 0
	Do ToolCode
Else
	Do ToolCode With lxParam1
Endif

Return

****************************************************************
****************************************************************
* Normal processing for this tool begins here.                  
Procedure ToolCode
	Lparameters lxParam1

	* editorwin home page = http://vfpx.codeplex.com/wikipage?title=thor%20editorwindow%20object
	Local lcCliptext, lcCodeBlock, lcNewCodeBlock, lnOrigSelEnd, lnOrigSelStart, lnPrevSelStart
	Local lnSelEnd, lnSelStart, loEditorWin
	loEditorWin = Execscript(_Screen.cThorDispatcher, 'Class= editorwin from pemeditor')

	If loEditorWin.GetEnvironment(25) <= 0
		Return
	Endif

	lcCliptext = _Cliptext

	lnOrigSelStart = m.loEditorWin.GetSelStart()
	lnOrigSelEnd   = m.loEditorWin.GetSelEnd()

	lnPrevSelStart = lnOrigSelStart

	Do While .T.
		Execscript(_Screen.cThorDispatcher, 'Thor_Proc_HighlightControlStructure')

		lnSelStart = m.loEditorWin.GetSelStart()
		lnSelEnd   = m.loEditorWin.GetSelEnd()

		If lnPrevSelStart = lnSelStart
			Exit
		Endif

		lnPrevSelStart = lnSelStart

		lcCodeBlock = loEditorWin.GetString(m.lnSelStart, m.lnSelEnd)
		If Upper(Getwordnum(lcCodeBlock, 1)) = 'WITH'
			lcNewCodeBlock = RemoveWITH (lcCodeBlock)
			m.loEditorWin.Paste(lcNewCodeBlock)
			Exit
		Endif

	Enddo && while .t.

	loEditorWin.Select(m.lnOrigSelStart, m.lnOrigSelEnd)
	_Cliptext = lcCliptext

Endproc


#Define	CR  		Chr[13]
#Define LF			Chr[10]
#Define Tab			Chr[9]
#Define CRLF		CR + LF
#Define DoubleAmps 	'&' + '&'

#Define DotMarker	Chr[134]

Procedure RemoveWITH(tcCodeBlock)

	* first issue: there may be lines terminated by CR not CRLF
	* this is peculiar to code just entered into a code window
	Local laLines[1], lcCodeBlock, lcLine, lcNextChars, lcPrevChar, lcTempFile, lcWITHLine
	Local lcWithObjectName, llReplace, lnI, lnPos, lnSelect, lnStartPos, lnWithLevel

	lnSelect = Select()
	Select 0

	lcCodeBlock = Strtran(Strtran(tcCodeBlock, LF, ''), CR, CRLF)

	* Pick of the parameter to the WITH statement
	lnPos	   = At(LF, lcCodeBlock)
	lcWITHLine = Chrtran(Left(lcCodeBlock, lnPos - 2), Tab, ' ')
	If DoubleAmps $ lcWITHLine
		m.lcWITHLine = Left(m.lcWITHLine, At(DoubleAmps, m.lcWITHLine) - 1)
	Endif
	lcWithObjectName = Alltrim(Strtran(m.lcWITHLine, 'with', '', 1, 1, 1), 1)
	lcCodeBlock		 = Substr(lcCodeBlock, lnPos + 1)

	* remove the trailing ENDWITH
	For lnI = 1 To Occurs(LF, m.lcCodeBlock)
		lnPos = Rat(LF, m.lcCodeBlock, lnI)
		If Upper(Getwordnum(Substr(m.lcCodeBlock, lnPos), 1)) = 'ENDW'
			m.lcCodeBlock = Left(m.lcCodeBlock, lnPos)
			Exit
		Endif
	Endfor

	* create cursor showing start/end positions of non-code blocks (characters strings and comments)
	lcTempFile = 'crsr_NotCode'
	Execscript (_Screen.cThorDispatcher, 'Thor_Proc_FindNonCodeBlocks', lcCodeBlock, lcTempFile)

	* Replace all DOTs in code with a marker character (actual placement comes later)
	For lnI = Occurs('.', lcCodeBlock) To 1 Step -1
		lnPos		= At('.', lcCodeBlock, lnI)
		lcPrevChar	= Substr(lcCodeBlock, lnPos - 1, 1)
		lcNextChars	= Substr(lcCodeBlock, lnPos + 1, 2)
		llReplace	= .F.
		Do Case
			Case lnPos = 1
				llReplace = .T.
			Case Isalpha(lcPrevChar) Or Isdigit(lcPrevChar) Or lcPrevChar $ '_)]'

			Case Isdigit(lcNextChars)

			Case Inlist(Upper(lcNextChars), 'F.', 'T.')

			Otherwise
				Locate For Between(lnPos, Start, End)
				llReplace = Not NotCode
		Endcase

		If llReplace
			lcCodeBlock = Stuff(lcCodeBlock, lnPos, 1, DotMarker)
		Endif
	Endfor

	* ignore code inside internal WITH/ENDWITH
	lnWithLevel	= 0
	lnStartPos	= 1
	For lnI = 1 To Alines(laLines, lcCodeBlock)
		lcLine = laLines[lnI]
		Locate For Between(lnStartPos, Start, End)
		Do Case
			Case NotCode && should apply to the entire line

			Case Upper(Getwordnum(lcLine, 1)) == 'WITH'
				lnWithLevel = lnWithLevel + 1
			Case Upper(Getwordnum(lcLine, 1)) == 'ENDWITH'
				lnWithLevel = lnWithLevel - 1
			Case lnWithLevel > 0
				lcCodeBlock = Stuff(lcCodeBlock, lnStartPos, Len(lcLine), Chrtran(lcLine, DotMarker, '.')) 
		Endcase
		lnStartPos = lnStartPos + Len(lcLine) + 2
	Endfor

	lcCodeBlock = Strtran(lcCodeBlock, DotMarker, lcWithObjectName + '.')

	* clean up and we are done
	Use In (lcTempFile)
	Select(lnSelect)

	Return m.lcCodeBlock

Endproc
