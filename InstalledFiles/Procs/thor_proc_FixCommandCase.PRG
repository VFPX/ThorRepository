Lparameters lcCommand

Local lcResult, lnCommandCase

lnCommandCase = Execscript(_Screen.cThorDispatcher, 'Thor_Proc_BeautifyOption', 2)
Do Case
	Case m.lnCommandCase = 1
		lcResult = Upper(m.lcCommand)
	Case m.lnCommandCase = 2
		lcResult = Lower(m.lcCommand)
	Otherwise
		lcResult = m.lcCommand
Endcase

Return Execscript(_Screen.cThorDispatcher, 'Result= ', m.lcResult)