Lparameters lcOptionName

* Use Regedit ... and see HKEY_CURRENT_USER\Software\Microsoft\VisualFoxPro\9.0\Options

Local lcOption, loReg
m.lcOption = ''

*	m.loReg = Newobject ( 'FoxReg', Home(2) + 'classes\registry.prg' )

m.loReg = Newobject ( 'FoxReg', Addbs(JustPath(Sys(16))) + 'Thor_Proc_Registry.prg' )

If m.loReg.GetFoxOption (m.lcOptionName, @m.lcOption) = 0
	Execscript (_Screen.cThorDispatcher, 'Result=', m.lcOption)
Else
	Execscript (_Screen.cThorDispatcher, 'Result=', .Null.)
Endif
