--the config object contains all of the settings for the mod.
local config =
{	
	--Each entry below denotes the name, cost, and parameters of individual modifications that can be done.
	--Each modification does not consume turrets. Future additions may require systems or turrets to sacrifice.
	TurretModificationOptions = 
	{
		["Independent Targeting"] = 
		{
			Description = "By adding automated servos, a command module and targeting systems, a turret can fire freely at targets of its own accord." ,
			Enabled = true,
			Cost = nil,
			RelativeCost = 0.25,
			Parameters = 
			{
				["Independent Targeting"] =  
				{
						acessor ="IndependentTargeting",
						Description = "Independent Targeting",
						type="bool"
				}
			}
		},
		Burstfire = 
		{
			Description = "Burstfire allows a turret to fire much faster, but it is an ugly engingeering hack, how it affects a turret varies and depends on the turrets design." ,
			Enabled = false,
			Cost = nil,
			RelativeCost = 0.25,
			Parameters = 
			{
				Burstfire =  
				{
						acessor ="Burstfire",
						Description = "Burstfire enabled?",
						type="bool"
				}
			}
		},
		-- Name = 
		-- {
			-- Description = "`There are people who believe it's bad luck for a gun not to have a name, and some guns just seem to pick up a nickname.`" ,
			-- Enabled = false,
			-- Cost = nil,
			-- RelativeCost = 0.25,
			-- Parameters = 
			-- {
				-- Name = 
				-- {
					-- acessor ="TurretName",
					-- type="string",
					-- Description = "Changes the name of your turret",
				-- }
			-- }
		-- },
		Size = 
		{
			Description = "Modifying the size of a turret makes it either more compact, or more intimidating. Minimizing turret profile is useful for coaxially mounted ones especially.",
			Enabled = true,
			Cost = nil,
			RelativeCost = 0.1,
			Parameters = 
			{
				Size = 
				{
					acessor ="Size",
					type="float",
					Description = "Changes the physical size of the turret",
					min = 0.5,
					max = 5,
					steps = 10
				}
			}
		},
		Color = 
		{
			Description = "Bring some color to your life.. or your enemies' death.",
			Enabled = true,
			Cost = 5000,
			RelativeCost = nil,
			Parameters = 
			{
				Red = 
				{
					acessor ="ColorRed",
					Description = "Red",
					type = "float",
					min = 0,
					max = 255,
					steps = 255
				},
				Green = 
				{
					acessor ="ColorGreen",
					Description = "Green",
					type = "float",
					min = 0,
					max = 255,
					steps = 255
				},
				Blue = 
				{
					acessor ="ColorBlue",
					Description = "Blue",
					type = "float",
					min = 0,
					max = 255,
					steps = 255
				}
			}
		},
		Coaxial = 
		{
			Description = "By sacrificing dampeners and the ability of a turret to re-align itself with targets, far greater firepower and energy flow can safely be achieved.",
			Enabled = true,
			Cost = nil,
			RelativeCost = 0.5,
			Parameters = 
			{
				Coaxial =  
				{
						acessor ="Coaxial",
						Description = "Toggle Coaxial",
						type="bool"
				}
			}
		}
	},
	TurretImprovementOptions = 
	{
		RarityWeights =
		{
			Common 		= 1/6,
			Uncommon 	= 2/6,
			Rare		= 3/6,
			Exceptional	= 4/6,
			Exotic		= 5/6,
			Legendary	= 6/6,
		},
		Coefficients = 
		{
			--Initial improvement will be 20% with base improvement value.
			baseImprovement = 0.3,
			--default: after every upgrade, the next upgrade only has 90% the strength, modify as desired.
			decreaseExponent = 0.75,
			--mimum upgrade factor, this means you could always upgrade a turret even if just by a little, but it doesn't really do much unless you are absolutely obsessed and mad, like General Inaptitude is.
			minimumIncrement =  0.00001 --scales with quality.
		},
		improvementFunction = 
		function(markNumber,quality,coefficients)
		
			--e.g. 1  + 0.2 * 0.9^1 = 1.18; after the first upgrade.
			local calculated =  1+ 
			(   coefficients.baseImprovement * quality * 
				math.pow(coefficients.decreaseExponent,markNumber)  )
			
			--calculated minimum increment 
			mincrement =  1+coefficients.minimumIncrement*quality
			
			if calculated <mincrement   then 
				return mincrement;
			else
				return calculated;
			end	
			
		end
	},
}

return config;