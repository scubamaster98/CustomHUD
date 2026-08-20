if RequiredScript == "lib/units/enemies/cop/copdamage" then

	local _on_damage_received_original = CopDamage._on_damage_received

	function CopDamage:_process_kill(data)
		local killer
		local weapon_type
		local weapon_slot

		local attacker = alive(data.attacker_unit) and data.attacker_unit

		if attacker then
			if attacker:in_slot(3) or attacker:in_slot(5) then
				--Teammate
				killer = attacker
			elseif attacker:in_slot(2) then
				--Player
				killer = attacker
			elseif attacker:in_slot(16) then
				--Bot/Joker
				killer = attacker
			elseif attacker:in_slot(12) then
				--Enemy
			elseif attacker:in_slot(25)	then
				--Turret
				local owner = attacker:base()._owner_id
				if owner then 
					killer =  managers.criminals:character_unit_by_peer_id(owner)
				end
			elseif attacker:base().thrower_unit then
				killer = attacker:base():thrower_unit()
			end

			if alive(killer) then
				local is_special = managers.groupai:state():is_enemy_special(self._unit)

				if killer:in_slot(2) then
					managers.hud:increment_teammate_kill_count(HUDManager.PLAYER_PANEL, is_special)
				else
					local crim_data = managers.criminals:character_data_by_unit(killer)
					if crim_data and crim_data.panel_id then
						managers.hud:increment_teammate_kill_count(crim_data.panel_id, is_special)
					end
				end
			end
		end
	end

	function CopDamage:_on_damage_received(data, ...)
		if self._dead then
			self:_process_kill(data)
		end

		return _on_damage_received_original(self, data, ...)
	end
	--Add sync damage checks for non-local bots and players
end

if RequiredScript == "lib/units/equipment/sentry_gun/sentrygunbase" then

	local sync_setup_original = SentryGunBase.sync_setup

	function SentryGunBase:sync_setup(upgrade_lvl, peer_id, ...)
		sync_setup_original(self, upgrade_lvl, peer_id, ...)
		self._owner_id = self._owner_id or peer_id
	end
end

if RequiredScript == "lib/managers/hudmanagerpd2" then

	HUDManager.KILL_COUNTER_PLUGIN = true
	HUDManager.SHOW_BOT_KILLS = true
--i dont like how this looks
	HUDManager.increment_teammate_kill_count = HUDManager.increment_teammate_kill_count or function (self, i, is_special)

	end

	HUDManager.reset_teammate_kill_count = HUDManager.reset_teammate_kill_count or function(self, i)

	end

	HUDManager.increment_teammate_kill_count_detailed = HUDManager.increment_teammate_kill_count_detailed or function(self, i, unit, weapon_type, weapon_slot)

	end
end