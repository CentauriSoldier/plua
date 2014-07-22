--[[
> rcall
> Concept and Code By Centauri Soldier
> http://www.github.com/CentauriSoldier/plua
> Version 1.3
>
> This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.
> To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/
> or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
--]]
rcall = {};

local t_rcall = {
	hasBeenReset = false,
	logFile = "",
	methods = {},
	pcallItems = {},
	resItems = {"pcall","coroutine","package","preload","loaded","debug","math","io","string","table","os","error","type","newproxy","pairs","ipairs","require","load","unpack","setmetatable","getmetatable","rawset","rawget","rawequal","getfenv","setfenv","assert","print","gcinfo","module","next","select","collectgarbage","loadfile","xpcall","tostring","tonumber","dofile","loadstring","rcall"},
};



local function isRcall(s_item)

	for n_index, s_pcallItem in pairs(t_rcall.pcallItems) do
		
		if s_item == s_pcallItem then
		return true
		end
		
	end

return false
end



local function isRestricted(s_item)

	for n_index, s_resItem in pairs(t_rcall.resItems) do
		
		if s_item == s_resItem then
		return true
		end
		
	end

return false
end



function forgetFunction(s_function) -- WHY IS THIS NOT LOCAL...? TEST TO SEE IF LOCAL WORKS...

	if t_rcall.methods[s_function] then
	t_rcall.methods[s_function] = nil;
	end
	
end





local function getFunctionStrings(s_function)
s_function = string.gsub(s_function, "_PC_", "");
s_function = string.gsub(s_function, "_XPC_", "%.");
local s_altFunction = "_PC_"..string.gsub(s_function, "%.", "_XPC_").."";
local s_remember = "rememberFunction(\""..s_function.."\", "..s_function..");";
local s_ls = s_altFunction.." = "..s_function..";\r\nfunction "..s_function.."(...)"..[[

local bOK, vRet = rcall(]]..s_altFunction..[[, ...);

	if bOK then
	return vRet
	
	else
	rcall.OnError(vRet);
	
	end

end
]]

return s_ls, s_remember
end



local function protectFunction(s_ls, s_remember)
	
	if type(s_ls) == "string" and type(s_remember) == "string" then
	local f_ls = loadstring(s_ls);
	local f_remember = loadstring(s_remember);
	
		if type(f_ls) == "function" and type(f_remember) == "function" then
		local b_ok, v_ignore = rcall(f_remember);
			
			if b_ok then
			rcall(f_ls);
			end
			
		end
		
	end

end



function recallFunction(s_function)
	
	if t_rcall.methods[s_function] then
	return t_rcall.methods[s_function]
	end
	
end



function rememberFunction(s_function, fFunction)
t_rcall.methods[s_function] = fFunction
end


--DELETE THIS USE FUNCTION
local function table_find(tTable, s_item)
	
	if tTable then
		
		for n_index, sTableItem in pairs(tTable) do
			
			if s_item == sTableItem then
			return n_index
			end
			
		end
		
	end
	
--return false
end



local function unprotectAllFunctions()

	if t_rcall.methods then
		
		for sMethod, fMethod in pairs(t_rcall.methods) do
		local s_ls = sMethod.." = recallFunction(\""..sMethod.."\");\r\nForgetFunction(\""..sMethod.."\");";
		
		--Dialog.Message("", s_ls)
		local f_ls = loadstring(s_ls);
		
			--if f_ls then
			f_ls();
			--end
					
		end		
		
	end

end



--END LOCAL FUNCTIONS, TABLES AND VARIABLES-->>>>>>>>>>>>>>>>



function rcall.AddPCallItem(s_item, bRefresh)
local n_index = table_find(t_rcall.pcallItems, s_item);
	
	if not n_index then
	t_rcall.pcallItems[#t_rcall.pcallItems + 1] = s_item;
		
		if bRefresh then
		rcall.Refresh();
		end
		
	return 0
	
	else
	return 1
	
	end
	
end



function rcall.addResItem(s_item, bRefresh)
local n_index = table_find(t_rcall.resItems, s_item);
	
	if not n_index then
	t_rcall.resItems[#t_rcall.resItems + 1] = s_item;
	
		if bRefresh then
		rcall.Refresh();
		end
		
	return 0
	
	else
	return 1
	
	end
	
end



function rcall.getPCallList()
return t_rcall.pcallItems
end



function rcall.getResList()
return t_rcall.resItems
end



function rcall.onError(sError)
end



function rcall.refresh(sInpTable, tInpTable)
local sTable = ""
local tTable = {};
	
	if not t_rcall.hasBeenReset then
	unprotectAllFunctions();
	t_rcall.hasBeenReset = true;
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
		
			if not isRestricted(vIndex) and (isRcall(vIndex) or isRcall(sTable)) then
															
				if sItemType == "function" then
				s_function  = string.getfuncname(vItem);
				
				local s_ls, s_remember = getFunctionStrings(s_function);
				protectFunction(s_ls, s_remember);
				
				elseif sItemType == "table" then
				rcall.Refresh(vIndex, vItem);
				
				end
			
			end
			
		end
		
	end

t_rcall.hasBeenReset = false;
end



function rcall.RemovePCallItem(s_item, bRefresh)
local n_index = table_find(t_rcall.pcallItems, s_item);

	if n_index then
	table.remove(t_rcall.pcallItems, n_index);	
		
		if bRefresh then
		rcall.Refresh();
		end
		
	return 0
	end
	
return -1	
end



function rcall.RemoveResItem(s_item, bRefresh)
local n_index = table_find(t_rcall.resItems, s_item);

	if n_index then
	tabel.remove(t_rcall.resItems, n_index);
		
		if bRefresh then
		rcall.Refresh();
		end
		
	return 0
	end
	
return -1	
end