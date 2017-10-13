* Created: 04/01/12 06:50:56 AM
Lparameters lxParam1

****************************************************************
****************************************************************
* Standard prefix for all tools for Thor, allowing this tool to
*   tell Thor about itself.

If Pcount() = 1						  ;
		And 'O' = Vartype (lxParam1)  ;
		And 'thorinfo' = Lower (lxParam1.Class)

	With lxParam1

		* Required
		.Prompt		   = 'Manage PEM Editor access' && used when tool appears in a menu
		Text To .Description Noshow
Manages access to PEM Editor, consistent with versions of PEM Editor before Thor.
    New Property
    New Method
    Edit Property/Method...
    Context menu of Property Window
		Endtext
		* For public tools, such as PEM Editor, etc.
		.Source	  = 'IDE Tools' && e.g., 'PEM Editor'
		.Author	  = 'Jim Nelson'
		.Sort	  = 1000
		.Category = 'Applications|PEM Editor'
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
	Local lcForm
	lcForm = Execscript(_Screen.cThorDispatcher, "Full Path=Thor_Tool_PEME_ManagePEMAccess.SCX")
	Do Form (lcForm) With Newobject('clsFoxCode')
Endproc


Define Class clsFoxCode As Session

	cError = ''

	Procedure Init
		This.Setup
	Endproc


	Procedure Setup
		Local lcFoxCode, lcFoxCodeName, lcFoxCodePath, lcPath, llFailure, loThorInfo
		lcFoxCode = (_Foxcode)
		llFailure = .F.
		Try
			Use (lcFoxCode) Again Shared Alias PEME_FoxCode
		Catch
			llFailure = .T.
		Endtry
		If llFailure
			This.cError = 'Unable to open FoxCode'
			Return .F.
		Endif

		loThorInfo = Execscript(_Screen.cThorDispatcher, "ToolInfo=", 'Thor_Tool_PEME_LaunchPEMEditor')
		lcPath	   = loThorInfo.FolderName

		lcFoxCodePath = Addbs(lcPath) + "FoxCode Backup"
		If Not Directory (lcFoxCodePath)
			Mkdir (lcFoxCodePath)
		Endif
		lcFoxCodeName = lcFoxCodePath + "\FoxCode_" + Ttoc(Datetime(), 1)
		Copy To (lcFoxCodeName) Cdx

	Endproc


	Procedure Destroy
		Use In (Select ('PEME_FoxCode')) && Close 'PEME_FoxCode'
	Endproc


	Procedure GetStatus(lcType, lcAbbrev, lcData)
		Local lnResult, lnSelect
		lnSelect = Select()
		Select PEME_FoxCode
		lcAbbrev = Padr(lcAbbrev, Len(Abbrev))
		Locate For Type = lcType And Upper(Abbrev) == Upper(lcAbbrev) And Not Deleted()
		Do Case
			Case Not Found()
				lnResult = 1
			Case Upper(Alltrim(Data, 1, ' ', Chr[13], Chr[10])) == Upper(Alltrim(lcData, 1, ' ', Chr[13], Chr[10]))
				lnResult = 2
			Case 'PEMEDITOR.APP' $ Upper(Data)
				lnResult = 3
			Otherwise
				lnResult = 4
		Endcase
		Select (lnSelect)
		Return lnResult
	Endproc

	Procedure AddItem(lcType, lcAbbrev, lcData)
		Local lnSelect, lnStatus
		lnStatus = This.GetStatus(lcType, lcAbbrev, lcData)
		Do Case
			Case lnStatus = 1
				Insert Into PEME_FoxCode(Type, Abbrev, Data, Timestamp) Values (lcType, lcAbbrev, lcData, Datetime())
			Case lnStatus = 2

			Otherwise
				Replace Data With lcData, Timestamp With Datetime() In PEME_FoxCode
		Endcase
	Endproc

	Procedure RemoveItem(lcType, lcAbbrev, lcData)
		Local lnSelect, lnStatus
		lnStatus = This.GetStatus(lcType, lcAbbrev, lcData)
		If lnStatus # 1
			Delete In PEME_FoxCode
		Endif
	Endproc

Enddefine
