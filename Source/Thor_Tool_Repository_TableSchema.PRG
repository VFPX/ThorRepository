
Lparameters lxParam1

****************************************************************
****************************************************************
* Standard prefix for all tools for Thor, allowing this tool to
*   tell Thor about itself.

If Pcount() = 1                              ;
		And 'O' = Vartype (lxParam1)  ;
		And 'thorinfo' = Lower (lxParam1.Class)

	With lxParam1

		* Required
		.Prompt        = 'Schema' && used when tool appears in a menu
		.Description   = "Print/View the current table's schema" && may be lengthy, including CRs, etc

		* Optional
		.StatusBarText = .Description
		.Summary       = '' && if empty, first line of .Description is used

		* For public tools, such as PEM Editor, etc.
		.Source        = 'Thor Repository' && e.g., 'PEM Editor'
		.Category      = 'Tables'
		.Author        = 'Eric Selje'
		.Version       = '1.3 May 24, 2012'
		.Link          = 'www.saltydogllc.com'
		.CanRunAtStartUp = .F.
    	.PlugIns = 'Open Table'
   	Endwith

	Return lxParam1
Endif

Do ToolCode With lxParam1

Return


****************************************************************
****************************************************************
* Normal processing for this tool begins here.
Procedure ToolCode

	Lparameters lxParam1
	* see	http://vfpx.codeplex.com/wikipage?title=Thor%20Tools%20Object
	LOCAL cDBCUsed
	cDBCUsed = DBC()
	loTools = Execscript (_Screen.cThorDispatcher, 'class= tools from pemeditor')
	loTools.UseHighlightedTable (Set ('Datasession'))

	If Empty (Alias())
		Wait Window "No table selected." Timeout 2
	Else
		oSchemaGenerator=Createobject("Schema")
		oSchemaGenerator.cTable = Dbf()
		If oSchemaGenerator.GenerateSchema()
			oSchemaGenerator.showSchema()
		Endif
	Endif
	SET DATABASE TO (cDBCUsed)
Endproc


Define Class Schema As Custom OlePublic

	cAlias = ""
	cTable = ""
	cFileName = ""
	cSchemaFile = ""
	nSele = 0
	lView = .F.
	cCaption = ""

	Procedure Init
		This.nSele = Select()
	Endproc

	Procedure Destroy
		Set Textmerge To
		Use In Sele("crsSchema")
		If File(This.cSchemaFile)
			Erase (This.cSchemaFile)
			Select (This.nSele)
		Endif
	Endproc


	Procedure Error(nError, cMethod, nLine)
		Wait Window "Error " + Transform(nError) + " in line " + Transform(nLine)+" of " + cMethod + Chr(13) + Message(1)
	Endproc

	Procedure cTable_Assign
		Lparameters cTable

		This.cTable = cTable
		This.cAlias = Alias()
		IF JUSTSTEM(CURSORGETPROP("Database")) != JUSTSTEM(EVL(DBC(),""))
			SET DATABASE TO JUSTSTEM(CURSORGETPROP("Database"))
		ENDIF
		This.cFileName = Addbs(Sys(2023))+This.cAlias+".html"
		If File(This.cFileName)
			* Overwrite it
			cSafety = Set("SAFETY")
			Set Safety Off
			Erase (This.cFileName)
			Set Safety &cSafety
		ENDIF
		This.cSchemaFile = Addbs(Sys(2023))+Sys(2015)+".dbf"
		nSourceType = CursorGetProp("SourceType",This.cAlias)
		This.lView = nSourceType <3
		If This.lView
			This.cCaption = Iif(nSourceType=1,"Local","Remote")+" View: " + This.cAlias
		Else
			This.cCaption = This.cTable
		Endif
		Copy Structure Extended To (This.cSchemaFile)
		Use In Sele("crsSchema")
		Use (This.cSchemaFile) In 0 Alias crsSchema Again Shared

		Return .T.


	Procedure GenerateSchema
		Local lReturn
		Local X, cAttributes, cCaption, cComment, cConnString, cConnection, cDataType
		Local cDataType2, cDefault, cField, cFormat, cInputMask, cValidation, iDbObjects, iTags, lDBC, Y
		lReturn = Not Empty(This.cTable)
		lDBC = Not Empty(Dbc()) And Indbc(This.cAlias,"TABLE")
		If lReturn
			Set Textmerge To (This.cFileName)
			Set Textmerge Delimiters To <<,>>
			TEXT TEXTMERGE NOSHOW
	<html>
	<head>
	 <style>
	<<IIF(FILE("Schema.css"),FILETOSTR("Schema.css"),This.getCSS())>>
	 </style>
	 <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.4.4/jquery.min.js"></script>
	<script>$(document).ready(function(){
	   $("tr:even").css("background-color", "#F4F4A8");
	   $("tr:odd").css("background-color", "#EFF1D1");});
	</script>

	</head>
	<body>
	<h1><<This.cCaption>></h1>
	<table id='tblHeader'>
	<tr><th>Alias</th><th>Database</th><th>Last Updated</th><th>Code Page</th><th>Records</th><th>Fields</th></tr>
	<tr><td><<ALIAS()>></td><td><<EVL(DBC(),'(Free Table)')>></td><td><<LUPDATE()>></td><td><<CPDBF()>></td><td><<TRANSFORM(RECCOUNT(),'999,999,999')>></td><td><<TRANSFORM(FCOUNT(),'99,999')>></td></tr>
			ENDTEXT

			Set Textmerge On Noshow

			If This.lView
		\ <h4>View's Properties</h4>
				cConnection = DBGetProp(This.cAlias,"VIEW","ConnectName")
				IF EMPTY(cConnection)
					cConnString = "(No Connection)"
				ELSE 
					cConnString = DBGetProp(cConnection,"CONNECTION","ConnectString")
				ENDIF
				
		\ <table id='tblView'>
		\ <tr><th>Connection Name</th><td><<cConnection>>&nbsp;[<<cConnString>>] </td></tr>
		\ <tr><th>Parameters</th><td><<This.vp("Parameterlist") >></td></tr>
		\ <tr><th>Tables</th><td><<This.vp("Tables")>> </td></tr>
		\ <tr><th>Comment</th><td><<<<This.vp("Comment") >></td></tr>
		\ <tr><th>SQL</th><td><<This.vp("SQL")>></td></tr>
		\ <tr><th>Properties</th><td>
		\ <table id='tblViewProps'>
		\ <tr><th>Send Updates</th><td><<This.vp("SendUpdates")>></td><th>Compare Memo</th><td> <<This.vp("CompareMemo")>></td><th>Fetch Size</th><td><<This.vp("FetchSize")>></td><th>Use Memo Size</th><td><<This.vp("UseMemoSize")>></td></tr>
		\ <tr><th>Update Type</th><td><<This.vp("UpdateType")>></td><th>Fetch as Needed</th><td> <<This.vp("FetchAsNeeded")>></td><th>Max Records</th><td><<This.vp("MaxRecords")>></td><th>Where Type</th><td><<This.vp("WhereType")>></td></tr>
		\ <tr><th>Batch Update Cnt</th><td><<This.vp("BatchUpdateCount")>></td><th>Fetch Memo</th><td><<This.vp("FetchMemo")>> </td><th>Prepared</th><td><<This.vp("Prepared")>></td><th>Offline?</th><td><<This.vp("Offline")>></td></tr>
		\ </table>
		\ </td></table>
			Endif

	\ <h4>Structure:</h4><table>
	\ <table id='tblSchema'>
			If This.lView
		\ <tr><th>Field Name</th> <th>Data Type</th> <th>Attributes</th> <th>Default</th><th>Upd</th><th>UpdateName</th> <th></th><th></th></tr>
			Else
		\ <tr><th>Field Name</th> <th>Data Type</th> <th>Attributes</th> <th>Default</th><th>Format</th><th>InputMask</th> <th>Validation</th><th>Comment</th></tr>
			Endif
			Select crsSchema
			Scan
				cField = This.cAlias+'.'+field_name
				If This.lView
					Store "" To cCaption, cAttributes, cDefault, cComment, cFormat, cInputMask, cValidation
					cFormat = Iif(DBGetProp(cField,"FIELD","Updatable"),"Yes","")
					cInputMask = DBGetProp(cField,"FIELD","UpdateName")
					cCaption = Iif(DBGetProp(cField,"FIELD","KeyField"),"(Key)","")
					cDefault = DBGetProp(cField,"FIELD","DefaultValue")
					cDataType = This.getField()
					cDataType2 = DBGetProp(cField,"FIELD","DataType")
					If cDataType != cDataType2
						cDataType = cDataType + ' << ' + cDataType2
					Endif

				Else
					cCaption = Iif(lDBC,DBGetProp(cField,"FIELD","Caption"),"")
					cCaption = Iif(Empty(cCaption),""," ("+cCaption+")")
					cAttributes = This.getAttributes()
					cDefault = Iif(lDBC,DBGetProp(cField,"FIELD","Default"),"")
					cComment = Iif(lDBC,DBGetProp(cField,"FIELD","Comment"),"")
					cFormat = Iif(lDBC,DBGetProp(cField,"FIELD","Format"),"")
					cInputMask = Iif(lDBC,DBGetProp(cField,"FIELD","InputMask"),"")
					cValidation = Iif(lDBC,DBGetProp(cField,"FIELD","RuleExpression"),"")
					cDataType = This.getField()
				Endif

		\<tr> <td> <<field_name>> <<cCaption>> </td>
		\\<td><<cDataType>> </td>
		\\<td> <<cAttributes>> </td>
		\\<td> <<cDefault>> </td>
		\\<td> <<cFormat>> </td>
		\\<td> <<cInputMask>> </td>
		\\<td> <<cValidation>> </td>

		\\<td> <<cComment >> </td>
			Endscan
	\</table>
		
			If lDBC AND NOT This.lView
		\ <h4>Table Properties:</h4><table>
				This.writeTableProperty("PrimaryKey")
				This.writeTableProperty("RuleExpression")
				This.writeTableProperty("RuleText")
				This.writeTableProperty("InsertTrigger")
				This.writeTableProperty("UpdateTrigger")
				This.writeTableProperty("DeleteTrigger")
				This.writeTableProperty("Comment")
		\</table>
				iDbObjects = Adbobjects(aDb,"RELATION")
				If Ascan(aDb,Upper(This.cAlias))>0
		\ <h4>Relations:</h4><table>
		\ <tr><th>Related to Table</th><th>on Related Index Tag</th><th>Using Index Tag</th><th>Relation</th></tr>
					For X = 1 To iDbObjects
						* Related to this table
						If aDb[X,2]=Upper(This.cAlias) && This table is a parent table 
				\<tr> <td> <<aDb[X,1]>> </td><td><<aDb[X,3]>> </td><td><<aDb[X,4]>> </td><td>One-to-Many</td></tr>
						Endif
					Next
					For X = 1 To iDbObjects
						* Foreign Keys to other tables
						If aDb[X,1]=Upper(This.cAlias) && This table is a child table 
				\<tr> <td> <<aDb[X,2]>> </td><td><<aDb[X,4]>> </td><td><<aDb[X,3]>> </td><td>Many-to-One</td></tr>
						Endif
					Next
				Endif
		\ </table>
			Endif
			* Indexes
			Select (This.cAlias)
			If Not This.lView
				Dimension aTags[1]
				iTags = Ataginfo(aTags)
				If iTags = 0
			\ No Structural Index Tags
				Else
			\ <h4>Indexes:</h4><table>

			\ <table id='tblIndices'><tr><th>Tag Name</th> <th>Type</th> <th>Expression</th> <th>Filter</th> <th>Order</th> <th>Collation</th></tr>
					For X = 1 To iTags
			\<tr>
						For Y = 1 To 6
					\ <td> <<aTags[X,Y]>>	</td>
						Next
			\</tr>
					Next
				Endif
		\</table>
			Endif

			* Dependencies
	\ <h4>Dependencies:</h4><table>

	\ </body>
			Set Textmerge Off
			Set Textmerge To
		Endif
		Return lReturn

	Function vp
		Lparameters cProperty
		Local cValue
		cValue = DBGetProp(This.cAlias,"View",cProperty)
		If Vartype(cValue)='L'
			cValue=Iif(cValue,'Yes','No')
		Endif

		Return cValue


	Function writeTableProperty
		Lparameters cProperty
		Local cValue
		cValue = DBGetProp(This.cAlias,"Table",cProperty)
		If Not Empty(cValue)
\ <tr><th><<cProperty>>:</th><td> <<cValue>> </td></tr>
		Endif

	Function getAttributes
		Local cReturn
		cReturn = Iif(field_null,", Null","")
		cReturn = cReturn + Iif(field_nocp,", NoCP","")
		cReturn = Substr(cReturn,3)
		Return cReturn


	Function getField
		Lparameters cReturn
		cReturn = field_type
		If Inlist(field_type,'C','N')
			cReturn = cReturn + '('+Transform(field_len)
			If field_dec>0
				cReturn = cReturn + ','+Transform(field_dec)
			Endif
			cReturn = cReturn + ')'
		Endif
		Return cReturn


	Procedure showSchema
		If File(This.cFileName)
			Declare Integer ShellExecute In shell32;
				INTEGER HWnd,;
				STRING  lpOperation,;
				STRING  lpFile,;
				STRING  lpParameters,;
				STRING  lpDirectory,;
				INTEGER nShowCmd
			ShellExecute(_vfp.HWnd, 'open', This.cFileName, '','', 3)
		Endif


	Function getCSS
		* Default CSS, overridden by Schema.css if it exists
\ body {background : beige; font-family : "Arial";}
\ h1 {color : darkblue; font-size : large;}
\ td {text-align : left; font-family: "Courier New"; padding-left : 3px; padding-right : 10px; }
\ th {text-align : left; }
\ h4 {color : darkblue; }
\ table {margin-bottom : 20px; }
\ #tblHeader {width : 80%; align:left;}
\ #tblSchema {width : 100%; border : 0;}
\ #tblIndices {width : 50%;}
\ #tblViewProps {width: 100%;}
		Return ""

Enddefine

