Local laHotKey[1], lcAlias, lcToolName, llChanged, lnResponse, loThisTable

#Define CR               	Chr(13)
#Define LF               	Chr(10)
#Define CRLF             	Chr(13)+Chr(10)
#Define Tab				    Chr(9)

lcAlias = Alias()

Scatter Name m.loThisTable Memo

Do Case
	Case Not Empty(m.loThisTable.PRGName)
		lcToolName = Upper(Forceext(m.loThisTable.PRGName, 'PRG'))

		llChanged = Execscript(_Screen.cThorDispatcher, 'Thor_Proc_ToolContextMenu', m.lcToolName)
		If m.llChanged
			UpdateChangedFields(m.lcAlias, m.lcToolName)
		Endif

	Case m.loThisTable.Source = 'Popup Menu'
		lnResponse = Messagebox('Popup Menu definition' + CRLF + CRLF + 'Open Thor Configuration to edit it?', 32 + 3)
		If m.lnResponse = 6
			Execscript(_Screen.cThorDispatcher)
		Endif

	Otherwise
		Messagebox(Trim(m.loThisTable.Source) + ' definition - cannot be edited here', 16)
Endcase

Return



Procedure UpdateChangedFields(lcAlias, lcToolName)

	Local laHotKey[1], lcToolbar, llFavorite, llStartup, lnRecNo, loCloseTemps, loThorUtils

	loThorUtils  = Execscript (_Screen.cThorDispatcher, 'Thor_Proc_Utils')

	loCloseTemps = m.loThorUtils.CloseTempFiles()
	m.loThorUtils.OpenThorTables()

	llFavorite = GetStatus('Favorites', 'StartUp', m.lcToolName)
	llStartup  = GetStatus('StartupTools', 'StartUp', m.lcToolName)
	lcToolbar  = GetStatus('ToolBarTools', 'Caption', m.lcToolName, 'Enabled')
	Select  Chrtran(Alltrim(Descript), '-', '+')									;
		From ToolHotKeyAssignments													;
			Join HotKeyDefinitions													;
				On     ToolHotKeyAssignments.HotKeyID = HotKeyDefinitions.Id		;
		Where Upper(PRGName) = Upper(m.lcToolName)									;
			And HotKeyID # 0														;
		Into Array laHotKey

	Select (m.lcAlias)
	lnRecNo = Recno()
	Update  TM										;
		Set Favorite   = m.llFavorite,				;
			StartUp    = m.llStartup,				;
			ToolPrompt = Evl(m.lcToolbar, ''),		;
			HotKey     = Evl(m.laHotKey, '')		;
		From (m.lcAlias)    As  TM					;
		Where Upper(PRGName) = m.lcToolName
	Goto(m.lnRecNo)

Endproc


Procedure GetStatus(lcTable, lcField, lcPRGName, lcEnabledField)
	Local laStatus[1]

	lcEnabled = Iif(Empty(m.lcEnabledField), '', ' and ' + m.lcEnabledField)

	Select  &lcField									;
		From &lcTable									;
		Where Upper(PRGName) =  Upper(m.lcPRGName)		;
			&lcEnabled									;
		Into Array laStatus
	Return m.laStatus
	Return
Endproc
