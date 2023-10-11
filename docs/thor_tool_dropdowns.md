### DropDown Tools

There are a number of Thor tools that are closely related in that they all share the same UI, a dropdown list that filters as you type.  (This UI originated in IntellisenseX.)

| Thor Tool | Description |
| --- | ----------- |
| Dropdown Procedures List | List of all PRGs and procedures/functions defined in PRGs found in "Set Procedure to"|
| Dropdown Constants List | List of all defined constants created by #Define or #Include statements |
| AutoComplete | List of all names used in code window (or what is highlighted there)|
| Dropdown Aliases | List of all aliases used in current data session
| Dropdown Table Names | List of all tables in the path|
| Dropdown Form Names in Active Project | List of all form names in the Active Project|
| Dropdown Report Names in Active Project | List of all report names in the Active Project|
| Dropdown Command Expansions | List of native Intellisense Command Expansions|

#### Initializing the DropDown

You can start the dropdown any of these three distinct ways:
* Run the tool on a blank area of code; it will come up with the full dropdown list
* Begin typing part of your expected match and then run the tool; the list will be filtering to match your input.
* Click on a possible match and then run the tool; the list will be filtering to match your input.

#### Filtering
As noted, the list is progressively filtered as you type.  All records in the list that match your entry anywhere (just not at the beginning) are shown, and the first that does match at the beginning is highlighted.

![](Images/DropDownFilteringExample.png)

You can continue typing (including the use of backspace or left arrow to delete unwanted characters) until your desired match is found, where you can click on it.

Alternatively, any from the normal list of characters that cannot be part of a name (punctuation) will terminate the drop down, select the highlighted item and then insert the character typed. A space is automatically inserted before those characters that are operators (plus, minus, etc).

### Additional Keystrokes

* **Ctrl+C** copies the contents of the second visible column into the clipboard.
* **Ctrl+Z** closes the popup and leaves the text already entered as is, whether it matches anything in the dropdown or not.


### Notes
* The listbox is contained actually contained within a modal form. Thus, to remove the dropdown, you must press the Esc key.
* The listbox is resizable.  However its changed size does not persist to the next use.

Last changed: _2023/05/06_ 

![Picture](./images/vfpxpoweredby_alternative.gif)