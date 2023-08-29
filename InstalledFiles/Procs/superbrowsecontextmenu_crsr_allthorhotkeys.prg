Local laEvents[1], laHotKey[1], laToolName[1], lcAlias, lcPrompt, lcToolName, llChanged, lnResponse
Local loThisTable

#Define CR               	Chr(13)
#Define LF               	Chr(10)
#Define CRLF             	Chr(13)+Chr(10)
#Define Tab				    Chr(9)

lcAlias = Alias()

Scatter Name m.loThisTable Memo

Aevents(laEvents, 0)

If Vartype(m.laEvents[1]) # 'O'
	Return
Endif

lcPrompt = m.laEvents[1].Value
If Empty(m.lcPrompt)
	Return
Endif

Select  PRGName,							;
		Source								;
	From CRSR_ALLTHORHOTKEYS_SOURCE			;
	Where Descript = m.lcPrompt				;
		And Not Empty(HotKey)				;
	Into Array laToolName

Do Case

	Case Not Empty(m.laToolName[1])
		lcToolName = Upper(Forceext(Trim(m.laToolName[1]), 'PRG'))

		llChanged = Execscript(_Screen.cThorDispatcher, 'Thor_Proc_ToolContextMenu', m.lcToolName)
		If m.llChanged
			UpdateChangedFields(m.lcAlias, m.lcToolName)
		Endif

	Case _Tally = 0
		Return

	Case m.laToolName[2] = 'Popup Menu'
		lnResponse = Messagebox('Popup Menu definition' + CRLF + CRLF + 'Open Thor Configuration to edit it?', 32 + 3)
		If m.lnResponse = 6
			Execscript(_Screen.cThorDispatcher)
		Endif

	Otherwise
		Messagebox(Trim(m.laToolName[2]) + ' definition - cannot be edited here', 16)

Endcase

Return



Procedure UpdateChangedFields(lcAlias, lcToolName)

	Return
Endproc
