Lparameters lxParam1
****************************************************************
****************************************************************
* Standard prefix for all tools for Thor, allowing this tool to
*   tell Thor about itself.
If Pcount() = 1								;
		And 'O' = Vartype(lxParam1)			;
		And 'thorinfo' = Lower(lxParam1.Class)
	With lxParam1
		.Prompt      = [Combine REPLACE statements]
		Text To .Description Noshow
Replace a highlighted block of simple REPLACE commands, like this:
    Replace Field1 with Value1
    Replace Field2 with Value2
    Replace Field3 with Value3

with a single multi-line statement that looks like this:
    Replace Field1 with Value1  ;
            Field2 with Value2  ;
            Field3 with Value3  ;
            in Alias
            
The alias referenced here is prompted for when you run the tool.
		Endtext
		.Category		 = 'Code|Highlighted text'
		.Author			 = 'Andrew Nickless'
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
	Local lcClipText, lcOldClipText, lnCursorPosition, loEditorWin, lcTableAlias
	loEditorWin = Execscript(_Screen.cThorDispatcher, 'class= editorwin from pemeditor')
	* locate the active editor window; exit if none active
	If loEditorWin.GetEnvironment(25) <= 0
		Return
	Endif
	lcOldClipText = _Cliptext
	* copy highlighted text into clipboard
	loEditorWin.Copy()
	lcClipText = _Cliptext
	Local lcClipText, lcTableAlias

	lnCursorPosition = -1
	ModifySelectedText(loEditorWin, @lcClipText, @lnCursorPosition, lcOldClipText)
	****************************************************************
	* This final block of code pastes in the modification (in <lcNewCliptext>)
	loEditorWin.Paste(lcClipText)
	If lnCursorPosition >= 0
		loEditorWin.SetInsertionPoint(lnCursorPosition)
	Endif
	_Cliptext = lcOldClipText
	Return
Endproc


Procedure ModifySelectedText(loEditorWin, lcClipText, lnCursorPosition, lcOldClipText)
	* Parameters:
	*     lcCliptext:             Currently selected (or highlighted) text
	*     lnCursorPosition:       Where to place the cursor when done (Passed in by reference)
	#Define ccTab           Chr(9)
	#Define ccCR            Chr(13)

	Local laLines[1], lcAlias, lcComment, lcExtraIndent, lcFirstLine, lcFirstWord, lcIndent, lcLine
	Local lcNewClipText, lcReplace, lcUpper, llLineAdded, lnCount, lnI, lnLineCount, lnPos

	lnLineCount	= Alines(laLines, lcClipText)
	lcFirstLine	= laLines(1)
	lcIndent	= Left(lcFirstLine, At(Getwordnum(lcFirstLine, 1), lcFirstLine) - 1)
	lcFirstLine	= StripComments(lcFirstLine)

	lcNewClipText = ''
	lcComment	  = '&' + '&'
	lcExtraIndent = GetNormalIndentation()
	lnCount		  = 1
	llLineAdded	  = .F.
	lnI			  = 2

	For lnI = 2 To lnLineCount
		lcLine		= laLines(lnI)
		lcFirstWord	= Getwordnum(Upper(lcLine), 1)
		Do Case
			Case Empty(lcLine) && strip blank lines
				* do nothing
			Case 'REPLACE' = lcFirstWord
				If llLineAdded = .T.
					lcNewClipText     = lcNewClipText + ' ;' + ccCR + lcIndent + lcExtraIndent
				Endif
				lcLine		  = StripComments(lcLine)
				lcReplace	  = Substr(lcLine, Atc(lcFirstWord, lcLine) + Len(lcFirstWord))
				lcNewClipText = lcNewClipText + lcReplace
				llLineAdded	  = .T.
				lnCount		  = lnCount + 1
			Case Inlist(Substr(Alltrim(lcLine, ' ', ccTab), 1, 1), '*', '&') && strip if, comments between
				* do nothing
			Otherwise
				Exit
		Endcase
	Endfor

	If llLineAdded
		lcNewClipText = lcIndent + lcFirstLine + ' ;' + ccCR +				;
			lcIndent + lcExtraIndent + lcNewClipText + ' ;' + ccCR +		;
			lcIndent + lcExtraIndent  + ' In '
	Else
		lcNewClipText = lcIndent + lcFirstLine +  ' In '
	Endif

	* --------------------------------------------------------------------------------
	lcUpper = Upper(Chrtran(lcNewClipText, ccTab, ' '))
	Do Case
		Case ' FOR ' $ lcUpper
			Messagebox('Statements with FOR phrase cannot be combined', 16, 'Failed')
			Return
		Case Occurs(' ALL ', lcUpper) = 0

		Case Occurs(' ALL ', lcUpper) = lnCount
			For lnI = 2 To lnCount
				lnPos		  = At(' ALL ', lcUpper, lnI)
				lcNewClipText = Stuff(lcNewClipText, lnPos, 5, Space(5))
			Endfor
		Otherwise
			Messagebox('Statements with ALL phrases can only be merged' + ccCR + 'if ALL is found in each phrase.', 16, 'Failed')
			Return

	Endcase
	* --------------------------------------------------------------------------------

	lcAlias	  = PromptForAlias(loEditorWin, lcNewClipText + '<<Alias>>')
	If Vartype(lcAlias) = 'L'
		Return
	Endif

	lcAlias		  = Evl(lcAlias, 'Alias()')
	lcNewClipText = lcNewClipText + lcAlias

	lcClipText = lcNewClipText + ccCR
	Return
Endproc


Procedure StripComments
	Lparameters tcReplace
	Local lcComment, lcReplace
	lcComment     = '&' + '&'
	If lcComment $ tcReplace
		lcReplace = Substr(tcReplace, 1, Atc(lcComment, tcReplace) - 1)
	Else
		lcReplace = tcReplace
	Endif
	Return Alltrim(lcReplace, 1, ' ', ccTab)
Endproc

Procedure GetNormalIndentation
	If Execscript(_Screen.cThorDispatcher, 'Thor_Proc_BeautifyOption', 4) = 1
		Return ccTab
	Else
		Return Space(Execscript(_Screen.cThorDispatcher, 'Thor_Proc_BeautifyOption', 3))
	Endif
Endproc


Procedure PromptForAlias(loEditorWin, tcReplaceText)
	#Define ccKey	[Aliases]
	#Define ccTool  [Combine REPLACE statements]

	Private pcAlias, paAliases, pcReplaceText, pcClickMethodCode
	Local laUsed[1], lcAliases, lcNewAliases, lcNewMethodName, lnI, lnItemCount, lnStart, lnUsed, loForm
	loForm		  = Execscript(_Screen.cThorDispatcher, 'Class= DynamicFormDeskTop')
	pcAlias		  = ''
	pcReplaceText = tcReplaceText

	lcAliases = Nvl(Execscript(_Screen.cThorDispatcher, 'Get Option=', ccKey, ccTool), '')
	If Empty(lcAliases)
		Dimension paAliases[1]
		paAliases[1] = 'Alias()'
	Else
		Alines(paAliases, lcAliases, 5, ',')
	Endif

	lnUsed = Aused(laUsed)
	If lnUsed > 0
		Asort(laUsed, 1, -1, 0, 1)
		lnItemCount = Alen(paAliases)
		For lnI = 1 To lnUsed
			If 0 = Ascan(paAliases, laUsed[lnI, 1], 1, -1, 1, 7)
				lnItemCount = lnItemCount + 1
				Dimension paAliases[lnItemCount]
				paAliases[lnItemCount] = laUsed[lnI, 1]
			Endif
		Endfor
	Endif

	With loForm
		.Caption	 = 'Set Alias'
		.MinWidth	 = 275
		.MinHeight	 = 100
		.MinButton	 = .F.
		.MaxButton	 = .F.
		.BorderStyle = 2

		.cHeading			= 'Enter Alias to be used after IN'
		.cSaveButtonCaption	= 'Apply'
	Endwith

	Text To loForm.cBodyMarkup Noshow Textmerge
	pcAlias 	.class 				= 'ComboBox'
				.caption			= 'Enter Alias:'
				.name				= 'cboAlias'
				.width				= 200
				.Increment			= 1	
				.RowSourceType	    = 5	
				.RowSource		    = 'paAliases'
				.Value				= '<<paAliases[1]>>'
				.DisplayCount		= 20
				|
				.class				= 'Thor_Proc_ResultButton'
				.caption			= 'Alias()'
				.default			= .f.
				.Tag				= 'ALIAS'
				.row-increment		= 0
				|
	pcReplaceText	.class			= 'EditBox'
				.Height				= 85
				.Readonly			= .T.
				.Caption			= 'Replacement Text'
				.FontName			= 'Courier New'
				.Width				= 300
	Endtext

	loForm.Render()
	loForm.AlignToEditWindow(loEditorWin)
	loForm.Show(1, .T.)

	If 'O' = Vartype(loForm) And Not Empty(loForm.cReturn)
		Do Case
			Case loForm.cReturn = 'ALIAS'
				pcAlias = 'Alias()'
			Case Upper(loForm.cReturn) = 'CANCEL'
				Return .F.
			Otherwise
				pcAlias		 = Alltrim(loForm.cntMain.cboAlias.DisplayValue)
				lcNewAliases = Alltrim(pcAlias)
				For lnI = 1 To Min(Alen(paAliases), 8)
					If Not Upper(pcAlias) == Upper(paAliases[lnI])
						lcNewAliases = lcNewAliases + ',' + paAliases[lnI]
					Endif
				Endfor

				Execscript(_Screen.cThorDispatcher, 'Set Option=', ccKey, ccTool, lcNewAliases)
		Endcase

		Return pcAlias
	Else
		Return .F.
	Endif
Endproc
