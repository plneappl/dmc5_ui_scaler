function logger(it)
    log.debug(it)
end

function vec3_tostring(vec)
    return tostring(vec.x) .. ", " .. tostring(vec.y) .. ", " .. tostring(vec.z)
end
function vec4_tostring(vec)
    return vec3_tostring(vec) .. ", " .. tostring(vec.w)
end

local x_scale = 1
local y_scale = 0.5

local x_offset = 100
local y_offset = 200

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
end

function save_settings()
    local all_settings = { 
        x_scale = x_scale,
        y_scale = y_scale,
        x_offset = x_offset,
        y_offset = y_offset,
        disable = disable
    }
    json.dump_file(json_name, all_settings)
end

re.on_draw_ui(function()
    if imgui.tree_node("UI Scale") then
        changed1, disable = imgui.checkbox(" disable", disable)
        changed2, x_scale = imgui.slider_float(" x-scale", x_scale, 0, 1)
        changed3, y_scale = imgui.slider_float(" y-scale", y_scale, 0, 1)
        changed4, x_offset = imgui.slider_float(" x-offset", x_offset, 0, 4000)
        changed5, y_offset = imgui.slider_float(" y_offset", y_offset, 0, 1000)
        discard, reset_disabled = imgui.checkbox(" reset disabled elements (debugging)", reset_disabled)

        if changed1 or changed2 or changed3 or changed4 or changed5 then
            save_settings()
        end
    end
end)

function do_scale(game_object, name)
    return 
        not disable and
        name ~= "SaveLoadIcon_GUImesh" and
        -- gauntlet overlay
        name ~= "pickupGauntletHud" and
        name ~= "Fade_Loading" and
        name ~= "Fade_InGame" and
        name ~= "Fade_Menu" and
        -- secret mission marker
        name ~= "SecretVision" and
        -- overlay: start secret mission
        name ~= "MessageLabel" and
        name ~= "ui3104" and
        -- credits
        name ~= "ui6000" and
        name ~= "ScarsGUI" and
        name ~= "ScarsRoughnessGUI" and
        name ~= "ScarsNormalGUI" and
        --name:find("Scars", 1, true) ~= 1 and
        -- hp markers
        game_object:call("getComponent(System.Type)", sdk.typeof("app.ui1008GUI")) == nil and
        -- target markers
        game_object:call("getComponent(System.Type)", sdk.typeof("app.ui1009GUI")) == nil and
        game_object:call("getComponent(System.Type)", sdk.typeof("app.ui1010GUI")) == nil 
end

function draw_right_aligned(game_object, name)
    return 
        -- gauntlet UI
        game_object:call("getComponent(System.Type)", sdk.typeof("app.ui1013GUI")) ~= nil or
        -- ORBS
        game_object:call("getComponent(System.Type)", sdk.typeof("app.ui1020GUI")) ~= nil or
        -- c-c-combo
        game_object:call("getComponent(System.Type)", sdk.typeof("app.ui1014GUI")) ~= nil
end

function draw_bot_aligned(game_object, name)
    return
        -- gauntlet UI
        game_object:call("getComponent(System.Type)", sdk.typeof("app.ui1013GUI")) ~= nil or
        -- boss health
        game_object:call("getComponent(System.Type)", sdk.typeof("app.ui1007GUI")) ~= nil
end

re.on_pre_gui_draw_element(function(element, context)
    local game_object = (element:read_qword(0x10) ~= 0) and element:call("get_GameObject")
    if game_object ~= nil then 
        local transform = game_object:get_Transform()
        local position = transform:get_position()
        local name = game_object:get_Name()

        if do_scale(game_object, name) then
            --logger(tostring(name))

            local gui_component = game_object:call("getComponent(System.Type)", sdk.typeof("via.gui.GUI"))
            local view = gui_component:get_View()

            view:set_Scale(Vector3f.new(x_scale, y_scale, 1))

            x_off = x_offset
            y_off = y_offset
            if draw_right_aligned(game_object, name) then
                x_off = -x_off
            end
            if draw_bot_aligned(game_object, name) then
                y_off = -y_off
            end
            view:set_Position(Vector3f.new(x_off, y_off, 0))

        elseif reset_disabled then
            local gui_component = game_object:call("getComponent(System.Type)", sdk.typeof("via.gui.GUI"))
            local view = gui_component:get_View()
            view:set_Scale(Vector3f.new(1, 1, 1))
            view:set_Position(Vector3f.new(0, 0, 0))
        end
    end
    return true
end)