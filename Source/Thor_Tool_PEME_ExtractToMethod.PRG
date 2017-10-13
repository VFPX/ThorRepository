* Created: 02/23/12 09:45:02 AM
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
		.Prompt		   = 'Extract To Method' && used when tool appears in a menu
		Text to .Description NoShow
Extracts the currently highlighted block of code into a new method.

You are first prompt for the named of the new method (which may contain both upper and lower case).

The new method is created, the highlighted text is pasted into the new method, and the highlighted text in the original is replaced with a reference to the new method.
		EndText

		* Optional
		.StatusBarText = 'Extracts the currently highlighted block of code into a new method.'
		.Summary       = 'Extracts the currently highlighted block of code into a new method.' && if empty, first line of .Description is used

		* For public tools, such as PEM Editor, etc.
		.Source		   = 'Thor Repository'
		.Sort		   = -1 && the sort order for all items from the same .Source
		.Category      = 'Code|Highlighted Text|Extract to'
		.Link          = 'https://vfpx.codeplex.com/wikipage?title=Thor%20TWEeT%208'
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
   	Execscript (_Screen.cThorDispatcher, 'Thor_Proc_PEME_ExtractToMethod')
EndProc 
