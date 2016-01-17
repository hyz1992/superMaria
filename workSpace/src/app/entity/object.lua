local object = class("object",function ( ... )
	local node = display.newNode()
	node:enableNodeEvents()
	node:setAnchorPoint(0,0)
	return node
end)

allObjectList = {}

function object:ctor(objectTab)
	self._obj = objectTab
	self._spr = display.newSprite()
					:align(display.CENTER_BOTTOM,0,0)
	self:addChild(self._spr,0,0)

	local _map = self:getMap()
	local _pos = _map:positionToTileCoord(cc.p(self._obj.x,self._obj.y))
	self.tileCoord = _pos
	_pos = _map:tilecoordToPosition(_pos)
	_pos.x = _pos.x + _map.tileSize.width/2
	self:setPosition(_pos)
end

function object:getMap()
	_map = gameLayerInstance.m_map
	return _map
end

function object:bIsInScreen()
	local pt = cc.p(0,0)
	pt = self._spr:convertToWorldSpace(pt)

	local offSet = 100
	local ret = pt.x>-offSet and pt.x<display.width+offSet and pt.y>-offSet and pt.y<display.height+offSet

	return ret
end

function object:onEnter()
	table.insert(allObjectList,self)
end

function object:clearSelf()
	for k,v in pairs(allObjectList) do
		if v==self then
			allObjectList[k] = nil
		end
	end
end

function object:onExit()
	
end

--判断自身是否与目标点相交
function object:ifContainPoint(pt)
	local _map = self:getMap()
	local myRect = cc.rect(self._obj.x-self._obj.width/2,self._obj.y-self._obj.height/2,self._obj.width,self._obj.height)
	-- myRect.y = _map.mapSize.height * _map.tileSize.height - myRect.y
	local ret = cc.rectContainsPoint(myRect,pt)
	-- if ret then
		print("--pt",pt.x,pt.y)
		print("myRect",myRect.x,myRect.y)
	-- end
	print("ret",ret)
	return ret
end



return object