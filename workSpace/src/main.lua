
cc.FileUtils:getInstance():setPopupNotify(false)
cc.FileUtils:getInstance():addSearchPath("src/")
cc.FileUtils:getInstance():addSearchPath("res/")

print("cccccccccccccccccccccc")

require "config"
require "cocos.init"
require("app.MyInit")

local function main()
    require("app.MyApp"):create():enterScene("gameLayer")
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end
