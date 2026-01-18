# 协议验证器使用说明

## 概述

协议验证器 (`protocol_validator.lua`) 用于验证服务器发送的每个数据包是否符合客户端期望的格式和大小。这有助于：

1. **及早发现问题**：在发送前验证包体大小，避免客户端解析错误
2. **协议文档化**：所有协议定义集中在一个文件中，便于维护
3. **调试辅助**：自动显示期望大小和实际大小的对比

## 自动验证

验证器已集成到 `LocalGameServer:sendResponse()` 函数中，每次发送响应时自动验证：

```lua
-- 自动验证示例输出
✓ [PET_RELEASE] 包体大小正确: 166字节
❌ [ACCEPT_TASK] 包体大小错误: 期望8字节, 实际4字节
⚠️  未定义协议 CMD 9999
```

## 协议定义格式

在 `protocol_validator.lua` 中定义协议：

### 1. 固定大小协议

```lua
[101] = {
    name = "ACCEPT_TASK",
    minSize = 8,
    maxSize = 8,
    description = "taskId(4) + status(4)"
}
```

### 2. 动态大小协议

```lua
[2304] = {
    name = "PET_RELEASE",
    minSize = 12,  -- 最小大小
    maxSize = nil,  -- 无上限
    calculateSize = function(body)
        -- 根据包体内容计算期望大小
        if #body < 12 then return 12 end
        local flag = readUInt32(body, 9)
        if flag == 0 then
            return 12
        else
            -- 读取effectCount等动态字段
            local effectCount = readUInt16(body, 149)
            return 12 + 154 + effectCount * 24
        end
    end
}
```

### 3. 范围大小协议

```lua
[2605] = {
    name = "ITEM_LIST",
    minSize = 4,
    maxSize = 1000,  -- 可选的最大值
    calculateSize = function(body)
        local itemCount = readUInt32(body, 1)
        return 4 + itemCount * 16
    end
}
```

## 添加新协议

1. 打开 `protocol_validator.lua`
2. 在 `ProtocolValidator.protocols` 表中添加新条目
3. 根据客户端源码确定字段结构和大小

### 示例：添加新协议

```lua
[2999] = {
    name = "NEW_PROTOCOL",
    minSize = 20,
    maxSize = 20,
    description = "field1(4) + field2(8) + field3(8)"
}
```

## 测试验证器

运行测试脚本：

```bash
.\luvit.exe test_protocol_validator.lua
```

测试脚本会：
- 验证各种协议的正确和错误情况
- 列出所有已定义的协议
- 显示详细的验证结果

## 已定义的协议

当前已定义的协议：

| CMD  | 名称 | 大小 | 类型 |
|------|------|------|------|
| 100  | TASK_LIST | ≥4字节 | 动态 |
| 101  | ACCEPT_TASK | 8字节 | 固定 |
| 102  | COMPLETE_TASK | 4字节 | 固定 |
| 2301 | GET_PET_INFO | ≥154字节 | 动态 |
| 2303 | GET_PET_LIST | ≥4字节 | 动态 |
| 2304 | PET_RELEASE | ≥12字节 | 动态 |
| 2404 | READY_TO_FIGHT | 0字节 | 固定 |
| 2405 | USE_SKILL | 0字节 | 固定 |
| 2411 | CHALLENGE_BOSS | 0字节 | 固定 |
| 2504 | NOTE_START_FIGHT | 104字节 | 固定 |
| 2505 | NOTE_USE_SKILL | 16字节 | 固定 |
| 2506 | NOTE_INJURY_HP | 12字节 | 固定 |
| 2507 | NOTE_CHANGE_PROP | 16字节 | 固定 |
| 2508 | NOTE_FIGHT_OVER | 8字节 | 固定 |
| 2605 | ITEM_LIST | ≥4字节 | 动态 |

## 客户端数据结构参考

### PetInfo (完整版, param2=true)

```actionscript
id: uint (4)
name: String (16) - readUTFBytes(16)
dv: uint (4)
nature: uint (4)
level: uint (4)
exp: uint (4)
lvExp: uint (4)
nextLvExp: uint (4)
hp: uint (4)
maxHp: uint (4)
attack: uint (4)
defence: uint (4)
s_a: uint (4)
s_d: uint (4)
speed: uint (4)
ev_hp: uint (4)
ev_attack: uint (4)
ev_defence: uint (4)
ev_sa: uint (4)
ev_sd: uint (4)
ev_sp: uint (4)
skillNum: uint (4)
[固定4次循环] PetSkillInfo (8字节/个)
catchTime: uint (4)
catchMap: uint (4)
catchRect: uint (4)
catchLevel: uint (4)
effectCount: ushort (2)
[循环effectCount次] PetEffectInfo (24字节/个)
skinID: uint (4)

总计: 154字节 (不含effectList)
```

### PetSkillInfo

```actionscript
id: uint (4)
pp: uint (4)

总计: 8字节
```

### PetEffectInfo

```actionscript
itemId: uint (4)
status: ubyte (1)
leftCount: ubyte (1)
effectID: ushort (2)
_loc2_: ubyte (1)
padding: ubyte (1)
_loc3_: ubyte (1)
readUTFBytes(13): (13)

总计: 24字节
```

## 注意事项

1. **字节对齐**：确保所有字段按正确顺序写入，字节数精确匹配
2. **动态字段**：对于动态大小的协议，必须先写入数量字段，再写入数据
3. **固定循环**：某些协议（如技能）客户端固定循环读取4次，即使实际数量少于4
4. **字符串字段**：使用 `readUTFBytes(n)` 的字段必须写入精确的n字节
5. **未定义协议**：未定义的协议会显示警告但不会阻止发送

## 调试技巧

1. 查看服务器日志中的验证消息（绿色✓或红色❌）
2. 对比官服抓包的包体大小
3. 使用十六进制输出查看实际发送的字节
4. 参考客户端源码中的数据结构类（`*.as`文件）

## 维护建议

- 每次添加新协议处理时，同时在验证器中定义
- 发现包体大小错误时，先检查协议定义是否正确
- 定期运行测试脚本确保验证器正常工作
- 参考客户端源码更新协议定义
