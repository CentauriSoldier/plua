--[[Description
<p>This plugin makes key binding, key code association and integrated script execution simple.<br/>
No more memorizing key codes or endless lines of code on different pages or separate objects.<br/>
With KeyBind, creating key-script associations is simple and quick.</p>
]]
--[[Features
<ul class="comments_list_features">
	<li>Dynamic key coding</li>
	<li>Access to mutiple key binding tables</li>
	<li>Integratable key mapping system</li>
</ul>
]]
--[[Version History
<p><b>Version 1.0.0.0</b></p>
<p>Converted the KeyBind script into plugin format.</p>
]]
--[[Planned Features
<p><b>Features</b></p>
<ul class="comments_list_planned">
	<li>KeyBind.OnGrid()</li>
</ul>
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
local ERROR_PLUGIN_NAME = "KeyBind";
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
KeyBind = {};

local function DDTS(DelimitedString, Delimiter)
	local tbReturn = {};
	local strWorking;
	local nPos = nil;
	local strData;
	local nTableIndex = 1;
	local nDelimiterLength = String.Length(Delimiter);
	
	if(nDelimiterLength < 1)then
		tbReturn[nTableIndex] = DelimitedString;
		return tbReturn;
	end
	
	strWorking = DelimitedString;
	nPos = String.Find(strWorking,Delimiter);
	while(nPos ~= -1)do
		strData = String.Left(strWorking,nPos-1);
		tbReturn[nTableIndex] = strData;
		nTableIndex = nTableIndex + 1;
		local nLength = String.Length(strWorking);
		strWorking = String.Right(strWorking,nLength - (nPos + (nDelimiterLength-1)));
		nPos = String.Find(strWorking,Delimiter);
	end
	if(strWorking ~= "")then
		tbReturn[nTableIndex] = strWorking;
	end
	
	return tbReturn;
end

local KEYBIND_DELIMTER = "||";
local KEYBIND_SECTION_TITLE = "Key Bindings:"

local KEYBIND_KEY_TABLES = {
["DEFAULT_KEY_TABLE"] = {},
};

--===============================>>
-- BEGIN | Key Codes
--------------------------
local tKeyCodes = {
	["LeftMouseButton"] = 1,
	["RightMouseButton"] = 2,
	["MiddleMouseButton"] = 4,
	["Backspace"] = 8,
	["Tab"] = 9,
	["Enter"] = 13,
	["Shift"] = 16,
	["Ctrl"] = 17,
	["Alt"] = 18,
	["Pause"] = 19,
	["CapsLock"] = 20,
	["Esc"] = 27,
	["Spacebar"] = 32,
	["PageUp"] = 33,
	["PageDown"] = 34,
	["End"] = 35,
	["Home"] = 36,
	["Left"] = 37,
	["Up"] = 38,
	["Right"] = 39,
	["Down"] = 40,
	["Insert"] = 45,
	["Delete"] = 46,
	["0"] = 48,
	["1"] = 49,
	["2"] = 50,
	["3"] = 51,
	["4"] = 52,
	["5"] = 53,
	["6"] = 54,
	["7"] = 55,
	["8"] = 56,
	["9"] = 57,
	["A"] = 65,
	["B"] = 66,
	["C"] = 67,
	["D"] = 68,
	["E"] = 69,
	["F"] = 70,
	["G"] = 71,
	["H"] = 72,
	["I"] = 73,
	["J"] = 74,
	["K"] = 75,
	["L"] = 76,
	["M"] = 77,
	["N"] = 78,
	["O"] = 79,
	["P"] = 80,
	["Q"] = 81,
	["R"] = 82,
	["S"] = 83,
	["T"] = 84,
	["U"] = 85,
	["V"] = 86,
	["W"] = 87,
	["X"] = 88,
	["Y"] = 89,
	["Z"] = 90,
	["a"] = 65,
	["b"] = 66,
	["c"] = 67,
	["d"] = 68,
	["e"] = 69,
	["f"] = 70,
	["g"] = 71,
	["h"] = 72,
	["i"] = 73,
	["j"] = 74,
	["k"] = 75,
	["l"] = 76,
	["m"] = 77,
	["n"] = 78,
	["o"] = 79,
	["p"] = 80,
	["q"] = 81,
	["r"] = 82,
	["s"] = 83,
	["t"] = 84,
	["u"] = 85,
	["v"] = 86,
	["w"] = 87,
	["x"] = 88,
	["y"] = 89,
	["z"] = 90,
	["WindowsLeft"] = 91,
	["WindowsRight"] = 92,
	["Application"] = 93,
	["Numpad0"] = 96,
	["Numpad1"] = 97,
	["Numpad2"] = 98,
	["Numpad3"] = 99,
	["Numpad4"] = 100,
	["Numpad5"] = 101,
	["Numpad6"] = 102,
	["Numpad7"] = 103,
	["Numpad8"] = 104,
	["Numpad9"] = 105,
	["NumpadAsterisk"] = 106,
	["NumpadPlus"] = 107,
	["NumpadDash"] = 109,
	["NumpadPeriod"] = 110,
	["NumpadForwardslash"] = 111,
	["F1"] = 112,
	["F2"] = 113,
	["F3"] = 114,
	["F4"] = 115,
	["F5"] = 116,
	["F6"] = 117,
	["F7"] = 118,
	["F8"] = 119,
	["F9"] = 120,
	["F10"] = 121,
	["F11"] = 122,
	["F12"] = 123,
	["NumLock"] = 144,
	["ScrollLock"] = 145,
	["SemiColon"] = 186,
	["="] = 187,
	[","] = 188,
	["-"] = 189,
	["."] = 190,
	["/"] = 191,
	["`"] = 192,
	["["] = 219,
	["\\"] = 220,
	["]"] = 221,
	["'"] = 222,
	["Function"] = 255,
};

local tKeyNames = {
[8]="Backspace";
[9]="Tab";
[13]="Return";
[16]="Shift";
[17]="Ctrl";
[18]="Alt";
[19]="Pause";
[20]="CapsLock";
[27]="Escape",
[32]="Space",
[33]="PageUp",
[34]="PageDown",
[35]="End",
[36]="Home",
[37]="Left",
[38]="Up",
[39]="Right",
[40]="Down",
[45]="Insert",
[46]="Delete",
[48]="0",
[49]="1",
[50]="2",
[51]="3",
[52]="4",
[53]="5",
[54]="6",
[55]="7",
[56]="8",
[57]="9",
[65]="A",
[66]="B",
[67]="C",
[68]="D",
[69]="E",
[70]="F",
[71]="G",
[72]="H",
[73]="I",
[74]="J",
[75]="K",
[76]="L",
[77]="M",
[78]="N",
[79]="O",
[80]="P",
[81]="Q",
[82]="R",
[83]="S",
[84]="T",
[85]="U",
[86]="V",
[87]="W",
[88]="X",
[89]="Y",
[90]="Z",
[91]="LWin",
[92]="RWin",
[93]="App",
[96]="(NumPad)0",
[97]="(NumPad)1",
[98]="(NumPad)2",
[99]="(NumPad)3",
[100]="(NumPad)4",
[101]="(NumPad)5",
[102]="(NumPad)6",
[103]="(NumPad)7",
[104]="(NumPad)8",
[105]="(NumPad)9",
[106]="(NumPad)*",
[107]="(NumPad)+",
[109]="(NumPad)-",
[110]="(NumPad).",
[111]="(NumPad)/",
[112]="F1",
[113]="F2",
[114]="F3",
[115]="F4",
[116]="F5",
[117]="F6",
[118]="F7",
[119]="F8",
[120]="F9",
[121]="F10",
[122]="F11",
[123]="F12",
[144]="NumLock",
[145]="ScrollLock",
[186]=";",
[187]="+",
[188]=",",
[189]="-",
[190]=".",
[191]="/",
[192]="`",
[219]="[",
[220]="\\",
[221]="]",
[222]="'",
[255]="Function",
};
--------------------------
--END | Key Codes
--===============================>>

local Encode = 0;
local Decode = 1;
local tTo = {
["\r"] = "¬0¬",
["\n"] = "¬1¬",
["["] = "¬2¬",
["]"] = "¬3¬",
["="] = "¬4¬",
[";"] = "¬5¬",
};
local tFrom = {
["¬0¬"] = "\r",
["¬1¬"] = "\n",
["¬2¬"] = "[",
["¬3¬"] = "]",
["¬4¬"] = "=",
["¬5¬"] = ";",
};

--==========================
-- CharConv
--==========================
local function CharConv(nProcess, sInput)
if nProcess == Encode then
	
	for sFromChar, sToChar in pairs(tTo) do
	sInput = String.Replace(sInput, sFromChar, sToChar, false);
	end

return sInput

elseif nProcess == Decode then
	
	for sFromChar, sToChar in pairs(tFrom) do
	sInput = String.Replace(sInput, sFromChar, sToChar, false);
	end
	
return sInput
end
end



--==========================
-- CheckVar
--==========================
local function CheckVar(vInput, vReturn)
if not vInput then
return vReturn
else
	
	if String.Replace(vInput, " ", "", false) == "" then
	return vReturn
	else
	return vInput
	end
	
end
end



--==========================
-- KeyExists
--==========================
local function KeyExists(nKey)
if tKeyNames[nKey] then
return true
else
return false
end
end





--[[
Return Codes
-9 : Unspecified error. Use Application.GetLastError() to determine the cause
-8 : Object does not exist
-6 : The specified source table section does not exist, is empty or is corrupt
-5 : File does not exist
-3 : The specified key is unbound
-2 : The specified key table does not exist or is empty
-1 : The specified key is not supported or does not exist
 0  : Action was successful

]]


--=======================================================================================================================================
-- <END HIDDEN ELEMENTS>  <END HIDDEN ELEMENTS> <END HIDDEN ELEMENTS> <END HIDDEN ELEMENTS> <END HIDDEN ELEMENTS> <END HIDDEN ELEMENTS> 
--=======================================================================================================================================



--==========================
-- KeyBind.BindGroup
--==========================
function KeyBind.BindGroup(...)
IRLUA_PLUGIN_CheckNumArgs(arg,1);
local tSource = IRLUA_PLUGIN_CheckTypes(arg,1,{"table"});
local sKeyTable = IRLUA_PLUGIN_CheckTypes(arg,2,{"string", "nil"});
sKeyTable = CheckVar(sKeyTable, "DEFAULT_KEY_TABLE");
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
for nID, tAtt in pairs(tSource) do	
local nRet = KeyBind.BindKey(tAtt.Key, tAtt.Text, tAtt.Desc, tAtt.Shift, tAtt.Ctrl, tAtt.Alt, tAtt.Script, sKeyTable);
	
	if nRet ~= 0 then
	return nRet
	end	
	
end

return 0
end



--==========================
-- KeyBind.BindKey
--==========================
function KeyBind.BindKey(...)
IRLUA_PLUGIN_CheckNumArgs(arg,1);
local nKey = IRLUA_PLUGIN_CheckTypes(arg,1,{"number"});
local sText = IRLUA_PLUGIN_CheckTypes(arg,2,{"string", "nil"});
local sDesc = IRLUA_PLUGIN_CheckTypes(arg,3,{"string", "nil"});
local bShift = IRLUA_PLUGIN_CheckTypes(arg,4,{"boolean", "nil"});
local bCtrl = IRLUA_PLUGIN_CheckTypes(arg,5,{"boolean", "nil"});
local bAlt = IRLUA_PLUGIN_CheckTypes(arg,6,{"boolean", "nil"});
local sScript = IRLUA_PLUGIN_CheckTypes(arg,7,{"string", "nil"});
local sKeyTable = IRLUA_PLUGIN_CheckTypes(arg,8,{"string", "nil"});
sKeyTable = CheckVar(sKeyTable, "DEFAULT_KEY_TABLE");
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if not KeyExists(nKey) then
return -1
end

if String.Replace(sKeyTable, " ", "", false) == "" then
sKeyTable = "DEFAULT_KEY_TABLE";
else
		
	if not KEYBIND_KEY_TABLES[sKeyTable] then
	KEYBIND_KEY_TABLES[sKeyTable] = {};
	end
		
end

local sName = tKeyNames[nKey];

if not sText then
sText = "";
end

if not sDesc then
sDesc = "";
end

if not bShift then
bShift = false;
else
	
	if sName ~= "Shift" then
	sName = "Shift + "..sName;
	end
	
end

if not bCtrl then
bCtrl = false;
else

	if sName ~= "Ctrl" then
	sName = "Ctrl + "..sName;
	end
	
end

if not bAlt then
bAlt = false;
else

	if sName ~= "Alt" then
	sName = "Alt + "..sName;
	end
	
end

if not sScript then
sScript = "";
end

KEYBIND_KEY_TABLES[sKeyTable][nKey] = {
Key=nKey,
Name=sName,
Text=sText,
Desc=sDesc,
Shift=bShift,
Ctrl=bCtrl,
Alt=bAlt,
Script=sScript,
};

return 0
end



--==========================
-- KeyBind.DeleteKeyBinding
--==========================
function KeyBind.DeleteKeyBinding(...)
IRLUA_PLUGIN_CheckNumArgs(arg,1);
local nKey = IRLUA_PLUGIN_CheckTypes(arg,1,{"number"});
local sKeyTable = IRLUA_PLUGIN_CheckTypes(arg,2,{"string", "nil"});
sKeyTable = CheckVar(sKeyTable, "DEFAULT_KEY_TABLE");
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if not KeyExists(nKey) then
return -1
end

if KeyBind.KeyTableDoesExist(sKeyTable) then

	if KeyBind.KeyIsBound(nKey, sKeyTable) then
	KEYBIND_KEY_TABLES[sKeyTable][nKey] = nil;
	return 0
	else
	return -3
	end
	
else
return -2
end

end



--==========================
-- KeyBind.DeleteKeyTable
--==========================
function KeyBind.DeleteKeyTable(...)
IRLUA_PLUGIN_CheckNumArgs(arg,1);
local sKeyTable = IRLUA_PLUGIN_CheckTypes(arg,1,{"string"});
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if KeyBind.KeyTableDoesExist(sKeyTable) then
KEYBIND_KEY_TABLES[sKeyTable] = nil;
return 0
else
return -2
end

end



--==========================
-- KeyBind.GetKeyAtt
--==========================
function KeyBind.GetKeyAtt(...)
IRLUA_PLUGIN_CheckNumArgs(arg,1);
local nKey = IRLUA_PLUGIN_CheckTypes(arg,1,{"number"});
local sKeyTable = IRLUA_PLUGIN_CheckTypes(arg,2,{"string", "nil"});
sKeyTable = CheckVar(sKeyTable, "DEFAULT_KEY_TABLE");
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if not KeyExists(nKey) then
return -1
end

if not KEYBIND_KEY_TABLES[sKeyTable] then
sKeyTable = "DEFAULT_KEY_TABLE";
end

if KEYBIND_KEY_TABLES[sKeyTable][nKey] then
return KEYBIND_KEY_TABLES[sKeyTable][nKey]
else
return -3
end
	
end



--==========================
-- KeyBind.GetKeyCode
--==========================
function KeyBind.GetKeyCode(...)
IRLUA_PLUGIN_CheckNumArgs(arg,1);
local sKey = IRLUA_PLUGIN_CheckTypes(arg,1,{"string"});
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
local nRet = -1;

if tKeyCodes[sKey] then
nRet = tKeyCodes[sKey];
end

return nRet
end



--==========================
-- KeyBind.GetKeyCount
--==========================
function KeyBind.GetKeyCount(...)
IRLUA_PLUGIN_CheckNumArgs(arg,0);
local sKeyTable = IRLUA_PLUGIN_CheckTypes(arg,1,{"string"});
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if not KEYBIND_KEY_TABLES[sKeyTable] then
sKeyTable = "DEFAULT_KEY_TABLE";
end

if KeyBind.KeyTableDoesExist(sKeyTable) then
return Table.Count(KEYBIND_KEY_TABLES[sKeyTable])
else
return -2
end
end



--==========================
-- KeyBind.GetKeyName
--==========================
function KeyBind.GetKeyName(...)
IRLUA_PLUGIN_CheckNumArgs(arg,1);
local nKey = IRLUA_PLUGIN_CheckTypes(arg,1,{"number"});
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if not KeyExists(nKey) then
return -1
end

return tKeyNames[nKey]
end



--==========================
-- KeyBind.GetKeyTableCount
--==========================
function KeyBind.GetKeyTableCount()
local nRet = 0;

if KEYBIND_KEY_TABLES then
nRet = Table.Count(KEYBIND_KEY_TABLES);
end

return nRet
end



--==========================
-- KeyBind.GetKeyTableNames
--==========================
function KeyBind.GetKeyTableNames()
local tRet = {};

if KEYBIND_KEY_TABLES then
	
	for sIndex, tTable in pairs(KEYBIND_KEY_TABLES) do
	tRet[Table.Count(tRet) + 1] = sIndex;
	end
	
end

return tRet
end



--==========================
-- KeyBind.KeyIsBound
--==========================
function KeyBind.KeyIsBound(...)
IRLUA_PLUGIN_CheckNumArgs(arg,1);
local nKey = IRLUA_PLUGIN_CheckTypes(arg,1,{"number"});
local sKeyTable = IRLUA_PLUGIN_CheckTypes(arg,2,{"string", "nil"});
sKeyTable = CheckVar(sKeyTable, "DEFAULT_KEY_TABLE");
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if not KeyExists(nKey) then
return -1
end

if KEYBIND_KEY_TABLES[sKeyTable][nKey] then
return true
else
return false
end

end



--==========================
-- KeyBind.KeyTableDoesExist
--==========================
function KeyBind.KeyTableDoesExist(...)
IRLUA_PLUGIN_CheckNumArgs(arg,1);
local sKeyTable = IRLUA_PLUGIN_CheckTypes(arg,1,{"string"});
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if KEYBIND_KEY_TABLES[sKeyTable] then
return true
else
return false
end
end



--==========================
-- KeyBind.LoadSettings
--==========================
function KeyBind.LoadSettings(...)
IRLUA_PLUGIN_CheckNumArgs(arg,1);
local sFile = IRLUA_PLUGIN_CheckTypes(arg,1,{"string"});
local sSrcSection = IRLUA_PLUGIN_CheckTypes(arg,2,{"string", "nil"});
local sKeyTable = IRLUA_PLUGIN_CheckTypes(arg,3,{"string", "nil"});
local sEnc = IRLUA_PLUGIN_CheckTypes(arg,4,{"string", "nil"});
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if sSrcSection then

	if String.Replace(sSrcSection, " ", "", false) == "" then
	sSrcSection = "DEFAULT_KEY_TABLE";
	end
	
else
sSrcSection = "DEFAULT_KEY_TABLE";
end	

sSrcSection = KEYBIND_SECTION_TITLE..sSrcSection;

if sEnc then
	
	if String.Replace(sEnc, " ", "", false) == "" then
	sEnc = nil;
	end
	
end

if not File.DoesExist(sFile) then
return -5
end

local tSections = INIFile.GetSectionNames(sFile)
if not tSections then
return -6
end

local bSectionExists = false;
for nIndex, sSection in pairs(tSections) do

	if sSection == sSrcSection then
	bSectionExists = true;
	end

end

if not bSectionExists then
return -6
end

local tValues = INIFile.GetValueNames(sFile, sSrcSection);
if not tValues then
return -6
end

for nIndex, sValue in pairs(tValues) do
local tAtt = DDTS(INIFile.GetValue(sFile, sSrcSection, sValue), KEYBIND_DELIMTER);

	if tAtt then
	KeyBind.BindKey(String.ToNumber(sValue), tAtt[1], tAtt[2], CONVERT(tAtt[3],"boolean"), CONVERT(tAtt[4],"boolean"), CONVERT(tAtt[5],"boolean"), CharConv(Decode, tAtt[6]), sKeyTable);
	else
	
	return -6	
	end
	
end

return 0
end



--==========================
-- KeyBind.OnKey
--==========================
function KeyBind.OnKey(...)
IRLUA_PLUGIN_CheckNumArgs(arg,2);
local e_Key = IRLUA_PLUGIN_CheckTypes(arg,1,{"number"});
local e_Modifiers = IRLUA_PLUGIN_CheckTypes(arg,2,{"table"});
local sKeyTable = IRLUA_PLUGIN_CheckTypes(arg,3,{"string", "nil"});
sKeyTable = CheckVar(sKeyTable, "DEFAULT_KEY_TABLE");
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if not KeyExists(e_Key) then
return -1
end

if String.Replace(sKeyTable, " ", "", false) == "" then
sKeyTable = "DEFAULT_KEY_TABLE";
else
		
	if not KEYBIND_KEY_TABLES[sKeyTable] then
	sKeyTable = "DEFAULT_KEY_TABLE";
	end
		
end

for nIndex, tAtt in pairs(KEYBIND_KEY_TABLES[sKeyTable]) do

    if e_Key == tAtt.Key then
    
    	if tAtt.Shift == e_Modifiers.shift and tAtt.Ctrl == e_Modifiers.ctrl and tAtt.Alt == e_Modifiers.alt then
    	loadstring(tAtt.Script)();
    	break;
    	end
	    	
    end

end

end



--==========================
-- KeyBind.SaveSettings
--==========================
function KeyBind.SaveSettings(...)
IRLUA_PLUGIN_CheckNumArgs(arg,1);
local sFile = IRLUA_PLUGIN_CheckTypes(arg,1,{"string"});
local sKeyTable = IRLUA_PLUGIN_CheckTypes(arg,2,{"string", "nil"});
local sEnc = IRLUA_PLUGIN_CheckTypes(arg,3,{"string", "nil"});
sKeyTable = CheckVar(sKeyTable, "DEFAULT_KEY_TABLE");
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
local sModScript = "";

if File.DoesExist(sFile) then
TextFile.WriteFromString(sFile, "", false);

	local nError = Application.GetLastError();
	if nError ~= 0 then
	return nError
	end

end	
	
if not KEYBIND_KEY_TABLES[sKeyTable] then
sKeyTable = "DEFAULT_KEY_TABLE";
end

if sEnc then

	if String.Replace(sEnc, " ", "", false) ~= "" then
	sEnc = nil;
	end
	
end

if Table.Count(KEYBIND_KEY_TABLES[sKeyTable]) > 0 then

	for nIndex, tAtt in pairs(KEYBIND_KEY_TABLES[sKeyTable]) do
		
		if sEnc then
		sModScript = Crypto.BlowfishEncryptString(tAtt.Script, sEnc, 0);
		else
		sModScript =  CharConv(Encode, tAtt.Script);
		end
		
	INIFile.SetValue(sFile, KEYBIND_SECTION_TITLE..sKeyTable, tAtt.Key, tAtt.Text..KEYBIND_DELIMTER..tAtt.Desc..KEYBIND_DELIMTER..CONVERT(tAtt.Shift, "string")..KEYBIND_DELIMTER..CONVERT(tAtt.Ctrl, "string")..KEYBIND_DELIMTER..CONVERT(tAtt.Alt, "string")..KEYBIND_DELIMTER..sModScript);

		local nError = Application.GetLastError();
		if nError ~= 0 then
		return nError
		end
		
	end
	
end

return 0
end



--==========================
-- KeyBind.SetKeyAtt
--==========================
function KeyBind.SetKeyAtt(...)
IRLUA_PLUGIN_CheckNumArgs(arg,1);
local nKey = IRLUA_PLUGIN_CheckTypes(arg,1,{"number"});
local sText = IRLUA_PLUGIN_CheckTypes(arg,2,{"string", "nil"});
local sDesc = IRLUA_PLUGIN_CheckTypes(arg,3,{"string", "nil"});
local bShift = IRLUA_PLUGIN_CheckTypes(arg,4,{"boolean", "nil"});
local bCtrl = IRLUA_PLUGIN_CheckTypes(arg,5,{"boolean", "nil"});
local bAlt = IRLUA_PLUGIN_CheckTypes(arg,6,{"boolean", "nil"});
local sScript = IRLUA_PLUGIN_CheckTypes(arg,7,{"string", "nil"});
local sKeyTable = IRLUA_PLUGIN_CheckTypes(arg,8,{"string", "nil"});
sKeyTable = CheckVar(sKeyTable, "DEFAULT_KEY_TABLE");
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if not KeyExists(nKey) then
return -1
end

if not KeyBind.KeyIsBound(nKey, sKeyTable) then
return -3
end

if sText then
KEYBIND_KEY_TABLES[sKeyTable][nKey].Text = sText;
end

if sDesc then
KEYBIND_KEY_TABLES[sKeyTable][nKey].Desc = sDesc;
end

if bShift then
KEYBIND_KEY_TABLES[sKeyTable][nKey].Shift = bShift;
end

if bCtrl then
KEYBIND_KEY_TABLES[sKeyTable][nKey].Ctrl = bCtrl;
end

if bAlt then
KEYBIND_KEY_TABLES[sKeyTable][nKey].Alt = bAlt;
end

if sScript then
KEYBIND_KEY_TABLES[sKeyTable][nKey].Script = sScript;
end

return 0
end



--==========================
-- KeyBind.UpdateGrid
--==========================
function KeyBind.UpdateGrid(...)
IRLUA_PLUGIN_CheckNumArgs(arg,2);
local sGridObject = IRLUA_PLUGIN_CheckTypes(arg,1,{"string"});
local bIncludeDesc = IRLUA_PLUGIN_CheckTypes(arg,2,{"boolean"});
local nAutoFit = IRLUA_PLUGIN_CheckTypes(arg,3,{"number", "nil"});
local sKeyTable = IRLUA_PLUGIN_CheckTypes(arg,4,{"string", "nil"});
sKeyTable = CheckVar(sKeyTable, "DEFAULT_KEY_TABLE");
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
local nKeyCount = KeyBind.GetKeyCount(sKeyTable);

if nKeyCount > 0 then
local fAction = Page;

	if Application.GetCurrentDialog() ~= "" then
	fAction = DialogEx;
	end
	
	local tObjects = fAction.EnumerateObjects();
	if tObjects then
	local bObjectExists = false;
	
		for nIndex, sObject in pairs(tObjects) do
			
			if sObject == sGridObject then
			bObjectExists = true;
			break;
			end
			
		end
	
		if bObjectExists then
		Grid.DeleteAllItems(sGridObject);
		local nColumnCount = 2;
					
			if bIncludeDesc == true then
			nColumnCount = nColumnCount + 1;
			end
			
		Grid.SetColumnCount(sGridObject, nColumnCount);
		Grid.SetRowCount(sGridObject, nKeyCount + 1);
		
		Grid.SetFixedRowCount(sGridObject, 1);
		Grid.SetFixedColumnCount(sGridObject, 0);
		
		Grid.SetCellText(sGridObject, 0, 0, "Key", false);	
		Grid.SetCellText(sGridObject, 0, 1, "Text", false);
			
			if bIncludeDesc then
			Grid.SetCellText(sGridObject, 0, 2, "Description", false);
			end
			
			local nRowCount = 0;
			for nID, tAtt in pairs(KEYBIND_KEY_TABLES[sKeyTable]) do
			nRowCount = nRowCount + 1;
			Grid.SetCellText(sGridObject, nRowCount, 0, tAtt.Name, false);
			Grid.SetCellText(sGridObject, nRowCount, 1, tAtt.Text, false);
				
				if bIncludeDesc then
				Grid.SetCellText(sGridObject, nRowCount, 2, tAtt.Desc, false);
				end
				
			end
			
			if not nAutoFit then
			nAutoFit = GVS_BOTH;
			end
		
		Grid.AutoSizeColumns(sGridObject, nAutoFit, true);
		return 0
		else
		return -8
		end
		
	else
	return -8
	end
	
end
end