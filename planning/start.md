Hello agent, we are going to create a framework for managing your zsh https://www.zsh.org/ configuration (like oh my zsh, oh my post, etc). This project is called Gitmon CLI.

1. **Functional features (themes)**  
   - Custom prompt  
   - Gitmons (ASCII/emoji characters)  
   - Git utilities (branch, clean/dirty)  
   - Timers, clock, path display  
   - Works on macOS, Linux, and Windows (PowerShell)
   - It will start with only 2 themes shadrix and crystalix
   - I want you to make a list of everything we need a template/visual for (use oh my zsh as reference.) eg: not found/failed feedback, directory, branch display, etc

   2. **A separate ASCII turn-based game**, launched with the command: /play
   (LATER, AFTER WE FINISH THE #1 FUNCTIONALITY)

   The game runs in a **new terminal window/tab**, not inside the current shell.
   By default, the game is **NOT installed**. On first run, `/play` must display:

   Gitmon Game is not installed. Would you like to download it? (Y/N)
   
   If the user accepts, the game is downloaded into:

   Then `/play` can be executed normally to open the game in a new terminal.


## Requirements Summary 1ST STEP
- Cross-platform (macOS / Linux / Windows)  
- Functional themes loaded on each terminal session  
- Git status + timer + clock + Gitmon display    
- All scripts must avoid breaking user dotfiles  
- Modular and easy to extend

## Requirements Summary 2ND STEP
- `/play` command that launches a separate game terminal  
- Game is optional and must be downloaded on-deman
