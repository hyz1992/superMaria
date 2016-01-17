
local object = require("app.entity.object")

local brick = class("brick",object)

function brick:ctor(objectTab)
	brick.super.ctor(self,objectTab)
	self._spr:setSpriteFrame("img_17.png")
	
end

return brick