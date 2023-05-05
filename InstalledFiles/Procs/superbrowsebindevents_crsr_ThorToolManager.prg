Lparameters loForm, loColumn, lcControlSource

Local lcControlSource))

loColumn.DynamicBackColor = [ICase(Deleted(), Rgb(212, 208, 200), Favorite, Rgb(255, 255, 160), Rgb(255, 255, 255))]

AddObjectToForm(m.loForm)

*!* ******** JRN Removed 2023-01-18 ********
*!* Bindevent(m.loColumn.Text1, 'DblClick', m.loForm.oCustomBindEvents, 'RunTool')

lcControlSource = loColumn.FieldName

* hide some columns
If ' ' + lcControlSource + ' ' $ Upper(' ID Link VideoLink OptionTool PlugIns ToolPrompt ToolDescription ')
	m.loColumn.lVisible = .F.
Endif

* fix some header captions
Do Case
	Case lcControlSource == Upper('ToolName')
		m.loColumn.cHeaderCaption = 'Tool Name / Menu Caption'
		m.loForm.Caption = 'Thor Tool Manager'
		m.loForm.cboSelectAlias.Visible = .F.
	Case lcControlSource == Upper('MenuHotKey')
		m.loColumn.cHeaderCaption = 'Menu Hot Key'
	Case lcControlSource == Upper('HotKey')
		m.loColumn.cHeaderCaption = 'Hot Key'
	Case lcControlSource == Upper('HotKeySort')
		m.loColumn.cHeaderCaption = 'Hot Key Sort'
	Case lcControlSource == Upper('Date')
		m.loColumn.cHeaderCaption = 'Modified'
Endcase

* link on column one
If lcControlSource == Upper('ToolName')
	m.loColumn.ControlSource = 'Trim(' + m.loColumn.ControlSource + ')'
	*!* ******** JRN Removed 2023-05-04 ********
	*!* m.loColumn.DynamicFontUnderline = 'not Empty(Link)'
	*!* m.loColumn.DynamicFontBold = 'not Empty(Link)'
	*!* m.loColumn.DynamicForeColor = 'IIF(not Empty(Link), Rgb(0,0,255), 0)'
	*!* Bindevent(m.loColumn.Text1, 'Click', m.loForm.oCustomBindEvents, 'GoURL')
Endif


* maybe these no longer necessary as they are now context menu options
If lcControlSource == Upper('Favorite')
	Bindevent(m.loColumn.Text1, 'LostFocus', m.loForm.oCustomBindEvents, 'Favorite_LostFocus')
Endif

If lcControlSource == Upper('Startup')
	Bindevent(m.loColumn.Text1, 'LostFocus', m.loForm.oCustomBindEvents, 'StartUp_LostFocus')
Endif


* ================================================================================

Procedure AddObjectToForm(loForm)

	If 'O' # Vartype(m.loForm.oCustomBindEvents)
		m.loForm.AddProperty([oCustomBindEvents], Newobject('CustomBindEvents'))
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
		Update  StartUpTools							;
			Set StartUp = m.loData.StartUp			;
			From (m.lcAlias)    As  StartUpTools		;
			Where Upper(StartUpTools.PRGName) = Upper(m.lcPRGName)
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
	
			ShellExecute(0,		;
				  'OPEN', m.lcURL,		;
				  '', Sys(2023), 1)
		Endif && not Empty(lcLink)
	Endproc
			

Enddefine  