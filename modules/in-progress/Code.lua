--[[Description
<p>The Code Action Plugin allows for unconventional means of code manipulation by implementing a goto method as well as providing other functionality such as a UUID generation.</p>
]]
--[[Features
<ul class="comments_list_features">
	<li>Allows the settings of code sections for Goto reference</li>
	<li>Custom UUID generation</li>
</ul>
]]
--[[Version History
<p><b>Version 1.0.0.0</b></p>
<p>Absorbed the Goto Action Plugin.</p>
<p>Updated the IRLua Plugin Helper Functions v2.9.</p>
]]
--#########################################################################################################
-- IRLUA PLUGIN HELPER FUNCTIONS By MicroByte (Revised by Centauri Soldier) ||@#$|| VERSION 2.9 ||$#@|| 
--#########################################################################################################
_ShowErrorEventContext=true-- set this to false to disable 'EventContext' display
--#########################################################################################################
local IRLUA_PLUGIN_ERROR = error;
--#########################################################################################################
-- Sets a Global error message in the runtime engine.
IRLUA_PLUGIN_SetGlobalErrorMessage = function(nCode, sMessage)
	if _tblErrorMessages[nCode] then
		if _ShowErrorEventContext then
			local sEventContext=Debug.GetEventContext()
			IRLUA_PLUGIN_ERROR("Error code "..nCode.." already in use, please use another.\r\n\r\nEventContext: "..sEventContext,2)
		else
			IRLUA_PLUGIN_ERROR("Error code "..nCode.." already in use, please use another.",2)
		end
	else
		_tblErrorMessages[nCode]=sMessage
	end
end
--#########################################################################################################
-- Checks the number of arguments in the table and throws a syntax error If there are Not enough. 
-- This is useful For checking the number of arguments available To your aciton.
local IRLUA_PLUGIN_CheckNumArgs = function(tbArgs,nArgs) 
	local nCount=table.getn(tbArgs)
	if nCount < nArgs then
		if _ShowErrorEventContext then
			local sEventContext=Debug.GetEventContext()
			IRLUA_PLUGIN_ERROR(nArgs.." Arguments expected, "..nCount.." Arguments passed.\r\n\r\nEventContext: "..sEventContext,3)
		else
			IRLUA_PLUGIN_ERROR(nArgs.." Arguments expected, "..nCount.." Arguments passed.",3)
		end
	end
end
--#########################################################################################################
-- Checks the value at a given argument table position To see if it is any of the specified types.
-- If Not it throws a syntax error.
--Possible variable types[ boolean, function, nil, number, string, table, thread, userdata]
local IRLUA_PLUGIN_CheckTypes = function(tbArgs,nArg,tTypes)
local sType = type(tbArgs[nArg]);
local nTotalTypes = Table.Count(tTypes);
local nStrikes = 0;
local sAllowedTypes = "";

for nIndex, sAllowedType in pairs(tTypes) do
	
	if nIndex < (nTotalTypes - 1) then
	sAllowedTypes = sAllowedTypes.." "..sAllowedType..",";
	elseif nIndex == nTotalTypes - 1 then
	sAllowedTypes = sAllowedTypes.." "..sAllowedType;
	elseif nIndex == nTotalTypes then
		if nTotalTypes == 1 then
		sAllowedTypes = " "..sAllowedType;
		else
		sAllowedTypes = sAllowedTypes.." or "..sAllowedType;
		end
	end
	
	if sType ~= String.Lower(sAllowedType) then
	nStrikes = nStrikes + 1;
	end
end

if nStrikes == nTotalTypes then
	if _ShowErrorEventContext then
	local sEventContext=Debug.GetEventContext()
	IRLUA_PLUGIN_ERROR("bad argument #" .. nArg .. ", must be a "..sAllowedTypes..", you passed a "..sType..".\r\n\r\nEventContext: "..sEventContext,3)
	else
	IRLUA_PLUGIN_ERROR("bad argument #" .. nArg .. ", must be a "..sAllowedTypes..", you passed a "..sType..".",3)
	end
else
return tbArgs[nArg]
end
end
--#########################################################################################################
-- Ensures that your table contains data of only the specified type. If it does not then false is returned.
-- This will see nil values as subtable declarations and will, therefore, ignore them.
local IRLUA_PLUGIN_CheckTableVars = function(tTable,tVarTypes)
local bRet = true;
local nTypes = Table.Count(tVarTypes);
local nStrikes = 0;

for nIndex, sItem in pairs(tTable) do
nStrikes = 0;

	for nType, sType in pairs(tVarTypes) do

		if type(sItem) ~= sType then
		nStrikes = nStrikes + 1;
		end
			
	end
	
	if nStrikes >= nTypes then
	bRet = false;
	break;
	end

end
return bRet
end
--#########################################################################################################
-- Converts certain datatypes into other datatypes ||| Supported Types |||
-- [String <-> Boolean] [Number <-> Boolean] [String <-> Number]
--#########################################################################################################
local CONVERT = function (vInput, sNewType)
local sOldType = type(vInput);

if sNewType == "boolean" then

	if sOldType == "string" then

		if String.Lower(vInput) == "true" then
		return true
		elseif String.Lower(vInput) == "false" then
		return false
		end
		
	elseif sOldType == "number" then
		
		if vInput == 0 then
		return false
		elseif vInput == 1 then
		return true
		end
	
	elseif sOldType == "table" then
	
		if vInput then
		return true
		else
		return false
		end
	
	else
	
	return false	
	end

elseif sNewType == "string"	then
	
	if sOldType == "boolean" then
	
		if vInput == true then
		return "true"
		elseif vInput == false then
		return "false"
		end
	
	elseif sOldType == "number" then
	return ""..vInput..""
	
	else
	
	return ""
	end

elseif sNewType == "number" then
	
	if sOldType == "boolean" then
	
		if vInput == true then
		return 1
		elseif vInput == false then
		return 0
		end
	
	elseif sOldType == "string" then
	
	return tonumber(vInput)				
	
	else
	
	return -1
	end

end
end
--#########################################################################################################
--ERROR PLUGIN DETAILS
local ERROR_PLUGIN_NAME = "Code";
--#########################################################################################################
--Displays a custom error message using the plugin and function name and lists the event context as well.
local ERROR = function(sFunctionName,sMessage,nEmbedLevel)

if not nEmbedLevel then
nEmbedLevel = 0;
elseif type(nEmbedLevel) ~= "number" then
nEmbedLevel = 0;
end

if type(sFunctionName) ~= "string" then
sFunctionName = "";
end	

local sFunctionNameCode = "";
if String.Replace(sFunctionName, " ", "", false) ~= "" then
sFunctionNameCode = ", function \""..sFunctionName.."()\"";
end

IRLUA_PLUGIN_ERROR("\r\nError in \""..ERROR_PLUGIN_NAME.."\" plugin"..sFunctionNameCode.."\r\n\r\n"..sMessage.."\r\n\r\nEventContext: "..Debug.GetEventContext(),3 + nEmbedLevel);
end
--#########################################################################################################
--Throws and error if the required plugin is not loaded. This should be called at the called at the
--beginning of each function, once for each required plugin.
--NOTE: This may be called at once only at the start of your plugin script if the required plugin is after your plugin alphabetically
local REQUIRE = function(tPlugin,sPluginName)
if not tPlugin then
IRLUA_PLUGIN_ERROR("\r\nError loading the \""..ERROR_PLUGIN_NAME.."\" plugin.\r\nThis plugin requires the \""..sPluginName.."\" plugin.");
end
end
--#########################################################################################################
-- END IRLUA PLUGIN HELPER FUNCTIONS
--#########################################################################################################
Code = {};

--===========================
-- Code.GenerateUUID
--===========================
function Code.GenerateUUID(...)
IRLUA_PLUGIN_CheckNumArgs(arg, 0)
local sPrefix = IRLUA_PLUGIN_CheckTypes(arg, 1,{"string","nil"});
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
local tChars = {"x","3","y","1","b","2","p","e","8","f","v","t","g","9","h","7","u","4","i","z","a","j","0","c","k","l","5","m","n","w","o","q","r","s","d","6"};
local tSequence = {1,4,4,4,12};
local sSSID = "";
local nMaxPrefixLength = 6; --range from 0 to 8
local sDelimiter = "-";

if sPrefix then
local nLength = String.Length(sPrefix);
	
	if nLength > nMaxPrefixLength then
	sPrefix = String.Mid(sPrefix, 1, nMaxPrefixLength);
	end
	
	if String.Replace(sPrefix, " ", "", false) ~= "" then
	sSSID = sPrefix..sDelimiter;
	end
	
	if nLength < nMaxPrefixLength then
	tSequence[1] = tSequence[1] + (nMaxPrefixLength - nLength);
	end
	
else
tSequence[1] = 8;
end

for nIndex, nSequence in pairs(tSequence) do
	
	for x = 1, nSequence do
	sSSID = sSSID..tChars[Math.Random(1, 36)];
	end

sSSID = sSSID.."-";
end

sSSID = String.TrimRight(sSSID, "-");
return sSSID
end


--=================================
-- Code.GetEventScript
--=================================
function Code.GetEventScript(...)
IRLUA_PLUGIN_CheckNumArgs(arg, 2)
local sPageorDialog = IRLUA_PLUGIN_CheckString(arg, 1,{"string"});
local sEvent = IRLUA_PLUGIN_CheckTypes(arg, 2,{"string"});
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if Application.GetCurrentDialog() ~= "" then
return Application.GetDialogScript(sPageorDialog, sEvent);
else
return Application.GetPageScript(sPageorDialog, sEvent);
end
end



--=================================
-- Code.GetObjectScript
--=================================
function Code.GetObjectScript(...)
IRLUA_PLUGIN_CheckNumArgs(arg, 2)
local sObject = IRLUA_PLUGIN_CheckTypes(arg, 1,{"string"});
local sEvent = IRLUA_PLUGIN_CheckTypes(arg, 2,{"string"});
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if Application.GetCurrentDialog() ~= "" then
return DialogEx.GetObjectScript(sObject, sEvent);
else
return Page.GetObjectScript(sObject, sEvent);
end
end



--=========================
-- Code.GotoEventLine
--=========================
function Code.GotoEventLine(...)
IRLUA_PLUGIN_CheckNumArgs(arg, 3)
local sPageorDialog = IRLUA_PLUGIN_CheckTypes(arg, 1,{"string"});
local sPageEvent = IRLUA_PLUGIN_CheckTypes(arg, 2,{"string"});
local nLineNumber = IRLUA_PLUGIN_CheckTypes(arg, 3,{"number"});
local tFullCode = CSG.DelimitedStringToTable(GetEventScript(sPageorDialog, sPageEvent), "\r\n");
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if tFullCode then

local nCodeLines = Table.Count(tFullCode);

	if nCodeLines - nLineNumber >= 0 then
	local sNewCode = "";
	
		for x = 1, nCodeLines do
			
			if tFullCode[(nLineNumber - 1) + x] == nil then
			sAddCode = "";
			else
			sAddCode = tFullCode[(nLineNumber - 1) + x];
			end
			
		sNewCode = sNewCode.."\r\n"..sAddCode;
		end
		
	loadstring(sNewCode)();
	sNewCode = nil;
	end

end

end



--==============================
-- Code.GotoEventSection
--==============================
function Code.GotoEventSection(...)
IRLUA_PLUGIN_CheckNumArgs(arg,3);
local sPageorDialog = IRLUA_PLUGIN_CheckTypes(arg, 1,{"string"});
local sPageEvent = IRLUA_PLUGIN_CheckTypes(arg, 2,{"string"});
local sSection = IRLUA_PLUGIN_CheckTypes(arg, 3,{"string"});
local tFullCode = CSG.DelimitedStringToTable(CSG.GetEventScript(sPageorDialog, sPageEvent), "\r\n");
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if tFullCode and Table.Count(tFullCode) > 0 then

local nCodeLines = Table.Count(tFullCode);

	for x = 1, nCodeLines do
	nOpenFound = String.Find(tFullCode[x], "<"..sSection..">", 1, true);
		if nOpenFound ~= -1 then
		nOpenFound = x;
		break
		end
	end
	
	for x = 1, nCodeLines do
	nCloseFound = String.Find(tFullCode[x], "</"..sSection..">", 1, true);
		if nCloseFound ~= -1 then
		nCloseFound = x;
		break
		end
	end

	if nOpenFound ~= -1 and nCloseFound ~= -1 then
	local sNewCode = "";
	
		for x = nOpenFound, nCloseFound do
				
			if tFullCode[x] == nil then
			sAddCode = "";
			else
			sAddCode = tFullCode[x];
			end
				
		sNewCode = sNewCode.."\r\n"..sAddCode;		
		end
	
	loadstring(sNewCode)();
	sNewCode = nil;
	end
	
end

end



--=========================
-- Code.GotoObjectLine
--=========================
function Code.GotoObjectLine(...)
IRLUA_PLUGIN_CheckNumArgs(arg, 3)
local sObject = IRLUA_PLUGIN_CheckTypes(arg,1,{"string"});
local sEvent = IRLUA_PLUGIN_CheckTypes(arg,2,{"string"});
local nLineNumber = IRLUA_PLUGIN_CheckTypes(arg,3,{"number"});
local tFullCode = CSG.DelimitedStringToTable(CSG.GetObjectScript(sObject, sEvent), "\r\n");
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if tFullCode then

local nCodeLines = Table.Count(tFullCode);

	if nCodeLines - nLineNumber >= 0 then
	local sNewCode = "";
	
		for x = 1, nCodeLines do
			
			if tFullCode[(nLineNumber - 1) + x] == nil then
			sAddCode = "";
			else
			sAddCode = tFullCode[(nLineNumber - 1) + x];
			end
			
		sNewCode = sNewCode.."\r\n"..sAddCode;
		end
		
	loadstring(sNewCode)();
	sNewCode = nil;
	end

end

end



--=========================
-- Code.GotoObjectSection
--=========================
function Code.GotoObjectSection(...)
IRLUA_PLUGIN_CheckNumArgs(arg, 3)
local sObject = IRLUA_PLUGIN_CheckTypes(arg, 1,{"string"});
local sEvent = IRLUA_PLUGIN_CheckTypes(arg, 2,{"string"});
local sSection = IRLUA_PLUGIN_CheckTypes(arg, 3,{"string"});
local tFullCode = CSG.DelimitedStringToTable(CSG.GetObjectScript(sObject, sEvent), "\r\n");
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if tFullCode and Table.Count(tFullCode) > 0 then

local nCodeLines = Table.Count(tFullCode);

	for x = 1, nCodeLines do
	nOpenFound = String.Find(tFullCode[x], "<"..sSection..">", 1, true);
		if nOpenFound ~= -1 then
		nOpenFound = x;
		break
		end
	end
	
	for x = 1, nCodeLines do
	nCloseFound = String.Find(tFullCode[x], "</"..sSection..">", 1, true);
		if nCloseFound ~= -1 then
		nCloseFound = x;
		break
		end
	end

	if nOpenFound ~= -1 and nCloseFound ~= -1 then
	local sNewCode = "";
	
		for x = nOpenFound, nCloseFound do
				
			if tFullCode[x] == nil then
			sAddCode = "";
			else
			sAddCode = tFullCode[x];
			end
				
		sNewCode = sNewCode.."\r\n"..sAddCode;		
		end
	
	loadstring(sNewCode)();
	sNewCode = nil;
	end
	
end

end



--=========================
-- Code.GotoScriptFileLine
--=========================
function Code.GotoScriptFileLine(...)
IRLUA_PLUGIN_CheckNumArgs(arg, 2)
local sScriptFile = IRLUA_PLUGIN_CheckTypes(arg,1,{"string"});
local nLineNumber = IRLUA_PLUGIN_CheckTypes(arg,2,{"number"});
local tFullCode = TextFile.ReadToTable(sScriptFile);
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if tFullCode then

local nCodeLines = Table.Count(tFullCode);

	if nCodeLines - nLineNumber >= 0 then
	local sNewCode = "";
	
		for x = 1, nCodeLines do
			
			if tFullCode[(nLineNumber - 1) + x] == nil then
			sAddCode = "";
			else
			sAddCode = tFullCode[(nLineNumber - 1) + x];
			end
			
		sNewCode = sNewCode.."\r\n"..sAddCode;
		end
		
	loadstring(sNewCode)();
	sNewCode = nil;
	end

end

end



--===========================
-- Code.GotScriptFileSection
--===========================
function Code.GotoScriptFileSection(...)
IRLUA_PLUGIN_CheckNumArgs(arg, 2)
local sScriptFile = IRLUA_PLUGIN_CheckTypes(arg, 1,{"string"});
local sSection = IRLUA_PLUGIN_CheckTypes(arg, 2,{"string"});
local tFullCode = TextFile.ReadToTable(sScriptFile);
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if tFullCode and Table.Count(tFullCode) > 0 then

local nCodeLines = Table.Count(tFullCode);

	for x = 1, nCodeLines do
	nOpenFound = String.Find(tFullCode[x], "<"..sSection..">", 1, true);
		if nOpenFound ~= -1 then
		nOpenFound = x;
		break
		end
	end
	
	for x = 1, nCodeLines do
	nCloseFound = String.Find(tFullCode[x], "</"..sSection..">", 1, true);
		if nCloseFound ~= -1 then
		nCloseFound = x;
		break
		end
	end

	if nOpenFound ~= -1 and nCloseFound ~= -1 then
	local sNewCode = "";
	
		for x = nOpenFound, nCloseFound do
				
			if tFullCode[x] == nil then
			sAddCode = "";
			else
			sAddCode = tFullCode[x];
			end
				
		sNewCode = sNewCode.."\r\n"..sAddCode;		
		end
	
	loadstring(sNewCode)();
	sNewCode = nil;
	end
	
end

end



--=========================
-- Code.GotoScriptLine
--=========================
function Code.GotoScriptLine(...)
IRLUA_PLUGIN_CheckNumArgs(arg, 2)
local sScript = IRLUA_PLUGIN_CheckTypes(arg,1,{"string"});
local nLineNumber = IRLUA_PLUGIN_CheckTypes(arg,2,{"number"});
local tFullCode = CSG.DelimitedStringToTable(sScript, "\r\n");
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if tFullCode then

local nCodeLines = Table.Count(tFullCode);

	if nCodeLines - nLineNumber >= 0 then
	local sNewCode = "";
	
		for x = 1, nCodeLines do
			
			if tFullCode[(nLineNumber - 1) + x] == nil then
			sAddCode = "";
			else
			sAddCode = tFullCode[(nLineNumber - 1) + x];
			end
			
		sNewCode = sNewCode.."\r\n"..sAddCode;
		end
		
	loadstring(sNewCode)();
	sNewCode = nil;
	end

end

end



--=========================
-- Code.GotoScriptSection
--=========================
function Code.GotoScriptSection(...)
IRLUA_PLUGIN_CheckNumArgs(arg, 2)
local sScript = IRLUA_PLUGIN_CheckTypes(arg, 1,{"string"});
local sSection = IRLUA_PLUGIN_CheckTypes(arg, 2,{"string"});
local tFullCode = CSG.DelimitedStringToTable(sScript, "\r\n");
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if tFullCode and Table.Count(tFullCode) > 0 then

local nCodeLines = Table.Count(tFullCode);

	for x = 1, nCodeLines do
	nOpenFound = String.Find(tFullCode[x], "<"..sSection..">", 1, true);
		if nOpenFound ~= -1 then
		nOpenFound = x;
		break
		end
	end
	
	for x = 1, nCodeLines do
	nCloseFound = String.Find(tFullCode[x], "</"..sSection..">", 1, true);
		if nCloseFound ~= -1 then
		nCloseFound = x;
		break
		end
	end

	if nOpenFound ~= -1 and nCloseFound ~= -1 then
	local sNewCode = "";
	
		for x = nOpenFound, nCloseFound do
				
			if tFullCode[x] == nil then
			sAddCode = "";
			else
			sAddCode = tFullCode[x];
			end
				
		sNewCode = sNewCode.."\r\n"..sAddCode;		
		end
	
	loadstring(sNewCode)();
	sNewCode = nil;
	end
	
end

end