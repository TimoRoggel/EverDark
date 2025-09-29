# Everdark
## Overview
- [Description](#description) - A short description of the game.
- [Controls](#controls) - Mapping of the game's default controls.
- [Installation](#installation) - Step by step tutorial on how to intall the project.
    - [Project](#project)
    - [Game](#game)
- [How to...?](#how-to) - Step by step tutorial for common how to questions.
    - [Add an item](#add-an-item)
    - [Add a recipe](#add-a-recipe)
## Description
Everdark is a survival crafting adventure game where you use light to unlock more playable area. You feed resources to a mysterious hole to obtain this light. Monsters of the darkness don't like the light and will attack you. Venture into the darkness to restore the light.
## Controls
WASD - Move\
Mouse - Look around\
LMB - Attack / Spawn a random item\
RMB - Block\
F - Pick up item / interact\
Escape / P - Pause game
## Installation
### Project
#### Step 1
Install GitHub Desktop or use git.
#### Step 2
Clone the project using the clone button at the top or by using the git command line.
#### Step 3
Install Godot version 4.5 (stable), preferrably the non-mono version, so the standard one.
#### Step 4
Open godot and import the project by navigating to the cloned location.
#### (If you are planning on contributing and/or editing)
#### Step 5
Switch and/or make a branch using your name. From here on you can start pushing your changes.
#### Step 6
Inform the Lead Developer when you're done with a feature. From here on the Lead Developer will merge your changes into the main branch. Until then stay put as there could be merge conflicts that need resolving.
### Game
#### Step 1
Navigate to the releases tab on the right side of the page.
#### Step 2
Download a build that works for your operating system.
#### Step 3
Have fun!
## How to...?
### Add an item
#### Step 1
Navigate to the [Everdark spreadsheet](https://docs.google.com/spreadsheets/d/1625O4iMQZqi9_kXD7bO6tz-KfY_-GNBzAe-nHMraaSU/edit?gid=0).
#### Step 2
Add an item entry by supplying it with the following:
| type       | description                         | example            |
|------------|-------------------------------------|--------------------|
| id         | numerical value                     | 50                 |
| name       | don't use commas                    | Wooden Sword       |
| icon       | uid can be copied from within godot | uid://yr12pliky2ha |
| stack size | numerical value                     | 1                  |
#### Step 3
Open the project in Godot and sync the CSV file by navigating to **Sync CSV Spreadsheets** at the bottom of the editor and pressing the **Sync Now** button.
### Add a recipe
#### Step 1
Navigate to the [Everdark spreadsheet](https://docs.google.com/spreadsheets/d/1625O4iMQZqi9_kXD7bO6tz-KfY_-GNBzAe-nHMraaSU/edit?gid=2082329103).
#### Step 2
Add a recipe entry by supplying it with the following:
| type    | description                                                           | example             |
|---------|-----------------------------------------------------------------------|---------------------|
| id      | numerical value                                                       | 32                  |
| name    | don't use commas                                                      | Wooden Sword Recipe |
| rewards | array of item ids that this recipe grants separated by semicolons (;) | [50]                |
| costs   | array of item ids that this recipe costs separated by semicolons (;)  | [21;21;22;25]       |
#### Step 3
Open the project in Godot and sync the CSV file by navigating to **Sync CSV Spreadsheets** at the bottom of the editor and pressing the **Sync Now** button.
