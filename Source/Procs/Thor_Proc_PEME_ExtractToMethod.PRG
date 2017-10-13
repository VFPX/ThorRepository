#Define CR  	Chr[13]
#Define CRLF 	Chr[13] + Chr[10]

loExtractToMethod = Newobject('ExtractToMethod')
loExtractToMethod.Run()
Return


*|================================================================================
*|================================================================================

Define Class ExtractToMethod As Custom

	cCodeSource		  = ''
	cCodeSourceBefore = ''
	cCodeSourceAfter  = ''
	nSelEnd			  = 0
	nSelStart		  = 0
	oEditorWin		  = .Null.
	oTools			  = .Null.

	*|================================================================================
	*| extracttomethod
	* editorwin home page = http://vfpx.codeplex.com/wikipage?title=thor%20editorwindow%20object
	Procedure Init
		Local loEditorWin As Editorwin Of 'c:\visual foxpro\programs\MyThor\thor\tools\apps\pem editor\source\peme_editorwin.vcx'
		This.oEditorWin = Execscript(_Screen.cThorDispatcher, 'Class= editorwin from pemeditor')
	Endproc


	*|================================================================================
	*| extracttomethod
	Procedure Run
		Local lcOldClipText, lnWindowType, loEditorWin

		loEditorWin	 = This.oEditorWin
		lnWindowType = loEditorWin.FindWindow()

		If lnWindowType < 0
			Return
		Endif

		This.nSelStart = loEditorWin.GetSelStart()
		This.nSelEnd   = loEditorWin.GetSelEnd()

		If This.nSelStart = This.nSelEnd
			Return
		Endif

		This.cCodeSource	   = loEditorWin.GetString(This.nSelStart, This.nSelEnd - 1)
		This.cCodeSourceBefore = loEditorWin.GetString(0, This.nSelStart - 1)
		This.cCodeSourceAfter  = loEditorWin.GetString(This.nSelEnd, 10000000)

		lcOldClipText	 = _Cliptext

		If  lnWindowType = 10
			This.ExtractForVCXs(loEditorWin)
		Else
			*!* * Removed 11/6/2012 / JRN
			*!* This.ExtractForPRGs()
		Endif

		_Cliptext = lcOldClipText
	Endproc


	*|================================================================================
	*| extracttomethod
	Procedure ExtractForVCXs(loEditorWin)
		Local laTitle[1], lcCodeSource, lcIndent, lcName, lcNewCode, lcNewHeader, lcNewMethodName
		Local lcParameters, llFailed, lnEOF, lnNewPosition, lnSelEnd, lnSelStart, loCurrentObject
		Local loException, loInfo, loTools, loTopOfForm, lcDescription
		lnSelStart = This.nSelStart
		lnSelEnd   = This.nSelEnd

		* tools home page = http://vfpx.codeplex.com/wikipage?title=thor%20tools%20object
		loTools = Execscript(_Screen.cThorDispatcher, 'Class= tools from pemeditor')

		loTopOfForm = loTools.GetCurrentObject(.T.)
		If Isnull(loTopOfForm)
			Return
		Endif

		lcCodeSource	= This.cCodeSource
		loCurrentObject	= loTools.GetThis()

		* prompt for name of new method
		loInfo = This.PromptForMethodName(loEditorWin)
		If 'O' # Vartype(loInfo)
			Return
		Endif

		lcNewMethodName	= loInfo.Name
		lcParameters	= loInfo.Parameters
		lcResultName	= loInfo.Result
		lcDescription	= loInfo.Description 

		* verify
		Try
			If Pemstatus(loTopOfForm, lcNewMethodName, 5)
				Messagebox(lcNewMethodName + ' already exists', 16)
				llFailed = .T.
			Else
				llFailed = .F.
			Endif
		Catch To loException
			Execscript(_Screen.cThorDispatcher, 'Thor_Proc_ShowErrorMessage', loException)
			llFailed = .T.
		Endtry

		If llFailed
			Return
		Endif

		lcNewCode = lcCodeSource
		If Not Empty(lcParameters)
			lcNewCode = 'Lparameters ' + lcParameters + CR + CR + lcNewCode
		EndIf
		
		If Not Empty(lcResultName)
			lcNewCode = lcNewCode + CR + 'Return ' + lcResultName
		EndIf
		
		If Not loTools.CreateNewPEM('M', lcNewMethodName, lcNewCode, , lcDescription)
			Return
		Endif

		****************************************************************
		* put reference to this new method back in the original code

		Do Case
			Case Upper(loTopOfForm.BaseClass) = 'FORM'
				lcNewHeader = 'ThisForm'
			Case 'O' = Vartype(loCurrentObject)
				lcName		= loTools.GetFullObjectName(loCurrentObject)
				lcNewHeader	= 'This' + Replicate('.Parent', Occurs('.', lcName))
			Case 2 < Alines(laTitle, This.oEditorWin.GetTitle(), .T., '.')
				lcNewHeader = 'This' + Replicate('.Parent', Alen(laTitle) - 2)
			Otherwise
				lcNewHeader = 'This'
		Endcase

		lcIndent  = Left(lcCodeSource, At(Getwordnum(lcCodeSource, 1), lcCodeSource) - 1)
		lcNewCode = lcIndent + IIF(Empty(lcResultName), '', lcResultName + ' = ') + lcNewHeader + '.' + lcNewMethodName + '(' + lcParameters + ')'
		Do Case
			Case Right(lcCodeSource, 2) = CRLF
				lcNewCode = lcNewCode + CRLF
			Case Right(lcCodeSource, 1) = CR
				lcNewCode = lcNewCode + CR
		Endcase

		_Cliptext = lcNewCode

		This.oEditorWin.Paste()
		lnNewPosition = lnSelStart + At('(', lcNewCode)
		This.oEditorWin.Select(lnNewPosition, lnNewPosition)
		This.oEditorWin.SetInsertionPoint(lnNewPosition)

		* and edit the new method
		loTools.EditMethod(loTopOfForm, lcNewMethodName)

		If 10 = This.oEditorWin.FindWindow()
			With This.oEditorWin
				lnEOF = .GetFileSize()
				.Select(lnEOF - 1, lnEOF - 1)
				.SetInsertionPoint(lnEOF)
				.WinShow()
			Endwith
		Endif

		*!* ******************** Removed 12/9/2013 *****************
		*!* If Vartype(_oPEMEditor.oUtils.oPEMEditor) = 'O'
		*!* 	_oPEMEditor.oUtils.oPEMEditor.DoRefresh()
		*!* Endif

	Endproc


	*|================================================================================
	*| extracttomethod
	* prompt for name of new method
	Procedure PromptForMethodName(loEditorWin)
		Private lcMethodName, lcDescription
		Local loResult As 'Empty'
		Local lcName, lcParameters, lcResult, loForm
		loForm		 = Execscript(_Screen.cThorDispatcher, 'Class= DynamicFormDeskTop')
		lcMethodName = ''
		lcDescription = ''

		With loForm
			.Caption	 = 'Extract to Method'
			.MinWidth	 = 275
			.MinHeight	 = 100
			.MinButton	 = .F.
			.MaxButton	 = .F.
			.BorderStyle = 3

			.cHeading			= 'Extract highlighted code'
			.cSaveButtonCaption	= 'Apply'
		Endwith


		Text To loForm.cBodyMarkup Noshow Textmerge
	lcMethodName 	.class 				= 'TextBox'
				.caption			= 'To Method :'
				.width				= 300
				.Increment			= 1		
				.Anchor				= 10	
				|
				.class 				= 'Thor_Proc_Label'
				.caption			= 'To return a result named lxResult, enter "lxResult ``" before the method name.'
				.left 				= 30
				.autosize			= .t.
				|
				.class 				= 'Thor_Proc_Label'
				.caption			= 'To create parameters, enter them after the method name, in parenthesis.'
				.left 				= 30
				.autosize			= .t.
				|
				.class 				= 'Thor_Proc_Label'
				.caption			= 'For example::       lxResult `` NewMethod(param1, param2)'
				.left 				= 30
				.autosize			= .t.
				|
		lcDescription		.class 				= 'EditBox'
				.caption			= 'Description:'
				.width				= 300
				.height				= 60
		Endtext

		loForm.Render()
		loForm.AlignToEditWindow(loEditorWin)
		loForm.Show(1, .T.)

		If 'O' = Vartype(loForm) And loForm.lSaveClicked

			If '=' $ lcMethodName
				lcResult	 = Alltrim(Left(lcMethodName, At('=', lcMethodName) - 1))
				lcMethodName = Alltrim(Substr(lcMethodName, At('=', lcMethodName) + 1))
			Else
				lcResult	 = ''
				lcMethodName = Alltrim(lcMethodName)
			Endif

			If '(' $ lcMethodName
				lcName		 = Alltrim(Left(lcMethodName, At('(', lcMethodName) - 1))
				lcParameters = Strextract(lcMethodName, '(', ')', 1, 3)
			Else
				lcName		 = Alltrim(lcMethodName)
				lcParameters = ''
			Endif

			loResult = Createobject('Empty')
			AddProperty(loResult, 'Name', lcName)
			AddProperty(loResult, 'Result', lcResult)
			AddProperty(loResult, 'Parameters', lcParameters)
			AddProperty(loResult, 'Description', lcDescription)
			Return loResult
		Else
			Return .F.
		Endif

	Endproc


	*|================================================================================
	*| extracttomethod
	Procedure GetProcedureStartPositions
		Lparameters lcSearchText

		Local loItem As 'Empty'
		Local loResult As 'Collection'
		Local lcClass, lcCode, lcName, llResult, llWithinAClass, lnGoToPosition, lnI, lnSelStart
		Local lnStartByte, loProc, loProcs

		lcCode	   = This.oEditorWin.GetString(0, 10000000)
		lnSelStart = This.nSelStart
		loResult   = Createobject('Collection')

		loProcs	   = _oPEMEditor.oUtils.GetProcedureStartPositions(lcCode)

		For lnI = 1 To loProcs.Count
			loProc		= loProcs[lnI]
			lcName		= loProc.Name
			lnStartByte	= loProc.StartByte

			loItem			 = This.GetEmptyItem()
			loItem.Class	 = lcClass
			loItem.Name		 = lcName
			loItem.StartByte = lnStartByte

			Do Case

				Case loProc.Type = 'Class' And lnStartByte <= lnSelStart
					llWithinAClass = .T.
					loResult	   = Createobject('Collection')
					lcClass		   = lcName
					loItem.Class   = lcClass
					loItem.Name	   = '<DEFINE>'
					loResult.Add(loItem)

				Case loProc.Type = 'Class'
					loItem.Name		 = '<ENDDEFINE>'
					loResult.Add(loItem)
					Exit

				Case loProc.Type = '-End'
					loResult = Createobject('Collection')

				Case llWithinAClass
					If Occurs('.', loProc.Name) = 1
						loItem.Name		 = Iif('-' $ lcName, '<ENDDEFINE>', lcName)
						loResult.Add(loItem)
					Endif
			Endcase
		Endfor

		Return loResult
	Endproc


	Procedure GetEmptyItem()
		loItem	 = Createobject('Empty')
		AddProperty(loItem, 'Class', '')
		AddProperty(loItem, 'Name', '')
		AddProperty(loItem, 'StartByte', 0)
		Return loItem
	Endproc


	*|================================================================================
	*| extracttomethod
	Procedure ExtractForPRGs
		Local laTitle[1], lcIndent, lcName, lcNewCode, lcNewHeader, lcNewMethodName, llFailed, lnEOF
		Local lnNewPosition, lnSelEnd, lnSelStart, loException, loStartPositions
		lnSelStart = This.nSelStart
		lnSelEnd   = This.nSelEnd

		* Following returns a collection
		* Each item is an object:
		*    Name / StartByte / EndByte
		loStartPositions = This.GetProcedureStartPositions()

		Assert .F. Message 'Not implemented for PRGs'
		Return

		If loStartPositions.Count = 0
			Return
		Endif

		* prompt for name of new method
		lcNewMethodName = This.PromptForMethodName()
		If Empty(lcNewMethodName)
			Return
		Endif

		* verify
		Try
			If Pemstatus(loTopOfForm, lcNewMethodName, 5)
				Messagebox(lcNewMethodName + ' already exists', 16, loTopOfForm.Caption)
				llFailed = .T.
			Else
				llFailed = .F.
			Endif
		Catch To loException
			Execscript(_Screen.cThorDispatcher, 'Thor_Proc_ShowErrorMessage', loException)
			llFailed = .T.
		Endtry

		If llFailed
			Return
		Endif

		If Not loTools.CreateNewPEM('M', lcNewMethodName, '*')
			Return
		Endif

		****************************************************************
		* put reference to this new method back in the original code

		Do Case
			Case Upper(loTopOfForm.BaseClass) = 'FORM'
				lcNewHeader = 'ThisForm'
			Case 'O' = Vartype(loCurrentObject)
				lcName		= loTools.GetFullObjectName(loCurrentObject)
				lcNewHeader	= 'This' + Replicate('.Parent', Occurs('.', lcName))
			Case 2 < Alines(laTitle, This.oEditorWin.GetTitle(), .T., '.')
				lcNewHeader = 'This' + Replicate('.Parent', Alen(laTitle) - 2)
			Otherwise
				lcNewHeader = 'This'
		Endcase

		lcIndent  = Left(lcCodeSource, At(Getwordnum(lcCodeSource, 1), lcCodeSource) - 1)
		lcNewCode = lcIndent + lcNewHeader + '.' + lcNewMethodName + '()'
		Do Case
			Case Right(lcCodeSource, 2) = CRLF
				lcNewCode = lcNewCode + CRLF
			Case Right(lcCodeSource, 1) = CR
				lcNewCode = lcNewCode + CR
		Endcase

		_Cliptext = lcNewCode

		This.oEditorWin.Paste()
		lnNewPosition = lnSelStart + At('(', lcNewCode)
		This.oEditorWin.Select(lnNewPosition, lnNewPosition)
		This.oEditorWin.SetInsertionPoint(lnNewPosition)

		* and edit it
		loTools.EditMethod(loTopOfForm, lcNewMethodName)

		If 10 # This.oEditorWin.FindWindow()
			Return
		Endif

		If Vartype(_oPEMEditor.oUtils.oPEMEditor) = 'O'
			_oPEMEditor.oUtils.oPEMEditor.DoRefresh()
		Endif

		_Cliptext = loTools.oUtils.GetNewMethodHeader(lcNewMethodName) + lcCodeSource

		With This.oEditorWin
			lnEOF = .GetEnvironment(2)
			.Select(lnEOF, lnEOF)
			.Paste()
			.SetInsertionPoint(0)
			.WinShow()
		Endwith
	Endproc


Enddefine
