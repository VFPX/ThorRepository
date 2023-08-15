SuperBrowse
===

![](Images/Thor_SuperBrowse1.jpg)

### Left Pane

The left pane shows a grid with the data structure of the table. The fields are listed in alphabetical order. The order can be changed by clicking one of the headers.

Click on the fields listed in the grid to mark those you wish to "process".

Click a column header to change the field order.

Below the grid are two buttons:

**Button** |**Description**
---|---
Save Selections|Saves the current selections so that the next time you open this table the same fields will be selected.
Show Schema|Opens a detailed description about the table in your browser.

### Grid page:

This page is an advanced grid.

Click a column header to sort the table. 

Double-click any record to open it for editing, or viewing if "Read-Only" is checked, in a separate window created by Dynamic Forms. 

![](Images/Thor_SuperBrowse2.jpg)
#### Filtering the grid:

**Radio Button** |**Description**
---|---
Expression|For entry of a valid filter expression (SET FILTER TO).
Value|For entry of text string(s), separated by spaces or commas, to be found in character fields.  

#### Searching by Expression

Enter a value filter expression, that is, one that you would use in SET FILTER TO.  This expression is case sensitive.  

##### Sample Usage for Option Type = 'Expression"
**Option type** |**Entered value**|**Description**
|---|---|---|
Expression|Name='Jim' or Name = 'Tore'|Self explanatory
Expression|Obsolete|Finds every record where logical field Obsolete is .T.
Expression|Inlist(CustNo, 10, 20, 30)|Self explanatory
Expression|'nit' $ Country|Finds every record where 'nit' is inside the field Country

#### Searching by Value

Searching by value allows you to search for text string(s), separated by spaces or commas, in character fields.  Searching is done in the character or memo fields selected in the left panel, if any, else all character or memo fields. **This search is not case sensitive.**

A match is found if **each** of the strings entered are found in any of the character fields.  This is **and** logic.  There are some alternatives, see the samples below.

#### Sample Usage for Option Type = 'Value'
**Option type** |**Entered value**|**Description**
|---|---|---|
Value|USA|Finds every record where the string 'usa' is found in any of the selected fields.
Value|USA Canada|Finds every record where the strings 'usa' **and** 'canada' are each found in any of the selected fields
Either|\|USA Canada|Finds every record where either of the strings 'usa' **or** 'canada' are found in any of the selected fields
Either|$Grand Rapids|Treats "Grand Rapids" as a single entry. Thus, it finds every record where the string 'Grand Rapids' if found in any of the selected fields. 

#### Sample Usage, ignoring the value of "Option Type" selection

You can over-ride the value of "Option Type" by prefixing your entry with these single characters

**Character** |**Description**
|---|---|
= | a filter expression
^ | a value expression, using **and** logic if multiple fields entered
\| | a value expression, using **or** logic if multiple fields entered
$ | a value expression where the remainder of the string is treated as a single entry.

**Option type** |**Entered value**|**Description**
|---|---|---|
Ignored|= Name='Jim' or Name = 'Tore'|A filter expression
Ignored|=Obsolete|A filter espression
Ignored|^USA|Finds every record where the string 'usa' is found in any of the selected fields.
Ignroed|^USA Canada|Finds every record where the strings 'usa' **and** 'canada' are each found in any of the selected fields
Ignored|\|USA Canada|Finds every record where either of the strings 'usa' **or** 'canada' are found in any of the selected fields
Ignored|$Grand Rapids|Treats "Grand Rapids" as a single entry. Thus, it finds every record where the string 'Grand Rapids' if found in any of the selected fields.  

#### Other controls on this page:

**Control** |**Description**
---|---
Listbox Sort|To select the current sort order
Button \|<|Go to previous record
Button \|>|Go to next record
Button +|Add a new record
Button Edit|Edit the current record on a separate form
Checkbox Read-Only|Self explanatory
Checkbox Hide unselected fields|Makes the grid only show selected fields
Button Modify Structure|Gives you the possibility to modify the structure. If the table is opened shared, you are asked whether you want to reopen it exclusive or not.

### Picker Page

This page is a SQL and Browse syntax builder.

![](Images/Thor_Super_Browse_image_thumb_3.png)

**Button** |**Description**
---|---
Only fields|Creates a list of the selected fields
Select ...|Creates a SQL Select statement
Update ...|Creates a SQL Update statement
Insert ...|Creates a SQL Insert statement
Create ...|Create a SQL Create statement
Browse|Create a Browse command


#### Option group to select SQL syntax type:

**Button** |**Description**
---|---
VFP|Creates VFP SQL syntax
SQLExec|Creates MsSQL syntax

#### Checkbox for NVL():

**Button** |**Description**
---|---
Add NVL()|Adds NVL() syntax where appropriate

#### Option group to select Cast type:

**Button** |**Description**
---|---
No|Does not add Cast()
VFP|Adds VFP type Cast()
ANSI|Creates ANSI type Cast()

#### Other options and controls:

**Control** |**Description**
---|---
“From:” Textbox|Shows the current table name
“Add From” Checkbox|Adds “From” phrase to the Select statement
“Close afterwards” Checkbox|Closes the table when SuperBrowse exits
“As:” Textbox|Fills in the Table_Alias
“=TableName” Button|Fills in the current table name in the As textbox
“Remove” Button|Blanks the As field
“Into Table” Textbox|Fill in the name of the target table/cursor
Option 1\. Table|Target is a table
Option 2\. Cursor|Target is a read only cursor
Option 3\. Cursor read/Write|Target is a read/write cursor


### Index page

Lists all active index tags, and shows the syntax to recreate the index file. Can be copied to the clipboard by marking the text with the mouse and press Ctrl-C.

### Settings page

This page should be self explanatory.  
Tip: The ForeColor and BackColor is a good tool to find the RGB values for a color. Select any color, press OK and you will see the value.  
NB! It's usually best to use ForeColor, since the default is Black.

### Keyboard shortcuts while the left grid is active:

#### Common:

**Button** |**Description**
---|---
Escape|Close the form
Enter|Close the form
Spacebar|Toggle Select Field
A|Press button Select all
B|Copy the current SQL statement to the clipboard
G|Activate page Grid
H|Toggle checkbox Hide unselected Fields (Grid page)
K|Activate page Picker
O|Copy the current SQL statement to the clipboard
R|Press button Reverse all
S|Toggle Select Field
U|Press button Unselect all


#### When Picker page is visible, these keys also are activated:

**Button** |**Description**
---|---
\:|Set focus to the textbox Into Cursor
C|Select option SQL Create...
D|Set focus to the textbox Into Local Alias
E|Select option SQL Select...
F|Toggle checkbox Add From
I|Select option SQL Insert...
L|Toggle checkbox Add NVL()
M|Click button Remove
N|Select option ANSI Cast
P|Select option SQL Update...
T|Select option No Cast
V|Select option VFP Cast
W|Select option Browse
X|Sets Local Alias to current alias
Y|Select option Only fields
1|Select option Into Table
2|Select option Into Cursor

<!--
### Keyboard shortcuts while the main (right) grid is active:

#### **NB!** These shortcuts are only active in Read-Only mode!

**Button** |**Description**
---|---
Enter|Select left grid
F|Set focus to the Searc Values textbox
K|Select left grid
-->
