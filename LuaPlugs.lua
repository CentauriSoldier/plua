--[[
> Init
> Concept and Code By Centauri Soldier
> http://www.github.com/CentauriSoldier/LuaPlugs
> Version 0.4
>
> This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.
> To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/
> or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
--]]

LuaPlugs = {};
local tLuaPlugs = {
	AutoCallInit = false,
	Libs = {
		[1] = {
			Active = true,
			Name = "Help",
			RequiresLuaExt = true,
		},
		[2] = {
			Active = true,
			Name = "Name",
			RequiresLuaExt = true,
		},
		[3] = {
			Active = true,
			Name = "PCall",
			RequiresLuaExt = true,
		},	
	},
	LuaExtPath = "",
	Path = "",
};


function LuaPlugs.Init(pPath, pLuaExt)
local bRequireLuaExt = false;
--local bLuaExtHasBeenCalled = false;
	
	--set the plugin path
	if type(pPath) == "string" then
	tLuaPlugs.Path = pPath;
	end
	
	--set the luaext path
	if type(pLuaExt) == "string" then
	tLuaPlugs.LuaExtPath = pLuaExt;
	end
	
	for nLib, tLib in pairs(tLuaPlugs.Libs) do
		
		if tLib.Active then
			
			if tLib.RequiresLuaExt then
				
				if not LuaExt then
				local sPath = tLuaPlugs.LuaExtPath;
				require(sPath..".".."LuaExt");
					
					if LuaExt then
					LuaExt.Init(sPath);
										
					else
					error("Could not load LuaExt module. Please check that the  path is correct");
					
					end
					
				bLuaExtHasBeenCalled = true;
				end
				
			end
						
		require(tLuaPlugs.Path..".modules."..tLib.Name);
		end
		
	end

end

if tLuaPlugs.AutoCallInit then
LuaPlugs.Init();
end