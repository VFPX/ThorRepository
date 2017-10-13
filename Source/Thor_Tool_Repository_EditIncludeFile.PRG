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
		.Prompt	 = 'Go To Include file' && used when tool appears in a menu
		.Summary = 'Edits the include file for the currently open form/class'

		* Optional
		.Description   = '' && a more complete description; may be lengthy, including CRs, etc
		.StatusBarText = ''

		* These are used to group and sort tools when they are displayed in menus or the Thor form
		.Source		 = 'Thor Repository' && where did this tool come from?  Your own initials, for instance
		.Category	 = 'Go To' && allows categorization for tools with the same source
		.SubCategory = '' && and sub-categorization
		.Sort		 = 0 && the sort order for all items from the same Source, Category and Sub-Category

		* For public tools, such as PEM Editor, etc.
		.Version		 = '' && e.g., 'Version 7, May 18, 2011'
		.Author			 = 'Jim Nelson'
		.CanRunAtStartUp = .F.

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

	Local loContextMenu As ContextMenu Of 'C:\VISUAL FOXPRO\PROGRAMS\MyThor\Thor\Source\Thor_Menu.vcx'
	Local lcFile, lcIncludeFile, lnI, loConstants, loTools

	* tools home page = http://vfpx.codeplex.com/wikipage?title=thor%20tools%20object
	* ContextMenu home page = http://vfpx.codeplex.com/wikipage?title=Thor%20Framework%20ContextMenu

	loConstants = Execscript(_Screen.cThorDispatcher, 'Thor_Proc_ZDef')
	Do Case
		Case loConstants.FileList.Count = 0
			Messagebox('No #Include statements found', 16, 'Not found')
			Return
		Case loConstants.FileList.Count = 1
			lcIncludeFile = loConstants.FileList[1]
		Otherwise
			loContextMenu = Execscript(_Screen.cThorDispatcher, 'Class= ContextMenu')
			For lnI = 1 To loConstants.FileList.Count
				lcFile = loConstants.FileList[lnI]
				loContextMenu.AddMenuItem('\<' + Justfname(lcFile), , , , lcFile)
			Endfor
			If loContextMenu.Activate()
				lcIncludeFile = loContextMenu.Keyword
			Else
				Return
			Endif
	Endcase

	loTools = Execscript (_Screen.cThorDispatcher, 'Class= tools from pemeditor')
	loTools.EditSourceX (lcIncludeFile)

Endproc


