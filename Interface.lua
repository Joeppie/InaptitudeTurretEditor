
local SellableInventoryItem = require("sellableinventoryitem")


-- namespace InaptitudeTurretWindow
InaptitudeTurretWindow = {}

if onClient() then -- CLIENT

	function InaptitudeTurretWindow.interactionPossible(Player)
		return true, ""
	end

	function InaptitudeTurretWindow.getIcon(Seed, Rarity)

		return "data/textures/icons/repair-beam.png"
	end
	
	function InaptitudeTurretWindow.initUI()
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
		window.showCloseButton = 1;
		window.moveable = 1;

		--Split between the turret and the improvement and modifications tabs.
		local hsplit = UIHorizontalSplitter(Rect(window.size), 10, 10, 0.15);
		
		local rect = hsplit.top;
		rect.width = 220;
		
		upgradeTurret = window:createSelection(rect, 2);
		upgradeTurret:addEmpty();
		upgradeTurret.dropIntoEnabled = 1
		upgradeTurret.entriesSelectable = 0
		upgradeTurret.onReceivedFunction = "onTurretReceived"
		upgradeTurret.onDroppedFunction = "onTurretDropped"
		
		window:createLabel(
		upgradeTurret.position,
		"Turret To Upgrade",
		(font2))
		
		tabbedWindow = window:createTabbedWindow(hsplit.bottom)
		
		local improvementTab = tabbedWindow:createTab("Improvement", "data/textures/icons/tools.png", "Improvement");
		
		local improvementVsplit = UIVerticalSplitter(Rect(improvementTab.size), 10, 10, 0.7);

		inventory = improvementTab:createInventorySelection(improvementVsplit.right, 5); --Created as a property, not local.
		inventory.dragFromEnabled = 1
		populateInventory(); --Also grabs systems for the time being, until this is resolved.
		
		local improvmentTabLeftHorizontalsplitter  = UIHorizontalSplitter(improvementVsplit.left, 10, 10, 0.5)
		
		sacrificeTurrets = improvementTab:createSelection(improvmentTabLeftHorizontalsplitter.top, 5);
		
		for i =0,4,1 do sacrificeTurrets:addEmpty(); end
		
		local modificationTab = tabbedWindow:createTab("Modification", "data/textures/icons/tinker.png", "Modification");
		
		--modificationTab.active = false;
		
		
		
	end
	
	function onShowWindow()
		inventory:clear();
		populateInventory();
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
				print("turret " .. reference.item.weaponName);
			else
				print("not a turret, remove from list");
					--todo: remove the element; this may need to happen outside of the iterator loop...
				inventory:remove(i);
			end
			
			
		end
		
	end
	
	
	function onTurretDropped(selectionIndex, kx, ky)
		local selection = Selection(selectionIndex)
		local key = ivec2(kx, ky)
		moveItem(selection:getItem(key), Selection(selectionIndex), inventory, key, nil)
		refreshButton()
	end
	
	
	function onTurretReceived(selectionIndex, fkx, fky, item, fromIndex, toIndex, tkx, tky)
		print("test");
		
		if not item then return end

		-- don't allow dragging from/into the left hand selections
		if fromIndex == sacrificeTurrets.index then
			return
		end

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
		upgradeTurret = window:createSelection(rect, 1);

		local rect = hsplitleft.bottom;
		rect.width = 150;
		sacrifice = window:createSelection(rect,5);
		
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
end

function onClickDamage()
   --_,turret = pairs(upgradeTurret:getItems());
end

function onClickCoaxial()
   --_,turret = pairs(sacrifice:getItems());
end