-- 赛尔号任务配置
-- 集中管理任务奖励、条件和特殊逻辑

local SeerTaskConfig = {}

-- 任务定义
SeerTaskConfig.Tasks = {
    -- ==================== 新手任务 ====================
    -- 任务85: 领取服装 (0x55)
    [85] = {
        name = "新手礼物",
        rewards = {
            items = {
                {id = 100027, count = 1},  -- 0x0186BB 服装
                {id = 100028, count = 1},  -- 0x0186BC 服装
                {id = 500001, count = 1},  -- 0x07A121
                {id = 300650, count = 3},  -- 0x04966A
                {id = 300025, count = 3},  -- 0x0493F9
                {id = 300035, count = 3},  -- 0x049403
                {id = 500502, count = 1},  -- 0x07A316
                {id = 500503, count = 1},  -- 0x07A317
            }
        }
    },
    
    -- 任务86: 选择精灵 (0x56)
    -- 特殊逻辑: 需要根据 param 参数选择获得的精灵
    [86] = {
        name = "初次伙伴",
        type = "select_pet",
        -- 映射: 客户端参数 -> 精灵ID
        -- 1=布布种子(1), 2=小火猴(7), 3=伊优(4)
        paramMap = {
            [1] = 1,
            [2] = 7,
            [3] = 4
        }
    },
    
    -- 任务87: 战斗胜利 (0x57)
    [87] = {
        name = "初试身手",
        rewards = {
            items = {
                {id = 300001, count = 5},  -- 0x0493E1 精灵胶囊
                {id = 300011, count = 3},  -- 0x0493EB 体力药剂
                -- 任务处理代码中写的是2个物品，但handler里有3个(300006)，这里统一用handler的还是server的？
                -- server用的是 300001(5) 和 300011(3)
                -- 暂时保持 server 的逻辑
            }
        }
    },
    
    -- 任务88: 使用道具 (0x58)
    [88] = {
        name = "治愈伤痛",
        rewards = {
            coins = 50000,
            -- 还有经验等，暂时用 items 模拟特殊奖励，或者在 handler 特殊处理
            -- 官服返回: 1=50000(金币), 3=250000(经验?), 5=20(?)
            special = {
                {type = 1, value = 50000},
                {type = 3, value = 250000},
                {type = 5, value = 20},
            }
        }
    }
}

-- 获取任务配置
function SeerTaskConfig.get(taskId)
    return SeerTaskConfig.Tasks[taskId]
end

return SeerTaskConfig
