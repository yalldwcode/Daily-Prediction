-- Daily Prediction mod
-- shows 3 random predictions each day when you open the menu
-- button sits next to the daily chest, resets at midnight

local cocos = geode.cocos2d
local modId = geode.Mod.getID()

local LEVEL_NAMES = {
    "Stereo Madness", "Back On Track", "Polargeist", "Dry Out", "Base After Base",
    "Cant Let Go", "Jumper", "Time Machine", "Cycles", "xStep",
    "Clutterfunk", "Theory of Everything", "Electroman Adventures", "Clubstep",
    "Theory of Everything 2", "Geometrical Dominator", "Deadlocked", "Fingerdash",
    "Dash", "Explorers", "Fingerbang", "Yatagarasu", "Bloodbath", "Crimson Clutter",
    "Sonic Wave", "Erebus", "Plasma Pulse Finale", "Acropolis", "Tartarus",
    "The Golden", "Bausha Vortex", "Sakupen Hell", "Phobos", "Zodiac",
    "Vicarious", "The Eschaton", "Firework", "Abyss of Darkness",
}

local TEMPLATES = {
    -- level stuff
    "gonna open <cy>{level}</c> real quick and die at <cr>{pct}%</c> for like an hour",
    "ur starting a <cy>{level}</c> arc today. it ends badly at <cr>{pct}%</c>",
    "you WILL convince yourself <cy>{level}</c> is passable after hitting <cg>{pct}%</c> once",
    "today on <cy>{level}</c>: <cr>{attempts} attempts</c>, zero progress, blaming the hitbox",
    "<cy>{level}</c> said no. specifically at <cr>{pct}%</c>. repeatedly.",
    "bro is waking up and doing <cr>{attempts} attempts</c> on <cy>{level}</c> before breakfast",
    "u get <cg>{pct}%</c> on <cy>{level}</c> and screenshot it like u beat it",
    "the <cy>{level}</c> arc is NOT going well. <cr>{pct}%</c> wall incoming",
    "<cy>{level}</c> is not it today. come back tomorrow. or dont. same result",
    "youre gonna die at <cr>{pct}%</c> on <cy>{level}</c> and say 'that doesnt count'",
    "new attempt on <cy>{level}</c>. new excuse ready. same death at <cr>{pct}%</c>",

    -- chest stuff
    "small chest is giving <cg>{orbs} orbs</c> today. yeah thats it. dont get excited",
    "u open the chest, get <cg>{orbs} orbs</c>, close the game, open it again for no reason",
    "the chest has <cg>{shards} shards</c> and <cg>{orbs} orbs</c> in it. life changing. not really",
    "<cg>{orbs} orbs</c> from the chest today. u already forgot about it didnt u",
    "daily chest drop: <cg>{orbs} orbs</c>. u will spend them on something stupid",
    "its giving <cg>{orbs} orbs</c>. the chest said 'here, have nothing basically'",

    -- gameplay moments
    "dying at <cr>1%</c> is on the schedule. block it off",
    "there is a coin somewhere u have never seen. today it finds u first",
    "practice mode is going worse than normal mode today and u will not understand why",
    "u said 10 minutes. its been <cr>{attempts}</c> minutes. the forecast was correct",
    "'one more attempt' will be said at least <cr>{attempts} times</c> tonight. minimum",
    "new best incoming. followed immediately by the worst attempt of your life",
    "the level clicks after <cg>{attempts} attempts</c> and u feel like a god for 4 seconds",
    "the jump at <cr>{pct}%</c> has your name on it today",
    "a run is happening. it goes great. u tab out right before the end. classic",
    "practice run. perfect. normal run. dies at <cr>{pct}%</c>. skill issue.",
    "u already know which part is gonna kill u. and youre right",

    -- unhinged ones
    "the GD gods want <cr>{attempts} attempts</cr> as tribute before they let u pass",
    "geometry is NOT dashing today. try again when mercury stops doing its thing",
    "the stars said <cy>maybe</c> and honestly thats the most honest thing ive ever heard",
    "ur energy today: started confident, ended in the settings menu for no reason",
    "something is off about ur timing today and u will spend way too long figuring out what",
    "dies at <cr>{pct}%</c>. blames internet. closes game. reopens game. dies at <cr>{pct}%</c>",
    "prediction: u have fun. actual outcome: debatable",
    "u will open the level browser, scroll for 10 minutes, and play the same level anyway",
    "todays vibe is <cy>one good run surrounded by disasters</c>. stay patient king",
    "ur fingers are cooked today. tomorrow is a different story though",
}

-- same seed all day, resets at midnight
local function getDaySeed(): number
    return math.floor(os.time() / 86400)
end

-- lcg so each slot gets different values from the same day seed
local function seededRandom(seed: number, index: number): number
    local s = (seed * 1664525 + index * 22695477 + 1013904223) % (2 ^ 32)
    s = (s * 1664525 + 1013904223) % (2 ^ 32)
    return s / (2 ^ 32)
end

local function seededInt(seed: number, index: number, min: number, max: number): number
    return math.floor(seededRandom(seed, index) * (max - min + 1)) + min
end

local function seededPick(seed: number, index: number, tbl: {any}): any
    return tbl[seededInt(seed, index, 1, #tbl)]
end

local function fillTemplate(template: string, seed: number, slot: number): string
    local base = slot * 100
    local level    = seededPick(seed, base + 1, LEVEL_NAMES)
    local pct      = seededInt(seed, base + 2, 1, 97)
    local attempts = seededInt(seed, base + 3, 3, 99)
    local orbs     = seededInt(seed, base + 4, 30, 200)
    local shards   = seededInt(seed, base + 5, 1, 5)

    local out = template
    out = out:gsub("{level}",    level)
    out = out:gsub("{pct}",      tostring(pct))
    out = out:gsub("{attempts}", tostring(attempts))
    out = out:gsub("{orbs}",     tostring(orbs))
    out = out:gsub("{shards}",   tostring(shards))
    return out
end

local function getTodaysPredictions(): {string}
    local seed = getDaySeed()
    local results = {}
    local used = {}

    for slot = 1, 3 do
        local pick
        local tries = 0
        repeat
            tries += 1
            pick = TEMPLATES[seededInt(seed, slot * 1000 + tries, 1, #TEMPLATES)]
        until not used[pick] or tries > 20
        used[pick] = true
        table.insert(results, fillTemplate(pick, seed, slot))
    end

    return results
end

local function showPredictions()
    local preds = getTodaysPredictions()
    local body = "<cy>todays predictions</c>\n\n"
        .. "① " .. preds[1] .. "\n\n"
        .. "② " .. preds[2] .. "\n\n"
        .. "③ " .. preds[3]

    FLAlertLayer.create("Daily Prediction", body, "ok"):show()
end

local function shouldShowToday(): boolean
    local saved = geode.Mod.getSavedValue("lastShownDay")
    return saved ~= tostring(getDaySeed())
end

local function markShownToday()
    geode.Mod.setSavedValue("lastShownDay", tostring(getDaySeed()))
end

local shownThisSession = false

geode.hook("geode.gd.MenuLayer:init/0", {
    after = function(self, result)
        if not result then return result end

        local menu = self:getChildByID("bottom-menu")
        if not menu then return result end

        local sprite = cocos.CCSprite.createWithSpriteFrameName("GJ_starsIcon_001.png")
        if not sprite then
            sprite = cocos.CCSprite.createWithSpriteFrameName("GJ_bigStar_001.png")
        end
        if not sprite then return result end

        sprite:setScale(0.9)

        local button = CCMenuItemSpriteExtra.create(
            sprite,
            self,
            menu_selector(function(_self, _sender)
                showPredictions()
            end)
        )

        if not button then return result end

        button:setID(modId .. "/prediction-button")
        menu:addChild(button)
        menu:updateLayout()

        if not shownThisSession and shouldShowToday() then
            shownThisSession = true
            markShownToday()
            task.delay(0.4, function()
                showPredictions()
            end)
        end

        return result
    end,
})

print("[daily-prediction] loaded, day seed = " .. tostring(getDaySeed()))
