Lparameters lxParam1

****************************************************************
****************************************************************
* Standard prefix for all tools for Thor, allowing this tool to
*   tell Thor about itself.

If Pcount() = 1								;
		And 'O' = Vartype (lxParam1)		;
		And 'thorinfo' == Lower (lxParam1.Class)

	With lxParam1

		* Required
		.Prompt		   = 'Use and Select highlighted table'
		.AppID 		   = 'ThorRepository'

		Text To .Description Noshow
Use and Select highlighted table
		Endtext
		.Category = 'Tables'
		.Author	  = 'JRN'
		.PlugIns   = 'Open Table'

	Endwith

	Return lxParam1
Endif

If Pcount() = 0
	Do ToolCode
Else
	Do ToolCode With lxParam1
Endif

Return

****************************************************************
****************************************************************
* Normal processing for this tool begins here.                  
Procedure ToolCode
	Lparameters lxParam1

	* tools home page = http://vfpx.codeplex.com/wikipage?title=thor%20tools%20object
	Local loTools
	loTools = Execscript(_Screen.cThorDispatcher, 'class= tools from pemeditor')
	loTools.UseHighlightedTable(Set('Datasession'))

Endproc
