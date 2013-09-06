function io.addsafefunctions(tFunctions)

	if type(tFunctions) == "table" then
		
		for nIndex, sResFunction in pairs(tFunctions) do
			
			if type(sResFunction) == "string" then
							
				if not table.find(tIO.ResFunctions, sResFunction) then
				tIO.ResFunctions[#tIO.ResFunctions + 1] = sResFunction;
				end
				
			end
			
		end
		
	end

end



function io.scriptissafe(pFile, tResFunctionList)
local sScript = "";
local tFunctions = LuaExt.GetRestrictedFunctions();
local bOK, hFile = pcall(io.open, pFile, "rb");

	if not bOK or not hFile then
	return false, "could not open file for reading";
	end

	sScript = hFile:read("*all");
		
	if type(tResFunctionList) == "table" then
	tFunctions = tResFunctionList
	end

	for nIndex, sFunction in pairs(tFunctions) do		
	local nLastFound = 1;
		
		repeat
		local nFound = string.find(sScript, sFunction, nLastFound);
			
			if nFound then
			nLastFound = nFound + 1;
			local nLength = string.len(sFunction);
			local nFailCount = 0;
			local sBefore = string.sub(sScript, (nFound - 1), (nFound - 1));
			local sAfter = string.sub(sScript, (nFound + nLength), (nFound + nLength));
							
				if not string.find(sBefore, '[_%a]') then
					
					--if not string.find(sBefore, '_') then
					nFailCount = nFailCount + 1;
					--end
					
				end
				
				if not string.find(sAfter, '[_%a]') then
					
					--if not string.find(sBefore, '_') then
					nFailCount = nFailCount + 1;
					--end
								
				end
				
				if nFailCount > 1 then
				return false, sFunction
				end
				
			
			end
		
		until not nFound
			
	end	
	
return true
end