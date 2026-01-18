# GET_PET_INFO (CMD 2301) 协议分析

## 官服响应数据

```
[←官服房间] CMD 2301 (GET_PET_INFO) UID=516982 LEN=171
HEX: 00 00 00 07 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 1F 00 00 00 15 00 00 00 05 00 00 00 08 00 00 00 6A 00 00 00 72 00 00 00 12 00 00 00 14 00 00 00 0C 00 00 00 0A 00 00 00 0C 00 00 00 0A 00 00 00 0C 00 00 00 00 00 00 00 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 02 00 00 4E 24 00 00 00 1D 00 00 27 16 00 00 00 22 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 69 69 E0 DA 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
```

总长度: 171 bytes = 17 (header) + 154 (body)

## 字节分析 (154 bytes body)

```
偏移  字段              值 (HEX)        值 (DEC)    说明
----  --------------  --------------  ----------  --------
0     id              00 00 00 07     7           精灵ID (伊优)
4     name            00 00 00 00...  ""          名字 (16字节，空)
20    dv              00 00 00 1F     31          个体值
24    nature          00 00 00 15     21          性格
28    level           00 00 00 05     5           等级
32    exp             00 00 00 08     8           总经验
36    lvExp           00 00 00 6A     106         当前等级经验
40    nextLvExp       00 00 00 72     114         升级所需经验
44    hp              00 00 00 12     18          当前HP
48    maxHp           00 00 00 14     20          最大HP
52    attack          00 00 00 0C     12          攻击
56    defence         00 00 00 0A     10          防御
60    s_a             00 00 00 0C     12          特攻
64    s_d             00 00 00 0A     10          特防
68    speed           00 00 00 0C     12          速度
72    ev_hp           00 00 00 00     0           HP努力值
76    ev_attack       00 00 00 01     1           攻击努力值
80    ev_defence      00 00 00 00     0           防御努力值
84    ev_sa           00 00 00 00     0           特攻努力值
88    ev_sd           00 00 00 00     0           特防努力值
92    ev_sp           00 00 00 00     0           速度努力值
96    skillNum        00 00 00 02     2           技能数量 (实际有效技能)
100   skill1_id       00 00 4E 24     20004       技能1 ID
104   skill1_pp       00 00 00 1D     29          技能1 PP
108   skill2_id       00 00 27 16     10006       技能2 ID
112   skill2_pp       00 00 00 22     34          技能2 PP
116   skill3_id       00 00 00 00     0           技能3 ID (空)
120   skill3_pp       00 00 00 00     0           技能3 PP
124   skill4_id       00 00 00 00     0           技能4 ID (空)
128   skill4_pp       00 00 00 00     0           技能4 PP
132   catchTime       69 69 E0 DA     1768284378  捕获时间戳
136   catchMap        00 00 00 00     0           捕获地图
140   catchRect       00 00 00 00     0           捕获区域
144   catchLevel      00 00 00 00     0           捕获等级
148   effectCount     00 00           0           特效数量 (2字节)
150   skinID          00 00 00 00     0           皮肤ID (4字节)
```

## 关键发现

### 1. skillNum 字段的含义 ⭐
- **官服**: skillNum = 2 (实际有效技能数量)
- **本地修复前**: skillNum = 4 (固定值，总是4个槽位)
- **本地修复后**: skillNum = 实际技能数量 ✓

**官服逻辑**：
- skillNum 表示实际学会的技能数量
- 但仍然发送4个技能槽的数据
- 空槽位的 id=0, pp=0

### 2. 技能PP值
- 官服: skill1_pp=29, skill2_pp=34 (使用后的值)
- 本地修复后: 从 skills.xml 读取默认PP值 ✓

### 3. 捕获信息 ⭐
- catchTime: 实际捕获时间戳
- catchMap: **0** (不是301)
- catchRect: 0
- catchLevel: **0** (不是petLevel)

**本地修复**：
- ✓ catchMap 改为 0
- ✓ catchLevel 改为 0

### 4. effectCount 是 2 字节
- 官服: `00 00` (2 bytes)
- 本地: 使用 writeUInt16BE(0) ✓ 正确

### 5. 总大小
- 官服: 154 bytes
- 本地实现: 154 bytes ✓

## 已修复的问题

### ✓ 问题1: skillNum 改为实际技能数量
```lua
-- 计算实际技能数量（官服格式）
local actualSkillCount = 0
for i = 1, 4 do
    local skillId = skills[i] or 0
    if type(skillId) == "table" then
        skillId = skillId.id or 0
    end
    if skillId ~= 0 then
        actualSkillCount = actualSkillCount + 1
    end
end
responseBody = responseBody .. writeUInt32BE(actualSkillCount)  -- skillNum
```

### ✓ 问题2: catchMap 改为 0
```lua
responseBody = responseBody .. writeUInt32BE(0)  -- catchMap (官服为0)
```

### ✓ 问题3: catchLevel 改为 0
```lua
responseBody = responseBody .. writeUInt32BE(0)  -- catchLevel (官服为0)
```

### ✓ 问题4: 技能PP值从数据读取
```lua
-- 获取技能的默认PP值
local skillPP = 0
if skillId ~= 0 then
    local skillInfo = SeerSkills.get(skillId)
    skillPP = (skillInfo and skillInfo.pp) or 30
end
```

## 协议格式总结

```
PetInfo (完整版, param2=true):
- id(4) + name(16) + dv(4) + nature(4) + level(4) + exp(4) + lvExp(4) + nextLvExp(4)
- hp(4) + maxHp(4) + attack(4) + defence(4) + s_a(4) + s_d(4) + speed(4)
- ev_hp(4) + ev_attack(4) + ev_defence(4) + ev_sa(4) + ev_sd(4) + ev_sp(4)
- skillNum(4) + [skill_id(4) + skill_pp(4)] * 4
- catchTime(4) + catchMap(4) + catchRect(4) + catchLevel(4)
- effectCount(2) + [effectList...] + skinID(4)

总大小: 154 bytes (当 effectCount=0 时)
```

## 修复日期

2026年1月17日
