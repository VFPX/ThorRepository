Lparameters lcFileName

Local lcCommand
Do Case
	Case Empty(lcFileName)
		lcCommand = ''
	Case Directory(lcFileName)
		lcCommand = Fullpath(lcFileName)
	Case File(lcFileName)
		lcCommand = '/select, ' + Fullpath(lcFileName)
	Otherwise
		lcCommand = ''
Endcase

Run /N "Explorer" &lcCommand
