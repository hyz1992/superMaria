local mariaAI = class("mariaAI",function ( ... )
	--return display.newNode()
	local node = display.newSprite("common_Frame9.png")
	node:setAnchorPoint(0,0)
	return node
end)

local MariaType = {}
MariaType.small = 1
MariaType.big = 2
MariaType.fire = 3

local aniType = {}
aniType.standing = 1
aniType.walk = 2
aniType.jump = 3
aniType.die = 4
aniType.fire = 5
aniType.down = 6

local MariaDirectionType = {}
MariaDirectionType.left = -1
MariaDirectionType.right = 1

local OldCommond = {}
OldCommond.standing = 0
OldCommond.walkLeft = 1
OldCommond.walkRight = 2

local isJumpBtnDown = false  --跳跃按钮是否被按下

MAX_V_SPEED = 12  --最大垂直距离
ACC_V = 0.5

START_H_SPEED = 0.5
MAX_H_SPEED = 3
ACC_H = 0.1

function mariaAI:ctor()
	display.loadSpriteFrames("mario.plist","mario.png")
	self.m_mariArmature = display.newSprite()
					:align(display.CENTER_BOTTOM,0,0)
	self:addChild(self.m_mariArmature,0,0)

	self:changeDirection(MariaDirectionType.right)

	self.m_speed = START_H_SPEED
	self.m_vSpeed = 0
	self.m_oldCommond = OldCommond.standing
	self.isJumpOver = false
	self.m_mariaType = MariaType.fire

	self:playAni()

    self:addStateMachine()
    self:onUpdate(handler(self,self.update))
end

function mariaAI:onExit()
	display.removeSpriteFrame("mario.plist")
end

function mariaAI:playAni(_type)
	_type = aniType.standing
	--print(_type)
	self.m_mariArmature:stopAllActions()
	if self.m_mariaType == MariaType.small then
		if aniType.walk == _type then
			local animation = display.newAnimation("mario_1_%d.png",0,2,false,0.2)
			local ani = cc.Animate:create(animation)
			self.m_mariArmature:runAction(cc.RepeatForever:create(ani))
		elseif aniType.jump == _type then
			self.m_mariArmature:setSpriteFrame("mario_1_2.png")
		elseif aniType.standing == _type then
			self.m_mariArmature:setSpriteFrame("mario_1_5.png")
		elseif aniType.die == _type then
			self.m_mariArmature:setSpriteFrame("mario_1_6.png")
		end
	elseif self.m_mariaType == MariaType.big then
		if aniType.walk == _type then
			local animation = display.newAnimation("mario_2_%d.png",0,2,false,0.2)
			local ani = cc.Animate:create(animation)
			self.m_mariArmature:runAction(cc.RepeatForever:create(ani))
		elseif aniType.jump == _type then
			self.m_mariArmature:setSpriteFrame("mario_2_2.png")
		elseif aniType.standing == _type then
			self.m_mariArmature:setSpriteFrame("mario_2_5.png")
		elseif aniType.down == _type then
			self.m_mariArmature:setSpriteFrame("mario_2_6.png")
		end
	elseif self.m_mariaType == MariaType.fire then
		if aniType.walk == _type then
			local animation = display.newAnimation("mario_3_%d.png",0,2,false,0.2)
			local ani = cc.Animate:create(animation)
			self.m_mariArmature:runAction(cc.RepeatForever:create(ani))
		elseif aniType.jump == _type then
			self.m_mariArmature:setSpriteFrame("mario_3_2.png")
		elseif aniType.standing == _type then
			self.m_mariArmature:setSpriteFrame("mario_3_5.png")
		elseif aniType.down == _type then
			self.m_mariArmature:setSpriteFrame("mario_3_6.png")
		elseif aniType.fire == _type then
			self.m_mariArmature:setSpriteFrame("mario_3_7.png")
		end
	end
end

function mariaAI:update()
	local _type,_tilePt = self:ifCollistionV(-1)
	if _type==TileType.eTile_Ground or _type==TileType.eTile_Pillar or _type==TileType.eTile_Mountain or _type==TileType.eTile_Cloud or _type==TileType.eTile_BackGround then
		if self.m_fsm:getState() == "standing" then
			print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~_type: ",_type)
			self:doEvent("goJumpUp",false)
		elseif self.m_fsm:getState() == "walkLeft" then
			self:doEvent("goJumpLeft",false)
		elseif self.m_fsm:getState() == "walkRight" then
			self:doEvent("goJumpRight",false)
		end
	end


	if self.m_fsm:getState() == "standing" then
        return
    elseif self.m_fsm:getState() == "walkLeft" then
    	self:moveH()
    elseif self.m_fsm:getState() == "walkRight" then
    	self:moveH()
    elseif self.m_fsm:getState() == "jumpUp" then
    	if self.isJumpOver then
    		print("停下---------------------------------------xx")
    		self:doEvent("goStanding")
    		if isJumpBtnDown then
    			self:doEvent("goJumpUp")
    		end
    	else
    		self:moveV()
    	end
    elseif self.m_fsm:getState() == "jumpLeft" then
    	if self.m_oldCommond == OldCommond.walkLeft then  
	    	self:moveH()
	    else
	    	self:doEvent("goJumpUp",false)  --跳到空中，中途松开向左按钮
	    	return
	    end
    	if self.isJumpOver then
	    	self:doEvent("goWalkLeft")
	    	if isJumpBtnDown then
    			self:doEvent("goJumpLeft")  --返回地面后，如果向左按钮还没松开，则继续跳
    		end
    	else
    		self:moveV()
    	end
    elseif self.m_fsm:getState() == "jumpRight" then
    	if self.m_oldCommond == OldCommond.walkRight then
	    	self:moveH()
	    else
	    	print("pppppppppppppppppppppppppp---------")
	    	self:doEvent("goJumpUp",false)	--跳到空中，中途松开向右按钮
	    	return
	    end
    	if self.isJumpOver then
	    	self:doEvent("goWalkRight")
	    	if isJumpBtnDown then
    			self:doEvent("goJumpRight")  --返回地面后，如果向右按钮还没松开，则继续跳
    		end
    	else
    		self:moveV()
    	end
    end
end

function mariaAI:moveV()
	local y = self:getPtRightDown().y
	--print("down y : ",y,"  vSpeed: ",self.m_vSpeed)
	local _type,_tilePt = self:ifCollistionV()
	--print("-------------------当前vSpeed: "..self.m_vSpeed.."  当前y ："..y.."  当前_type: ".._type)
	if _type==TileType.eTile_Barrier or _type==TileType.eTile_Object_image or _type==TileType.eTile_Monster_image then
		if self.m_vSpeed >=0 then  --向上遇到障碍，向下反弹
			self.m_vSpeed = 0 - self.m_vSpeed
			--print("碰壁-----------------")
		else  					   --向下遇到障碍，垂直速度降为0
			--print("回到地面--------------------------")
			--self:unscheduleUpdate()
			self.m_vSpeed = 0
			self.isJumpOver = true
			local _map = self:getParent().m_map
			local _tab = {_map:tilecoordToPosition(_tilePt)}
			local mapPtY = _map:getPositionY()
			local _realPtY = _tab[2].y + mapPtY
			self:setPositionY(_realPtY)
			-- print("----------------------------------- vv  ",_tab[2].y,mapPtY)
		end
		return
	end
	self.isJumpOver = false
	--print("竖直位移,_type: ".._type)
	self.m_vSpeed = self.m_vSpeed - ACC_V
	if self.m_vSpeed<-MAX_V_SPEED then
		self.m_vSpeed = -MAX_V_SPEED
	end

	local ptY = self:getPositionY()
	local _map = self:getParent().m_map
	local mapHeight = _map.tileSize.height * _map.mapSize.height
	local mapPtY = _map:getPositionY()
	
	if self.m_vSpeed>0 then
		if ptY < display.height / 10 * 7 or mapPtY <=-(mapHeight - display.height) then
			ptY = ptY + self.m_vSpeed
			self:setPositionY(ptY)
			-- print("1111111111  ",self.m_vSpeed)
		else
			mapPtY = mapPtY-self.m_vSpeed
			_map:setPositionY(mapPtY)
			-- print("2222222222  ",self.m_vSpeed,mapPtY)
		end
		
	elseif self.m_vSpeed<0 then
		if ptY > display.height / 10 * 3 or mapPtY >=0 then
			ptY = ptY + self.m_vSpeed
			self:setPositionY(ptY)
			-- print("3333333333333  ",self.m_vSpeed)
		else
			mapPtY = mapPtY-self.m_vSpeed
			if mapPtY>0 then
				print("重置地图Y坐标为0，"..mapPtY)
				mapPtY = 0
			end
			_map:setPositionY(mapPtY)
			-- print("44444444444444  ",self.m_vSpeed,mapPtY)
		end
	end



	-- local ptY = self:getPositionY()
	-- ptY = ptY + self.m_vSpeed
	-- self:setPositionY(ptY)
end

function mariaAI:adjustOffsetX()
	local ptX = self:getPositionX()
	local _map = self:getParent().m_map
	local mapLength = _map.tileSize.width * _map.mapSize.width
	local mapPtX = _map:getPositionX()

	local rect = self.m_mariArmature:getBoundingBox()
	local realPtX,tileNum
	if self.m_direction == MariaDirectionType.right then
		realPtX = ptX -mapPtX + rect.width/2
		tileNum = math.floor(realPtX/_map.tileSize.width)
		local mod = realPtX % _map.tileSize.width
		print("num: ",tileNum,"   mod:  ",mod)
		if mod~=0 and mod <= MAX_H_SPEED then
			realPtX = tileNum * _map.tileSize.width
			ptX = realPtX + mapPtX - rect.width/2
		elseif mod~=0 and mod >= _map.tileSize.width - MAX_H_SPEED then
			realPtX = tileNum * _map.tileSize.width + _map.tileSize.width
			ptX = realPtX + mapPtX - rect.width/2
		end
		self:setPositionX(ptX)
	elseif self.m_direction == MariaDirectionType.left then
		realPtX = ptX -mapPtX - rect.width/2
		tileNum = math.ceil(realPtX/_map.tileSize.width)
		local mod = realPtX % _map.tileSize.width
		if mod~=0 and mod <= MAX_H_SPEED then
			realPtX = tileNum * _map.tileSize.width - _map.tileSize.width
			ptX = realPtX + mapPtX + rect.width/2
		elseif mod~=0 and mod >= _map.tileSize.width - MAX_H_SPEED then
			realPtX = tileNum * _map.tileSize.width 
			ptX = realPtX + mapPtX + rect.width/2
		end
		self:setPositionX(ptX)
	end
	print("=================,",self.m_direction,ptX,realPtX)
end

function mariaAI:moveH()
	local ptX = self:getPositionX()
	local _map = self:getParent().m_map
	local mapLength = _map.tileSize.width * _map.mapSize.width
	local mapPtX = _map:getPositionX()

	local _type = self:ifCollistionH()
	if _type==TileType.eTile_Barrier or _type==TileType.eTile_Object_image or _type==TileType.eTile_Monster_image or _type==TileType.eTile_Bounder then
		--撞到障碍物时，对横坐标进行微调
		print(self.m_fsm:getState())
		if self.m_fsm:getState()== "walkLeft" or self.m_fsm:getState()=="walkRight" or self.m_fsm:getState()=="jumpLeft" or self.m_fsm:getState()=="jumpRight" then
			self:adjustOffsetX()
		end
		return
	end
	if self.m_speed<MAX_H_SPEED then
		self.m_speed = self.m_speed + ACC_H
	end
	
	if self.m_direction == MariaDirectionType.right then
		if ptX < display.width / 10 * 7 or mapPtX <=-(mapLength - display.width) then
			ptX = ptX + self.m_speed
			self:setPositionX(ptX)
		else
			mapPtX = mapPtX-self.m_speed
			_map:setPositionX(mapPtX)
		end
		
	elseif self.m_direction == MariaDirectionType.left then
		if ptX > display.width / 10 * 3 or mapPtX >=0 then
			ptX = ptX - self.m_speed
			self:setPositionX(ptX)
		else
			mapPtX = mapPtX+self.m_speed
			_map:setPositionX(mapPtX)
		end
	end
end

--竖直方向上的碰撞检测,offSet是地图块的偏移量{x,y}
--bValue为可选参数，bValue=1，表示向上检测，bValue=-1表示向下检测，bValue=0或bValue=nil表示根据竖直方向速度检测
function mariaAI:ifCollistionV(bValue)
	local _offY = 0
	local _map = self:getParent().m_map
	local pt_1,pt_2
	bValue = bValue or 0
	local _bol
	if bValue==0 then
		_bol = (self.m_vSpeed >=0)
	elseif bValue==1 then
		_bol = true
	elseif bValue==-1 then
		_bol = false
	else
		_bol = (self.m_vSpeed >=0)
	end
	if _bol then 		   --向上
		-- print("---------向上：-----")
		pt_1 = self:getPtLeftTop()			--需要检测的有左上和右上边界
		pt_2 = self:getPtRightTop()
		pt_1.y = pt_1.y+_offY
		pt_2.y = pt_2.y+_offY
		if pt_1.y>=display.height then				--首先判断是否到了边界
			return TileType.eTile_Bounder
		end
		-- printTable(pt_2)
		-- print("-------------,屏幕像素")
	else 								--向下
		-- print("---------向下：-----")
		pt_1 = self:getPtLeftDown()			--需要检测的有左下和右下边界
		pt_2 = self:getPtRightDown()
		pt_1.y = pt_1.y-_offY
		pt_2.y = pt_2.y-_offY
		if pt_1.y<=0 then				--首先判断是否到了边界
			return TileType.eTile_Bounder
		end
		-- printTable(pt_2)
		-- print("-------------,屏幕像素")
	end

	local mapX,mapY = _map:getPosition()
	-- print("地图坐标  ",mapY)
	pt_1 = cc.p((pt_1.x - mapX),(pt_1.y - mapY))  --得到玛丽在地图上的像素坐标
	pt_2 = cc.p((pt_2.x - mapX),(pt_2.y - mapY))
	-- printTable(pt_2)
	-- print("-------------,地图像素")
	local _y 
	if _bol then 
		_y = 1
	else
		_y = -1
	end
	pt_1 = _map:positionToTileCoord(pt_1,{x=1,y = _y})										  --得到玛丽在地图上的块坐标
	pt_2 = _map:positionToTileCoord(pt_2,{x=-1,y = _y})
	-- printTable(pt_2)
	-- print("---------------------,地图块")
	local type_1 = _map:tileTypeforPos(pt_1)		--得到块类型
	local type_2 = _map:tileTypeforPos(pt_2)
	-- print("type_1",type_1)
	-- print("type_2",type_2)
	if type_1==TileType.eTile_Barrier or type_1==TileType.eTile_Object_image or type_1==TileType.eTile_Monster_image or type_1==TileType.eTile_Land then		--如果阻止前进的东西，则先返回
		-- print("type_1",type_1)
		-- print("---------------------====111")
		return type_1,pt_1
	end
	if type_2==TileType.eTile_Barrier or type_2==TileType.eTile_Object_image or type_2==TileType.eTile_Monster_image or type_2==TileType.eTile_Land then
		-- print("type_2",type_2)
		-- print("---------------------====222")
		return type_2,pt_2
	end

	if type_1~=TileType.eTile_None then
		return type_1,pt_1
	else
		return type_2,pt_2
	end
end

--水平方向上的碰撞检测
function mariaAI:ifCollistionH()
	local _offX = 0
	local _map = self:getParent().m_map
	local pt_1,pt_2
	local _bol = (self.m_direction == MariaDirectionType.right)
	if _bol then
		pt_1 = self:getPtRightTop()			--需要检测的有右上和右下边界
		pt_2 = self:getPtRightDown()
		pt_1.x = pt_1.x+_offX
		pt_2.x = pt_2.x+_offX

		if pt_1.x>=display.width then				--首先判断是否到了边界
			return TileType.eTile_Bounder
		end
	else
		pt_1 = self:getPtLeftTop()			--需要检测的有左上和左下边界
		pt_2 = self:getPtLeftDown()
		pt_1.x = pt_1.x-_offX
		pt_2.x = pt_2.x-_offX
		if pt_1.x<=0 then				--首先判断是否到了边界
			return TileType.eTile_Bounder
		end
	end

	local mapX,mapY = _map:getPosition()
	pt_1 = cc.p((pt_1.x - mapX),(pt_1.y - mapY))  --得到玛丽在地图上的像素坐标
	pt_2 = cc.p((pt_2.x - mapX),(pt_2.y - mapY))
	local _x 
	if _bol then 
		_x = 1
	else
		_x = -1
	end
	print("--------地图坐标x",mapX,"玛丽地图坐标x",pt_2.x)
	pt_1 = _map:positionToTileCoord(pt_1,{x = _x,y=-1})										  --得到玛丽在地图上的块坐标
	pt_2 = _map:positionToTileCoord(pt_2,{x = _x,y=1})
	local type_1 = _map:tileTypeforPos(pt_1)		--得到块类型
	local type_2 = _map:tileTypeforPos(pt_2)
	-- print(type_1)
	-- print(type_2)
	if type_1==TileType.eTile_Barrier or type_1==TileType.eTile_Object_image or type_1==TileType.eTile_Monster_image then		--如果阻止前进的东西，则先返回
		return type_1
	end
	if type_2==TileType.eTile_Barrier or type_2==TileType.eTile_Object_image or type_1==TileType.eTile_Monster_image then
		return type_2
	end

	if type_1~=TileType.eTile_None then
		return type_1
	else
		return type_2
	end
end

function mariaAI:getPtLeftTop()
	local rect = self.m_mariArmature:getBoundingBox()
	local position = cc.p(self:getPositionX(),self:getPositionY())
	position.x = position.x - rect.width/2
	position.y = position.y + rect.height
	return position
end

function mariaAI:getPtLeftDown()
	local rect = self.m_mariArmature:getBoundingBox()
	local position = cc.p(self:getPositionX(),self:getPositionY())
	position.x = position.x - rect.width/2
	return position
end

function mariaAI:getPtRightTop()
	local rect = self.m_mariArmature:getBoundingBox()
	local position = cc.p(self:getPositionX(),self:getPositionY())
	position.x = position.x + rect.width/2
	position.y = position.y + rect.height
	return position
end

function mariaAI:getPtRightDown()
	local rect = self.m_mariArmature:getBoundingBox()
	local position = cc.p(self:getPositionX(),self:getPositionY())
	position.x = position.x + rect.width /2
	return position
end

function mariaAI:addStateMachine()
    self.m_fsm = {}
    cc.GameObject.extend(self.m_fsm)
    :addComponent("components.behavior.StateMachine")
    :exportMethods()

    self.m_fsm:setupState({
        -- 初始状态
        initial = "standing",
        
        -- 事件和状态转换
        events = {
            {name = "goStanding",  from = {"standing","walkLeft","walkRight","jumpUp","jumpLeft","jumpRight"}, to = "standing" },
            {name = "goWalkLeft",  from = {"standing","walkRight","jumpLeft"}, to = "walkLeft" },
            {name = "goWalkRight",  from = {"standing","walkLeft","jumpRight"}, to = "walkRight" },
            {name = "goJumpUp",  from = {"standing","jumpLeft","jumpRight"}, to = "jumpUp" },
            {name = "goJumpLeft",  from = {"walkLeft","jumpUp"}, to = "jumpLeft" },
            {name = "goJumpRight",  from = {"walkRight","jumpUp"}, to = "jumpRight" },
            {name = "goWalkDown",  from = {"standing"}, to = "walkDown" },
            
        }, 

        -- 状态转变后的回调 
        callbacks = {
            onstanding = function (event) self:standing() end,
            onwalkLeft = function (event) self:walkLeft() end,
            onwalkRight = function (event) self:walkRight() end,
            onjumpUp = function (event) self:jumpUp(event) end,
            onjumpLeft = function (event) self:jumpLeft(event) end,
            onjumpRight = function (event) self:jumpRight(event) end,
            goWalkDown = function (event) self:walkDown() end,

        },
    })
end

function mariaAI:doEvent(event, ...)
	if event == "goStanding" or event == "goWalkLeft" or event == "goWalkRight" then
		self.m_vSpeed = 0
		self.m_oldCommond = OldCommond.standing
		printTraceback()
		self.isJumpOver = false
	end
	--print("--------",event)
	if event == "goWalkLeft" or event == "goJumpLeft" then
		self:changeDirection(MariaDirectionType.left)
		self.m_oldCommond = OldCommond.walkLeft
	end
	if event == "goWalkRight" or event == "goJumpRight" then
		--printTraceback()
		self:changeDirection(MariaDirectionType.right)
		self.m_oldCommond = OldCommond.walkRight
	end
    self.m_fsm:doEvent(event, ...)
end

function mariaAI:standing()
	self:playAni(aniType.standing)
end

function mariaAI:walkLeft()
	self:playAni(aniType.walk)
end

function mariaAI:walkRight()
	self:playAni(aniType.walk)
end

function mariaAI:jumpUp(event)
	if event.args[1]==nil or event.args[1] then
		self.m_vSpeed = MAX_V_SPEED
	end
	self:playAni(aniType.jump)
end

function mariaAI:jumpLeft(event)
	if event.args[1]==nil or event.args[1] then
		self.m_vSpeed = MAX_V_SPEED
	end
	self:playAni(aniType.jump)
end

function mariaAI:jumpRight(event)
	if event.args[1]==nil or event.args[1] then
		self.m_vSpeed = MAX_V_SPEED
	end
	self:playAni(aniType.jump)
end

function mariaAI:walkDown()
	self:playAni(aniType.down)
end

function mariaAI:changeDirection(_direction)
	self.m_direction = _direction
	self.m_mariArmature:setScale(self.m_direction,1)
end

function mariaAI:onKeyPressed(keyCode,event)
    if keyCode == cc.KeyCode.KEY_LEFT_ARROW then
    	if self.m_fsm:getState()=="walkRight" or self.m_fsm:getState()=="walkLeft" or self.m_fsm:getState()=="standing" or self.m_fsm:getState()=="down" then
	        self:doEvent("goWalkLeft")
	    elseif self.m_fsm:getState()=="jumpUp" then
	    	self:doEvent("goJumpLeft",false)
	    end
    elseif keyCode == cc.KeyCode.KEY_RIGHT_ARROW  then
        if self.m_fsm:getState()=="walkRight" or self.m_fsm:getState()=="walkLeft" or self.m_fsm:getState()=="standing" or self.m_fsm:getState()=="down" then
	        self:doEvent("goWalkRight")
	    elseif self.m_fsm:getState()=="jumpUp" then
        	self:doEvent("goJumpRight",false)
	    end
    elseif keyCode == cc.KeyCode.KEY_UP_ARROW  then
    	if self.m_fsm:getState() == "jumpUp" or self.m_fsm:getState() == "jumpLeft" or self.m_fsm:getState() == "jumpRight" then
    		return
    	end
    	isJumpBtnDown = true
        if self.m_fsm:getState() == "standing" then
        	self:doEvent("goJumpUp")
        else
        	if self.m_direction == MariaDirectionType.left then
		        self:doEvent("goJumpLeft")
		    elseif self.m_direction == MariaDirectionType.right then
		    	self:doEvent("goJumpRight")
		    end
        end
    elseif keyCode == cc.KeyCode.KEY_DOWN_ARROW  then
        print("cccccccccccccccccccccc")
    end
end

function mariaAI:onKeyReleased(keyCode,event)
    if keyCode == cc.KeyCode.KEY_LEFT_ARROW then
    	self.m_oldCommond = OldCommond.standing
        if self.m_fsm:getState()=="walkRight" or self.m_fsm:getState()=="walkLeft" or self.m_fsm:getState()=="standing" or self.m_fsm:getState()=="down" then
	        self:doEvent("goStanding")
	    end
    elseif keyCode == cc.KeyCode.KEY_RIGHT_ARROW  then
    	self.m_oldCommond = OldCommond.standing
        if self.m_fsm:getState()=="walkRight" or self.m_fsm:getState()=="walkLeft" or self.m_fsm:getState()=="standing" or self.m_fsm:getState()=="down" then
	        self:doEvent("goStanding")
	    end
    elseif keyCode == cc.KeyCode.KEY_UP_ARROW  then
        isJumpBtnDown = false
    elseif keyCode == cc.KeyCode.KEY_DOWN_ARROW  then
        print("cccccccccccccccccccccc")
        self:doEvent("goStanding")
    end
end

return mariaAI