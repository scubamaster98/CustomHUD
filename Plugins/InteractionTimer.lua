local init_original = HUDInteraction.init
local show_interaction_bar_original = HUDInteraction.show_interaction_bar
local set_interaction_bar_width_original = HUDInteraction.set_interaction_bar_width
local hide_interaction_bar_original = HUDInteraction.hide_interaction_bar
local destroy_original = HUDInteraction.destroy

local OUTLINE_OFFSET = 1

function HUDInteraction:init(hud, child_name)
	init_original(self, hud, child_name)

	self._interact_timer_outlines = {}
	local offsets = {{OUTLINE_OFFSET, 0}, {-OUTLINE_OFFSET, 0}, {0, OUTLINE_OFFSET}, {0, -OUTLINE_OFFSET}}
	for i, offset in ipairs(offsets) do
		local outline = self._hud_panel:text({
			name = "interact_timer_outline_" .. i,
			visible = false,
			text = "",
			valign = "center",
			align = "center",
			layer = 1,
			color = Color(1, 0, 0, 0),
			font = tweak_data.menu.pd2_large_font,
			font_size = tweak_data.hud_present.text_size + 2,
			h = 64
		})
		outline:set_y(self._hud_panel:h() / 2 + offset[2])
		outline:set_x(outline:x() + offset[1])
		table.insert(self._interact_timer_outlines, outline)
	end

	self._interact_timer_text = self._hud_panel:text({
		name = "interact_timer_text",
		visible = false,
		text = "",
		valign = "center",
		align = "center",
		layer = 2,
		color = Color(1, 0, 1, 0),
		font = tweak_data.menu.pd2_large_font,
		font_size = tweak_data.hud_present.text_size + 2,
		h = 64
	})
	self._interact_timer_text:set_y(self._hud_panel:h() / 2)
end

function HUDInteraction:show_interaction_bar(current, total)
	show_interaction_bar_original(self, current, total)
	self._interact_timer_text:set_visible(true)
	for _, outline in ipairs(self._interact_timer_outlines) do
		outline:set_visible(true)
	end
end

function HUDInteraction:set_interaction_bar_width(current, total)
	set_interaction_bar_width_original(self, current, total)
	if not self._interact_timer_text then
		return
	end
	local text = string.format("%.1f", total - current >= 0 and total - current or 0)
	self._interact_timer_text:set_text(text)
	for _, outline in ipairs(self._interact_timer_outlines) do
		outline:set_text(text)
	end

	local perc = current / total
	local color_start = Color(1, 0, 1, 0)
	local color_end = Color(1, 1, 0, 0)
	self._interact_timer_text:set_color(math.lerp(color_start, color_end, perc))
end

function HUDInteraction:hide_interaction_bar(complete)
	hide_interaction_bar_original(self, complete)
	self._interact_timer_text:set_visible(false)
	for _, outline in ipairs(self._interact_timer_outlines) do
		outline:set_visible(false)
	end
end

function HUDInteraction:destroy()
	self._hud_panel:remove(self._hud_panel:child("interact_timer_text"))
	for i = 1, 4 do
		self._hud_panel:remove(self._hud_panel:child("interact_timer_outline_" .. i))
	end
	destroy_original(self)
end