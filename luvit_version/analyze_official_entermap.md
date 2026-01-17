# 官服 ENTER_MAP 数据分析

## 官服房间服务器 ENTER_MAP 响应

### 第一次进入（未装备衣服）
```
[←官服房间] CMD 2001 (ENTER_MAP) UID=516982 LEN=161
HEX: 69 6B 93 5E 00 07 E3 76 E9 BB 91 E8 89 B2 E8 B5 9B E5 B0 94 E4 BA BA 00 00 00 00 00 00 00 00 00 00 00 00 0F 00 00 00 00 00 00 00 00 00 00 00 AD 00 00 01 52 00 00 00 00 00 00 00 02 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 01 00 00 00 00 00 00 00 00 00 00 00 01 00 FF FF FF 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
```
- 总长度: 161 bytes = 17 (header) + 144 (body)
- clothCount: 0

### 换衣服后再次进入（装备2件衣服）
```
[←官服房间] CMD 2001 (ENTER_MAP) UID=516982 LEN=177
HEX: 69 6B 94 89 00 07 E3 76 E9 BB 91 E8 89 B2 E8 B5 9B E5 B0 94 E4 BA BA 00 00 00 00 00 00 00 00 00 00 00 00 0F 00 00 00 00 00 00 00 00 00 00 00 AD 00 00 01 52 00 00 00 00 00 00 00 02 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 01 00 00 00 00 00 00 00 00 00 00 00 01 00 FF FF FF 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 02 00 01 86 BB 00 00 00 01 00 01 86 BC 00 00 00 01 00 00 00 00
```
- 总长度: 177 bytes = 17 (header) + 160 (body)
- 160 = 144 (base) + 16 (2 clothes * 8 bytes)
- clothCount: 2
- cloth1: id=100027 (0x000186BB), level=1
- cloth2: id=100028 (0x000186BC), level=1

## 字节分析 (基础 144 bytes)

```
偏移  字段                值 (HEX)              值 (DEC)        说明
----  ----------------  --------------------  --------------  --------
0     sysTime           69 6B 93 5E           1768813406      时间戳
4     userID            00 07 E3 76           516982          用户ID
8     nick              E9 BB 91 E8 89 B2...  "黑色赛尔人"    昵称(16字节)
24    color             00 00 00 0F           15              颜色
28    texture           00 00 00 00           0               纹理
32    vipFlags          00 00 00 00           0               VIP标志
36    vipStage          00 00 00 AD           173             VIP等级
40    actionType        00 00 01 52           338             动作类型
44    posX              00 00 00 00           0               X坐标
48    posY              00 00 00 02           2               Y坐标
52    action            00 00 00 00           0               动作
56    direction         00 00 00 00           0               方向
60    changeShape       00 00 00 00           0               变形
64    spiritTime        00 00 00 00           0               精灵时间
68    spiritID          00 00 00 00           0               精灵ID
72    petDV             00 00 00 01           1               精灵DV
76    petSkin           00 00 00 00           0               精灵皮肤
80    fightFlag         00 00 00 00           0               战斗标志
84    teacherID         00 00 00 01           1               导师ID
88    studentID         00 FF FF FF           16777215        学生ID
92    nonoState         00 00 00 00           0               NONO状态
96    nonoColor         00 00 00 00           0               NONO颜色
100   superNono         00 00 00 00           0               超级NONO
104   playerForm        00 00 00 00           0               玩家形态
108   transTime         00 00 00 00           0               变形时间
112   teamId            00 00 00 00           0               战队ID
116   coreCount         00 00 00 00           0               核心数量
120   isShow            00 00 00 00           0               是否显示
124   logoBg            00 00                 0               Logo背景
126   logoIcon          00 00                 0               Logo图标
128   logoColor         00 00                 0               Logo颜色
130   txtColor          00 00                 0               文字颜色
132   logoWord          00 00 00 00           ""              Logo文字(4字节)
136   clothCount        00 00 00 02           2               衣服数量
140   [clothes]         ...                   ...             衣服列表 (clothCount * 8)
...   curTitle          00 00 00 00           0               当前称号
```

## 关键发现 ⭐

**官服房间服务器的衣服数据发送逻辑**：
1. **有衣服时**：发送完整的衣服数据（clothCount > 0）
2. **无衣服时**：clothCount = 0，不发送衣服列表

**之前的错误理解**：
- ❌ 以为房间服务器永远不发送衣服数据（clothCount=0）
- ✅ 实际上房间服务器会根据用户是否装备衣服来决定

## 协议格式

### ENTER_MAP (CMD 2001) - 房间服务器
```
基础数据: 136 bytes
clothCount: 4 bytes
衣服列表: clothCount * 8 bytes (每件: clothId(4) + level(4))
curTitle: 4 bytes

总大小: 144 + clothCount * 8 bytes
```

### LIST_MAP_PLAYER (CMD 2003) - 房间服务器
```
count: 4 bytes
玩家列表: count * (144 + clothCount * 8) bytes

例如1个玩家2件衣服: 4 + 160 = 164 bytes body (181 bytes total)
```

## 对比官服地图服务器 ENTER_MAP

官服在地图服务器中也会发送衣服数据，格式完全相同：
- 基础: 144 bytes
- 衣服: clothCount * 8 bytes
- 例如: 5件衣服 = 144 + 40 = 184 bytes

## 结论

房间服务器和地图服务器的 ENTER_MAP 格式完全一致：
- 144 bytes 基础数据
- clothCount 字段
- 衣服列表（如果有）
- curTitle 字段
- **区别只在于是否有衣服数据，格式本身相同**
