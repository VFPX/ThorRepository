Lparameters lcHighLightedText, lcWindowType

Local lcResult

lcResult = Execscript(_Screen.cThorDispatcher, 'Thor_Proc_GetIntellisenseScript', m.lcHighLightedText, m.lcWindowType)
Return Execscript(_Screen.cThorDispatcher, 'Result=', m.lcResult)