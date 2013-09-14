--[[########################################################################
#	 												| Automated Argument Assesment |															#
#									| Original Concept By MicroByte for AutoPlay Media Studio |												#
#									   | Revised and Maintained for Lua by Centauri Soldier |													#
#  									 | http://www.github.com/CentauriSoldier/LuaPlugs |													#
#													  |||>>>|| VERSION 3.2 ||<<<|||																#
#													  																											#
#		This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.								#
#		To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/											#
#		or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.			#
#########################################################################]]
AAA = {};
local tErrors = {};



--[[************===***********->
		AAA.SetGlobalErrorMessage
<-**************===*********<<
Sets a global error message in the runtime engine.
]]
function AAA.SetGlobalErrorMessage(nCode, sMessage)
tErrors[nCode] = sMessage;
end



--[[********===******->
		AAA.CheckNumArgs
<-********===********<<
Checks the number of arguments in the table and throws a syntax error if there are not enough. 
This is useful for checking the number of arguments available to your aciton.
Keep in mind, any arguments that accept nil must not be counted in the number of total arguments
and should be placed after all other function arguments.
]]
function AAA.CheckNumArgs(tbArgs, nArgs)
local nCount = table.getn(tbArgs);

if nCount < nArgs then
error(nArgs.." Arguments expected, "..nCount.." Arguments passed.",3);
end
	
end



--[[********===******->
		AAA.CheckTableVars
<-********===********<<
Ensures that your table contains data of only the specified type. If it does not then false is returned.
This will see nil values as subtable declarations and will, therefore, ignore them.
TODO - MAKE THIS RECURSIVE
]]
function AAA.CheckTableVars(tTable,tVarTypes)
local bRet = true;
local nTypes = #tVarTypes;
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



--[[********===******->
		AAA.CheckTypes
<-********===********<<
Checks the value at a given argument table position to see if it is any of the specified types,
if Not it throws a syntax error. Possible variable types[boolean, function, nil, number, string, table, thread, userdata]
]]
function AAA.CheckTypes(tbArgs, nArg, tTypes)
local sType = type(tbArgs[nArg]);
local nTotalTypes = #tTypes;
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
		
		if sType ~= string.lower(sAllowedType) then
		nStrikes = nStrikes + 1;
		end
		
	end

	if nStrikes == nTotalTypes then
	error("Bad argument #" .. nArg .. "."..sAllowedTypes.." expected, got "..sType..".",3);
	else

	return tbArgs[nArg]
	end

end



--[[********===******->
			 AAA.Convert
<-********===********<<
Converts certain datatypes into other datatypes
||| Supported Types |||
[String <-> Boolean] [Number <-> Boolean] [String <-> Number]
]]
function AAA.Convert(vInput, sNewType)
local sOldType = type(vInput);

	if sNewType == "boolean" then

		if sOldType == "string" then

			if string.lower(vInput) == "true" then
			return true
			elseif string.lower(vInput) == "false" then
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