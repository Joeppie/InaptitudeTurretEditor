package.path = package.path .. ";data/scripts/entity/merchants/?.lua;"
package.path = package.path .. ";data/scripts/lib/?.lua;"

require ("galaxy")
require ("utility")
require ("faction")
require ("player")
require ("randomext")
require ("stringutility")
require ("callable")

require("mods.InaptitudeTurretEditor.Implementation")

local SellableInventoryItem = require("sellableinventoryitem")

-- namespace itw
itw = {}


function itw.interactionPossible(Player)
	return true, ""
end

function itw.getIcon(Seed, Rarity)

	return "data/textures/icons/repair-beam.png"
end
 
function itw.initUI()
	--local status, clientData = Player():invokeFunction("clientdata.lua", "getValue", "SectorOverview")
	if not itw.config then
		itw.config = invokeServerFunction("iti_getConfigServer");
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
	
	itw.upgradeTurret = window:createSelection(rect, 1);
	itw.upgradeTurret:addEmpty();
	itw.upgradeTurret.dropIntoEnabled = true;
	itw.upgradeTurret.entriesSelectable = false;
	itw.upgradeTurret.onClickedFunction = "onTurretClicked"
	itw.upgradeTurret.onReceivedFunction = "onTurretReceived";
	itw.upgradeTurret.onDroppedFunction = "onTurretDropped";
	
	
	window:createLabel(
	itw.upgradeTurret.position,
	"Turret To Upgrade",
	(font2))
	
	tabbedWindow = window:createTabbedWindow(hsplit.bottom)
	
	itw.improvementTab = tabbedWindow:createTab("Improvement", "data/textures/icons/tools.png", "Improvement");
	
	local improvementVsplit = UIVerticalSplitter(Rect(itw.improvementTab.size), 10, 10, 0.7);

	local rect = improvementVsplit.right;
	
	itw.inventory = itw.improvementTab:createInventorySelection(rect, 5); --Created as a property, not local.
	itw.inventory.dragFromEnabled = true;
	itw.inventory.entriesSelectable = false;
	itw.inventory.dragFromEnabled = true;
	itw.inventory.onClickedFunction = "onInventoryClicked"
	itw.populateInventory(); --Also grabs systems for the time being, until this is resolved.
	
	local improvmentTabLeftHorizontalsplitter  = UIHorizontalSplitter(improvementVsplit.left, 10, 10, 0.5)
	
	local rect = improvmentTabLeftHorizontalsplitter.top;
	rect.width = 128*5/2;
	rect.height = 128;
	
	itw.sacrificeTurrets = itw.improvementTab:createSelection(rect, 5);
	itw.sacrificeTurrets.entriesSelectable = false;
	itw.sacrificeTurrets.dropIntoEnabled = true;
	
	itw.sacrificeTurrets.onClickedFunction = "onTurretClicked"
	itw.sacrificeTurrets.onReceivedFunction = "onTurretReceived";
	itw.sacrificeTurrets.onDroppedFunction = "onTurretDropped";
	
	for i =0,4,1 do itw.sacrificeTurrets:addEmpty(); end
	
	itw.modificationTab = tabbedWindow:createTab("Modification", "data/textures/icons/tinker.png", "Modification");
	
	itw.MakeUIForModificationTab();
	
	--modificationTab.active = false;
end

function itw.MakeUIForModificationTab()

	local hsplit = UIHorizontalSplitter(Rect(itw.modificationTab.size), 10, 10, 0.3);
		local topvsplit =  UIVerticalSplitter(hsplit.top, 10, 10, 0.5);
			local tophsplit = UIHorizontalSplitter(topvsplit.left, 10, 10, 0.2);
				itw.comboBox 	= itw.modificationTab:createComboBox(tophsplit.top,"onSelectModification");
				itw.description = itw.modificationTab:createMultiLineTextBox(tophsplit.bottom);		
		local bottomvsplit = UIVerticalSplitter(hsplit.bottom, 10, 10, 0.5);
			local before = itw.modificationTab:createMultiLineTextBox(bottomvsplit.left);
			local after = itw.modificationTab:createMultiLineTextBox(bottomvsplit.right);
	
end

function itw.onSelectModification()

end

function itw.onShowWindow()
	itw.inventory:clear();
	itw.populateInventory();
end

function itw.onCloseWindow()
	itw.inventory:clear();
	itw.populateInventory();
end

function itw.clearUI()
	itw.inventory:clear();
	itw.populateInventory();
	
	itw.upgradeTurret:clear();
	itw.upgradeTurret.addEmpty();
	for i =0,4,1 do itw.sacrificeTurrets:addEmpty(); end
	itw.updateUIStatus();
end

--Update labels and buttons to reflect the options available.
function itw.UpdateUIStatus()

	if(#itw.upgradeTurret:getItems() > 0) then
		itw.modificationTab:show();
		--todo: disable all the buttons on the improvmentTab
	else
		itw.modificationTab:hide();
		--todo: disable all the buttons on the improvmentTab
	end

end


--Populate with the inventory which is appropriate; alliance or the individual player.
function itw.populateInventory()
	--todo: systems are not currently filtered out of this.
	player = Player();
	
	if player.allianceIndex and ship.factionIndex == player.allianceIndex then
		itw.inventory:fill(alliance.index);
	else
		itw.inventory:fill(player.index);
	end
	
	print("listing all items");
	for i,reference in pairs(itw.inventory:getItems()) do
	
		if(reference.item.__avoriontype == "InventoryTurret") then --is a turret
			--print("turret " .. reference.item.weaponName);
		else
			--print("not a turret, remove from list");
				--todo: remove the element; this may need to happen outside of the iterator loop...
			itw.inventory:remove(i);
		end
		
		
	end
	
end

function itw.onInventoryClicked(selectionIndex, kx, ky, item, button)
	--print('itw.onInventoryClicked')
	if button == 2 or button == 3 then
		-- fill itw.upgradeTurret first.
		local items = itw.upgradeTurret:getItems()
		if tablelength(items) < 1 then
			itw.moveItem(item, itw.inventory, itw.upgradeTurret, ivec2(kx, ky), nil)
			itw.UpdateUIStatus();
			return
		end

		local items = itw.sacrificeTurrets:getItems()
		if tablelength(items) < 5 then
			itw.moveItem(item, itw.inventory, itw.sacrificeTurrets, ivec2(kx, ky), nil)
			itw.UpdateUIStatus();
			return
		end
	end
end


--Function taken from researchstation.lua
function itw.moveItem(item, from, to, fkey, tkey)
    if not item then return end

    if from.index == itw.inventory.index then -- move from inventory to a selection
        -- first, move the item that might be in place back to the inventory
        if tkey then
            itw.addItemToMainSelection(to:getItem(tkey))
            to:remove(tkey)
        end

        itw.removeItemFromMainSelection(fkey)

        -- fix item amount, we don't want numbers in the upper selections
        item.amount = nil
        to:add(item, tkey)

    elseif to.index == itw.inventory.index then
        -- move from selection to itw.inventory
        itw.addItemToMainSelection(item)
        from:remove(fkey)
    end
	itw.UpdateUIStatus();
end


--Function taken from researchstation.lua
function itw.removeItemFromMainSelection(key)
    local item = itw.inventory:getItem(key)
    if not item then return end

    if item.amount then
        item.amount = item.amount - 1
        if item.amount == 0 then item.amount = nil end
    end

    itw.inventory:remove(key)

    if item.amount then
        itw.inventory:add(item, key)
    end
	itw.UpdateUIStatus();
end

--Function taken from researchstation.lua
function itw.addItemToMainSelection(item)
    if not item then return end
    if not item.item then return end

    if item.item.stackable then
        -- find the item and increase the amount
        for k, v in pairs(itw.inventory:getItems()) do
            if v.item and v.item == item.item then
                v.amount = v.amount + 1

                itw.inventory:remove(k)
                itw.inventory:add(v, k)
                return
            end
        end

        item.amount = 1
    end

    -- when not found or not stackable, add it
    itw.inventory:add(item)
	itw.UpdateUIStatus();
end

function itw.onTurretDropped(selectionIndex, kx, ky)
	print('onTurretDropped')
	local selection = Selection(selectionIndex)
	local key = ivec2(kx, ky)
	itw.moveItem(selection:getItem(key), Selection(selectionIndex), itw.inventory, key, nil)
end


function itw.onTurretReceived(selectionIndex, fkx, fky, item, fromIndex, toIndex, tkx, tky)
	print("onTurretReceived");
	if not item then return end
	itw.moveItem(item, itw.inventory, Selection(selectionIndex), ivec2(fkx, fky), ivec2(tkx, tky))
end

--function taken from researchstation.lua
function itw.onTurretClicked(selectionIndex, fkx, fky, item, button)
    if button == 3 or button == 2 then
        itw.moveItem(item, Selection(selectionIndex), itw.inventory, ivec2(fkx, fky), nil)
    end
end

	
function itw.commentedOutBymakingitaseparaterunction()
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
	itw.upgradeTurret = window:createInventorySelection(rect, 1);

	local rect = hsplitleft.bottom;
	rect.width = 150;
	sacrifice = window:createInventorySelection(rect,5);
	
	itw.upgradeTurret.dropIntoEnabled = 1;
	itw.upgradeTurret.entriesSelectable = 0;
	--itw.upgradeTurret.onReceivedFunction = "onitw.upgradeTurretReceived"
	--itw.upgradeTurret.onDroppedFunction = "onitw.upgradeTurretDropped"
	--itw.upgradeTurret.onClickedFunction = "onitw.upgradeTurretClicked"
	
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

function itw.onClickDamage()
   --_,turret = pairs(itw.upgradeTurret:getItems());
end

function itw.onClickCoaxial()
   --_,turret = pairs(sacrifice:getItems());
end