local THRESHOLD = 0.25 --Double-tap threshold (in seconds)
local STEALTH_ONLY = true --Use only during stealth

local _check_action_throw_grenade_original = PlayerStandard._check_action_throw_grenade

function PlayerStandard:_check_action_throw_grenade(t, input, ...)
	if input.btn_throw_grenade_press then
		if (not STEALTH_ONLY or managers.groupai:state():whisper_mode()) and (t - (self._last_grenade_t or 0) >= THRESHOLD) then
			self._last_grenade_t = t
			return
		end
	end

	return _check_action_throw_grenade_original(self, t, input, ...)
end