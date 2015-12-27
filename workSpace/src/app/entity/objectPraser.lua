local monster_mushroom = require("app.entity.monster_mushroom")
local monster_tortoise = require("app.entity.monster_tortoise")
xxx = 0
--解析地图的对象层每个对象，通过对象的属性创建不同的实体
function parseTiledObject(objectTab)
	local ret = nil
	local name = objectTab.name
	--print(name)
	if name == "Monster" then			--怪物
		--print("Monster")
		ret = createMonster(objectTab)
		if ret._obj.x ~= 904 then
			-- ret = nil
		end
		-- ret = nil
		xxx = xxx+1
	elseif name == "Prop" then			--金币
	elseif name == "Brick" then			--箱子
	elseif name == "DisPenser" then		--起点
	elseif name == "Over" then			--终点
	end

	return ret
end

--创建金币、砖块等对象
function createObject(objectTab)
	-- body
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