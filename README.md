# About
This is a tool I created to automate the process of taking screenshots of Sim Settlements 2 addon items. These screenshots are used on [SS2 Catalog](https://samutz.com/ss2db).

# Where's the download?
For the time being I'm not providing the plugin or compiled script files as I'm still constantly updating the tool to add more functions. When it reaches a point that I'm not updating as frequently, I might start including them in the releases section.

# <span style="color:red">WARNING</span>
This tool is not meant to be used by casual players or in a casual playthough. It should only be used in a development environment by people that know what they are doing. This tool modifies some of SS2's sytems and has the potential to corrupt save files.

For these reasons, I do not permit this tool to be uploaded to any other website, including NexusMods or Bethesda.net.

# Usage
On first load, the tool will scan SS2's registered addons for supported addon items, such as building plans. If there are any changes to registered addons, the scan needs to run again using the console command `cqf ss2sst_indexer reindex`.

This tool adds a sub menu to the SS2 workshop menu called SS2 Screenshot Tool. In it are several activators that can be placed in a settlement. After being placed, activate the object (E key or select it with the console and enter `activate player`). An inventory menu containing the eligible items will appear. Take the items you want to capture and exit the menu. You have 10 seconds to move your character, as the camera man, in to position. The tool will then spawn each item in place of the activator, capture a screenshot, then despawn the item, and repeat until all selected items have been captured. Screenshots are output to the data\textures\SUPScreenshots\SS2_ScreenshotTool folder.

# Logging
If papyrus logging is enabled for FO4, the tool outputs various information to SS2_ScreenshotTool.0.log.

# Requirements
* [Sim Settlements 2](https://simsettlements2.com) and its requirements
* SS2 and WSFW script sources are also needed to compile  
* [Fallout 4 Script Extender](https://www.nexusmods.com/fallout4/mods/42147)  
* [Address Library for F4SE Plugins](https://www.nexusmods.com/fallout4/mods/47327)
* [SUP F4SE](https://www.nexusmods.com/fallout4/mods/55419)
* [Papyrus Common Library](https://www.nexusmods.com/fallout4/mods/86222)  
* [Garden of Eden Papyrus Script Extender](https://www.nexusmods.com/fallout4/mods/74160)