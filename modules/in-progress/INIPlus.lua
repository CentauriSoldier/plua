--[[Description
<p>INIPlus implements a human-readable file format using combined features of INI and XML.<br/>
With custom parsing, INIPlus lifts INI file length limits and combines the versatility of XML and the simplicity of INI. </p>
]]
--[[Features
<ul class="comments_list_features">
	<li>Allows the setting of section and value attributes</li>
	<li>Quick enumeration of sections, values and their attributes</li>
	<li>Allows for multiline values</li>
	<li>Auto-saves changes to file</li>
	<li>Toggle error messages display On/Off</li>
</ul>
]]
--[[Version History
<p><b>Version 1.2.2.0</b></p>
<p>Fixed a typo in INIPlus.SetSectionAttrubute() that was causing a bug.</p>
<br/>
<p><b>Version 1.2.1.0</b></p>
<p>Completed missed sections of 8.0 update.</p>
<br/>
<p><b>Version 1.2.0.0</b></p>
<p>Updated to be compatible with AMS 8.0.</p>
<p>Updated the IRLua Plugin Helper Functions to v2.6.</p>
<br/>
<p><b>Version 1.1.0.0</b></p>
<p>Fixed a bug that occurred when the INIPlus.ValueDoesExist() function targeted a section that did not exist.</p>
<br/>
]]
--[[Planned Features
<p><b>Features</b></p>
<p>Create a system that toggles auto-save for increased processing speed with large files.</p>
]]
--#########################################################################################################
-- IRLUA PLUGIN HELPER FUNCTIONS By MicroByte (Revised by Centauri Soldier) ||@#$|| VERSION 2.6 ||$#@|| 
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
	IRLUA_PLUGIN_ERROR("bad argument #" .. nArg .. ", must be a"..sAllowedTypes..", you passed a "..sType..".\r\n\r\nEventContext: "..sEventContext,3)
	else
	IRLUA_PLUGIN_ERROR("bad argument #" .. nArg .. ", must be a"..sAllowedTypes..", you passed a "..sType..".",3)
	end
else
return tbArgs[nArg]
end
end
--#########################################################################################################
-- Ensures that your table contains data of only the specified type. If it does not then false is returned.
-- This will see nil values as subtables declarations and will, therefore, ignore them.
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
--ERROR PLUGIN DETAILS
local ERROR_PLUGIN_NAME = "INIPlus";
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
--Throws and error if the required plugin is not loaded
local REQUIRE = function(tPlugin,sPluginName)
if not tPlugin then
IRLUA_PLUGIN_ERROR("\r\nError loading the \""..ERROR_PLUGIN_NAME.."\" plugin.\r\nThis plugin requires the \""..sPluginName.."\" plugin.");
end
end
--#########################################################################################################
-- END IRLUA PLUGIN HELPER FUNCTIONS
--#########################################################################################################
INIPlus = {};
INIPLUS_ERRORS_ON = false;
INIPLUS_ESCAPE_CHAR = "^";

--[[ INIPlus Symbols 

[Section"SectionAttribute"]
|Value'Value Attribute'=<Data>
Comments - Comments can be placed anywhere in the file provided that they are outside the escapable character sections

Esacpable Characters
[ ] | = " ' < >

]]

--============================================================================================================================================================
-- <BEGIN HIDDEN FUNCTIONS> <BEGIN HIDDEN FUNCTIONS>  <BEGIN HIDDEN FUNCTIONS>  <BEGIN HIDDEN FUNCTIONS>  <BEGIN HIDDEN FUNCTIONS>  <BEGIN HIDDEN FUNCTIONS> 
--============================================================================================================================================================


--==============================
-- INIPlus.GetError
--==============================
function INIPlus.GetError()
return Application.GetLastError()
end



--==============================
-- INIPlus.IsError
--==============================
function INIPlus.IsError()
local bReturn = false;

if INIPlus.GetError() > 0 then
bReturn = true;
end

return bReturn
end



--==============================
-- INIPlus.DisplayError
--==============================
function INIPlus.DisplayError(...)
IRLUA_PLUGIN_CheckNumArgs(arg,2);
local sError = IRLUA_PLUGIN_CheckTypes(arg,1,{"string"});
local sFunctionName = IRLUA_PLUGIN_CheckTypes(arg,2,{"string"});
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if INIPLUS_ERRORS_ON then
sLastError = "";
	
	if  INIPlus.GetError() > 0 then
	sLastError = _tblErrorMessages[INIPlus.GetError()];
	end
	
Dialog.Message("Error in \""..sFunctionName.."\" function", Debug.GetEventContext().."\r\n"..sError.."\r\n"..sLastError, MB_OK, MB_ICONSTOP, MB_DEFBUTTON1);

end
end



--==============================
-- INIPlus.Read
--==============================
function INIPlus.Read(...)
IRLUA_PLUGIN_CheckNumArgs(arg,2);
local sINIPlusFile = IRLUA_PLUGIN_CheckTypes(arg,1,{"string"});
local sCallingFunction = IRLUA_PLUGIN_CheckTypes(arg,2,{"string"});
local tSections = {};
--created for when we need to index the sections and value names
local tNames = {};
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if not File.DoesExist(sINIPlusFile) then
INIPlus.DisplayError("Error reading INIPlus file \""..sINIPlusFile.."\"", sCallingFunction);
else
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
local function ParseString(sInputString, tEscapableCharacters, sEscapeChar)
local sParsableIPText = sInputString;
local sReadableIPText = sInputString;
local tEscapeSequences = {};
Table.Insert(tEscapableCharacters, Table.Count(tEscapableCharacters), sEscapeChar)

for nIndex, sChar in pairs(tEscapableCharacters) do
tEscapeSequences[nIndex] = {};
tEscapeSequences[nIndex].Sequence = sEscapeChar..sChar;
tEscapeSequences[nIndex].Readable = sChar;
tEscapeSequences[nIndex].Parsable = sEscapeChar;
end

for nIndex = 1, Table.Count(tEscapeSequences) do
sParsableIPText = String.Replace(sParsableIPText, tEscapeSequences[nIndex].Sequence, tEscapeSequences[nIndex].Parsable, false);
sReadableIPText =  String.Replace(sReadableIPText, tEscapeSequences[nIndex].Sequence, tEscapeSequences[nIndex].Readable, false);
end
return {sParsableIPText, sReadableIPText}
end

local tEscapeChars = {"\'", "\"", "[", "]", "<", ">", "|", "="};
local tText = ParseString(TextFile.ReadToString(sINIPlusFile), tEscapeChars, INIPLUS_ESCAPE_CHAR);
local sParsableIPText = tText[1];
local sReadableIPText = tText[2];
local nFileLength = String.Length(sParsableIPText);
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
local function CountItems(sInputString, sStartSymbol, nStartBoundary, nEndBoundary)
local nLoopCounter = 0;
local nLastPoint = 0;
local bHasRunOnce = nil;
local bEndLoop = false;
repeat
local nSectionFound = String.Find(sInputString, sStartSymbol, nStartBoundary, false);

	if nSectionFound ~= -1 and nSectionFound >= nStartBoundary and nSectionFound <= nEndBoundary then
	
		if nSectionFound >= nLastPoint then
		nStartBoundary = nSectionFound + 1;
		nLastPoint = nSectionFound + 1;
		nLastPoint = nStartBoundary;
		nLoopCounter = nLoopCounter + 1;
		bHasRunOnce = true;
		else
		bEndLoop = true;
		end

	elseif nSectionFound ~= -1 and nSectionFound < nStartBoundary and bHasRunOncee == true then
	
	bEndLoop = true;
	else
	bEndLoop = true;
	
	end

until bEndLoop == true
return nLoopCounter
end
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
local nSearchPoint = 0;
local nLastSectionStart = 0;
local nTotalSections = CountItems(sParsableIPText, "[", 1, nFileLength);
for nSectionIndex = 1, nTotalSections do
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
--BEGIN || GET THE SECTION AND ATTRIBUTE START AND END POINTS
local nSectionStart = String.Find(sParsableIPText, "[", nSearchPoint + 1, false);
local nSectionEnd = String.Find(sParsableIPText, "]", nSectionStart + 1, false);
local nAttributeStart = (String.Find(sParsableIPText, "\"", nSectionStart, false));
local nAttributeEnd = (String.Find(sParsableIPText, "\"", nAttributeStart + 1, false));
local nSectionBoundary = String.Find(sParsableIPText, "[", nSectionEnd + 1, false) - 1;
if nLastSectionStart > nSectionStart or nSectionBoundary < 1 then
nSectionBoundary = nFileLength;
end
nLastSectionStart = nSectionStart;
--END || GET THE SECTION AND ATTRIBUTE START AND END POINTS
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
--BEGIN || GET THE SECTION NAME AND ATTTRIBUTE
local sSectionName = String.Mid(sReadableIPText, nSectionStart + 1, (nAttributeStart - nSectionStart) - 1);
local sSectionAttribute = String.Mid(sReadableIPText, nAttributeStart + 1, (nAttributeEnd - nAttributeStart) - 1);
--END || GET THE SECTION NAME AND ATTTRIBUTE
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
--BEGIN || WRITE SECTION DETAILS TO THE TABLE
tSections[sSectionName] = {};
tSections[sSectionName].ID = nSectionIndex;
tSections[sSectionName].Name = sSectionName;
tSections[sSectionName].Attribute = sSectionAttribute;
tSections[sSectionName].Values = {};
--created for when we need to index the sections
tNames[nSectionIndex] = {};
tNames[nSectionIndex].ID = nSectionIndex;
tNames[nSectionIndex].Name = sSectionName;
tNames[nSectionIndex].Attribute = sSectionAttribute;
tNames[nSectionIndex].Values = {};
--END || WRITE SECTION DETAILS TO THE TABLE
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
--BEGIN || GET THE VALUES FOR THIS SECTION
local nValueSearchPoint = nSectionEnd;
local nTotalValues = CountItems(sParsableIPText, "|", nSectionStart, nSectionBoundary);
	for nValueIndex = 1, nTotalValues do
	--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	--BEGIN || GET THE VALUE, ATTRIBUTE AND DATA START AND END POINTS
	local nValueStart = String.Find(sParsableIPText, "|", nValueSearchPoint + 1, false);
	local nValueEnd = String.Find(sParsableIPText, "\'", nValueStart + 1, false);
	local nValueAttributeStart = nValueEnd;
	local nValueAttributeEnd = (String.Find(sParsableIPText, "\'", nValueAttributeStart + 1, false));
	local nDataStart = String.Find(sParsableIPText, "<", nValueAttributeEnd + 1, false);
	local nDataEnd = String.Find(sParsableIPText, ">", nDataStart + 1, false);
	--END || GET THE VALUE, ATTRIBUTE AND DATA START AND END POINTS
	--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	--BEGIN || GET THE VALUE, ATTRIBUTE AND DATA
	local sValueName = String.Mid(sReadableIPText, nValueStart + 1, (nValueAttributeStart - nValueStart) - 1);
	local sValueAttribute = String.Mid(sReadableIPText, nValueAttributeStart + 1, (nValueAttributeEnd - nValueAttributeStart) - 1);
	local sValueData = String.Mid(sReadableIPText, nDataStart + 1, (nDataEnd - nDataStart) - 1);
	--END || GET THE VALUE, ATTRIBUTE AND DATA
	--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	tSections[sSectionName].Values[sValueName] = {};
	tSections[sSectionName].Values[sValueName].ID = nValueIndex;
	tSections[sSectionName].Values[sValueName].Name = sValueName;
	tSections[sSectionName].Values[sValueName].Attribute = sValueAttribute;
	tSections[sSectionName].Values[sValueName].Data = sValueData;
	--created for when we need to index the values
	tNames[nSectionIndex].Values[nValueIndex] = {};
	tNames[nSectionIndex].Values[nValueIndex].ID = nValueIndex;
	tNames[nSectionIndex].Values[nValueIndex].Name = sValueName;
	tNames[nSectionIndex].Values[nValueIndex].Attribute = sValueAttribute;
	tNames[nSectionIndex].Values[nValueIndex].Data = sValueData;
	nValueSearchPoint = nDataEnd + 1;
	end
	--END || GET THE VALUES FOR THIS SECTION
	--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
nSearchPoint = nSectionBoundary;
end
--<<<<<<<<<<<<<<<<<
end
return {tSections, tNames}
end



--==============================
-- INIPlus.Write
--==============================
function INIPlus.Write(...)
IRLUA_PLUGIN_CheckNumArgs(arg,3);
local sINIPlusFile = IRLUA_PLUGIN_CheckTypes(arg,1,{"string"});
local tData = IRLUA_PLUGIN_CheckTypes(arg,2,{"table"});
local sCallingFunction = IRLUA_PLUGIN_CheckTypes(arg,3,{"string"});
local sSpacer = "";
local sDataText = "";
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if not File.DoesExist(sINIPlusFile) then
TextFile.WriteFromString(sINIPlusFile, "", false);
	
	if INIPlus.IsError() then
	INIPlus.DisplayError("The INIPlus file \""..sINIPlusFile.."\" could not be created.", sCallingFunction);
	end
	
end
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if tData then

	for x = 1, Table.Count(tData) do
	sDataText = sDataText.."["..tData[x].Name.."\""..tData[x].Attribute.."\"]".."\r\n";

		for y = 1, Table.Count(tData[x].Values) do
		sDataText = sDataText.."|"..tData[x].Values[y].Name.."'"..tData[x].Values[y].Attribute.."'<"..tData[x].Values[y].Data..">".."\r\n";
		end
				
	end

TextFile.WriteFromString(sINIPlusFile, sDataText, false);
if INIPlus.IsError() then
INIPlus.DisplayError("Error writing to file. \""..sINIPlusFile.."\".", sCallingFunction);
end
end
end
--===================================================================================================================================================================
-- <END HIDDEN FUNCTIONS> <END HIDDEN FUNCTIONS> <END HIDDEN FUNCTIONS> <END HIDDEN FUNCTIONS> <END HIDDEN FUNCTIONS> <END HIDDEN FUNCTIONS> <END HIDDEN FUNCTIONS>
--===================================================================================================================================================================



--==============================
-- INIPlus.CreateSection
--==============================
function INIPlus.CreateSection(...)
IRLUA_PLUGIN_CheckNumArgs(arg,3);
local sINIPlusFile = IRLUA_PLUGIN_CheckTypes(arg,1,{"string"});
local sSection = IRLUA_PLUGIN_CheckTypes(arg,2,{"string"});
local sAttribute = IRLUA_PLUGIN_CheckTypes(arg,3,{"string"});
local tTemp = INIPlus.Read(sINIPlusFile, "INIPlus.CreateSection");
local tData = tTemp[1];
local tIndexedData = tTemp[2];
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if not INIPlus.SectionDoesExist(sINIPlusFile, sSection) then
	if String.Replace(sSection, " ", "", false) ~= "" then
		if tData then
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
		local nIndex = Table.Count(tIndexedData) + 1;
		tIndexedData[nIndex] = {};
		tIndexedData[nIndex].Name = sSection;
		tIndexedData[nIndex].Attribute = sAttribute;
		tIndexedData[nIndex].Values = {};
		
		INIPlus.Write(sINIPlusFile, tIndexedData, "INIPlus.CreateSection");
		end
	
	else
	INIPlus.DisplayError("The new section name in file \""..sINIPlusFile.."\" cannot be blank.", "INIPlus.ChangeSectionName");
	end
	
else
INIPlus.DisplayError("The section \""..sSection.."\" for file \""..sINIPlusFile.."\" already exists.", "INIPlus.CreateSection");
end
end



--==============================
-- INIPlus.CreateFromINI
--==============================
function INIPlus.CreateFromINI(...)
IRLUA_PLUGIN_CheckNumArgs(arg,2);
local sINIPlusFile = IRLUA_PLUGIN_CheckTypes(arg,1,{"string"});
local sINIFile = IRLUA_PLUGIN_CheckTypes(arg,2,{"string"});
local tNewData = {};
if File.DoesExist(sINIFile) then
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
local tAllSections = INIFile.GetSectionNames(sINIFile);

if tAllSections then

	for x = 1, Table.Count(tAllSections) do
	local sSectionName = tAllSections[x];
	
	tNewData[x] = {}
	tNewData[x].Name = sSectionName;
	tNewData[x].Attribute = "";
	tNewData[x].Values = {};
	
	local tAllValues = INIFile.GetValueNames(sINIFile, sSectionName);
		
		if tAllValues then
			
			for y = 1, Table.Count(tAllValues) do
			local sValueName = tAllValues[y];
			
			tNewData[x].Values[y] = {};
			tNewData[x].Values[y].Name = sValueName;
			tNewData[x].Values[y].Attribute = "";
			tNewData[x].Values[y].Data = INIFile.GetValue(sINIFile, sSectionName, sValueName);
			end
			
		end	
	
	end

end
INIPlus.Write(sINIPlusFile, tNewData, "INIPlus.CreateFromINI");
-->>>>>>>
else
INIPlus.DisplayError("Error reading INI file \""..sINIFile.."\"", "INIPlus.CreateFromINI");
end
end



--==============================
-- INIPlus.ChangeSectionName
--==============================
function INIPlus.ChangeSectionName(...)
IRLUA_PLUGIN_CheckNumArgs(arg,3);
local sINIPlusFile = IRLUA_PLUGIN_CheckTypes(arg,1,{"string"});
local sOldSectionName = IRLUA_PLUGIN_CheckTypes(arg,2,{"string"});
local sNewSectionName = IRLUA_PLUGIN_CheckTypes(arg,3,{"string"});
local tTemp = INIPlus.Read(sINIPlusFile, "INIPlus.ChangeSectionName");
local tData = tTemp[1];
local tIndexedData = tTemp[2];
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if INIPlus.SectionDoesExist(sINIPlusFile, sOldSectionName) then
	if not INIPlus.SectionDoesExist(sINIPlusFile, sNewSectionName) then
		if String.Replace(sOldSectionName, " ", "", false) ~= "" and String.Replace(sNewSectionName, " ", "", false) ~= "" then
			if tData then
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
			local nIndex = tData[sOldSectionName].ID;
			tIndexedData[nIndex].Name = sNewSectionName;
			INIPlus.Write(sINIPlusFile, tIndexedData, "INIPlus.ChangeSectionName");
			end
			
		else
		INIPlus.DisplayError("Neither section name for file \""..sINIPlusFile.."\" can be blank.", "INIPlus.ChangeSectionName");
		end
	
	else
	INIPlus.DisplayError("The new section name \""..sNewSectionName.."\" in file \""..sINIPlusFile.."\" already exists.", "INIPlus.ChangeSectionName");
	end
	
else
INIPlus.DisplayError("The source section \""..sOldSectionName.."\" in file \""..sINIPlusFile.."\" does not exist.", "INIPlus.ChangeSectionName");
end
end



--==============================
-- INIPlus.CopySection
--==============================
function INIPlus.CopySection(...)
IRLUA_PLUGIN_CheckNumArgs(arg,3);
local sINIPlusFile = IRLUA_PLUGIN_CheckTypes(arg,1,{"string"});
local sSection = IRLUA_PLUGIN_CheckTypes(arg,2,{"string"});
local sNewSection = IRLUA_PLUGIN_CheckTypes(arg,3,{"string"});
local tTemp = INIPlus.Read(sINIPlusFile, "INIPlus.CopySection");
local tData = tTemp[1];
local tIndexedData= tTemp[2];
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if String.Replace(sSection, " ", "", false) ~= "" and String.Replace(sNewSection, " ", "", false) ~= "" then	
	if tData then
		if INIPlus.SectionDoesExist(sINIPlusFile, sSection) and not INIPlus.SectionDoesExist(sINIPlusFile, sNewSection) and INIPlus.SectionDoesExist(sINIPlusFile, sNewSection) ~= INIPlus.SectionDoesExist(sINIPlusFile, sSection) then
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
		
		local nNewIndex = Table.Count(tIndexedData) + 1;
		local nOldIndex = tData[sSection].ID;
		
		tIndexedData[nNewIndex] = {};
		tIndexedData[nNewIndex].Name = sNewSection;
		tIndexedData[nNewIndex].Attribute = tIndexedData[nOldIndex].Attribute
		tIndexedData[nNewIndex].Values = {};
		
			for nValueIndex, sValue in pairs(tIndexedData[nOldIndex].Values) do
			tIndexedData[nNewIndex].Values[nValueIndex] = {};
			tIndexedData[nNewIndex].Values[nValueIndex].Name = tIndexedData[nOldIndex].Values[nValueIndex].Name;
			tIndexedData[nNewIndex].Values[nValueIndex].Attribute = tIndexedData[nOldIndex].Values[nValueIndex].Attribute;
			tIndexedData[nNewIndex].Values[nValueIndex].Data = tIndexedData[nOldIndex].Values[nValueIndex].Data;
			end
		
		elseif not INIPlus.SectionDoesExist(sINIPlusFile, sSection) then
		INIPlus.DisplayError("The section \""..sSection.."\" in file \""..sINIPlusFile.."\" does not exist.", "INIPlus.CopySection");
		elseif INIPlus.SectionDoesExist(sINIPlusFile, sNewSection) then
		INIPlus.DisplayError("The section \""..sSection.."\" in file \""..sINIPlusFile.."\" already exists.", "INIPlus.CopySection");
		elseif INIPlus.SectionDoesExist(sINIPlusFile, sNewSection) == INIPlus.SectionDoesExist(sINIPlusFile, sSection) then
		INIPlus.DisplayError("The new section \""..sNewSection.."\" in file \""..sINIPlusFile.."\" cannot be the same name as an existing section.", "INIPlus.CopySection");
		else
		INIPlus.DisplayError("The section \""..sSection.."\" in file \""..sINIPlusFile.."\" could not be changed.", "INIPlus.CopySection");
		end
		
	INIPlus.Write(sINIPlusFile, tIndexedData, "INIPlus.CopySection");
	end
	
else
INIPlus.DisplayError("Neither section name for file \""..sINIPlusFile.."\" can be blank.", "INIPlus.CopySection");
end
end



--==============================
-- INIPlus.CountSections
--==============================
function INIPlus.CountSections(...)
IRLUA_PLUGIN_CheckNumArgs(arg,1);
local sINIPlusFile = IRLUA_PLUGIN_CheckTypes(arg,1,{"string"});
local tData = INIPlus.Read(sINIPlusFile, "INIPlus.CountSections")[1];
local nRet = -1;
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if tData then
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
nRet = Table.Count(tData);
-->>>>>>>
end
return nRet;
end



--==============================
-- INIPlus.CountValues
--==============================
function INIPlus.CountValues(...)
IRLUA_PLUGIN_CheckNumArgs(arg,2);
local sINIPlusFile = IRLUA_PLUGIN_CheckTypes(arg,1,{"string"});
local sSection = IRLUA_PLUGIN_CheckTypes(arg,2,{"string"});
local tData = INIPlus.Read(sINIPlusFile, "INIPlus.CountSections")[1];
local nRet = -1;
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if tData then
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	
	if INIPlus.SectionDoesExist(sINIPlusFile, sSection) then
	nRet = Table.Count(tData[sSection].Values);
	end
	
end
return nRet
end



--==============================
-- INIPlus.DeleteSection
--==============================
function INIPlus.DeleteSection(...)
IRLUA_PLUGIN_CheckNumArgs(arg,2);
local sINIPlusFile = IRLUA_PLUGIN_CheckTypes(arg,1,{"string"});
local sInputSection = IRLUA_PLUGIN_CheckTypes(arg,2,{"string"});
local tTemp = INIPlus.Read(sINIPlusFile, "INIPlus.DeleteSection");
local tData = tTemp[1];
local tDataNames = tTemp[2];
local tNewData = {};
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if INIPlus.SectionDoesExist(sINIPlusFile, sInputSection) then
	if tData then
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	local nSectionCounter = 0;
		
		for nSectionIndex = 1, Table.Count(tData) do
		local sCurrentSectionName = tDataNames[nSectionIndex].Name;
			
				if sCurrentSectionName ~= sInputSection then
				nSectionCounter = nSectionCounter + 1;
				local nValueCounter = 0;
				
				tNewData[nSectionCounter] = {};
				tNewData[nSectionCounter].Name = tData[sCurrentSectionName].Name;
				tNewData[nSectionCounter].Attribute = tData[sCurrentSectionName].Attribute;
				tNewData[nSectionCounter].Values = {};
		
				
					for nValueIndex = 1, Table.Count(tData[sCurrentSectionName].Values) do
					local sCurrentValueName = tDataNames[nSectionIndex].Values[nValueIndex].Name;
					nValueCounter = nValueCounter + 1;
					
					tNewData[nSectionCounter].Values[nValueCounter] = {};
					tNewData[nSectionCounter].Values[nValueCounter].Name = tData[sCurrentSectionName].Values[sCurrentValueName].Name;
					tNewData[nSectionCounter].Values[nValueCounter].Attribute = tData[sCurrentSectionName].Values[sCurrentValueName].Attribute;
					tNewData[nSectionCounter].Values[nValueCounter].Data = tData[sCurrentSectionName].Values[sCurrentValueName].Data;
					end			
				
				end
		
		end

	INIPlus.Write(sINIPlusFile, tNewData, "INIPlus.DeleteSection");

	end
	
else
INIPlus.DisplayError("The section \""..sInputSection.."\" in file \""..sINIPlusFile.."\" does not exist.", "INIPlus.DeleteSection");
end
end



--==============================
-- INIPlus.DeleteValue
--==============================
function INIPlus.DeleteValue(...)
IRLUA_PLUGIN_CheckNumArgs(arg,3);
local sINIPlusFile = IRLUA_PLUGIN_CheckTypes(arg,1,{"string"});
local sSection = IRLUA_PLUGIN_CheckTypes(arg,2,{"string"});
local sInputValue = IRLUA_PLUGIN_CheckTypes(arg,3,{"string"});
local tTemp = INIPlus.Read(sINIPlusFile, "INIPlus.DeleteValue");
local tData = tTemp[1];
local tDataNames = tTemp[2];
local tNewData = {};
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if tData then
	if INIPlus.SectionDoesExist(sINIPlusFile, sSection) then
		if INIPlus.ValueDoesExist(sINIPlusFile, sSection, sInputValue) then
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
		
		
			for nSectionIndex = 1, Table.Count(tData) do
			local sCurrentSectionName = tDataNames[nSectionIndex].Name;
				
				local nValueCounter = 0;
				
				tNewData[nSectionIndex] = {};
				tNewData[nSectionIndex].Name = tData[sCurrentSectionName].Name;
				tNewData[nSectionIndex].Attribute = tData[sCurrentSectionName].Attribute;
				tNewData[nSectionIndex].Values = {};
				
				
				for nValueIndex = 1, Table.Count(tData[sCurrentSectionName].Values) do
				local sCurrentValueName = tDataNames[nSectionIndex].Values[nValueIndex].Name;
					
					if sInputValue ~= sCurrentValueName then
					nValueCounter = nValueCounter + 1;
					tNewData[nSectionIndex].Values[nValueCounter] = {};
					tNewData[nSectionIndex].Values[nValueCounter].Name = tData[sCurrentSectionName].Values[sCurrentValueName].Name;
					tNewData[nSectionIndex].Values[nValueCounter].Attribute = tData[sCurrentSectionName].Values[sCurrentValueName].Attribute;
					tNewData[nSectionIndex].Values[nValueCounter].Data = tData[sCurrentSectionName].Values[sCurrentValueName].Data;
					end
					
				end			
									
			end
		
		INIPlus.Write(sINIPlusFile, tNewData, "INIPlus.DeleteSection");

		else
		INIPlus.DisplayError("The value \""..sInputValue.."\" in file \""..sINIPlusFile.."\" does not exist.", "INIPlus.DeleteValue");
		end
		
	else
	INIPlus.DisplayError("The section \""..sSection.."\" in file \""..sINIPlusFile.."\" does not exist.", "INIPlus.DeleteValue");
	end
	
end
end



--==============================
-- INIPlus.ExportToINI
--==============================
function INIPlus.ExportToINI(...)
IRLUA_PLUGIN_CheckNumArgs(arg,3);
local sINIPlusFile = IRLUA_PLUGIN_CheckTypes(arg,1,{"string"});
local sINIFile = IRLUA_PLUGIN_CheckTypes(arg,2,{"string"});
local bIncludeAttributes = IRLUA_PLUGIN_CheckTypes(arg,3,{"boolean"});
local tTemp = INIPlus.Read(sINIPlusFile, "INIPlus.ExportToINI");
local tData = tTemp[1];
local tDataNames = tTemp[2];
local sDataText = "";
local sSectionAttribute = "";
local sValueAttribute = "";
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if tData then --ADD A SECTION IN HERE THAT WILL ADD ESCAPE CHARCTERS TO ALL ESCAPABLE CHARACTERS...If it needs it
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	for nSectionIndex = 1, Table.Count(tData) do
	local sSection = tDataNames[nSectionIndex].Name;
	
		if bIncludeAttributes == true then
		sSectionAttribute = tData[sSection].Attribute;
		
			if String.Replace(sSectionAttribute, " ", "", false) ~= "" then
			sSectionAttribute = "\r\n;"..sSectionAttribute;
			end
	
		end
		
		sDataText = sDataText.."["..sSection.."]"..sSectionAttribute.."\r\n";
	
			for nValueIndex = 1, Table.Count(tData[sSection].Values) do
			sValue = tDataNames[nSectionIndex].Values[nValueIndex].Name;
				
				if bIncludeAttributes == true then
				sValueAttribute = tData[sSection].Values[sValue].Attribute;
					
					if String.Replace(sValueAttribute, " ", "", false) ~= "" then
					sValueAttribute = "\r\n;"..sValueAttribute;
					end
				
				end
								
			sData = tData[sSection].Values[sValue].Data;
			sData = String.Replace(sData, "\r\n", "\"\\r\\n\"", false)
			
			sDataText = sDataText..sValue.."="..sData..sValueAttribute.."\r\n";
			end
					
	end
	
end

TextFile.WriteFromString(sINIFile, sDataText, false);

if INIPlus.IsError() then
INIPlus.DisplayError("The INIPlus file \""..sINIFile.."\" could not be created.", "INIPlus.ExportToINI");
end
end



--==============================
-- INIPlus.GetSectionAttribute
--==============================
function INIPlus.GetSectionAttribute(...)
IRLUA_PLUGIN_CheckNumArgs(arg,2);
local sINIPlusFile = IRLUA_PLUGIN_CheckTypes(arg,1,{"string"});
local sSection = IRLUA_PLUGIN_CheckTypes(arg,2,{"string"});
local tData = INIPlus.Read(sINIPlusFile, "INIPlus.GetSectionAttribute")[1];
local tRet = "";
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if tData then

	if tData[sSection] then
	sRet = tData[sSection].Attribute;
	else
	sRet = "";
	end
	
end
-->>>>>>
return sRet
end



--==============================
-- INIPlus.GetSectionNames
--==============================
function INIPlus.GetSectionNames(...)
IRLUA_PLUGIN_CheckNumArgs(arg,1);
local sINIPlusFile = IRLUA_PLUGIN_CheckTypes(arg,1,{"string"});
local tTemp = INIPlus.Read(sINIPlusFile, "INIPlus.GetSectionNames");
local tData = tTemp[1]; 
local tDataNames = tTemp[2];
local tRet = {};
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if tData then
	
	for x = 1, Table.Count(tData) do
	tRet[x] = tDataNames[x].Name
	end

end
return tRet
end



--==============================
-- INIPlus.GetValue
--==============================
function INIPlus.GetValue(...)
IRLUA_PLUGIN_CheckNumArgs(arg,3);
local sINIPlusFile = IRLUA_PLUGIN_CheckTypes(arg,1,{"string"});
local sSection = IRLUA_PLUGIN_CheckTypes(arg,2,{"string"});
local sValue = IRLUA_PLUGIN_CheckTypes(arg,3,{"string"});
local tData = INIPlus.Read(sINIPlusFile, "INIPlus.GetValue")[1];
local sRet = "";
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if tData then

	if tData[sSection] then
	
		if tData[sSection].Values[sValue] then		
		sRet = tData[sSection].Values[sValue].Data
		end

	end

end
return sRet
end



--==============================
-- INIPlus.GetValueAttribute
--==============================
function INIPlus.GetValueAttribute(...)
IRLUA_PLUGIN_CheckNumArgs(arg,3);
local sINIPlusFile = IRLUA_PLUGIN_CheckTypes(arg,1,{"string"});
local sSection = IRLUA_PLUGIN_CheckTypes(arg,2,{"string"});
local sValue = IRLUA_PLUGIN_CheckTypes(arg,3,{"string"});
local tData = INIPlus.Read(sINIPlusFile, "INIPlus.GetValueAttribute")[1];
local sRet = "";
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if tData then

	if tData[sSection] then
	
		if tData[sSection].Values[sValue] then
			
		sRet = tData[sSection].Values[sValue].Attribute
		end

	end

end
return sRet
end



--==============================
-- INIPlus.GetValueNames
--==============================
function INIPlus.GetValueNames(...)
IRLUA_PLUGIN_CheckNumArgs(arg,2);
local sINIPlusFile = IRLUA_PLUGIN_CheckTypes(arg,1,{"string"});
local sSection = IRLUA_PLUGIN_CheckTypes(arg,2,{"string"});
local tTemp = INIPlus.Read(sINIPlusFile, "INIPlus.GetValueNames");
local tData = tTemp[1]; 
local tDataNames = tTemp[2];
local tRet = {};
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if tData then
	
	if tData[sSection] then
	nSectionID = tData[sSection].ID
	
		for x = 1, Table.Count(tDataNames[nSectionID].Values) do
		tRet[x] = tDataNames[nSectionID].Values[x].Name;
		end
		
	end

end
return tRet
end



--==============================
-- INIPlus.ReadToTable
--==============================
function INIPlus.ReadToTable(...)
IRLUA_PLUGIN_CheckNumArgs(arg,1);
local sINIPlusFile = IRLUA_PLUGIN_CheckTypes(arg,1,{"string"});
local tTemp = INIPlus.Read(sINIPlusFile, "INIPlus.ReadToTable");
local tData = tTemp[1];
local tIndexedData = tTemp[2];
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if tData then
return {tData, tIndexedData}
else
return nil
end
end



--==============================
-- INIPlus.SectionDoesExist
--==============================
function INIPlus.SectionDoesExist(...)
IRLUA_PLUGIN_CheckNumArgs(arg,2);
local sINIPlusFile = IRLUA_PLUGIN_CheckTypes(arg,1,{"string"});
local sSection = IRLUA_PLUGIN_CheckTypes(arg,2,{"string"});
local tData = INIPlus.Read(sINIPlusFile, "INIPlus.SectionDoesExist")[1];
local bRet = nil
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if tData then
	
	if tData[sSection] then
	bRet = true;
	else
	bRet = false;
	end

end
return bRet
end



--==============================
-- INIPlus.SetSectionAttribute
--==============================
function INIPlus.SetSectionAttribute(...)
IRLUA_PLUGIN_CheckNumArgs(arg,3);
local sINIPlusFile = IRLUA_PLUGIN_CheckTypes(arg,1,{"string"});
local sSection = IRLUA_PLUGIN_CheckTypes(arg,2,{"string"});
local sAttribute = IRLUA_PLUGIN_CheckTypes(arg,3,{"string"});
local tTemp = INIPlus.Read(sINIPlusFile, "INIPlus.SetSectionAttribute");
local tData = tTemp[1];
local tIndexedData = tTemp[2];
local tNewData = {};
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if String.Replace(sSection, " ", "", false) ~= "" then
	if tData then
	local nSectionIndex = nil;
-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		if not INIPlus.SectionDoesExist(sINIPlusFile, sSection) then
		nSectionIndex = Table.Count(tIndexedData) + 1;
		
		tIndexedData[nSectionIndex] = {};
		tIndexedData[nSectionIndex].ID = nSectionIndex;
		tIndexedData[nSectionIndex].Name = sSection;
		tIndexedData[nSectionIndex].Attribute = sAttribute;
		tIndexedData[nSectionIndex].Values = {};
		elseif INIPlus.SectionDoesExist(sINIPlusFile, sSection) then
		nSectionIndex = tData[sSection].ID;
		tIndexedData[nSectionIndex].Attribute = sAttribute;
		end
		
	INIPlus.Write(sINIPlusFile, tIndexedData, "INIPlus.SetSectionAttribute");

	end

else
INIPlus.DisplayError("The section name for file \""..sINIPlusFile.."\" cannot be blank.", "INIPlus.SetValueAttribute");
end
end



--==============================
-- INIPlus.SetValueAttribute
--==============================
function INIPlus.SetValueAttribute(...)
IRLUA_PLUGIN_CheckNumArgs(arg,4);
local sINIPlusFile = IRLUA_PLUGIN_CheckTypes(arg,1,{"string"});
local sSection = IRLUA_PLUGIN_CheckTypes(arg,2,{"string"});
local sValue = IRLUA_PLUGIN_CheckTypes(arg,3,{"string"});
local sAttribute = IRLUA_PLUGIN_CheckTypes(arg,4,{"string"});
local tTemp = INIPlus.Read(sINIPlusFile, "INIPlus.SetValueAttribute");
local tData = tTemp[1];
local tIndexedData = tTemp[2];
local tNewData = {};
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if String.Replace(sSection, " ", "", false) ~= "" then
	if String.Replace(sValue, " ", "", false) ~= "" then
		if tData then
		local nSectionIndex = nil;
		local nValueIndex = nil;
-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
			if not INIPlus.SectionDoesExist(sINIPlusFile, sSection) then
			nSectionIndex = Table.Count(tIndexedData) + 1;
			
			tIndexedData[nSectionIndex] = {};
			tIndexedData[nSectionIndex].ID = nSectionIndex;
			tIndexedData[nSectionIndex].Name = sSection;
			tIndexedData[nSectionIndex].Attribute = "";
			tIndexedData[nSectionIndex].Values = {};
			elseif INIPlus.SectionDoesExist(sINIPlusFile, sSection) then
			nSectionIndex = tData[sSection].ID;
			end
		
		
			if not INIPlus.ValueDoesExist(sINIPlusFile, sSection, sValue) then
			nValueIndex = Table.Count(tIndexedData[nSectionIndex].Values) + 1;
			
			tIndexedData[nSectionIndex].Values[nValueIndex] = {};
			tIndexedData[nSectionIndex].Values[nValueIndex].ID = nValueIndex;
			tIndexedData[nSectionIndex].Values[nValueIndex].Name = sValue;
			tIndexedData[nSectionIndex].Values[nValueIndex].Attribute = sAttribute;
			tIndexedData[nSectionIndex].Values[nValueIndex].Data = "";
			elseif INIPlus.ValueDoesExist(sINIPlusFile, sSection, sValue) then
			nValueIndex = tData[sSection].Values[sValue].ID;
			tIndexedData[nSectionIndex].Values[nValueIndex].Attribute = sAttribute;
			end
			
		INIPlus.Write(sINIPlusFile, tIndexedData, "INIPlus.SetValueAttribute");
		end
			
	else
	INIPlus.DisplayError("The value name for file \""..sINIPlusFile.."\" cannot be blank.", "INIPlus.SetValueAttribute");
	end
			
else
INIPlus.DisplayError("The section name for file \""..sINIPlusFile.."\" cannot be blank.", "INIPlus.SetValueAttribute");
end
end



--==============================
-- INIPlus.SetValueData
--==============================
function INIPlus.SetValueData(...)
IRLUA_PLUGIN_CheckNumArgs(arg,4);
local sINIPlusFile = IRLUA_PLUGIN_CheckTypes(arg,1,{"string"});
local sSection = IRLUA_PLUGIN_CheckTypes(arg,2,{"string"});
local sValue = IRLUA_PLUGIN_CheckTypes(arg,3,{"string"});
local sData = IRLUA_PLUGIN_CheckTypes(arg,4,{"string"});
local tTemp = INIPlus.Read(sINIPlusFile, "INIPlus.SetValueData");
local tData = tTemp[1];
local tIndexedData = tTemp[2];
local tNewData = {};
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if String.Replace(sSection, " ", "", false) ~= "" then
	if String.Replace(sValue, " ", "", false) ~= "" then
		if tData then
			local nSectionIndex = nil;
			local nValueIndex = nil;
-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
			if not INIPlus.SectionDoesExist(sINIPlusFile, sSection) then
			nSectionIndex = Table.Count(tIndexedData) + 1;
			
			tIndexedData[nSectionIndex] = {};
			tIndexedData[nSectionIndex].ID = nSectionIndex;
			tIndexedData[nSectionIndex].Name = sSection;
			tIndexedData[nSectionIndex].Attribute = "";
			tIndexedData[nSectionIndex].Values = {};
			elseif INIPlus.SectionDoesExist(sINIPlusFile, sSection) then
			nSectionIndex = tData[sSection].ID;
			end


			if not INIPlus.ValueDoesExist(sINIPlusFile, sSection, sValue) then
			nValueIndex = Table.Count(tIndexedData[nSectionIndex].Values) + 1;
			
			tIndexedData[nSectionIndex].Values[nValueIndex] = {};
			tIndexedData[nSectionIndex].Values[nValueIndex].ID = nValueIndex;
			tIndexedData[nSectionIndex].Values[nValueIndex].Name = sValue;
			tIndexedData[nSectionIndex].Values[nValueIndex].Attribute = "";
			tIndexedData[nSectionIndex].Values[nValueIndex].Data = sData;
			elseif INIPlus.ValueDoesExist(sINIPlusFile, sSection, sValue) then
			nValueIndex = tData[sSection].Values[sValue].ID;
			tIndexedData[nSectionIndex].Values[nValueIndex].Data = sData;
			end

		INIPlus.Write(sINIPlusFile, tIndexedData, "INIPlus.SetValueData");
		end
		
	else
	INIPlus.DisplayError("The value name for file \""..sINIPlusFile.."\" cannot be blank.", "INIPlus.SetValueData");
	end
else
INIPlus.DisplayError("The section name for file \""..sINIPlusFile.."\" cannot be blank.", "INIPlus.SetValueData");
end
end



--===================================
-- INIPlus.SetValueAttributeAndData
--===================================
function INIPlus.SetValueAttributeAndData(...)
IRLUA_PLUGIN_CheckNumArgs(arg,5);
local sINIPlusFile = IRLUA_PLUGIN_CheckTypes(arg,1,{"string"});
local sSection = IRLUA_PLUGIN_CheckTypes(arg,2,{"string"});
local sValue = IRLUA_PLUGIN_CheckTypes(arg,3,{"string"});
local sAttribute = IRLUA_PLUGIN_CheckTypes(arg,4,{"string"});
local sData = IRLUA_PLUGIN_CheckTypes(arg,5,{"string"});
local tTemp = INIPlus.Read(sINIPlusFile, "INIPlus.SetValueAttributeAndData");
local tData = tTemp[1];
local tIndexedData = tTemp[2];
local tNewData = {};
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if String.Replace(sSection, " ", "", false) ~= "" then
	if String.Replace(sValue, " ", "", false) ~= "" then
		if tData then
		local nSectionIndex = nil;
		local nValueIndex = nil;
-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
			if not INIPlus.SectionDoesExist(sINIPlusFile, sSection) then
			nSectionIndex = Table.Count(tIndexedData) + 1;
			
			tIndexedData[nSectionIndex] = {};
			tIndexedData[nSectionIndex].ID = nSectionIndex;
			tIndexedData[nSectionIndex].Name = sSection;
			tIndexedData[nSectionIndex].Attribute = "";
			tIndexedData[nSectionIndex].Values = {};
			elseif INIPlus.SectionDoesExist(sINIPlusFile, sSection) then
			nSectionIndex = tData[sSection].ID;
			end
			
			
			if not INIPlus.ValueDoesExist(sINIPlusFile, sSection, sValue) then
			nValueIndex = Table.Count(tIndexedData[nSectionIndex].Values) + 1;
			
			tIndexedData[nSectionIndex].Values[nValueIndex] = {};
			tIndexedData[nSectionIndex].Values[nValueIndex].ID = nValueIndex;
			tIndexedData[nSectionIndex].Values[nValueIndex].Name = sValue;
			tIndexedData[nSectionIndex].Values[nValueIndex].Attribute = sAttribute;
			tIndexedData[nSectionIndex].Values[nValueIndex].Data = sData;
			elseif INIPlus.ValueDoesExist(sINIPlusFile, sSection, sValue) then
			nValueIndex = tData[sSection].Values[sValue].ID;
			tIndexedData[nSectionIndex].Values[nValueIndex].Attribute = sAttribute;
			tIndexedData[nSectionIndex].Values[nValueIndex].Data = sData;
			end
		
		INIPlus.Write(sINIPlusFile, tIndexedData, "INIPlus.SetValueAttributeAndData");
		end
		
	else
	INIPlus.DisplayError("The value name for file \""..sINIPlusFile.."\" cannot be blank.", "INIPlus.SetValueAttributeAndData");
	end

else
INIPlus.DisplayError("The section name for file \""..sINIPlusFile.."\" cannot be blank.", "INIPlus.SetValueAttributeAndData");
end
end



--==============================
-- INIPlus.ShowErrors
--==============================
function INIPlus.ShowErrors(...)
IRLUA_PLUGIN_CheckNumArgs(arg,1);
local bShowErrors = IRLUA_PLUGIN_CheckTypes(arg,1,{"boolean"});
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if bShowErrors == true then
INIPLUS_ERRORS_ON = true;
elseif bShowErrors == false then
INIPLUS_ERRORS_ON = false;
end
end



--==============================
-- INIPlus.ValueDoesExist
--==============================
function INIPlus.ValueDoesExist(...)
IRLUA_PLUGIN_CheckNumArgs(arg,3);
local sINIPlusFile = IRLUA_PLUGIN_CheckTypes(arg,1,{"string"});
local sSection = IRLUA_PLUGIN_CheckTypes(arg,2,{"string"});
local sValue = IRLUA_PLUGIN_CheckTypes(arg,3,{"string"});
local tData = INIPlus.Read(sINIPlusFile, "INIPlus.ValueDoesExist")[1];
local bRet = nil;
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if INIPlus.SectionDoesExist(sINIPlusFile ,sSection) then
	if tData then
	--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
		
		if tData[sSection] then
			
			if tData[sSection].Values[sValue] then
			bRet = true;
			else
			bRet = false;
			end
		
		end
		
	end

else
bRet = false;
-- THIS HAS BEEN REMOVED BECAUSE THE VALUE SHOULD BE FALSE IF THE SECTION DOES NOT EXIST INSTEAD OF THROWING AN ERROR
--INIPlus.DisplayError("The section \""..sSection.."\" in file \""..sINIPlusFile.."\" does not exist.", "INIPlus.ValueDoesExist");
end
return bRet
end