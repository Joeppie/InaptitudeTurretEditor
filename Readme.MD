# warning
`This mod is highly a work in progress, and as of the first commit, no usuable functionality is of yet available to end-users.`


# Turret Editor

This code adds a turret editor, not unlike the tmod, or weapons engineering bay created by DarkConsole ( https://www.avorion.net/forum/index.php?topic=4595.0 )

However, the design and purpose of this mod slightly differ:

* The upgrades provided to turrets are balanced, upgrading does not occur based on a percentage that is left unchanged as weapons progress; instead there is a decreasing return on investment.
* Costs for making turrets coaxial or independent targeting depend on the cost of the turret itself
* There may be future versions where the modifications depend on high-quality trained engineers being available in sufficient quantities, or where production time depends on assembly blocks or available mechanics/engineering capacity.





# Usage

After proper installation, all ships and stations that are player or alliance owned will have the turret editor menu available in the top right of the screen, next to the other menu options.

The overal UI design should be relatively intuitive. After selecting a turret (by either dragging or right-clicking) for modification or improvement the User interface for performing modifications (a new tab) and the improvement of turret performance characteristics becomes available.

Users should beware that improving a turret will increase its price and make future modifications less effective.
Further details can be gathered by running test.lua via its corresponding batch file after placing a lua executable and dll/library in the folder.


# Design


## The code 
I am trying to implement the code in such a way that the server is responsible for presenting many of the 'modifications' to the client in a generic manner so that server owners could implement/add or tweak the way the mod works without needing to modify and distribute a modified version to the client. 

This is achieved by sending a config that informs the client of the types of modifications that can be done, their cost and which parameters apply. The client requests current values, and once the user chooses to apply the modification, the server can perform this within a transaction, ensuring that no undue benefits are gained by users that may try to modify their client.

## Balance
Balance is important. Some mods out there have benefits that keep stacking and may ultimately make individual players capabilities scale more than linearly. To prevent this problem and as much as possible mitigate this risk, a formula is employed which ensures that consecutive modifications have diminishing returns. You can play around with this using the attached test.lua and test.bat using a lua executable, so that specific configuration mods can be tested.



# License

All code is licensed under the GNU affero license, unless otherwise stated;

You are free to use it unaltered on any machine or server, however,
if you make modifications to this code, you are obliged to publish the changes made and make them public. For the purpose of compatibility, works that merely interface for the purpose of adding this mod to games, are not considered derivative works by the author. Note that a good portion of the code within this mod is slightly, or heavily modified code from the base lua scripts provided by Boxelware and that legally, as a result, this code/work is probably considered a derivative work of Boxelware/Avorion's code.



# Installation Instructions:

Extract all files in this folder to /avorion/mods/InaptitudeTurretEditor

Edit avorion/data/scripts/entity/init.lua and add the following text to the bottom, or above that added by other mods:

    -- BEGIN MOD: InaptitudeTurretEditor
    if not entity.aiOwned and (entity.isShip or entity.isStation) then ;
    	entity:removeScript("mods/InaptitudeTurretEditor/Interface.lua");
    	entity:addScriptOnce("mods/InaptitudeTurretEditor/Interface.lua");
    end
    -- END MOD: InaptitudeTurretEditor
