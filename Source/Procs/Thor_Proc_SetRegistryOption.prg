Lparameters lcOptionName, lcNewValue

* Use Regedit ... and see HKEY_CURRENT_USER\Software\Microsoft\VisualFoxPro\9.0\Options

Local loReg
m.loReg = Newobject ( 'FoxReg', Home(1) + 'samples\classes\registry.prg' )

m.loReg.SetFoxOption (m.lcOptionName, m.lcNewValue)
