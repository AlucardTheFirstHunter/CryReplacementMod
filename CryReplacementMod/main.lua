return function(mod)
    ------------------------------------------------------------
    -- CRY PACKS
    -- assets/Anime/1.ogg … 151.ogg
    -- assets/FireRed/1.ogg … 151.ogg
    -- ORIGINAL = vanilla chip cries
    ------------------------------------------------------------

    local CHOICES = {
        { "ORIGINAL", "original" },
        { "ANIME", "Anime" },
        { "FIRE RED", "FireRed" },
    }

    -- Change if your files are .wav
    local EXT = ".ogg"

    -- National dex 1–151 → gen1recomp species ids
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

    ------------------------------------------------------------
    -- Snapshot vanilla cries once (for ORIGINAL restore)
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

    local function getGame()
        local ok, Game = pcall(require, "src.core.Game")
        if ok and Game then return Game end
        return nil
    end

    local function ensureVanillaSnapshot(data)
        if vanillaCries or not data or not data.audio or not data.audio.cries then
            return
        end
        vanillaCries = shallowCopy(data.audio.cries)
    end

    ------------------------------------------------------------
    -- Apply pack (runtime-safe: live data only)
    ------------------------------------------------------------
    local function applyCries(pack)
        local Game = getGame()
        local data = Game and Game.data
        if not data or not data.audio or not data.audio.cries then
            return
        end

        ensureVanillaSnapshot(data)

        if pack == "original" then
            if vanillaCries then
                for species, def in pairs(vanillaCries) do
                    data.audio.cries[species] = def
                end
            end
        else
            for dex, species in ipairs(SPECIES) do
                data.audio.cries[species] = {
                    file = mod.assets:path(
                        ("assets/%s/%d%s"):format(pack, dex, EXT)
                    ),
                }
            end
        end

        -- Drop cached cry sources so the next play uses the new defs
        local Sound = require("src.core.Sound")
        if Sound.invalidate then
            Sound.invalidate()
        end
    end

    ------------------------------------------------------------
    -- Persist (same path as mod manager)
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

        if loader and loader.events then
            loader.events:emit("mod.options_changed", {
                mod = mod.id,
                key = "cries",
                value = value,
            })
        end
    end

    ------------------------------------------------------------
    -- Apply after game data exists
    ------------------------------------------------------------
    mod.events:on("game.ready", function()
        local Game = getGame()
        if Game and Game.data then
            ensureVanillaSnapshot(Game.data)
        end
        applyCries(mod.options:get("cries") or "Anime")
    end)

    ------------------------------------------------------------
    -- Main Options menu
    ------------------------------------------------------------
    mod.hooks:wrap("ui.options.rows", function(next, game, rows)
        rows = next(game, rows) or rows

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

        if mod.ui and mod.ui.insertAfter then
            mod.ui.insertAfter(rows, "SFX VOL", row)
        else
            rows[#rows + 1] = row
        end

        return rows
    end)

    ------------------------------------------------------------
    -- Mod manager change
    ------------------------------------------------------------
    mod.events:on("mod.options_changed", function(ev)
        if ev.key ~= "cries" then return end
        applyCries(ev.value)
    end)
end