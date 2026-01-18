# LOGIN_IN 包体结构详细分析

## 实际数据

```
总大小: 1162 bytes
clothCount: 2
期望: 1146 bytes (0件衣服时)
差异: +16 bytes = 2 * 8 bytes
```

## HEX Dump 关键位置

### clothCount 位置
```
03A0: 00 00 00 00 00 00 00 00 00 00 00 00 00 02 00 01
                                            ^^^^^ clothCount=2
偏移: 0x3AC = 940 (decimal)
```

### 衣服数据
```
03A0: ... 00 02 00 01 86 BC 00 05 7E 40 00 01 86 BB 00 05 7E 40
          ^^^^^ ^^^^^^^^^^^ ^^^^^^^^^^^ ^^^^^^^^^^^ ^^^^^^^^^^^
          count cloth1_id   cloth1_exp  cloth2_id   cloth2_exp
```

- 偏移 940-943: clothCount = 2
- 偏移 944-947: cloth1.id = 0x000186BC = 100028
- 偏移 948-951: cloth1.expireTime = 0x00057E40 = 360000
- 偏移 952-955: cloth2.id = 0x000186BB = 100027
- 偏移 956-959: cloth2.expireTime = 0x00057E40 = 360000

### 衣服数据后面
```
03B0: ... 7E 40 00 00 00 00 00 00 00 00 00 00 00 00 00 00
          ^^^^^ ^^^^^^^^^^^ curTitle?
偏移 960-963: 0x00000000 (可能是 curTitle)
```

## 计算验证

### 0件衣服时
```
基础部分: 940 bytes (到 clothCount 之前)
clothCount: 4 bytes
衣服数据: 0 bytes
curTitle: 4 bytes
bossAchievement: 200 bytes
总计: 940 + 4 + 0 + 4 + 200 = 1148 bytes
```

**但是 minSize 是 1146，差了 2 bytes！**

### 2件衣服时
```
基础部分: 940 bytes
clothCount: 4 bytes
衣服数据: 16 bytes (2 * 8)
curTitle: 4 bytes
bossAchievement: 200 bytes
总计: 940 + 4 + 16 + 4 + 200 = 1164 bytes
```

**但是实际是 1162 bytes，差了 2 bytes！**

## 问题分析

差异是 2 bytes，可能的原因：

1. **bossAchievement 不是 200 bytes，而是 198 bytes**
2. **curTitle 不是 4 bytes，而是 2 bytes**
3. **基础部分不是 940 bytes，而是 942 bytes**

## 重新计算

### 假设 bossAchievement = 198 bytes
```
0件衣服: 940 + 4 + 0 + 4 + 198 = 1146 ✓
2件衣服: 940 + 4 + 16 + 4 + 198 = 1162 ✓
```

**这个匹配！**

### 或者假设 curTitle = 2 bytes
```
0件衣服: 940 + 4 + 0 + 2 + 200 = 1146 ✓
2件衣服: 940 + 4 + 16 + 2 + 200 = 1162 ✓
```

**这个也匹配！**

## 验证方法

查看 seer_login_response.lua 中：
1. curTitle 的大小
2. bossAchievement 的大小

## 结论

需要检查实际代码中 curTitle 和 bossAchievement 的大小。
