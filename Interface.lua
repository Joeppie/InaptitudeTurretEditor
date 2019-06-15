package.path = package.path .. ";data/scripts/entity/merchants/?.lua;"
package.path = package.path .. ";data/scripts/lib/?.lua;"

require ("galaxy")
require ("utility")
require ("faction")
require ("player")
require ("randomext")
require ("stringutility")
require ("callable")

local SellableInventoryItem = require("sellableinventoryitem")

---- name--spa--ce InaptitudeTurretWindow
--InaptitudeTurretWindow = {}


function interactionPossible(Player)
	return true, ""
end

function getIcon(Seed, Rarity)

	return "data/textures/icons/repair-beam.png"
end

function initUI()
	--local status, clientData = Player():invokeFunction("clientdata.lua", "getValue", "SectorOverview")
	if not clientData then
		--Player():invokeFunction("clientdata.lua", "setValue", "SectorOverview", {})
		--invokeServerFunction("sendServerConfig")
	end
	
	
	font1 = 20;
	font2 = 14;
	font3 = 8;

	local res = getResolution();
	local size = vec2(1240, 900);

	local menu = ScriptUI();
	local window = menu:createWindow(Rect(res * 0.5 - size * 0.5, res * 0.5 + size * 0.5));
	
	menu:registerWindow(window, "Turret Editor");
	window.caption = "Turret Editor";
	window.showCloseButton = true;
	window.moveable = true;

	--Split between the turret and the improvement and modifications tabs.
	local hsplit = UIHorizontalSplitter(Rect(window.size), 10, 10, 0.15);
	
	local rect = hsplit.top;
	rect.width = 128;
	rect.height = 128;
	
	upgradeTurret = window:createSelection(rect, 1);
	upgradeTurret:addEmpty();
	upgradeTurret.dropIntoEnabled = true;
	upgradeTurret.entriesSelectable = false;
	upgradeTurret.onClickedFunction = "onTurretClicked"
	upgradeTurret.onReceivedFunction = "onTurretReceived";
	upgradeTurret.onDroppedFunction = "onTurretDropped";
	
	
	window:createLabel(
	upgradeTurret.position,
	"Turret To Upgrade",
	(font2))
	
	tabbedWindow = window:createTabbedWindow(hsplit.bottom)
	
	local improvementTab = tabbedWindow:createTab("Improvement", "data/textures/icons/tools.png", "Improvement");
	
	local improvementVsplit = UIVerticalSplitter(Rect(improvementTab.size), 10, 10, 0.7);

	local rect = improvementVsplit.right
	rect.width = 128*2.5;
	
	inventory = improvementTab:createInventorySelection(rect, 5); --Created as a property, not local.
	inventory.dragFromEnabled = true;
	inventory.entriesSelectable = false;
	inventory.dragFromEnabled = 1
	inventory.onClickedFunction = "onInventoryClicked"
	populateInventory(); --Also grabs systems for the time being, until this is resolved.
	
	local improvmentTabLeftHorizontalsplitter  = UIHorizontalSplitter(improvementVsplit.left, 10, 10, 0.5)
	
	sacrificeTurrets = improvementTab:createSelection(improvmentTabLeftHorizontalsplitter.top, 5);
	sacrificeTurrets.entriesSelectable = false;
	
	for i =0,4,1 do sacrificeTurrets:addEmpty(); end
	
	local modificationTab = tabbedWindow:createTab("Modification", "data/textures/icons/tinker.png", "Modification");
	
	--modificationTab.active = false;
	
	
	
end

function onShowWindow()
	inventory:clear();
	populateInventory();
end

function refreshUI()
	inventory:clear();
	populateInventory();
	
	upgradeTurret:clear();
	upgradeTurret.addEmpty();
	for i =0,4,1 do sacrificeTurrets:addEmpty(); end
end


--Populate with the inventory which is appropriate; alliance or the individual player.
function populateInventory()
	--todo: systems are not currently filtered out of this.
	player = Player();
	
	if player.allianceIndex and ship.factionIndex == player.allianceIndex then
		inventory:fill(alliance.index);
	else
		inventory:fill(player.index);
	end
	
	print("listing all items");
	for i,reference in pairs(inventory:getItems()) do
	
		if(reference.item.__avoriontype == "InventoryTurret") then --is a turret
			--print("turret " .. reference.item.weaponName);
		else
			--print("not a turret, remove from list");
				--todo: remove the element; this may need to happen outside of the iterator loop...
			inventory:remove(i);
		end
		
		
	end
	
end

function onInventoryClicked(selectionIndex, kx, ky, item, button)
	print('Hello I pressed this window?!')
	if button == 2 or button == 3 then
		-- fill upgradeTurret first.
		local items = upgradeTurret:getItems()
		if tablelength(items) < 1 then
			moveItem(item, inventory, upgradeTurret, ivec2(kx, ky), nil)
			return
		end

		local items = sacrificeTurrets:getItems()
		if tablelength(items) < 5 then
			moveItem(item, inventory, sacrificeTurrets, ivec2(kx, ky), nil)
			return
		end
	end
end


--Function taken from researchstation.lua
function moveItem(item, from, to, fkey, tkey)
    if not item then return end

    if from.index == inventory.index then -- move from inventory to a selection
        -- first, move the item that might be in place back to the inventory
        if tkey then
            addItemToMainSelection(to:getItem(tkey))
            to:remove(tkey)
        end

        removeItemFromMainSelection(fkey)

        -- fix item amount, we don't want numbers in the upper selections
        item.amount = nil
        to:add(item, tkey)

    elseif to.index == inventory.index then
        -- move from selection to inventory
        addItemToMainSelection(item)
        from:remove(fkey)
    end
end


--Function taken from researchstation.lua
function removeItemFromMainSelection(key)
    local item = inventory:getItem(key)
    if not item then return end

    if item.amount then
        item.amount = item.amount - 1
        if item.amount == 0 then item.amount = nil end
    end

    inventory:remove(key)

    if item.amount then
        inventory:add(item, key)
    end

end

function addItemToMainSelection(item)
    if not item then return end
    if not item.item then return end

    if item.item.stackable then
        -- find the item and increase the amount
        for k, v in pairs(inventory:getItems()) do
            if v.item and v.item == item.item then
                v.amount = v.amount + 1

                inventory:remove(k)
                inventory:add(v, k)
                return
            end
        end

        item.amount = 1
    end

    -- when not found or not stackable, add it
    inventory:add(item)
end

function onTurretDropped(selectionIndex, kx, ky)
	print('onTurretDropped')
	local selection = Selection(selectionIndex)
	local key = ivec2(kx, ky)
	moveItem(selection:getItem(key), Selection(selectionIndex), inventory, key, nil)
end


function onTurretReceived(selectionIndex, fkx, fky, item, fromIndex, toIndex, tkx, tky)
	print("onTurretReceived");
	 moveItem(item, inventory, Selection(selectionIndex), ivec2(fkx, fky), ivec2(tkx, tky))
	if not item then return end

	-- don't allow dragging from/into the left hand selections
	if fromIndex == sacrificeTurrets.index then
		return
	end
	moveItem(item, inventory, Selection(selectionIndex), ivec2(fkx, fky), ivec2(tkx, tky))
	moveItem(item, inventory, Selection(selectionIndex), ivec2(fkx, fky), ivec2(tkx, tky))

	end
	
function commentedOutBymakingitaseparaterunction()
	local res = getResolution();
	local size = vec2(1240, 900);

	local menu = ScriptUI();
	local window = menu:createWindow(Rect(res * 0.5 - size * 0.5, res * 0.5 + size * 0.5));
	menu:registerWindow(window, "Turret Editor");
	window.caption = "Turret Editor";
	window.showCloseButton = 1;
	window.moveable = 1;
	
	local hsplit = UIHorizontalSplitter(Rect(window.size), 10, 10, 0.4);
	--Create the inventory widget as a property.
	inventory = window:createInventorySelection(hsplit.bottom, 11);
	local vsplit = UIVerticalSplitter(hsplit.top, 10, 10, 0.4);
	local hsplitleft = UIHorizontalSplitter(vsplit.left, 10, 10, 0.5);
	
	--Create two bars: one with the turret to upgrade, one with the
	--turrets which can be sacrificed in one go.
	hsplitleft.padding = 6;
	local rect = hsplitleft.top;
	rect.width = 220;
	upgradeTurret = window:createInventorySelection(rect, 1);

	local rect = hsplitleft.bottom;
	rect.width = 150;
	sacrifice = window:createInventorySelection(rect,5);
	
	upgradeTurret.dropIntoEnabled = 1;
	upgradeTurret.entriesSelectable = 0;
	--upgradeTurret.onReceivedFunction = "onUpgradeTurretReceived"
	--upgradeTurret.onDroppedFunction = "onUpgradeTurretDropped"
	--upgradeTurret.onClickedFunction = "onUpgradeTurretClicked"
	
	sacrifice.dropIntoEnabled = 1;
	sacrifice.entriesSelectable = 0;
	--sacrifice.onReceivedFunction = "onSacrificeReceived"
	--sacrifice.onDroppedFunction = "onSacrificeDropped"
	--sacrifice.onClickedFunction = "onSacrificeClicked"
	
	inventory.dragFromEnabled = 1;
	--inventory.onClickedFunction = "onInventoryClicked"
	
	vsplit.padding = 30;
	local rect = vsplit.right;
	rect.width = 70;
	rect.height = 70;
	results = window:createSelection(rect, 1);
	results.entriesSelectable = 0;
	results.dropIntoEnabled = 0;
	results.dragFromEnabled = 0;

	vsplit.padding = 10;
	local organizer = UIOrganizer(vsplit.right);
	organizer.marginBottom = 5;
	
	local splitter = UIHorizontalMultiSplitter(Rect(window.size), 10, 10, 8)

	window:createButton(splitter:partition(0), "Idle"%_t, "onUserIdleOrder")
	window:createButton(splitter:partition(1), "Passive"%_t, "onUserPassiveOrder")
	window:createButton(splitter:partition(2), "Guard This Position"%_t, "onUserGuardOrder")
	window:createButton(splitter:partition(3), "Patrol Sector"%_t, "onUserPatrolOrder")
	window:createButton(splitter:partition(4), "Escort Me"%_t, "onUserEscortMeOrder")
	window:createButton(splitter:partition(5), "Attack Enemies"%_t, "onUserAttackEnemiesOrder")
	window:createButton(splitter:partition(6), "Mine"%_t, "onUserMineOrder")
	window:createButton(splitter:partition(7), "Salvage"%_t, "onUserSalvageOrder")
	
	
	

	damageButton = window:createButton(Rect(), "Improve Damage", "onClickDamage");
	damageButton.width = 300;
	damageButton.height = 40;
	organizer:placeElementBottom(damageButton);
	
	coaxialButton = window:createButton(Rect(), "Make Coaxial", "onClickCoaxial");
	coaxialButton.width = 300;
	coaxialButton.height = 40;
	organizer:placeElementBottom(coaxialButton);
	
end

function onClickDamage()
   --_,turret = pairs(upgradeTurret:getItems());
end

function onClickCoaxial()
   --_,turret = pairs(sacrifice:getItems());
end