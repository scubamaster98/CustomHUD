--ty wolfhud
if not CustomHUDMenu.settings.interaction.enable_interaction then return end
if string.lower(RequiredScript) == "lib/managers/hudmanagerpd2" then

	function HUDManager:set_interaction_bar_locked(status)
		self._hud_interaction:set_locked(status)
	end

elseif string.lower(RequiredScript) == "lib/managers/hud/hudinteraction" then

	local init_original                      = HUDInteraction.init
	local show_interaction_bar_original      = HUDInteraction.show_interaction_bar
	local hide_interaction_bar_original      = HUDInteraction.hide_interaction_bar
	local set_interaction_bar_width_original = HUDInteraction.set_interaction_bar_width
	local destroy_original                   = HUDInteraction.destroy

	function HUDInteraction:init(...)
		init_original(self, ...)

		local interact_text = self._hud_panel:child(self._child_name_text)
		local invalid_text  = self._hud_panel:child(self._child_ivalid_name_text)
		self._original_circle_radius = self._circle_radius
		self._original_interact_text_font_size = interact_text:font_size()
		self._original_invalid_text_font_size  = invalid_text:font_size()

		self:_rescale()
	end

	function HUDInteraction:set_interaction_bar_width(current, total)
		set_interaction_bar_width_original(self, current, total)

		if self._interact_time then
			local perc  = current / total
			local color = math.lerp(Color(0, 1, 0), Color(1, 0, 0), perc)
			self._interact_time:set_text(string.format("%.1fs", math.max(total - current, 0)))
			self._interact_time:set_color(color)
			self._interact_time:set_alpha(1)
			self._interact_time:set_visible(perc < 1)
		end
	end

	function HUDInteraction:show_interaction_bar(current, total)
		self:_rescale()
		if self._interact_circle_locked then
			self._interact_circle_locked:remove()
			self._interact_circle_locked = nil
		end

		local val = show_interaction_bar_original(self, current, total)

		if not self._interact_time then
			self._interact_time = self._hud_panel:text({
				name      = "interaction_timer",
				visible   = false,
				text      = "",
				valign    = "center",
				align     = "center",
				layer     = 1,
				color     = Color(0, 1, 0), --change to color.white?
				font      = tweak_data.menu.default_font,
				font_size = 32 * (self._circle_scale or 1),
				h         = 64,
			})
		else
			self._interact_time:set_font_size(32 * (self._circle_scale or 1))
		end

		self._interact_time:set_y(self._hud_panel:center_y() + self._circle_radius - (2 * self._interact_time:font_size()))
		self._interact_time:show()
		self._interact_time:set_text(string.format("%.1fs", total))

		return val
	end

	function HUDInteraction:hide_interaction_bar(complete, ...)		
		if self._interact_circle_locked then
			self._interact_circle_locked:remove()
			self._interact_circle_locked = nil
		end
		
		if self._interact_time then
			self._interact_time:set_text("")
			self._interact_time:set_visible(false)
		end

		return hide_interaction_bar_original(self, false, ...)
	end

	function HUDInteraction:destroy()
		if self._interact_time and self._hud_panel then
			self._hud_panel:remove(self._interact_time)
			self._interact_time = nil
		end
		destroy_original(self)
	end

	function HUDInteraction:_rescale()
		local circle_scale = CustomHUDMenu.settings.interaction.circle_scale
		local text_scale = CustomHUDMenu.settings.interaction.text_scale
		local interact_text = self._hud_panel:child(self._child_name_text)
		local invalid_text  = self._hud_panel:child(self._child_ivalid_name_text)
		local changed = false
		if self._circle_scale ~= circle_scale then
			self._circle_radius = self._original_circle_radius * circle_scale
			self._circle_scale  = circle_scale
			changed = true
		end
		if self._text_scale ~= text_scale then
		local interact_text = self._hud_panel:child(self._child_name_text)
		local invalid_text  = self._hud_panel:child(self._child_ivalid_name_text)
			interact_text:set_font_size(self._original_interact_text_font_size * text_scale)
			invalid_text:set_font_size(self._original_invalid_text_font_size  * text_scale)
			self._text_scale = text_scale
			changed = true
		end
		if changed then
			interact_text:set_y(self._hud_panel:h() / 2 + self._circle_radius + interact_text:font_size() / 2)
			invalid_text:set_center_y(interact_text:center_y())
		end
	end
end