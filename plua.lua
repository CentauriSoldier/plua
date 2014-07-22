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

plua = {};
local tplua = {
	autoCallInit = false,
	libs = {
		[1] = {
			active = true,
			name = "help",
			requiresLuax = true,
		},
		[2] = {
			active = true,
			name = "name",
			requiresLuax = true,
		},
		[3] = {
			active = true,
			name = "pcall",
			requiresLuax = true,
		},	
	},
	luaxtPath = "",
	path = "",
};


function plua.init(p_path, p_luax)
local bRequireLuaExt = false;
--local b_luaxHasBeenCalled = false;
	
	--set the plugin path
	if type(p_path) == "string" then
	tplua.path = p_path;
	end
	
	--set the luaext path
	if type(p_luax) == "string" then
	tplua.luaxtPath = p_luax;
	end
	
	for nLib, t_lib in pairs(tplua.libs) do
		
		if t_lib.active then
			
			if t_lib.requiresLuax then
				
				if not luax then
				local s_path = tplua.luaxtPath;
				require(s_path..".".."luax");
					
					if luax then
					luax.Init(s_path);
										
					else
					error("Could not load luax module. Please check that the  path is correct");
					
					end
					
				b_luaxHasBeenCalled = true;
				end
				
			end
						
		require(tplua.path..".modules."..t_lib.name);
		end
		
	end

end

if plua.autoCallInit then
plua.init();
end