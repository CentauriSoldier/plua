--[[########################################################################
#	 																	| PCall |																				#
#  											 | Concept and Code By Centauri Soldier |															#
#  									  | http://www.github.com/CentauriSoldier/LuaPlugs |													#
#													  |||>>>|| VERSION 1.2 ||<<<|||																#
#													  																											#
#		This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.								#
#		To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/											#
#		or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.			#
#########################################################################]]
PCall = {};

local tPCall = {
	HasBeenReset = false,
	LogFile = "",
	Methods = {},
	PCallItems = {},
	ResItems = {"PCall","coroutine","package","preload","loaded","debug","math","io","string","table","os","error","type","newproxy","pairs","ipairs","require","load","unpack","setmetatable","getmetatable","rawset","rawget","rawequal","getfenv","setfenv","assert","print","gcinfo","module","next","select","collectgarbage","loadfile","xpcall","tostring","tonumber","dofile","loadstring","pcall"},
};



local function IsPCall(sItem)

	for nIndex, sPCallItem in pairs(tPCall.PCallItems) do
		
		if sItem == sPCallItem then
		return true
		end
		
	end

return false
end



local function IsRestricted(sItem)

	for nIndex, sResItem in pairs(tPCall.ResItems) do
		
		if sItem == sResItem then
		return true
		end
		
	end

return false
end



function ForgetFunction(sFunction)

	if tPCall.Methods[sFunction] then
	tPCall.Methods[sFunction] = nil;
	end
	
end



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



local function GetFunctionStrings(sFunction)
sFunction = string.gsub(sFunction, "_PC_", "");
sFunction = string.gsub(sFunction, "_XPC_", "%.");
local sAltFunction = "_PC_"..string.gsub(sFunction, "%.", "_XPC_").."";
local sRemember = "RememberFunction(\""..sFunction.."\", "..sFunction..");";
local sLS = sAltFunction.." = "..sFunction..";\r\nfunction "..sFunction.."(...)"..[[

local bOK, vRet = pcall(]]..sAltFunction..[[, ...);

	if bOK then
	return vRet
	
	else
	PCall.OnError(vRet);
	
	end

end
]]

return sLS, sRemember
end



local function ProtectFunction(sLS, sRemember)
	
	if type(sLS) == "string" and type(sRemember) == "string" then
	local fLS = loadstring(sLS);
	local fRemember = loadstring(sRemember);
	
		if type(fLS) == "function" and type(fRemember) == "function" then
		local bOk, vIgnore = pcall(fRemember);
			
			if bOk then
			pcall(fLS);
			end
			
		end
		
	end

end



function RecallFunction(sFunction)
	
	if tPCall.Methods[sFunction] then
	return tPCall.Methods[sFunction]
	end
	
end



function RememberFunction(sFunction, fFunction)
tPCall.Methods[sFunction] = fFunction
end



local function table_find(tTable, sItem)
	
	if tTable then
		
		for nIndex, sTableItem in pairs(tTable) do
			
			if sItem == sTableItem then
			return nIndex
			end
			
		end
		
	end
	
--return false
end



local function UnprotectAllFunctions()

	if tPCall.Methods then
		
		for sMethod, fMethod in pairs(tPCall.Methods) do
		local sLS = sMethod.." = RecallFunction(\""..sMethod.."\");\r\nForgetFunction(\""..sMethod.."\");";
		
		--Dialog.Message("", sLS)
		local fLS = loadstring(sLS);
		
			--if fLS then
			fLS();
			--end
					
		end		
		
	end

end



--END LOCAL FUNCTIONS, TABLES AND VARIABLES-->>>>>>>>>>>>>>>>



function PCall.AddPCallItem(sItem, bRefresh)
local nIndex = table_find(tPCall.PCallItems, sItem);
	
	if not nIndex then
	tPCall.PCallItems[#tPCall.PCallItems + 1] = sItem;
		
		if bRefresh then
		PCall.Refresh();
		end
		
	return 0
	
	else
	return 1
	
	end
	
end



function PCall.AddResItem(sItem, bRefresh)
local nIndex = table_find(tPCall.ResItems, sItem);
	
	if not nIndex then
	tPCall.ResItems[#tPCall.ResItems + 1] = sItem;
	
		if bRefresh then
		PCall.Refresh();
		end
		
	return 0
	
	else
	return 1
	
	end
	
end



function PCall.GetPCallList()
return tPCall.PCallItems
end



function PCall.GetResList()
return tPCall.ResItems
end



function PCall.OnError(sError)
end



function PCall.Refresh(sInpTable, tInpTable)
local sTable = ""
local tTable = {};
	
	if not tPCall.HasBeenReset then
	UnprotectAllFunctions();
	tPCall.HasBeenReset = true;
	end
	
	
	if type(sInpTable) == "string" then
	sTable = sInpTable;
	end
	
	if type(tInpTable) == "table" then
	tTable = tInpTable;
	
	else
	tTable = _G;
	
	end
	
local tCurrentTable = tTable;
	
	if tTable[sTable] then
	tCurrentTable = tTable[sTable];
	end
		
	for vIndex, vItem in pairs(tCurrentTable) do
	local sItemType = type(vItem);
			
		if type(vIndex) == "string" then
		
			if not IsRestricted(vIndex) and (IsPCall(vIndex) or IsPCall(sTable)) then
															
				if sItemType == "function" then
				sFunction  = GetFunctionName(vItem);
				
				local sLS, sRemember = GetFunctionStrings(sFunction);
				ProtectFunction(sLS, sRemember);
				
				elseif sItemType == "table" then
				PCall.Refresh(vIndex, vItem);
				
				end
			
			end
			
		end
		
	end

tPCall.HasBeenReset = false;
end



function PCall.RemovePCallItem(sItem, bRefresh)
local nIndex = table_find(tPCall.PCallItems, sItem);

	if nIndex then
	table.remove(tPCall.PCallItems, nIndex);	
		
		if bRefresh then
		PCall.Refresh();
		end
		
	return 0
	end
	
return -1	
end



function PCall.RemoveResItem(sItem, bRefresh)
local nIndex = table_find(tPCall.ResItems, sItem);

	if nIndex then
	tabel.remove(tPCall.ResItems, nIndex);
		
		if bRefresh then
		PCall.Refresh();
		end
		
	return 0
	end
	
return -1	
end