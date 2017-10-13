*– Set the following constants to match your personal color preferences.
#Define ccTool 'Toggle Comment Colors'

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
		.Prompt	 = 'Toggle comment colors'
		.Summary = 'Toggle color for comments in edit windows'
		Text To .Description Noshow
Toggle the color for comments in code windows between bright and dim.
		Endtext
		* For public tools, such as PEM Editor, etc.
		.Source		   = 'Thor Repository'
		.Category	   = 'Code|Miscellaneous|Colors for code windows'
		.Author		   = 'Matt Slay'
		.Link		   = 'http://mattslay.com/the-color-of-your-comments/'
		.OptionClasses = 'clsToggleComments'
		.OptionTool		  = ccTool
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


	* Modified version obtained from link noted above (so that changes to colors are clearer
	* Could also be modified to reference any of the colors in editor windows
	*
	* EditorCommentColor   
	* EditorKeywordColor   
	* EditorConstantColor  
	* EditorNormalColor    
	* EditorOperatorColor  
	* EditorStringColor    

	#Define COMMENT_COLOR [RGB(Colors), NoAuto, NoAuto]

	Local lcCommentColors, lcCurrentColor, lcDimColor, lcNew, lcNewColor, lcRGB
	lcCurrentColor = Execscript(_Screen.cThorDispatcher, 'Thor_Proc_GetRegistryOption.prg', 'EditorCommentColor')
	lcRGB		   = Strextract(lcCurrentColor, '(', ')', 1)

	lcCommentColors	= ExecScript(_Screen.cThorDispatcher, "Get Option=", ccTool, ccTool)
	If Empty(lcCommentColors)
		lcCommentColors = '(' + lcRGB + ')(192,192,192,255,255,255)'
		ExecScript(_Screen.cThorDispatcher, "Set Option=", ccTool, ccTool, lcCommentColors)
	Endif
	lcNewColor = Strextract(lcCommentColors, '(', ')', 1)
	lcDimColor = Strextract(lcCommentColors, '(', ')', 2)

	*– Check which comment color scheme is being used. If the "dim"
	*– colors are being used, toggle to "bright" colors, and vice versa.
	If lcRGB # lcDimColor
		lcNewColor = lcDimColor
	Endif
	lcNew = Strtran(COMMENT_COLOR, 'Colors', lcNewColor)

	*– Set and apply the new comment color.
	Execscript(_Screen.cThorDispatcher, 'Thor_Proc_SetRegistryOption.prg', 'EditorCommentColor', lcNew)
	Sys(3056, 1)
Endproc


Define Class clsToggleComments As Custom

	Tool		  = ccTool
	Key			  = ccTool
	Value		  = ''
	EditClassName = 'ToggleColors of Thor_Options_ToggleCommentColors.VCX'

Enddefine

