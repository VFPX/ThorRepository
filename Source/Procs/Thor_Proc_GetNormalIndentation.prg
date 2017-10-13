Local lcResult
If Execscript (_Screen.cThorDispatcher, 'Thor_Proc_BeautifyOption', 4) = 1
	lcResult =  Chr[9]
Else
	lcResult = Space (Execscript (_Screen.cThorDispatcher, 'Thor_Proc_BeautifyOption', 3))
Endif

Return Execscript (_Screen.cThorDispatcher, 'Result=', lcResult)