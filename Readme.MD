


# Turret Editor

This code adds a turret editor, not unlike the tmod, or weapons engineering bay created by DarkConsole ( https://www.avorion.net/forum/index.php?topic=4595.0 )

However, the design and purpose of this mod slightly differ:

* The upgrades provided to turrets are balanced, upgrading does not occur based on a percentage that is left unchanged as weapons progress; instead there is a decreasing return on investment.
* Costs for making turrets coaxial or independent targeting depend on the cost of the turret itself
* There may be future versions where the modifications depend on high-quality trained engineers being available in sufficient quantities, or where production time depends on assembly blocks or available mechanics/engineering capacity.

This mod is highly a work in progress, and as of the first commit, no usuable functionality is of yet available to end-users.


# Usage

After proper installation, all ships and stations that are player or alliance owned will have the turret editor menu available in the top right of the screen, next to the other menu options.


# License

All code is licensed under the GNU affero license, unless otherwise stated;

You are free to use it unaltered on any machine or server, however,
if you make modifications to this code, you are obliged to publish the changes made and make them public. For the purpose of compatibility, works that merely interface for the purpose of adding this mod to games, are not considered derivative works by the author.



# Installation Instructions:

Extract all files in this folder to /avorion/mods/InaptitudeTurretEditor

Edit avorion/data/scripts/entity/init.lua and add the following text to the bottom, or above that added by other mods:

    -- BEGIN MOD: InaptitudeTurretEditor
    if not entity.aiOwned and (entity.isShip or entity.isStation) then ;
    	entity:removeScript("mods/InaptitudeTurretEditor/Interface.lua");
    	entity:addScriptOnce("mods/InaptitudeTurretEditor/Interface.lua");
    end
    -- END MOD: InaptitudeTurretEditor