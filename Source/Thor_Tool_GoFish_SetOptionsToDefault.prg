Lparameters lxParam1

****************************************************************
****************************************************************
* Standard prefix for all tools for Thor, allowing this tool to
*   tell Thor about itself.

If Pcount() = 1								;
		And 'O' = Vartype(lxParam1)			;
		And 'thorinfo' = Lower(lxParam1.Class)

	With lxParam1

		* Required
		.Prompt             = 'Reset all GoFish options to default' && used when tool appears in a menu
		Text To .Description Noshow
Resets all GoFish options to default by removing the GF_*.XML files files Home(7)
		Endtext
		.PRGName            = 'Thor_Tool_GoFish_SetOptionsToDefault' && a unique name for the tool; note the required prefix

		* For public tools, such as PEM Editor, etc.
		.Category = 'Applications|GoFish'
		.Source	  = 'GoFish' && Deprecated; use .Category instead
		.Author	  = 'Matt Slay'
		.Sort	  = 10 && the sort order for all items from the same .Source
		.Link	  = 'http://vfpx.codeplex.com/wikipage?title=GoFish'
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

	Local lcFolder, lnMsgBoxAns, loException
	lnMsgBoxAns = Messagebox('Reset all options for GoFish to their default values?' + Chr(13) + '' + Chr(13) + 'This is done by removing all GF*.XML files from Home(7).', 35, 'Set GoFish options to default')
	Do Case
		Case lnMsgBoxAns = 6 && Yes
			lcFolder = Home(7)
			Try
				Erase(Addbs(lcFolder) + 'GF*.XML')
				Messagebox('All options for GoFish have been reset to default', 48, 'GoFish options reset')
			Catch To loException
				lnMsgBoxAns = Messagebox('Unable to erase all files - ' + loException.Message, 16, 'Error')
			Endtry

		Case lnMsgBoxAns = 7 && No

		Case lnMsgBoxAns = 2 && Cancel

	Endcase

Endproc
