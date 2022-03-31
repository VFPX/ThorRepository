# How to contribute to ThorRepository
## Bug report?
- Please check  [issues](https://github.com/VFPX/ThorRepository/issues) if the bug is reported
- If you're unable to find an open issue addressing the problem, open a new one. Be sure to include a title and clear description, as much relevant information as possible, and a code sample or an executable test case demonstrating the expected behavior that is not occurring.
### Did you write a patch that fixes a bug?
- Open a new GitHub pull request with the patch.
- Ensure the PR description clearly describes the problem and solution.
  - Include the relevant version number if applicable.

## Coding conventions

Start reading our code and you'll get the hang of it. We optimize for readability:

- Beautification is done like:
  - Keywords: Mixed case 
  - Symbols: First occurence
  - Indentation Tabs, 1
  - Indent anything then Comments
- Please do not run BeautifyX with mDots insertion against the code. 
- We ALWAYS put spaces after list items and method parameters (`[1, 2, 3]`, not `[1,2,3]`), around operators (`x = 1`, not `x=1`).
- This is open source software. Consider the people who will read your code, and make it look nice for them. It's sort of like driving a car: Perhaps you love doing donuts when you're alone, but with passengers the goal is to make the ride as smooth as possible.
- Please kindly add comments where and what you change

## Important
Why ever, the ThorRepository repository is not self contained. The code is scattered over 2 repositories and gathers code from a lot.
- The code doing the work: https://github.com/VFPX/ThorRepository
- Version of ThorRepository: File _Thor_Update_Thor_Repository.prg_ of https://github.com/VFPX/Thor/blob/master/ThorUpdater/Updates.zip
- An variety of VFPX / Thor repositories. The settings (in Thor - configuration menu) of those repositories **might** be controled here. See https://github.com/VFPX/PEMEditor as example.

## New version
Please note, there are some tasks to set up a new version.
Stuff is a bit scattered, so this is where to look up.
1. Please create a fork at github
1. Make whatever changes are necessary.
3. Alter version in _README.md_.
4. Describe the changes in the _What's New_ section near the bottom.
3. Update the version number in _Source\ThorRepositoryVersionFile.txt_
4. On major changes add a description to the _docs_ folder.
5. Set new version to _Thor_Update_Thor_Repository.prg_ of https://github.com/VFPX/Thor/blob/master/ThorUpdater/Updates.zip
   - see https://github.com/VFPX/Thor for contribution.
   - see that depending repositories, ThorRepository and Thor are pushed as close as possible. The order how to publish is on the maintainers of Thor.
6. Please alter the footer of \*.md files touched to recent date.
9. push to your fork
0. create a pull request

Thanks

----
Last changed: _2022/03/31_