# Introduction
[Guild Wars](https://wiki.guildwars.com/wiki/Main_Page) bot for farming [Heroes' Ascent](https://wiki.guildwars.com/wiki/Heroes_Ascent).

Forked from another bot that I acquired, decompiled, then made less awful.
At the time I was running this it was definitely the best bot available on the ladder, primarily due to fixes made to the targeting function and changes to `engine.au3` code that allowed relic detection. 

![](/docs/bot_ui.png)

# Use
Not functional at the moment due to exe header changes; you need to update this each time there's a GW update. Given that this process is somewhat skilled and a foundation of any bot, I am not really inclined to share. However if you know what you're doing, go open favourite reversing tool and update the offsets in `engine.au3` `Headers` region.
Ethically, I always considered the HA bots to be more a service to the community, given HA was dead. However RA bots are a plague.

After doing that,
* Launch GW, login, start bot, pick your character name from list.
* Set your skillbar (bot will approximately cast skills left to right, but maintain Attunements and anything you define in `UpkeepSkills`, see `KillEnemy`)
* Press Start
* Toggle "Disable graphics" to hide the GW UI

# Features
* Supports multiple concurrent GW processes, correctly shows player name of logged-in bot
* Does not need GW credentials to operate; launch GW first then attach the bot
* Bot will navigate to HA, add Henchmen, queue, defeat Zaishen, navigate maps, pick targets and try to win
* Buys ZKeys, farms all 3 versions of the HA quest when option selected
* Uses glyph-sac Meteor Shower sensibly (place Glyph to the left of MS in skillbar)
* Reports earnings, win rates, inventory content, and current fame / faction counts
* Immune to Courtyard gates "bot-juggling"
* Knows if it's carrying a relic (unlike all the other bots of the era)
* Uses interrupts, but does not target anything appropriate. 

# UI
* `Disable graphics` - Hides the GW window, but keeps running. Reduces CPU/GPU burden.
* `HA quest` - Bot will try to talk to the Zaishen Combat quest NPC to take and farm the quest.
* `Leave after 5 mins` - Bot will always leave maps after 20 minutes to avoid rare bot vs bot stalemates it can't otherwise resolve, but if you'd prefer to not hang around on Burial or long waits on Vault then check this
* `Leave before Halls` - Bot will restart rather than attempt to win Hall of Heroes. Bot will generally beat bot teams in halls, and has picked up HoH chest loot, but nearly always there was a human team who will always out play it.

# Epitaph  
Looking at code now, it's pretty terrible. It was a good introduction to AutoIt though, and it was fun to be king of HA for a few years. 
Highlights of the bots history include:
* Taking halls from a human team who were AFK waiting at the chest, where bot had a strategy on cap points of "Wait until last 3 minutes then cap mid"
* Winning Courtyard vs 2 full human teams
* Earning enough Zkeys to max Zaishen
* 16 accounts to R12 hero, until I stopped be cautious and ran it 24 hours and got them all banned ¯\\_(ツ)_/¯

# Developers
The `engine.au3` was a bot framework common to a lot of bots. I made several fixes / enhancements to this, but there's likely newer versions you can find now. I do not know who the original author was.
I attempted to integrate the infamous GvG rupt-bot into this as well, but the results were just worse performance and a lot of crash bugs so I took it out. 

# Copyright
Do what you like. Don't run it for more than 18 hours in a row or you'll flag bot detection, otherwise it's not detected.

