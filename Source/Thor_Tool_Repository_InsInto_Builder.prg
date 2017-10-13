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
		.Prompt	 = 'INSERT INTO from cursor Wizard ' && used when tool appears in a menu
		.Summary = 'Creates INSERT INTO from cursor'

		* Optional
		.Description   = 'Puts a INSERT INTO statement on the clipboard from an open cursor' && a more complete description; may be lengthy, including CRs, etc
		.StatusBarText = ''

		* These are used to group and sort tools when they are displayed in menus or the Thor form
		.Source		 = 'Thor Repository' && where did this tool come from?  Your own initials, for instance
		.Category	 = 'Tables' && allows categorization for tools with the same source
		.SubCategory = '' && and sub-categorization
		.Sort		 = 0 && the sort order for all items from the same Source, Category and Sub-Category

		* For public tools, such as PEM Editor, etc.
		.Version = 'Version 1.1, December 2, 2011'
		.Author	 = 'Zdenek Krejci'
		.Sort    = 20
		.CanRunAtStartUp = .F.
	    .PlugIns = 'Open Table'
	Endwith

	Return lxParam1
Endif

Do ToolCode 

Return


****************************************************************
****************************************************************
* Normal processing for this tool begins here.                  
Procedure ToolCode
	Local lcFormFileName
	lcFormFileName = Execscript (_Screen.cThorDispatcher, 'Full Path=Thor_Tool_Repository_InsInto_Builder.SCX')
	Do Form (lcFormFileName)
	Return
Endproc
*Thor_Tool_Repository_InsInto_Builder     