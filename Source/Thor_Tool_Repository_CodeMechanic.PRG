Lparameters lxParam1

****************************************************************
****************************************************************
* Standard prefix for all tools for Thor, allowing this tool to
*   tell Thor about itself.

If Pcount() = 1						  ;
		And 'O' = Vartype (lxParam1)  ;
		And 'thorinfo' = Lower (lxParam1.Class)

	#Define crlf Chr(13)+Chr(10)
	With lxParam1

		* Required
		.Prompt	 = 'Code Mechanic'
		.Summary = 'Beautify, add locals and fix m.dot'

		* Optional
		Text to .Description NoShow
Fixes up many files in one run by executing one or more of
   1. BeautifyX
   2. Add Locals
   3. Add M.DOTs
 
Files may be selected from a project or a folder.
 		EndText
		.StatusBarText = ''

		* These are used to group and sort tools when they are displayed in menus or the Thor form
		.Source	  = 'Thor Repository' && where did this tool come from?  Your own initials, for instance
		.Category = 'Code|Miscellaneous' && and sub-categorization
		.Sort	  = 10 && the sort order for all items from the same Source, Category and Sub-Category

		* For public tools, such as PEM Editor, etc.
		.Version = '1.0 Beta' && e.g., 'Version 7, May 18, 2011'
		.Author	 = 'Tore Bleken'
		.CanRunAtStartUp = .F.

	Endwith

	Return lxParam1
Endif

Do ToolCode

Return


****************************************************************
****************************************************************
* Normal processing for this tool begins here.                  
Procedure ToolCode (lcThisFolder)
	Local lcFormFileName
	lcFormFileName = Execscript (_Screen.cThorDispatcher, 'Full Path=Thor_Tool_Repository_CodeMechanic.SCX')
	Do Form (lcFormFileName)
Endproc
