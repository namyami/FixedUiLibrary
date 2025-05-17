local framework = loadstring(game:HttpGet("https://raw.githubusercontent.com/judghementday2/bypass/refs/heads/main/framework.lua", true))();
--
do -- checks
    do -- folders
        if (not isfolder("ENHANCEMENTS")) then
            makefolder("ENHANCEMENTS");
        end;
        --
        if (not isfolder("CONFIGS")) then
            makefolder("CONFIGS");
        end;
        --
        if (not isfolder("ENHANCEMENTS/MENU")) then
            makefolder("ENHANCEMENTS/MENU");
        end;
        --
        if (not isfolder("ENHANCEMENTS/MENU/FONTS")) then
            makefolder("ENHANCEMENTS/MENU/FONTS");
        end;
        --
        if (not isfolder("ENHANCEMENTS/LOADER/IMAGES")) then
            makefolder("ENHANCEMENTS/LOADER/IMAGES");
        end;
    end;
end;
-- math
local udim2 = UDim2.new;
local udim = UDim.new;
local vec2 = Vector2.new;
local color3_rgb = Color3.fromRGB;
-- services
local services = framework["services"];
local run_service = cloneref(services["RunService"]);
local players = cloneref(services["players"]);
local uis = cloneref(services["userInputService"]);
local tween_service = cloneref(services["tweenService"]);
local camera = cloneref(services.Workspace["CurrentCamera"]);
local lighting = cloneref(services["lighting"]);
-- vars
local viewport_size = camera["ViewportSize"];
local lplr = players["LocalPlayer"];
local user = lplr["Name"];
local get_mouse = lplr:GetMouse();
-- modules
Instance_manager = framework.modules.instance_manager
signals = framework.modules.signals
-- fonts
local create_font = {}
function create_font:register(path, options)
        local name = options.name
            local link = options.link
                local path = path .."/" .. name.. ".ttf"

                    local weight = options.weight
                        weight = weight:sub(1,1):upper()..weight:sub(2, #weight):lower()

                            local style  = options.style
                                style = style:sub(1,1):upper()..style:sub(2, #style):lower()
                                    
                                        if not isfile(path) then
                                                writefile(path, game:HttpGet(link))
                                                    end

                                                        local asset = getcustomasset(path)
                                                            return Font.new(
                                                                    asset,
                                                                            Enum.FontWeight[weight],
                                                                                    Enum.FontStyle[style]
                                                                                        )
                                                                                        end
local fonts = {
    smallest_pixel = create_font:register("ENHANCEMENTS/MENU/FONTS", {
        name = "smallest pixel",
        weight = "regular",
        style = "normal",
        link = "https://raw.githubusercontent.com/judghementday2/bypass/refs/heads/main/smallest_pixel-7.ttf",
    }),
    templeos = create_font:register("ENHANCEMENTS/MENU/FONTS", {
        name = "templeos",
        weight = "regular",
        style = "normal",
        link = "https://raw.githubusercontent.com/judghementday2/bypass/refs/heads/main/Templeos.ttf",
    }),
    proggytiny = create_font:register("ENHANCEMENTS/MENU/FONTS", {
        name = "proggytiny",
        weight = "regular",
        style = "normal",
        link = "https://raw.githubusercontent.com/judghementday2/bypass/refs/heads/main/ProggyTiny.ttf",
    }),
    medodica = create_font:register("ENHANCEMENTS/MENU/FONTS", {
        name = "medodica",
        weight = "regular",
        style = "normal",
        link = "https://raw.githubusercontent.com/judghementday2/bypass/refs/heads/main/MedodicaRegular.ttf",
    }),
};
--
local UI = ({
    autoload = true,
    font = Font.new([[rbxassetid://12187365977]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
    font_size = 12;
    ui_key = Enum.KeyCode.Delete,
    menu_gui = nil,
    watermark_gui = nil,
    themes = ({ accent = color3_rgb(131,135,250), risky = color3_rgb(85, 0, 0), background = color3_rgb(7,7,8), outline = color3_rgb(15,15,16), inactive = color3_rgb(69,69,70) }),
    keys = {
        [Enum.KeyCode.LeftShift] = "L-SHIFT", [Enum.KeyCode.RightShift] = "R-SHIFT", [Enum.KeyCode.LeftControl] = "L-CTRL",
        [Enum.KeyCode.RightControl] = "R-CTRL", [Enum.KeyCode.LeftAlt] = "L-ALT", [Enum.KeyCode.RightAlt] = "R-ALT",
        [Enum.KeyCode.Insert] = "INSERT", [Enum.KeyCode.End] = "END", [Enum.KeyCode.PageUp] = "PGUP",
        [Enum.KeyCode.Delete] = "DELETE", [Enum.KeyCode.Home] = "HOME", [Enum.KeyCode.PageDown] = "PGDN",
        [Enum.UserInputType.MouseButton1] = "MB1", [Enum.UserInputType.MouseButton2] = "MB2",
        [Enum.UserInputType.MouseButton3] = "MB3",
    },

    un_named_flags = 0,
    page_amount = 0,
    pages = {},
    sections = {},
    flags = {},

    language = "English",
    user_data = {
        username = (user or "User"),
        uid = 1
    };
    shared = {
        initialized = false,
        fps = 0,
        ping = 0
    },
});
--
local flags = {};
UI.__index = UI;
UI.pages.__index = UI.pages;
UI.sections.__index = UI.sections;
--
local black_bg;
local blur_effect;
do -- other
    function UI.next_flag() -- flags
        UI.un_named_flags = UI.un_named_flags + 1;
        return string.format("%.14g", UI.un_named_flags);
    end;
    --
    function UI:RGBA(r, g, b, alpha)
        local rgb = Color3.fromRGB(r, g, b)
        local mt = table.clone(getrawmetatable(rgb))

        setreadonly(mt, false)
        local old = mt.__index

        mt.__index = newcclosure(function(self, key)
            if key:lower() == "transparency" then
                return alpha
            end
            return old(self, key)
        end)

        setrawmetatable(rgb, mt)
        return rgb
    end
    --
    function UI:GetConfig()
        local Config = ""
        for Index, Value in pairs(self.flags) do
            if Index ~= "ConfigConfig_List" and Index ~= "ConfigConfig_Load" and Index ~= "ConfigConfig_Save" then
                local Value2 = Value
                local Final = ""
                --
                if typeof(Value2) == "Color3" then
                    local hue, sat, val = Value2:ToHSV()
                    --
                    Final = ("rgb(%s,%s,%s,%s)"):format(hue, sat, val, 1)
                elseif typeof(Value2) == "table" and Value2.Color and Value2.Transparency then
                    local hue, sat, val = Value2.Color:ToHSV()
                    --
                    Final = ("rgb(%s,%s,%s,%s)"):format(hue, sat, val, Value2.Transparency)
                elseif typeof(Value2) == "table" and Value.Mode then
                    local Values = Value.current
                    --
                    Final = ("key(%s,%s,%s)"):format(Values[1] or "nil", Values[2] or "nil", Value.Mode)
                elseif Value2 ~= nil then
                    if typeof(Value2) == "boolean" then
                        Value2 = ("bool(%s)"):format(tostring(Value2))
                    elseif typeof(Value2) == "table" then
                        local New = "table("
                        --
                        for _, Value3 in pairs(Value2) do
                            New = New .. Value3 .. ","
                        end
                        --
                        if New:sub(#New) == "," then
                            New = New:sub(0, #New - 1)
                        end
                        --
                        Value2 = New .. ")"
                    elseif typeof(Value2) == "string" then
                        Value2 = ("string(%s)"):format(Value2)
                    elseif typeof(Value2) == "number" then
                        Value2 = ("number(%s)"):format(Value2)
                    end
                    --
                    Final = Value2
                end
                --
                Config = Config .. Index .. ": " .. tostring(Final) .. "\n"
            end
        end
        --
        return Config;
    end;
    --
    function UI:LoadConfig(Config)
        local Table = string.split(Config, "\n")
        local Table2 = {}
        for _, Value in pairs(Table) do
            local Table3 = string.split(Value, ":")
            --
            if Table3[1] ~= "ConfigConfig_List" and #Table3 >= 2 then
                local Value = Table3[2]:sub(2, #Table3[2])
                --
                if Value:sub(1, 3) == "rgb" then
                    local Table4 = string.split(Value:sub(5, #Value - 1), ",")
                    --
                    Value = Table4
                elseif Value:sub(1, 3) == "key" then
                    local Table4 = string.split(Value:sub(5, #Value - 1), ",")
                    --
                    if Table4[1] == "nil" and Table4[2] == "nil" then
                        Table4[1] = nil
                        Table4[2] = nil
                    end
                    --
                    Value = Table4
                elseif Value:sub(1, 4) == "bool" then
                    local Bool = Value:sub(6, #Value - 1)
                    --
                    Value = Bool == "true"
                elseif Value:sub(1, 5) == "table" then
                    local Table4 = string.split(Value:sub(7, #Value - 1), ",")
                    --
                    Value = Table4
                elseif Value:sub(1, 6) == "string" then
                    local String = Value:sub(8, #Value - 1)
                    --
                    Value = String
                elseif Value:sub(1, 6) == "number" then
                    local Number = tonumber(Value:sub(8, #Value - 1))
                    --
                    Value = Number
                end
                --
                Table2[Table3[1]] = Value
            end
        end
        --
        for i, v in pairs(Table2) do
            if flags[i] then
                if typeof(flags[i]) == "table" then
                    flags[i]:Set(v)
                else
                    flags[i](v)
                end
            end
        end
    end;
    --
    function UI:IsMouseOverFrame(Frame)
        local AbsPos, AbsSize = Frame.AbsolutePosition, Frame.AbsoluteSize;
        if get_mouse.X >= AbsPos.X and get_mouse.X <= AbsPos.X + AbsSize.X
            and get_mouse.Y >= AbsPos.Y and get_mouse.Y <= AbsPos.Y + AbsSize.Y then
            return true;
        end;
    end;
    --
    blur_effect = cloneref(Instance.new("BlurEffect", lighting));
    
black_bg = Instance_manager.new("Frame", {
    Name = "bg_effect";
    Size = udim2(9999, 0, 9999, 0);
    BorderColor3 = UI.themes.outline;
    Position = udim2(0, 0, 0, -100);
    ZIndex = -9999;
    BackgroundColor3 = color3_rgb(0, 0, 0);
    Visible = UI.autoload;
    BackgroundTransparency = 0.35;
    Parent = cloneref(Instance.new("ScreenGui", gethui()));
});
end
--
do -- menu
    function UI:watermark(properties)
        local watermark = {
            name = (properties.Name or properties.name or "watermark text | placeholder");
        };
        --
        local watermark_ui = Instance_manager.new("ScreenGui", {
            Name = "watermark";
            Parent = cloneref(gethui());
            IgnoreGuiInset = Enum.ScreenInsets.DeviceSafeInsets;
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
        });
        UI.watermark_gui = watermark_ui;

        local outline = Instance_manager.new("Frame", {
            Name = "watermark_outline";
            AutomaticSize = Enum.AutomaticSize.X;
            BackgroundColor3 = UI.themes.background;
            BorderColor3 = UI.themes.outline;
            Position = udim2(0.5, 0, 0.02, 0);
            BorderSizePixel = 1;
            AnchorPoint = vec2(0.5, 0);
            Size = udim2(0, 0, 0, 25);
            Visible = false;
            Parent = watermark_ui;
        });

        local Inline = Instance_manager.new("Frame", {
            Name = "watermark_inline";
            BackgroundColor3 = UI.themes.background;
            BorderSizePixel = 0;
            Position = udim2(0, 1, 0, 1);
            Size = udim2(1, -2, 1, -2);
            Parent = outline;
        });

        local Value = Instance_manager.new("TextLabel", {
            FontFace = UI.font;
            TextSize = UI.font_size;
            Name = "watermark_text";
            Text = watermark.name;
            TextColor3 = color3_rgb(255, 255, 255);
            RichText = true;
            TextStrokeTransparency = 0;
            TextXAlignment = Enum.TextXAlignment.Left;
            AutomaticSize = Enum.AutomaticSize.X;
            BackgroundColor3 = color3_rgb(20, 20, 20);
            BackgroundTransparency = 1;
            BorderColor3 = color3_rgb(0, 0, 0);
            BorderSizePixel = 0;
            Size = udim2(0, 0, 1, 0);
            Parent = Inline;
        });

        local UIPadding = Instance_manager.new("UIPadding", {
            Name = "UIPadding";
            PaddingLeft = udim(0, 5);
            PaddingRight = udim(0, 5);
            Parent = Value;
        });

        -- functions
        function watermark:update_text(NewText)
            Value.Text = NewText;
        end

        function watermark:Position(NewPositionX, NewPositionY)
            if NewPositionX ~= nil then
                self.HorizontalPosition = NewPositionX
            end
            if NewPositionY ~= nil then
                self.VerticalPosition = NewPositionY
            end
            outline.Position = udim2(self.HorizontalPosition, 0, self.VerticalPosition, 0);
        end

        function watermark:SetVisible(State)
            outline.Visible = State;
        end

        return watermark;
    end
    --
    function UI:NewPicker(name, default, defaultalpha, parent, count, flag, callback)
        local Icon = Instance.new("TextButton", parent)
        local color_name = Instance.new("TextLabel")
        local Outline4 = Instance.new("Frame")
        local ColorWindow = Instance.new("Frame")
        local ColorInline = Instance.new("Frame")
        local Color = Instance.new("TextButton")
        local text_color = Instance.new("TextButton")
        local text_color2 = Instance.new("TextButton")
        local text_color_outline = Instance.new("Frame")
        local Sat = Instance.new("ImageLabel")
        local Val = Instance.new("ImageLabel")
        local Outline = Instance.new("Frame")
        local Alpha = Instance.new("ImageButton")
        local Outline1 = Instance.new("Frame")
        local Hue = Instance.new("ImageButton")
        local Outline2 = Instance.new("Frame")
        local Color_Circle = Instance.new("TextButton")
        local Alpha_Bg = Instance.new("ImageLabel")

        do -- properties
            Icon.Name = "Icon_Colorpicker"
            Icon.AnchorPoint = Vector2.new(0, 0.5)
            Icon.BackgroundColor3 = default
            Icon.BorderColor3 = Color3.fromRGB(36, 36, 36)
            Icon.BorderSizePixel = 1
            local spacing = 3;
            if count == 1 then
                Icon.Position = UDim2.new(1, - (count * 18), 0.5, 0);
            else
                Icon.Position = UDim2.new(1, - (count * 16) - (count * spacing), 0.5, 0);
            end;
            Icon.Size = UDim2.new(0, 16, 0, 16)
            Icon.Text = ""
            Icon.ZIndex = 99
            Icon.AutoButtonColor = false

            Instance_manager.new("UICorner", {
                Parent = Icon;
                CornerRadius = udim(1, 0);
            });

            Outline4.Name = "Outline"
            Outline4.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Outline4.BackgroundTransparency = 1
            Outline4.BorderColor3 = Color3.fromRGB(0, 0, 0)
            Outline4.BorderSizePixel = 0
            Outline4.Position = UDim2.new(0, -1, 0, -1)
            Outline4.Size = UDim2.new(1, 2, 1, 2)
            Outline4.ZIndex = 99
            Outline4.Parent = Icon

            ColorWindow.Name = "ColorWindow"
            ColorWindow.AnchorPoint = Vector2.new(0.5, 0.5)
            ColorWindow.BackgroundColor3 = UI.themes.outline
            ColorWindow.BorderColor3 = Color3.fromRGB(0, 0, 0)
            ColorWindow.Parent = Icon
            ColorWindow.Position = UDim2.new(1, 0, 1, 2)
            ColorWindow.AnchorPoint = Vector2.new(1,0)
            ColorWindow.Size = UDim2.new(0, 180, 0, 220)
            ColorWindow.ZIndex = 99
            ColorWindow.Visible = false

            Instance_manager.new("UICorner", {
                Parent = ColorWindow;
                CornerRadius = udim(0, 6);
            });

            ColorInline.Name = "ColorInline"
            ColorInline.BackgroundColor3 = UI.themes.background
            ColorInline.BorderColor3 = Color3.fromRGB(0, 0, 0)
            ColorInline.BorderSizePixel = 0
            ColorInline.Position = UDim2.new(0, 1, 0, 1)
            ColorInline.Size = UDim2.new(1, -2, 1, -2)

            Instance_manager.new("UICorner", {
                Parent = ColorInline;
                CornerRadius = udim(0, 6);
            });

            color_name.BackgroundTransparency = 1
            color_name.Text = name
            color_name.TextXAlignment = Enum.TextXAlignment.Left
            color_name.TextColor3 = color3_rgb(255, 255, 255)
            color_name.Position = udim2(0,8,0,5)
            color_name.Size = udim2(1,-10,0,20)
            color_name.TextSize = UI.font_size
            color_name.FontFace = UI.font
            color_name.Parent = ColorInline
            color_name.TextStrokeTransparency = 0

            text_color.Name = "Text Color"
            text_color.FontFace = UI.font
            text_color.TextColor3 = color3_rgb(155, 155, 155)
            text_color.Parent = ColorInline
            text_color.TextStrokeTransparency = 0
            text_color.TextSize = UI.font_size
            text_color.AutoButtonColor = false
            text_color.BackgroundColor3 = UI.themes.background
            text_color.BorderColor3 = UI.themes.outline
            text_color.Position = UDim2.new(0, 7, 1, -17)
            text_color.Size = UDim2.new(0, 76, 0, 12)

            text_color2.Name = "Text Color 2"
            text_color2.FontFace = UI.font
            text_color2.TextColor3 = color3_rgb(155, 155, 155)
            text_color2.Parent = ColorInline
            text_color2.TextStrokeTransparency = 0
            text_color2.TextSize = UI.font_size
            text_color2.AutoButtonColor = false
            text_color2.BackgroundColor3 = UI.themes.background
            text_color2.BorderColor3 = UI.themes.outline
            text_color2.Position = UDim2.new(0, 90, 1, -17)
            text_color2.Size = UDim2.new(0, 80, 0, 12)

            text_color_outline.Name = "Outline"
            text_color_outline.BackgroundTransparency = 1
            text_color_outline.BorderColor3 = Color3.fromRGB(0, 0, 0)
            text_color_outline.BorderSizePixel = 0
            text_color_outline.Position = UDim2.new(0, -1, 0, -1)
            text_color_outline.Size = UDim2.new(1, 2, 1, 2)
            text_color_outline.ZIndex = 99
            text_color_outline.Parent = text_color
            local text_color_outline2 = text_color_outline:Clone()
            text_color_outline2.Parent = text_color2

            Color.Name = "Color"
            Color.FontFace = UI.font
            Color.Text = ""
            Color.TextColor3 = Color3.fromRGB(0, 0, 0)
            Color.TextSize = UI.font_size
            Color.AutoButtonColor = false
            Color.BackgroundColor3 = default
            Color.BorderColor3 = UI.themes.background
            Color.Position = UDim2.new(0, 6, 0, 30)
            Color.Size = UDim2.new(0, 145, 1, -74)

            Instance_manager.new("UICorner", {
                Parent = Color;
                CornerRadius = udim(0, 7);
            });

            Color_Circle.Name = "CircleButton"
            Color_Circle.FontFace = UI.font
            Color_Circle.Text = ""
            Color_Circle.TextColor3 = Color3.fromRGB(0, 0, 0)
            Color_Circle.TextSize = UI.font_size
            Color_Circle.AutoButtonColor = false
            Color_Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Color_Circle.BorderColor3 = UI.themes.background
            Color_Circle.Position = UDim2.new(0.5, -25, 0.5, -25)
            Color_Circle.Size = UDim2.new(0, 7, 0, 7)
            Color_Circle.Parent = Color
            Color_Circle.ZIndex = 9

            Instance_manager.new("UICorner", {
                Parent = Color_Circle;
                CornerRadius = UDim.new(1, 0);
            })

            Sat.Name = "Sat"
            Sat.Image = "http://www.roblox.com/asset/?id=14684562507"
            Sat.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Sat.BackgroundTransparency = 1
            Sat.BorderColor3 = Color3.fromRGB(0, 0, 0)
            Sat.BorderSizePixel = 0
            Sat.Size = UDim2.new(1, 0, 1, 0)
            Sat.Parent = Color

            Instance_manager.new("UICorner", {
                Parent = Sat;
                CornerRadius = udim(0, 6);
            });

            Val.Name = "Val"
            Val.Image = "http://www.roblox.com/asset/?id=14684563800"
            Val.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Val.BackgroundTransparency = 1
            Val.BorderColor3 = Color3.fromRGB(0, 0, 0)
            Val.BorderSizePixel = 0
            Val.Size = UDim2.new(1, 0, 1, 0)
            Val.Parent = Color

            Instance_manager.new("UICorner", {
                Parent = Val;
                CornerRadius = udim(0, 6);
            });

            Outline.Name = "Outline"
            Outline.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Outline.BackgroundTransparency = 1
            Outline.BorderColor3 = Color3.fromRGB(0, 0, 0)
            Outline.BorderSizePixel = 0
            Outline.Position = UDim2.new(0, -1, 0, -1)
            Outline.Size = UDim2.new(1, 2, 1, 2)

            Outline.Parent = Color
            Color.Parent = ColorInline

            Alpha.Name = "Alpha"
            Alpha.Image = "http://www.roblox.com/asset/?id=15486053510"
            Alpha.AutoButtonColor = false
            Alpha.BackgroundTransparency = 1
            Alpha.ImageTransparency = 0.03
            Alpha.BorderSizePixel = 0
            Alpha.Position = UDim2.new(1, -18, 0, 30)
            Alpha.Size = UDim2.new(0, 10, 1, -74)
            Alpha.Parent = ColorInline

            Instance_manager.new("UICorner", {
                Parent = Alpha;
                CornerRadius = udim(0, 5);
            });

            Alpha_Bg.Name = "alpha_bg"
            Alpha_Bg.ZIndex = -1
            Alpha_Bg.Image = "http://www.roblox.com/asset/?id=4879903999"
            Alpha_Bg.BackgroundTransparency = 1
            Alpha_Bg.ScaleType = Enum.ScaleType.Crop
            Alpha_Bg.ImageColor3 = Color3.fromRGB(255, 255, 255)
            Alpha_Bg.BorderSizePixel = 0
            Alpha_Bg.Position = UDim2.new(1, -18, 0, 68)
            Alpha_Bg.Size = UDim2.new(0, 10, 1, -114)
            Alpha_Bg.Parent = ColorInline

            Instance_manager.new("UICorner", {
                Parent = Alpha_Bg;
                CornerRadius = udim(0, 5);
            });

            Outline1.Name = "Outline"
            Outline1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Outline1.BackgroundTransparency = 1
            Outline1.BorderColor3 = Color3.fromRGB(0, 0, 0)
            Outline1.BorderSizePixel = 0
            Outline1.Position = UDim2.new(0, -1, 0, -1)
            Outline1.Size = UDim2.new(1, 2, 1, 2)
            Outline1.Parent = Alpha

            Hue.Name = "Hue"
            Hue.Image = "http://www.roblox.com/asset/?id=138435236878653"
            Hue.AutoButtonColor = false
            Hue.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
            Hue.BorderColor3 = Color3.fromRGB(17, 17, 17)
            Hue.Position = UDim2.new(0, 7, 1, -35)
            Hue.Size = UDim2.new(0, 164, 0, 10)

            Instance_manager.new("UICorner", {
                Parent = Hue;
                CornerRadius = udim(0, 5);
            });

            Outline2.Name = "Outline"
            Outline2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Outline2.BackgroundTransparency = 1
            Outline2.BorderColor3 = Color3.fromRGB(0, 0, 0)
            Outline2.BorderSizePixel = 0
            Outline2.Position = UDim2.new(0, -1, 0, -1)
            Outline2.Size = UDim2.new(1, 2, 1, 2)

            Outline2.Parent = Hue
            Hue.Parent = ColorInline
            ColorInline.Parent = ColorWindow
        end

        --connections
        local mouseover = false
        local hue, sat, val = default:ToHSV()
        local hsv = default:ToHSV()
        local alpha = defaultalpha
        local oldcolor = hsv
        local slidingsaturation = false
        local slidinghue = false
        local slidingalpha = false

        local function update()
            local real_pos = uis:GetMouseLocation()
            local mouse_position = Vector2.new(real_pos.X - 3, real_pos.Y - 55)
            local relative_palette = (mouse_position - Color.AbsolutePosition)
            local relative_hue     = (mouse_position - Hue.AbsolutePosition)
            local relative_opacity = (mouse_position - Alpha.AbsolutePosition)
            --
            if slidingsaturation then
                sat = math.clamp(1 - relative_palette.X / Color.AbsoluteSize.X, 0, 1)
                val = math.clamp(1 - relative_palette.Y / Color.AbsoluteSize.Y, 0, 1)
            elseif slidinghue then
                hue = math.clamp(1 - (relative_hue.X / Hue.AbsoluteSize.X), 0, 1) -- Invert hue direction
            elseif slidingalpha then
                alpha = math.clamp(relative_opacity.X / Alpha.AbsoluteSize.X, 0, 1)
            end

            hsv = Color3.fromHSV(hue, sat, val)
            Color.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
            Icon.BackgroundColor3 = hsv
            Color_Circle.Position = UDim2.new(1 - sat, 0, 1 - val, -5)

            if flag then
                UI.flags[flag] = UI:RGBA(hsv.r * 255, hsv.g * 255, hsv.b * 255, alpha)
            end

            local r, g, b = math.floor(hsv.r * 255), math.floor(hsv.g * 255), math.floor(hsv.b * 255)
            local rgbColor = Color3.fromRGB(r, g, b)

            Alpha.ImageColor3 = rgbColor
            text_color.Text = string.format("#%02x%02x%02x", r, g, b)
            text_color2.Text = string.format("%d, %d, %d", r, g, b)

            callback(UI:RGBA(hsv.r * 255, hsv.g * 255, hsv.b * 255, alpha))
        end

        local function set(color, a)
            if type(color) == "table" then
                a = color[4]
                color = Color3.fromHSV(color[1], color[2], color[3])
            end
            if type(color) == "string" then
                color = Color3.fromHex(color)
            end

            local oldcolor = hsv
            local oldalpha = alpha

            hue, sat, val = color:ToHSV()
            alpha = a or 1
            hsv = Color3.fromHSV(hue, sat, val)

            if hsv ~= oldcolor then
                Icon.BackgroundColor3 = hsv
                Color.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)

                local r, g, b = math.floor(hsv.r * 255), math.floor(hsv.g * 255), math.floor(hsv.b * 255)
                local rgbColor = Color3.fromRGB(r, g, b)

                Alpha.ImageColor3 = rgbColor
                text_color.Text = string.format("#%02x%02x%02x", r, g, b)
                text_color2.Text = string.format("%d, %d, %d", r, g, b)

                if flag then
                    UI.flags[flag] = UI:RGBA(hsv.r * 255, hsv.g * 255, hsv.b * 255, alpha)
                end

                callback(UI:RGBA(hsv.r * 255, hsv.g * 255, hsv.b * 255, alpha))
            end
        end

        flags[flag] = set
        set(default, defaultalpha)

        Sat.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                slidingsaturation = true
                update()
            end
        end)

        Sat.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                slidingsaturation = false
                update()
            end
        end)

        Hue.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                slidinghue = true
                update()
            end
        end)

        Hue.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                slidinghue = false
                update()
            end
        end)

        Alpha.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                slidingalpha = true
                update()
            end
        end)

        Alpha.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                slidingalpha = false
                update()
            end
        end)

        signals.connection(uis.InputChanged, function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                if slidingalpha then
                    update()
                end

                if slidinghue then
                    update()
                end

                if slidingsaturation then
                    update()
                end
            end
        end)

        local colorpickertypes = {}

        function colorpickertypes:Set(color, newalpha)
            set(color, newalpha)
        end

        signals.connection(uis.InputBegan, function(Input)
            if ColorWindow.Visible and Input.UserInputType == Enum.UserInputType.MouseButton1 then
                if not UI:IsMouseOverFrame(ColorWindow) and not UI:IsMouseOverFrame(Icon) and not UI:IsMouseOverFrame(parent) then
                    ColorWindow.Visible = false
                    parent.ZIndex = 1
                end
            end
        end);

        Icon.MouseButton1Down:Connect(function()
            ColorWindow.Visible = true
            parent.ZIndex = 5

            if slidinghue then
                slidinghue = false
            end

            if slidingsaturation then
                slidingsaturation = false
            end

            if slidingalpha then
                slidingalpha = false
            end
        end)

        return colorpickertypes, ColorWindow
    end
    -- menu
    local pages = UI.pages;
    local sections = UI.sections;
    --
    do -- window
        function UI:window(options)
            local window = {
                name = (options.Name or options.name or "visual enhancements");
                size = (options.Size or options.size or udim2(0, 750, 0, 500));
                position = (options.position == "left" and Enum.TextXAlignment.Left) or (options.position == "center" and Enum.TextXAlignment.Center) or (options.position == "right" and Enum.TextXAlignment.Right) or Enum.TextXAlignment.Left,
                dragging = { false, udim2(0, 0, 0, 0) };
                page_amount = options.Amount or options.amount or 5;
                elements = {};
                sections = {};
                pages = {};
            };
            --
            local menu = Instance_manager.new("ScreenGui", {
                Name = "menu";
                Parent = cloneref(gethui());
                IgnoreGuiInset = Enum.ScreenInsets.DeviceSafeInsets;
                ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
            });
            UI.menu_gui = menu;

            local background = Instance_manager.new("TextButton", {
                Name = "background";
                Parent = menu;
                Text = "";
                AutoButtonColor = false;
                AnchorPoint = vec2(0.5, 0.5);
                BackgroundColor3 = UI.themes.background;
                BorderColor3 = UI.themes.outline;
                Position = udim2(0.5, 0, 0.5, 0);
                BorderSizePixel = 1;
                Size = window.size;
            });

            Instance_manager.new("Frame", {
                Name = "line";
                ZIndex = 10;
                BackgroundColor3 = UI.themes.accent;
                BackgroundTransparency = 1; -- later add checks
                BorderColor3 = color3_rgb(0, 0, 0);
                BorderSizePixel = 0;
                Position = udim2(0, 0, 0, 0);
                Size = udim2(1, 0, 0, 1);
                Parent = background;
            });

            Instance_manager.new("Frame", {
                Name = "line";
                BackgroundColor3 = UI.themes.outline;
                BorderColor3 = color3_rgb(0, 0, 0);
                BorderSizePixel = 0;
                Position = udim2(0, 80, 0, 0);
                Size = udim2(0, 1, 1, 0);
                Parent = background;
            });

            local tabs_holder = Instance_manager.new("Frame", {
                Name = "tabs_holder";
                BackgroundTransparency = 1;
                BackgroundColor3 = UI.themes.background;
                BorderColor3 = color3_rgb(0, 0, 0);
                BorderSizePixel = 0;
                Size = udim2(0, 80, 0, 500);
                Parent = background;
            });
            --
            local page_holder = Instance_manager.new("Frame", {
                Name = "page_holder";
                BackgroundColor3 = color3_rgb(255, 255, 255);
                BackgroundTransparency = 1.000;
                BorderColor3 = color3_rgb(255, 255, 255);
                BorderSizePixel = 0;
                Position = udim2(0.127, 0, 0, 13);
                Size = udim2(0, 640, 0, 470);
                Parent = background;
            });
            --
            window.elements = {
                tab_holder = tabs_holder,
                holder = page_holder,
                base = background,
            };
            --
            function window:update_tabs()
                for _, page in pairs(window.pages) do
                    page:Turn(page.open);
                end;
            end;
            --
            do -- dragging
                signals.connection(background.InputBegan, function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        window.dragging[1], window.dragging[2] = true, uis:GetMouseLocation();
                    end
                end);

                signals.connection(uis.InputEnded, function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        window.dragging[1] = false;
                    end
                end);

                signals.connection(uis.InputChanged, function(input)
                    if window.dragging[1] and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local mouse_pos = uis:GetMouseLocation()

                        local x_pos = math.clamp(background.Position.X.Offset + (mouse_pos.X - window.dragging[2].X), -viewport_size.X / 2 + background.AbsoluteSize.X / 2, viewport_size.X / 2 - background.AbsoluteSize.X / 2);
                        local y_pos = math.clamp(background.Position.Y.Offset + (mouse_pos.Y - window.dragging[2].Y), -viewport_size.Y / 2 + background.AbsoluteSize.Y / 2, viewport_size.Y / 2 - background.AbsoluteSize.Y / 2);

                        background.Position = udim2(background.Position.X.Scale, x_pos, background.Position.Y.Scale, y_pos);
                        window.dragging[2] = mouse_pos;
                    end
                end);
            end

            -- elements
            UI.holder = background;
            UI.page_amount = window.page_amount;
            return setmetatable(window, UI);
        end;
    end;
    --
    do -- pages
        function UI:tabs(properties)
            if not properties then properties = {} end;
            --
            local page = {
                name = properties.Name or properties.name or "page",
                window = self,
                open = false,
                sections = {},
                pages = {},
                elements = {},
                icon = properties.icon or properties.Icon or "",
                size = properties.size or properties.Size or udim2(0, 60, 0, 60),
            };
            --
            if (not page.window.elements.tab_holder:FindFirstChild("UIListLayout")) then
                Instance_manager.new("UIListLayout", {
                    Name = "UIListLayout";
                    Padding = udim(0, 0);
                    SortOrder = Enum.SortOrder.LayoutOrder;
                    Parent = page.window.elements.tab_holder;
                });
            end;
            --
            local tab_button = Instance_manager.new("TextButton", {
                Name = page.name;
                BackgroundColor3 = UI.themes.background;
                AutoButtonColor = false;
                BackgroundTransparency = 0;
                BorderSizePixel = 0;
                Position = udim2(0, 0, 0, 0);
                Size = udim2(1, 0, 0, 90);
                Text = "";
                Parent = page.window.elements.tab_holder;
            });
            --
            local image_button = Instance_manager.new("ImageLabel", {
                Name = page.name;
                Image = page.icon;
                BackgroundTransparency = 1;
                BorderSizePixel = 0;
                Position = udim2(
                    0.5,
                    -(typeof(properties.size) == "UDim2" and properties.size.X.Offset or 60) / 2,
                    0.5,
                    -(typeof(properties.size) == "UDim2" and properties.size.Y.Offset or 60) / 2
                ),
                Size = properties.size;Size = properties.size;
                ImageColor3 = UI.themes.inactive;
                Parent = tab_button;
            });
            --
            local text_button = Instance_manager.new("TextLabel", {
                Name = "Window_Name";
                Text = string.upper(page.name);
                FontFace = UI.font;
                TextSize = UI.font_size;
                TextColor3 = UI.themes.inactive;
                BackgroundTransparency = 1;
                TextStrokeTransparency = 0;
                BorderSizePixel = 0;
                Position = udim2(0, 0, 0, 25);
                Size = udim2(1, 0, 1, 0);
                Parent = tab_button;
            });
            --
            local new_page = Instance_manager.new("Frame", {
                Name = "new_page";
                BackgroundColor3 = color3_rgb(255, 255, 255);
                BackgroundTransparency = 1;
                BorderColor3 = color3_rgb(0, 0, 0);
                BorderSizePixel = 0;
                Position = udim2(0, -2, 0, 2);
                Size = udim2(1, 4, 1, 0);
                Visible = false;
                Parent = page.window.elements.holder;
            });
            --
            local gutter = 2

            local left = Instance_manager.new("ScrollingFrame", {
                Name = "left";
                    BackgroundColor3 = UI.themes.background;
                        BorderColor3 = UI.themes.outline;
                            Position = UDim2.new(0, 0, 0, 0);
                                Size = UDim2.new(1/3, -gutter, 1, 0);
                                    ScrollBarThickness = 0;
                                        AutomaticCanvasSize = Enum.AutomaticSize.Y; 
                                            Parent = new_page;
                                            });

                                            local center = Instance_manager.new("ScrollingFrame", {
                                                Name = "center";
                                                    BackgroundColor3 = UI.themes.background;
                                                        BorderColor3 = UI.themes.outline;
                                                            Position = UDim2.new(1/3, gutter/2, 0, 0);
                                                                Size = UDim2.new(1/3, -gutter, 1, 0);
                                                                    ScrollBarThickness = 0;
                                                                        AutomaticCanvasSize = Enum.AutomaticSize.Y;
                                                                            Parent = new_page;
                                                                            });

                                                                            local right = Instance_manager.new("ScrollingFrame", {
                                                                                Name = "right";
                                                                                    BackgroundColor3 = UI.themes.background;
                                                                                        BorderColor3 = UI.themes.outline;
                                                                                            Position = UDim2.new(2/3, gutter, 0, 0);
                                                                                                Size = UDim2.new(1/3, -gutter, 1, 0);
                                                                                                    ScrollBarThickness = 0;
                                                                                                        AutomaticCanvasSize = Enum.AutomaticSize.Y;
                                                                                                            Parent = new_page;
                                                                                                            });
            --
            do -- auto-sizer
                local tabs = {};
                for _, v in pairs(page.window.elements.tab_holder:GetChildren()) do
                    if v:IsA("GuiObject") and not v:IsA("UIListLayout") and not v:IsA("UIGridLayout") then
                        table.insert(tabs, v);
                    end
                end

                local tab_count = #tabs;
                local holder_size = page.window.elements.tab_holder.Size.Y.Offset;
                local adjusted_size = math.max(holder_size, 0);

                if tab_count > 0 and adjusted_size > 0 then
                    local tab_height = adjusted_size / tab_count;

                    for _, tab in ipairs(tabs) do
                        tab.Size = udim2(1, 0, 0, tab_height);
                    end
                end
            end
            --
            function page:Turn(bool)
                page.open = bool;
                new_page.Visible = bool;

                local tweens = {}
                for _, v in pairs(UI.menu_gui:GetDescendants()) do
                    if table.find({ "toggle_bg", "accent_bg", "Slider_Inline", "Slider_Accent", "Slider_Circle", "List_Outline", "List_Inline", "Keybind_Outline", "Keybind_Inline", "button_outline", "button_inline", "textbox_outline", "textbox_inline", "ContentOutline", "ContentInline"}, v.Name) then
                        if bool then v.BackgroundTransparency = 1 end;
                        table.insert(tweens, tween_service:Create(v, TweenInfo.new(0.333, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), { BackgroundTransparency = bool and 0 or 1 }));
                    end;

                    if v:IsA("TextLabel") and v.Name ~= "Window_Name" then
                        if bool then v.TextTransparency = 1 end;
                        table.insert(tweens, tween_service:Create(v, TweenInfo.new(0.333, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), { TextTransparency = bool and 0 or 1 }));
                    end;
                end;

                for _, tween in ipairs(tweens) do
                    tween:Play()
                end;

                tween_service:Create(tab_button, TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
                    BackgroundColor3 = bool and UI.themes.outline or UI.themes.background,
                }):Play()

                tween_service:Create(image_button, TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
                    ImageColor3 = bool and UI.themes.accent or UI.themes.inactive,
                }):Play()

                tween_service:Create(text_button, TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
                    TextColor3 = bool and UI.themes.accent or UI.themes.inactive,
                }):Play()
            end;
            --
            tab_button.MouseEnter:Connect(function()
                if (not page.open) then
                    tween_service:Create(tab_button, TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
                        BackgroundColor3 = UI.themes.outline,
                    }):Play()
                end
            end);

            tab_button.MouseLeave:Connect(function()
                if (not page.open) then
                    tween_service:Create(tab_button, TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
                        BackgroundColor3 = UI.themes.background,
                    }):Play()
                end
            end);
            --
            signals.connection(tab_button.MouseButton1Down, function()
                if not page.open then
                    for _, v in pairs(page.window.pages) do
                        if v.open and v ~= page then
                            v:Turn(false);
                        end
                    end
                    page:Turn(true);
                end
            end)

            -- elements
            page.elements = {
                left = left,
                center = center,
                right = right,
                button = tab_button,
                main = new_page,
            };

            if #page.window.pages == 0 then
                page:Turn(true);
            end
            page.window.pages[#page.window.pages + 1] = page;
            UI.pages[#UI.pages + 1] = page;
            page.window:update_tabs();
            return setmetatable(page, UI.pages);
        end;
    end;
    --
    function pages:section(properties)
        if not properties then properties = {} end;
        --
        local section = {
            name = (properties.name or properties.Name or "section"),
            page = self,
            side = (properties.side or properties.Side),
            risky = (properties.risky or properties.Risky),
            elements = {},
            content = {},
            sections = {},
        };

        local top_section = Instance_manager.new("Frame", {
            Name = "top_section";
            BackgroundTransparency = 1;
            AutomaticSize = Enum.AutomaticSize.Y;
            BackgroundColor3 = UI.themes.background;
            BorderColor3 = color3_rgb(0, 0, 0);
            Size = udim2(1, 0, 0, 20);
            Parent = (section.side == "left" and section.page.elements.left) or (section.side == "center" and section.page.elements.center) or (section.side == "right" and section.page.elements.right);
            ZIndex = 10 - #section.page.sections;
        });

        local title = Instance_manager.new("TextLabel", {
            Name = section.name;
            FontFace = UI.font;
            Text = string.upper(section.name);
            TextColor3 = section.risky and UI.themes.risky or UI.themes.inactive;
            TextSize = UI.font_size;
            TextStrokeTransparency = 0;
            TextXAlignment = Enum.TextXAlignment.Left;
            BackgroundTransparency = 1;
            BorderColor3 = color3_rgb(0, 0, 0);
            BorderSizePixel = 0;
            Position = udim2(0, 15, 0, 12);
            Size = udim2(0, 186, 0, 20);
            Parent = top_section;
        });

        local section_content = Instance_manager.new("Frame", {
            Name = "section_content";
            AutomaticSize = Enum.AutomaticSize.Y;
            BackgroundColor3 = color3_rgb(255, 255, 255);
            BackgroundTransparency = 1;
            BorderColor3 = color3_rgb(0, 0, 0);
            BorderSizePixel = 0;
            Position = udim2(0, 16, 0, 44);
            Size = udim2(1, -32, 0, 30);
            Parent = top_section;
        });

        Instance_manager.new("UIListLayout", {
            Name = "UIListLayout";
            Padding = udim(0, 22);
            SortOrder = Enum.SortOrder.LayoutOrder;
            Parent = section_content;
        });

        Instance_manager.new("UIPadding", {
            Name = "UIPadding";
            PaddingBottom = udim(0, 6);
            Parent = section_content;
        });

        -- elements
        section.elements = {
            section_content = section_content
        };

        section.page.sections[#section.page.sections + 1] = section;
        return setmetatable(section, UI.sections);
    end
    function sections:toggle(properties)
        if not properties then properties = {} end;
        --
        local toggle = {
            window = self.window,
            page = self.page,
            section = self,
            risk = properties.Risk or properties.Risky or properties.risk or properties.risky or false,
            name = properties.Name or properties.name or "Toggle",
            description = properties.Description or properties.description or "Unknown",
            State = (properties.state or properties.State or properties.def or properties.Def or properties.default or properties.Default or false),
            callback = (properties.callback or properties.Callback or properties.callBack or properties.CallBack or function() end),
            flag = (properties.flag or properties.Flag or properties.pointer or properties.Pointer or UI.next_flag()),
            toggled = false,
            Colorpickers = 0,
        };
        --
        local new_toggle = Instance_manager.new("TextButton", {
            Name = toggle.name;
            Text = "";
            AutoButtonColor = false;
            BackgroundTransparency = 1;
            Size = udim2(1, 0, 0, 18);
            Parent = toggle.section.elements.section_content;
        });

        local toggle_bg = Instance_manager.new("Frame", {
            Name = "toggle_bg";
            BackgroundColor3 = UI.themes.outline;
            Position = udim2(0.81, 0, 0, 0);
            Size = udim2(0, 34, 0, 20);
            Parent = new_toggle;
        });

        Instance_manager.new("UICorner", {
            Parent = toggle_bg;
            CornerRadius = udim(0, 10);
        });

        local accent_bg = Instance_manager.new("Frame", {
            Name = "accent_bg";
            BorderColor3 = UI.themes.outline;
            BorderSizePixel = 1;
            Position = udim2(0, 2, 0.5, -8);
            Size = udim2(0, 16, 0, 16);
            Parent = toggle_bg;
            BackgroundColor3 = UI.themes.inactive;
        });

        Instance_manager.new("UICorner", {
            Parent = accent_bg;
            CornerRadius = udim(1, 0);
        });

        Instance_manager.new("TextLabel", {
            Name = "title";
            FontFace = UI.font;
            TextSize = UI.font_size;
            TextColor3 = toggle.risk and UI.themes.risky or color3_rgb(255, 255, 255);
            TextStrokeTransparency = 0;
            TextXAlignment = Enum.TextXAlignment.Left;
            BackgroundColor3 = color3_rgb(255, 255, 255);
            BackgroundTransparency = 1;
            BorderColor3 = color3_rgb(0, 0, 0);
            BorderSizePixel = 0;
            Position = udim2(0, 0, 0, 0);
            Size = udim2(1, 0, 1, 0);
            Parent = new_toggle;
            Text = toggle.name;
        });

        Instance_manager.new("TextLabel", {
            Name = "description";
            FontFace = UI.font;
            TextSize = UI.font_size;
            TextColor3 = UI.themes.inactive;
            TextStrokeTransparency = 0;
            TextXAlignment = Enum.TextXAlignment.Left;
            BackgroundColor3 = color3_rgb(255, 255, 255);
            BackgroundTransparency = 1;
            BorderColor3 = color3_rgb(0, 0, 0);
            BorderSizePixel = 0;
            Position = udim2(0, 0, 0, 15);
            Size = udim2(1, 0, 1, 0);
            Parent = new_toggle;
            Text = toggle.description;
        });

        -- functions
        local function set_state()
            toggle.toggled = not toggle.toggled;
            UI.flags[toggle.flag] = toggle.toggled;
            toggle.callback(toggle.toggled);
            --
            tween_service:Create(toggle_bg, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), { BackgroundColor3 = toggle.toggled and UI.themes.accent or UI.themes.outline }):Play()
            tween_service:Create(accent_bg, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), { Position = toggle.toggled and udim2(1, -18, 0.5, -8) or udim2(0, 2, 0.5, -8) }):Play()
            tween_service:Create(accent_bg, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), { BackgroundColor3 = toggle.toggled and Color3.fromRGB(200, 200, 200) or UI.themes.inactive }):Play()
        end
        signals.connection(new_toggle.MouseButton1Down, set_state);

        -- functions
        function toggle.Set(bool)
            bool = type(bool) == "boolean" and bool or false;
            if toggle.toggled ~= bool then
                set_state();
            end
        end
        --
        toggle.Set(toggle.State);
        UI.flags[toggle.flag] = toggle.State;
        flags[toggle.flag] = toggle.Set;

        return toggle;
    end
    --
    function sections:slider(properties)
        if not properties then properties = {} end;
        --
        local slider = {
            window = self.Window,
            page = self.Page,
            section = self,
            Name = (properties.name or properties.Name or nil),
            Min = (properties.min or properties.Min or properties.minimum or properties.Minimum or 0),
            State = (properties.state or properties.State or properties.def or properties.Def or properties.default or properties.Default or 10),
            Max = (properties.max or properties.Max or properties.maximum or properties.Maximum or 100),
            Sub = (properties.suffix or properties.Suffix or properties.ending or properties.Ending or properties.prefix or properties.Prefix or properties.measurement or properties.Measurement or ""),
            Decimals = (properties.decimals or properties.Decimals or 1),
            Callback = (properties.callback or properties.Callback or properties.callBack or properties.CallBack or function() end),
            Flag = (properties.flag or properties.Flag or properties.pointer or properties.Pointer or UI.next_flag()),
            Disabled = (properties.Disabled or properties.disable or nil),
        };
        --
        local slider_name = ("[value]" .. slider.Sub) -- for slider name
        --
        local new_slider = Instance_manager.new("Frame", {
            Name = "new_slider",
            BackgroundColor3 = color3_rgb(255, 255, 255),
            BackgroundTransparency = 1,
            BorderColor3 = color3_rgb(0, 0, 0),
            BorderSizePixel = 0,
            Size = udim2(1, 0, 0, slider.Name and 26 or 12),
            Parent = slider.section.elements.section_content,
        });

        local Inline = Instance_manager.new("TextButton", {
            Name = "Slider_Inline",
            BackgroundColor3 = UI.themes.outline,
            BorderColor3 = color3_rgb(0, 0, 0),
            BorderSizePixel = 0,
            Position = udim2(0, 0, 1, -2),
            Size = udim2(1, 0, 0, 6),
            FontFace = UI.font,
            Text = "",
            TextColor3 = color3_rgb(0, 0, 0),
            TextSize = UI.font_size,
            AutoButtonColor = false,
            Parent = new_slider,
        });

        local Accent = Instance_manager.new("TextButton", {
            Name = "Slider_Accent",
            BackgroundColor3 = UI.themes.accent,
            BorderColor3 = color3_rgb(0, 0, 0),
            BorderSizePixel = 0,
            Size = udim2(0, 0, 1, 0),
            FontFace = UI.font,
            Text = "",
            TextColor3 = color3_rgb(0, 0, 0),
            TextSize = UI.font_size,
            AutoButtonColor = false,
            Parent = Inline,
        });

        local SliderCircle = Instance_manager.new("Frame", {
            Name = "Slider_Circle",
            BackgroundColor3 = UI.themes.accent,
            Size = udim2(0, 12, 0, 12),
            AnchorPoint = vec2(0.5, 0.5),
            Parent = Inline,
        });

        Instance_manager.new("UICorner", {
            Parent = SliderCircle,
            CornerRadius = udim(1, 0),
        });

        local Value = Instance_manager.new("TextLabel", {
            Name = "Value",
            FontFace = UI.font,
            Text = "0",
            TextColor3 = color3_rgb(255, 255, 255),
            TextSize = UI.font_size,
            TextStrokeTransparency = 0,
            BackgroundColor3 = color3_rgb(255, 255, 255),
            BackgroundTransparency = 1,
            BorderColor3 = color3_rgb(0, 0, 0),
            BorderSizePixel = 0,
            Size = udim2(1, 0, 0, 10),
            Position = udim2(0, 0, 0, 4),
            TextXAlignment = Enum.TextXAlignment.Right,
            Parent = new_slider,
        });

        local Title = Instance_manager.new("TextLabel", {
            Name = "Title",
            FontFace = UI.font,
            TextColor3 = color3_rgb(255, 255, 255),
            TextSize = UI.font_size,
            TextStrokeTransparency = 0,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundColor3 = color3_rgb(255, 255, 255),
            BackgroundTransparency = 1,
            BorderColor3 = color3_rgb(0, 0, 0),
            BorderSizePixel = 0,
            Size = udim2(1, 0, 0, 10),
            Position = udim2(0, 0, 0, 4),
            Text = slider.Name or "",
            Visible = slider.Name ~= nil,
            Parent = new_slider,
        });

        -- functions
        local Sliding = false;
        local Val = slider.State;
        local current_tween;
        --
        local function is_set(value)
            value = math.clamp(math.floor(value * slider.Decimals + 0.5) / slider.Decimals, slider.Min, slider.Max);
            local target_size = udim2((value - slider.Min) / (slider.Max - slider.Min), 0, 1, 0);

            if current_tween then current_tween:Cancel() end;
            current_tween = tween_service:Create(Accent, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {Size = target_size});
            current_tween:Play();

            local inlineWidth = Inline.AbsoluteSize.X
            local target_positionx = inlineWidth * target_size.X.Scale
            local horizontalOffset = 5
            local verticalOffset = 3

            local pos = udim2( 0, target_positionx - SliderCircle.AbsoluteSize.X / 2 + horizontalOffset, 1, -SliderCircle.AbsoluteSize.Y / 2 + verticalOffset );
            local circle_tween = tween_service:Create(SliderCircle, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {Position = pos})
            circle_tween:Play()

            Value.Text = slider.Disabled and value == slider.Min and slider.Disabled or slider_name:gsub("%[value%]", string.format("%.14g", value));

            Val = value
            UI.flags[slider.Flag] = value
            slider.Callback(value)
        end
        --
        local function is_sliding(input)
            is_set(((slider.Max - slider.Min) * ((input.Position.X - Inline.AbsolutePosition.X) / Inline.AbsoluteSize.X)) + slider.Min)
        end
        --
        for _, obj in pairs({Inline, Accent}) do
            signals.connection(obj.InputBegan, function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Sliding = true;
                    is_sliding(input);
                end
            end)
            signals.connection(obj.InputEnded, function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then Sliding = false end;
            end)
        end
        --
        signals.connection(uis.InputChanged, function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement and Sliding then
                is_sliding(input);
            end
        end)
        --
        function slider:Set(value)
            is_set(value);
        end;
        flags[slider.Flag] = is_set;
        UI.flags[slider.Flag] = slider.State;
        is_set(slider.State);
        return slider;
    end
    --
    function sections:button(properties)
        local properties = properties or {}
        local button = {
            window = self.Window,
            page = self.Page,
            section = self,
            name = (properties.name or properties.Name or "button"),
            callback = (properties.callback or properties.Callback or properties.callBack or properties.CallBack or function() end),
        };

        local new_button = Instance_manager.new("Frame", {
            Name = "new_button",
            BackgroundTransparency = 1,
            Size = udim2(1, 0, 0, 16),
            Parent = button.section.elements.section_content,
        });

        local outline = Instance_manager.new("Frame", {
            Name = "button_outline",
            BackgroundColor3 = UI.themes.outline,
            Position = udim2(0, 0, 1, -16),
            Size = udim2(1, 0, 0, 22),
            BorderSizePixel = 0,
            Parent = new_button,
        });

        Instance_manager.new("UICorner", {
            Parent = outline,
            CornerRadius = udim(0, 4),
        });

        local inline = Instance_manager.new("TextButton", {
            Name = "button_inline",
            Text = "",
            BackgroundColor3 = UI.themes.background,
            Position = udim2(0, 1, 0, 1),
            Size = udim2(1, -2, 1, -2),
            FontFace = UI.font,
            BorderSizePixel = 0,
            TextSize = 11,
            AutoButtonColor = false,
            Parent = outline,
        });

        Instance_manager.new("UICorner", {
            Parent = inline,
            CornerRadius = udim(0, 4),
        });

        local text = Instance_manager.new("TextLabel", {
            Name = "button_text",
            FontFace = UI.font,
            Text = string.upper(button.name),
            TextColor3 = color3_rgb(255, 255, 255),
            TextSize = UI.font_size,
            BackgroundTransparency = 1,
            Size = udim2(1, 0, 1, 0),
            Parent = inline,
        });

        new_button.MouseEnter:Connect(function()
            tween_service:Create(outline, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = UI.themes.accent}):Play()
        end)

        new_button.MouseLeave:Connect(function()
            tween_service:Create(outline, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = UI.themes.outline}):Play()
        end)

        local confirm = false
        signals.connection(inline.MouseButton1Down, function()
            if (not confirm) then
                confirm = true
                text.Text = "ARE YOU SURE?"

                delay(2, function()
                    if confirm then
                        confirm = false
                        text.Text = string.upper(button.name);
                    end
                end)
            else
                confirm = false
                button.callback()
                text.Text = string.upper(button.name);
            end
        end);

        return button;
    end;
    --
    function sections:dropdown(Properties)
        local Properties = Properties or {};
        local Dropdown = {
            Window = self.Window,
            Page = self.Page,
            Section = self,
            Open = false,
            description = (Properties.description or Properties.Description),
            Name = Properties.Name or Properties.name or nil,
            Options = (Properties.options or Properties.Options or Properties.values or Properties.Values or {"1", "2", "3",}),
            Max = (Properties.Max or Properties.max or nil),
            ScrollMax = (Properties.ScrollingMax or Properties.scrollingmax or nil),
            State = (Properties.state or Properties.State or Properties.def or Properties.Def or Properties.default or Properties.Default or nil),
            Callback = (Properties.callback or Properties.Callback or Properties.callBack or Properties.CallBack or function() end),
            Flag = (Properties.flag or Properties.Flag or Properties.pointer or Properties.Pointer or UI.next_flag()),
            OptionInsts = {},
        };
        --
        local NewList = Instance_manager.new("Frame", {
            Name = "NewList",
            BackgroundColor3 = color3_rgb(255, 255, 255),
            BackgroundTransparency = 1,
            BorderColor3 = color3_rgb(0, 0, 0),
            BorderSizePixel = 0,
            Size = udim2(1, 0, 0, Dropdown.Name ~= nil and 20 or 16),
            Parent = Dropdown.Section.elements.section_content
        });

        local Outline = Instance_manager.new("Frame", {
            Name = "List_Outline",
            BackgroundColor3 = UI.themes.outline,
            BorderSizePixel = 0,
            BorderColor3 = color3_rgb(0, 0, 0),
            Position = udim2(0.5, 0, 0, -5),
            Size = udim2(0.5, 0, 0, 18),
            Parent = NewList
        });

        Instance_manager.new("UICorner", {
            Parent = Outline,
            CornerRadius = udim(0, 6),
        });

        local Inline = Instance_manager.new("TextButton", {
            Name = "List_Inline",
            BackgroundColor3 = UI.themes.background,
            BorderColor3 = color3_rgb(0, 0, 0),
            BorderSizePixel = 0,
            Position = udim2(0, 1, 0, 1),
            Size = udim2(1, -2, 1, -2),
            FontFace = UI.font,
            Text = "",
            TextColor3 = color3_rgb(0, 0, 0),
            TextSize = UI.font_size,
            AutoButtonColor = false,
            Parent = Outline
        });

        Instance_manager.new("UICorner", {
            Parent = Inline,
            CornerRadius = udim(0, 5),
        });

        local Value = Instance_manager.new("TextLabel", {
            Name = "Value",
            FontFace = UI.font,
            Text = "None",
            TextColor3 = color3_rgb(255, 255, 255),
            TextSize = UI.font_size,
            TextStrokeTransparency = 0,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundColor3 = color3_rgb(255, 255, 255),
            BackgroundTransparency = 1,
            BorderColor3 = color3_rgb(0, 0, 0),
            BorderSizePixel = 0,
            Position = udim2(0, 5, 0, 0),
            Size = udim2(0.75, 0, 1, 0),
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = Inline
        });

        local Icon = Instance_manager.new("ImageLabel", {
            Name = "Dropdown_Icon",
            Image = "http://www.roblox.com/asset/?id=13184099706",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ImageColor3 = color3_rgb(98,98,98),
            Size = udim2(0, 8, 0, 10),
            Position = udim2(1, -5, 0.5, 0),
            AnchorPoint = vec2(1, 0.5),
            ScaleType = Enum.ScaleType.Fit,
            Parent = Inline
        });

        local ContentOutline = Instance_manager.new("Frame", {
            Name = "List_ContentOutline",
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = UI.themes.outline,
            BorderSizePixel = 0,
            Position = udim2(0, 1, 1, 2),
            Size = udim2(1, -2, 0, 0),
            Visible = false,
            Parent = Outline
        });

        Instance_manager.new("UICorner", {
            Parent = ContentOutline,
            CornerRadius = udim(0, 6),
        });

        local ContentInline = Instance_manager.new("Frame", {
            Name = "List_ContentInline",
            BackgroundColor3 = UI.themes.background,
            BorderColor3 = color3_rgb(0, 0, 0),
            BorderSizePixel = 0,
            Position = udim2(0, 2, 0, 1),
            Size = udim2(1, -3, 1, 0),
            Parent = ContentOutline
        });

        Instance_manager.new("UICorner", {
            Parent = ContentInline,
            CornerRadius = udim(0, 6),
        });

        local UIListLayout = Instance_manager.new("UIListLayout", {
            Name = "UIListLayout",
            Padding = udim(0, 2),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = ContentInline
        });

        local UIPadding = Instance_manager.new("UIPadding", {
            Name = "UIPadding",
            PaddingBottom = udim(0, 2),
            PaddingTop = udim(0, 2),
            Parent = ContentInline
        });

        local description = Instance_manager.new("TextLabel", {
            Name = "description",
            FontFace = UI.font,
            TextColor3 = UI.themes.inactive,
            TextSize = UI.font_size,
            TextStrokeTransparency = 0,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundColor3 = color3_rgb(255, 255, 255),
            BackgroundTransparency = 1,
            BorderColor3 = color3_rgb(0, 0, 0),
            BorderSizePixel = 0,
            Size = udim2(1, 0, 0, 10),
            Parent = NewList,
            Position = udim2(0, 0, 0, 17),
            Visible = Dropdown.Name ~= nil and true or false,
            Text = Dropdown.description ~= nil and Dropdown.description or "",
            ZIndex = -1
        });

        local title = Instance_manager.new("TextLabel", {
            Name = "title",
            FontFace = UI.font,
            TextColor3 = color3_rgb(255, 255, 255),
            TextSize = UI.font_size,
            TextStrokeTransparency = 0,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundColor3 = color3_rgb(255, 255, 255),
            BackgroundTransparency = 1,
            BorderColor3 = color3_rgb(0, 0, 0),
            BorderSizePixel = 0,
            Size = udim2(1, 0, 0, 10),
            Parent = NewList,
            Visible = Dropdown.Name ~= nil and true or false,
            Text = Dropdown.Name ~= nil and Dropdown.Name or ""
        });

        -- connections
        signals.connection(Inline.MouseButton1Down, function()
            ContentOutline.Visible = not ContentOutline.Visible
            tween_service:Create(Icon, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Rotation = ContentOutline.Visible and 180 or 0}):Play()
            NewList.ZIndex = ContentOutline.Visible and 5 or 1
        end)
        signals.connection(uis.InputBegan, function(Input)
            if ContentOutline.Visible and Input.UserInputType == Enum.UserInputType.MouseButton1 then
                if not UI:IsMouseOverFrame(ContentOutline) and not UI:IsMouseOverFrame(Inline) then
                    ContentOutline.Visible = false
                    NewList.ZIndex = 1
                    tween_service:Create(Icon, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Rotation = 0}):Play()
                end
            end
        end)
        --
        local chosen = Dropdown.Max and {} or nil
        local Count = 0
        local previousAccentLine
        local previousText
        --
        local function handleoptionclick(option, button, text, AccentLine)
            button.MouseButton1Down:Connect(function()
                if Dropdown.Max then
                    if table.find(chosen, option) then
                        table.remove(chosen, table.find(chosen, option))
                        text.TextColor3 = UI.themes.inactive
                        AccentLine.BackgroundTransparency = 1
                    else
                        if #chosen == Dropdown.Max then
                            local firstChosen = table.remove(chosen, 1)
                            Dropdown.OptionInsts[firstChosen].text.TextColor3 = UI.themes.inactive
                            Dropdown.OptionInsts[firstChosen].accent.BackgroundTransparency = 1
                        end
                        table.insert(chosen, option)
                        text.TextColor3 = UI.themes.accent
                        AccentLine.BackgroundTransparency = 0
                    end

                    local textchosen = {}
                    for _, opt in next, chosen do
                        table.insert(textchosen, opt)
                    end
                    Value.Text = #chosen == 0 and "" or table.concat(textchosen, ",")
                    UI.flags[Dropdown.Flag] = chosen
                    Dropdown.Callback(chosen)
                else
                    if previousAccentLine then
                        previousAccentLine.BackgroundTransparency = 1
                    end
                    if previousText then
                        previousText.TextColor3 = UI.themes.inactive
                    end

                    for opt, tbl in next, Dropdown.OptionInsts do
                        tbl.text.TextColor3 = UI.themes.inactive
                        tbl.accent.BackgroundTransparency = 1
                    end

                    chosen = option
                    Value.Text = option
                    text.TextColor3 = UI.themes.accent
                    AccentLine.BackgroundTransparency = 0
                    previousAccentLine = AccentLine
                    previousText = text
                    ContentOutline.Visible = false
                    NewList.ZIndex = 1
                    tween_service:Create(Icon, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Rotation = 0}):Play()
                    UI.flags[Dropdown.Flag] = option
                    Dropdown.Callback(option)
                end
            end)
        end
        --
        local function createoptions(tbl)
            for _, option in next, tbl do
                Dropdown.OptionInsts[option] = {}
                --
                local NewOption = Instance_manager.new("TextButton", {
                    Name = "NewOption",
                    FontFace = UI.font,
                    Text = "",
                    TextColor3 = color3_rgb(255, 255, 255),
                    TextSize = UI.font_size,
                    TextStrokeTransparency = 0,
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    AutoButtonColor = false,
                    BackgroundTransparency = 1,
                    Size = udim2(1, 0, 0, 14),
                    Parent = ContentInline
                });
                local AccentLine = Instance_manager.new("Frame", {
                    Name = "AccentLine",
                    BackgroundColor3 = UI.themes.accent,
                    Size = udim2(0, 1, 1, 0),
                    BackgroundTransparency = 1,
                    Parent = NewOption
                });
                local OptionLabel = Instance_manager.new("TextLabel", {
                    Name = "OptionLabel",
                    FontFace = UI.font,
                    Text = option,
                    TextColor3 = color3_rgb(145, 145, 145),
                    TextSize = UI.font_size,
                    TextStrokeTransparency = 0,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BackgroundTransparency = 1,
                    Position = udim2(0, 4, 0, 0),
                    Size = udim2(1, 0, 1, 0),
                    Parent = NewOption
                });

                Count = Count + 1
                Dropdown.OptionInsts[option].text = OptionLabel
                Dropdown.OptionInsts[option].accent = AccentLine
                handleoptionclick(option, NewOption, OptionLabel, AccentLine)
            end
        end
        createoptions(Dropdown.Options)
        --
        local set
        set = function(option)
            if Dropdown.Max then
                table.clear(chosen)
                option = type(option) == "table" and option or {}

                for opt, tbl in next, Dropdown.OptionInsts do
                    if not table.find(option, opt) then
                        tbl.text.TextColor3 = UI.themes.inactive
                        tbl.accent.BackgroundTransparency = 1
                    end
                end

                for _, opt in next, option do
                    if table.find(Dropdown.Options, opt) and #chosen < Dropdown.Max then
                        table.insert(chosen, opt)
                        Dropdown.OptionInsts[opt].text.TextColor3 = UI.themes.accent
                        Dropdown.OptionInsts[opt].accent.BackgroundTransparency = 0
                    end
                end

                local textchosen = {}
                local cutobject = false

                for _, opt in next, chosen do
                    table.insert(textchosen, opt)
                end

                Value.Text = #chosen == 0 and "" or table.concat(textchosen, ",") .. (cutobject and ", ..." or "")

                UI.flags[Dropdown.Flag] = chosen
                Dropdown.Callback(chosen)
            end
        end
        --
        function Dropdown:Set(option)
            if Dropdown.Max then
                set(option)
            else
                for opt, tbl in next, Dropdown.OptionInsts do
                    if opt ~= option then
                        tbl.text.TextColor3 = UI.themes.inactive
                        tbl.accent.BackgroundTransparency = 1
                    end
                end
                if table.find(Dropdown.Options, option) then
                    chosen = option
                    Dropdown.OptionInsts[option].text.TextColor3 = UI.themes.accent
                    Dropdown.OptionInsts[option].accent.BackgroundTransparency = 0
                    Value.Text = option
                    UI.flags[Dropdown.Flag] = chosen
                    Dropdown.Callback(chosen)
                else
                    chosen = nil
                    Value.Text = "None"
                    UI.flags[Dropdown.Flag] = chosen
                    Dropdown.Callback(chosen)
                end
            end
        end
        --
        function Dropdown:Refresh(tbl)
            for _, opt in next, Dropdown.OptionInsts do
                coroutine.wrap(function()
                    pcall(function()
                        opt.button:Destroy()
                    end)
                end)()
            end
            table.clear(Dropdown.OptionInsts)

            createoptions(tbl)

            if Dropdown.Max then
                table.clear(chosen)
            else
                chosen = nil
            end

            UI.flags[Dropdown.Flag] = chosen
            Dropdown.Callback(chosen)
        end

        if Dropdown.Max then
            flags[Dropdown.Flag] = set
        else
            flags[Dropdown.Flag] = Dropdown
        end
        Dropdown:Set(Dropdown.State)
        return Dropdown
    end
    --
    function sections:textbox(Properties)
        local Properties = Properties or {};
        local textbox = {
            Window = self.Window,
            Page = self.Page,
            Section = self,
            Name = (Properties.Name or Properties.name or nil),
            Placeholder = (Properties.placeholder or Properties.Placeholder or Properties.holder or Properties.Holder or ""),
            State = (Properties.state or Properties.State or Properties.def or Properties.Def or Properties.default or Properties.Default or ""),
            Callback = (Properties.callback or Properties.Callback or Properties.callBack or Properties.CallBack or function() end),
            Flag = (Properties.flag or Properties.Flag or Properties.pointer or Properties.Pointer or UI.next_flag()),
        };
        --
        local NewBox = Instance_manager.new("TextButton", {
            Name = "NewBox",
            FontFace = UI.font,
            Text = "",
            TextColor3 = color3_rgb(0, 0, 0),
            TextSize = UI.font_size,
            AutoButtonColor = false,
            BackgroundColor3 = color3_rgb(255, 255, 255),
            BackgroundTransparency = 1,
            BorderColor3 = color3_rgb(0, 0, 0),
            BorderSizePixel = 0,
            Size = udim2(1, 0, 0, textbox.Name ~= nil and 30 or 20),
            Parent = textbox.Section.elements.section_content
        });

        local Outline = Instance_manager.new("Frame", {
            Name = "textbox_outline",
            BackgroundColor3 = UI.themes.outline,
            BorderColor3 = color3_rgb(0, 0, 0),
            BorderSizePixel = 0,
            Position = udim2(0, 0, 1, -16),
            Size = udim2(1, 0, 0, 20),
            Parent = NewBox
        });

        Instance_manager.new("UICorner", {
            Parent = Outline,
            CornerRadius = udim(0, 4),
        });

        local Inline = Instance_manager.new("Frame", {
            Name = "textbox_inline",
            BackgroundColor3 = UI.themes.background,
            BorderColor3 = color3_rgb(0, 0, 0),
            BorderSizePixel = 0,
            Position = udim2(0, 1, 0, 1),
            Size = udim2(1, -2, 1, -2),
            Parent = Outline
        });

        Instance_manager.new("UICorner", {
            Parent = Inline,
            CornerRadius = udim(0, 4),
        });

        local Value = Instance_manager.new("TextBox", {
            Name = "text",
            FontFace = UI.font,
            Text = textbox.State,
            PlaceholderText = textbox.Placeholder,
            TextColor3 = color3_rgb(255, 255, 255),
            PlaceholderColor3 = UI.themes.inactive,
            TextSize = UI.font_size,
            TextStrokeTransparency = 0,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundColor3 = color3_rgb(255, 255, 255),
            BackgroundTransparency = 1,
            BorderColor3 = color3_rgb(0, 0, 0),
            BorderSizePixel = 0,
            Position = udim2(0, 4, 0, 0),
            Size = udim2(1, 0, 1, 0),
            Parent = Inline,
            ClearTextOnFocus = false
        });

        local Title = Instance_manager.new("TextLabel", {
            Name = "title",
            FontFace = UI.font,
            TextColor3 = color3_rgb(255, 255, 255),
            TextSize = UI.font_size,
            TextStrokeTransparency = 0,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundColor3 = color3_rgb(255, 255, 255),
            BackgroundTransparency = 1,
            BorderColor3 = color3_rgb(0, 0, 0),
            BorderSizePixel = 0,
            Size = udim2(1, 0, 0, 10),
            Parent = NewBox,
            Position = udim2(0, 2, 0, 0),
            Text = textbox.Name ~= nil and textbox.Name or "",
            Visible = textbox.Name ~= nil and true or false
        });
        --
        Value.FocusLost:Connect(function()
            textbox.Callback(Value.Text);
            UI.flags[textbox.Flag] = Value.Text;
        end)
        --
        local function set(str)
            Value.Text = str;
            UI.flags[textbox.Flag] = str;
            textbox.Callback(str);
        end

        flags[textbox.Flag] = set;
        return textbox;
    end;
    --
    function sections:listbox(Properties)
        local Dropdown = {
            Window = self.Window,
            Page = self.Page,
            Section = self,
            Open = Properties.open or false,
            Options = Properties.options or Properties.Options or Properties.values or Properties.Values or {"1", "2", "3"},
            Max = Properties.Max or Properties.max or nil,
            ScrollMax = Properties.ScrollingMax or Properties.scrollingmax or nil,
            State = Properties.state or Properties.State or Properties.def or Properties.Def or Properties.default or Properties.Default or nil,
            Callback = Properties.callback or Properties.Callback or Properties.callBack or Properties.CallBack or function() end,
            Flag = Properties.flag or Properties.Flag or Properties.pointer or Properties.Pointer or UI.next_flag(),
            OptionInsts = {}
        };

        local NewList = Instance_manager.new("TextButton", {
            Name = "NewList",
            FontFace = UI.font,
            Text = "",
            TextColor3 = color3_rgb(0, 0, 0),
            TextSize = UI.font_size,
            AutoButtonColor = false,
            BackgroundColor3 = UI.themes.outline,
            BackgroundTransparency = 0,
            BorderColor3 = color3_rgb(0, 0, 0),
            BorderSizePixel = 0,
            Size = udim2(1, 0, 0, (14 * (Dropdown.ScrollMax or #Dropdown.Options)) + (2 * (Dropdown.ScrollMax or #Dropdown.Options)) + 4),
            Parent = Dropdown.Section.elements.section_content
        });

        NewList.MouseEnter:Connect(function()
            tween_service:Create(NewList, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = UI.themes.accent}):Play();
        end);

        NewList.MouseLeave:Connect(function()
            tween_service:Create(NewList, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = UI.themes.outline}):Play();
        end);

        local ContentOutline = Instance_manager.new("Frame", {
            Name = "ContentOutline",
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = UI.themes.outline,
            BorderColor3 = color3_rgb(0, 0, 0),
            Size = udim2(1, 0, 1, 0),
            Parent = NewList
        });

        Instance_manager.new("UICorner", {
            Parent = ContentOutline,
            CornerRadius = udim(0, 8),
        });

        local ContentInline = Instance_manager.new("ScrollingFrame", {
            Name = "ContentInline",
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            BottomImage = "rbxassetid://7783554086",
            CanvasSize = udim2(),
            MidImage = "rbxassetid://7783554086",
            ScrollBarImageColor3 = UI.themes.accent,
            ScrollBarThickness = 4,
            Active = true,
            BackgroundColor3 = UI.themes.background,
            BorderColor3 = color3_rgb(0, 0, 0),
            BorderSizePixel = 0,
            Position = udim2(0, 1, 0, 1),
            Size = udim2(1, -2, 1, -2),
            Parent = ContentOutline
        });

        Instance_manager.new("UICorner", {
            Parent = ContentInline,
            CornerRadius = udim(0, 8),
        });

        Instance_manager.new("UIListLayout", {
            Name = "UIListLayout",
            Padding = udim(0, 2),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = ContentInline
        });

        Instance_manager.new("UIPadding", {
            Name = "UIPadding",
            PaddingBottom = udim(0, 2),
            PaddingTop = udim(0, 2),
            Parent = ContentInline
        });

        local function handleOptionClick(option, button, label)
            button.MouseButton1Down:Connect(function()
                for _, opt in pairs(Dropdown.OptionInsts) do
                    tween_service:Create(opt.label, TweenInfo.new(0.33), { TextColor3 = UI.themes.inactive }):Play()
                end
                tween_service:Create(label, TweenInfo.new(0.33), { TextColor3 = UI.themes.accent }):Play()
                UI.flags[Dropdown.Flag] = option
                Dropdown.Callback(option)
            end);
        end;

        for _, option in ipairs(Dropdown.Options) do
            local button = Instance_manager.new("TextButton", {
                Name = "Option",
                Text = "",
                Size = udim2(1, 0, 0, 14),
                BackgroundTransparency = 1,
                Parent = ContentInline
            });

            local label = Instance_manager.new("TextLabel", {
                Text = option,
                TextColor3 = UI.themes.inactive,
                BackgroundTransparency = 1,
                Size = udim2(1, 0, 1, 0),
                FontFace = UI.font,
                TextSize = UI.font_size,
                TextXAlignment = Enum.TextXAlignment.Left,
                Position = udim2(0, 5, 0, 0),
                Parent = button
            });

            Dropdown.OptionInsts[option] = { label = label };
            handleOptionClick(option, button, label);
        end;

        function Dropdown:Set(option)
            UI.flags[Dropdown.Flag] = option
            Dropdown.Callback(option)
        end;

        function Dropdown:Refresh(options)
            for _, opt in pairs(Dropdown.OptionInsts) do opt.label.Parent:Destroy() end;
            Dropdown.OptionInsts = {}
            for _, option in ipairs(options) do
                local button = Instance_manager.new("TextButton", {
                    Name = "Option",
                    Text = "",
                    Size = udim2(1, 0, 0, 14),
                    BackgroundTransparency = 1,
                    Parent = ContentInline
                });

                local label = Instance_manager.new("TextLabel", {
                    Text = option,
                    TextColor3 = UI.themes.inactive,
                    BackgroundTransparency = 1,
                    Size = udim2(1, 0, 1, 0),
                    FontFace = UI.font,
                    TextSize = UI.font_size,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Position = udim2(0, 5, 0, 0),
                    Parent = button
                });

                Dropdown.OptionInsts[option] = { label = label }
                handleOptionClick(option, button, label)
            end;
            Dropdown:Set(Dropdown.State)
        end;

        Dropdown:Set(Dropdown.State);
        return Dropdown;
    end;
    --
    function sections:colorpicker(Properties)
        local Properties = Properties or {};
        local Colorpicker = {
            Window = self.Window,
            Page = self.Page,
            Section = self,
            Name = (Properties.Name or Properties.name or "Colorpicker"),
            Description = (Properties.Description or Properties.description),
            State = (Properties.state or Properties.State or Properties.def or Properties.Def or Properties.default or Properties.Default or Color3.fromRGB(255, 0, 0)),
            Alpha = (Properties.alpha or Properties.Alpha or Properties.transparency or Properties.Transparency or 1),
            Callback = (Properties.callback or Properties.Callback or Properties.callBack or Properties.CallBack or function() end),
            Flag = (Properties.flag or Properties.Flag or Properties.pointer or Properties.Pointer or UI.next_flag()),
            Colorpickers = 0,
        };
        --
        local NewColor = Instance.new("TextButton");
        local Title = Instance.new("TextLabel");
        local Description = Instance.new("TextLabel");

        do -- properties
            NewColor.Name = "NewColor"
            NewColor.FontFace = UI.font
            NewColor.Text = ""
            NewColor.TextColor3 = Color3.fromRGB(0, 0, 0)
            NewColor.TextSize = UI.font_size
            NewColor.AutoButtonColor = false
            NewColor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            NewColor.BackgroundTransparency = 1
            NewColor.BorderColor3 = Color3.fromRGB(0, 0, 0)
            NewColor.BorderSizePixel = 0
            NewColor.Size = UDim2.new(1, 0, 0, 20)
            NewColor.Parent = Colorpicker.Section.elements.section_content

            Instance_manager.new("UICorner", {
                Parent = NewColor;
                CornerRadius = udim(0, 4);
            });

            Title.Name = "Title"
            Title.FontFace = UI.font
            Title.TextColor3 = Color3.fromRGB(255, 255, 255)
            Title.TextSize = UI.font_size
            Title.TextStrokeTransparency = 0
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Title.BackgroundTransparency = 1
            Title.BorderColor3 = Color3.fromRGB(0, 0, 0)
            Title.BorderSizePixel = 0
            Title.Size = UDim2.new(1, 0, 1, 0)
            Title.Parent = NewColor
            Title.Text = Colorpicker.Name

            Description.Name = "Description"
            Description.FontFace = UI.font
            Description.TextColor3 = UI.themes.inactive
            Description.TextSize = UI.font_size
            Description.TextStrokeTransparency = 0
            Description.TextXAlignment = Enum.TextXAlignment.Left
            Description.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Description.BackgroundTransparency = 1
            Description.BorderColor3 = Color3.fromRGB(0, 0, 0)
            Description.BorderSizePixel = 0
            Description.Size = UDim2.new(1, 0, 1, 0)
            Description.Position = udim2(0, 0, 0, 15)
            Description.Parent = NewColor
            Description.Text = Colorpicker.Description or "Description"
        end;
        --
        Colorpicker.Colorpickers = Colorpicker.Colorpickers + 1
        local colorpickertypes = UI:NewPicker(
            Colorpicker.Name,
            Colorpicker.State,
            Colorpicker.Alpha,
            NewColor,
            Colorpicker.Colorpickers,
            Colorpicker.Flag,
            Colorpicker.Callback
        );

        function Colorpicker:Set(color)
            colorpickertypes:set(color, false, true);
        end;

        function Colorpicker:colorpicker(Properties)
            local Properties = Properties or {};
            local NewColorpicker = {
                State = (Properties.state or Properties.State or Properties.def or Properties.Def or Properties.default or Properties.Default or Color3.fromRGB(255, 0, 0)),
                Alpha = (Properties.alpha or Properties.Alpha or Properties.transparency or Properties.Transparency or 1),
                Description = (Properties.description or Properties.Description or Properties.Info or Properties.info or "Description"),
                Callback = (Properties.callback or Properties.Callback or Properties.callBack or Properties.CallBack or function() end),
                Flag = (Properties.flag or Properties.Flag or Properties.pointer or Properties.Pointer or UI.next_flag()),
            };
            --
            Colorpicker.Colorpickers = Colorpicker.Colorpickers + 1
            local Newcolorpickertypes = UI:NewPicker(
                "",
                NewColorpicker.State,
                NewColorpicker.Alpha,
                NewColor,
                Colorpicker.Colorpickers,
                NewColorpicker.Flag,
                NewColorpicker.Callback
            );

            function NewColorpicker:Set(color)
                Newcolorpickertypes:Set(color);
            end;

            return NewColorpicker;
        end
        return Colorpicker;
    end
    --
    function sections:keybind(Properties)
        local Properties = Properties or {}
        local Keybind = {
            Section = self,
            Name = (Properties.name or Properties.Name or "Keybind"),
            description = (Properties.description or Properties.Description or ""),
            State = (Properties.state or Properties.State or Properties.def or Properties.Def or Properties.default or Properties.Default or nil),
            Mode = (Properties.mode or Properties.Mode or "Toggle"),
            UseKey = (Properties.UseKey or Properties.usekey or false),
            Ignore = (Properties.ignore or Properties.Ignore or false),
            Callback = (Properties.callback or Properties.Callback or Properties.callBack or Properties.CallBack or function() end),
            Flag = (Properties.flag or Properties.Flag or Properties.pointer or Properties.Pointer or UI.next_flag()),
            Binding = nil,
        };
        local State, Key = false
        --[[local ListValue;
        if not Keybind.Ignore then
            ListValue = library.keybind_list:NewKey(Keybind.State, Keybind.Name)
        end]]
        --
        local NewBind = Instance_manager.new("Frame", {
            Name = "NewBind",
            BackgroundTransparency = 1,
            Size = udim2(1, 0, 0, 15),
            Parent = Keybind.Section.elements.section_content
        });

        local Title = Instance_manager.new("TextLabel", {
            Name = "Title",
            FontFace = UI.font,
            TextColor3 = color3_rgb(255, 255, 255),
            TextSize = UI.font_size,
            TextStrokeTransparency = 0,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1,
            Size = udim2(1, 0, 1, 0),
            Parent = NewBind,
            Text = Keybind.Name
        });

        local description = Instance_manager.new("TextLabel", {
            Name = "description",
            FontFace = UI.font,
            TextColor3 = UI.themes.inactive,
            TextSize = UI.font_size,
            TextStrokeTransparency = 0,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1,
            Size = udim2(1, 0, 1, 0),
            Parent = NewBind,
            Position = udim2(0, 0, 0, 15),
            Text = Keybind.description
        });

        local Outline = Instance_manager.new("Frame", {
            Name = "Keybind_Outline",
            AnchorPoint = vec2(1, 0.5),
            BackgroundColor3 = UI.themes.outline,
            Position = udim2(1, -1, 0.85, 0),
            Size = udim2(0, 65, 1.75, 0),
            Parent = NewBind
        });

        Instance_manager.new("UICorner", {
            Parent = Outline,
            CornerRadius = udim(0, 3)
        });

        local Inline = Instance_manager.new("TextButton", {
            Name = "Keybind_Inline",
            BackgroundColor3 = UI.themes.background,
            Position = udim2(0, 1, 0, 1),
            Size = udim2(1, -2, 1, -2),
            FontFace = UI.font,
            Text = "",
            TextColor3 = color3_rgb(0, 0, 0),
            TextSize = UI.font_size,
            AutoButtonColor = false,
            Parent = Outline
        });

        Instance_manager.new("UICorner", {
            Parent = Inline,
            CornerRadius = udim(0, 3)
        });

        local Container = Instance_manager.new("Frame", {
            Name = "Container",
            BackgroundTransparency = 1,
            AnchorPoint = vec2(0.5, 0.5),
            Position = udim2(0.47, 0, 0.5, 0),
            Size = udim2(0, 0, 1, 0),
            AutomaticSize = Enum.AutomaticSize.X,
            Parent = Inline
        });

        local Icon = Instance_manager.new("ImageLabel", {
            Name = "Bind_Icon",
            Image = "http://www.roblox.com/asset/?id=16081386298",
            BackgroundTransparency = 1,
            ImageColor3 = UI.themes.inactive,
            AnchorPoint = vec2(0, 0.5),
            Position = udim2(0, 1, 0.5, 0),
            Size = udim2(0, 20, 0, 20),
            Parent = Container
        });

        local Value = Instance_manager.new("TextLabel", {
            Name = "Value",
            FontFace = UI.font,
            Text = "None",
            TextColor3 = color3_rgb(100, 100, 100),
            TextSize = UI.font_size,
            TextStrokeTransparency = 0,
            BackgroundTransparency = 1,
            AnchorPoint = vec2(0, 0.5),
            Position = udim2(0, 23, 0.5, 0),
            Size = udim2(0, 0, 1, 0),
            AutomaticSize = Enum.AutomaticSize.X,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Container
        });
        Inline.Size = udim2(1, -2, 1, -2);

        Inline.MouseEnter:Connect(function()
            tween_service:Create(Inline, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = UI.themes.accent}):Play()
        end)

        Inline.MouseLeave:Connect(function()
            tween_service:Create(Inline, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = UI.themes.background}):Play()
        end)

        Inline.MouseEnter:Connect(function()
            tween_service:Create(Value, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = color3_rgb(200, 200, 200)}):Play()
        end)

        Inline.MouseLeave:Connect(function()
            tween_service:Create(Value, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = color3_rgb(100, 100, 100)}):Play()
        end)

        local ModeBox = Instance_manager.new("Frame", {
            Name = "ModeBox",
            Parent = Outline,
            AnchorPoint = vec2(0,0.5),
            BackgroundColor3 = UI.themes.background,
            BorderColor3 = UI.themes.outline,
            BorderSizePixel = 1,
            Size = udim2(0, 65, 0, 60),
            Position = udim2(0,-70,3,0),
            Visible = false,
            ZIndex = 99999
        });

        local Hold = Instance_manager.new("TextButton", {
            Name = "Hold",
            Parent = ModeBox,
            BackgroundTransparency = 1,
            Size = udim2(1, 0, 0.333, 0),
            ZIndex = 2,
            FontFace = UI.font,
            Text = "Hold",
            TextColor3 = Keybind.Mode == "Hold" and color3_rgb(255,255,255) or color3_rgb(145,145,145),
            TextSize = UI.font_size,
            TextStrokeTransparency = 0
        });

        local Toggle = Instance_manager.new("TextButton", {
            Name = "Toggle",
            Parent = ModeBox,
            BackgroundTransparency = 1,
            Position = udim2(0, 0, 0.333, 0),
            Size = udim2(1, 0, 0.333, 0),
            ZIndex = 2,
            FontFace = UI.font,
            Text = "Toggle",
            TextColor3 = Keybind.Mode == "Toggle" and color3_rgb(255,255,255) or color3_rgb(145,145,145),
            TextSize = UI.font_size,
            TextStrokeTransparency = 0
        });

        local Always = Instance_manager.new("TextButton", {
            Name = "Always",
            Parent = ModeBox,
            BackgroundTransparency = 1,
            Position = udim2(0, 0, 0.667, 0),
            Size = udim2(1, 0, 0.333, 0),
            ZIndex = 2,
            FontFace = UI.font,
            Text = "Always",
            TextColor3 = Keybind.Mode == "Always" and color3_rgb(255,255,255) or color3_rgb(145,145,145),
            TextSize = UI.font_size,
            TextStrokeTransparency = 0
        });

        -- functions
        local function set(newkey)
            if string.find(tostring(newkey), "Enum") then
                if c then
                    c:Disconnect()
                    if Keybind.Flag then
                        UI.flags[Keybind.Flag] = false
                    end
                    Keybind.Callback(false)
                end
                if tostring(newkey):find("Enum.KeyCode.") then
                    newkey = Enum.KeyCode[tostring(newkey):gsub("Enum.KeyCode.", "")]
                elseif tostring(newkey):find("Enum.UserInputType.") then
                    newkey = Enum.UserInputType[tostring(newkey):gsub("Enum.UserInputType.", "")]
                end
                if newkey == Enum.KeyCode.Backspace then
                    Key = nil
                    if Keybind.UseKey then
                        if Keybind.Flag then
                            UI.flags[Keybind.Flag] = Key
                        end
                        Keybind.Callback(Key)
                    end
                    local text = "None"
                    Value.Text = text
                    --[[if not Keybind.Ignore then
                        ListValue:Update(text, Keybind.Name)
                    end]]
                    --Outline.Size = udim2(0, Value.TextBounds.X + 10, 1.9, 0)
                elseif newkey ~= nil then
                    Key = newkey
                    if Keybind.UseKey then
                        if Keybind.Flag then
                            UI.flags[Keybind.Flag] = Key
                        end
                        Keybind.Callback(Key)
                    end
                    local text = (UI.keys[newkey] or tostring(newkey):gsub("Enum.KeyCode.", ""))

                    Value.Text = text
                    --[[if not Keybind.Ignore then
                        ListValue:Update(text, Keybind.Name)
                    end]]
                    --Outline.Size = udim2(0, Value.TextBounds.X + 10, 1.9, 0)
                end
                UI.flags[Keybind.Flag .. "_KEY"] = newkey
            elseif table.find({ "Always", "Toggle", "Hold" }, newkey) then
                if not Keybind.UseKey then
                    UI.flags[Keybind.Flag .. "_KEY STATE"] = newkey
                    Keybind.Mode = newkey
                    --[[if not Keybind.Ignore then
                        ListValue:Update((UI.keys[Key] or tostring(Key):gsub("Enum.KeyCode.", "")), Keybind.Name)
                    end]]
                    if Keybind.Mode == "Always" then
                        State = true
                        if Keybind.Flag then
                            UI.flags[Keybind.Flag] = State
                        end
                        Keybind.Callback(true)
                        --ListValue:SetVisible(true)
                    end
                end
            else
                State = newkey
                if Keybind.Flag then
                    UI.flags[Keybind.Flag] = newkey
                end
                Keybind.Callback(newkey)
            end
        end
        --
        set(Keybind.State)
        set(Keybind.Mode)
        Inline.MouseButton1Click:Connect(function()
            if (not Keybind.Binding) then
                Value.Text = "..."

                Keybind.Binding = signals.connection(uis.InputBegan, function(input, gpe)
                    set( input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode or input.UserInputType )
                    Keybind.Binding:Disconnect()
                    task.wait()
                    Keybind.Binding = nil
                end);
            end
        end)
        --
        signals.connection(uis.InputBegan, function(inp)
            if (inp.KeyCode == Key or inp.UserInputType == Key) and not Keybind.Binding and not Keybind.UseKey then
                if Keybind.Mode == "Hold" then
                    if Keybind.Flag then
                        UI.flags[Keybind.Flag] = true
                    end
                    signals.connection(run_service.RenderStepped, function()
                        if Keybind.Callback then
                            Keybind.Callback(true)
                        end
                    end)
                    --[[if not Keybind.Ignore then
                        ListValue:SetVisible(true)
                    end]]
                elseif Keybind.Mode == "Toggle" then
                    State = not State
                    if Keybind.Flag then
                        UI.flags[Keybind.Flag] = State
                    end
                    Keybind.Callback(State)
                    --[[if not Keybind.Ignore then
                        ListValue:SetVisible(State)
                    end]]
                end
            end
        end)
        --
        signals.connection(uis.InputEnded, function(inp)
            if Keybind.Mode == "Hold" and not Keybind.UseKey then
                if Key ~= "" or Key ~= nil then
                    if inp.KeyCode == Key or inp.UserInputType == Key then
                        if c then
                            c:Disconnect()
                            if Keybind.Flag then
                                UI.flags[Keybind.Flag] = false
                            end
                            if Keybind.Callback then
                                Keybind.Callback(false)
                            end
                            --[[if not Keybind.Ignore then
                                ListValue:SetVisible(false)
                            end]]
                        end
                    end
                end
            end
        end)
        --
        signals.connection(Inline.MouseButton2Down, function()
            ModeBox.Visible = true
            NewBind.ZIndex = 5
        end)
        --
        signals.connection(Hold.MouseButton1Down, function()
            set("Hold")
            Hold.TextColor3 = color3_rgb(255,255,255)
            Toggle.TextColor3 = color3_rgb(145,145,145)
            Always.TextColor3 = color3_rgb(145,145,145)
            ModeBox.Visible = false
            NewBind.ZIndex = 1
        end)
        --
        signals.connection(Toggle.MouseButton1Down, function()
            set("Toggle")
            Hold.TextColor3 = color3_rgb(145,145,145)
            Toggle.TextColor3 = color3_rgb(255,255,255)
            Always.TextColor3 = color3_rgb(145,145,145)
            ModeBox.Visible = false
            NewBind.ZIndex = 1
        end)
        --
        signals.connection(Always.MouseButton1Down, function()
            set("Always")
            Hold.TextColor3 = color3_rgb(145,145,145)
            Toggle.TextColor3 = color3_rgb(145,145,145)
            Always.TextColor3 = color3_rgb(255,255,255)
            ModeBox.Visible = false
            NewBind.ZIndex = 1
        end)
        --
        signals.connection(uis.InputBegan, function(Input)
            if ModeBox.Visible and Input.UserInputType == Enum.UserInputType.MouseButton1 then
                local pos, size, mouse = ModeBox.AbsolutePosition, ModeBox.AbsoluteSize, get_mouse
                if not (mouse.X >= pos.X and mouse.X <= pos.X + size.X and mouse.Y >= pos.Y and mouse.Y <= pos.Y + size.Y) then
                    ModeBox.Visible = false
                    NewBind.ZIndex = 1
                end
            end
        end)
        --
        UI.flags[Keybind.Flag .. "_KEY"] = Keybind.State
        UI.flags[Keybind.Flag .. "_KEY STATE"] = Keybind.Mode
        flags[Keybind.Flag] = set
        flags[Keybind.Flag .. "_KEY"] = set
        flags[Keybind.Flag .. "_KEY STATE"] = set
        --
        function Keybind:Set(key)
            set(key);
        end;

        return Keybind;
    end;
end;
do -- open/close
    signals.connection(uis.InputBegan, function(input)
        if input.KeyCode == UI.ui_key then
            pcall(function()
                UI.autoload = not UI.autoload
                UI.menu_gui.Enabled = UI.autoload
                black_bg.Visible = UI.autoload
                blur_effect.Size = UI.autoload and 20 or 0
            end);
        end;
    end);
end;

return {UI, framework, fonts, black_bg, blur_effect};