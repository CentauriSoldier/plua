--[[########################################################################
#	 																	| Help |																								#
#  											 | Concept and Code By Centauri Soldier |																	#
#													  |||>>>|| VERSION 0.2 ||<<<|||																		#
#													  																															#
#		This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.							#
#		To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/											#
#		or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.		#
#########################################################################]]
require "AAA";

Help = {};
local tTopics = {};
local tDefault = {
	Categories = {},
	Children = {},			
	Desc = "",	
	ImageData = "",
	ImagePath = "",
	Keywords = {},
	Parent = "",
};


--Assumes that the topic exists
local function ConfigureNewParent(sTopic, sParent)
		
	if string.gsub(sParent, " ", "") ~= "" then

		if not tTopics[sParent] then
		CloneDefaultTable(tTopics[sParent]);
		tTopics[sParent].Children[1] = sTopic;
				
		else
	
		--check to see if the topic is a child of the parent already
		local bExists = false;
		
			for nIndex, sChild in pairs(tTopics[sParent].Children) do
				
				if sChild == sTopic then
				bExists = true;
				break;
				end
				
			end
			
			--if it's not, make it one
			if not bExists then
			tTopics[sParent].Children[#tTopics[sParent].Children + 1] = sTopic;
			end
			
		end
		
	end

end


--assumes that the input is a table
local function CloneDefaultTable(tTargetTable)
	
	for sIndex, vVal in pairs(tDefault) do
	tTargetTable[sIndex] = vVal;
	end

end


--assumes the values input are correct types
local function ProcessValue(tTable, sIndex, vValue)
local sDefaultType = type(tDefault[sIndex]);
local sValueType = type(vValue);
local sDefaultValue = true;
	
	--return the imagedata directly if it exists
	if sIndex == "ImageData" then
		
		if sValueType == "userdata" then		
		tTable[sIndex] = vValue;
		return true
		end
	
	tTable[sIndex] = "";
	return true
	end
	
	--get the default value
	if sDefaultType == "boolean" then
	sDefaultValue = false;
	
	elseif sDefaultType == "number" then
	sDefaultValue = -1;
		
	elseif sDefaultType == "string" then
	sDefaultValue = "";
	
	elseif sDefaultType == "table" then
	sDefaultValue = {};	
	
	end
		
	--process the input
	if sValueType ~= sDefaultType then
	tTable[sIndex] =  sDefaultValue;
	return true
	
	else
		
		if sValueType == "string" then
			
			if string.gsub(vValue, " ", "") == "" then
			tTable[sIndex] = sDefaultValue;
			return true
			
			else
			tTable[sIndex] = vValue;
			return true
			
			end
					
		elseif sValueType == "table" then
		local tRet = {};
		
			for nIndex, sValue in pairs(vValue) do	
				
				if type(sValue) == "string" then
				tRet[#tRet + 1] = sValue;
				end
				
			end
			
		tTable[sIndex] =  tRet;
		return true
		
		else
		tTable[sIndex] = vValue;
		return true
		
		end	
	
	end

return false
end


function Help.Test()
Help.AddTopic("Test", "", "This is a topic.");
Help.AddTopic("Sub Topic" ,"Test", "This is a sub-topic.");
Help.Export("exported.lua");
end

function Help.Test2()
Help.Import("exported.lua");
Help.Export("exported2.lua");
end
-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

function Help.AddTopic(...)
AAA.CheckNumArgs(arg, 1);
local sTopic = AAA.CheckTypes(arg,1,{"string"});
local sParent = AAA.CheckTypes(arg,2,{"string","nil"});
local sDesc = AAA.CheckTypes(arg,3,{"string","nil"});
local tCategories = AAA.CheckTypes(arg,4,{"table","nil"});
local tKeywords = AAA.CheckTypes(arg,5,{"table","nil"});
local tChildren = AAA.CheckTypes(arg,6,{"table","nil"});
local sImagePath = AAA.CheckTypes(arg,7,{"string","nil"});
local uImageData = AAA.CheckTypes(arg,8,{"userdata","nil"});


	
	if not tTopics[sTopic] then
	tTopics[sTopic] = {};
	CloneDefaultTable(tTopics[sTopic]);
		
		ProcessValue(tTopics[sTopic], "Parent", sParent);
		ProcessValue(tTopics[sTopic], "Desc", sDesc);
		ProcessValue(tTopics[sTopic], "Categories", tCategories);
		ProcessValue(tTopics[sTopic], "Keywords", tKeywords);
		ProcessValue(tTopics[sTopic], "Children", tChildren);
		ProcessValue(tTopics[sTopic], "ImagePath", sImagePath);
		ProcessValue(tTopics[sTopic], "ImageData", uImageData);
		
		
				
		--[[
		--categories
		if type(tCategories) == "table" then
			
			for nIndex, sCategory in pairs(tCategories) do
				
				if type(sCategory) == "string" then
				tTopics[sTopic].Categories[#tTopics[sTopic].Categories + 1] = sCategory;
				end
				
			end
		
		end
		
		--children
		if type(tChildren) == "table" then
			
			for nIndex, sChild in pairs(tChildren) do
				
				if type(sChild) == "string" then
				tTopics[sTopic].Children[#tTopics[sTopic].Children + 1] = sChild;
				end
				
			end
		
		end
		
		--description
		if type(sDesc) == "string" then
		tTopics[sTopic].Desc = sDesc;
		end
		
		--imagepath
		if type(sImagePath) == "string" then
		tTopics[sTopic].ImagePath = sImagePath;
		end
		
		--imagedata
		if type(uImageData) == "userdata" then
		tTopics[sTopic].ImageData = uImageData;
		end
		
		--keywords
		if type(tKeywords) == "table" then
			
			for nIndex, sKeyword in pairs(tKeywords) do
				
				if type(sKeyword) == "string" then
				tTopics[sTopic].Keyword[#tTopics[sTopic].Keyword + 1] = sKeyword;
				end
				
			end
		
		end
		
		--parent
		if not type(sParent) == "string" then
		sParent = "";
		end
		
		if string.gsub(sParent, " ", "") == "" then
		sParent = "";		
		end
		
		tTopics[sTopic].Parent = sParent;
		]]
		--if the parent table doesn't exist then create that too
		ConfigureNewParent(sTopic, tTopics[sTopic].Parent);

	end

end



function Help.Export(...)
AAA.CheckNumArgs(arg, 1);
local pFile = AAA.CheckTypes(arg,1,{"string"});
local bOk, hFile = pcall(io.open, pFile, "wb");
	
	if bOk and hFile then
	local sContents = "local tHelp = "..table.tostring(tTopics, 0).."\r\n\r\nreturn tHelp";
	hFile:write(sContents);
	hFile:close();
	return true
	end
	
return false
end



function Help.GetChildren(...)
AAA.CheckNumArgs(arg, 1);
local sTopic = AAA.CheckTypes(arg,1,{"string"});

	if tTopics[sTopic] then
	return tTopics[sTopic].Children
	end	
	
return {}
end



function Help.GetDesc(sTopic)

	if tTopics[sTopic] then
	return tTopics[sTopic].Desc
	end

return ""
end



function Help.GetCategories(sTopic)

	if tTopics[sTopic] then
	return tTopics[sTopic].Categories
	end

return {}
end



function Help.GetChildCount(...)
AAA.CheckNumArgs(arg, 1);
local sTopic = AAA.CheckTypes(arg,1,{"string"});

	if tTopics[sTopic] then
	return #tTopics[sTopic].Children
	end

return -1
end



function Help.GetImageData(sTopic)
local sRet = "";

	if tTopics[sTopic] then
	return tTopics[sTopic].ImageData
	end

return sRet
end



function Help.GetImagePath(sTopic)
local sRet = "";

	if tTopics[sTopic] then
	return tTopics[sTopic].ImagePath
	end

return sRet
end



function Help.GetKeywords(sTopic)

	if tTopics[sTopic] then
	return tTopics[sTopic].Keywords
	end

return {}
end



function Help.GetParent(sTopic)

	if tTopics[sTopic] then
	return tTopics[sTopic].Parent
	end

return ""
end



function Help.GetTopicCount()
return #tTopics
end



function Help.GetTopicNames()
local tNames
	
	for nIndex, sTopic in pairs(tTopics) do
	tNames[#tNames + 1] = sTopic;
	end
	
	if type(tNames) == "table" then
	table.sort(tNames, true);
	end
	
return tNames
end



function Help.GetTopics()
return tTopics
end



function Help.Import(...)
AAA.CheckNumArgs(arg, 1);
local pFile = AAA.CheckTypes(arg,1,{"string"});
local bImportExisting = AAA.CheckTypes(arg,2,{"boolean","nil"});
local bMerge = AAA.CheckTypes(arg,3,{"boolean","nil"});

local bOk, hFile = pcall(io.open, pFile, "rb");
	
	if bOk and hFile then
	sContents = hFile:read("*all");
	hFile:close();
	
		if bOk then
		_HELP_TempTable = -1;
		bOk, fGetTable = pcall(loadstring, "_HELP_TempTable = "..sContents);
			
			if bOk then
				
				if type(fGetTable) == "function" then
				bOk = pcall(fGetTable);
					
					if bOk then
						
						if type(_HELP_TempTable) == "table" then
						
							for sTopic, tTopic in pairs(_HELP_TempTable) do
								
								if type(sTopic) == "string" then
									
									if string.gsub(sTopic, " ", "") ~= "" then
									local bTopicExists = false;
										
										--check if the topic already exists in the main table
										if tTopics[sTopic] then
										bTopicExists = true;
										
										else
										--create the topic if it does not exist
										tTopics[sTopic] = {};
										CloneDefaultTable(tTopics[sTopic]);
										
										end
										
										if (bTopicExists and bImportExisting) or (not bTopicExists) then
										local tMyCategories = {};
										local tChildren = {};
										local tKeywords = {};
										
											--clear the child table if the merge option was not enabled
											if not bMerge then
											tTopics[sTopic].Children = {};
											end
											
											--import categories
											if type(tTopic.Categories) == "table" then
												
												for nIndex, sCategory in pairs(tTopic.Categories) do
													
													if type(sCategory) == "string" then
													tTopics[sTopic].Categories[#tTopics[sTopic].Categories + 1] = sCategory;
													end
													
												end
												
											end
											
											--import children
											if type(tTopic.Children) == "table" then
												
												for nIndex, sChild in pairs(tTopic.Children) do
													
													if type(sChild) == "string" then
													tChildren[#tChildren + 1] = sChild;
													end
													
												end
												
											end
											
											--import description
											if type(tTopic.Desc) == "string" then
											tTopics[sTopic].Desc = tTopic.Desc;
											end
											
											--import image path
											if type(tTopic.ImagePath) == "string" then
											tTopics[sTopic].ImagePath = tTopic.ImagePath;
											end
											
											--import keywords
											if type(tTopic.Keywords) == "table" then
												
												for nIndex, sKeyword in pairs(tTopic.Keywords) do
													
													if type(sKeyword) == "string" then
													tTopics[sTopic].Keywords[#tTopics[sTopic].Keywords + 1] = sKeyword;
													end
													
												end
												
											end
											
											--import parent
											if type(tTopic.Parent) == "string" then	
												
												--check to make sure the parent is or will be in the main topics table
												if tTopics[tTopic.Parent] or _HELP_TempTable[tTopic.Parent] then
												tTopics[sTopic].Parent = tTopic.Parent;
												end
												
											end
										
										--clean the topic table and delete bad references
										Help.Vacuum();
										end
										
									end
									
								end
								
							end
						
						_HELP_TempTable = nil;
						end
						
					end
					
				end
				
			end
		
		end
		
	end
	
return false
end



function Help.SetImageData(...)
AAA.CheckNumArgs(arg, 2);
local sTopic = AAA.CheckTypes(arg,1,{"string"});
local pImageData = AAA.CheckTypes(arg,2,{"userdata"});

	if tTopics[sTopic] then
	tTopics[sTopic].ImageData = pImageData;
	return true
	end

return false
end



function Help.SetImagePath(...)
AAA.CheckNumArgs(arg, 2);
local sTopic = AAA.CheckTypes(arg,1,{"string"});
local pImagePath = AAA.CheckTypes(arg,2,{"string"});

	if tTopics[sTopic] then
	tTopics[sTopic].ImagePath = pImagePath;
	return true
	end

return false
end



function Help.SetParent(...)
AAA.CheckNumArgs(arg, 2);
local sTopic = AAA.CheckTypes(arg,1,{"string"});
local sParent = AAA.CheckTypes(arg,2,{"string","userdata"});

	if tTopics[sTopic] then
		
		if string.gsub(sParent, " ", "") ~= "" then
		local sOldParent = tTopics[sTopic].Parent;
	
			if tTopics[sOldParent] then
			local nIndex = table.find(tTopics[sOldParent].Children, sTopic);
				
				if nIndex then
				table.remove(tTopics[sOldParent].Children, nIndex);
				end
			
			end
						
		tTopics[sTopic].Parent = sParent;
		ConfigureNewParent(sTopic, sParent);
		end
			
	return true
	end

return false
end



function Help.TopicExists(...)
AAA.CheckNumArgs(arg, 1);
local sTopic = AAA.CheckTypes(arg,1,{"string"});

	if tTopics[sTopic] then
	return true
	end

return false
end



--consider auto-tag for links in this function. It could search for keywords, categories etc and create links according to user-defined start and end tags

function Help.Vacuum()
	
	for sTopic, tTopic in pairs(tTopics) do
	local sParent	 = tTopic.Parent;
		
		--check the make sure the parent exists
		if not tTopics[sParent] then
		tTopics[sTopic].Parent = "";
		end
		
		--look through each child entry to make sure the topic exists
		local tValidEntries = {};
		for nIndex, sChild in pairs(tTopics[sTopic].Children) do
			
			if tTopics[sChild] then
			tValidEntries[#tValidEntries+ 1] = sChild;
			end
			
		end
		
		--clear the topic's child table
		tTopics[sTopic].Children = {};
		
		--put all valid children back into the topic's child table
		for nIndex, sChild in pairs(tValidEntries) do
		tTopics[sTopic].Children[#tTopics[sTopic].Children + 1] = sChild;
		end
		
	end

end