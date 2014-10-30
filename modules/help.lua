--[[
> help
> Concept and Code By Centauri Soldier
> http://www.github.com/CentauriSoldier/LuaPlugs
> Version 2.2
>
> This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.
> To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/
> or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
--]]
--require "aaa";

help = {};
local t_topics = {};



--[[
DO NOT MOVE THIS FUNCTION
It must remain above all other functions.
]]
local function getDefaultTable()
return {
	categories = {},
	children = {},
	desc = "",
	imageData = "",
	imagePath = "",
	keywords = {},
	parent = "",
}
end



--Assumes that the topic exists
local function configureNewParent(s_topic, s_parent)

	if string.gsub(s_parent, " ", "") ~= "" then

		if not t_topics[s_parent] then
		t_topics[s_parent] = {};
		cloneDefaultTable(t_topics[s_parent]);
		t_topics[s_parent].children[1] = s_topic;

		else

		--check to see if the topic is a child of the parent already
		local b_exists = false;

			for n_index, s_child in pairs(t_topics[s_parent].Children) do

				if s_child == s_topic then
				b_exists = true;
				break;
				end

			end

			--if it's not, make it one
			if not b_exists then
			t_topics[s_parent].children[#t_topics[s_parent].children + 1] = s_topic;
			end

		end

	end

end



--assumes that the input is a table
local function cloneDefaultTable(t_targetTable)
local t_default = getDefaultTable();

	for s_index, v_val in pairs(t_default) do
	t_targetTable[s_index] = v_val;
	end

end



--assumes the values input are correct types
local function processValue(t_table, s_index, v_value)
local t_default = getDefaultTable();
local s_defaultType = type(t_default[s_index]);
local s_valueType = type(v_value);
local s_defaultValue = true;

	--return the imagedata directly if it exists
	if s_index == "imageData" then

		if s_valueType == "userdata" then
		t_table[s_index] = v_value;
		return true
		end

	t_table[s_index] = "";
	return true
	end

	--get the default value
	if s_defaultType == "boolean" then
	s_defaultValue = false;

	elseif s_defaultType == "number" then
	s_defaultValue = -1;

	elseif s_defaultType == "string" then
	s_defaultValue = "";

	elseif s_defaultType == "table" then
	s_defaultValue = {};

	end

	--process the input
	if s_valueType ~= s_defaultType then
	t_table[s_index] =  s_defaultValue;
	return true

	else

		if s_valueType == "string" then

			if string.gsub(v_value, " ", "") == "" then
			t_table[s_index] = s_defaultValue;
			return true

			else
			t_table[s_index] = v_value;
			return true

			end

		elseif s_valueType == "table" then

			if not t_table[s_index] then
			t_table[s_index] = {};
			end

			for n_index, s_value in pairs(v_value) do

				if type(s_value) == "string" then
				t_table[s_index][n_index] =  s_value;
				end

			end


		return true

		else
		t_table[s_index] = v_value;
		return true

		end

	end

return false
end



--[[
DO NOT MOVE THIS FUNCTION
It must remain below all other local functions.
]]
local function importString(s_input)
_HELP_TempTable = -1;
b_ok, f_getTable = pcall(loadstring, "_HELP_TempTable = "..s_input);

	if b_ok then

		if type(f_getTable) == "function" then
		b_ok = pcall(f_getTable);

			if b_ok then

				if type(_HELP_TempTable) == "table" then

					for s_topic, t_topic in pairs(_HELP_TempTable) do

						if type(s_topic) == "string" then

							if string.gsub(s_topic, " ", "") ~= "" then
							local b_topicExists = false;

								--check if the topic already exists in the main table
								if t_topics[s_topic] then
								b_topicExists = true;

								else
								--create the topic if it does not exist
								t_topics[s_topic] = {};
								cloneDefaultTable(t_topics[s_topic]);

								end

								if (b_topicExists and b_importExisting) or (not b_topicExists) then

									--clear the child table if the merge option was not enabled
									if not b_merge then
									t_topics[s_topic].categories = {};
									t_topics[s_topic].children = {};
									t_topics[s_topic].keywords = {};
									end

									processValue(t_topics[s_topic], "categories", t_topic.categories);
									processValue(t_topics[s_topic], "children", t_topic.children);
									processValue(t_topics[s_topic], "desc", t_topic.desc);
									processValue(t_topics[s_topic], "imagePath", t_topic.imagePath);
									processValue(t_topics[s_topic], "keywords", t_topic.keywords);
									processValue(t_topics[s_topic], "parent", t_topic.parent);

								end

							end

						end

					end

				--memory clean up
				_HELP_TempTable = nil;

				--clean the topic table and delete bad references
				help.vacuum();
				end

			end

		end

	end

end



local function e()
help.addTopic("Test", "", "This is a topic.", {"Test Function","First Items"});
help.addTopic("Sub Topic" ,"Test", "This is a sub-topic.", nil, {"poop","junk","dumb"});
help.export("exported.lua");
end

local function i()
help.importFile("exported.lua");
help.export("exported2.lua");
end
-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

function help.addTopic(...)
aaa.checkNumArgs({...}, 1);
local s_topic = aaa.checkTypes({...},1,{"string"});
local s_parent = aaa.checkTypes({...},2,{"string","nil"});
local s_desc = aaa.checkTypes({...},3,{"string","nil"});
local t_categories = aaa.checkTypes({...},4,{"table","nil"});
local t_keywords = aaa.checkTypes({...},5,{"table","nil"});
local s_imagePath = aaa.checkTypes({...},6,{"string","nil"});
local u_imageData = aaa.checkTypes({...},7,{"userdata","nil"});

	if not t_topics[s_topic] then
	t_topics[s_topic] = {};
	cloneDefaultTable(t_topics[s_topic]);

		processValue(t_topics[s_topic], "parent", s_parent);
		processValue(t_topics[s_topic], "Desc", s_desc);
		processValue(t_topics[s_topic], "Categories", t_categories);
		processValue(t_topics[s_topic], "Keywords", t_keywords);
		processValue(t_topics[s_topic], "ImagePath", s_imagePath);
		processValue(t_topics[s_topic], "ImageData", u_imageData);

		--if the parent table doesn't exist then create that too
		configureNewParent(s_topic, s_parent);

	end

end



function help.export(...)
aaa.checkNumArgs({...}, 1);
local p_file = aaa.checkTypes({...},1,{"string"});
local b_ok, h_file = pcall(io.open, p_file, "wb");

	if b_ok and h_file then
	h_file:write(table.tostring(t_topics, 0));
	h_file:close();
	return true
	end

return false
end



function help.getDesc(s_topic)

	if t_topics[s_topic] then
	return t_topics[s_topic].desc
	end

return ""
end



function help.getCategories(s_topic)

	if t_topics[s_topic] then
	return t_topics[s_topic].categories
	end

return {}
end



function help.getCategoryCount(s_topic)

	if t_topics[s_topic] then
	return #t_topics[s_topic].categories
	end

return {}
end



function help.GetChildren(...)
aaa.checkNumArgs({...}, 1);
local s_topic = aaa.checkTypes({...},1,{"string"});

	if t_topics[s_topic] then
	return t_topics[s_topic].children
	end

return -1
end



function help.getChildCount(...)
aaa.checkNumArgs({...}, 1);
local s_topic = aaa.checkTypes({...},1,{"string"});

	if t_topics[s_topic] then
	return #t_topics[s_topic].children
	end

return -1
end



function help.getImageData(s_topic)
local s_ret = "";

	if t_topics[s_topic] then
	return t_topics[s_topic].imageData
	end

return s_ret
end



function help.getImagePath(s_topic)
local s_ret = "";

	if t_topics[s_topic] then
	return t_topics[s_topic].imagePath
	end

return s_ret
end



function help.getKeywords(s_topic)

	if t_topics[s_topic] then
	return t_topics[s_topic].keywords
	end

return {}
end



function help.getParent(s_topic)

	if t_topics[s_topic] then
	return t_topics[s_topic].parent
	end

return ""
end



function help.getTopicCount()
return #t_topics
end



function help.getTopicNames()
local t_names

	for n_index, s_topic in pairs(t_topics) do
	t_names[#t_names + 1] = s_topic;
	end

	if type(t_names) == "table" then
	table.sort(t_names, true);
	end

return t_names
end



function help.getTopics()
return t_topics
end



function help.importFile(...)
aaa.checkNumArgs({...}, 1);
local p_file = aaa.checkTypes({...},1,{"string"});
local b_importExisting = aaa.checkTypes({...},2,{"boolean","nil"});
local b_merge = aaa.checkTypes({...},3,{"boolean","nil"});

local b_ok, h_file = pcall(io.open, p_file, "rb");

	if b_ok and h_file then
	s_contents = h_file:read("*all");
	h_file:close();

		if b_ok then
		return importString(s_contents, b_importExisting, b_merge);
		end

	end

return false
end



function help.importString()
aaa.checkNumArgs({...}, 1);
local sString = aaa.checkTypes({...},1,{"string"});
local b_importExisting = aaa.checkTypes({...},2,{"boolean","nil"});
local b_merge = aaa.checkTypes({...},3,{"boolean","nil"});
return importString(sString, b_importExisting, b_merge);
end



function help.importTable(...)
aaa.checkNumArgs({...}, 1);
local t_table = aaa.checkTypes({...},1,{"table"});
local b_importExisting = aaa.checkTypes({...},2,{"boolean","nil"});
local b_merge = aaa.checkTypes({...},3,{"boolean","nil"});
return importString(table.tostring(t_table, 0), b_importExisting, b_merge);
end



function help.setCategories(...)
aaa.checkNumArgs({...}, 2);
local s_topic = aaa.checkTypes({...},1,{"string"});
local t_categories = aaa.checkTypes({...},2,{"table"});

	if t_topics[s_topic] then
	t_topics[s_topic].Categories = {};

		for n_index, s_category in pairs(t_categories) do
		t_topics[s_topic].categories[#t_topics[s_topic].categories + 1] = s_category;
		end

	return true
	end

return false
end



function help.setImageData(...)
aaa.checkNumArgs({...}, 2);
local s_topic = aaa.checkTypes({...},1,{"string"});
local p_imageData = aaa.checkTypes({...},2,{"userdata"});

	if t_topics[s_topic] then
	t_topics[s_topic].imageData = p_imageData;
	return true
	end

return false
end



function help.setImagePath(...)
aaa.checkNumArgs({...}, 2);
local s_topic = aaa.checkTypes({...},1,{"string"});
local pImagePath = aaa.checkTypes({...},2,{"string"});

	if t_topics[s_topic] then
	t_topics[s_topic].ImagePath = pImagePath;
	return true
	end

return false
end



function help.setKeywords(...)
aaa.checkNumArgs({...}, 2);
local s_topic = aaa.checkTypes({...},1,{"string"});
local t_keywords = aaa.checkTypes({...},2,{"table"});

	if t_topics[s_topic] then
	t_topics[s_topic].Keywords = {};

		for n_index, sKeyword in pairs(t_keywords) do
		t_topics[s_topic].Keywords[#t_topics[s_topic].Keywords + 1] = sKeyword;
		end

	return true
	end

return false
end



function help.setParent(...)
aaa.checkNumArgs({...}, 2);
local s_topic = aaa.checkTypes({...},1,{"string"});
local s_parent = aaa.checkTypes({...},2,{"string","userdata"});

	if t_topics[s_topic] then

		if string.gsub(s_parent, " ", "") ~= "" then
		local sOldParent = t_topics[s_topic].parent;

			if t_topics[sOldParent] then
			local n_index = table.find(t_topics[sOldParent].Children, s_topic);

				if n_index then
				table.remove(t_topics[sOldParent].Children, n_index);
				end

			end

		t_topics[s_topic].parent = s_parent;
		configureNewParent(s_topic, s_parent);
		end

	return true
	end

return false
end



function help.topicExists(...)
aaa.checkNumArgs({...}, 1);
local s_topic = aaa.checkTypes({...},1,{"string"});

	if t_topics[s_topic] then
	return true
	end

return false
end



function help.vacuum()

	for s_topic, t_topic in pairs(t_topics) do
	local s_parent	 = t_topic.parent;

		--check the make sure the parent exists
		if not t_topics[s_parent] then
		t_topics[s_topic].parent = "";
		end

		--look through each child entry to make sure the topic exists
		local tValidEntries = {};
		for n_index, s_child in pairs(t_topics[s_topic].Children) do

			if t_topics[s_child] and s_child ~= s_topic then
			tValidEntries[#tValidEntries + 1] = s_child;
			end

		end

		--clear the topic's child table
		t_topics[s_topic].Children = {};

		--put all valid children back into the topic's child table
		for n_index, s_child in pairs(tValidEntries) do
		t_topics[s_topic].Children[#t_topics[s_topic].Children + 1] = s_child;
		end

	end

end