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

-- namespace ite


function ite.interactionPossible(Player)
	return true, ""
end

function ite.getIcon(Seed, Rarity)
	return "data/textures/icons/repair-beam.png"
end


 
function ite.initUI()
	--local status, clientData = Player():invokeFunction("clientdata.lua", "getValue", "SectorOverview")
	--if not ite.config then
--		ite.config = invokeServerFunction("iti_getConfigServer");
--	end

	
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
	
	ite.upgradeTurret = window:createSelection(rect, 1);
	ite.upgradeTurret:addEmpty();
	ite.upgradeTurret.dropIntoEnabled = true;
	ite.upgradeTurret.entriesSelectable = false;
	ite.upgradeTurret.onClickedFunction = "onTurretClicked"
	ite.upgradeTurret.onReceivedFunction = "onTurretReceived";
	ite.upgradeTurret.onDroppedFunction = "onTurretDropped";
	
	
	window:createLabel(
	ite.upgradeTurret.position,
	"Turret To Upgrade",
	(font2))
	
	ite.tabbedWindow = window:createTabbedWindow(hsplit.bottom)
	
	ite.improvementTab = ite.tabbedWindow:createTab("Improvement", "data/textures/icons/tools.png", "Improvement");
	
	local improvementVsplit = UIVerticalSplitter(Rect(ite.improvementTab.size), 10, 10, 0.7);

	local rect = improvementVsplit.right;
	
	ite.inventory = ite.improvementTab:createInventorySelection(rect, 5); --Created as a property, not local.
	ite.inventory.dragFromEnabled = true;
	ite.inventory.entriesSelectable = false;
	ite.inventory.dragFromEnabled = true;
	ite.inventory.onClickedFunction = "onInventoryClicked"
	ite.populateInventory(); --Also grabs systems for the time being, until this is resolved.
	
	local improvmentTabLeftHorizontalsplitter  = UIHorizontalSplitter(improvementVsplit.left, 10, 10, 0.5)
	
	local rect = improvmentTabLeftHorizontalsplitter.top;
	rect.width = 128*5/2;
	rect.height = 128;
	
	ite.sacrificeTurrets = ite.improvementTab:createSelection(rect, 5);
	ite.sacrificeTurrets.entriesSelectable = false;
	ite.sacrificeTurrets.dropIntoEnabled = true;
	
	ite.sacrificeTurrets.onClickedFunction = "onTurretClicked"
	ite.sacrificeTurrets.onReceivedFunction = "onTurretReceived";
	ite.sacrificeTurrets.onDroppedFunction = "onTurretDropped";
	
	for i =0,4,1 do ite.sacrificeTurrets:addEmpty(); end
	
	ite.modificationTab = ite.tabbedWindow:createTab("Modification", "data/textures/icons/tinker.png", "Modification");
	
	ite.MakeUIForModificationTab();
	
	--modificationTab.active = false;
	
	if not ite.config then
		print("requesting config")
		invokeServerFunction("sendConfig")
	end
end

function ite.getStringFromTable(tbl,prefix)
--This function is almost identical to printTable function from Avorion's lib/utility.lua but returns a string instead.
    
    if prefix and string.len(prefix) > 100 then end
    prefix = prefix or ""
	
	output = ""
	
    for k, v in pairs(tbl) do
        if type(v) == "string" then
            output = output .. (prefix .. "" .. tostring(k) .. "=  \"" .. tostring(v) .. "\" \n")
        elseif type(v) == "userdata" and v.__avoriontype then
            output = output .. (prefix .. "" .. tostring(k) .. "=  [" .. v.__avoriontype .. "] " .. tostring(v) .. "\n")
        else 
            output = output .. (prefix .. "" .. tostring(k) .. "= " .. tostring(v) .. "\n")
        end

        if type(v) == "table" then
            output = output .. ite.getStringFromTable(v, prefix .. "   ")  .. ""
        end
    end
	return output;
end

function ite.MakeUIForModificationTab()

	local vsplit =  UIVerticalSplitter(Rect(ite.modificationTab.size), 10, 10, 0.5);
		local left =  UIHorizontalSplitter(vsplit.left, 10, 10, 0.3);
			local topleft = UIHorizontalSplitter(left.top, 10, 10, 0.2);
				ite.modificationDropDown 	= ite.modificationTab:createComboBox(topleft.top,"onSelectModification");
				ite.description = ite.modificationTab:createMultiLineTextBox(topleft.bottom);
				ite.editable = false;
		--modificationUI is cleared and populated as is appropriate for the options the server gives us.
		ite.modificationUI =  ite.modificationTab:createScrollFrame(vsplit.right);
		
		ite.status = ite.modificationTab:createMultiLineTextBox(left.bottom);
	
end

function ite.receiveConfig(config)
    ite.config = config
    print("ite config received")
	
	print("update UI now!");
	ite.UpdateUIStatus()
end




--If a modification is chosen, construct the UI required to let the user request the modification to server.
function ite.onSelectModification()
	local option = ite.modificationDropDown.selectedEntry;
	
	--Avorion does not properly let us disable most UI elements, therefore, we need ironplated code.
	if not option or option == "" or option == nil then return end
	
	local modification = ite.config.TurretModificationOptions[option];		
		
	ite.description.text = modification.Description;
	
	if modification.Parameters then
		for name,paramater in pairs(modification.Parameters) do
			--Create appropriate element for each thing.
			if(parameter.type == "float") then
			
			end
		end
	end
	
	--Create apply button to allow constructed UI to submit.
	--Todo: implement server hook for generic interface :)
	

end

function ite.onShowWindow()
	ite.inventory:clear();
	ite.populateInventory();
	ite.UpdateUIStatus();
end

function ite.onCloseWindow()
	ite.inventory:clear();
	ite.populateInventory();
	ite.UpdateUIStatus();
end

function ite.clearUI()
	ite.inventory:clear();
	ite.populateInventory();
	
	ite.upgradeTurret:clear();
	ite.upgradeTurret.addEmpty();
	for i =0,4,1 do ite.sacrificeTurrets:addEmpty(); end
	ite.UpdateUIStatus();
end

--Update labels and buttons to reflect the options available.
function ite.UpdateUIStatus()

	ite.modificationDropDown:clear();
	ite.modificationUI:clear();
	
	--if(#ite.upgradeTurret:getItems() > 0) then
	local items = ite.upgradeTurret:getItems()
		 
	if ite.config and tablelength(items) > 0 then 
		print("enabling tab")
		--todo: disable all the buttons on the improvmentTab
			--Populate modification tab box, so options can be selected.
		for name,_ in pairs(ite.config.TurretModificationOptions) do
			ite.modificationDropDown:addEntry(name,ColorRGB(1, 1, 1));
		end
		
		print("enabling tab")
		ite.tabbedWindow:activateTab(ite.modificationTab);
	else
		--Actions to clear/disable elements.
		ite.tabbedWindow:deactivateTab(ite.modificationTab);
		print("disabling tab")
	end

end


--Populate with the inventory which is appropriate; alliance or the individual player.
function ite.populateInventory()
	--todo: systems are not currently filtered out of this.
	player = Player();
	
	if player.allianceIndex and ship.factionIndex == player.allianceIndex then
		ite.inventory:fill(alliance.index);
	else
		ite.inventory:fill(player.index);
	end
	
	print("listing all items");
	for i,reference in pairs(ite.inventory:getItems()) do
	
		if(reference.item.__avoriontype == "InventoryTurret") then --is a turret
			--print("turret " .. reference.item.weaponName);
		else
			--print("not a turret, remove from list");
				--todo: remove the element; this may need to happen outside of the iterator loop...
			ite.inventory:remove(i);
		end
		
		
	end
	
end

function ite.onInventoryClicked(selectionIndex, kx, ky, item, button)
	--print('ite.onInventoryClicked')
	if button == 2 or button == 3 then
		-- fill ite.upgradeTurret first.
		if tablelength(ite.upgradeTurret:getItems()) < 1 then
			ite.moveItem(item, ite.inventory, ite.upgradeTurret, ivec2(kx, ky), nil)
		elseif tablelength(ite.sacrificeTurrets:getItems()) < 5 then
			ite.moveItem(item, ite.inventory, ite.sacrificeTurrets, ivec2(kx, ky), nil)
		end
	end
	ite.UpdateUIStatus();
end


--Function taken from researchstation.lua
function ite.moveItem(item, from, to, fkey, tkey)
    if not item then return end

    if from.index == ite.inventory.index then -- move from inventory to a selection
        -- first, move the item that might be in place back to the inventory
        if tkey then
            ite.addItemToMainSelection(to:getItem(tkey))
            to:remove(tkey)
        end

        ite.removeItemFromMainSelection(fkey)

        -- fix item amount, we don't want numbers in the upper selections
        item.amount = nil
        to:add(item, tkey)

    elseif to.index == ite.inventory.index then
        -- move from selection to ite.inventory
        ite.addItemToMainSelection(item)
        from:remove(fkey)
    end
end


--Function taken from researchstation.lua
function ite.removeItemFromMainSelection(key)
    local item = ite.inventory:getItem(key)
    if not item then return end

    if item.amount then
        item.amount = item.amount - 1
        if item.amount == 0 then item.amount = nil end
    end

    ite.inventory:remove(key)

    if item.amount then
        ite.inventory:add(item, key)
    end
end

--Function taken from researchstation.lua
function ite.addItemToMainSelection(item)
    if not item then return end
    if not item.item then return end

    if item.item.stackable then
        -- find the item and increase the amount
        for k, v in pairs(ite.inventory:getItems()) do
            if v.item and v.item == item.item then
                v.amount = v.amount + 1

                ite.inventory:remove(k)
                ite.inventory:add(v, k)
                return
            end
        end

        item.amount = 1
    end

    -- when not found or not stackable, add it
    ite.inventory:add(item)
end

function ite.onTurretDropped(selectionIndex, kx, ky)
	print('onTurretDropped')
	local selection = Selection(selectionIndex)
	local key = ivec2(kx, ky)
	ite.moveItem(selection:getItem(key), Selection(selectionIndex), ite.inventory, key, nil)
	ite.UpdateUIStatus();
end


function ite.onTurretReceived(selectionIndex, fkx, fky, item, fromIndex, toIndex, tkx, tky)
	print("onTurretReceived");
	if not item then return end
	ite.moveItem(item, ite.inventory, Selection(selectionIndex), ivec2(fkx, fky), ivec2(tkx, tky))
	ite.UpdateUIStatus();
end

--function taken from researchstation.lua
function ite.onTurretClicked(selectionIndex, fkx, fky, item, button)
    if button == 3 or button == 2 then
        ite.moveItem(item, Selection(selectionIndex), ite.inventory, ivec2(fkx, fky), nil)
    end
	ite.UpdateUIStatus();
end

	
function ite.commentedOutBymakingitaseparaterunction()
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
	ite.upgradeTurret = window:createInventorySelection(rect, 1);

	local rect = hsplitleft.bottom;
	rect.width = 150;
	sacrifice = window:createInventorySelection(rect,5);
	
	ite.upgradeTurret.dropIntoEnabled = 1;
	ite.upgradeTurret.entriesSelectable = 0;
	--ite.upgradeTurret.onReceivedFunction = "onite.upgradeTurretReceived"
	--ite.upgradeTurret.onDroppedFunction = "onite.upgradeTurretDropped"
	--ite.upgradeTurret.onClickedFunction = "onite.upgradeTurretClicked"
	
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

function ite.onClickDamage()
   --_,turret = pairs(ite.upgradeTurret:getItems());
end

function ite.onClickCoaxial()
   --_,turret = pairs(sacrifice:getItems());
end