### The Alias Dictionary

The **Alias Dictionary** provides some very powerful and almost universally overlooked features for getting dropdowns of business objects and data objects.  IntellisenseX provides many features for getting dropdown lists of what are essentially local objects; this is documented elsewhere and available simply by using IntellisenseX.  The Alias Dictionary extends that by recognizing objects that are more "universal" throughout an application.

Here's an example of the Alias Dictionary that we'll use to demonstrate some of the features that are available.

![](Images/Item_47_SampleAliasTable.png)

##### Business Object Examples

* **Example #1** is that of an object that is referenced globally in code.  Here's the definition in the table for one such object named goKTrack:

![](Images/Item_47_goKTrack.png)

The field _Table_ above contains the definition of the class for goKTrack. The curly braces indicate a class definition where the name of the class and the class library are separated by a comma. _(Note: to obtain the contents of the dropdown, the class is instantiated using NewObject, but the Init does not fire.)_ 

![](Images/Item_47_goKTrackExample.png)

* **Example #2** is much like #1, except that the Alias is actually a compound name (i.e., with dots):

![](Images/Item_47_oAppDotoAdmin.png)

* **Example #3** is a generalized version of #2, using wildcards in both the _Alias_ and the the _Table_ fields. The wildcard in the _Table_ field is replaced with whatever matches the wildcard in the _Alias_ field.  Thus, this would cover example #2 as well as handling similar objects like _oApp.oUser_ and any other objects contained in _oApp_.

![](Images/Item_47_oAppDotoStar.png)

* **Example #4** handles a different issue, where an object can be referenced with different (yet very similar) names.

    - `ThisForm.oNAVSQL`
    - `This.oNAVSQL`
    - `loNAVSQL`
    - `toNAVSQL`

![](Images/Item_47_oNAVSQL.png)


![](Images/Item_47_oNAVSQLSample.png)

* **Example #5** is a variant of #3.  In this case, the wildcard is interpreted as a table name and passed to a UDF that returns the business object for that table.  _(Note: The class should be instantiated using NewObject with a third parameter of 0 so that the Init does not fire.)_ 

![](Images/Item_47_loTable.png) 

In this case, the _Table_ field contains an executable expression, indicated by the leading 
'='.

![](Images/Item_47_loTableSample.png) 

##### Other Examples

* **Example #6** is a continuation of #5, where the business object contains a data object.  

![](Images/item_47_loStarDotData.png) 

In this case, the _Table_ field contains just the wildcard (assumed to be the file name)

![](Images/Item_47_loTableStarDotoData.png) 

* **Example #7** handles the case where you have a cursor selected from a table and the cursor name contains the name of the source table.

![](Images/Item_47_crsrStar.png) 

![](Images/Item_47_crsrStarSample.png)  
