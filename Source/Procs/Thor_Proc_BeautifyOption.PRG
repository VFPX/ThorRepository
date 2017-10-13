Lparameters lnOption

Local lcDisplay, lcOptions, lcTempFile, lnI, lnSelect, loBeautifyOptions

lnSelect = Select()
Select 0

lcOptions =								 ;
	Chr(3) + Chr(0) + Chr(0) + Chr(0) +	 ;
	Chr(3) + Chr(0) + Chr(0) + Chr(0) +	 ;
	Chr(4) + Chr(0) + Chr(0) + Chr(0) +	 ;
	Chr(1) + Chr(0) + Chr(0) + Chr(0) +	 ;
	Chr(0) + Chr(0) + Chr(0) + Chr(0) +	 ;
	Chr(0) + Chr(0) + Chr(0) + Chr(0) +	 ;
	Chr(1) + Chr(0) + Chr(0) + Chr(0) +	 ;
	Chr(0) + Chr(0) + Chr(0) + Chr(0) +	 ;
	Chr(0) + Chr(0) + Chr(0) + Chr(0)

If Set ('Resource') = 'ON'
	Use (Set ('Resource', 1)) Again Shared Alias crsr_Resource
	Locate For Id = 'BEAUTIFY'
	If Found()
		lcOptions = Right (Data, 36)
	Endif
	Use
Endif

loBeautifyOptions = Createobject ('Collection')
For lnI = 1 To 9
	loBeautifyOptions.Add (Asc (Substr (lcOptions, (4 * lnI) - 3, 1)))
Endfor

Select (lnSelect)


Do Case
	Case Type ('lnOption') = 'N' And Between (lnOption, 1, 9)
		Execscript (_Screen.cThorDispatcher, 'Result=', loBeautifyOptions[lnOption])
	Case Not Empty (lnOption)
		Execscript (_Screen.cThorDispatcher, 'Result=', loBeautifyOptions)

	Otherwise
		Text To lcDisplay Noshow Textmerge
    1 = Variable case [<<loBeautifyOptions(1)>>] 
          1 = UPPER, 2 = lower, 3 = Use First, 4 = No change
    2 = Command case [<<loBeautifyOptions(2)>>] 
          1 = upper, 2 = lower, 3 = mixed
    3 = Number of spaces if option 4 (below) is 2 [<<loBeautifyOptions(3)>>] 
    
    4 = Tabs or spaces? [<<loBeautifyOptions(4)>>] 
          1 - use tabs, 2 - use spaces, 3 = no change
    5 =  ??
    
    6 = Comments? [<<loBeautifyOptions(6)>>] 
          1 = include comments, 0 = no
    7 = Line continuation? [<<loBeautifyOptions(7)>>] 
          1 = include, 0 = no
    8 = Extra indent beneath procedures? [<<loBeautifyOptions(8)>>] 
          1 = yes, 0 = no
	9 = Extra indent beneath Do Case? [<<loBeautifyOptions(9)>>] 
          1 = yes, 0 = no
		Endtext

		lcTempFile = Sys(2023) + Sys(2015) + '.txt'
		Strtofile (lcDisplay, lcTempFile)
		Modify File (lcTempFile) Nowait

Endcase


Return
