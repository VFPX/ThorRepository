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
		.Prompt		   = 'Browse SQL Data Dictionary' && used in menus

		Text To .Description Noshow
Table of all table and field names in Solomon (updated weekly)
		Endtext
		.Category = 'Tables|SQL Data Dictionary'
		.Link     = 'https://vfpx.codeplex.com/wikipage?title=Thor%20TWEeT%2024'
		.CanRunAtStartup = .F.
		.Author	  = 'JRN'
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

	Local lcFileName
	lcFileName = Execscript(_Screen.cThorDispatcher, 'Get Option=', ccDictionary, ccTool)

	Do Case
		Case Empty(m.lcFileName)
			Messagebox('SQL Data Dictionary File not defined.' + CR + Chr(13) + 'Create using tool "Create SQL Data Dictionary"', 16, 'Dictionary file not found')
		Case Not File(m.lcFileName)
			Messagebox('SQL Data Dictionary File does not exist.' + CR + Chr(13) + 'Create using tool "Create SQL Data Dictionary"', 16, 'Dictionary file not found')
		Otherwise
			Use In (Select ('SQLDataDictionary')) && Close 'SQLDataDictionary'
			Use (m.lcFileName) Shared Again In 0 Alias SQLDataDictionary
			Execscript(_Screen.cThorDispatcher, 'Thor_Proc_SuperBrowse', 'SQLDataDictionary')
	Endcase

Endproc
