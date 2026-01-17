# LOGIN_IN 包体大小精确计算

## 字段列表（按顺序）

### 基本信息 (basic)
```
userID:          4
regTime:         4
nick:           16
vipFlags:        4
dsFlag:          4
color:           4
texture:         4
energy:          4
coins:           4
fightBadge:      4
mapID:           4
posX:            4
posY:            4
timeToday:       4
timeLimit:       4
4 booleans:      4
loginCnt:        4
inviter:         4
newInviteeCnt:   4
vipLevel:        4
vipValue:        4
vipStage:        4
autoCharge:      4
vipEndTime:      4
freshManBonus:   4
小计:          120 bytes
```

### nonoChipList
```
80 bytes
```

### dailyResArr
```
50 bytes
```

### teacherID ~ fuseTimes (buf)
```
teacherID:           4
studentID:           4
graduationCount:     4
maxPuniLv:           4
petMaxLev:           4
petAllNum:           4
monKingWin:          4
curStage:            4
maxStage:            4
curFreshStage:       4
maxFreshStage:       4
maxArenaWins:        4
twoTimes:            4
threeTimes:          4
autoFight:           4
autoFightTimes:      4
energyTimes:         4
learnTimes:          4
monBtlMedal:         4
recordCnt:           4
obtainTm:            4
soulBeadItemID:      4
expireTm:            4
fuseTimes:           4
小计:               96 bytes
```

### hasNono ~ nonoNick (nonoBuf)
```
hasNono:         4
superNono:       4
nonoState:       4
nonoColor:       4
nonoNick:       16
小计:           32 bytes
```

### TeamInfo
```
24 bytes
```

### TeamPKInfo
```
8 bytes
```

### 1 byte + badge + reserved
```
32 bytes
```

### TasksManager
```
500 bytes
```

### PetManager
```
petNum:          4 bytes
```

### Clothes
```
clothCount:      4 bytes
clothes数据:     clothCount * 8 bytes
```

### curTitle
```
4 bytes
```

### bossAchievement
```
200 bytes
```

## 总计（0件衣服）

```
基本信息:        120
nonoChipList:     80
dailyResArr:      50
buf:              96
nonoBuf:          32
TeamInfo:         24
TeamPKInfo:        8
reserved:         32
TasksManager:    500
PetManager:        4
clothCount:        4
clothes:           0
curTitle:          4
bossAchievement: 200
-------------------
总计:           1154 bytes
```

**但是实际 minSize 是 1146 bytes，差了 8 bytes！**

## 问题排查

让我检查代码中是否有字段被跳过或大小不对...

可能的问题：
1. TeamInfo 实际是 16 bytes 而不是 24 bytes？
2. reserved 实际是 24 bytes 而不是 32 bytes？
3. 某些字段没有发送？
