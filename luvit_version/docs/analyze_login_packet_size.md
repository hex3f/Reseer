# LOGIN_IN 包体大小分析

## 问题
```
[LOGIN] 加载了 2 件服装
[LOGIN] 响应包大小: 1162 bytes
❌ [LOGIN_IN] 包体大小不匹配: 期望1146字节, 实际1162字节
差异: +16 bytes
```

## 衣服数据位置分析

从 HEX dump 中找到衣服数据：
```
03A0: 00 00 00 00 00 00 00 00 00 00 00 00 00 02 00 01
03B0: 86 BC 00 05 7E 40 00 01 86 BB 00 05 7E 40 00 00
```

偏移 0x3AC (940): `00 02` = clothCount = 2
偏移 0x3AE (942): `00 01 86 BC` = cloth1.id = 100028
偏移 0x3B2 (946): `00 05 7E 40` = cloth1.??? = 360000
偏移 0x3B6 (950): `00 01 86 BB` = cloth2.id = 100027
偏移 0x3BA (954): `00 05 7E 40` = cloth2.??? = 360000

## 衣服数据格式问题 ⭐

### 当前实现（错误）
```
clothCount(4) + [clothId(4) + ???(4)] * count
每件衣服: 8 bytes
2件衣服: 4 + 16 = 20 bytes
```

### 正确格式（应该是）
```
clothCount(4) + [clothId(4)] * count
每件衣服: 4 bytes
2件衣服: 4 + 8 = 12 bytes
```

### 差异
- 当前: 20 bytes
- 正确: 12 bytes
- 多了: 8 bytes

**但是实际差异是 16 bytes，说明还有其他问题！**

## 重新分析

让我看看 protocol_validator.lua 中的定义：

```lua
[1001] = {
    name = "LOGIN_IN",
    minSize = 1146,
    maxSize = nil,  -- 动态大小
}
```

基础大小: 1146 bytes

### 衣服数据应该在哪里？

根据客户端代码，LOGIN_IN 响应包含：
1. UserInfo (固定大小)
2. 其他数据...
3. clothCount(4) + clothes数据

### 可能的问题

1. **衣服数据格式错误** - 每件衣服占用的字节数不对
2. **衣服数据位置错误** - 插入了额外的字段
3. **其他字段大小错误** - 某些字段比预期大

## 需要检查的地方

1. `seer_login_response.lua` 中的 `makeLoginResponse` 函数
2. 衣服数据的格式：是 `clothId(4)` 还是 `clothId(4) + level(4)`？
3. 对比官服的登录包格式
