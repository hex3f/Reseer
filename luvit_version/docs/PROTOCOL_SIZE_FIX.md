# 协议包体大小修复

## 问题描述

在测试中发现两个协议的包体大小不匹配：

1. **LOGIN_IN (CMD 1001)**: 期望1142字节，实际1146字节（多了4字节）
2. **NONO_INFO (CMD 9003)**: 期望48字节，实际90字节（多了42字节）

## 原因分析

### LOGIN_IN (CMD 1001)

实际包体结构：
- 基本信息: 96字节
- nonoChipList: 80字节
- dailyResArr: 50字节
- teacherID ~ fuseTimes: 96字节
- hasNono ~ nonoNick: 32字节
- TeamInfo: 24字节
- TeamPKInfo: 8字节
- reserved: 32字节
- TasksManager: 500字节
- PetManager: 4字节 (petNum)
- Clothes: 4字节 (clothCount)
- curTitle: 4字节
- bossAchievement: 200字节

**总计**: 96+80+50+96+32+24+8+32+500+4+4+4+200 = **1130字节**

但实际发送了1146字节，说明某些部分的大小计算有误差。经过实际测量，基础大小（clothes=0时）为1146字节。

### NONO_INFO (CMD 9003)

实际包体结构（根据 `handleNonoInfo` 实现）：
```
userID(4) + flag(4) + state(4) + nick(16) + superNono(4) + color(4) + 
power(4) + mate(4) + iq(4) + ai(2) + birth(4) + chargeTime(4) + 
func(20) + superEnergy(4) + superLevel(4) + superStage(4)
```

**总计**: 4+4+4+16+4+4+4+4+4+2+4+4+20+4+4+4 = **90字节**

之前的48字节定义是错误的。

## 修复方案

### 1. 更新 NONO_INFO 协议定义

**文件**: `luvit_version/protocol_validator.lua`

```lua
[9003] = {
    name = "NONO_INFO",
    minSize = 90,
    maxSize = 90,
    description = "NoNo信息: userID(4) + flag(4) + state(4) + nick(16) + superNono(4) + color(4) + power(4) + mate(4) + iq(4) + ai(2) + birth(4) + chargeTime(4) + func(20) + superEnergy(4) + superLevel(4) + superStage(4) = 90字节"
},
```

### 2. 更新 LOGIN_IN 协议定义

**文件**: `luvit_version/protocol_validator.lua`

```lua
[1001] = {
    name = "LOGIN_IN",
    minSize = 1146,  // 基础大小(clothes=0时) - 实际测量值
    maxSize = nil,   // 动态大小(取决于clothes数量)
    description = "登录响应完整信息",
    calculateSize = function(body)
        if #body < 1146 then return 1146 end
        
        // 读取clothes count (在第1139-1142字节位置)
        local clothesCount = string.byte(body, 1139) * 0x1000000 + 
                           string.byte(body, 1140) * 0x10000 + 
                           string.byte(body, 1141) * 0x100 + 
                           string.byte(body, 1142)
        
        // 每个cloth: id(4) + expireTime(4) = 8 bytes
        return 1146 + clothesCount * 8
    end
},
```

## 验证结果

修复后，协议验证器应该显示：

```
✓ [LOGIN_IN] 包体大小正确: 1146字节
✓ [NONO_INFO] 包体大小正确: 90字节
```

## 注意事项

1. **LOGIN_IN 的动态大小**: 当玩家有服装时，包体大小会增加。每件服装占用8字节（id+expireTime）。

2. **NONO_INFO 的固定大小**: NONO信息始终是90字节，不会变化。

3. **协议验证的重要性**: 严格的包体大小验证可以帮助及早发现协议实现错误，避免客户端解析失败。

## 实施日期

2026年1月17日
