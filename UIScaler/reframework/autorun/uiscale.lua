function logger(it)
    log.debug(it)
end

function vec3_tostring(vec)
    return tostring(vec.x) .. ", " .. tostring(vec.y) .. ", " .. tostring(vec.z)
end
function vec4_tostring(vec)
    return vec3_tostring(vec) .. ", " .. tostring(vec.w)
end

local gui_type = sdk.typeof("via.gui.GUI")

local x_scale = 1
local y_scale = 0.5

local x_scale_cutscenes = 1
local y_scale_cutscenes = 1

local x_offset = 0
local y_offset = 0

local x_offset_cutscenes = 0
local y_offset_cutscenes = 0

local disable = false
local reset_disabled = false

local json_name = "uiscale.json"
local settings = json.load_file(json_name)
logger(tostring(settings))
if(settings ~= nil) then
    x_scale = settings.x_scale
    y_scale = settings.y_scale

    x_offset = settings.x_offset
    y_offset = settings.y_offset

    disable = settings.disable == true

    local v111Settings = settings.v111Settings
    if v111Settings ~= nil then
        x_scale_cutscenes = v111Settings.x_scale_cutscenes
        y_scale_cutscenes = v111Settings.y_scale_cutscenes
        x_offset_cutscenes = v111Settings.x_offset_cutscenes
        y_offset_cutscenes = v111Settings.y_offset_cutscenes
    end
end

function save_settings()
    local all_settings = { 
        x_scale = x_scale,
        y_scale = y_scale,
        x_offset = x_offset,
        y_offset = y_offset,
        disable = disable,
        v111Settings = {
            x_scale_cutscenes = x_scale_cutscenes,
            y_scale_cutscenes = y_scale_cutscenes,
            x_offset_cutscenes = x_offset_cutscenes,
            y_offset_cutscenes = y_offset_cutscenes
        }
    }
    json.dump_file(json_name, all_settings)
end

re.on_draw_ui(function()
    if imgui.tree_node("UI Scale") then
        changed1, disable = imgui.checkbox(" disable", disable)
        changed2, x_scale = imgui.slider_float(" x-scale", x_scale, 0, 1)
        changed3, y_scale = imgui.slider_float(" y-scale", y_scale, 0, 1)
        changed4, x_scale_cutscenes = imgui.slider_float(" x-scale (loading screens)", x_scale_cutscenes, 0, 1)
        changed5, y_scale_cutscenes = imgui.slider_float(" y-scale (loading screens)", y_scale_cutscenes, 0, 1)
        changed6, x_offset = imgui.slider_float(" x-offset", x_offset, 0, 4000)
        changed7, y_offset = imgui.slider_float(" y_offset", y_offset, 0, 1000)
        changed8, x_offset_cutscenes = imgui.slider_float(" x-offset (loading screens)", x_offset_cutscenes, 0, 4000)
        changed9, y_offset_cutscenes = imgui.slider_float(" y_offset (loading screens)", y_offset_cutscenes, 0, 1000)
        _, reset_disabled = imgui.checkbox(" reset disabled elements (debugging)", reset_disabled)

        if 
            changed1 or 
            changed2 or 
            changed3 or 
            changed4 or 
            changed5 or 
            changed6 or 
            changed7 or 
            changed8 or 
            changed9 then
            save_settings()
        end
    end
end)

local game_object_get_component = sdk.find_type_definition("via.GameObject"):get_method("getComponent(System.Type)")

local should_not_scale_name = {}
should_not_scale_name["SaveLoadIcon_GUImesh"] = true
-- gauntlet overlay
should_not_scale_name["pickupGauntletHud"] = true
should_not_scale_name["Fade_Loading"] = true
should_not_scale_name["Fade_InGame"] = true
should_not_scale_name["Fade_Menu"] = true
-- secret mission marker
should_not_scale_name["SecretVision"] = true
-- shop messages
should_not_scale_name["ui0002"] = true
-- loading screen
should_not_scale_name["ui0040"] = true
should_not_scale_name["ui0041"] = true
should_not_scale_name["ui3107"] = true
should_not_scale_name["ui3108_s10"] = true
-- overlay: start secret mission
should_not_scale_name["MessageLabel"] = true
should_not_scale_name["ui3104"] = true
-- overlay: secret mission instructions
should_not_scale_name["ui7002"] = true
-- some boss names
should_not_scale_name["m16_200_UI"] = true
should_not_scale_name["m17_300_UI"] = true
-- credits
should_not_scale_name["ui6000"] = true
should_not_scale_name["ScarsGUI"] = true
should_not_scale_name["ScarsRoughnessGUI"] = true
should_not_scale_name["ScarsNormalGUI"] = true
should_not_scale_name["Fade_Menu"] = true

-- in game menu
-- "ui3105"

local should_not_scale_type = {}
-- hp markers
table.insert(should_not_scale_type, sdk.typeof("app.ui1008GUI"))
-- target markers
table.insert(should_not_scale_type, sdk.typeof("app.ui1009GUI"))
table.insert(should_not_scale_type, sdk.typeof("app.ui1010GUI"))

function has_type(list_of_types, game_object)
    for _, type in ipairs(list_of_types) do
        if game_object_get_component(game_object, type) ~= nil then
            return true
        end
    end
    return false
end

function do_scale(game_object, name)
    return
        not disable and
        should_not_scale_name[name] ~= true and
        not has_type(should_not_scale_type, game_object)
end

local cutscenes = {}
-- intro
cutscenes["StartLogo"] = true
cutscenes["ui2201_Vergil"] = true
-- loading screens
cutscenes["ui3101"] = true
cutscenes["ui3120"] = true
cutscenes["ui8022"] = true

function is_cutscene(game_object, name)
    return cutscenes[name] == true
end

local right_aligned_types = {}
-- gauntlet UI
table.insert(right_aligned_types, sdk.typeof("app.ui1013GUI"))
-- c-c-combo
table.insert(right_aligned_types, sdk.typeof("app.ui1014GUI"))
-- ORBS
table.insert(right_aligned_types, sdk.typeof("app.ui1020GUI"))

function draw_right_aligned(game_object, name)
    return has_type(right_aligned_types, game_object)
end

local bot_aligned_types = {}
-- boss health
table.insert(bot_aligned_types, sdk.typeof("app.ui1007GUI"))
-- gauntlet UI
table.insert(bot_aligned_types, sdk.typeof("app.ui1013GUI"))

function draw_bot_aligned(game_object, name)
    return has_type(bot_aligned_types, game_object)
end

re.on_pre_gui_draw_element(function(element, context)
    local game_object = (element:read_qword(0x10) ~= 0) and element:call("get_GameObject")
    if game_object ~= nil then 
        local transform = game_object:get_Transform()
        local position = transform:get_position()
        local name = game_object:get_Name()

        if do_scale(game_object, name) then
            --logger(tostring(name))

            local gui_component = game_object_get_component(game_object, gui_type)
            local view = gui_component:get_View()

            local x_s = x_scale
            local y_s = y_scale

            local x_off = x_offset
            local y_off = y_offset

            if is_cutscene(game_object, name) then
                x_s = x_scale_cutscenes
                y_s = y_scale_cutscenes
                x_off = x_offset_cutscenes
                y_off = y_offset_cutscenes
            end

            view:set_Scale(Vector3f.new(x_s, y_s, 1))
            if draw_right_aligned(game_object, name) then
                x_off = -x_off
            end
            if draw_bot_aligned(game_object, name) then
                y_off = -y_off
            end
            view:set_Position(Vector3f.new(x_off, y_off, 0))

        elseif reset_disabled then
            local gui_component = game_object_get_component(game_object, gui_type)
            local view = gui_component:get_View()
            view:set_Scale(Vector3f.new(1, 1, 1))
            view:set_Position(Vector3f.new(0, 0, 0))
        end
    end
    return true
end)