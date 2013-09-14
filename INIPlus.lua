--[[
> INIPlus
> Concept and Code By Centauri Soldier
> http://www.github.com/CentauriSoldier/LuaPlugs
> Version 3.6
>
> This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.
> To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/
> or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
--]]
require "AAA"
INIPlus = {};
local tINIPlus = {
	AutoSave = false,	
	Files = {},
};
local INIPLUS_ERRORS_ON = false;
local INIPLUS_ESCAPE_CHAR = "^";

--====================>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- <BEGIN HIDDEN FUNCTIONS> 
--====================>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


--==============
-- INIPlus.GetError
--==============
function INIPlus.GetError()
return Application.GetLastError()
end



--==============
-- INIPlus.IsError
--==============
function INIPlus.IsError()
local bReturn = false;

if INIPlus.GetError() > 0 then
bReturn = true;
end

return bReturn
end



--==============
-- INIPlus.DisplayError
--==============
function INIPlus.DisplayError(...)
AAA.CheckNumArgs(arg,2);
local sError = AAA.CheckTypes(arg,1,{"string"});
local sFunctionName = AAA.CheckTypes(arg,2,{"string"});
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if INIPLUS_ERRORS_ON then
sLastError = "";
	
	if INIPlus.GetError() > 0 then
	sLastError = _tblErrorMessages[INIPlus.GetError()];
	end
	
error("Error in \""..sFunctionName.."\" function.\r\n"..sError.."\r\n"..sLastError);

end
end



--==============
-- INIPlus.Read
--==============
function INIPlus.Read(...)
AAA.CheckNumArgs(arg,2);
local sINIPlusFile = AAA.CheckTypes(arg,1,{"string"});
local sCallingFunction = AAA.CheckTypes(arg,2,{"string"});
local tSections = {};
--created for when we need to index the sections and value names
local tNames = {};
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if not File.DoesExist(sINIPlusFile) then
INIPlus.DisplayError("Error reading INIPlus file \""..sINIPlusFile.."\"", sCallingFunction);
else
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
local function ParseString(sInputString, tEscapableCharacters, sEscapeChar)
local sParsableIPText = sInputString;
local sReadableIPText = sInputString;
local tEscapeSequences = {};
Table.Insert(tEscapableCharacters, #tEscapableCharacters, sEscapeChar)

for nIndex, sChar in pairs(tEscapableCharacters) do
tEscapeSequences[nIndex] = {};
tEscapeSequences[nIndex].Sequence = sEscapeChar..sChar;
tEscapeSequences[nIndex].Readable = sChar;
tEscapeSequences[nIndex].Parsable = sEscapeChar;
end

for nIndex = 1, #tEscapeSequences do
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
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
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
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
local nSearchPoint = 0;
local nLastSectionStart = 0;
local nTotalSections = CountItems(sParsableIPText, "%[", 1, nFileLength);
for nSectionIndex = 1, nTotalSections do
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
--BEGIN || GET THE SECTION AND ATTRIBUTE START AND END POINTS
local nSectionStart = String.Find(sParsableIPText, "%[", nSearchPoint + 1, false);
local nSectionEnd = String.Find(sParsableIPText, "%]", nSectionStart + 1, false);
local nAttributeStart = (String.Find(sParsableIPText, "\"", nSectionStart, false));
local nAttributeEnd = (String.Find(sParsableIPText, "\"", nAttributeStart + 1, false));
local nSectionBoundary = String.Find(sParsableIPText, "%[", nSectionEnd + 1, false) - 1;
if nLastSectionStart > nSectionStart or nSectionBoundary < 1 then
nSectionBoundary = nFileLength;
end
nLastSectionStart = nSectionStart;
--END || GET THE SECTION AND ATTRIBUTE START AND END POINTS
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
--BEGIN || GET THE SECTION NAME AND ATTTRIBUTE
local sSectionName = String.Mid(sReadableIPText, nSectionStart + 1, (nAttributeStart - nSectionStart) - 1);
local sSectionAttribute = String.Mid(sReadableIPText, nAttributeStart + 1, (nAttributeEnd - nAttributeStart) - 1);
--END || GET THE SECTION NAME AND ATTTRIBUTE
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
--BEGIN || WRITE SECTION DETAILS TO THE TABLE
tSections[sSectionName] = {
	ID = nSectionIndex,
	Name = sSectionName,
	Attribute = sSectionAttribute,
	Values = {},
};
--created for when we need to index the sections
tNames[nSectionIndex] = {
	ID = nSectionIndex,
	Name = sSectionName,
	Attribute = sSectionAttribute,
	Values = {},
};
--END || WRITE SECTION DETAILS TO THE TABLE
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
--BEGIN || GET THE VALUES FOR THIS SECTION
local nValueSearchPoint = nSectionEnd;
local nTotalValues = CountItems(sParsableIPText, "|", nSectionStart, nSectionBoundary);
	for nValueIndex = 1, nTotalValues do
	--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	--BEGIN || GET THE VALUE, ATTRIBUTE AND DATA START AND END POINTS
	local nValueStart = string.find(sParsableIPText, "|", nValueSearchPoint + 1);
	local nValueEnd = string.find(sParsableIPText, "\'", nValueStart + 1);
	local nValueAttributeStart = nValueEnd;
	local nValueAttributeEnd = string.find(sParsableIPText, "\'", nValueAttributeStart + 1);
	local nDataStart = string.find(sParsableIPText, "<", nValueAttributeEnd + 1);
	local nDataEnd = string.find(sParsableIPText, ">", nDataStart + 1);
	--END || GET THE VALUE, ATTRIBUTE AND DATA START AND END POINTS
	--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	--BEGIN || GET THE VALUE, ATTRIBUTE AND DATA
	local sValueName = String.Mid(sReadableIPText, nValueStart + 1, (nValueAttributeStart - nValueStart) - 1);
	local sValueAttribute = String.Mid(sReadableIPText, nValueAttributeStart + 1, (nValueAttributeEnd - nValueAttributeStart) - 1);
	local sValueData = String.Mid(sReadableIPText, nDataStart + 1, (nDataEnd - nDataStart) - 1);
	--END || GET THE VALUE, ATTRIBUTE AND DATA
	--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	tSections[sSectionName].Values[sValueName] = {
		ID = nValueIndex,
		Name = sValueName,
		Attribute = sValueAttribute,
		Data = sValueData,
	};
	--created for when we need to index the values
	tNames[nSectionIndex].Values[nValueIndex] = {
		ID = nValueIndex,
		Name = sValueName,
		Attribute = sValueAttribute,
		Data = sValueData,
	};
	nValueSearchPoint = nDataEnd + 1;
	end
	--END || GET THE VALUES FOR THIS SECTION
	--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
nSearchPoint = nSectionBoundary;
end
--<<<<<<<<<<<<<<<<<
end
return {tSections, tNames}
end



--==============
-- INIPlus.Write
--==============
function INIPlus.Write(...)
AAA.CheckNumArgs(arg,3);
local sINIPlusFile = AAA.CheckTypes(arg,1,{"string"});
local tData = AAA.CheckTypes(arg,2,{"table"});
local sCallingFunction = AAA.CheckTypes(arg,3,{"string"});
local sSpacer = "";
local sDataText = "";
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if not File.DoesExist(sINIPlusFile) then
TextFile.WriteFromString(sINIPlusFile, "", false);
	
	if INIPlus.IsError() then
	INIPlus.DisplayError("The INIPlus file \""..sINIPlusFile.."\" could not be created.", sCallingFunction);
	end
	
end
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if tData then

	for x = 1, #tData do
	sDataText = sDataText.."["..tData[x].Name.."\""..tData[x].Attribute.."\"]".."\r\n";

		for y = 1, #tData[x].Values do
		sDataText = sDataText.."|"..tData[x].Values[y].Name.."'"..tData[x].Values[y].Attribute.."'<"..tData[x].Values[y].Data..">".."\r\n";
		end
				
	end

TextFile.WriteFromString(sINIPlusFile, sDataText, false);
if INIPlus.IsError() then
INIPlus.DisplayError("Error writing to file. \""..sINIPlusFile.."\".", sCallingFunction);
end
end
end
--===================================================================================================================================================
-- <END HIDDEN FUNCTIONS> <END HIDDEN FUNCTIONS> <END HIDDEN FUNCTIONS> <END HIDDEN FUNCTIONS> <END HIDDEN FUNCTIONS> <END HIDDEN FUNCTIONS> <END HIDDEN FUNCTIONS>
--===================================================================================================================================================










function INIPlus.New(sInputPath)
local nID = #tINIPlus.Files + 1;
local sPath = "";

	if type(sInputPath) == "string" then
	sPath = sInputPath;
	end

	tINIPlus.Files[nID] = {
		Data = {},
		ID = nID,
		Path = sPath,
	};

return nID
end






function INIPlus.CreateSection(...)
AAA.CheckNumArgs(arg,3);
local nID = AAA.CheckTypes(arg,1,{"number"});
local sSection = AAA.CheckTypes(arg,2,{"string"});

	if tINIPlus.Files[nID] then
		
		if string.gsub(sSection, " ", "") ~= "" then	
			
			if not tINIPlus.Files[nID].Data[sSection] then
			tINIPlus.Files[nID].Data[sSection] = {};
			return true
			end
			
		end
		
	end

return false
end



function INIPlus.SetSectionName(...)
AAA.CheckNumArgs(arg,3);
local nID = AAA.CheckTypes(arg,1,{"number"});
local sOldSection = AAA.CheckTypes(arg,2,{"string"});
local sNewSection = AAA.CheckTypes(arg,3,{"string"});

	if tINIPlus.Files[nID] then
		
		if string.gsub(sSection, " ", "") ~= "" and string.gsub(sSection, " ", "") ~= "" then
			
			if tINIPlus.Files[nID].Data[sOldSection] then
			tINIPlus.Files[nID].Data[sNewSection] = {};
			
				for sValue, tValue in pairs(tINIPlus.Files[nID].Data[sOldSection]) do
				tINIPlus.Files[nID].Data[sNewSection][sValue] = {};
				
					for sIndex, sItem in pairs(tValue) do
					tINIPlus.Files[nID].Data[sNewSection][sValue][sIndex] = sItem;
					end
					
				end
			
			tINIPlus.Files[nID].Data[sOldSection] = nil;
			end
			
		end
		
	end

return false
end



















--==============
-- INIPlus.CreateFromINI
--==============
function INIPlus.CreateFromINI(...)
AAA.CheckNumArgs(arg,2);
local sINIPlusFile = AAA.CheckTypes(arg,1,{"string"});
local sINIFile = AAA.CheckTypes(arg,2,{"string"});
local tNewData = {};
if File.DoesExist(sINIFile) then
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
local tAllSections = INIFile.GetSectionNames(sINIFile);

if tAllSections then

	for x = 1, #tAllSections do
	local sSectionName = tAllSections[x];
	
	tNewData[x] = {}
	tNewData[x].Name = sSectionName;
	tNewData[x].Attribute = "";
	tNewData[x].Values = {};
	
	local tAllValues = INIFile.GetValueNames(sINIFile, sSectionName);
		
		if tAllValues then
			
			for y = 1, #tAllValues do
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



--==============
-- INIPlus.ChangeSectionName
--==============
function INIPlus.ChangeSectionName(...)
AAA.CheckNumArgs(arg,3);
local sINIPlusFile = AAA.CheckTypes(arg,1,{"string"});
local sOldSectionName = AAA.CheckTypes(arg,2,{"string"});
local sNewSectionName = AAA.CheckTypes(arg,3,{"string"});
local tTemp = INIPlus.Read(sINIPlusFile, "INIPlus.ChangeSectionName");
local tData = tTemp[1];
local tIndexedData = tTemp[2];
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if INIPlus.SectionExists(sINIPlusFile, sOldSectionName) then
	if not INIPlus.SectionExists(sINIPlusFile, sNewSectionName) then
		if String.Replace(sOldSectionName, " ", "", false) ~= "" and String.Replace(sNewSectionName, " ", "", false) ~= "" then
			if tData then
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
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



--==============
-- INIPlus.CopySection
--==============
function INIPlus.CopySection(...)
AAA.CheckNumArgs(arg,3);
local sINIPlusFile = AAA.CheckTypes(arg,1,{"string"});
local sSection = AAA.CheckTypes(arg,2,{"string"});
local sNewSection = AAA.CheckTypes(arg,3,{"string"});
local tTemp = INIPlus.Read(sINIPlusFile, "INIPlus.CopySection");
local tData = tTemp[1];
local tIndexedData= tTemp[2];
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if String.Replace(sSection, " ", "", false) ~= "" and String.Replace(sNewSection, " ", "", false) ~= "" then	
	if tData then
		if INIPlus.SectionExists(sINIPlusFile, sSection) and not INIPlus.SectionExists(sINIPlusFile, sNewSection) and INIPlus.SectionExists(sINIPlusFile, sNewSection) ~= INIPlus.SectionExists(sINIPlusFile, sSection) then
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
		
		local nNewIndex = #tIndexedData + 1;
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
		
		elseif not INIPlus.SectionExists(sINIPlusFile, sSection) then
		INIPlus.DisplayError("The section \""..sSection.."\" in file \""..sINIPlusFile.."\" does not exist.", "INIPlus.CopySection");
		elseif INIPlus.SectionExists(sINIPlusFile, sNewSection) then
		INIPlus.DisplayError("The section \""..sSection.."\" in file \""..sINIPlusFile.."\" already exists.", "INIPlus.CopySection");
		elseif INIPlus.SectionExists(sINIPlusFile, sNewSection) == INIPlus.SectionExists(sINIPlusFile, sSection) then
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



--==============
-- INIPlus.CountSections
--==============
function INIPlus.CountSections(...)
AAA.CheckNumArgs(arg,1);
local sINIPlusFile = AAA.CheckTypes(arg,1,{"string"});
local tData = INIPlus.Read(sINIPlusFile, "INIPlus.CountSections")[1];
local nRet = -1;
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if tData then
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
nRet = #tData;
-->>>>>>>
end
return nRet;
end



--==============
-- INIPlus.CountValues
--==============
function INIPlus.CountValues(...)
AAA.CheckNumArgs(arg,2);
local sINIPlusFile = AAA.CheckTypes(arg,1,{"string"});
local sSection = AAA.CheckTypes(arg,2,{"string"});
local tData = INIPlus.Read(sINIPlusFile, "INIPlus.CountSections")[1];
local nRet = -1;
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if tData then
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	
	if INIPlus.SectionExists(sINIPlusFile, sSection) then
	nRet = #tData[sSection].Values;
	end
	
end
return nRet
end



--==============
-- INIPlus.DeleteSection
--==============
function INIPlus.DeleteSection(...)
AAA.CheckNumArgs(arg,2);
local sINIPlusFile = AAA.CheckTypes(arg,1,{"string"});
local sInputSection = AAA.CheckTypes(arg,2,{"string"});
local tTemp = INIPlus.Read(sINIPlusFile, "INIPlus.DeleteSection");
local tData = tTemp[1];
local tDataNames = tTemp[2];
local tNewData = {};
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if INIPlus.SectionExists(sINIPlusFile, sInputSection) then
	if tData then
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	local nSectionCounter = 0;
		
		for nSectionIndex = 1, #tData do
		local sCurrentSectionName = tDataNames[nSectionIndex].Name;
			
				if sCurrentSectionName ~= sInputSection then
				nSectionCounter = nSectionCounter + 1;
				local nValueCounter = 0;
				
				tNewData[nSectionCounter] = {};
				tNewData[nSectionCounter].Name = tData[sCurrentSectionName].Name;
				tNewData[nSectionCounter].Attribute = tData[sCurrentSectionName].Attribute;
				tNewData[nSectionCounter].Values = {};
		
				
					for nValueIndex = 1, #tData[sCurrentSectionName].Values do
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



--==============
-- INIPlus.DeleteValue
--==============
function INIPlus.DeleteValue(...)
AAA.CheckNumArgs(arg,3);
local sINIPlusFile = AAA.CheckTypes(arg,1,{"string"});
local sSection = AAA.CheckTypes(arg,2,{"string"});
local sInputValue = AAA.CheckTypes(arg,3,{"string"});
local tTemp = INIPlus.Read(sINIPlusFile, "INIPlus.DeleteValue");
local tData = tTemp[1];
local tDataNames = tTemp[2];
local tNewData = {};
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if tData then
	if INIPlus.SectionExists(sINIPlusFile, sSection) then
		if INIPlus.ValueExists(sINIPlusFile, sSection, sInputValue) then
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
		
		
			for nSectionIndex = 1, #tData do
			local sCurrentSectionName = tDataNames[nSectionIndex].Name;
				
				local nValueCounter = 0;
				
				tNewData[nSectionIndex] = {};
				tNewData[nSectionIndex].Name = tData[sCurrentSectionName].Name;
				tNewData[nSectionIndex].Attribute = tData[sCurrentSectionName].Attribute;
				tNewData[nSectionIndex].Values = {};
				
				
				for nValueIndex = 1, #tData[sCurrentSectionName].Values do
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



--==============
-- INIPlus.ExportToINI
--==============
function INIPlus.ExportToINI(...)
AAA.CheckNumArgs(arg,3);
local sINIPlusFile = AAA.CheckTypes(arg,1,{"string"});
local sINIFile = AAA.CheckTypes(arg,2,{"string"});
local bIncludeAttributes = AAA.CheckTypes(arg,3,{"boolean"});
local tTemp = INIPlus.Read(sINIPlusFile, "INIPlus.ExportToINI");
local tData = tTemp[1];
local tDataNames = tTemp[2];
local sDataText = "";
local sSectionAttribute = "";
local sValueAttribute = "";
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if tData then --ADD A SECTION IN HERE THAT WILL ADD ESCAPE CHARCTERS TO ALL ESCAPABLE CHARACTERS...If it needs it
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	for nSectionIndex = 1, #tData do
	local sSection = tDataNames[nSectionIndex].Name;
	
		if bIncludeAttributes == true then
		sSectionAttribute = tData[sSection].Attribute;
		
			if String.Replace(sSectionAttribute, " ", "", false) ~= "" then
			sSectionAttribute = "\r\n;"..sSectionAttribute;
			end
	
		end
		
		sDataText = sDataText.."["..sSection.."]"..sSectionAttribute.."\r\n";
	
			for nValueIndex = 1, #tData[sSection].Values# do
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



--==============
-- INIPlus.GetSectionAttribute
--==============
function INIPlus.GetSectionAttribute(...)
AAA.CheckNumArgs(arg,2);
local sINIPlusFile = AAA.CheckTypes(arg,1,{"string"});
local sSection = AAA.CheckTypes(arg,2,{"string"});
local tData = INIPlus.Read(sINIPlusFile, "INIPlus.GetSectionAttribute")[1];
local tRet = "";
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
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



--==============
-- INIPlus.GetSectionNames
--==============
function INIPlus.GetSectionNames(...)
AAA.CheckNumArgs(arg,1);
local sINIPlusFile = AAA.CheckTypes(arg,1,{"string"});
local tTemp = INIPlus.Read(sINIPlusFile, "INIPlus.GetSectionNames");
local tData = tTemp[1]; 
local tDataNames = tTemp[2];
local tRet = {};
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if tData then
	
	for x = 1, #tData do
	tRet[x] = tDataNames[x].Name
	end

end
return tRet
end



--==============
-- INIPlus.GetValue
--==============
function INIPlus.GetValue(...)
AAA.CheckNumArgs(arg,3);
local sINIPlusFile = AAA.CheckTypes(arg,1,{"string"});
local sSection = AAA.CheckTypes(arg,2,{"string"});
local sValue = AAA.CheckTypes(arg,3,{"string"});
local tData = INIPlus.Read(sINIPlusFile, "INIPlus.GetValue")[1];
local sRet = "";
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if tData then

	if tData[sSection] then
	
		if tData[sSection].Values[sValue] then		
		sRet = tData[sSection].Values[sValue].Data
		end

	end

end
return sRet
end



--==============
-- INIPlus.GetValueAttribute
--==============
function INIPlus.GetValueAttribute(...)
AAA.CheckNumArgs(arg,3);
local sINIPlusFile = AAA.CheckTypes(arg,1,{"string"});
local sSection = AAA.CheckTypes(arg,2,{"string"});
local sValue = AAA.CheckTypes(arg,3,{"string"});
local tData = INIPlus.Read(sINIPlusFile, "INIPlus.GetValueAttribute")[1];
local sRet = "";
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if tData then

	if tData[sSection] then
	
		if tData[sSection].Values[sValue] then
			
		sRet = tData[sSection].Values[sValue].Attribute
		end

	end

end
return sRet
end



--==============
-- INIPlus.GetValueNames
--==============
function INIPlus.GetValueNames(...)
AAA.CheckNumArgs(arg,2);
local sINIPlusFile = AAA.CheckTypes(arg,1,{"string"});
local sSection = AAA.CheckTypes(arg,2,{"string"});
local tTemp = INIPlus.Read(sINIPlusFile, "INIPlus.GetValueNames");
local tData = tTemp[1]; 
local tDataNames = tTemp[2];
local tRet = {};
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if tData then
	
	if tData[sSection] then
	nSectionID = tData[sSection].ID
	
		for x = 1, #tDataNames[nSectionID].Values do
		tRet[x] = tDataNames[nSectionID].Values[x].Name;
		end
		
	end

end
return tRet
end



--==============
-- INIPlus.ReadToTable
--==============
function INIPlus.ReadToTable(...)
AAA.CheckNumArgs(arg,1);
local sINIPlusFile = AAA.CheckTypes(arg,1,{"string"});
local tTemp = INIPlus.Read(sINIPlusFile, "INIPlus.ReadToTable");
local tData = tTemp[1];
local tIndexedData = tTemp[2];
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if tData then
return {tData, tIndexedData}
else
return nil
end
end



--==============
-- INIPlus.SectionExists
--==============
function INIPlus.SectionExists(...)
AAA.CheckNumArgs(arg,2);
local sINIPlusFile = AAA.CheckTypes(arg,1,{"string"});
local sSection = AAA.CheckTypes(arg,2,{"string"});
local tData = INIPlus.Read(sINIPlusFile, "INIPlus.SectionExists")[1];
local bRet = nil
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if tData then
	
	if tData[sSection] then
	bRet = true;
	else
	bRet = false;
	end

end
return bRet
end



--==============
-- INIPlus.SetSectionAttribute
--==============
function INIPlus.SetSectionAttribute(...)
AAA.CheckNumArgs(arg,3);
local sINIPlusFile = AAA.CheckTypes(arg,1,{"string"});
local sSection = AAA.CheckTypes(arg,2,{"string"});
local sAttribute = AAA.CheckTypes(arg,3,{"string"});
local tTemp = INIPlus.Read(sINIPlusFile, "INIPlus.SetSectionAttribute");
local tData = tTemp[1];
local tIndexedData = tTemp[2];
local tNewData = {};
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if String.Replace(sSection, " ", "", false) ~= "" then
	if tData then
	local nSectionIndex = nil;
-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		if not INIPlus.SectionExists(sINIPlusFile, sSection) then
		nSectionIndex = #tIndexedData + 1;
		
		tIndexedData[nSectionIndex] = {};
		tIndexedData[nSectionIndex].ID = nSectionIndex;
		tIndexedData[nSectionIndex].Name = sSection;
		tIndexedData[nSectionIndex].Attribute = sAttribute;
		tIndexedData[nSectionIndex].Values = {};
		elseif INIPlus.SectionExists(sINIPlusFile, sSection) then
		nSectionIndex = tData[sSection].ID;
		tIndexedData[nSectionIndex].Attribute = sAttribute;
		end
		
	INIPlus.Write(sINIPlusFile, tIndexedData, "INIPlus.SetSectionAttribute");

	end

else
INIPlus.DisplayError("The section name for file \""..sINIPlusFile.."\" cannot be blank.", "INIPlus.SetValueAttribute");
end
end



--==============
-- INIPlus.SetValueAttribute
--==============
function INIPlus.SetValueAttribute(...)
AAA.CheckNumArgs(arg,4);
local sINIPlusFile = AAA.CheckTypes(arg,1,{"string"});
local sSection = AAA.CheckTypes(arg,2,{"string"});
local sValue = AAA.CheckTypes(arg,3,{"string"});
local sAttribute = AAA.CheckTypes(arg,4,{"string"});
local tTemp = INIPlus.Read(sINIPlusFile, "INIPlus.SetValueAttribute");
local tData = tTemp[1];
local tIndexedData = tTemp[2];
local tNewData = {};
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if String.Replace(sSection, " ", "", false) ~= "" then
	if String.Replace(sValue, " ", "", false) ~= "" then
		if tData then
		local nSectionIndex = nil;
		local nValueIndex = nil;
-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
			if not INIPlus.SectionExists(sINIPlusFile, sSection) then
			nSectionIndex = #tIndexedData + 1;
			
			tIndexedData[nSectionIndex] = {};
			tIndexedData[nSectionIndex].ID = nSectionIndex;
			tIndexedData[nSectionIndex].Name = sSection;
			tIndexedData[nSectionIndex].Attribute = "";
			tIndexedData[nSectionIndex].Values = {};
			elseif INIPlus.SectionExists(sINIPlusFile, sSection) then
			nSectionIndex = tData[sSection].ID;
			end
		
		
			if not INIPlus.ValueExists(sINIPlusFile, sSection, sValue) then
			nValueIndex = #tIndexedData[nSectionIndex].Values + 1;
			
			tIndexedData[nSectionIndex].Values[nValueIndex] = {};
			tIndexedData[nSectionIndex].Values[nValueIndex].ID = nValueIndex;
			tIndexedData[nSectionIndex].Values[nValueIndex].Name = sValue;
			tIndexedData[nSectionIndex].Values[nValueIndex].Attribute = sAttribute;
			tIndexedData[nSectionIndex].Values[nValueIndex].Data = "";
			elseif INIPlus.ValueExists(sINIPlusFile, sSection, sValue) then
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



--==============
-- INIPlus.SetValueData
--==============
function INIPlus.SetValueData(...)
AAA.CheckNumArgs(arg,4);
local sINIPlusFile = AAA.CheckTypes(arg,1,{"string"});
local sSection = AAA.CheckTypes(arg,2,{"string"});
local sValue = AAA.CheckTypes(arg,3,{"string"});
local sData = AAA.CheckTypes(arg,4,{"string"});
local tTemp = INIPlus.Read(sINIPlusFile, "INIPlus.SetValueData");
local tData = tTemp[1];
local tIndexedData = tTemp[2];
local tNewData = {};
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if String.Replace(sSection, " ", "", false) ~= "" then
	if String.Replace(sValue, " ", "", false) ~= "" then
		if tData then
			local nSectionIndex = nil;
			local nValueIndex = nil;
-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
			if not INIPlus.SectionExists(sINIPlusFile, sSection) then
			nSectionIndex = #tIndexedData + 1;
			
			tIndexedData[nSectionIndex] = {};
			tIndexedData[nSectionIndex].ID = nSectionIndex;
			tIndexedData[nSectionIndex].Name = sSection;
			tIndexedData[nSectionIndex].Attribute = "";
			tIndexedData[nSectionIndex].Values = {};
			elseif INIPlus.SectionExists(sINIPlusFile, sSection) then
			nSectionIndex = tData[sSection].ID;
			end


			if not INIPlus.ValueExists(sINIPlusFile, sSection, sValue) then
			nValueIndex = #tIndexedData[nSectionIndex].Values + 1;
			
			tIndexedData[nSectionIndex].Values[nValueIndex] = {};
			tIndexedData[nSectionIndex].Values[nValueIndex].ID = nValueIndex;
			tIndexedData[nSectionIndex].Values[nValueIndex].Name = sValue;
			tIndexedData[nSectionIndex].Values[nValueIndex].Attribute = "";
			tIndexedData[nSectionIndex].Values[nValueIndex].Data = sData;
			elseif INIPlus.ValueExists(sINIPlusFile, sSection, sValue) then
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



--===================
-- INIPlus.SetValueAttributeAndData
--===================
function INIPlus.SetValueAttributeAndData(...)
AAA.CheckNumArgs(arg,5);
local sINIPlusFile = AAA.CheckTypes(arg,1,{"string"});
local sSection = AAA.CheckTypes(arg,2,{"string"});
local sValue = AAA.CheckTypes(arg,3,{"string"});
local sAttribute = AAA.CheckTypes(arg,4,{"string"});
local sData = AAA.CheckTypes(arg,5,{"string"});
local tTemp = INIPlus.Read(sINIPlusFile, "INIPlus.SetValueAttributeAndData");
local tData = tTemp[1];
local tIndexedData = tTemp[2];
local tNewData = {};
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if String.Replace(sSection, " ", "", false) ~= "" then
	if String.Replace(sValue, " ", "", false) ~= "" then
		if tData then
		local nSectionIndex = nil;
		local nValueIndex = nil;
-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
			if not INIPlus.SectionExists(sINIPlusFile, sSection) then
			nSectionIndex = #tIndexedData + 1;
			
			tIndexedData[nSectionIndex] = {
				ID = nSectionIndex,
				Name = sSection,
				Attribute = "",
				Values = {},
			};
			elseif INIPlus.SectionExists(sINIPlusFile, sSection) then
			nSectionIndex = tData[sSection].ID;
			end
			
			
			if not INIPlus.ValueExists(sINIPlusFile, sSection, sValue) then
			nValueIndex = #tIndexedData[nSectionIndex].Values + 1;
			
			tIndexedData[nSectionIndex].Values[nValueIndex] = {};
			tIndexedData[nSectionIndex].Values[nValueIndex].ID = nValueIndex;
			tIndexedData[nSectionIndex].Values[nValueIndex].Name = sValue;
			tIndexedData[nSectionIndex].Values[nValueIndex].Attribute = sAttribute;
			tIndexedData[nSectionIndex].Values[nValueIndex].Data = sData;
			elseif INIPlus.ValueExists(sINIPlusFile, sSection, sValue) then
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



--==============
-- INIPlus.ShowErrors
--==============
function INIPlus.ShowErrors(...)
AAA.CheckNumArgs(arg,1);
local bShowErrors = AAA.CheckTypes(arg,1,{"boolean"});
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if bShowErrors == true then
INIPLUS_ERRORS_ON = true;
elseif bShowErrors == false then
INIPLUS_ERRORS_ON = false;
end
end



--==============
-- INIPlus.ValueExists
--==============
function INIPlus.ValueExists(...)
AAA.CheckNumArgs(arg,3);
local sINIPlusFile = AAA.CheckTypes(arg,1,{"string"});
local sSection = AAA.CheckTypes(arg,2,{"string"});
local sValue = AAA.CheckTypes(arg,3,{"string"});
local tData = INIPlus.Read(sINIPlusFile, "INIPlus.ValueExists")[1];
local bRet = nil;
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	if INIPlus.SectionExists(sINIPlusFile ,sSection) then
		if tData then
		--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
			
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
	--INIPlus.DisplayError("The section \""..sSection.."\" in file \""..sINIPlusFile.."\" does not exist.", "INIPlus.ValueExists");
	end
	
return bRet
end