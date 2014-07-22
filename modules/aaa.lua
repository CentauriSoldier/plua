--[[
> automated argument assessment 
> Original Concept By MicroByte for AutoPlay Media Studio
> Revised and Maintained for Lua by Centauri Soldier
> Concept and Code By Centauri Soldier
> http://www.github.com/CentauriSoldier/LuaPlugs
> Version 3.2
>
> This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.
> To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/
> or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
--]]
aaa = {};
local t_errors = {};



--[[************===***********->
		aaa.setGlobalErrorMessage
<-**************===*********<<
Sets a global error message in the runtime engine.
]]
function aaa.setGlobalErrorMessage(n_code, s_message)
t_errors[n_code] = s_message;
end



--[[********===******->
		aaa.checkNumArgs
<-********===********<<
Checks the number of arguments in the table and throws a syntax error if there are not enough. 
This is useful for checking the number of arguments available to your action.
Keep in mind, any arguments that accept nil must not be counted in the number of total arguments
and should be placed after all other function arguments.
]]
function aaa.checkNumArgs(t_args, n_args)
local n_count = table.getn(t_args);

if n_count < n_args then
error(n_args.." Arguments expected, "..n_count.." Arguments passed.",3);
end
	
end



--[[********===******->
		aaa.checkTableVars
<-********===********<<
Ensures that your table contains data of only the specified type. If it does not then false is returned.
This will see nil values as suitable declarations and will, therefore, ignore them.
TODO - MAKE THIS RECURSIVE
]]
function aaa.checkTableVars(t_table,t_varTypes)
local b_ret = true;
local n_types = #t_varTypes;
local n_strikes = 0;

for n_index, s_item in pairs(t_table) do
n_strikes = 0;

	for n_type, s_type in pairs(t_varTypes) do

		if type(s_item) ~= s_type then
		n_strikes = n_strikes + 1;
		end
			
	end
	
	if n_strikes >= n_types then
	b_ret = false;
	break;
	end

end
return b_ret
end



--[[********===******->
		aaa.checkTypes
<-********===********<<
Checks the value at a given argument table position to see if it is any of the specified types,
if Not it throws a syntax error. Possible variable types[boolean, function, nil, number, string,
table, thread, userdata]
]]
function aaa.checkTypes(t_args, n_arg, t_types)
local s_type = type(t_args[n_arg]);
local n_totalTypes = #t_types;
local n_strikes = 0;
local s_allowedTypes = "";

	for n_index, s_allowedType in pairs(t_types) do
		
		if n_index < (n_totalTypes - 1) then
		s_allowedTypes = s_allowedTypes.." "..s_allowedType..",";
		
		elseif n_index == n_totalTypes - 1 then
		s_allowedTypes = s_allowedTypes.." "..s_allowedType;
		
		elseif n_index == n_totalTypes then
		
			if n_totalTypes == 1 then
			s_allowedTypes = " "..s_allowedType;
			else
		
			s_allowedTypes = s_allowedTypes.." or "..s_allowedType;
			end
			
		end
		
		if s_type ~= string.lower(s_allowedType) then
		n_strikes = n_strikes + 1;
		end
		
	end

	if n_strikes == n_totalTypes then
	error("Bad argument #" .. n_arg .. "."..s_allowedTypes.." expected, got "..s_type..".",3);
	else

	return t_args[n_arg]
	end

end



--[[********===******->
	  aaa.convert
<-********===********<<
Converts certain datatypes into other datatypes
||| Supported Types |||
[String <-> Boolean] [Number <-> Boolean] [String <-> Number]
]]
function aaa.convert(v_input, s_newType)
local s_oldType = type(v_input);

	if s_newType == "boolean" then

		if s_oldType == "string" then

			if string.lower(v_input) == "true" then
			return true
			elseif string.lower(v_input) == "false" then
			return false
			end
			
		elseif s_oldType == "number" then
			
			if v_input == 0 then
			return false
			elseif v_input == 1 then
			return true
			end
		
		elseif s_oldType == "table" then
		
			if v_input then
			return true
			else
			return false
			end
		
		else
		
		return false	
		end

	elseif s_newType == "string"	then
		
		if s_oldType == "boolean" then
		
			if v_input == true then
			return "true"
			elseif v_input == false then
			return "false"
			end
		
		elseif s_oldType == "number" then
		return ""..v_input..""
		
		else
		
		return ""
		end

	elseif s_newType == "number" then
		
		if s_oldType == "boolean" then
		
			if v_input == true then
			return 1
			elseif v_input == false then
			return 0
			end
		
		elseif s_oldType == "string" then
		
		return tonumber(v_input)				
		
		else
		
		return -1
		end

	end
	
end