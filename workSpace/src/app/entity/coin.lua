
local object = require("app.entity.object")

local coin = class("coin",object)

function coin:ctor(objectTab)
	coin.super.ctor(self,objectTab)
	self._obj = objectTab
	self._spr:setSpriteFrame("img_07.png")

end

return coin