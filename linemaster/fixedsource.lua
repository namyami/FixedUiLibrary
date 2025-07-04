if getgenv and getgenv().unload_ui then
	getgenv().unload_ui();
end;

local base = {
	tab_index = 0,
	tabs = {},
	tab_lines = {},
	key_flags = {},
	is_open = true,
	save_flags = {},
	current_dropdown = nil,
	current_colorpicker = nil
};

local library_t = {
	theme = {
		accent = Color3.fromRGB(177, 144, 151),
		background_color = Color3.fromRGB(21, 21, 21),
		background_color_picker = Color3.fromRGB(30, 30, 30),
		dots_color = Color3.fromRGB(14, 14, 14),
		text_color = Color3.fromRGB(220, 220, 220)
	},
	cursor = nil,
	toggle_key = Enum.KeyCode.Insert,
	font_size = 12,
	font_link = "https://github.com/bluescan/proggyfonts/blob/master/ProggyOriginal/ProggyClean.ttf?raw=true",
	flags = {},
	font = Font.new("rbxasset://fonts/families/RobotoMono.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
	assets_dir = "index",
	base = table.clone(base)
}; do
	local cloneref = cloneref or function(...) return ... end;
	local gethui = gethui or function() return cloneref(game:GetService("CoreGui")) end;

	local players = cloneref(game:GetService("Players"));
	local user_input_service = cloneref(game:GetService("UserInputService"));
	local tween_service = cloneref(game:GetService("TweenService"));
	local text_service = cloneref(game:GetService("TextService"));
	local run_service = cloneref(game:GetService("RunService"));
	local http_service = cloneref(game:GetService("HttpService"));
	local context_action_service = cloneref(game:GetService("ContextActionService"));

	local local_player = players.LocalPlayer;

	local instances = {};
	local buttons = {};
	local connections = {};

	local signal_t = {}; do
		local connection_mt = {};
		connection_mt.__index = connection_mt;

		connection_mt.Disconnect = function(self)
			local index = table.find(self._signal._connections, self);

			if index then
				table.remove(self._signal._connections, index);
			end;
		end;

		local signal_mt = {};
		signal_mt.__index = signal_mt;

		signal_mt.Connect = function(self, callback)
			local connection = setmetatable({
				_callback = callback,
				_signal = self
			}, connection_mt);

			self._connections[#self._connections + 1] = connection;

			return connection
		end;

		signal_mt.fire = function(self, ...)
			local connections = self._connections;

			for i = 1, #connections do
				connections[i]._callback(...);
			end;
		end;

		signal_t.new = function()
			return setmetatable({
				_connections = {}
			}, signal_mt);
		end;
	end;

	local utility_t = {}; do
		utility_t.new_instance = function(class, properties)
			local instance = Instance.new(class);

			instances[#instances + 1] = instance;

			for property, value in properties do
				instance[property] = value;
			end;

			return instance;
		end;

		utility_t.get_path = function()
			return run_service:IsStudio() and local_player.PlayerGui or gethui();
		end;
		
		utility_t.darken_color = function(color, factor)
			return Color3.new(
				math.clamp(color.R * factor, 0, 1),
				math.clamp(color.G * factor, 0, 1),
				math.clamp(color.B * factor, 0, 1)
			);
		end;

		utility_t.is_mouse_in_frame = function(frame)
			local frame_position = frame.AbsolutePosition;
			local frame_size = frame.AbsoluteSize;

			local mouse_position = user_input_service:GetMouseLocation(); --// use GetMouseLocation instead, local_player:GetMouse is detected on rivals....???

			local mouse_x = mouse_position.X;
			local mouse_y = mouse_position.Y - 58; --// offset to mimic GetMouse in the local_player class

			return mouse_x >= frame_position.X and mouse_x <= frame_position.X + frame_size.X and mouse_y >= frame_position.Y and mouse_y <= frame_position.Y + frame_size.Y;
		end;

		utility_t.connect = function(signal, func)
			local connection = signal:Connect(func);

			connections[#connections + 1] = connection;

			return connection;
		end;
            utility_t.get_textbounds = function(text, size, font, width)
                font = font or Enum.Font.SourceSans
                width = width or math.huge

                return game:GetService("TextService"):GetTextSize(text, size, font, Vector2.new(width, math.huge))
            end



		utility_t.create_outlines = function(frame, outline_data) --// this should only be used for creating multiple outlines!
			local total_thickness = 0;
			local border_size_pixel = -1;

			for i, data in outline_data do
				local outline_color = data.color or Color3.new(1, 1, 1);
				local outline_thickness = 1;
				local outlineTransparency = data.transparency or 0;

				local newtotal_thickness = total_thickness + outline_thickness;

				local outline_frame = utility_t.new_instance("Frame", {
					Size = UDim2.new(1, (total_thickness + border_size_pixel) * 2 + outline_thickness * 2, 1, (total_thickness + border_size_pixel) * 2 + outline_thickness * 2),
					Position = UDim2.new(0, -(total_thickness + border_size_pixel) - outline_thickness, 0, -(total_thickness + border_size_pixel) - outline_thickness),
					BackgroundTransparency = 1,
					Parent = frame,
					Active = false
				});

				if data.zindex then
					outline_frame.ZIndex = data.zindex;
				end;

				utility_t.new_instance("UIStroke", {
					LineJoinMode = Enum.LineJoinMode.Miter,
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
					Color = outline_color,
					Thickness = outline_thickness,
					Transparency = outlineTransparency,
					Parent = outline_frame
				});

				total_thickness = newtotal_thickness;
			end;
		end;

		utility_t.has_property = function(object, property_name)
			local success, _ = pcall(function() 
				object[property_name] = object[property_name];
			end);
			return success;
		end;
		
		utility_t.is_in_main_frame = function(frame, main_frame)
			local frame_position = frame.AbsolutePosition;
			local frame_size = frame.AbsoluteSize;

			local main_frame_position = main_frame.AbsolutePosition;
			local main_frame_size = main_frame.AbsoluteSize;


			return frame_position.X >= main_frame_position.X and frame_position.X + frame_size.X <= main_frame_position.X + main_frame_size.X and frame_position.Y >= main_frame_position.Y and frame_position.Y + frame_size.Y <= main_frame_position.Y + main_frame_size.Y;
		end;

		utility_t.is_parents_visible = function(instance)
			local parent = instance.Parent;
			
			local result = true;

			while parent do
				if not utility_t.has_property(parent, "Visible") then
					parent = parent.Parent;
					continue;
				end;

				if parent.Visible == false then
					result = false;
				end;

				parent = parent.Parent;
			end;

			return result;
		end;

		utility_t.new_button = function(properties)
			local button = utility_t.new_instance("TextLabel", properties);

			local button_object = {
				pressed = signal_t.new();
				button = button
			}

			buttons[#buttons + 1] = button_object;

			return button_object.button, button_object.pressed;
		end;

		if not run_service:IsStudio() then
			writefile(library_t.assets_dir.."/font.ttf", game:HttpGet(library_t.font_link));

    local fonts = {{"proggyclean.ttf", "proggyclean.json", library_t.font_link},}
    for _, font in pairs(fonts) do
        local ttf, json, url = font[1], font[2], font[3]
        if not isfile(ttf) then writefile(ttf, game:HttpGet(url)) end
        if not isfile(json) then
            writefile(json, game:GetService('HttpService'):JSONEncode({name = ttf:match("([^%.]+)"), faces = {{name = "Regular", weight = 200, style = "normal", assetId = getcustomasset(ttf)}}}))
        end
    end
    local Enumed = {}
    for _, font in pairs(fonts) do
        Enumed[font[1]:match("([^%.]+)")] = Font.new(getcustomasset(font[2]), Enum.FontWeight.Regular)
    end
			library_t.font = Enumed.proggyclean
		end;

		if getgenv then
			getgenv().unload_ui = function()
				for i, connection in connections do
					connection:Disconnect();
				end;
	
				for i, instance in instances do
					instance:Destroy();
				end;
			end;
		end;
	end;

	do
		local create_colorpicker = function(self, properties, label, is_toggle)
			local name = properties and properties.name or "colorpicker";
			local default = properties and properties.default or library_t.theme.accent;
			local default_transparency = properties and properties.default_transparency or nil;
			local is_drawing = properties and properties.drawing or false;
			local flag = properties and properties.flag or name;
			local info = properties and properties.info or name;
			local callback = properties and properties.callback or function(...) end;

			local is_open = false;
			local is_dragging_hue = false;
			local is_dragging_transparency = false;
			local is_dragging_main = false;

			library_t.flags[flag] = default_transparency and { color = default, transparency = (is_drawing and 1 - default_transparency or default_transparency) } or { color = default };

			local colorpicker_frame, pressed_signal = utility_t.new_button({
				Parent = label,
				Position = UDim2.new(1, -18, 0, 0),
				Size = UDim2.new(0, 18, 0, 10),
				BackgroundColor3 = Color3.new(1, 1, 1),
				BorderSizePixel = 0,
				TextTransparency = 1
			});

			local colorpicker_gradient = utility_t.new_instance("UIGradient", {
				Parent = colorpicker_frame,
				Color = ColorSequence.new({ColorSequenceKeypoint.new(0, default), ColorSequenceKeypoint.new(1, utility_t.darken_color(default, 0.5))}),
				Rotation = 90
			});

			utility_t.create_outlines(colorpicker_frame, {
				{ color = Color3.fromRGB(14, 14, 14), transparency = 0 },
			});

			local colorpicker_content_holder = utility_t.new_instance("Frame", {
				Parent = self.lib.screen_gui,
				Position = UDim2.new(0, 0, 0, 0),
				Size = UDim2.new(0, 215, 0, 213),
				Visible = false,
				ZIndex = 1000,
				BackgroundColor3 = library_t.theme.background_color_picker,
				BorderSizePixel = 0,
			});
			
			utility_t.new_instance("ImageLabel", {
				Parent = colorpicker_content_holder,
				Size = UDim2.new(1, 0, 1, 0),
				Position = UDim2.new(0, 0, 0, 0),
				BackgroundTransparency = 1,
				ImageColor3 = library_t.theme.dots_color,
				ScaleType = Enum.ScaleType.Tile,
				ZIndex = 1000,
				TileSize = UDim2.new(0, 8, 0, 8),
				Image = "rbxassetid://134950628747280"
			});			

			local top_line = utility_t.new_instance("Frame", {
				Parent = colorpicker_content_holder,
				Position = UDim2.new(0, 0, 0, 0),
				Size = UDim2.new(1, 0, 0, 2),
				BackgroundColor3 = Color3.new(1, 1, 1),
				BorderSizePixel = 0
			});

			local colorpicker_info = utility_t.new_instance("TextLabel", {
				Parent = colorpicker_content_holder,
				Position = UDim2.new(0, 5, 0, 5),
				Size = UDim2.new(1, 0, 0, 14),
				ZIndex = 1002,
				BackgroundTransparency = 1,
				Text = info,
				TextColor3 = library_t.theme.text_color,
				FontFace = library_t.font,
				TextSize = library_t.font_size,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top
			});
			
			utility_t.new_instance("TextLabel", {
				Parent = colorpicker_info,
				Size = UDim2.new(1, 0, 1, 0),
				Position = UDim2.new(0, 1, 0, 1),
				ZIndex = 1001,
				FontFace = library_t.font,
				TextSize = library_t.font_size,
				BackgroundTransparency = 1,
				TextColor3 = Color3.fromRGB(0, 0, 0),
				Text = info,
				BorderSizePixel = 0,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top
			});

			utility_t.new_instance("UIGradient", {
				Parent = top_line,
				Color = ColorSequence.new({ColorSequenceKeypoint.new(0, library_t.theme.accent), ColorSequenceKeypoint.new(1, utility_t.darken_color(library_t.theme.accent, 0.9))}),
				Rotation = 90
			});

			utility_t.new_instance("UIStroke", {
				Parent = colorpicker_content_holder,
				LineJoinMode = Enum.LineJoinMode.Miter,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Color = Color3.fromRGB(14, 14, 14),
				Thickness = 1
			});

			utility_t.create_outlines(colorpicker_content_holder, {
				{ color = Color3.fromRGB(60, 60, 60), thickness = 1, zindex = 1000, },
				{ color = Color3.fromRGB(40, 40, 40), thickness = 1, zindex = 1000, },
				{ color = Color3.fromRGB(40, 40, 40), thickness = 1, zindex = 1000, },
				{ color = Color3.fromRGB(40, 40, 40), thickness = 1, zindex = 1000, },
				{ color = Color3.fromRGB(60, 60, 60), thickness = 1, zindex = 1000, },
				{ color = Color3.fromRGB(31, 31, 31), thickness = 1, zindex = 1000, }
			});
			
			local actual_colorpicker_frame = utility_t.new_instance("ImageLabel", {
				Parent = colorpicker_content_holder,
				ZIndex = 10005,
				Size = UDim2.new(0, 176, 0, 158),
				Position = UDim2.new(0, 5, 0, 24),
				BackgroundColor3 = default,
				BorderSizePixel = 0,
				Image = "rbxassetid://2615689005",
			});

			utility_t.new_instance("UIStroke", {
				Parent = actual_colorpicker_frame,
				LineJoinMode = Enum.LineJoinMode.Miter,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Color = Color3.fromRGB(14, 14, 14),
				Thickness = 1
			});

			utility_t.create_outlines(actual_colorpicker_frame, {
				{ color = Color3.fromRGB(14, 14, 14), transparency = 0 },	
			});

			local colorpicker_hue = utility_t.new_instance("Frame", {
				Parent = colorpicker_content_holder,
				ZIndex = 1001,
				BorderSizePixel = 0,
				Size = UDim2.new(0, 22, 0, 158),
				Position = UDim2.new(0, 188, 0, 24)
			});

			utility_t.new_instance("UIStroke", {
				Parent = colorpicker_hue,
				LineJoinMode = Enum.LineJoinMode.Miter,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Color = Color3.fromRGB(14, 14, 14),
				Thickness = 1
			});

			utility_t.create_outlines(colorpicker_hue, {
				{ color = Color3.fromRGB(14, 14, 14), transparency = 0 },
			});

			utility_t.new_instance("UIGradient", {
				Parent = colorpicker_hue,
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
					ColorSequenceKeypoint.new(0.166, Color3.fromRGB(255, 255, 0)),
					ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
					ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
					ColorSequenceKeypoint.new(0.666, Color3.fromRGB(0, 0, 255)),
					ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
				}),
				Rotation = 90
			});

			local transparency_slider;
			local transparency_slider_gradient;
			local transparency_slider_visualizer;

			if default_transparency then
				transparency_slider = utility_t.new_instance("Frame", {
					Parent = colorpicker_content_holder,
					ZIndex = 1003,
					BorderSizePixel = 0,
					Size = UDim2.new(0, 176, 0, 20),
					Position = UDim2.new(0, 5, 0, 188),
					BackgroundColor3 = default
				});

				utility_t.new_instance("UIStroke", {
					Parent = transparency_slider,
					LineJoinMode = Enum.LineJoinMode.Miter,
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
					Color = Color3.fromRGB(14, 14, 14),
					Thickness = 1
				});

				utility_t.create_outlines(transparency_slider, {
					{ color = Color3.fromRGB(14, 14, 14), transparency = 0 },
				});

				transparency_slider_gradient = utility_t.new_instance("UIGradient", {
					Parent = transparency_slider,
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, default),
						ColorSequenceKeypoint.new(1, utility_t.darken_color(default, 0.1))
					});
				});

				transparency_slider_visualizer = utility_t.new_instance("Frame", {
					Parent = transparency_slider,
					BorderSizePixel = 1,
					ZIndex = 1004,
					BorderColor3 = Color3.fromRGB(14, 14, 14),
					Size = UDim2.new(0, 2, 1, 0),
					Position = UDim2.new(0, (math.clamp(default_transparency, 0, 1) * transparency_slider.AbsoluteSize.X) , 0, 0), --// based of the default transparency
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 0,
				});
			end;

			local colorpicker_object = {};

			local change_open = function(state)
				is_open = state;

				colorpicker_content_holder.Visible = state;

				if is_open then
					if self.lib.base.current_colorpicker and self.lib.base.current_colorpicker ~= colorpicker_object then
						self.lib.base.current_colorpicker.change_open(false);
					end;

					local absolute_position = colorpicker_frame.AbsolutePosition;
					colorpicker_content_holder.Position = UDim2.new(0, absolute_position.X + 1, 0, absolute_position.Y + 25);

					self.lib.base.current_colorpicker = colorpicker_object
				else
					self.lib.base.current_colorpicker = nil;
				end;
			end;

			colorpicker_object.change_open = change_open;

			utility_t.connect(pressed_signal, function()
				if self.lib.base.current_tab == self.tab and utility_t.is_in_main_frame(colorpicker_frame, self.main_frame) then
					change_open(not is_open);
				end;
			end);

			utility_t.connect(user_input_service.InputBegan, function(input)
				if is_open and input.UserInputType == Enum.UserInputType.MouseButton1 and not (utility_t.is_mouse_in_frame(colorpicker_frame) or utility_t.is_mouse_in_frame(colorpicker_content_holder)) then
					change_open(false);
				end;
			end);

			local current_hue = 0;

			local set = function(color)
				colorpicker_gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, color), ColorSequenceKeypoint.new(1, utility_t.darken_color(color, 0.5))});

				local _hue, saturation, value = color:ToHSV();
				local colorpicker_size = actual_colorpicker_frame.AbsoluteSize;

				local _x = saturation * colorpicker_size.X;
				local _y = (1 - value) * colorpicker_size.Y;
				library_t.flags[flag].color = color;
				callback(library_t.flags[flag]);
			end;

			local set_transparency = function(transparency)
				transparency_slider_visualizer.Position = UDim2.new(0, transparency * transparency_slider.AbsoluteSize.X, 0, 0);

				library_t.flags[flag].transparency = transparency;
				callback(library_t.flags[flag]);
			end;

			local set_info = function(info)
				set(Color3.new(info.color[1], info.color[2], info.color[3]));
				if info.transparency then
					set_transparency(info.transparency);
				end;
			end;

			self.lib.base.save_flags[flag] = set_info;

			local update = function(mouse_pos)
				local color_size = actual_colorpicker_frame.AbsoluteSize;
				local x = math.clamp(mouse_pos.X - actual_colorpicker_frame.AbsolutePosition.X, 0, color_size.X);
				local y = math.clamp(mouse_pos.Y - actual_colorpicker_frame.AbsolutePosition.Y, 0, color_size.Y);

				local selected_color = Color3.fromHSV(current_hue, x / color_size.X, 1 - (y / color_size.Y));

				set(selected_color);

				if transparency_slider then
					transparency_slider.BackgroundColor3 = selected_color;
					transparency_slider_gradient.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, selected_color),
						ColorSequenceKeypoint.new(1, utility_t.darken_color(selected_color, 0.1))
					});
				end;
			end;

			utility_t.connect(user_input_service.InputBegan, function(input)
				if is_open and input.UserInputType == Enum.UserInputType.MouseButton1 then
					if utility_t.is_mouse_in_frame(actual_colorpicker_frame) then
						is_dragging_main = true;
						update(input.Position);
					elseif utility_t.is_mouse_in_frame(colorpicker_hue) then
						is_dragging_hue = true;
					elseif transparency_slider and utility_t.is_mouse_in_frame(transparency_slider) then
						is_dragging_transparency = true;
					end;
				end;
			end);

			utility_t.connect(user_input_service.InputEnded, function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					is_dragging_main = false;
					is_dragging_hue = false;
					is_dragging_transparency = false;
				end;
			end);

			utility_t.connect(user_input_service.InputChanged, function(input)
				if is_dragging_main and input.UserInputType == Enum.UserInputType.MouseMovement then
					update(input.Position);
				elseif is_dragging_hue and input.UserInputType == Enum.UserInputType.MouseMovement then
					local hue_height = colorpicker_hue.AbsoluteSize.Y
					local y = math.clamp(input.Position.Y - colorpicker_hue.AbsolutePosition.Y, 0, hue_height);

					current_hue = y / hue_height;
					colorpicker_gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHSV(current_hue, 1, 1)), ColorSequenceKeypoint.new(1, utility_t.darken_color(Color3.fromHSV(current_hue, 1, 1), 0.5))});
					library_t.flags[flag].color = Color3.fromHSV(current_hue, 1, 1);
					actual_colorpicker_frame.BackgroundColor3 = Color3.fromHSV(current_hue, 1, 1);
					callback(library_t.flags[flag]);
				elseif is_dragging_transparency and input.UserInputType == Enum.UserInputType.MouseMovement then
					local transparency_width = transparency_slider.AbsoluteSize.X;
					local x = math.clamp(input.Position.X - transparency_slider.AbsolutePosition.X, 0, transparency_width);

					local new_transparency = 1 - (x / transparency_width);

					transparency_slider_visualizer.Position = UDim2.new(0, x - (transparency_slider_visualizer.AbsoluteSize.X / 2), 0.5, -transparency_slider_visualizer.AbsoluteSize.Y / 2);

					library_t.flags[flag].transparency = is_drawing and new_transparency or 1 - new_transparency;
					callback(library_t.flags[flag]);
				end;
			end);
		end;

		local create_keybind = function(self, properties, label, is_toggle)
			local name = properties and properties.name or "keybind";
			local default = properties and properties.default or nil;
			local flag = properties and properties.flag or name;
			local callback = properties and properties.callback or function(...) end;
			local index_mode = properties and properties.index_mode or false;
			local mode = properties and properties.mode or "toggle";

			library_t.flags[flag] = index_mode and default or false;
			local current_key = default;
			self.lib.base.key_flags[flag] = default;
			local is_selecting = false;
			local state = false;

			local keybind_frame = utility_t.new_instance("Frame", {
				Parent = label,
				Position = UDim2.new(1, -10, 0, 0),
				Size = UDim2.new(0, 0, 0, 0),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
			});

			local keybind_text = utility_t.new_instance("TextLabel", {
				Parent = keybind_frame,
				Position = UDim2.new(0, 1, 0, 0),
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ZIndex = 2,
				TextColor3 = library_t.theme.text_color,
				TextSize = library_t.font_size,
				Text = default and default.Name or "none",
				FontFace = library_t.font,
			});

			local shadow = utility_t.new_instance("TextLabel", {
				Parent = keybind_text,
				Size = UDim2.new(1, 0, 1, 0),
				Position = UDim2.new(0, 1, 0, 1),
				ZIndex = 1,
				FontFace = library_t.font,
				TextSize = library_t.font_size,
				BackgroundTransparency = 1,
				TextColor3 = Color3.fromRGB(0, 0, 0),
				Text = default and default.Name or "none",
				BorderSizePixel = 0
			});

			local keybind_button, pressed_signal = utility_t.new_button({
				Parent = keybind_frame,
				Position = UDim2.new(0, 0, 0, 0),
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				TextTransparency = 1
			});

			local update_pos = function()
				local text_size = keybind_text.TextBounds;
                keybind_frame.Size = UDim2.new(0, text_size.X + 9, 0, 10);
                keybind_frame.Position = UDim2.new(1, -text_size.X -4, 0, 0);
			end;

			self.lib.base.save_flags[flag] = function(key_string)
				if key_string then
					is_selecting = false;
					keybind_text.Text = key_string:lower();
					shadow.Text = key_string:lower();
					update_pos();
					current_key = (Enum.KeyCode[key_string] or Enum.UserInputType[key_string]) or nil;
					if index_mode then
						self.lib.base.key_flags[flag] = current_key;
					else
						library_t.flags[flag] = false;
					end;
					callback(library_t.flags[flag]);
				end;
			end;

			update_pos();

			utility_t.connect(pressed_signal, function()
				if not is_selecting and self.lib.base.current_tab == self.tab and utility_t.is_in_main_frame(keybind_button, self.main_frame) then
					is_selecting = true;
					keybind_text.Text = "...";
					shadow.Text = "...";
					update_pos();
				end;
			end);

            utility_t.connect(user_input_service.InputBegan, function(input)
                if is_selecting and input.KeyCode == Enum.KeyCode.Escape then
                    is_selecting = false;
                    keybind_text.Text = "none";
					shadow.Text = "none";
                    update_pos();
                    current_key = nil;
					self.lib.base.key_flags[flag] = current_key;
					if not index_mode then
						library_t.flags[flag] = false;
					end;
                    callback(library_t.flags[flag]);
                end;

                if is_selecting then
                    local key = input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode or (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2) and input.UserInputType or nil;
                    if key then
                        is_selecting = false;
                        local key_name = key.Name;
                        keybind_text.Text = key_name:lower();
						shadow.Text = key_name:lower();
                        current_key = key;
						self.lib.base.key_flags[flag] = current_key;
						if index_mode then
							library_t.flags[flag] = current_key;
						else
							library_t.flags[flag] = false;
						end;
                        update_pos();
                        callback(library_t.flags[flag]);
                    end;
                end;

                if not is_selecting and not index_mode and ((input.UserInputType == Enum.UserInputType.MouseButton1 and current_key == Enum.UserInputType.MouseButton1) or (input.UserInputType == Enum.UserInputType.MouseButton2 and current_key == Enum.UserInputType.MouseButton2) or (input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == current_key)) then
                    if mode == "toggle" then
                        state = not state;
                        library_t.flags[flag] = state;
                        callback(state);
                    elseif mode == "hold" then
                        state = true;
                        library_t.flags[flag] = state;
                        callback(state);
                    end;
                end;
            end);

            utility_t.connect(user_input_service.InputEnded, function(input)
                if not index_mode and (input.UserInputType == Enum.UserInputType.MouseButton1 and current_key == Enum.UserInputType.MouseButton1) or (input.UserInputType == Enum.UserInputType.MouseButton2 and current_key == Enum.UserInputType.MouseButton2) or (input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == current_key) and mode == "hold" then
                    state = false;
                    library_t.flags[flag] = state;
                    callback(library_t.flags[flag]);
                end;
            end);
		end;

		library_t.watermark = function(self, name)
			local screen_gui = utility_t.new_instance("ScreenGui", {
				Parent = utility_t.get_path(),
				Name = "watermark",
				DisplayOrder = 1e5,
				ResetOnSpawn = false
			});

			local is_dragging = false;
			local initial_frame_pos;
			local initial_mouse_pos;

			local watermark_holder = utility_t.new_instance("Frame", {
				Parent = screen_gui,
				Position = UDim2.new(0, 100, 0, 100),
				Size = UDim2.new(0, 0, 0, 0),
				BackgroundColor3 = library_t.theme.background_color,
				BorderSizePixel = 0
			});

			local _, drag_signal = utility_t.new_button({
				Parent = watermark_holder,
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				TextTransparency = 1,
			});
			
			utility_t.connect(drag_signal, function()
				is_dragging = true;
				initial_frame_pos = watermark_holder.Position;
				initial_mouse_pos = user_input_service:GetMouseLocation();
			end);

			utility_t.connect(user_input_service.InputChanged, function(input, is_typing)
				if input.UserInputType == Enum.UserInputType.MouseMovement and is_dragging then
					local current_mouse_pos = user_input_service:GetMouseLocation();
					local delta_x = current_mouse_pos.X - initial_mouse_pos.X;
					local delta_y = current_mouse_pos.Y - initial_mouse_pos.Y;

					watermark_holder.Position = UDim2.new(initial_frame_pos.X.Scale, initial_frame_pos.X.Offset + delta_x, initial_frame_pos.Y.Scale, initial_frame_pos.Y.Offset + delta_y);
				end;
			end);

			utility_t.connect(user_input_service.InputEnded, function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					is_dragging = false;
				end;
			end);

			utility_t.new_instance("ImageLabel", {
				Parent = watermark_holder,
				Size = UDim2.new(1, 0, 1, 0),
				Position = UDim2.new(0, 0, 0, 0),
				BackgroundTransparency = 1,
				ImageColor3 = library_t.theme.dots_color,
				ScaleType = Enum.ScaleType.Tile,
				TileSize = UDim2.new(0, 8, 0, 8),
				Image = "rbxassetid://134950628747280"
			});

			local accent_line = utility_t.new_instance("Frame", {
				Parent = watermark_holder,
				Size = UDim2.new(1, -2, 0, 2),
				Position = UDim2.new(0, 1, 0, 1),
				BackgroundColor3 = Color3.new(1, 1, 1),
				BorderSizePixel = 0
			});

			utility_t.new_instance("UIGradient", {
				Parent = accent_line,
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, library_t.theme.accent),
					ColorSequenceKeypoint.new(1, utility_t.darken_color(library_t.theme.accent, 0.5))
				}),
				Rotation = 90
			});

			utility_t.create_outlines(watermark_holder, {
				{ color = Color3.fromRGB(60, 60, 60), thickness = 1 },
				{ color = Color3.fromRGB(40, 40, 40), thickness = 1 },
				{ color = Color3.fromRGB(40, 40, 40), thickness = 1 },
				{ color = Color3.fromRGB(40, 40, 40), thickness = 1 },
				{ color = Color3.fromRGB(60, 60, 60), thickness = 1 },
				{ color = Color3.fromRGB(31, 31, 31), thickness = 1 }
			});

			local text_bounds = utility_t.get_textbounds(name, library_t.font_size);

			watermark_holder.Size = UDim2.new(0, text_bounds.X + 8, 0, 20);

			local main_text_label = utility_t.new_instance("TextLabel", {
				Parent = watermark_holder,
				Size = UDim2.new(1, 0, 1, 0),
				Position = UDim2.new(0, 0, 0, 0),
				BackgroundTransparency = 1,
				ZIndex = 2,
				FontFace = library_t.font,
				Text = name,
				TextColor3 = library_t.theme.text_color,
				TextSize = library_t.font_size,
				TextXAlignment = Enum.TextXAlignment.Center
			});

			utility_t.new_instance("TextLabel", {
				Parent = main_text_label,
				Size = UDim2.new(1, 0, 1, 0),
				Position = UDim2.new(0, 1, 0, 1),
				ZIndex = 1,
				FontFace = library_t.font,
				TextSize = library_t.font_size,
				BackgroundTransparency = 1,
				TextColor3 = Color3.fromRGB(0, 0, 0),
				Text = name,
				BorderSizePixel = 0
			});
		end;

		local section = {}; do
			section.toggle = function(self, properties)
				local name = properties and properties.name or "enabled";
				local default = properties and properties.default or false;
				local flag = properties and properties.flag or name;
				local callback = properties and properties.callback or function(...) end;

				local current_state = default;

				library_t.flags[flag] = current_state;

				local BASE_COLOR = Color3.fromRGB(44, 44, 44);

				local ENABLED = ColorSequence.new({ColorSequenceKeypoint.new(0, library_t.theme.accent), ColorSequenceKeypoint.new(1, utility_t.darken_color(library_t.theme.accent, 0.8))});
				local DISABLED = ColorSequence.new({ColorSequenceKeypoint.new(0, BASE_COLOR), ColorSequenceKeypoint.new(1, utility_t.darken_color(BASE_COLOR, 0.8))});
				
				local toggle_holder = utility_t.new_instance("Frame", {
					Parent = self.content_frame,
					Size = UDim2.new(1, 0, 0, 7),
					BackgroundTransparency = 1,
					BorderSizePixel = 0
				})

				local toggle_button, pressed_signal = utility_t.new_button({
					Parent = toggle_holder,
					TextTransparency = 1,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BorderSizePixel = 0,
					Size = UDim2.new(0, 9, 0, 9)
				});

				local name_label = utility_t.new_instance("TextLabel", {
					Parent = toggle_button,
					Position = UDim2.new(0, 28, 0, 0),
					Size = UDim2.new(0, 9, 0, 12),
					Text = name,
					ZIndex = 2,
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					TextColor3 = library_t.theme.text_color,
					FontFace = library_t.font,
					TextSize = library_t.font_size
				});

				local text_bounds = name_label.TextBounds;
				name_label.Position = UDim2.new(0, text_bounds.X / 2 + 12, 0, -2);

				utility_t.new_instance("TextLabel", {
					Parent = name_label,
					Size = UDim2.new(1, 0, 1, 0),
					Position = UDim2.new(0, 1, 0, 1),
					ZIndex = 1,
					FontFace = library_t.font,
					TextSize = library_t.font_size,
					BackgroundTransparency = 1,
					TextColor3 = Color3.fromRGB(0, 0, 0),
					Text = name,
					BorderSizePixel = 0
				});

				utility_t.new_instance("UIStroke", {
					Parent = toggle_button,
					LineJoinMode = Enum.LineJoinMode.Miter,
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
					Color = Color3.fromRGB(17, 17, 17)
				});

				local ui_gradient = utility_t.new_instance("UIGradient", {
					Parent = toggle_button,
					Color = current_state and ENABLED or DISABLED,
					Rotation = 90
				});

				local change_state = function(state)
					current_state = state;
					callback(state);

					library_t.flags[flag] = state;
					ui_gradient.Color = state and ENABLED or DISABLED;
				end;

				utility_t.connect(pressed_signal, function()
					if self.lib.base.current_tab == self.tab and utility_t.is_in_main_frame(toggle_button, self.main_frame) then
						change_state(not current_state);
					end;
				end);

				self.lib.base.save_flags[flag] = change_state;

				self.update_size();
				
				return {
					colorpicker = function(_, properties)
						create_colorpicker(self, properties, toggle_holder, true);
					end,
					keybind = function(_, properties)
						create_keybind(self, properties, toggle_holder, true);
					end
				}
			end;

			section.slider = function(self, properties)
				local min = properties and properties.min or 0;
				local max = properties and properties.max or 100;
				local default = properties and (properties.default and math.clamp(properties.default, min, max)) or math.clamp(0, min, max);
				local name = properties and properties.name or "enabled";
				local flag = properties and properties.flag or name;
				local suffix = properties and properties.suffix or "%";
				local decimals = properties and properties.decimals or 0.1;
				local callback = properties and properties.callback or function(...) end;

				local is_dragging = false;

				local slider_holder = utility_t.new_instance("Frame", {
					Parent = self.content_frame,
					Position = UDim2.new(0, 0, 0, 0),
					Size = UDim2.new(1, -14, 0, 23),
					BackgroundTransparency = 1,
					BorderSizePixel = 0
				});

				local name_label = utility_t.new_instance("TextLabel", {
					Parent = slider_holder,
					Position = UDim2.new(0, 15, 0, -10),
					Size = UDim2.new(1, -15, 1, 0),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					ZIndex = 2,
					Text = name,
					TextSize = library_t.font_size,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Center,
					TextColor3 = library_t.theme.text_color,
					FontFace = library_t.font
				});

				utility_t.new_instance("TextLabel", {
					Parent = name_label,
					Size = UDim2.new(1, 0, 1, 0),
					Position = UDim2.new(0, 1, 0, 1),
					ZIndex = 1,
					FontFace = library_t.font,
					TextSize = library_t.font_size,
					BackgroundTransparency = 1,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Center,
					TextColor3 = Color3.fromRGB(0, 0, 0),
					Text = name,
					BorderSizePixel = 0
				});

				local slider_frame, pressed_signal = utility_t.new_button({
					Parent = slider_holder,
					Position = UDim2.new(0, 15, 0, 13),
					Size = UDim2.new(1, -38, 0, 5),
					BackgroundColor3 = Color3.new(1, 1, 1),
					TextTransparency = 1,
					BorderSizePixel = 0,
				});

				utility_t.new_instance("UIStroke", {
					Parent = slider_frame,
					LineJoinMode = Enum.LineJoinMode.Miter,
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
					Color = Color3.fromRGB(17, 17, 17),
					Thickness = 1
				});

				local actual_slider = utility_t.new_instance("Frame", {
					Parent = slider_frame,
					Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
					BackgroundColor3 = Color3.new(1, 1, 1),
					BorderSizePixel = 0,
				});

				local decimal_places = math.max(0, -math.floor(math.log10(decimals)));

				local value_text = utility_t.new_instance("TextLabel", {
					Parent = slider_holder,
					Name = "value",
					Position = UDim2.new(0.5, 0, 0.3, 0),
					BackgroundTransparency = 1,
					ZIndex = 2,
					BorderSizePixel = 0,
					Text = string.format("%0." .. decimal_places .. "f", default) .. suffix,
					TextSize = library_t.font_size,
					TextColor3 = library_t.theme.text_color,
					FontFace = library_t.font
				});

				local shadow_text = utility_t.new_instance("TextLabel", {
					Parent = value_text,
					Size = UDim2.new(1, 0, 1, 0),
					Position = UDim2.new(0, 1, 0, 1),
					ZIndex = 1,
					FontFace = library_t.font,
					TextSize = library_t.font_size,
					BackgroundTransparency = 1,
					TextColor3 = Color3.fromRGB(0, 0, 0),
					Text = string.format("%0." .. decimal_places .. "f", default) .. suffix,
					BorderSizePixel = 0
				});

				local text_size = value_text.TextBounds;

				value_text.Position = UDim2.new(0.5, -text_size.X / 2, 0.3, 0);

				utility_t.new_instance("UIGradient", {
					Parent = actual_slider,
					Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, library_t.theme.accent), ColorSequenceKeypoint.new(1, utility_t.darken_color(library_t.theme.accent, 0.5)) }),
					Rotation = 90
				});

				utility_t.new_instance("UIGradient", {
					Parent = slider_frame,
					Rotation = 90,
					Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(44, 44, 44)), ColorSequenceKeypoint.new(1, utility_t.darken_color(Color3.fromRGB(44, 44, 44), 0.8))})
				});

				local set = function(value)
					local step = decimals;
					value = math.floor(value / step + 0.5) * step;

					value = math.clamp(value, min, max);

					local decimal_places = math.max(0, -math.floor(math.log10(step)));
					local format_string = "%." .. decimal_places .. "f";

					library_t.flags[flag] = value;
					actual_slider.Size = UDim2.new((value - min) / (max - min), 0, 1, 0);
					value_text.Text = string.format(format_string, value) .. suffix;
					shadow_text.Text = value_text.Text;
					value_text.Position = UDim2.new(math.clamp((value - min) / (max - min), 0.1, 0.9), 0, 0, 20);
					callback(value);
				end;

				set(default);

				self.lib.base.save_flags[flag] = set;

				local update = function(mouse_position)
					local x = math.clamp(mouse_position.X - slider_frame.AbsolutePosition.X, 0, slider_frame.AbsoluteSize.X);
					local raw_value = (x / slider_frame.AbsoluteSize.X) * (max - min) + min;

					local step = decimals;
					local stepped_value = math.floor(raw_value / step + 0.5) * step;

					set(stepped_value);
				end;

				utility_t.connect(pressed_signal, function()
					if self.lib.base.current_tab == self.tab and utility_t.is_in_main_frame(slider_frame, self.main_frame) then
						update(user_input_service:GetMouseLocation());
						is_dragging = true;
					end;
				end);

				utility_t.connect(user_input_service.InputChanged, function(input)
					if self.lib.base.current_tab == self.tab and self.lib.base.is_open and not self.lib.base.current_dropdown and not self.lib.base.current_colorpicker and input.UserInputType == Enum.UserInputType.MouseMovement and is_dragging then
						update(user_input_service:GetMouseLocation());
					end;
				end);

				utility_t.connect(user_input_service.InputEnded, function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 and is_dragging then
						is_dragging = false;
					end;
				end);

				self.update_size();
			end;

			section.dropdown = function(self, properties)
				local name = properties and properties.name or "dropdown";
				local options = properties and properties.options or {"a", "b", "c"};
				local callback = properties and properties.callback or function() end;
				local multi = properties and properties.multi or false;
				local flag = properties and properties.flag or name;
				local no_none = properties and properties.no_none or false;
				local default = properties and properties.default or multi and {options[1]} or options[1];

				local is_open = false;
				local buttons = {};
				local current_options = default;

				local actual_dropdown_holder = utility_t.new_instance("Frame", {
					Parent = self.content_frame,
					Size = UDim2.new(1, -14, 0, 30),
					BackgroundTransparency = 1,
					BorderSizePixel = 0
				});

				local name_label = utility_t.new_instance("TextLabel", {
					Parent = actual_dropdown_holder,
					Position = UDim2.new(0, 15, 0, -10),
					Size = UDim2.new(1, -15, 1, 0),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					ZIndex = 2,
					Text = name,
					TextSize = library_t.font_size,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Center,
					TextColor3 = library_t.theme.text_color,
					FontFace = library_t.font
				});

				utility_t.new_instance("TextLabel", {
					Parent = name_label,
					Size = UDim2.new(1, 0, 1, 0),
					Position = UDim2.new(0, 1, 0, 1),
					ZIndex = 1,
					FontFace = library_t.font,
					TextSize = library_t.font_size,
					BackgroundTransparency = 1,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Center,
					TextColor3 = Color3.fromRGB(0, 0, 0),
					Text = name,
					BorderSizePixel = 0
				});

				local dropdown_button, pressed_signal = utility_t.new_button({
					Parent = actual_dropdown_holder,
					Position = UDim2.new(0, 15, 0, 15),
					Size = UDim2.new(1, -38, 0, 18),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					TextTransparency = 1,
					FontFace = library_t.font,
					TextSize = library_t.font_size
				});

				local dropdown_frame = utility_t.new_instance("Frame", {
					Parent = dropdown_button,
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BorderSizePixel = 0,
				});

				local selected_text = utility_t.new_instance("TextLabel", {
					Parent = dropdown_frame,
					BackgroundTransparency = 1,
					Text = type(current_options) == "table" and (#current_options == 0 and no_none and "none" or table.concat(current_options, ", ")) or current_options,
					TextColor3 = library_t.theme.text_color,
					ZIndex = 2,
					Position = UDim2.new(0, 7, 0, 7),
					FontFace = library_t.font,
					TextSize = library_t.font_size
				});

				local text_bounds = selected_text.TextBounds;
				selected_text.Position = UDim2.new(0, text_bounds.X / 2 + 5, 0, 7);

				local shadow = utility_t.new_instance("TextLabel", {
					Parent = selected_text,
					Size = UDim2.new(1, 0, 1, 0),
					Position = UDim2.new(0, 1, 0, 1),
					ZIndex = 1,
					FontFace = library_t.font,
					TextSize = library_t.font_size,
					BackgroundTransparency = 1,
					TextColor3 = Color3.fromRGB(0, 0, 0),
					Text = selected_text.Text,
					BorderSizePixel = 0
				});

				local dropdown_holder = utility_t.new_instance("Frame", {
					Parent = self.lib.screen_gui,
					Visible = false,
					ZIndex = 99,
					BackgroundColor3 = Color3.new(1, 1, 1),
					BorderSizePixel = 0,
					Size = UDim2.new(0, dropdown_frame.AbsoluteSize.X, 0, dropdown_frame.AbsoluteSize.Y)
				});

				local dropdown_padding = utility_t.new_instance("Frame", {
					Parent = dropdown_holder,
					Position = UDim2.new(0, 5, 0, 2),
					Size = UDim2.new(1, -5, 1, 0),
					BackgroundTransparency = 1,
					BorderSizePixel = 0
				});

				local ui_list_layout = utility_t.new_instance("UIListLayout", {
					Parent = dropdown_padding,
					SortOrder = Enum.SortOrder.LayoutOrder,
					FillDirection = Enum.FillDirection.Vertical
				});

				local update_size = function()
					dropdown_holder.Size = UDim2.new(0, 0, 0, ui_list_layout.AbsoluteContentSize.Y + 8);
				end;

				local set = function(options)
					current_options = options;
					selected_text.Text = type(options) == "table" and ((#options == 0 and "none") or table.concat(options, ", ")) or options;
					shadow.Text = selected_text.Text;

					for option, button in buttons do
						if multi and table.find(options, option) then
							button.TextColor3 = library_t.theme.accent;
						elseif not multi and option == options then
							button.TextColor3 = library_t.theme.accent;
						else
							button.TextColor3 = library_t.theme.text_color;
						end
					end;

					library_t.flags[flag] = options;
					callback(options);
				end;

				self.lib.base.save_flags[flag] = set;

				local dropdown_object = {};

				local change_open = function(state)
					is_open = state;

					self.lib.base.current_dropdown = dropdown_object;

					if is_open then
						if self.lib.base.current_dropdown and self.lib.base.current_dropdown ~= dropdown_object then
							self.lib.base.current_dropdown.change_open(false);
							return;
						end

						local absolute_size = dropdown_button.AbsoluteSize;

						dropdown_holder.Visible = true;

						dropdown_holder.Size = UDim2.new(dropdown_holder.Size.X.Scale, absolute_size.X, dropdown_holder.Size.Y.Scale, dropdown_holder.Size.Y.Offset);
						dropdown_holder.Position = UDim2.new(0, dropdown_button.AbsolutePosition.X, 0, dropdown_button.AbsolutePosition.Y + 23);
					else
						self.lib.base.current_dropdown = nil
						dropdown_holder.Visible = false;
					end;
				end;

				dropdown_object.change_open = change_open;

				for i, option in options do
					local option_button, pressed_option = utility_t.new_button({
						Parent = dropdown_padding,
						Position = UDim2.new(0, 0, 0, 4),
						Size = UDim2.new(1, 0, 0, 13),
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						ZIndex = 100,
						FontFace = library_t.font,
						TextSize = library_t.font_size,
						TextColor3 = multi and table.find(current_options, option) and library_t.theme.accent or current_options == option and library_t.theme.accent or library_t.theme.text_color,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextYAlignment = Enum.TextYAlignment.Center,
						Text = option
					});

					utility_t.new_instance("TextLabel", {
						Parent = option_button,
						Size = UDim2.new(1, 0, 1, 0),
						Position = UDim2.new(0, 1, 0, 1),
						ZIndex = 99,
						FontFace = library_t.font,
						TextSize = library_t.font_size,
						BackgroundTransparency = 1,
						TextColor3 = Color3.fromRGB(0, 0, 0),
						TextXAlignment = Enum.TextXAlignment.Left,
						TextYAlignment = Enum.TextYAlignment.Center,
						Text = option,
						BorderSizePixel = 0
					});

					buttons[option] = option_button;

					utility_t.connect(pressed_option, function()
						if self.lib.base.current_tab == self.tab and is_open then
							if multi then
								local index = table.find(current_options, option);
								if index and (not (#current_options == 1 and no_none)) then
									table.remove(current_options, index);
									option_button.TextColor3 = library_t.theme.text_color;
								else
									if not index then
										option_button.TextColor3 = library_t.theme.accent;
										table.insert(current_options, option);
									end;
								end;
	
								selected_text.Text = multi and (#current_options == 0 and "none" or table.concat(current_options, ", ")) or current_options;
								shadow.Text = selected_text.Text;
								library_t.flags[flag] = current_options;
								callback(current_options);
							else
								for _, button in buttons do
									if button ~= option_button then
										button.TextColor3 = library_t.theme.text_color;
									end;
								end;
	
								current_options = option;
								library_t.flags[flag] = current_options;
								callback(current_options);
								selected_text.Text = option;
								shadow.Text = option;
								option_button.TextColor3 = library_t.theme.accent;
	
								change_open(false);
							end;
	
							local text_bounds = selected_text.TextBounds;
							selected_text.Position = UDim2.new(0, text_bounds.X / 2 + 5, 0, 7);
						end;
					end);

					update_size();
				end;

				utility_t.new_instance("UIGradient", {
					Parent = dropdown_frame,
					Rotation = 90,
					Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(44, 44, 44)), ColorSequenceKeypoint.new(1, utility_t.darken_color(Color3.fromRGB(44, 44, 44), 0.8))})
				});

				utility_t.new_instance("UIGradient", {
					Parent = dropdown_holder,
					Rotation = 90,
					Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(44, 44, 44)), ColorSequenceKeypoint.new(1, utility_t.darken_color(Color3.fromRGB(44, 44, 44), 0.8))})
				});

				utility_t.new_instance("UIStroke", {
					Parent = dropdown_button,
					LineJoinMode = Enum.LineJoinMode.Miter,
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
					Color = Color3.fromRGB(17, 17, 17),
					Thickness = 1
				});

				utility_t.new_instance("UIStroke", {
					Parent = dropdown_holder,
					LineJoinMode = Enum.LineJoinMode.Miter,
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
					Color = Color3.fromRGB(17, 17, 17),
					Thickness = 1
				});

				utility_t.connect(user_input_service.InputBegan, function(input)
					if is_open and self.lib.base.is_open and input.UserInputType == Enum.UserInputType.MouseButton1 and not (utility_t.is_mouse_in_frame(dropdown_button) or utility_t.is_mouse_in_frame(dropdown_holder)) then
						change_open(false);
					end;
				end);

				utility_t.connect(pressed_signal, function()
					if self.lib.base.current_tab == self.tab and utility_t.is_in_main_frame(dropdown_button, self.main_frame) then
						change_open(not is_open);
					end;
				end);

				self.update_size();
			end;

			section.colorpicker = function(self, properties)
				local name = properties and properties.name or "colorpicker";
				
				local colorpicker_frame_holder = utility_t.new_instance("Frame", {
					Parent = self.content_frame,
					Size = UDim2.new(1, 0, 0, 3),
					BorderSizePixel = 0,
					BackgroundTransparency = 1
				});

				local name_label = utility_t.new_instance("TextLabel", {
					Parent = colorpicker_frame_holder,
					Position = UDim2.new(0, 37, 0, -3),
					Size = UDim2.new(0, 9, 0, 12),
					Text = name,
					ZIndex = 2,
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					TextColor3 = library_t.theme.text_color,
					FontFace = library_t.font,
					TextSize = library_t.font_size
				});

				utility_t.new_instance("TextLabel", {
					Parent = name_label,
					Size = UDim2.new(1, 0, 1, 0),
					Position = UDim2.new(0, 1, 0, 1),
					ZIndex = 1,
					FontFace = library_t.font,
					TextSize = library_t.font_size,
					BackgroundTransparency = 1,
					TextColor3 = Color3.fromRGB(0, 0, 0),
					Text = name,
					BorderSizePixel = 0
				});

				create_colorpicker(self, properties, colorpicker_frame_holder, false);
			end;

			section.keybind = function(self, properties)
				local name = properties and properties.name or "keybind";
				
				local colorpicker_frame_holder = utility_t.new_instance("Frame", {
					Parent = self.content_frame,
					Size = UDim2.new(1, 0, 0, 5),
					BorderSizePixel = 0,
					BackgroundTransparency = 1
				});

				local name_label = utility_t.new_instance("TextLabel", {
					Parent = colorpicker_frame_holder,
					Position = UDim2.new(0, 30, 0, -3),
					Size = UDim2.new(0, 9, 0, 12),
					Text = name,
					ZIndex = 2,
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					TextColor3 = library_t.theme.text_color,
					FontFace = library_t.font,
					TextSize = library_t.font_size
				});

				local text_bounds = name_label.TextBounds;
				name_label.Position = UDim2.new(0, text_bounds.X / 2 + 10, 0, 0);

				utility_t.new_instance("TextLabel", {
					Parent = name_label,
					Size = UDim2.new(1, 0, 1, 0),
					Position = UDim2.new(0, 1, 0, 1),
					ZIndex = 1,
					FontFace = library_t.font,
					TextSize = library_t.font_size,
					BackgroundTransparency = 1,
					TextColor3 = Color3.fromRGB(0, 0, 0),
					Text = name,
					BorderSizePixel = 0
				});

				create_keybind(self, properties, colorpicker_frame_holder, false);
			end;

			section.textbox = function(self, properties)
				local name = properties and properties.name or "textbox";
				local placeholder = properties and properties.placeholder or nil;
				local default = properties and properties.default or nil;
				local flag = properties and properties.flag or name;
				local callback = properties and properties.callback or function(...) end;

				local textbox_holder = utility_t.new_instance("Frame", {
					Parent = self.content_frame,
					Size = UDim2.new(1, 0, 0, 30),
					BorderSizePixel = 0,
					BackgroundTransparency = 1
				});

				local name_label = utility_t.new_instance("TextLabel", {
					Parent = textbox_holder,
					Position = UDim2.new(0, 33, 0, -3),
					Size = UDim2.new(0, 9, 0, 12),
					Text = name,
					ZIndex = 2,
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					TextColor3 = library_t.theme.text_color,
					FontFace = library_t.font,
					TextSize = library_t.font_size
				});

				local text_bounds = name_label.TextBounds;

				name_label.Position = UDim2.new(0, text_bounds.X / 2 + 12, 0, 0);

				library_t.flags[flag] = default;

				utility_t.new_instance("TextLabel", {
					Parent = name_label,
					Size = UDim2.new(1, 0, 1, 0),
					Position = UDim2.new(0, 1, 0, 1),
					ZIndex = 1,
					FontFace = library_t.font,
					TextSize = library_t.font_size,
					BackgroundTransparency = 1,
					TextColor3 = Color3.fromRGB(0, 0, 0),
					Text = name,
					BorderSizePixel = 0
				});

				local textbox_frame = utility_t.new_instance("Frame", {
					Parent = textbox_holder,
					Position = UDim2.new(0, 16, 0, 15),
					Size = UDim2.new(1, -52, 0, 18),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				});

				utility_t.new_instance("UIStroke", {
					Parent = textbox_frame,
					LineJoinMode = Enum.LineJoinMode.Miter,
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
					Color = Color3.fromRGB(17, 17, 17),
					Thickness = 1
				});

				utility_t.new_instance("UIGradient", {
					Parent = textbox_frame,
					Rotation = 90,
					Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(44, 44, 44)), ColorSequenceKeypoint.new(1, utility_t.darken_color(Color3.fromRGB(44, 44, 44), 0.8))})
				});

				local textbox = utility_t.new_instance("TextBox", {
					Parent = textbox_frame,
					Size = UDim2.new(1, -4, 1, -4),
					Position = UDim2.new(0, 2, 0, 2),
					BackgroundTransparency = 1,
					Text = default or "",
					TextColor3 = library_t.theme.text_color,
					FontFace = library_t.font,
					TextSize = library_t.font_size,
					PlaceholderText = placeholder,
					BorderSizePixel = 0,
					ClearTextOnFocus = false
				});

				utility_t.connect(textbox:GetPropertyChangedSignal("Text"), function()
					library_t.flags[flag] = textbox.Text;
					callback(textbox.Text);
				end);

				self.lib.base.save_flags[flag] = function(value)
					textbox.Text = value;
					library_t.flags[name] = value;
					callback(value);
				end;
			end;

			section.button = function(self, properties)
				local name = properties and properties.name or "button";
				local callback = properties and properties.callback or function(...) end;

				local button_frame = utility_t.new_instance("Frame", {
					Parent = self.content_frame,
					Size = UDim2.new(1, -52, 0, 15),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				});

				local actual_button, pressed = utility_t.new_button({
					Parent = button_frame,
					Size = UDim2.new(1, 0, 1, 0),
					Position = UDim2.new(0, 0, 0, 0),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Text = name,
					TextColor3 = library_t.theme.text_color,
					FontFace = library_t.font,
					TextSize = library_t.font_size	
				});

				utility_t.new_instance("UIStroke", {
					Parent = button_frame,
					LineJoinMode = Enum.LineJoinMode.Miter,
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
					Color = Color3.fromRGB(17, 17, 17),
					Thickness = 1
				});

				utility_t.new_instance("UIGradient", {
					Parent = button_frame,
					Rotation = 90,
					Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(44, 44, 44)), ColorSequenceKeypoint.new(1, utility_t.darken_color(Color3.fromRGB(44, 44, 44), 0.8))})
				});

				utility_t.connect(pressed, function()
					if self.lib.base.current_tab == self.tab and utility_t.is_in_main_frame(button_frame, self.main_frame) then
						callback();
					end;
				end);
			end;
		end;

		local tabs = {}; do
			tabs.section = function(self, properties)
				local size = properties and properties.size or 120;
				local name = properties and properties.name or "aimbot";
				local side = properties and (properties.side and properties.side:lower()) or "left";

				local section_frame = utility_t.new_instance("Frame", {
					Parent = side == "left" and self.left_side or self.right_side,
					Size = UDim2.new(1, 0, 0, size),
					BackgroundColor3 = Color3.fromRGB(24, 24, 24),
					BorderSizePixel = 0
				});

				local text_bounds = utility_t.get_textbounds(name, library_t.font_size);

				utility_t.new_instance("Frame", {
					Parent = section_frame,
					Size = UDim2.new(0, text_bounds.X + 2, 0, 1),
					BackgroundColor3 = Color3.fromRGB(24, 24, 24),
					Position = UDim2.new(0, 6, 0, -1),
					BorderSizePixel = 0
				});

				local name_label = utility_t.new_instance("TextLabel", {
					Parent = section_frame,
					Position = UDim2.new(0, (text_bounds.X / 2) + 7, 0, -1),
					BackgroundTransparency = 1,
					FontFace = library_t.font,
					ZIndex = 1000,
					Text = name,
					TextColor3 = library_t.theme.text_color,
					TextSize = library_t.font_size
				});

				utility_t.new_instance("TextLabel", {
					Parent = name_label,
					Size = UDim2.new(1, 0, 1, 0),
					Position = UDim2.new(0, 1, 0, 1),
					ZIndex = 1,
					FontFace = library_t.font,
					TextSize = library_t.font_size,
					BackgroundTransparency = 1,
					TextColor3 = Color3.fromRGB(0, 0, 0),
					Text = name,
					BorderSizePixel = 0
				});

				utility_t.new_instance("UIStroke", {
					Parent = section_frame,
					LineJoinMode = Enum.LineJoinMode.Miter,
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
					Color = Color3.fromRGB(44, 44, 44)
				});

				local main_frame = utility_t.new_instance("ScrollingFrame", {
					Parent = section_frame,
					BackgroundTransparency = 1,
					ScrollingEnabled = false,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 1, 0),
					ScrollBarImageTransparency = 1,
					ScrollBarThickness = 0,
				});
				
				local upper_fade = utility_t.new_instance("Frame", {
					Parent = section_frame,
					Size = UDim2.new(1, 0, 0, 10),
					ZIndex = 999,
					BackgroundTransparency = 0.5,
					Position = UDim2.new(0, 0, 0, -1),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BorderSizePixel = 0
				});

				utility_t.new_instance("UIGradient", {
					Parent = upper_fade,
					Rotation = 90,
					Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(24, 24, 24)), ColorSequenceKeypoint.new(0.6, Color3.fromRGB(24, 24, 24)), ColorSequenceKeypoint.new(0.7, Color3.fromRGB(24, 24, 24)), ColorSequenceKeypoint.new(0.8, Color3.fromRGB(24, 24, 24)), ColorSequenceKeypoint.new(0.9, Color3.fromRGB(24, 24, 24)), ColorSequenceKeypoint.new(1, Color3.fromRGB(24, 24, 24))})
				});

				utility_t.connect(user_input_service.InputChanged, function(input)
					if self.lib.base.current_tab == self and self.lib.base.is_open and input.UserInputType == Enum.UserInputType.MouseWheel and utility_t.is_mouse_in_frame(main_frame) then
						local is_going_up = input.Position.Z < 0;
						tween_service:Create(main_frame, TweenInfo.new(0.1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), { CanvasPosition = Vector2.new(0, main_frame.CanvasPosition.Y + (is_going_up and 40 or -40)) }):Play();
					end;
				end);

				local content_frame = utility_t.new_instance("Frame", {
					Parent = main_frame,
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Size = UDim2.new(1, -32, 1, -20),
					Position = UDim2.new(0, 16, 0, 13)
				});

				local ui_list_layout = utility_t.new_instance("UIListLayout", {
					Parent = content_frame,
					Padding = UDim.new(0, 10),
					SortOrder = Enum.SortOrder.LayoutOrder,
					FillDirection = Enum.FillDirection.Vertical
				});

				local section_object = {
					content_frame = content_frame,
					main_frame = main_frame,
					tab = self,
					lib = self.lib,
					update_size = function()
						main_frame.CanvasSize = UDim2.new(0, 0, 0, ui_list_layout.AbsoluteContentSize.Y + 29);
					end,
				};

				return setmetatable(section_object, { __index = section });
			end;
		end;

		library_t.tab = function(self, properties)
			local name = properties and properties.name or "legit";

			local tab_button, pressed_signal = utility_t.new_button({
				Parent = self.tab_padding,
				Size = UDim2.new(0, 72, 1, 0),
				FontFace = library_t.font,
				TextSize = library_t.font_size, 
				BackgroundTransparency = 1,
				TextColor3 = library_t.theme.text_color,
				Text = name,
				ZIndex = 2,
				BorderSizePixel = 0
			});

			utility_t.new_instance("TextLabel", {
				Parent = tab_button,
				Size = UDim2.new(1, 0, 1, 0),
				Position = UDim2.new(0, 1, 0, 1),
				ZIndex = 1,
				FontFace = library_t.font,
				TextSize = library_t.font_size,
				BackgroundTransparency = 1,
				TextColor3 = Color3.fromRGB(0, 0, 0),
				Text = name,
				BorderSizePixel = 0
			});

			utility_t.new_instance("UIFlexItem", {
				Parent = tab_button,
				FlexMode = Enum.UIFlexMode.Fill,
				ItemLineAlignment = Enum.ItemLineAlignment.Stretch
			});

			local tab_line_frame = utility_t.new_instance("Frame", {
				Parent = self.tab_padding,
				Size = UDim2.new(0, 1, 1, 0),
				BackgroundColor3 = Color3.fromRGB(44, 44, 44),
				BorderSizePixel = 0
			});

			local tab_section = utility_t.new_instance("Frame", {
				Parent = self.main_frame,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 18, 0, 57),
				Size = UDim2.new(1, -36, 1, -76),
				BorderSizePixel = 0,
				Visible = false
			});

			local left_side = utility_t.new_instance("Frame", {
				Parent = tab_section,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 0, 0, 0),
				Size = UDim2.new(0.5, -7, 1, 0),
				BorderSizePixel = 0
			});

			local right_side = utility_t.new_instance("Frame", {
				Parent = tab_section,
				BackgroundTransparency = 1,
				Position = UDim2.new(0.5, 7, 0, 0),
				Size = UDim2.new(0.5, -7, 1, 0),
				BorderSizePixel = 0
			});

			utility_t.new_instance("UIListLayout", {
				Parent = left_side,
				Padding = UDim.new(0, 16),
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Vertical
			});

			utility_t.new_instance("UIListLayout", {
				Parent = right_side,
				Padding = UDim.new(0, 16),
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Vertical
			});

			local switch_tab = function(tab)
				for i, v_tab in self.base.tabs do
					if v_tab == tab then
						v_tab.tab_section.Visible = true;
						v_tab.tab_button.TextColor3 = library_t.theme.accent;
					else
						v_tab.tab_section.Visible = false;
						v_tab.tab_button.TextColor3 = library_t.theme.text_color;
					end;
				end;

				self.base.current_tab = tab;
			end;

			local tab_object = {
				tab_section = tab_section,
				tab_button = tab_button,
				left_side = left_side,
				right_side = right_side,
				lib = self
			};

			local tab = setmetatable(tab_object, { __index = tabs });

			self.base.tabs[#self.base.tabs + 1] = tab; 
			self.base.tab_index += 1;

			if self.base.tab_index == 1 then
				switch_tab(tab);
			end;

			utility_t.connect(pressed_signal, function()
				switch_tab(tab);
			end);

			self.base.tab_lines[self.base.tab_index] = tab_line_frame;

			for i, tab_line in self.base.tab_lines do
				if i == #self.base.tabs then
					tab_line.Visible = false;
				else
					tab_line.Visible = true;
				end;
			end;

			return tab;
		end;

		library_t.new = function(properties)
			local _name = properties and properties.name or "linebot";
			local size = properties and properties.size or Vector2.new(600, 650);

			local is_dragging = false;
			local is_resizing = false;

			local initial_mouse_pos = Vector2.zero;
			local initial_frame_pos = Vector2.zero;

			local initial_mouse_pos_resize = Vector2.zero;
			local initial_size = Vector2.zero;

			local screen_gui = utility_t.new_instance("ScreenGui", {
				Parent = utility_t.get_path(),
				Name = "core",
				DisplayOrder = 1e5,
				ResetOnSpawn = false
			});

			local actual_size = typeof(size) == "Vector2" and UDim2.new(0, size.X, 0, size.Y) or size;

			local main_frame = utility_t.new_instance("Frame", {
				Parent = screen_gui,
				Size = actual_size,
				Position = UDim2.new(0.5, -size.X / 2, 0.5, -size.Y/ 2),
				BorderSizePixel = 0,
				BackgroundColor3 = library_t.theme.background_color
			});

			utility_t.new_instance("ImageLabel", {
				Parent = main_frame,
				Size = UDim2.new(1, 0, 1, 0),
				Position = UDim2.new(0, 0, 0, 0),
				BackgroundTransparency = 1,
				ImageColor3 = library_t.theme.dots_color,
				ScaleType = Enum.ScaleType.Tile,
				TileSize = UDim2.new(0, 8, 0, 8),
				Image = "rbxassetid://134950628747280"
			});

			local accent_line = utility_t.new_instance("Frame", {
				Parent = main_frame,
				Size = UDim2.new(1, -2, 0, 2),
				Position = UDim2.new(0, 1, 0, 1),
				BackgroundColor3 = Color3.new(1, 1, 1),
				BorderSizePixel = 0
			});

			utility_t.new_instance("UIGradient", {
				Parent = accent_line,
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, library_t.theme.accent),
					ColorSequenceKeypoint.new(1, utility_t.darken_color(library_t.theme.accent, 0.5))
				}),
				Rotation = 90
			});

			local cursor_frame;

			local mouse_location = user_input_service:GetMouseLocation();

			if library_t.cursor then
				cursor_frame = utility_t.new_instance("ImageLabel", {
					Parent = screen_gui,
					ZIndex = 1e6,
					Image = library_t.cursor,
					Visible = true,
					Size = UDim2.new(0, 34, 0, 34),
					Position = UDim2.new(0, mouse_location.X, 0, mouse_location.Y - 56),
					BackgroundTransparency = 1
				});
			end;

			utility_t.create_outlines(main_frame, {
				{ color = Color3.fromRGB(60, 60, 60), thickness = 1 },
				{ color = Color3.fromRGB(40, 40, 40), thickness = 1 },
				{ color = Color3.fromRGB(40, 40, 40), thickness = 1 },
				{ color = Color3.fromRGB(40, 40, 40), thickness = 1 },
				{ color = Color3.fromRGB(60, 60, 60), thickness = 1 },
				{ color = Color3.fromRGB(31, 31, 31), thickness = 1 }
			});

			local tab_frame = utility_t.new_instance("Frame", {
				Parent = main_frame,
				Position = UDim2.new(0, 18, 0, 19),
				Size = UDim2.new(1, -36, 0, 25),
				BackgroundColor3 = Color3.fromRGB(24, 24, 24),
				BorderSizePixel = 0
			});

			utility_t.new_instance("UIStroke", {
				Parent = tab_frame,
				LineJoinMode = Enum.LineJoinMode.Miter,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Color = Color3.fromRGB(44, 44, 44)
			});

			local _, drag_signal = utility_t.new_button({
				Parent = main_frame,
				Size = UDim2.new(1, 0, 0, 18),
				BackgroundTransparency = 1,
				TextTransparency = 1,
			});

			local _, resize_signal = utility_t.new_button({
				Parent = main_frame,
				Size = UDim2.new(0, 10, 0, 10),
				Position = UDim2.new(1, -10, 1, -10),
				BackgroundTransparency = 1,
				TextTransparency = 1,
			});

			local tab_padding = utility_t.new_instance("Frame", {
				Parent = tab_frame,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 1, -16),
				Position = UDim2.new(0, 0, 0, 8)
			});

			utility_t.new_instance("UIListLayout", {
				Parent = tab_padding,
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Horizontal
			});

			utility_t.connect(resize_signal, function()
				is_resizing = true;
				initial_size = main_frame.Size;
				initial_mouse_pos_resize = user_input_service:GetMouseLocation();
			end);

			utility_t.connect(drag_signal, function()
				is_dragging = true;
				initial_frame_pos = main_frame.Position;
				initial_mouse_pos = user_input_service:GetMouseLocation();
			end);

			local set_open = function(state)
				if state then
					context_action_service:BindAction("Scrolling", function() return Enum.ContextActionResult.Sink, nil end, false, Enum.UserInputType.MouseWheel);
				else
					context_action_service:UnbindAction("Scrolling");
				end;
			end;

			set_open(library_t.base.is_open);

			utility_t.connect(user_input_service.InputChanged, function(input, is_typing)
				if input.UserInputType == Enum.UserInputType.MouseMovement then
					if is_dragging then
						local current_mouse_pos = user_input_service:GetMouseLocation();
						local delta_x = current_mouse_pos.X - initial_mouse_pos.X;
						local delta_y = current_mouse_pos.Y - initial_mouse_pos.Y;

						main_frame.Position = UDim2.new(initial_frame_pos.X.Scale, initial_frame_pos.X.Offset + delta_x, initial_frame_pos.Y.Scale, initial_frame_pos.Y.Offset + delta_y);
					end;

					if is_resizing then
						local mouse_position = user_input_service:GetMouseLocation();

						local delta_x = mouse_position.X - initial_mouse_pos_resize.X;
						local delta_y = mouse_position.Y - initial_mouse_pos_resize.Y;

						local new_size = Vector2.new(
							math.max(initial_size.X.Offset + delta_x, size.X),
							math.max(initial_size.Y.Offset + delta_y, size.Y)
						);

						main_frame.Size = UDim2.new(0, new_size.X, 0, new_size.Y);
					end;

					if cursor_frame then
						local mouse_location = user_input_service:GetMouseLocation();
						cursor_frame.Position = UDim2.new(0, mouse_location.X, 0, mouse_location.Y - 56);
					end;
				end;
			end);

			utility_t.connect(user_input_service.InputEnded, function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					is_dragging = false;
					is_resizing = false;
				end;
			end);

			local main_library = setmetatable(library_t, {});

			main_library.screen_gui = screen_gui;
			main_library.tab_padding = tab_padding;
			main_library.main_frame = main_frame;

			utility_t.connect(user_input_service.InputBegan, function(input)
				if input.KeyCode == library_t.toggle_key then
					main_library.base.is_open = not main_library.base.is_open;
					screen_gui.Enabled = main_library.base.is_open;

					set_open(library_t.base.is_open);
				end;
			end);

			utility_t.connect(user_input_service.InputBegan, function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 and main_library.base.is_open then
					for _, button_object in buttons do
						if utility_t.is_mouse_in_frame(button_object.button) then
							if not utility_t.is_parents_visible(button_object.button) then
								continue;
							end;

							button_object.pressed:fire();
							break;
						end;
					end
				end;
			end);
			
			return main_library;
		end;

		library_t.create_config = function(self)
			local cfg = {};

			for flag,value in library_t.flags do
				if not self.base.key_flags[flag] then
					cfg[flag] = value;

					if type(value) == "table" and value.color then
						cfg[flag] = {color = {value.color.R, value.color.G, value.color.B}, transparency = value.transparency or nil};
					end;
				end;
			end;

			for flag,value in self.base.key_flags do
				cfg[flag] = value.Name;
			end;

			return http_service:JSONEncode(cfg);
		end;
		
		library_t.load_config = function(self, cfg)
			local actual_cfg = http_service:JSONDecode(cfg);

			for flag,value in actual_cfg do
				if self.base.save_flags[flag] then
					self.base.save_flags[flag](value);
				end;
			end;
		end;
	end;
end;

local window = library_t.new();
window:watermark("linemasterware | v1.0 | uid : 69 : ^o^ | cuddlesss!!");

local legit = window:tab({name = "legit"});
local _rage = window:tab({name = "rage"});
local _visuals = window:tab({name = "visuals"});
local _players = window:tab({name = "players"});
local settings = window:tab({name = "settings"});

local aim_assist = legit:section({name = "aim assist", size = 580});
local silent_aim = legit:section({name = "silent aim", side = "right", size = 464});
local triggerbot = legit:section({name = "triggerbot", side = "right", size = 100});

aim_assist:toggle({name = "enabled"});
aim_assist:keybind({name = "key", index_mode = true, callback = function(key)
	print("hellooooo qwq", key);
end});
aim_assist:toggle({name = "smoothing"});
aim_assist:toggle({name = "wallcheck"});
aim_assist:toggle({name = "friend check"})
aim_assist:toggle({name = "knocked check"});
aim_assist:toggle({name = "crew check"});
aim_assist:toggle({name = "grabbed check"});
aim_assist:toggle({name = "vehicle check"});
aim_assist:toggle({name = "field of view"}):colorpicker();
aim_assist:toggle({name = "line"}):colorpicker();
aim_assist:toggle({name = "deadzone"}):colorpicker();
aim_assist:toggle({name = "humanizer"});
aim_assist:textbox({name = "prediction", default = "0.134"});
aim_assist:dropdown({name = "prediction method", options = {"none", "normal", "simulate movement"}, default = "simulate movement"});
aim_assist:dropdown({name = "hitpart", options = {"head", "torso", "arms", "legs"}, default = "head"});
aim_assist:slider({name = "smoothing x", default = 10, min = 1, max = 15});
aim_assist:slider({name = "smoothing y", default = 10, min = 1, max = 15});
aim_assist:slider({name = "fov radius", default = 12.5, min = 0.5, max = 200, decimals = 0.01, suffix = "%"});
aim_assist:slider({name = "deadzone radius", default = 5.5, min = 0.5, max = 200, decimals = 0.01, suffix = "%"});
aim_assist:slider({name = "humanizer amount", default = 5, min = 0.5, max = 100, decimals = 0.01, suffix = "%"});
aim_assist:slider({name = "fov sides", default = 15, min = 3, max = 60});
aim_assist:slider({name = "deadzone sides", default = 15, min = 3, max = 60});
aim_assist:slider({name = "fov thickness", default = 1, min = 1, max = 10});
aim_assist:slider({name = "deadzone thickness", default = 1, min = 1, max = 10});
aim_assist:slider({name = "line thickness", default = 1, min = 1, max = 10});

silent_aim:toggle({name = "enabled"});
silent_aim:toggle({name = "wallcheck"});
silent_aim:toggle({name = "friend check"});
silent_aim:toggle({name = "knocked check"});
silent_aim:toggle({name = "crew check"});
silent_aim:toggle({name = "grabbed check"});
silent_aim:toggle({name = "vehicle check"});
silent_aim:toggle({name = "field of view"}):colorpicker();
silent_aim:toggle({name = "line"}):colorpicker();
silent_aim:toggle({name = "deadzone"}):colorpicker();
silent_aim:textbox({name = "prediction", default = "0.134"});
silent_aim:dropdown({name = "prediction method", options = {"none", "normal", "simulate movement"}, default = "simulate movement"});
silent_aim:dropdown({name = "hitpart", options = {"head", "torso", "arms", "legs"}, default = "head"});
silent_aim:slider({name = "fov radius", default = 12.5, min = 0.5, max = 200, decimals = 0.01, suffix = "%"});
silent_aim:slider({name = "deadzone radius", default = 5.5, min = 0.5, max = 200, decimals = 0.01, suffix = "%"});
silent_aim:slider({name = "fov sides", default = 15, min = 3, max = 60});
silent_aim:slider({name = "deadzone sides", default = 15, min = 3, max = 60});
silent_aim:slider({name = "fov thickness", default = 1, min = 1, max = 10});
silent_aim:slider({name = "deadzone thickness", default = 1, min = 1, max = 10});
silent_aim:slider({name = "line thickness", default = 1, min = 1, max = 10});

triggerbot:toggle({name = "enabled"});
triggerbot:toggle({name = "use prediction"});
triggerbot:toggle({name = "use delay"});
triggerbot:toggle({name = "knocked check"});
triggerbot:toggle({name = "crew check"});
triggerbot:toggle({name = "grabbed check"});
triggerbot:toggle({name = "vehicle check"});
triggerbot:textbox({name = "prediction", default = "0.134"});
triggerbot:slider({name = "delay", default = 5, min = 0, max = 10, decimals = 0.1, suffix = "s"});

--// config
do
	local config = settings:section({name = "config", size = 100});
	config:textbox({name = "config name", flag = "config_name"});
	config:button({name = "load", callback = function()
		local config_name = library_t.flags["config_name"];

		if config_name and isfile(library_t.assets_dir.."/"..config_name..".json") then
			window:load_config(readfile(library_t.assets_dir.."/"..config_name..".json"));
		end;
	end});
	config:button({name = "save", callback = function()
		local config_name = library_t.flags["config_name"];
		
		if config_name then
			writefile(library_t.assets_dir.."/"..config_name..".json", window:create_config());
		end;
	end});
end;
