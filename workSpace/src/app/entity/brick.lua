
local object = require("app.entity.object")

local brick = class("brick",object)

function brick:ctor(objectTab)
	brick.super.ctor(self,objectTab)
	self._spr:setSpriteFrame("img_17.png")
	
end

function brick:isHited()
	brick.super:isHited(self)
	self:goDead()
end

function brick:goDead()
	self:clearSelf()
	
end

return brick