local monster_tortoise = class("monster_tortoise",function ()
	local node = cc.Node:create()
	return node
end)

function monster_tortoise:ctor(objectTab)
	self._obj = objectTab
	self._spr = cc.Sprite:createWithSpriteFrameName("img_67.png")
	print("self._spr: ",self._spr)
	print(objectTab.x,objectTab.y)
	self._spr:addTo(self)
			:align(display.CENTER_BOTTOM,self:getContentSize().width/2,0)
	local _pos = cc.p(objectTab.x+8,objectTab.y-8)
	self:setPosition(_pos)
end

return monster_tortoise