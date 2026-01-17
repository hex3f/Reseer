# 服装 Level 字段修复

## 问题描述

用户报告：第二次登录后，客户端尝试加载 `100027_360000.swf`，导致 404 错误。

## 根本原因

### 协议字段混淆

**LOGIN_IN (CMD 1001) 响应中的服装数据格式**：
```
clothCount(4) + [clothId(4) + field2(4)] * count
```

**问题**：`field2` 到底是什么？

1. **服务器端代码**（之前）：
   ```lua
   local expireTime = cloth.expireTime or 0x057E40  -- 360000
   clothBuf:wuint(pos, expireTime)
   ```
   发送的是 `expireTime = 360000`

2. **客户端代码**（UserInfo.as）：
   ```actionscript
   _loc3_ = param2.readUnsignedInt();  // clothId
   _loc4_ = param2.readUnsignedInt();  // 第二个字段
   param1.clothes.push(new PeopleItemInfo(_loc3_, _loc4_));
   ```
   
3. **PeopleItemInfo 构造函数**：
   ```actionscript
   public function PeopleItemInfo(param1:uint, param2:uint = 1)
   {
       this.id = param1;
       this.level = param2;  // 第二个参数是 level！
   }
   ```

**结论**：客户端把第二个字段当作 `level` 读取，而不是 `expireTime`！

### 为什么会出现 `_360000.swf` 后缀？

虽然我们还没有找到客户端中哪里把 `level` 当作文件名后缀使用，但可以确定：
- 服务器发送 `expireTime = 360000`
- 客户端读取为 `level = 360000`
- 某处代码可能把这个巨大的 level 值用作 `_curUrlType` 参数
- 导致尝试加载 `clothId_360000.swf`

### 为什么首次获得正常，第二次登录出问题？

1. **首次获得衣服**（通过任务奖励）：
   - 衣服被添加到 `items` 中
   - 此时还没有装备，`clothes` 数组为空
   - 登录响应：`clothCount = 0`，没有发送任何服装数据
   - 客户端正常工作 ✓

2. **用户换衣服**（CMD 2604）：
   - `handleChangeCloth` 保存为 `{id = clothId, level = 1}`
   - 数据库中：`"clothes": [{"id": 100027, "level": 1}]`
   - 此时正确 ✓

3. **第二次登录**：
   - 登录响应读取 `clothes` 数组
   - **之前的代码**：`local expireTime = cloth.expireTime or 0x057E40`
   - 因为 `cloth.expireTime` 不存在，使用默认值 `360000`
   - 发送给客户端：`clothId=100027, field2=360000`
   - 客户端读取为：`id=100027, level=360000`
   - 尝试加载 `100027_360000.swf` → 404 错误 ❌

## 修复方案

### 修改 seer_login_response.lua

**文件**：`luvit_version/gameserver/seer_login_response.lua`

```lua
-- 每件服装: id(4) + level(4)
-- 注意：客户端把第二个字段当作 level 读取，不是 expireTime！
for _, cloth in ipairs(clothes) do
    local clothId = cloth.id or cloth[1] or 0
    local level = cloth.level or 1  -- 默认等级为 1
    clothBuf:wuint(pos, clothId)
    pos = pos + 4
    clothBuf:wuint(pos, level)
    pos = pos + 4
end
```

**关键变化**：
- ❌ `local expireTime = cloth.expireTime or 0x057E40`
- ✅ `local level = cloth.level or 1`

### 更新协议验证器注释

**文件**：`luvit_version/protocol_validator.lua`

```lua
-- 每个cloth: id(4) + level(4) = 8 bytes
-- 注意：客户端把第二个字段当作 level 读取，不是 expireTime
```

## 官服行为分析

根据抓包分析，官服确实发送了 `0x00057E40 = 360000`。

**可能的解释**：
1. 官服的客户端版本可能不同，正确处理了这个字段
2. 官服可能有额外的逻辑来处理 expireTime
3. 我们的分析可能有误，需要进一步验证

**但是**：根据客户端源码（UserInfo.as 和 PeopleItemInfo.as），客户端明确把第二个字段当作 `level` 读取。

**结论**：为了兼容客户端源码，我们应该发送 `level`，而不是 `expireTime`。

## 测试验证

### 测试步骤

1. **清空用户数据**：
   ```json
   "clothes": []
   ```

2. **首次登录**：
   - 观察日志：`[LOGIN] 加载了 0 件服装`
   - 包体大小：1146 bytes ✓

3. **换衣服**：
   - 穿上一件衣服（如 100027）
   - 观察日志：`[LocalGame] 用户 X 服装已保存到数据库`
   - 数据库：`"clothes": [{"id": 100027, "level": 1}]` ✓

4. **第二次登录**：
   - 观察日志：`[LOGIN] 加载了 1 件服装`
   - 包体大小：1154 bytes (1146 + 8) ✓
   - **关键**：不应该出现 `100027_360000.swf` 的 404 错误 ✓

5. **查看客户端**：
   - 角色应该正确显示服装
   - 没有 404 错误

### 预期结果

- ✅ 登录响应发送 `level = 1`
- ✅ 客户端读取 `level = 1`
- ✅ 客户端加载 `100027.swf`（或 `100027_1.swf`，取决于具体逻辑）
- ✅ 没有 404 错误

## 实施日期

2026年1月17日

## 相关文档

- `CLOTH_PERSISTENCE_FIX.md` - 服装持久化修复
- `login_packet_structure_analysis.md` - 登录包结构分析
- `protocol_validator.lua` - 协议验证器
