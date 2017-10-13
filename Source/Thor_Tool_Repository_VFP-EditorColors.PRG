Lparameters lxParam1

****************************************************************
****************************************************************
* Standard prefix for all tools for Thor, allowing this tool to
*   tell Thor about itself.

If Pcount() = 1						  ;
		And 'O' = Vartype (lxParam1)  ;
		And 'thorinfo' == Lower (lxParam1.Class)

	With lxParam1
	
		* Required
		.Prompt	 = 'Enhanced color editor'
		Text To .Description Noshow
Enhanced editor for colors used in VFP code windows
		Endtext
		* For public tools, such as PEM Editor, etc.
		.Source		   = 'Thor Repository'
		.Category	   = 'Code|Miscellaneous|Colors for code windows'

		* These are used to group and sort tools when they are displayed in menus or the Thor form
		.Sort		   = 10 && the sort order for all items from the same Category
		
		* For public tools, such as PEM Editor, etc.
		.Version	   = '' && e.g., 'Version 7, May 18, 2011'
		.Author        = 'Matt Weinbender'
		.CanRunAtStartup = .F.
		.Link          = '' && link to a page for this tool
		.VideoLink     = '' && link to a video for this tool
		
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
		lcFormName = ExecScript(_Screen.cThorDispatcher, "Full Path= thor_proc_vfp-editorcolors.SCX")
		Do form (lcFormName)
EndProc 
