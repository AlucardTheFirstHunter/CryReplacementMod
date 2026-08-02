return function(mod)
    ------------------------------------------------------------
    -- CRY PACKS
    -- assets/Anime/1.ogg … 151.ogg
    -- assets/FireRed/1.ogg … 151.ogg
    -- ORIGINAL = vanilla chip cries
    --
    -- Pack files are staged into mod-derived/CryReplacementMod/ in the
    -- LOVE save directory (see packCryPath below) so the engine can
    -- resolve them through love.filesystem on every platform.
    --
    -- Yellow Pikachu uses PCM clips (playPikaCry), not cries.PIKACHU.
    -- This mod redirects those to assets/<pack>/25.ogg when a pack is on.
    ------------------------------------------------------------

    local CHOICES = {
        { "ORIGINAL", "original" },
        { "ANIME", "Anime" },
        { "FIRE RED", "FireRed" },
    }

    local EXT = ".ogg" -- change to ".wav" if needed

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

    ------------------------------------------------------------
    -- OPTION
    ------------------------------------------------------------
    mod.options:define({
        {
            key = "cries",
            type = "choice",
            label = "POKEMON CRIES",
            choices = CHOICES,
            default = "Anime",
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

    local function getGame()
        local ok, Game = pcall(require, "src.core.Game")
        if ok and Game then return Game end
        return nil
    end

    -- Where the pack files are staged so the engine can play them.  The
    -- mods tree is NOT guaranteed to sit on love.filesystem's read path
    -- (a packaged / portable install keeps it outside the save dir, which
    -- is why sources created straight from "mods/.../assets/..." paths
    -- went silent on the Steam Deck): the OGG bytes are copied into the
    -- mod-owned save-directory tree (save/mod-derived/<id>/..., the same
    -- home the engine's asset transforms write), which is ALWAYS on
    -- love.filesystem's read path.  The bytes come from mod:read, the
    -- same channel the loader used to read main.lua, so they resolve on
    -- every platform the mod itself loads on.
    local GENERATED_ROOT = "mod-derived/CryReplacementMod"

    -- Stage one pack file (assets/<pack>/<dex>.ogg) into the save dir;
    -- returns the generated virtual path or nil when the file is missing
    -- from the mod (the species then keeps its vanilla cry).
    local function packCryPath(pack, dex)
        if not pack or pack == "original" then return nil end
        local rel = ("assets/%s/%d%s"):format(pack, dex, EXT)
        local bytes = mod:read(rel)
        if not bytes then return nil end
        local outPath = ("%s/%s/%d%s"):format(GENERATED_ROOT, pack, dex, EXT)
        if love and love.filesystem then
            love.filesystem.createDirectory(GENERATED_ROOT)
            love.filesystem.createDirectory(GENERATED_ROOT .. "/" .. pack)
            if not love.filesystem.write(outPath, bytes) then
                return nil
            end
        end
        return outPath
    end

    local function pikachuPackPath(pack)
        return packCryPath(pack, PIKACHU_DEX)
    end

    local function invalidateSoundCache()
        local Sound = require("src.core.Sound")
        if Sound.invalidate then
            Sound.invalidate()
        end
    end

    ------------------------------------------------------------
    -- Yellow Pikachu PCM → pack file (25.ogg)
    ------------------------------------------------------------
    do
        local Sound = require("src.core.Sound")
        local origPlayPika = Sound.playPikaCry

        function Sound.playPikaCry(data, n)
            local path = pikachuPackPath(currentPack)
            if path and love.audio then
                local ok, src = pcall(love.audio.newSource, path, "static")
                if ok and src then
                    -- Respect SFX / Pikachu volume when possible
                    if Sound.getVolumeFor then
                        pcall(function()
                            src:setVolume(Sound.getVolumeFor("pikacry:" .. tostring(n or 1)))
                        end)
                    end
                    src:stop()
                    src:play()
                    return src
                end
            end
            return origPlayPika(data, n)
        end
    end

    ------------------------------------------------------------
    -- Vanilla snapshot + apply (missing file → keep vanilla)
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
            invalidateSoundCache()
            return
        end

        ensureVanillaSnapshot(data)

        if vanillaCries then
            for species, def in pairs(vanillaCries) do
                data.audio.cries[species] = def
            end
        end

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
    local function setCriesOption(game, value)
        if game and game.save and game.save.options then
            game.save.options.modOptions = game.save.options.modOptions or {}
            local t = game.save.options.modOptions
            t[mod.id] = t[mod.id] or {}
            t[mod.id].cries = value
        end

        local loader = game and game.mods
        if loader then
            loader.modOptions = loader.modOptions or {}
            loader.modOptions[mod.id] = loader.modOptions[mod.id] or {}
            loader.modOptions[mod.id].cries = value
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

        for _, r in ipairs(rows) do
            if r.id == "mod_cries" then
                return rows
            end
        end

        local row = {
            id = "mod_cries",
            label = "POKEMON CRIES",
            value = function()
                return packLabel(mod.options:get("cries"))
            end,
            step = function(g, dir)
                local cur = mod.options:get("cries") or "Anime"
                local new = nextPack(cur, dir or 1)
                setCriesOption(g, new)
                applyCries(new)
                return true
            end,
        }

        local inserted = false
        if mod.ui and mod.ui.insertAfter then
            for _, anchor in ipairs({ "SFX VOL", "MUSIC VOL", "PIKACHU VOL" }) do
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

        return rows
    end)

    ------------------------------------------------------------
    -- Mod manager
    ------------------------------------------------------------
    mod.events:on("mod.options_changed", function(ev)
        if ev.key ~= "cries" then return end
        applyCries(ev.value)
    end)
end