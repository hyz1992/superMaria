local monster_mushroom = require("app.entity.monster_mushroom")
local monster_tortoise = require("app.entity.monster_tortoise")
local coin = require("app.entity.coin")
local brick = require("app.entity.brick")
local brickCoin = require("app.entity.brickCoin")

--解析地图的对象层每个对象，通过对象的属性创建不同的实体
function parseTiledObject(objectTab)
	local ret = nil
	local name = objectTab.name
	if name == "Monster" then			--怪物
		--print("Monster")
		ret = createMonster(objectTab)
		if ret._obj.x ~= 1448 then
			-- ret = nil
		end
	elseif name == "Prop" then			--金币
		ret = createObject(objectTab)
	elseif name == "Brick" then			--箱子
		ret = createObject(objectTab)
		if ret._obj.x ~= 360 then
			-- ret = nil
		end
	elseif name == "DisPenser" then		--起点
	elseif name == "Over" then			--终点
	end

	return ret
end

--创建金币、砖块等对象
function createObject(objectTab)
	local ret = nil
	local _a = objectTab.a
	local _b = objectTab.b
	if _a=="AppPropCoin" and _b=="BehPropCoinStop" then		--金币
		--print("创建蘑菇敌人")
		ret = coin.new(objectTab)
	elseif _a=="AppBrickCoin" then	--金币砖块或蘑菇砖块
		ret = brickCoin.new(objectTab)
	elseif _a=="AppBrickRock" and _b=="BehBrickFly" then	--普通砖块
		ret = brick.new(objectTab)
	end
	return ret
end

--创建怪物
function createMonster(objectTab)
	local ret = nil
	local _a = objectTab.a
	local _b = objectTab.b
	if _a=="AppMonsterSmall" and _b=="BehMonsterSmall" then
		--print("创建蘑菇敌人")
		ret = monster_mushroom.new(objectTab)
	elseif _a=="AppTortoise" and _b=="BehTortoise" then
		--print("创建乌龟敌人")
		ret = monster_tortoise.new(objectTab)
	end
	return ret
end
