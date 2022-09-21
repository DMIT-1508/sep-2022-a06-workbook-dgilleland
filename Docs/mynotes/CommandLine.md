# Terminal Commands

## DOS Commands (Disk Operating System)

- `dir` - Display the directory listing for the current folder
- `cd <path>` - Change directory to a specific path; for example: `cd Documents/GH` to go from your current path down two folders to the **GH** folder.
- `cls` - Clear the screen
- `mkdir <folderName>` - Create a folder (directory); for example: `mkdir Sandbox` to create a subfolder named **Sandbox**.

## git Commands

Some commands you do infrequently.

- First-time setup of "who you are"
  - `git config user.name "Your Name"`
  - `git config user.email "YourGitHubUserName@users.noreply.github.com"`
- Cloning a repository
  - `git clone <pathToGitHubRepo>`
  - Be sure your path on the command line is where you want to be. e.g.: **C://Users/WhoYouAre/Documents/GH**

These are regular commands you do daily.

- `git status`
- `git pull`
- `git push`
- `git add <filePath>` to "stage" a file for commit where `<filePath>` is the path to a file; for example: `git add README.md` will stage any changes you made to the *README.md* file so that it is *ready to commit*.
  - To just take all your changes from the current path on down, you can type `git add .` where the dot (`.`) means the "current path".
- `git commit -m "Your Message"`






