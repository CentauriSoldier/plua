--[[########################################################################
#	 																	| Init |																				#
#  											 | Concept and Code By Centauri Soldier |															#
#  									  | http://www.github.com/CentauriSoldier/LuaPlugs |													#
#													  |||>>>|| VERSION 0.4 ||<<<|||																#
#													  																											#
#		This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.								#
#		To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/											#
#		or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.			#
#########################################################################]]

LuaPlugs = {};
local tLuaPlugs = {
	Libs = {
		[1] = {
			Active = true,
			Name = "Help",
			RequiresLuaExt = true,
		},
	},
	LuaExtPath = "luaext",
	Path = "",
};


function LuaPlugs.Init()
local bRequireLuaExt = false;
local bLuaExtHasBeenCalled = false;

	for nLib, tLib in pairs(tLuaPlugs.Libs) do
		
		if tLib.Active then
			
			if tLib.RequiresLuaExt then
				
				if not bLuaExtHasBeenCalled then
				local sPath = tLuaPlugs.Path.."."..tLuaPlugs.LuaExtPath;
				require(sPath..".".."LuaExt");
					
					if LuaExt then
					LuaExt.Init(sPath);
										
					else
					error("Could not load LuaExt module. Please check that the  path is correct");
					
					end
					
				bLuaExtHasBeenCalled = true;
				end
				
			end
			
		require(tLuaPlugs.Path.."."..tLib.Name);
		end
		
	end

end

LuaPlugs.Init();