
local object = require("app.entity.object")

local coin = class("coin",object)

function coin:ctor(objectTab)
	coin.super.ctor(self,objectTab)
	self._obj = objectTab
	self._spr:setSpriteFrame("img_25.png")
	local animation = display.newAnimation("img_%02d.png",25,3,false,1/3)
	local ani = cc.Animate:create(animation)
	self._spr:runAction(cc.RepeatForever:create(ani))
end

function coin:isHited()
	coin.super:isHited(self)
	self:goDead()
end

function coin:goDead()
	self:clearSelf()
	self:removeSelf()
end

return coin