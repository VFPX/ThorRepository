* Registered with Thor: 02/15/14 07:46:14 PM
Lparameters lxParam1

****************************************************************
****************************************************************
* Standard prefix for all tools for Thor, allowing this tool to
*   tell Thor about itself.

If Pcount() = 1								;
		And 'O' = Vartype (m.lxParam1)		;
		And 'thorinfo' = Lower (m.lxParam1.Class)

	With m.lxParam1

		* Required
		.Prompt             = 'Set Object Size and Position' && used when tool appears in a menu
		Text To .Description Noshow
Opens the 'Size and Position' form for changing the size and position of objects.
		Endtext
		.PRGName            = 'Thor_Tool_PEME_SetCloseSizeandPosition' && a unique name for the tool; note the required prefix

		* Optional
		Text To .StatusBarText Noshow
Opens the 'Size and Position' form for changing the size and position of objects.
		Endtext
		Text To .Summary Noshow && if empty, first line of .Description is used
Opens the 'Size and Position' form for changing the size and position of objects.
		Endtext

		* For public tools, such as PEM Editor, etc.
		.Category = 'Objects and PEMs'
		.Sort	  = 420 && the sort order for all items from the same .Source
		.Link	  = 'http://vfpx.codeplex.com/wikipage?title=PEMEditor%20Tools%20Object%20Size%20and%20Position'
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

	Local loForm

	If Type('_Screen.oFormatMenu') = 'O' And Vartype(_Screen.oFormatMenu) = 'O'
		loForm = _Screen.oFormatMenu
	Else
		loForm = Execscript(_Screen.cThorDispatcher, 'Class= FRMFORMATMENU of Thor_Proc_FORMATMENU.VCX')
		_Screen.AddProperty('oFormatMenu', m.loForm)
	Endif

	m.loForm.Show()

Endproc
