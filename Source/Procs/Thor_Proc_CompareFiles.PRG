Lparameters lcFile1, lcFile2

Local lcCompareEXE, lcText

lcCompareEXE = 'C:\Program Files (x86)\Beyond Compare 4\BCompare.exe'
lcText		 = Textmerge([Run /n "<<lcCompareEXE>>" "<<lcFile1>>" "<<lcFile2>>"])

Execscript(m.lcText)
