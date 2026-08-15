return function(mod)
    ------------------------------------------------------------
    -- CRY PACKS
    -- assets/Anime/1.ogg … 151.ogg
    -- assets/FireRed/1.ogg … 151.ogg
    --
    -- Yellow Pikachu emotions (PCM clips):
    --   assets/<pack>/pika/<emotion>.ogg
    --   e.g. assets/Anime/pika/confused.ogg
    -- Fallback: pika/default.ogg → 25.ogg → vanilla PCM
    ------------------------------------------------------------

    local CHOICES = {
        { "ORIGINAL", "original" },
        { "ANIME", "Anime" },
        { "FIRE RED", "FireRed" },
    }

    local EXT = ".ogg"

    local STARTER_DEX = { 1, 4, 7 }

    local SPECIES = {
        "BULBASAUR", "IVYSAUR", "VENUSAUR",
        "CHARMANDER", "CHARMELEON", "CHARIZARD",
        "SQUIRTLE", "WARTORTLE", "BLASTOISE",
        "CATERPIE", "METAPOD", "BUTTERFREE",
        "WEEDLE", "KAKUNA", "BEEDRILL",
        "PIDGEY", "PIDGEOTTO", "PIDGEOT",
        "RATTATA", "RATICATE",
        "SPEAROW", "FEAROW",
        "EKANS", "ARBOK",
        "PIKACHU", "RAICHU",
        "SANDSHREW", "SANDSLASH",
        "NIDORAN_F", "NIDORINA", "NIDOQUEEN",
        "NIDORAN_M", "NIDORINO", "NIDOKING",
        "CLEFAIRY", "CLEFABLE",
        "VULPIX", "NINETALES",
        "JIGGLYPUFF", "WIGGLYTUFF",
        "ZUBAT", "GOLBAT",
        "ODDISH", "GLOOM", "VILEPLUME",
        "PARAS", "PARASECT",
        "VENONAT", "VENOMOTH",
        "DIGLETT", "DUGTRIO",
        "MEOWTH", "PERSIAN",
        "PSYDUCK", "GOLDUCK",
        "MANKEY", "PRIMEAPE",
        "GROWLITHE", "ARCANINE",
        "POLIWAG", "POLIWHIRL", "POLIWRATH",
        "ABRA", "KADABRA", "ALAKAZAM",
        "MACHOP", "MACHOKE", "MACHAMP",
        "BELLSPROUT", "WEEPINBELL", "VICTREEBEL",
        "TENTACOOL", "TENTACRUEL",
        "GEODUDE", "GRAVELER", "GOLEM",
        "PONYTA", "RAPIDASH",
        "SLOWPOKE", "SLOWBRO",
        "MAGNEMITE", "MAGNETON",
        "FARFETCHD",
        "DODUO", "DODRIO",
        "SEEL", "DEWGONG",
        "GRIMER", "MUK",
        "SHELLDER", "CLOYSTER",
        "GASTLY", "HAUNTER", "GENGAR",
        "ONIX",
        "DROWZEE", "HYPNO",
        "KRABBY", "KINGLER",
        "VOLTORB", "ELECTRODE",
        "EXEGGCUTE", "EXEGGUTOR",
        "CUBONE", "MAROWAK",
        "HITMONLEE", "HITMONCHAN",
        "LICKITUNG",
        "KOFFING", "WEEZING",
        "RHYHORN", "RHYDON",
        "CHANSEY",
        "TANGELA",
        "KANGASKHAN",
        "HORSEA", "SEADRA",
        "GOLDEEN", "SEAKING",
        "STARYU", "STARMIE",
        "MR_MIME",
        "SCYTHER",
        "JYNX",
        "ELECTABUZZ",
        "MAGMAR",
        "PINSIR",
        "TAUROS",
        "MAGIKARP", "GYARADOS",
        "LAPRAS",
        "DITTO",
        "EEVEE", "VAPOREON", "JOLTEON", "FLAREON",
        "PORYGON",
        "OMANYTE", "OMASTAR",
        "KABUTO", "KABUTOPS",
        "AERODACTYL",
        "SNORLAX",
        "ARTICUNO", "ZAPDOS", "MOLTRES",
        "DRATINI", "DRAGONAIR", "DRAGONITE",
        "MEWTWO",
        "MEW",
    }

    local PIKACHU_DEX = 25
    local currentPack = "Anime"
    local sourceCache = {}

    ------------------------------------------------------------
    -- Yellow PCM clip index → emotion filename (no extension)
    -- playPikaCry(data, n) uses 1-based n matching cry_XX.wav
    -- Adjust entries if a specific in-game moment feels wrong.
    ------------------------------------------------------------
    -- false = intentionally silent (no sound mood)
    local PIKA_CLIP_TO_EMOTION = {
        [1]  = "default",       -- title / everyday "Pika!"
        [2]  = "cute",
        [3]  = "angry",
        [4]  = "happy",
        [5]  = "playful",
        [6]  = "neutral",
        [7]  = "bored",
        [8]  = "stubborn",
        [9]  = "tired",
        [10] = "energetic",
        [11] = "default",       -- main menu exit cry
        [12] = "slightly_angered",
        [13] = "very_angry",
        [14] = "attacking",
        [15] = "more_playful",
        [16] = "happy_voicecrack",
        [17] = "overly_happy",
        [18] = "pleased",       -- catching
        [19] = "playful_fishing",
        [20] = "refusing",      -- thunderstone / party select
        [21] = "attacking",     -- teach Thunder / Thunderbolt
        [22] = "sleeping",
        [23] = "stressed",      -- statused
        [24] = "terrified",     -- Pokémon Tower
        [25] = "overly_happy",  -- Fan Club
        [26] = "confused",      -- Bill 1
        [27] = "interested",    -- Bill 2
        [28] = "impressed",     -- Bill 3
        [29] = "happy",
        [30] = "overly_happy",
        [31] = "angry",
        [32] = "playful",
        [33] = "default",
        [34] = "energetic",
        [35] = "cute",
        [36] = "neutral",
        [37] = "tired",
        [38] = "stubborn",
        [39] = "bored",
        [40] = "slightly_angered",
        [41] = "very_angry",
        [42] = "attacking",
    }

    -- All emotion basenames you can drop in assets/<pack>/pika/
    local PIKA_EMOTIONS = {
        "attacking",
        "slightly_angered",
        "very_angry",
        "bored",
        "stubborn",
        "angry",
        "cute",
        "playful",
        "neutral",
        "more_playful",
        "tired",
        "default",
        "energetic",
        "happy",
        "happy_voicecrack",
        "overly_happy",
        "pleased",
        "playful_fishing",
        "refusing",
        "sleeping",
        "stressed",
        "terrified",
        "confused",
        "interested",
        "impressed",
        -- silent moods need no file
    }

    ------------------------------------------------------------
    -- OPTIONS
    ------------------------------------------------------------
    mod.options:define({
        {
            key = "cries",
            type = "choice",
            label = "POKEMON CRIES",
            choices = CHOICES,
            default = "Anime",
        },
        {
            key = "yellow_intro",
            type = "choice",
            label = "PIKA INTRO MODDED",
            choices = {
                { "OFF", "off" },
                { "ON", "on" },
            },
            default = "off",
        },
    })

    local function packLabel(value)
        for _, c in ipairs(CHOICES) do
            if c[2] == value then return c[1] end
        end
        return "ORIGINAL"
    end

    local function nextPack(value, dir)
        local i = 1
        for idx, c in ipairs(CHOICES) do
            if c[2] == value then
                i = idx
                break
            end
        end
        i = ((i - 1 + (dir or 1)) % #CHOICES) + 1
        return CHOICES[i][2]
    end

    local function nextOnOff(value, dir)
        if (dir or 1) >= 0 then
            return value == "on" and "off" or "on"
        end
        return value == "off" and "on" or "off"
    end

    local function getGame()
        local ok, Game = pcall(require, "src.core.Game")
        if ok and Game then return Game end
        return nil
    end

    ------------------------------------------------------------
    -- Paths & Files
    ------------------------------------------------------------
    local function fileExists(path)
        if not path then return false end

        if mod and mod.assets and type(mod.assets.read) == "function" then
            if mod.assets:read(path) ~= nil then return true end
        end

        if mod and type(mod.read) == "function" then
            if mod:read(path) ~= nil then return true end
        end

        if mod and mod.assets and type(mod.assets.path) == "function" then
            local resolved = mod.assets:path(path)
            if resolved and mod and type(mod.read) == "function" and mod:read(resolved) ~= nil then
                return true
            end
        end

        return false
    end

    local function packCryPath(pack, dex)
        if not pack or pack == "original" then return nil end

        local rel = ("assets/%s/%d%s"):format(pack, dex, EXT)
        if fileExists(rel) then 
            return mod.assets and type(mod.assets.path) == "function" and mod.assets:path(rel) or rel 
        end

        local shortRel = ("%s/%d%s"):format(pack, dex, EXT)
        if fileExists(shortRel) then 
            return mod.assets and type(mod.assets.path) == "function" and mod.assets:path(shortRel) or shortRel 
        end

        return nil
    end

    local function pikaEmotionPath(pack, emotion)
        if not pack or pack == "original" or not emotion then return nil end

        local rel = ("assets/%s/pika/%s%s"):format(pack, emotion, EXT)
        if fileExists(rel) then 
            return mod.assets and type(mod.assets.path) == "function" and mod.assets:path(rel) or rel 
        end

        local shortRel = ("%s/pika/%s%s"):format(pack, emotion, EXT)
        if fileExists(shortRel) then 
            return mod.assets and type(mod.assets.path) == "function" and mod.assets:path(shortRel) or shortRel 
        end

        return nil
    end

    ------------------------------------------------------------
    -- Source cache
    ------------------------------------------------------------
    local function clearSourceCache()
        for path, src in pairs(sourceCache) do
            pcall(function()
                if src.stop then src:stop() end
                if src.release then src:release() end
            end)
            sourceCache[path] = nil
        end
        sourceCache = {}
    end

    local function getCachedSource(path)
        if not path or not love.audio then return nil end
        local src = sourceCache[path]
        if src then return src end

        local ok, source = pcall(function()
            -- Si el modloader ofrece un resolvedor de assets nativo
            if mod.assets and type(mod.assets.source) == "function" then
                return mod.assets:source(path, "static")
            end
            -- Carga mediante SoundData a partir de los bytes leídos por el mod
            if love.sound and love.sound.newSoundData and mod:read(path) then
                local fileData = love.filesystem and love.filesystem.newFileData 
                    and love.filesystem.newFileData(mod:read(path), path)
                if fileData then
                    local soundData = love.sound.newSoundData(fileData)
                    return love.audio.newSource(soundData, "static")
                end
            end
            return love.audio.newSource(path, "static")
        end)

        if ok and source then
            sourceCache[path] = source
            return source
        end
        return nil
    end

    local function playCached(path)
        local src = getCachedSource(path)
        if not src then return nil end
        src:stop()
        src:play()
        return src
    end

    local function invalidateSoundCache()
        local Sound = require("src.core.Sound")
        if Sound.invalidate then
            Sound.invalidate()
        end
    end

    local function isYellowTitleIntro()
       local ok, res = pcall(function()
            local Game = getGame()
            local stack = Game and Game.stack
            if not stack or not stack.states then return false end
            for i = #stack.states, 1, -1 do
                local s = stack.states[i]
                if s and s.yellowLayout then
                    local phase = s.phase
                    if phase == "drop" or phase == "settle"
                        or phase == "bubble" or phase == "cry" then
                        return true
                    end
                end
            end
            return false
        end)
        return ok and res
    end

    local function yellowIntroOverrideEnabled()
        return (mod.options:get("yellow_intro") or "off") == "on"
    end

    -- Resolve which file to play for PCM clip n
    local function resolvePikaPath(pack, n)
        if not pack or pack == "original" then return nil end

        local emotion = PIKA_CLIP_TO_EMOTION[n]
        if emotion == false then
            return false -- silent
        end

        -- 1) exact emotion file
        if emotion then
            local p = pikaEmotionPath(pack, emotion)
            if p then return p end
        end

        -- 2) default emotion
        local d = pikaEmotionPath(pack, "default")
        if d then return d end

        -- 3) species cry 25.ogg
        return packCryPath(pack, PIKACHU_DEX)
    end

    ------------------------------------------------------------
    -- Preview
    ------------------------------------------------------------
    local function playRandomStarterCry(pack)
        local Game = getGame()
        local data = Game and Game.data
        if not data then return end

        local Sound = require("src.core.Sound")
        local dex = STARTER_DEX[love.math.random(#STARTER_DEX)]
        local species = SPECIES[dex]

        if pack and pack ~= "original" then
            local path = packCryPath(pack, dex)
            if path and playCached(path) then
                return
            end
        end

        if Sound.playCry then
            Sound.playCry(data, species)
        end
    end

    ------------------------------------------------------------
    -- Yellow Pikachu PCM → per-emotion files
    ------------------------------------------------------------
    do
        local Sound = require("src.core.Sound")
        local origPlayPika = Sound.playPikaCry

        function Sound.playPikaCry(data, n)
            n = n or 1

            if not yellowIntroOverrideEnabled() and isYellowTitleIntro() then
                return origPlayPika(data, n)
            end

            local path = resolvePikaPath(currentPack, n)
            if path == false then
                return nil -- "no sound" mood
            end
            if path then
                local src = playCached(path)
                if src then return src end
            end
            return origPlayPika(data, n)
        end
    end

    ------------------------------------------------------------
    -- Vanilla snapshot + apply
    ------------------------------------------------------------
    local vanillaCries = nil

    local function shallowCopy(t)
        local out = {}
        if type(t) ~= "table" then return out end
        for k, v in pairs(t) do
            out[k] = v
        end
        return out
    end

    local function ensureVanillaSnapshot(data)
        if vanillaCries or not data or not data.audio or not data.audio.cries then
            return
        end
        vanillaCries = shallowCopy(data.audio.cries)
    end

    local function applyCries(pack)
        currentPack = pack or "original"

        local Game = getGame()
        local data = Game and Game.data
        if not data or not data.audio or not data.audio.cries then
            clearSourceCache()
            invalidateSoundCache()
            return
        end

        ensureVanillaSnapshot(data)

        -- Restaurar definiciones originales
        if vanillaCries then
            for species, def in pairs(vanillaCries) do
                data.audio.cries[species] = def
            end
        end

        -- Limpiar caché previa
        clearSourceCache()

        -- Asignar únicamente las rutas (SIN cargar love.audio.newSource de golpe)
        if pack ~= "original" then
            for dex, species in ipairs(SPECIES) do
                local path = packCryPath(pack, dex)
                if path then
                    data.audio.cries[species] = { file = path }
                end
            end
        end

        invalidateSoundCache()
    end

    ------------------------------------------------------------
    -- Persist
    ------------------------------------------------------------
    local function setOption(game, key, value)
        if game and game.save and game.save.options then
            game.save.options.modOptions = game.save.options.modOptions or {}
            local t = game.save.options.modOptions
            t[mod.id] = t[mod.id] or {}
            t[mod.id][key] = value
        end
        local loader = game and game.mods
        if loader then
            loader.modOptions = loader.modOptions or {}
            loader.modOptions[mod.id] = loader.modOptions[mod.id] or {}
            loader.modOptions[mod.id][key] = value
        end
    end

    ------------------------------------------------------------
    -- Boot
    ------------------------------------------------------------
    mod.events:on("game.ready", function()
        local Game = getGame()
        if Game and Game.data then
            ensureVanillaSnapshot(Game.data)
        end
        applyCries(mod.options:get("cries") or "Anime")
    end)

    ------------------------------------------------------------
    -- MAIN OPTIONS MENU
    ------------------------------------------------------------
    mod.hooks:wrap("ui.options.rows", function(next, game, rows)
        rows = next(game, rows) or rows

        local function already(id)
            for _, r in ipairs(rows) do
                if r.id == id then return true end
            end
            return false
        end

        local function tryInsert(row, anchors)
            if already(row.id) then return end
            local inserted = false
            if mod.ui and mod.ui.insertAfter then
                for _, anchor in ipairs(anchors) do
                    local n = #rows
                    mod.ui.insertAfter(rows, anchor, row)
                    if #rows > n then
                        inserted = true
                        break
                    end
                end
            end
            if not inserted then
                rows[#rows + 1] = row
            end
        end

        tryInsert({
            id = "mod_cries",
            label = "POKEMON CRIES",
            value = function()
                return packLabel(mod.options:get("cries"))
            end,
            step = function(g, dir)
                local cur = mod.options:get("cries") or "Anime"
                local new = nextPack(cur, dir or 1)
                setOption(g, "cries", new)
                applyCries(new)
                playRandomStarterCry(new)
                return true
            end,
        }, { "SFX VOL", "MUSIC VOL", "PIKACHU VOL" })

        tryInsert({
            id = "mod_yellow_intro",
            label = "PIKA INTRO MODDED",
            value = function()
                local v = mod.options:get("yellow_intro") or "off"
                return v == "on" and "ON" or "OFF"
            end,
            step = function(g, dir)
                local cur = mod.options:get("yellow_intro") or "off"
                local new = nextOnOff(cur, dir or 1)
                setOption(g, "yellow_intro", new)
                return true
            end,
        }, { "POKEMON CRIES", "SFX VOL", "MUSIC VOL" })

        return rows
    end)

    mod.events:on("mod.options_changed", function(ev)
        if ev.key == "cries" then
            applyCries(ev.value)
            playRandomStarterCry(ev.value)
        end
    end)
end
