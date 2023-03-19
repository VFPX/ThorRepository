# How to contribute to ThorRepository

## Bug report?
- Please check  [issues](https://github.com/VFPX/ThorRepository/issues) if the bug is reported
- If you're unable to find an open issue addressing the problem, open a new one. Be sure to include a title and clear description, as much relevant information as possible, and a code sample or an executable test case demonstrating the expected behavior that is not occurring.

### Did you write a patch that fixes a bug?
- Open a new GitHub pull request with the patch.
- Ensure the PR description clearly describes the problem and solution.
  - Include the relevant version number if applicable.
- See [New version](#new-version) for additional tasks

## Coding conventions
Start reading our code and you'll get the hang of it. We optimize for readability:

- Beautification is done like:
  - Keywords: Mixed case 
  - Symbols: First occurrence
  - Indentation Tabs, 1
  - Indent anything then Comments
- Please do not run BeautifyX with mDots insertion against the code. 
- We ALWAYS put spaces after list items and method parameters (`[1, 2, 3]`, not `[1,2,3]`), around operators (`x = 1`, not `x=1`).
- This is open source software. Consider the people who will read your code, and make it look nice for them. It's sort of like driving a car: Perhaps you love doing donuts when you're alone, but with passengers the goal is to make the ride as smooth as possible.
- Please kindly add comments where and what you change

## New version
Here are the steps to updating to a new version:

1. Create a fork at github
   - See this [guide](https://www.dataschool.io/how-to-contribute-on-github/) for setting up and using a fork
1. Make whatever changes are necessary.
1. If you haven't already done so, install VFPX Deployment: invoke menu item  **Thor -> Check For Updates**, turn on the checkbox for VFPX Deployment, and click Install.

---
4. Edit the Version setting in _BuildProcess\ProjectSettings.txt_.
1. Update the version and date in _README.md_.
1. Describe the changes in the top of _docs\Change Log.md_.
1. Run the VFPX Deployment tool to create the installation files by
    -   Invoking menu item  **Thor Tools -> Applications -> VFPX Project Deployment**  
    -   Or executing ```EXECSCRIPT(_screen.cThorDispatcher, 'Thor_Tool_DeployVFPXProject')``` 
    -   Or executing Thor tool **"VFPX Project Deployment"**
---
8. Commit
1. Push to your fork
1. Create a pull request
----
Last changed: _2022/03/19_ ![Picture](../docs/Images/vfpxpoweredby_alternative.gif)
