* This program should perform any build tasks necessary for the project, such
* as  versions numbers in code or include files. This program can use the public
* variables discussed in the documentation as necessary.
CreateDocumentationDirectory()

Return

#Define Tab Chr[9]
#Define CR Chr[13]
#Define lf Chr[10]
#Define CRLF + CR + lf


Procedure CreateDocumentationDirectory
	Local laMDFiles[1], laTXTFiles[1], lcContents, lcDirectoryFile, lcFileName, lcFolder, lnFileCount
	Local lnI

	lcFolder		= 'docs\'
	lcDirectoryFile	= m.lcFolder + 'Directory.txt'
	Strtofile('', m.lcDirectoryFile, .F.)

	lnFileCount = Adir(laMDFiles, m.lcFolder + 'Thor_Tool_*.md')
	For lnI = 1 To m.lnFileCount
		lcFileName = m.laMDFiles[m.lnI, 1]
		Strtofile(ForceExt(m.lcFileName, 'PRG') + Tab + Justext(m.lcFileName) + CRLF, m.lcDirectoryFile, .T.)
	Endfor

	lnFileCount = Adir(laTXTFiles, m.lcFolder + 'Thor_Tool_*.txt')
	For lnI = 1 To m.lnFileCount
		lcFileName = m.laTXTFiles[m.lnI, 1]
		lcContents = Filetostr(m.lcFolder + m.lcFileName)
		lcContents = Alltrim(Strtran(m.lcContents, 'Link =', '', 1, 1, 1), ' ', CR, lf)
		Strtofile(ForceExt(m.lcFileName, 'PRG') + Tab + Justext(m.lcFileName) + Tab + m.lcContents + CRLF, m.lcDirectoryFile, .T.)
	Endfor

Endproc
