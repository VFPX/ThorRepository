Lparameters tuPara

Do Case
	*	Case M.tuPara.Mode == 0  && Code References from the VFP Tools Menu

	Case M.tuPara.Mode == 1  && "View Definition" from the Code Editor right click menu
		If Type ('_Screen.cThorDispatcher') = 'C'
			Execscript (_Screen.cThorDispatcher, 'Thor_Tool_PEME_GoToDefinition')
		Else
			Messagebox ('Thor is not active; this tool requires Thor', 16, 'Thor is not active', 0)
		Endif

	Case M.tuPara.Mode == 2  && "Look Up Reference" from the Code Editor right click menu
		If Type ('_Screen.cThorDispatcher') = 'C'
			Execscript (_Screen.cThorDispatcher, 'Thor_Tool_Repository_GoToGoFish4.PRG')
		Else
			Messagebox ('Thor is not active; this tool requires Thor', 16, 'Thor is not active', 0)
		Endif

	Otherwise
		Do (_Screen.cOldFoxRefValue) With M.tuPara
Endcase
