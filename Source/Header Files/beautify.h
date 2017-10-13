#DEFINE E_STRING1_LOC 		"Could not find FDKEYWRD table"
#DEFINE E_STRING2_LOC 		"Could not find FD3.FLL library"
#DEFINE WHEREIS_LOC	 		"Where is "

#DEFINE EDENV_FILENAME      1
#DEFINE EDENV_LENGTH		2
#DEFINE EDENV_READONLY		12
#DEFINE EDENV_SELSTART		17
#DEFINE EDENV_SELEND		18

#Define INLINECOMMENTS		("&" + "&")
#Define CR 					Chr[13]
#Define LF					Chr(10)
#Define CRLF				CR + LF
#Define TAB					Chr(9)
#Define BLANKS				' ' + Tab
#Define ISABLANK 			$ BLANKS
#Define LINEEND				CR + LF
* list of characters that can't be part of a name assigned a value;
* note that period (.) is not in the list, intentionally

* Values not important, but will be displayed in this order
* and anything in more than one category will appear in lowest
#Define TYPE_Constants		 5
#Define TYPE_Parameters		10
#Define TYPE_Locals			15
#Define TYPE_Tables			20
#Define TYPE_Forms			30
#Define TYPE_Assignments	40
#Define TYPE_Procedures		50
#Define TYPE_Methods		60
#Define TYPE_PropAssign		70
#Define TYPE_Objects		80
#Define TYPE_Fields			90
#Define TYPE_Others			99

#Define ASDATATYPE_CHARS	'WCYDTBFGILMNQV'
