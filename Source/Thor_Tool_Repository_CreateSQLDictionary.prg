#Define ccTool 				'Opening Tables'
#Define ccDictionary 		'Dictionary File Name'
#Define ccConnectionString 	'Connection string'

#Define CR Chr(13)

Lparameters lxParam1

****************************************************************
****************************************************************
* Standard prefix for all tools for Thor, allowing this tool to
*   tell Thor about itself.

If Pcount() = 1								;
		And 'O' = Vartype (m.lxParam1)		;
		And 'thorinfo' == Lower (m.lxParam1.Class)

	With m.lxParam1

		* Required
		.Prompt		   = 'Create SQL Data Dictionary' && used in menus

		Text To .Description Noshow
Table of all table and field names in Solomon (updated weekly)
		Endtext
		.Category		 = 'Tables|SQL Data Dictionary'
		.Link     = 'https://vfpx.codeplex.com/wikipage?title=Thor%20TWEeT%2024'
		.CanRunAtStartUp = .F.
		.Author			 = 'JRN'
	Endwith

	Return m.lxParam1
Endif

If Pcount() = 0
	Do ToolCode
Else
	Do ToolCode With m.lxParam1
Endif

Return

****************************************************************
****************************************************************
* Normal processing for this tool begins here.                  
Procedure ToolCode
	Lparameters lxParam1

	Local lnSelect
	lnSelect = Select()
	Do CreateSQLDictionary
	Select (m.lnSelect)
Endproc


Procedure CreateSQLDictionary
	Local laTables[1], lcAlias, lcConnectionString, lcDictionary, lnHandle, lnRecCount

	lcConnectionString = GetConnectionString()
	If Empty(m.lcConnectionString)
		Return
	Endif

	lcDictionary = GetDictionary()
	If Empty(m.lcDictionary)
		Return
	Endif

	lnHandle = Sqlstringconnect(m.lcConnectionString)
	lcAlias	 = Sys(2015)
	ReadSQLTableDefs(m.lnHandle, m.lcAlias)

	If File(m.lcDictionary)
		Erase (m.lcDictionary)
		Erase (Forceext(m.lcDictionary, 'CDX'))
	Endif

	Select * From (m.lcAlias) Into Table (m.lcDictionary)
	Index On XTabName Tag XTabName
	Index On Field_Name Tag Field_Name

	lnRecCount = Reccount()
	Select Distinct XTabName From (m.lcDictionary) Into Array laTables
	Use
	Use In (m.lcAlias)

	SaveDictionary (m.lcDictionary, Alen(m.laTables), m.lnRecCount)


Endproc


* --------------------------------------------------------------------------------
* --------------------------------------------------------------------------------

Procedure ReadSQLTableDefs(lnHandle, lcAlias)

	Local lcTableName, lcName
	Create Cursor (m.lcAlias) (XTabName C(40), Field_Name C(30), Field_TYPE C(1), Field_Len N(3), Field_Dec N(3))

	= SQLTables(m.lnHandle, "'SYSTEM TABLE', 'TABLE'", 'Tablelist')

	Select Tablelist

	Scan
		Use In (Select ('temp')) && Close 'temp'
		lcTableName = Tablelist.table_name
		= SQLColumns(m.lnHandle, m.lcTableName, 'FOXPRO', 'Temp')

		If Used('Temp')
			Wait (Trim(m.lcTableName)) Window Nowait At 20, 20
			Alter Table Temp Add Column XTabName C(40)
			Replace All XTabName With Upper(m.lcTableName)

			lcName = Dbf('Temp')
			Select (m.lcAlias)
			Append From (m.lcName)

		Endif

		Use In (Select ('temp')) && Close 'temp'

	Endscan

	Use In Tablelist

	Wait Clear

	Select (m.lcAlias)

Endproc


* --------------------------------------------------------------------------------
* --------------------------------------------------------------------------------
* --------------------------------------------------------------------------------
* --------------------------------------------------------------------------------

Procedure GetConnectionString
	Private pcConnectionString
	* lcConnectionString = 'Driver={SQL Server};Server=JimN-Desktop\JimBob; database=KongCompany; Trusted Connection=yes;'
	Local lcResult, loForm
	pcConnectionString = Nvl(Execscript(_Screen.cThorDispatcher, 'Get Option=', ccConnectionString, ccTool), '')

	loForm = GetDynamicForm()

	With m.loForm
		.Caption			= 'Connection string'
		.cHeading			= 'Enter connection string'
		.cSaveButtonCaption	= 'Apply'
	Endwith

	Text To m.loForm.cBodyMarkup Noshow Textmerge
	pcConnectionString 	
				.class 				= 'TextBox'
				.caption			= 'Connection string:'
				.width				= 600
				.Increment			= 1		
				.Anchor				= 10	
			|
				.Class	  = 'TestCommandButton'
				.Caption  = 'Test connection string'
				.FontSize = 8
				.Autosize = .T.
				.Anchor	  = 8
				.Left     = 180
				.Top	  = (.Top - 6)
	Endtext

	m.loForm.Render()
	m.loForm.Show(1, .T.)

	If 'O' = Vartype(m.loForm) And m.loForm.lSaveClicked
		lcResult = m.pcConnectionString
	Else
		lcResult = ''
	Endif

	Return (m.lcResult)
Endproc


Define Class TestCommandButton As CommandButton

	Procedure Click
		Execscript(_Screen.cThorDispatcher, 'Thor_Proc_TestConnectionString', pcConnectionString)
	Endproc

Enddefine


* --------------------------------------------------------------------------------
* --------------------------------------------------------------------------------

Procedure GetDictionary
	Private pcFileName
	pcFileName = Execscript(_Screen.cThorDispatcher, 'Get Option=', ccDictionary, ccTool)
	loForm	   = GetDynamicForm()

	With m.loForm
		.Caption			= 'SQL Data Dictionary'
		.cHeading			= 'Get SQL Data Dictionary file name'
		.cSaveButtonCaption	= 'Apply'
	Endwith


	Text To m.loForm.cBodyMarkup Noshow Textmerge
	pcFileName 	
				.class 				= 'TextBox'
				.caption			= 'File Name:'
				.width				= 600
				.Increment			= 1		
				.Anchor				= 10	
			|
				.Class	  = 'BrowseCommandButton'
				.Caption  = 'Browse'
				.FontSize = 8
				.Autosize = .T.
				.Anchor	  = 8
				.Left     = 180
				.Top	  = (.Top - 6)
	Endtext

	m.loForm.Render()
	m.loForm.Show(1, .T.)

	If 'O' = Vartype(m.loForm) And m.loForm.lSaveClicked
		lcResult = m.pcFileName
	Else
		lcResult = ''
	Endif

	Return (m.lcResult)
Endproc


Define Class BrowseCommandButton As CommandButton

	Procedure Click
		Local lcFileName
		lcFileName = Getfile('dbf')
		If Not Empty(m.lcFileName)
			pcFileName = m.lcFileName
			Thisform.Refresh()
		Endif
	Endproc

Enddefine


* --------------------------------------------------------------------------------
* --------------------------------------------------------------------------------

Procedure SaveDictionary(lcDictionary, lnTableCount, lnFieldCount)

	Local lcCaption, lcCurrentDictionary, llCancelButtonVisible, loForm
	lcCurrentDictionary = Evl(Execscript(_Screen.cThorDispatcher, 'Get Option=', ccDictionary, ccTool), '')

	loForm = GetDynamicForm()

	With m.loForm
		.Caption	 = 'SQL Data Dictionary'
		.BorderStyle = 2
		.cHeading	 = Juststem(m.lcDictionary) + ': ' + Transform(m.lnTableCount) + ' tables, ' + Transform(m.lnFieldCount) + ' fields'

		Do Case
			Case Empty(m.lcCurrentDictionary)
				lcCaption			  = 'Save SQL Data Dictionary file name?'
				.cSaveButtonCaption	  = 'Yes'
				.cCancelButtonCaption = 'No'
				llCancelButtonVisible = .T.

			Case Upper(m.lcCurrentDictionary) == Upper(m.lcDictionary)
				lcCaption			  = 'SQL Data Dictionary updated'
				.cSaveButtonCaption	  = 'OK'
				.cCancelButtonCaption = ''
				llCancelButtonVisible = .F.

			Otherwise
				lcCaption			  = 'Replace SQL Data Dictionary file name?'
				.cSaveButtonCaption	  = 'Yes'
				.cCancelButtonCaption = 'No'
				llCancelButtonVisible = .T.

		Endcase

		Text To m.loForm.cBodyMarkup Noshow Textmerge
				.class 				= 'Label'
				.AutoSize			= .F.
				.width				= 300
				.caption			= '<<lcCaption>>'
				.Fontsize			= 12
				.Left				= 50
		|				
				.class 				= 'Label'
				.AutoSize			= .F.
				.width				= 300
				.caption			= 'See Thor Configuration -> Options -> Opening Tables'
				.Left				= 75 
		Endtext

	Endwith


	m.loForm.Render()
	loForm.cntMain.CmdCancel.Visible = m.llCancelButtonVisible
	m.loForm.Show(1, .T.)

	If 'O' = Vartype(m.loForm) And m.loForm.lSaveClicked
		Execscript(_Screen.cThorDispatcher, 'Set Option=', ccDictionary, ccTool, m.lcDictionary)
	Endif

Endproc


* --------------------------------------------------------------------------------
* --------------------------------------------------------------------------------

Procedure GetDynamicForm
	Local loForm
	loForm	   = Execscript(_Screen.cThorDispatcher, 'Class= DynamicFormDeskTop')

	With m.loForm
		.Top		 = 200
		.Left		 = 200
		.MinWidth	 = 275
		.MinHeight	 = 100
		.MinButton	 = .F.
		.MaxButton	 = .F.
		.BorderStyle = 3
	Endwith

	Return m.loForm
Endproc