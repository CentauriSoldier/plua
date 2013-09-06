local tEscapeChars = {
	[1] = {
		Char = "\\",
		RelacementChar = "\\\\",
	},
	[2] = {
		Char = "\a",
		RelacementChar = "\\a",
	},
	[3] = {
		Char = "\b",
		RelacementChar = "\\b",
	},
	[4] = {
		Char = "\f",
		RelacementChar = "\\f",
	},
	[5] = {
		Char = "\r\n",
		RelacementChar = "\\r\\n",
	},
	[6] = {
		Char = "\t",
		RelacementChar = "\\t",
	},
	[7] = {
		Char = "\v",
		RelacementChar = "\\v",
	},
	[8] = {
		Char = "\"",
		RelacementChar = "\\\"",
		},
	[9] = {
		Char = "\'",
		RelacementChar = "\\'",
	},	 
	[10] = {
		Char = "%[",
		RelacementChar = "%%[",
		},
	[11] = {
		Char = "%]",
		RelacementChar = "%%]",
		},
	--[[
	[10] = {
		Char = "%[",
		RelacementChar = "\\[",
		},
	[11] = {
		Char = "%]",
		RelacementChar = "\\]",
		},
		]]
};


local function GetFunctionName(fFunc)

if type(fFunc) == "function" then

	for vIndex, vItem in pairs(getfenv(fFunc)) do
		
		if vIndex ~= "_G" then
		local sItemType = type(vItem);
			
			if sItemType == "function" then
				
				if vItem == fFunc then
				return vIndex
				end
			
			elseif sItemType == "table" then
				
				for vIndex2, vItem2 in pairs(vItem)	do
				local sItemType2 = type(vItem2);
	
					if sItemType2 == "function" then
				
						if vItem2 == fFunc then
						return vIndex.."."..vIndex2
						end
					
					elseif sItemType2 == "table" then
					
						for vIndex3, vItem3 in pairs(vItem2) do
						local sItemType3 = type(vItem3);
			
							if sItemType3 == "function" then
						
								if vItem3 == fFunc then
								return vIndex.."."..vIndex2.."."..vIndex3
								end
													
							end
							
						end			
							
					end
					
				end
				
			end
			
		end
	
	end
	
end
	
return ""
end



function table.dump(pFile, tTable, bAppend)
assert(type(pFile) == "string", "File path must be a string.");
assert(type(tTable) == "table", "Input table must be of type table.");

local sOpenType = "wb";

	if bAppend then
	sOpenType = sOpenType.."+";
	end

	local hFile = assert(io.open(pFile, sOpenType), "Error in file: "..pFile.."\r\nDestination file could not be created or opened.\r\nPerhaps you do not have the required permissions for this action.");

	if hFile then
	hFile:write(table.tostring(tTable, 0));
	
	hFile:close();
	end

end



function table.find(tInput, vValue)
	
	if type(tInput) == "table" then
		
		for nIndex, vExistingValue in pairs(tInput) do
			
			if vExistingValue == vValue then
			return nIndex
			end
			
		end
		
	end	
	
end



function table.getassocorder(tTable, fCompare)
local tReturn = {};

if type(tTable) == "table" then

	for sIndex, vValue in pairs(tTable) do
	tReturn[#tReturn + 1] = sIndex;
	end

	table.sort(tReturn, fCompare);

end

return tReturn
end



--[[
The number(argument #2) tells
the function how many indents
we want from the start. This can be 0.
]]
function table.tostring(tInput, nStartCount)
local sRet = "";
local nCount = 0;
	
	if type(nStartCount) == "number" then
	nCount = nStartCount;
	end

local sTab = "";

for x = 1, nCount do
sTab = sTab.."\t";
end

local sIndexTab = sTab.."\t";

nCount = nCount + 1;

	if type(tInput) == "table" then
	sRet = sRet.."{\r\n";
				
		for vIndex, vItem in pairs(tInput) do
		local sIndexType = type(vIndex);
		local sItemType = type(vItem);
		local sIndex = "";
				
			--write the index to string
			if sIndexType == "number" then
			sRet = sRet..sTab.."["..vIndex.."] = ";
					
			elseif sIndexType == "string" then
							
				if string.find(vIndex, '%W', 1) then
				sIndex = sIndexTab.."[\""..vIndex.."\"] = ";
				else
				sIndex = sIndexTab..vIndex.." = ";
				end
						
			end
			
			--write the item to string
			if sItemType == "number" then
			sRet = sRet..sIndex..vItem..",\r\n"
			
			elseif sItemType == "string" then
			
				for nIndex, tChar in pairs(tEscapeChars) do
				vItem = string.gsub(vItem, tChar.Char, tChar.RelacementChar);
				end
			
			sRet = sRet..sIndex.."\""..vItem.."\",\r\n";
			
			elseif sItemType == "boolean" then
			
				if vItem then
				sRet = sRet..sIndex.."true,\r\n";
				else
				sRet = sRet..sIndex.."false,\r\n";
				end
			
			elseif sItemType == "nil" then
			sRet = sRet..sIndex.."nil,\r\n";
			
			elseif sItemType == "function" then
			sRet = sRet..sIndex..GetFunctionName(vItem, getfenv(vItem), "")..",\r\n";
									
			elseif sItemType == "userdata" then
			sRet = sRet..sIndex.."\"_USERDATA_\",\r\n"
			
			elseif sItemType == "table" then
			sRet = sRet..sIndex..table.tostring(vItem, nCount)..",\r\n";			
			
			end
			
		end
			
	end

sRet = sRet..sTab.."}"

return sRet
end