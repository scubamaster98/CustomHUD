--vibecoded af :(
if string.lower(RequiredScript) == "lib/network/networkgame" then
	Hooks:PostHook(NetworkGame, "on_peer_added", "peer_chat_messages_on_peer_added", function(self, peer, peer_id)
		if managers.chat then
			managers.chat:feed_system_message(ChatManager.GAME, peer:name() .. " is joining.")
		end
	end)

	Hooks:PreHook(NetworkGame, "on_peer_removed", "peer_chat_messages_on_peer_removed", function(self, peer, peer_id, reason)
		if managers.chat and self._members[peer_id] then
			local name = peer:name()
			local text
			if reason == "left" then
				text = name .. " left."
			elseif reason == "kicked" then
				text = name .. " has been kicked."
			else
				text = name .. " has been lost."
			end
			managers.chat:feed_system_message(ChatManager.GAME, text)
		end
	end)
end

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
			--[[if peer:rank() > 0 then
				managers.hud:post_event("infamous_player_join_stinger")
			end]]
			nick = "(" .. peer:level() .. ") " .. nick
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