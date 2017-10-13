Lparameters lcFileName, tcAlias

#Define 	ccTool 				'Opening Tables'

#Define		ccSQLsFirst			'SQLs First'
#Define		ccIncludeMRUs		'Include MRUs'
#Define		ccConnectionString	'Connection String'
#Define		ccNumberofRecords	'Number of SQL records'
#Define		ccDictionaryFile	'Dictionary File Name'

*** JRN 03/08/2013
*
* Result must be returned with following syntax (required by Thor)
* 	Return Execscript(_Screen.cThorDispatcher, 'Result=', RESULT)
*
* Result may be any of these (otherwise ignored)
*	Character string = Alias for cursor/table/view
*   Object containing array property named aList, with up to five columns (only one required)
*		Columns 1, 2, and 3 = to be displayed in dropdown
*       Column 4 = ignored
*       Column 5 = text to be pasted in if user pressed Ctrl+Enter,
*             such as happens when you display the PEMs from an
*             object (pasting in the parameter list for a method)
*   An object (PEMSs will be displayed)

*  Thanks to Mike Potjer (MJP) to his enhancements to this / JRN

* tools home page = http://vfpx.codeplex.com/wikipage?title=thor%20tools%20object
Local lcAlias, lcResult, llDBCTable, llSQLsFirst, loTools

lcResult = ''
lcAlias	 = Evl(m.tcAlias, GetAliasFromFileName(m.lcFileName))

* tools home page = http://vfpx.codeplex.com/wikipage?title=thor%20tools%20object
loTools = Execscript(_Screen.cThorDispatcher, 'Class= tools from pemeditor')

* Note the use of passing a variable by reference so that each function below
* simply returns a result indicating success/failure, whereas the actual
* result (see above) is stuffed into lcResult

*-- MJP -- 02/06/2014 05:00:53 PM
*-- Check if the alias is in the format DBC!TableName.
llDBCTable = ( '!' $ m.lcAlias )

*-- MJP -- 02/06/2014 05:09:00 PM
*-- If the passed filename is a VFP DBC + TableName, then we're not
*-- going to bother trying to open it as a SQL table, so ignore the
*-- SQLs first option.
*!*	llSQLsFirst = GetOption(ccSQLsFirst, .F.)
llSQLsFirst = Iif( m.llDBCTable, .F., GetOption(ccSQLsFirst, .F.) )

Do Case

	Case Used(m.lcAlias)
		lcResult = m.lcFileName

		*-- MJP -- 02/06/2014 05:24:57 PM
		*-- This function only checks if a DBC!TableName is already open,
		*-- so do this next.
	Case CheckIfDBCFile(m.lcFileName, m.lcAlias, m.loTools, @m.lcResult)

		*-- MJP -- 02/06/2014 05:11:02 PM
		*-- Only try to open this as a SQL table if it isn't a VFP DBC and
		*-- table name.
	Case m.llDBCTable = .F. And m.llSQLsFirst = .T. And USESQLTable(m.lcFileName, m.lcAlias, m.loTools, @m.lcResult)

	Case TryToUSE(m.lcFileName, m.lcAlias, m.loTools, @m.lcResult)

	Case TryToUSEJustStem(m.lcFileName, m.lcAlias, m.loTools, @m.lcResult)

	Case LookInDataEnviroment(m.lcFileName, m.lcAlias, m.loTools, @m.lcResult)

		*-- MJP -- 02/06/2014 05:11:41 PM
		*-- Only try to open this as a SQL table if it isn't a VFP DBC and
		*-- table name.
	Case m.llDBCTable = .F. And m.llSQLsFirst = .F. And USESQLTable(m.lcFileName, m.lcAlias, m.loTools, @m.lcResult)

	Case GetTableForAlias(m.lcFileName, @m.lcResult)

	Case GetOption(ccIncludeMRUs, .T.) And LookInMRUList(m.lcFileName, m.lcAlias, m.loTools, @m.lcResult)

Endcase

Return Execscript(_Screen.cThorDispatcher, 'Result=', m.lcResult)


***********************************************************************
***********************************************************************
***********************************************************************

Procedure CheckIfDBCFile(lcFileName, tcAlias, loTools, lcResult)
	****** Reference to already opened DBC file?
	Local lcAlias
	If '!' $ m.tcAlias
		lcAlias	= Substr(m.tcAlias, Atc('!', m.tcAlias) + 1 )
		If Used(m.lcAlias)
			lcResult = m.lcAlias
			Return .T.
		Endif
	Endif
	Return .F.
Endproc


*-- MJP -- 02/06/2014 05:13:13 PM
*!*	Procedure TryToUSE(lcFileName, lcAlias, loTools, lcResult)
Procedure TryToUSE(lcFileName, tcAlias, loTools, lcResult)
	****** Try USE on the file (finds in current folder on the path) 
	Local lcAlias, llReturn
	llReturn = .F.

	*{ MJP -- 02/06/2014 05:13:41 PM - Begin
	*-- Check if the alias is in DBC!TableName format, and strip off
	*-- the DBC name to use the TableName as the alias.
	lcAlias = m.tcAlias
	If '!' $ m.tcAlias
		lcAlias	= Substr(m.tcAlias, Atc('!', m.tcAlias) + 1 )
	Endif
	*} MJP -- 02/06/2014 05:13:41 PM - End

	Try
		*-- MJP -- 02/06/2014 05:19:27 PM
		*-- Try to open the table AGAIN, in case it's already open with
		*-- a different alias.
		Use (m.lcFileName) Shared In 0 Alias (m.lcAlias) Nodata Again
		lcResult = m.lcAlias
		llReturn = .T.
		m.loTools.AddMRUFile(Dbf(m.lcAlias))
	Catch
	Endtry

	Return m.llReturn
Endproc


Procedure TryToUSEJustStem(lcFileName, lcAlias, loTools, lcResult)
	****** Try USE just the stem of the file (finds in current folder on the path) 
	Local lcFileToFind, llReturn
	llReturn	 = .F.
	lcFileToFind = Alltrim(Lower(m.lcAlias))
	If Not Lower(m.lcFileToFind) == Lower(m.lcFileName)
		Try
			Use (m.lcFileToFind) Again Shared In 0 Alias (m.lcAlias) Nodata
			lcResult = m.lcAlias
			llReturn = .T.
			m.loTools.AddMRUFile(Dbf(m.lcAlias))
		Catch
		Endtry
	Endif
	Return m.llReturn
Endproc


Procedure LookInMRUList(lcFileName, lcAlias, loTools, lcResult)
	****** Check the MRU List for DBFs opened from the command window
	Local lcFileToFind, lcItem, lcJustPath, lnFileCount, lnX, loDBF

	loDBF		 = m.loTools.GetMRUList('dbf')
	lnFileCount	 = m.loDBF.Count
	lcFileToFind = Alltrim(Lower(Juststem(m.lcFileName)))
	lcJustPath	 = Justpath(m.lcFileToFind)

	If m.lnFileCount > 0
		For lnX = 1 To m.lnFileCount
			lcItem	   = m.loDBF.Item(m.lnX)
			Do Case
				Case Empty(m.lcJustPath) And m.lcFileToFind == Lower(Juststem(m.lcItem)) And File(m.lcItem)
					lcResult = m.loDBF.Item(m.lnX)
					Exit
				Case Not Empty(m.lcJustPath) And m.lcFileToFind $ Lower(m.lcItem) And File(m.lcItem)
					lcResult = m.loDBF.Item(m.lnX)
					Exit
				Otherwise
			Endcase
		Endfor
	Endif
	Release m.loDBF
	If Not Empty(m.lcResult)
		Try
			lcAlias = Juststem(m.lcResult)
			Use(m.lcResult) Again Shared In 0 Alias(m.lcAlias) Nodata
			lcResult = m.lcAlias
			m.loTools.AddMRUFile(Dbf(m.lcAlias))
		Catch
		Endtry
	Endif

	Return Not Empty(m.lcResult)
Endproc


Procedure LookInDataEnviroment(lcFileName, lcAlias, loTools, lcResult)
	****** If there is an active form, check the data environment
	Local laDataEnvironment[1], lcResult, lnX, loCurrent, loDataEnvironment, loFormObject
	loFormObject = m.loTools.GetCurrentObject(.T.)
	If Not Isnull(m.loFormObject) And 0 # Aselobj(laDataEnvironment, 2)
		loDataEnvironment = m.laDataEnvironment[1]
		lcAlias			  = Lower(Juststem(m.lcFileName))
		For lnX = 1 To 1000
			If 'O' # Type('loDataEnvironment.Objects(lnX)')
				Exit
			Else
				loCurrent = m.loDataEnvironment.Objects(m.lnX)
				If Pemstatus(m.loCurrent, 'Alias', 5) And Lower(m.loCurrent.Alias) == m.lcAlias
					lcResult = Addbs(Justpath(m.loCurrent.Database)) + Alltrim(m.loCurrent.CursorSource)
					Try
						If Not Used(m.lcAlias)
							Use(m.lcResult) Again Shared In 0 Alias(m.lcAlias) Nodata
							lcResult = m.lcAlias
							m.loTools.AddMRUFile(Dbf(m.lcAlias))
						Endif
					Catch
					Endtry
					If Not Empty(m.lcResult)
						Return .T.
					Endif
					Exit
				Endif
			Endif && 'O' # Type('laDataEnvironment.Objects(lnX)')
		Endfor
	Endif
	Return .F.
Endproc


#Define SQLPREFIX '_SQL4ISX_'

Procedure USESQLTable(tcFilename, lcAlias, loTools, lcResult)
	****** Read structure from SQL Table
	Local lcSQLFileName

	lcResult = m.tcFilename
	If Atc(SQLPREFIX, m.tcFilename) = 1
		lcSQLFileName = m.lcResult
	Else
		lcSQLFileName = SQLPREFIX + m.lcResult
	Endif

	Do Case
			* If cursor already exists, use it
		Case Used(m.lcSQLFileName)
			lcResult = m.lcSQLFileName

			* Read an empty cursor from SQL Server
		Case UseSQLFile(m.lcResult, m.lcSQLFileName)
			lcResult = m.lcSQLFileName

			* Create an empty cursor from a local dictionary of all tables
		Case UseSQLFileFromDictionary(m.lcResult, m.lcSQLFileName)
			lcResult = m.lcSQLFileName

		Otherwise
			lcResult = ''

	Endcase

	Return Not Empty(m.lcResult)

Endproc


Procedure UseSQLFile(lcFileName, lcSQLFileName)
	* This needs to be filled in to create a cursor named <lcSQLFileName>
	* if <lcFileName> is a valid table.  In order to get just the structure,
	* use WHERE 1=0.
	* Return .T. if successful

	Local lcConnectionString, lcSQL, lnConnectionHandle, lnRecords, lnResult

	lcConnectionString = GetOption(ccConnectionString, '')
	If Empty(m.lcConnectionString)
		Return .F.
	Endif
	lnConnectionHandle = Sqlstringconnect(m.lcConnectionString)

	If m.lnConnectionHandle > 0
		lnRecords = GetOption(ccNumberofRecords, 0)
		If m.lnRecords = 0
			lcSQL = 'Select * From ' + m.lcFileName + ' Where 0 = 1'
		Else
			lcSQL = 'Select top ' + Transform(m.lnRecords) + ' * From ' + m.lcFileName
		Endif
		lnResult = SQLExec(m.lnConnectionHandle, m.lcSQL, m.lcSQLFileName)
		SQLDisconnect(m.lnConnectionHandle)
	Else
		Return .F.
	Endif

	Return m.lnResult > 0

Endproc


Procedure UseSQLFileFromDictionary(lcFileName, lcSQLFileName)
	* Create an empty cursor from a dictionary of SQL tables (see <GetSQLStructure>

	Local lcExec, lnI, loResult
	loResult = GetSQLStructure(m.lcFileName)
	If 'O' # Vartype(m.loResult)
		Return .F.
	Endif

	lcExec = 'Create cursor ' + m.lcSQLFileName + ' ('
	For lnI = 1 To Alen(m.loResult.aList, 1)
		lcExec = m.lcExec + Iif(m.lnI = 1, '', ',') + m.loResult.aList[m.lnI, 1] + ' ' + m.loResult.aList[m.lnI, 2]
	Endfor
	lcExec = m.lcExec + ')'
	Execscript(m.lcExec)
	Return .T.

Endproc


#Define Table_FieldName     Xtabname
#Define Field_FieldName		Field_Name
#Define Type_FieldName		Field_Type
#Define Length_FieldName	Field_Len
#Define Decimals_FieldName	Field_Dec

Procedure GetSQLStructure(lcEntityName)
	* Sample Procedure that gets the structure for an SQL table

	* The result is a collection, each element containing the field name,
	* then a tab, then the data type and width

	* This procedure uses a dictionary in a local table. It could just
	* as well use SQLColumns to read the structure directly.

	Local laFields[1], laList[1], lcDictionary, lcTableName, lnSelect, lxResult

	lxResult = .F.
	If '.' $ m.lcEntityName
		Return m.lxResult
	Endif

	* Assumes beginning of table name is '_SQL_'
	If Upper(m.lcEntityName) = '_SQL_'
		lcTableName = Substr(m.lcEntityName, 6)
	Else
		lcTableName = m.lcEntityName
	Endif

	lcDictionary = GetOption(ccDictionaryFile, '')
	If File(m.lcDictionary)
		lnSelect = Select()
		Use (m.lcDictionary) Alias DataDictSource In 0 Again Shared

		Select  Lower(Field_FieldName)    As  Field_Name,				;
				Type_FieldName            As  Field_Type,				;
				Length_FieldName          As  Field_Len,				;
				Decimals_FieldName        As  Field_Dec					;
			From DataDictSource											;
			Where Lower(Table_FieldName)  = Lower(m.lcTableName)		;
			Into Array laFields

		If _Tally > 0
			Dimension m.laList[1]
			Execscript(_Screen.cThorDispatcher, 'THOR_PROC_GetFieldNames', @m.laFields, @m.laList, 3)
			lxResult = Createobject('Empty')
			AddProperty(m.lxResult, 'aList[1]')
			Acopy(laList, m.lxResult.aList)
		Endif

		Use In DataDictSource
		Select(m.lnSelect)
	Endif && File(DictionaryTableName)

	Return m.lxResult
Endproc


Procedure GetOption(lcOptionName, lxDefaultValue)
	Return Nvl(Execscript(_Screen.cThorDispatcher, 'Get Option=', m.lcOptionName, ccTool), m.lxDefaultValue)
Endproc


Procedure GetAliasFromFileName(lcFileName)
	Return Chrtran(Juststem(m.lcFileName), ' ', '_')
Endproc


Procedure GetTableForAlias(lcAlias, lcResult)
	* See if this alias is defined in Thor's global alias list
	Local loThor As Thor_Engine Of 'C:\VISUAL FOXPRO\PROGRAMS\MyThor\Thor\Source\Thor.vcx'
	Local lcFileName

	loThor	   = Execscript(_Screen.cThorDispatcher, 'Thor Engine=')
	lcFileName = m.loThor.GetTableForAlias(m.lcAlias)

	If Empty(m.lcFileName)
		Return .F.
	Else
		Return Execscript(_Screen.cThorDispatcher, 'THOR_PROC_GetTableForAlias', m.lcFileName, @m.lcResult)
	Endif
Endproc
