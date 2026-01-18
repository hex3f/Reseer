# 精灵包修复 - GET_PET_LIST 协议

## 问题描述

打开精灵包没有反应，客户端无法显示精灵列表。

## 根本原因

服务器发送的 `GET_PET_LIST` (CMD 2303) 响应格式与客户端期望不匹配。

### 客户端期望的格式 (PetListInfo.as)

```actionscript
public function PetListInfo(param1:IDataInput = null)
{
    if(Boolean(param1))
    {
        this.id = param1.readUnsignedInt();          // 精灵ID (4 bytes)
        this.catchTime = param1.readUnsignedInt();   // 捕获时间 (4 bytes)
        this.skinID = param1.readUnsignedInt();      // 皮肤ID (4 bytes)
    }
}
```

**每只精灵 12 字节：id(4) + catchTime(4) + skinID(4)**

### 服务器原来发送的格式

```lua
-- 错误的格式：
catchTime(4) + id(4) + level(4) + hp(4) + maxHp(4) + skillNum(4) + skills...
-- 每只精灵至少 24 字节，还有技能数据
```

## 修复方案

### 1. 修复 handleGetPetList (localgameserver.lua)

```lua
-- CMD 2303: 获取精灵列表
-- 响应格式: petCount(4) + [PetListInfo * petCount]
-- PetListInfo: id(4) + catchTime(4) + skinID(4) = 12 bytes
function LocalGameServer:handleGetPetList(clientData, cmdId, userId, seqId, body)
    local petCount = 0
    local petData = ""
    
    if self.userdb then
        local db = self.userdb:new()
        local pets = db:getPets(userId)
        
        for _, pet in ipairs(pets) do
            petCount = petCount + 1
            local petId = pet.id or 0
            local catchTime = pet.catchTime or os.time()
            local skinID = pet.skinID or 0
            
            -- PetListInfo: id(4) + catchTime(4) + skinID(4)
            petData = petData ..
                writeUInt32BE(petId) ..
                writeUInt32BE(catchTime) ..
                writeUInt32BE(skinID)
        end
    end
    
    local responseBody = writeUInt32BE(petCount) .. petData
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end
```

### 2. 更新协议验证器 (protocol_validator.lua)

```lua
[2303] = {
    name = "GET_PET_LIST",
    minSize = 4,  -- petCount(4)
    maxSize = nil,
    calculateSize = function(body)
        if #body < 4 then return 4 end
        local petCount = string.byte(body, 1) * 0x1000000 + 
                       string.byte(body, 2) * 0x10000 + 
                       string.byte(body, 3) * 0x100 + 
                       string.byte(body, 4)
        -- 每个精灵: id(4) + catchTime(4) + skinID(4) = 12字节
        return 4 + petCount * 12
    end,
    description = "获取精灵列表（每只精灵12字节）"
},
```

## 数据包结构对比

### 修复前（错误）
```
响应包体:
  petCount(4)
  对于每只精灵:
    catchTime(4)
    id(4)
    level(4)
    hp(4)
    maxHp(4)
    skillNum(4)
    skills[4] * (id(4) + pp(4))
  
总大小: 4 + petCount * (24 + skillNum * 8) 字节
```

### 修复后（正确）
```
响应包体:
  petCount(4)
  对于每只精灵:
    id(4)
    catchTime(4)
    skinID(4)
  
总大小: 4 + petCount * 12 字节
```

## 测试验证

### 测试用户数据
用户 100000001 有 3 只精灵（ID 7）：
```json
"pets": [
    {"catchTime": 1768539136, "level": 5, "id": 7, "nature": 6, "dv": 31},
    {"catchTime": 1768539136, "level": 5, "id": 7, "nature": 5, "dv": 31},
    {"catchTime": 1768539136, "level": 5, "id": 7, "nature": 15, "dv": 31}
]
```

### 期望的服务器响应
```
petCount: 3 (0x00000003)
精灵1: id=7, catchTime=1768539136, skinID=0
精灵2: id=7, catchTime=1768539136, skinID=0
精灵3: id=7, catchTime=1768539136, skinID=0

总大小: 4 + 3 * 12 = 40 字节
```

### 验证步骤
1. 启动服务器
2. 登录游戏
3. 点击精灵包图标
4. 观察服务器日志：
   ```
   [LocalGame] 处理 CMD 2303: 获取精灵列表
   [LocalGame] 返回精灵: id=7, catchTime=1768539136, skinID=0
   [LocalGame] 返回精灵: id=7, catchTime=1768539136, skinID=0
   [LocalGame] 返回精灵: id=7, catchTime=1768539136, skinID=0
   [LocalGame] 返回 3 只精灵
   ✓ [GET_PET_LIST] 包体大小正确: 40字节
   ```
5. 客户端应该显示精灵包界面，包含 3 只精灵

## 注意事项

1. **PetListInfo 只是精灵列表的简化信息**
   - 只包含 id, catchTime, skinID
   - 不包含等级、HP、技能等详细信息
   - 详细信息通过其他命令获取（如 GET_PET_INFO）

2. **catchTime 的作用**
   - 用作精灵的唯一标识符
   - 在其他命令中用于指定具体的精灵

3. **skinID 的作用**
   - 精灵皮肤 ID
   - 0 表示默认皮肤

## 相关命令

- **CMD 2303 (GET_PET_LIST)**: 获取精灵列表（简化信息）
- **CMD 2301 (GET_PET_INFO)**: 获取单只精灵的详细信息
- **CMD 2304 (PET_RELEASE)**: 释放精灵到战斗位置
- **CMD 2305 (PET_SHOW)**: 展示精灵

## 修复文件

- `luvit_version/gameserver/localgameserver.lua` - handleGetPetList 函数
- `luvit_version/protocol_validator.lua` - GET_PET_LIST 协议定义
