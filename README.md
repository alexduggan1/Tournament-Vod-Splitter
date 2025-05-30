# Tournament-Vod-Splitter

Slug
https://www.start.gg/tournament/smash-at-wpi-135/event/ultimate-singles


Video
https://www.youtube.com/watch?v=adMTKeI0Z5c

https://youtu.be/adMTKeI0Z5c?t=17195


https://youtu.be/adMTKeI0Z5c?t=20009
https://youtu.be/adMTKeI0Z5c?t=20719

find the t=




TODO

User prefs
[+] start.gg token
[+] parent directory for all project folders

File stuff, project saving
[+] projects saved as a json file named proj.tvs (within a directory named after the project)
- [+] downloaded videos are saved in a subfolder
- [+] thumbnails are also saved in a different subfolder
[+] things to save: project name, event link, youtube link, array of sets
[+] make it so that you can save a project after it is open
[+] ctrl + s saves
[+] button to save
[+] open a previous file rather than start a new one (from the startup page)

ProjectPane
[+] editable project name LineEdit
[+] buttons linking to the start.gg bracket and the youtube video
[+] save button

SetDetailsPane
[+] shows the players, round, and total score just like in the little set obj thing on the right sidebar
[+] displays each player's character for each game (and who won)
[+] slider button for whether this set was streamed or not
[+] if the slider button is true, change the color of the set on the right
[+] if the slider button is true, show LineEdits to input the start and end time of the set
- [+] (accepts the link you get when you click 'copy URL at current time' on a yt video and translates it to just seconds for use by yt-dlp)


ThumbnailPane
[] Generates a thumbnail with custom art? (mightybird art, mural art, or idk)
[+] a button to export the thumbnail
- [+] properly named
[] Customization options?
[+] button at bottom to download the selected segment of the video
- [+] (this will automatically name the video properly)
- [] do error handling / fixes for this
[] button to update yt-dlp
