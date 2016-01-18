
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
	self._spr:hide()
	local texeture2D = self._spr:getSpriteFrame():getTexture()
	local size = self._spr:getContentSize()
	local rect = self._spr:getSpriteFrame():getRect()
	printTable(size)
	printTable(rect)
	local sp_1 = cc.Sprite:createWithTexture(texeture2D,cc.rect(rect.x,rect.y,size.width/2,size.height/2))
			:addTo(self)
			:move(cc.p(-size.width*0.25,size.height*0.75))
	local sp_2 = cc.Sprite:createWithTexture(texeture2D,cc.rect(rect.x+size.width/2,rect.y,size.width/2,size.height/2))
			:addTo(self)
			:move(cc.p(size.width*0.25,size.height*0.75))
	local sp_3 = cc.Sprite:createWithTexture(texeture2D,cc.rect(rect.x,rect.y+size.height/2,size.width/2,size.height/2))
			:addTo(self)
			:move(cc.p(-size.width*0.25,size.height*0.25))
	local sp_4 = cc.Sprite:createWithTexture(texeture2D,cc.rect(rect.x+size.width/2,rect.y+size.height/2,size.width/2,size.height/2))
			:addTo(self)
			:move(cc.p(size.width*0.25,size.height*0.25))

	local moveTime = 0.2
	local distance = 40
	sp_1:runAction(cc.MoveBy:create(moveTime,cc.p(-distance,distance)))
	sp_2:runAction(cc.MoveBy:create(moveTime,cc.p(distance,distance)))
	sp_3:runAction(cc.MoveBy:create(moveTime,cc.p(-distance,-distance)))
	sp_4:runAction(cc.MoveBy:create(moveTime,cc.p(distance,-distance)))
	self:runAction(transition.sequence{cc.DelayTime:create(moveTime),cc.CallFunc:create(function (obj)
		obj:removeSelf()
	end)})
end

return brick