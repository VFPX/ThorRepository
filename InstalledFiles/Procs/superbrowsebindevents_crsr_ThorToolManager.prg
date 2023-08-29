Lparameters loForm, loColumn, lcControlSource

loColumn.DynamicBackColor = [ICase(Deleted(), Rgb(212, 208, 200), Favorite, Rgb(255, 255, 160), Rgb(255, 255, 255))]

AddObjectToForm(m.loForm)

lcControlSource = m.loColumn.FieldName

* fix some header captions
Do Case
	Case m.lcControlSource == Upper('ToolName')
		*!* ******** JRN Removed 2023-08-27 ********
		*!* ModifyFormProperties(m.loForm)
		loColumn.cHeaderCaption	= 'Tool Name / Menu Caption'
		loColumn.ControlSource	= 'Trim(' + m.loColumn.ControlSource + ')'
	Case m.lcControlSource == Upper('MenuHotKey')
		loColumn.cHeaderCaption = 'Menu Hot Key'
	Case m.lcControlSource == Upper('HotKey')
		loColumn.cHeaderCaption = 'Hot Key'
	Case m.lcControlSource == Upper('HotKeySort')
		loColumn.cHeaderCaption = 'Hot Key Sort'
	Case m.lcControlSource == Upper('HasPlugIns')
		loColumn.cHeaderCaption = 'Has Plug Ins'
	Case m.lcControlSource == Upper('Date')
		loColumn.cHeaderCaption = 'Modified'
		
		* hide some columns
	Case ' ' + m.lcControlSource + ' ' $ Upper(' ID Link VideoLink OptionTool PlugIns ToolPrompt ToolDescription ')
		loColumn.lVisible = .F.

Endcase


* ================================================================================

Procedure AddObjectToForm(loForm)

	If 'O' # Vartype(m.loForm.oCustomBindEvents)
		m.loForm.AddProperty([oCustomBindEvents], Newobject('CustomBindEvents'))
	Endif

Endproc

* ================================================================================
Procedure ModifyFormProperties(loForm)
	Local lnAnchor, lnI, lnWidthChange, loControl

	loForm.Caption	 = 'Thor Tool Manager'

	loForm.lblTable.Visible		  = .F.
	loForm.cboSelectAlias.Visible = .F.

	lnWidthChange = m.loForm.pgfFieldPicker.Left - 2
	If m.lnWidthChange > 0
		For lnI = 1 To m.loForm.ControlCount
			loControl = m.loForm.Controls[m.lnI]
			If Pemstatus(m.loControl, 'Left', 5)
				With m.loControl
					lnAnchor = .Anchor
					.Anchor	 = 0
					.Left	 = .Left - m.lnWidthChange
					.Anchor	 = m.lnAnchor
				Endwith
			Endif
			loControl = Null
		Endfor

		With m.loForm.pgfFieldPicker
			lnAnchor = .Anchor
			.Anchor	 = 0
			.Top	 = 35
			.Tabs	 = .F.

			.Width	= m.loForm.Width - 4
			.Height	= m.loForm.Height - .Top - 4
			.Anchor	= m.lnAnchor

			.Page2.chkReadOnly.Visible = .F.
		Endwith

	Endif

Endproc

* ================================================================================
* ================================================================================

Define Class CustomBindEvents As Custom

	Procedure RunTool(loThisTable)
		Local lcPRGName, loForm

		lcPRGName = Trim(PRGName)

		loForm = _Screen.ActiveForm
		m.loForm.Hide()
		Execscript(_Screen.cThorDispatcher, m.lcPRGName)
		m.loForm.Release()
	Endproc


	Procedure Favorite_LostFocus
		Local lcAlias, lcPRGName, loData
		Scatter Name m.loData

		lcPRGName = Evl(m.loData.PRGName, m.loData.HotKey)

		lcAlias = 'Thor_Favorites'
		If Not Used(m.lcAlias)
			Use (_Screen.cThorFolder + 'Tables\Favorites') Again In 0 Alias (m.lcAlias)
		Endif
		Update  Favorites							;
			Set StartUp = m.loData.Favorite			;
			From (m.lcAlias)    As  Favorites		;
			Where Upper(Favorites.PRGName) = Upper(m.lcPRGName)
		If _Tally = 0 And m.loData.Favorite = .T.
			Insert Into (m.lcAlias) (PRGName, StartUp) Values (m.lcPRGName, .T.)
		Endif

		Use In (m.lcAlias)

	Endproc


	Procedure StartUp_LostFocus
		Local lcAlias, lcPRGName, loData
		Scatter Name m.loData

		lcPRGName = Evl(m.loData.PRGName, m.loData.HotKey)

		lcAlias = 'Thor_StartupTools'
		If Not Used(m.lcAlias)
			Use (_Screen.cThorFolder + 'Tables\StartupTools') Again In 0 Alias (m.lcAlias)
		Endif
		Update  StartupTools							;
			Set StartUp = m.loData.StartUp				;
			From (m.lcAlias)    As  StartupTools		;
			Where Upper(StartupTools.PRGName) = Upper(m.lcPRGName)
		If _Tally = 0 And m.loData.StartUp = .T.
			Insert Into (m.lcAlias) (PRGName, StartUp) Values (m.lcPRGName, .T.)
		Endif

		Use In (m.lcAlias)

	Endproc


	Procedure GoURL
		Local lcURL, loData

		Scatter Name m.loData

		lcURL = Trim(m.loData.Link)
		If Not Empty(m.lcURL)
			Declare Integer ShellExecute		;
				In SHELL32.Dll					;
				Integer nWinHandle,				;
				String cOperation,				;
				String cFileName,				;
				String cParameters,				;
				String cDirectory,				;
				Integer nShowWindow

			ShellExecute(0,				;
				  'OPEN', m.lcURL,		;
				  '', Sys(2023), 1)
		Endif && not Empty(lcLink)
	Endproc


Enddefine