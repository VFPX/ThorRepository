* Opens the options page for a tool
Lparameters lcTool

Local loForm
Execscript(_Screen.Cthordispatcher)
loForm = _Screen.oThorUI.OpenOptionsPage(lcTool)

