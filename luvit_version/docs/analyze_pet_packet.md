# 精灵数据包分析

## Hex Dump 分析 (从 0x3A8 开始)

```
03A0: ... 00 00 00 00 00 01 00 00 00 07 00 00
03B0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
03C0: 00 1F 00 00 00 18 00 00 00 05 00 00 00 00 00 00
03D0: 00 00 00 00 00 5B 00 00 00 1A 00 00 00 1A 00 00
03E0: 00 0C 00 00 00 0A 00 00 00 0C 00 00 00 0A 00 00
03F0: 00 0C 00 00 00 00 00 00 00 00 00 00 00 00 00 00
0400: 00 00 00 00 00 00 00 00 00 00 00 00 00 02 00 00
0410: 27 16 00 00 00 23 00 00 00 23 00 00 4E 24 00 00
0420: 00 1E 00 00 00 1E 00 00 00 00 00 00 00 00 00 00
0430: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 69 69
0440: C4 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
0450: 00 00 00 00 00 00 00 03
```

## 字段解析

### petNum (0x3A8-0x3AB)
- Bytes: `00 01 00 00`
- Value: 1
- ✓ 正确

### PetInfo 开始 (0x3AC)

#### id (0x3AC-0x3AF) - 4 bytes
- Bytes: `00 07 00 00`
- Value: 7
- ✓ 正确

#### name (0x3B0-0x3BF) - 16 bytes
- Bytes: `00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00`
- Value: 空字符串
- ✓ 正确

#### dv (0x3C0-0x3C3) - 4 bytes
- Bytes: `00 1F 00 00`
- Value: 31 (0x1F)
- ✓ 正确

#### nature (0x3C4-0x3C7) - 4 bytes
- Bytes: `00 18 00 00`
- Value: 24 (0x18)
- ✓ 正确

#### level (0x3C8-0x3CB) - 4 bytes
- Bytes: `00 05 00 00`
- Value: 5
- ✓ 正确

#### exp (0x3CC-0x3CF) - 4 bytes
- Bytes: `00 00 00 00`
- Value: 0
- ✓ 正确

#### lvExp (0x3D0-0x3D3) - 4 bytes
- Bytes: `00 00 00 00`
- Value: 0
- ✓ 正确

#### nextLvExp (0x3D4-0x3D7) - 4 bytes
- Bytes: `00 5B 00 00`
- Value: 91 (0x5B)
- ✓ 正确

#### hp (0x3D8-0x3DB) - 4 bytes
- Bytes: `00 1A 00 00`
- Value: 26 (0x1A)
- ✓ 正确

#### maxHp (0x3DC-0x3DF) - 4 bytes
- Bytes: `00 1A 00 00`
- Value: 26
- ✓ 正确

#### attack (0x3E0-0x3E3) - 4 bytes
- Bytes: `00 0C 00 00`
- Value: 12 (0x0C)
- ✓ 正确

#### defence (0x3E4-0x3E7) - 4 bytes
- Bytes: `00 0A 00 00`
- Value: 10 (0x0A)
- ✓ 正确

#### s_a (0x3E8-0x3EB) - 4 bytes
- Bytes: `00 0C 00 00`
- Value: 12
- ✓ 正确

#### s_d (0x3EC-0x3EF) - 4 bytes
- Bytes: `00 0A 00 00`
- Value: 10
- ✓ 正确

#### speed (0x3F0-0x3F3) - 4 bytes
- Bytes: `00 0C 00 00`
- Value: 12
- ✓ 正确

#### ev_hp (0x3F4-0x3F7) - 4 bytes
- Bytes: `00 00 00 00`
- Value: 0
- ✓ 正确

#### ev_attack (0x3F8-0x3FB) - 4 bytes
- Bytes: `00 00 00 00`
- Value: 0
- ✓ 正确

#### ev_defence (0x3FC-0x3FF) - 4 bytes
- Bytes: `00 00 00 00`
- Value: 0
- ✓ 正确

#### ev_sa (0x400-0x403) - 4 bytes
- Bytes: `00 00 00 00`
- Value: 0
- ✓ 正确

#### ev_sd (0x404-0x407) - 4 bytes
- Bytes: `00 00 00 00`
- Value: 0
- ✓ 正确

#### ev_sp (0x408-0x40B) - 4 bytes
- Bytes: `00 00 00 00`
- Value: 0
- ✓ 正确

#### skillNum (0x40C-0x40F) - 4 bytes
- Bytes: `00 02 00 00`
- Value: 2
- ✓ 正确

#### Skill 1 (0x410-0x41B) - 12 bytes
- skillId (0x410-0x413): `27 16 00 00` = 0x00001627 = 5671
- ❌ **错误！** 应该是 `00 00 27 16` = 0x00002716 = 10006
- pp (0x414-0x417): `00 23 00 00` = 35
- maxPP (0x418-0x41B): `00 23 00 00` = 35

#### Skill 2 (0x41C-0x427) - 12 bytes
- skillId (0x41C-0x41F): `00 4E 24 00` = 0x00244E00 = 2379264
- ❌ **错误！** 应该是 `00 00 4E 24` = 0x00004E24 = 20004
- pp (0x420-0x423): `00 1E 00 00` = 30
- maxPP (0x424-0x427): `00 1E 00 00` = 30

## 问题发现

**技能ID的字节序错误！**

期望的字节序（little-endian）：
- Skill 1 ID: 10006 = 0x2716 → `16 27 00 00`
- Skill 2 ID: 20004 = 0x4E24 → `24 4E 00 00`

实际发送的字节序：
- Skill 1: `27 16 00 00` (big-endian的前两个字节)
- Skill 2: `4E 24 00 00` (big-endian的前两个字节)

这说明 `buf:wuint()` 在写入技能ID时使用了错误的字节序！

## 其他字段继续验证

#### Skill 3 (empty) (0x428-0x433) - 12 bytes
- All zeros ✓

#### Skill 4 (empty) (0x434-0x43F) - 12 bytes
- All zeros ✓

#### catchTime (0x440-0x443) - 4 bytes
- Bytes: `69 69 C4 00`
- Value (little-endian): 0x00C46969 = 12,953,961
- Expected: 1768539136 = 0x6969C400
- Expected bytes (little-endian): `00 C4 69 69`
- ❌ **错误！** 字节序完全颠倒

#### catchMap (0x444-0x447) - 4 bytes
- Bytes: `00 00 00 00`
- Value: 0
- ✓ 正确（默认值）

#### catchRect (0x448-0x44B) - 4 bytes
- Bytes: `00 00 00 00`
- Value: 0
- ✓ 正确

#### catchLevel (0x44C-0x44F) - 4 bytes
- Bytes: `00 00 00 00`
- Value: 0
- ❌ **错误！** 应该是 5（精灵等级）

#### effectCount (0x450-0x451) - 2 bytes
- Bytes: `00 00`
- Value: 0
- ✓ 正确

#### skinID (0x452-0x455) - 4 bytes
- Bytes: `00 00 00 03`
- Value: 3
- ❌ **错误！** 应该是 0

等等，这里的偏移量不对了。让我重新计算...

实际上从 0x450 开始应该是 clothes 数据了，不是 effectCount！

## 重新分析

PetInfo 应该在 effectCount 之后结束。让我重新计算大小：

- 基础字段到 ev_sp: 4 + 16 + 19*4 = 96 bytes
- skillNum + 4 skills: 4 + 4*12 = 52 bytes
- catchTime, catchMap, catchRect, catchLevel: 4*4 = 16 bytes
- effectCount: 2 bytes
- skinID: 4 bytes

总计: 96 + 52 + 16 + 2 + 4 = 170 bytes

从 0x3AC 开始，170 bytes 后应该在 0x3AC + 0xAA = 0x456

但是 clothes 数据在 0x450 开始（`00 03` = 3件衣服）

0x450 - 0x3AC = 0xA4 = 164 bytes

**少了 6 bytes！**

## 结论

PetInfo 序列化有严重问题：
1. 技能ID字节序错误（big-endian vs little-endian）
2. catchTime字节序错误
3. 整体大小不对，少了6个字节
4. 可能是 effectCount (2 bytes) + skinID (4 bytes) 没有正确写入
