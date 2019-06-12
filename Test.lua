




config = require("Config");
print(config.TurretModificationOptions.Coaxial.Enabled);


--Output an analysis of what happens to total maximum statistics supposing all upgrades are sunk into e.g. damage.
for name,q in pairs(config.TurretImprovementOptions.RarityWeights)
do

cumulative = 1;

for i = 0,20000,1
do 
	improvement = config.TurretImprovementOptions.improvementFunction(
	i,q	,config.TurretImprovementOptions.Coefficients);
	
	cumulative  = cumulative * improvement;

	if i < 50 or (i < 5000 and i % 500 == 0) or (i % 5000 == 0) then
		print("5x" .. name .. " q=" .. q .. "mk #" .. i .. " : " .. improvement .. ", \t\t\tcumulative: " .. cumulative)
	end
end

end


