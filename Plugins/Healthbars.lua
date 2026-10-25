local CharacterData = {
	["security"]				= "SECURITY GUARD",
	["gensec"]					= "GENSEC UNIT",
	["cop"]						= "POLICE OFFICER",
	["inside_man"]				= "INSIDE MAN",
	["fbi"]						= "FBI UNIT",
	["swat"]					= "SWAT UNIT",
	["heavy_swat"]				= "HEAVY SWAT",
	["fbi_swat"]				= "FBI SWAT",
	["fbi_heavy_swat"]			= "FBI HEAVY SWAT",
	["city_swat"]				= "CITY SWAT/MURKY",
	["sniper"]					= "SNIPER",
	["gangster"]				= "GANGSTER",
	["biker"]					= "BIKER",
	["biker_escape"]			= "BIKER",
	["mobster"]					= "RUSSIAN MOBSTER",
	["mobster_boss"]			= "THE COMMISSAR",
	["hector_boss"]				= "ARMORED HECTOR",
	["hector_boss_no_armor"]	= "HECTOR",
	["tank"]					= "BULLDOZER",
	["spooc"]					= "CLOAKER",
	["shield"]					= "SHIELD",
	["phalanx_minion"]			= "WINTERS UNIT",
	["phalanx_vip"]				= "CAPTAIN WINTERS",
	["taser"]					= "TASER",
	["civilian"]				= "CIVILIAN",
	["bank_manager"]			= "BANK MANAGER",
	["drunk_pilot"]				= "DRUNK PILOT",
	["escort"]					= "ESCORT",
	["russian"]					= "DALLAS",
	["german"]					= "WOLF",
	["spanish"]					= "CHAINS",
	["american"]				= "HOUSTON",
	["jowi"]					= "JOHN WICK",
	["old_hoxton"]				= "HOXTON",
	["clover"]					= "CLOVER",
	["female_1"]				= "CLOVER",
	["dragan"]					= "DRAGAN",
	["jacket"]					= "JACKET",
	["bonnie"]					= "BONNIE",
	["sokol"]					= "SOKOL",
	["dragon"]					= "JIRO",
	["bodhi"]					= "BODHI",
	["old_hoxton_mission"]		= "HOXTON/LOCKE"
}

if RequiredScript == "lib/managers/hudmanager" then
	Hooks:PostHook(HUDManager, "_player_hud_layout", "customHUDPostHUDManagerPlayerInfoHUDLayout", function(self)

		local unit_health_main = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2).panel:panel({
			name 	= "unit_health_main",
			halign 	= "grow",
			valign 	= "grow"
		})

		self._unit_health_panel = unit_health_main:panel({
			name 	= "unit_health_panel",
			visible = false
		})

		self._unit_health = self._unit_health_panel:bitmap({
			name 			= "unit_health",
			texture 		= "guis/textures/pd2/healthshield",
			texture_rect 	= { 2, 18, 232, 11 },
			blend_mode 		= "normal"
		})

		self._health_text_rect = { 2, 18, 232, 11 }

		self._unit_shield = self._unit_health_panel:bitmap({
			name 			= "unit_shield",
			texture 		= "guis/textures/pd2/healthshield",
			texture_rect 	= { 1, 1, 234, 13 },
			blend_mode 		= "normal"
		})

		self._unit_health_text = self._unit_health_panel:text({
			name 		= "unit_health_text",
			text 		= "250000/250000",
			blend_mode 	= "normal",
			alpha 		= 1,
			halign 		= "right",
			font 		= "fonts/font_medium_shadow_mf",
			font_size 	= 20,
			color 		= Color.white,
			align 		= "center",
			layer 		= 1
		})

		self._unit_health_enemy_text = self._unit_health_panel:text({
			name 		= "unit_health_enemy_text",
			text 		= "SWAT VAN TURRET",
			blend_mode 	= "normal",
			alpha 		= 1,
			halign 		= "left",
			font 		= "fonts/font_medium_shadow_mf",
			font_size 	= 22,
			color 		= Color.white,
			align 		= "center",
			layer 		= 1
		})

		local hx, hy, hw, hh = self._unit_health_text:text_rect()
		local ex, ey, ew, eh = self._unit_health_enemy_text:text_rect()

		self._unit_health_text:set_size(hw, hh)
		self._unit_health_enemy_text:set_size(ew, eh)
		self._unit_health:set_w(self._unit_health:w() - 2)
		self._unit_health:set_center(self._unit_health_panel:center_x(), self._unit_health_panel:center_y() - 190)
		self._unit_shield:set_center(self._unit_health_panel:center_x(), self._unit_health_panel:center_y() - 190)
		self._unit_health_text:set_right(self._unit_shield:right())
		self._unit_health_text:set_bottom(self._unit_shield:top())
		self._unit_health_enemy_text:set_left(self._unit_shield:left())
		self._unit_health_enemy_text:set_bottom(self._unit_shield:top())
	end)

	function HUDManager:set_unit_health_visible(visible)
		if visible == true and not self._unit_health_visible then
			self._unit_health_visible = true
			self._unit_health_panel:stop()
			self._unit_health_panel:animate(function(p)
				self._unit_health_panel:set_visible(true)
				over(0.25, function(o)
					self._unit_health_panel:set_alpha(math.lerp(self._unit_health_panel:alpha(), 1, o))
				end)
			end)

		elseif visible == false and self._unit_health_visible then
			self._unit_health_visible = nil
			self._unit_health_panel:stop()
			self._unit_health_panel:animate(function(p)
				if self._unit_health_panel:alpha() >= 0.9 then
					over(0.3, function(o) end)
				end

				over(0.8, function(o)
					self._unit_health_panel:set_alpha(math.lerp(self._unit_health_panel:alpha(), 0, o))
				end)

				self._unit_health_panel:set_visible(false)
			end)
		end
	end

	function HUDManager:set_unit_health(current, total, tweak_table)
		if not current or not total then return end

		local enemy = CharacterData[tweak_table] or tweak_table

		total = math.min(total, 999999999)
		current = math.clamp(current, 0, total)
		local _r = current / total or 0

		local r = self._unit_health:width()
		local rn = (self._health_text_rect[3] - 2) * _r

		self._unit_health_enemy_text:set_text(enemy)
		self._unit_health_text:set_text(string.format("%d/%d", current * 10, total * 10))

		local hx, hy, hw, hh = self._unit_health_text:text_rect()
		local ex, ey, ew, eh = self._unit_health_enemy_text:text_rect()

		self._unit_health_text:set_size(hw, hh)
		self._unit_health_enemy_text:set_size(ew, eh)
		self._unit_health_text:set_right(self._unit_shield:right())
		self._unit_health_text:set_bottom(self._unit_shield:top())
		self._unit_health_enemy_text:set_left(self._unit_shield:left())
		self._unit_health_enemy_text:set_bottom(self._unit_shield:top())
		self._unit_health_text:set_color(_r <= 0.1 and Color.red or _r <= 0.25 and Color.yellow or Color.white)
		self._unit_health:stop()

		if rn > r then
			self._unit_health:animate(function(p)
				over(0.5, function(o)
					self._unit_health:set_w(math.lerp(r, rn, o))
					self._unit_health:set_texture_rect(self._health_text_rect[1], self._health_text_rect[2], math.lerp(r, rn, o), self._health_text_rect[4])
				end)
			end)
		end

		self._unit_health:set_w(_r * (self._health_text_rect[3] - 2))
		self._unit_health:set_texture_rect(self._health_text_rect[1], self._health_text_rect[2], self._health_text_rect[3] * _r, self._health_text_rect[4])
	end

end

if RequiredScript == "lib/units/beings/player/states/playerstandard" then
	Hooks:PostHook(PlayerStandard, "_update_fwd_ray", "customHUDPostPlayerStandardUpdateFwdRay", function(self)

		if self._fwd_ray and self._fwd_ray.unit then
			local unit = self._fwd_ray.unit

			if unit:in_slot(8) and alive(unit:parent()) then
				unit = unit:parent()
			end

			if alive(unit) and unit:character_damage() and not managers.enemy:is_civilian(unit) and unit:base() and unit:base()._tweak_table and CharacterData[unit:base()._tweak_table] ~= nil then
				if unit:character_damage()._dead then
					managers.hud:set_unit_health(0, unit:character_damage()._HEALTH_INIT or 1, unit:base()._tweak_table or "cop")
					managers.hud:set_unit_health_visible(false)
				else
					managers.hud:set_unit_health_visible(true)
					managers.hud:set_unit_health(unit:character_damage()._health or 0, unit:character_damage()._HEALTH_INIT or 0, unit:base()._tweak_table or "cop")
				end
			else
				managers.hud:set_unit_health_visible(false)
			end
		else
			managers.hud:set_unit_health_visible(false)
		end
	end)
end