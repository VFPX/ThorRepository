#Define ccHandlersEnabled _oPEMEditor.oPrefs.lEventHandlersEnabled
#Define ccCR Chr(13)

Lparameters lxParam1

****************************************************************
****************************************************************
* Standard prefix for all tools for Thor, allowing this tool to
*   tell Thor about itself.

Local laProjects[1]
If Pcount() = 1								;
		And 'O' = Vartype (m.lxParam1)		;
		And 'thorinfo' = Lower (m.lxParam1.Class)

	With m.lxParam1

		* Required
		.Prompt		 = 'Toggle PEM Editor Event Handler'
		Text To .Description Noshow Textmerge
PEM Editor, if open, provides design time event handing. The most familiar use is evaluating the Anchor properties when resizing controls so that a form or class resizes as it would at run time. See the PEM Editor help file for more on this.    
		Endtext

		* For public tools, such as PEM Editor, etc.
		.Category           = 'Applications|PEM Editor'
		.CanRunAtStartUp = .F.
	Endwith

	Return m.lxParam1
Endif

****************************************************************
****************************************************************
* Normal processing for this tool begins here.

If Not (Type('_opemeditor.outils.oPEMEditor') = 'O' And Vartype(_oPEMEditor.Outils.oPEMEditor) = 'O')
	Execscript(_Screen.cThorDispatcher, 'Thor_Tool_PEME_LaunchPEMEditor')
	ccHandlersEnabled = .T.
Else
	ccHandlersEnabled = Not m.ccHandlersEnabled
Endif

Messagebox('Event Handlers ' + Iif(m.ccHandlersEnabled, 'enabled', 'disabled'))


