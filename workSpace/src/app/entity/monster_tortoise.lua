local body = require("app.entity.body")

local monster_tortoise = class("monster_tortoise",body)

function monster_tortoise:ctor(objectTab)
	monster_tortoise.super.ctor(self)
	self._obj = objectTab
	self._spr:setSpriteFrame("img_67.png")
	self._spr:align(display.CENTER_BOTTOM,self:getContentSize().width/2,0)
	-- print("self._spr: ",self._spr)
	-- print(objectTab.x,objectTab.y)
			
	local _pos = cc.p(objectTab.x+8,objectTab.y-8)
	self:setPosition(_pos)
end

return monster_tortoise