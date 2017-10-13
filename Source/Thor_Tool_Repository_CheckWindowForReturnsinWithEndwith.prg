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
		.Prompt		   = 'Find RETURNs between WITH/ENDWITH and TRY/CATCH' && used in menus

		* Optional
		Text To .Description Noshow && a description for the tool
Checks curent code window for RETURN statements between WITH/ENDWITH and TRY/CATCH.

Returns between WITH/ENDWITH can create latent C5 errors.

Returns between TRY/CATCH will fail (not allowed).
		Endtext
		.StatusBarText	 = ''
		.OptionClasses	 = 'clsReturns, clsBeautifyX'
		.OptionTool		 = 'RETURNs between WITH/ENDWITH'
		.CanRunAtStartUp = .F.

		* These are used to group and sort tools when they are displayed in menus or the Thor form
		.Category      = 'Code|WITH/ENDWITH' && creates categorization of tools; defaults to .Source if empty

		* For public tools, such as PEM Editor, etc.
		.Author        = 'Jim Nelson'

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

	ExecScript(_screen.Cthordispatcher, 'Thor_Proc_CheckWindowForReturns')

Endproc


****************************************************************
****************************************************************
#Define		ccContainerName			'clsReturnsContainer'
#Define		ccToolName				'RETURNs between WITH/ENDWITH'

#Define		ccKeyMessageLevel		'Message Level'
#Define		ccKeyInBeautifyX		'BeautifyX'

Define Class clsReturns As Custom

	Tool		  = ccToolName
	Key			  = ccKeyMessageLevel
	Value		  = 1
	EditClassName = ccContainerName

Enddefine

Define Class clsBeautifyX As Custom

	Tool		  = ccToolName
	Key			  = ccKeyInBeautifyX
	Value		  = .F.
	EditClassName = ccContainerName

Enddefine

****************************************************************
****************************************************************
Define Class clsReturnsContainer As Container

	Procedure Init
		Local lcCaption, loRenderEngine
		loRenderEngine = Execscript(_Screen.cThorDispatcher, 'Class= OptionRenderEngine')

		Text To loRenderEngine.cBodyMarkup Noshow Textmerge

			.Class	  		  = 'Label'
			.Caption		  = 'Informative messages:'
			.AutoSize		  = .T.
			.FontBold		  = .T.
			.Margin-Left	  = 30
			|
			.Name			  = 'optUsage'
			.Class			  = 'optiongroup'
			.cTool	  		  = ccToolName
			.cKey	          = ccKeyMessageLevel
			.Margin-Top       = -10
			.cCaptions		  = 'Always\\If any matches found\\Only if more than one match found.\n(If one found, it will be highlighted.)'
			|
			.Class	  = 'CheckBox'
			.Caption  = 'Check for RETURNs between WITH/ENDWITH as part of BeautifyX'
			.cTool	  = ccToolName
			.cKey	  = ccKeyInBeautifyX
			.Width    = 300
			.WordWrap = .T.

		Endtext

		loRenderEngine.Render(This, ccToolName)

	Endproc

Enddefine

