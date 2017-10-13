* Created: 05/29/12 03:25:12 PM
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
		.Prompt		   = 'Edit Settings for IDE Tools' && used when tool appears in a menu
		Text to .Description NoShow
Edit Preference Settings for PEM Editor with IDE Tools                                              
		EndText
		.PRGName       = 'Thor_Tool_PEME_EditHotKeysPreferences' && a unique name for the tool; note the required prefix

		* Optional
		.StatusBarText = 'Edit Preference Settings for PEM Editor with IDE Tools'
		.Summary       = 'Edit Preference Settings for PEM Editor with IDE Tools' && if empty, first line of .Description is used

		* For public tools, such as PEM Editor, etc.
		.Source		   = 'IDE Tools' && e.g., 'PEM Editor'
		.Author  	   = '' 
		.Sort		   = 630 && the sort order for all items from the same .Source
		.Category      = 'Settings & Misc.'
		.SubCategory   = ''
		.Link          = ''
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
	ExecScript(_Screen.cThorDispatcher)
	_Screen.oThorUI.OpenOptionsPage()
EndProc 
