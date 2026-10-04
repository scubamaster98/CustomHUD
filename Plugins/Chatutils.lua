Chatutils = Chatutils or {}
Chatutils.LIMIT = 255

local ID_INSERT = Idstring("insert")
local ID_V = Idstring("v")
local ID_A = Idstring("a")
local ID_C = Idstring("c")

local function down(name)
	local kb = Input:keyboard()
	return kb:down(Idstring(name))
end

function Chatutils.ctrl()
	return down("left ctrl") or down("right ctrl")
end

function Chatutils.alt()
	return down("left alt") or down("right alt")
end

function Chatutils.shortcut_down()
	return Chatutils.ctrl() and not Chatutils.alt()
end

function Chatutils.set_clipboard(str)
	return pcall(function()
		Application:set_clipboard(str)
	end)
end

function Chatutils.get_clipboard()
	local ok, res = pcall(function()
		return Application:get_clipboard()
	end)
	if ok and type(res) == "string" then
		return res
	end
	return nil
end

local function input_field(gui)
	return gui._input_text or (gui._input_panel and gui._input_panel:child("input_text"))
end

function Chatutils.room(text)
	local s, e = text:selection()
	return Chatutils.LIMIT - (utf8.len(text:text()) - math.abs(e - s))
end

function Chatutils.filter_text(gui, s)
	if gui._chatutils_builtin or type(s) ~= "string" or s == "" then
		return false
	end
	if #s == 1 and s:byte() < 32 then
		return true
	end
	if Chatutils.shortcut_down() and (s == "v" or s == "V" or s == "a" or s == "A" or s == "c" or s == "C") then
		return true
	end
	local text = input_field(gui)
	return text ~= nil and Chatutils.room(text) < utf8.len(s)
end

function Chatutils.sync_caret(gui)
	if gui._chatutils_builtin or not gui._input_text or not alive(gui._caret) then
		return
	end
	local s, e = gui._input_text:selection()
	if s ~= e then
		if not gui._cp_sel then
			gui._cp_sel = true
			gui._caret:stop()
		end
		gui._caret:set_visible(true)
	elseif gui._cp_sel then
		gui._cp_sel = false
		gui._caret:stop()
		if gui._focus then
			gui._caret:animate(function(o)
				local visible = true
				while true do
					o:set_visible(visible)
					visible = not visible
					wait(0.5)
				end
			end)
		end
	end
end

function Chatutils.handle_key(gui, k)
	if gui._chatutils_builtin then
		return false
	end
	local is_paste = k == ID_INSERT or (k == ID_V and Chatutils.shortcut_down())
	local is_select_all = k == ID_A and Chatutils.shortcut_down()
	local is_copy = k == ID_C and Chatutils.shortcut_down()
	if not is_paste and not is_select_all and not is_copy then
		return false
	end

	local custom = gui._input_text ~= nil
	local text = gui._input_text or gui._input_panel:child("input_text")
	if not text then
		return false
	end

	if not custom and not gui._enter_text_set then
		gui._input_panel:enter_text(callback(gui, gui, "enter_text"))
		gui._enter_text_set = true
	end
	gui._key_pressed = false

	local function refresh()
		if custom and gui._update_input_panel_height then
			gui:_update_input_panel_height()
		end
		local update = custom and gui._update_caret or gui.update_caret or gui._update_caret
		if update then
			update(gui)
		end
	end

	if is_copy then
		local s, e = text:selection()
		if s ~= e then
			Chatutils.set_clipboard(utf8.sub(text:text(), math.min(s, e) + 1, math.max(s, e)))
		end
		return true
	end

	if is_select_all then
		text:set_selection(0, utf8.len(text:text()))
		refresh()
		return true
	end

	local clip = Chatutils.get_clipboard()
	if not clip or clip == "" then
		return true
	end
	clip = clip:gsub("%c+", " ")
	local room = Chatutils.room(text)
	if room <= 0 then
		return true
	end
	if utf8.len(clip) > room then
		clip = utf8.sub(clip, 1, room)
	end

	if gui._typing_callback and type(gui._typing_callback) ~= "number" then
		gui._typing_callback()
	end
	text:replace_text(clip)

	if not custom then
		local lbs = text:line_breaks()
		if 1 < #lbs then
			local s = lbs[2]
			local e = utf8.len(text:text())
			text:set_selection(s, e)
			text:replace_text("")
		end
	end
	refresh()
	return true
end

local function wrap(class)
	local orig_key_press = class.key_press
	function class:key_press(o, k)
		if not self._skip_first and Chatutils.handle_key(self, k) then
			return
		end
		return orig_key_press(self, o, k)
	end

	local orig_enter_text = class.enter_text
	function class:enter_text(o, s)
		if not self._skip_first and Chatutils.filter_text(self, s) then
			return
		end
		return orig_enter_text(self, o, s)
	end
end

if RequiredScript == "lib/managers/chatmanager" then
	wrap(ChatGui)
elseif RequiredScript == "lib/managers/hud/hudchat" then
	wrap(HUDChat)

	if HUDChat._update_caret then
		local orig_update_caret = HUDChat._update_caret
		function HUDChat:_update_caret(...)
			local ret = orig_update_caret(self, ...)
			Chatutils.sync_caret(self)
			return ret
		end
	end

	if HUDChat._show_caret then
		local orig_show_caret = HUDChat._show_caret
		function HUDChat:_show_caret(...)
			self._cp_sel = false
			return orig_show_caret(self, ...)
		end
	end
end

function MenuManager:toggle_chatinput()
	if Application:editor() or SystemInfo:platform() ~= Idstring("WIN32") or self:active_menu() or not managers.network:session() then
		return
	end
	if managers.hud then
		managers.hud:toggle_chatinput()
		return true
	end
end