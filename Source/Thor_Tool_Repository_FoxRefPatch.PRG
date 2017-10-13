#Define RestoreLookUpRefMsg '"Look up Reference" has been restored to its previous version.'
#Define RestoreViewDefMsg '"View Definition"  has been restored to its previous version.'

#Define LookUpRefMsg '"Look up Reference" option re-assigned to use "GoFish".'
#Define ViewDefMsg '"View Definition" option re-assigned to use "Go To Definition".'

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
		.Prompt	 = 'Replace code window context menu items'
		.Summary = 'Replace "View Definition" with Go To Definition, "Look up Reference" with "GoFish"'

		* Optional
		Text To .Description Noshow
Updates the _FoxRef system variable so that two options in the context menu in a code window use Thor tools instead:
      "View Definition"   uses "Go To Definition"
      "Look up Reference" uses "GoFish"

This will not affect the use of Code References from the VFP Tools Menu.

This only needs to be executed once IDE session. The recommended way to do this is to check "Run at startup" (above).
		Endtext
		.StatusBarText = .Summary

		* These are used to group and sort tools when they are displayed in menus or the Thor form
		.Source		 = 'Thor Repository' && where did this tool come from?  Your own initials, for instance
		.Category	 = 'Code|Miscellaneous' && allows categorization for tools with the same source
		.SubCategory = '' && and sub-categorization
		.Sort		 = 30 && the sort order for all items from the same Source, Category and Sub-Category

		* For public tools, such as PEM Editor, etc.
		.Version = 'Version 1.2 February 28 2012'
		.Author	 = 'Ian Simcock'

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

	Local lcMyName

	If Empty (Execscript (_Screen.cThorDispatcher, 'Full Path=Thor_TOOL_GoFish4'))

		Messagebox ('GoFish is not installed; unable to proceed', 16, 'GoFish not installed', 0)

	Else

		lcMyName = Execscript (_Screen.cThorDispatcher, 'Full Path=Thor_Proc_Repository_FoxrefPatch.')
		If _FoxRef == M.lcMyName And Not lxParam1  && If it's pointing to me and it's not AutoRun
			_FoxRef = _Screen.cOldFoxRefValue
			Messagebox (RestoreLookUpRefMsg + Chr[13] + RestoreViewDefMsg,  ;
				  '_FoxRef Updated', 64)
		Else
			If Not _FoxRef == M.lcMyName
				* If _FoxRef currently doesn't point to this then save it so we can restore it if needed.
				_Screen.AddProperty ('cOldFoxRefValue', _FoxRef)  && Both Updates and adds it.
				_FoxRef = M.lcMyName
			Endif
			If lxParam1
				*!* * Removed 3/1/2012 
				*!* Activate Screen
				*!* ? ViewDefMsg
				*!* ? LookUpRefMsg
			Else
				Messagebox (ViewDefMsg + Chr[13] + LookUpRefMsg,  ;
					  '_FoxRef Updated', 64)
			Endif
		Endif
	Endif

Endproc
