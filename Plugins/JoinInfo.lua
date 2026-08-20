--ty wolfhud
if string.lower(RequiredScript) == "lib/managers/menumanagerdialogs" then
	local show_person_joining_original = MenuManager.show_person_joining
	local update_person_joining_original = MenuManager.update_person_joining
	local close_person_joining_original = MenuManager.close_person_joining

	function MenuManager:show_person_joining( id, nick, ... )
		self.peer_join_start_t = self.peer_join_start_t or {}
		self.peer_join_start_t[id] = os.clock()
		local peer = managers.network:session():peer(id)
		if peer then
			if peer:rank() > 0 then
				managers.hud:post_event("infamous_player_join_stinger")
			end
			nick = "(" .. (peer:rank() > 0 and managers.experience:rank_string(peer:rank()) .. "-" or "") .. peer:level() .. ") " .. nick
		end
		return show_person_joining_original(self, id, nick, ...)
	end

	function MenuManager:update_person_joining( id, progress_percentage, ... )
		if self.peer_join_start_t and self.peer_join_start_t[id] then
			local t = os.clock() - self.peer_join_start_t[id]
			local result = update_person_joining_original(self, id, progress_percentage, ...)
			local time_left = (t / progress_percentage) * (100 - progress_percentage)
			local dialog = managers.system_menu:get_dialog("user_dropin" .. id)
			if dialog and time_left then
				dialog:set_text(managers.localization:text("dialog_wait") .. string.format(" %d%% (%0.2fs)", progress_percentage, time_left))
			end
		end
	end

	function MenuManager:close_person_joining(id, ...)
		if self.peer_join_start_t then
			self.peer_join_start_t[id] = nil
		end
		close_person_joining_original(self, id, ...)
	end
end