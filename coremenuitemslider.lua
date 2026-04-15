core:module("CoreMenuItemSlider")

local data = ItemSlider.reload
function ItemSlider:reload(row_item, node)
	if row_item then
		return data(self, row_item, node)
	else
		return
	end
end