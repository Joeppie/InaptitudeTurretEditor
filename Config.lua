--the config object contains all of the settings for the mod.
local config =
{

	TurretModificationOptions = 
	{
		Coaxial = 
		{
			Enabled = true,
			Cost = nil,
			RelativeCost = 0.5
		},
		IndependentTargeting = 
		{
			 Enabled = true,
			 Cost = nil,
			 RelativeCost = 0.25
		},
		BurstFire = 
		{
			 Enabled = false,
			 Cost = nil,
			 RelativeCost = 0.25
		},
		Size = 
		{
			 Enabled = true,
			 Cost = nil,
			 RelativeCost = 0.1
		},
		Color = 
		{
			 Enabled = true,
			 Cost = nil,
			 RelativeCost = 0.05
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
	}	
}

return config;