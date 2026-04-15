if Network:is_server() and Utils:IsInGameState() and not Utils:IsInHeist() then
	local Is_Synched = true
	for _, peer in pairs(managers.network:session():peers()) do
		if not peer:synched() then
			local name = peer:name()
			Is_Synched = false
		end
	end

	if Is_Synched then
		game_state_machine:current_state():start_game_intro()
	end
end