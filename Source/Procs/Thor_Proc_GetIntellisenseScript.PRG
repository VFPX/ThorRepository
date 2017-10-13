Lparameters lcText, lnLocation

Local lcFoxCode, lcRecord, llOpened, loFoxcode, lxResult

* --------------------------------------------------------------------------------
lcFoxCode = 'Foxcode' + Sys(2015)

Try
	Use (_Foxcode) Again In 0 Shared Alias (m.lcFoxCode)
	llOpened = .T.
Catch
	llOpened = .F.
Endtry

* --------------------------------------------------------------------------------
lxResult = .F.
If m.llOpened
	lcRecord = 'FoxCodeRecord' + Sys(2015)
	Select * From (m.lcFoxCode) Where Trim(Upper(Abbrev)) == Upper(m.lcText) Into Cursor (m.lcRecord)
	Do Case
		Case _Tally = 0

		Case Empty(Data)
			lxResult = Trim(Expanded)
		Case cmd = '{stmthandler}'
			lxResult = Data
		Case cmd = '{}'
			Scatter Name m.loFoxcode Memo
			AddProperty(m.loFoxcode, 'Location', m.lnLocation)
			AddProperty(m.loFoxcode, 'ValueType', '')
			lxResult = Execscript(m.loFoxcode.Data, m.loFoxcode)
	Endcase
	Use In (m.lcFoxCode)
	Use In (m.lcRecord)
Endif
Return Execscript(_Screen.cThorDispatcher, 'Result=', m.lxResult)

