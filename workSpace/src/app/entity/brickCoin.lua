
local object = require("app.entity.object")

local brickCoin = class("brickCoin",object)

function brickCoin:ctor(objectTab)
	brickCoin.super.ctor(self,objectTab)
	self._obj = objectTab
	self._spr:setSpriteFrame("img_03.png")
	local animation = display.newAnimation("img_%02d.png",1,3,false,1/3)
	local ani = cc.Animate:create(animation)
	self._spr:runAction(cc.RepeatForever:create(ani))
end

function brickCoin:isHited()
	brickCoin.super:isHited(self)
	self:goDead()
end

function brickCoin:goDead()
	if self.isDead then
		return
	end
	local sq = transition.sequence{
					cc.MoveBy:create(0.05,cc.p(0,10)),
					cc.MoveBy:create(0.05,cc.p(0,-10)),
					cc.CallFunc:create(function ( ... )
						self.isRuning = false
						self._spr:stopAllActions()
						self._spr:setSpriteFrame("img_09.png")
					end),
					cc.CallFunc:create(function ( ... )
						self.isDead = true

						local moveTime = 0.15
						local animation = display.newAnimation("img_%02d.png",4,4,false,moveTime/4)
						local ani = cc.Animate:create(animation)
						local spr = display.newSprite("#img_04.png")
							:align(display.CENTER_BOTTOM,self._spr:getContentSize().width/2,self._spr:getContentSize().height)
							:addTo(self._spr)
						spr:setGlobalZOrder(10)
						local sq = cc.Spawn:create({
										cc.Repeat:create(ani,2),
										cc.MoveBy:create(moveTime*1.5,cc.p(0,40)),
										
									})
						spr:runAction(transition.sequence{sq,cc.CallFunc:create(function (obj)
											obj:removeSelf()
										end)})
					end)
				}
	if not self.isRuning then
		self.isRuning = true
		self._spr:runAction(sq)
	end
end

return brickCoin