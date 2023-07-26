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

local json_name = "uiscale.json"
local settings = json.load_file(json_name)
logger(tostring(settings))
if(settings ~= nil) then
    x_scale = settings.x_scale
    y_scale = settings.y_scale

    x_offset = settings.x_offset
    y_offset = settings.y_offset
end

function save_settings()
    local all_settings = { 
        x_scale = x_scale,
        y_scale = y_scale,
        x_offset = x_offset,
        y_offset = y_offset
    }
    json.dump_file(json_name, all_settings)
end

re.on_draw_ui(function()
    if imgui.tree_node("UI Scale") then
        changed1, x_scale = imgui.slider_float(" x-scale", x_scale, 0, 1)
        changed2, y_scale = imgui.slider_float(" y-scale", y_scale, 0, 1)
        changed3, x_offset = imgui.slider_float(" x-offset", x_offset, 0, 4000)
        changed4, y_offset = imgui.slider_float(" y_offset", y_offset, 0, 1000)

        if changed1 or changed2 or changed3 or changed4 then
            save_settings()
        end
    end
end)

re.on_pre_gui_draw_element(function(element, context)
    local game_object = (element:read_qword(0x10) ~= 0) and element:call("get_GameObject")
    if game_object ~= nil then 
        local transform = game_object:get_Transform()
        local position = transform:get_position()
        local name = game_object:get_Name()
        --logger(name)

        -- don't scale target markers
        if game_object:call("getComponent(System.Type)", sdk.typeof("app.ui1008GUI")) == nil and 
           game_object:call("getComponent(System.Type)", sdk.typeof("app.ui1009GUI")) == nil and 
           game_object:call("getComponent(System.Type)", sdk.typeof("app.ui1010GUI")) == nil then
            local gui_component = game_object:call("getComponent(System.Type)", sdk.typeof("via.gui.GUI"))
            local view = gui_component:get_View()

            view:set_Scale(Vector3f.new(x_scale, y_scale, 1))
            view:set_Position(Vector3f.new(x_offset, y_offset, 0))
        end
        --logger(tostring(game_object:get_parent()))
    end
    return true
end)