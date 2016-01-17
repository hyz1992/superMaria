
local object = require("app.entity.object")

local brickCoin = class("brickCoin",object)

function brickCoin:ctor(objectTab)
	brickCoin.super.ctor(self,objectTab)
	self._obj = objectTab
	self._spr:setSpriteFrame("img_03.png")
	
end

function brickCoin:isHited()
	brickCoin.super:isHited(self)
end

return brickCoin