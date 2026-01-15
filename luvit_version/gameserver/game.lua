local Game = {}
local Map = require "./map"
local gpp = require "./gamepktprotocol"
local usrcnt = 0
local userlist = {}

function Game.newUser()
    local user = {}
    user.logon = false
    user.userid = 0
    user.nick = ""
    user.color = 0xFFFFFF
    user.vip = false
    user.viped = false
    user.vipLevel = 0
    user.coins = 0
    user.energy = 100
    user.mapID = 101
    user.mapid = 101
    user.posX = 300
    user.posY = 300
    user.x = 300
    user.y = 300
    user.status = 0
    user.action = 0
    user.direction = 0
    return user
end

function Game.login(user,userid,serverID,magicString,session,loginType)
    userlist[userid] = user
    usrcnt = usrcnt + 1
    user.logon = true
    user.userid = userid
    user.nick = "赛尔" .. usrcnt .. "号"
    user.color = 0xFFFFFF
    user.vip = true
    user.viped = true
    user.vipLevel = 5
    user.coins = 999999  -- 赛尔豆
    user.energy = 100
    user.mapID = 101  -- 赛尔号起始地图 (太空站)
    user.mapid = 101
    user.posX = 300
    user.posY = 300
    user.x = 300
    user.y = 300
    user.status = 0
    user.action = 0
    user.direction = 0
    
    print(string.format("\27[32m[GAME] User %d logged in as %s\27[0m", userid, user.nick))
end

function Game.endUser(user)
    if user.userid and userlist[user.userid] then
        userlist[user.userid] = nil
        usrcnt = usrcnt - 1
        print(string.format("\27[33m[GAME] User %d disconnected\27[0m", user.userid))
    end
end

function Game.enterMap(user, newmap, newmaptype)
    print(string.format("\27[36m[GAME] User %d entering map %d\27[0m", user.userid, newmap))
    
    -- 离开旧地图
    if user.mapid and user.mapid ~= newmap then
        local oldMap = Map.getMap(user.mapid)
        if oldMap then
            local body = gpp.makeLeaveMap({user.userid})
            gpp.mapBroadcast(oldMap, 2002, 0, body)  -- LEAVE_MAP
        end
    end
    
    -- 更新用户地图
    user.mapID = newmap
    user.mapid = newmap
    
    -- 设置默认位置
    user.posX = 300
    user.posY = 300
    user.x = 300
    user.y = 300
    
    -- 加入新地图
    Map.changeMapOfUser(user, newmap)
    
    -- 发送地图信息给用户
    local mapInfo = gpp.makeMapInfo(newmap, newmaptype or 0)
    local head = gpp.makeHead(406, user.userid, 0, #mapInfo)
    user:send(head .. mapInfo)
    
    -- 发送场景用户列表
    gpp.sendAllSceneUser(user, newmap)
end

function Game.walk(user, endx, endy)
    user.x = endx
    user.y = endy
    user.posX = endx
    user.posY = endy
    print(string.format("\27[36m[GAME] User %d walking to (%d, %d)\27[0m", user.userid, endx, endy))
    gpp.broadcastWalk(Map.getMapByUser(user), user.userid, endx, endy)
end

function Game.talk(user, towho, str)
    print(string.format("\27[35m[CHAT] [%d] %s: %s\27[0m", user.userid, user.nick, str))
    
    if towho == 0 then
        -- 公共聊天
        if str == "/color" then
            gpp.broadcastChat(Map.getMapByUser(user), user, towho, "我已经随机变色了")
            user.color = math.random(0xffffff)
            gpp.sendAllSceneUser(user, user.mapid)
            return
        elseif str == "/help" then
            gpp.broadcastChat(Map.getMapByUser(user), user, towho, "命令: /color - 随机变色, /pos - 显示位置")
            return
        elseif str == "/pos" then
            gpp.broadcastChat(Map.getMapByUser(user), user, towho, 
                string.format("位置: 地图%d (%d, %d)", user.mapid, user.x, user.y))
            return
        end
        gpp.broadcastChat(Map.getMapByUser(user), user, towho, str)
    elseif userlist[towho] then
        -- 私聊
        gpp.sendChat(userlist[towho], user, towho, str)
    end
end

function Game.doAction(user, action, direction)
    user.action = action
    user.direction = direction
    print(string.format("\27[36m[GAME] User %d action: %d, direction: %d\27[0m", user.userid, action, direction))
    gpp.broadcastAction(Map.getMapByUser(user), user, action, direction)
end

return Game
