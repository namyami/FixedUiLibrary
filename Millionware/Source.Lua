local Fonts; do 
    local HttpService = cloneref(game:GetService("HttpService"));
    Fonts = {
        Folder = "CustomFonts",

        ["windows-xp-tahoma"] = {
            FileName = {"windowsXPTahoma.ttf", "windowsXPTahoma.json"},
            Url = "https://raw.githubusercontent.com/sametexe001/luas/main/fonts/windows-xp-tahoma.ttf"
        };

        ["proggy-square"] = {
            FileName = {"proggySquare.ttf", "proggySquare.json"},
            Url = "https://github.com/sametexe001/luas/raw/refs/heads/main/fonts/proggy-square.ttf"
        };

        ["proggy-clean"] = {
            FileName = {"proggyClean.ttf", "proggySquare.json"},
            Url = "https://github.com/sametexe001/luas/raw/refs/heads/main/fonts/proggy-clean.ttf"
        };

        ["proggy-tiny"] = {
            FileName = {"proggyTiny.ttf", "proggyTiny.json"},
            Url = "https://github.com/sametexe001/luas/raw/refs/heads/main/fonts/proggy-tiny.ttf"
        };

        ["minecraftia"] = {
            FileName = {"minecraftia.ttf", "minecraftia.json"},
            Url = "https://github.com/sametexe001/luas/raw/refs/heads/main/fonts/minecraftia.ttf"
        };

        ["verdana"] = {
            FileName = {"verdana.ttf", "verdana.json"},
            Url = "https://github.com/sametexe001/luas/raw/refs/heads/main/fonts/verdana.ttf"
        };

        ["cozette-vector"] = {
            FileName = {"cozetteVector.ttf", "cozetteVector.json"},
            Url = "https://github.com/sametexe001/luas/raw/refs/heads/main/fonts/cozette-vector.ttf"
        };

        ["teachers-pet"] = {
            FileName = {"teachersPet.ttf", "teachersPet.json"},
            Url = "https://github.com/sametexe001/luas/raw/refs/heads/main/fonts/teachers-pet.ttf"
        };

        ["open-sans-px"] = {
            FileName = {"openSansPX.ttf", "openSansPX.json"},
            Url = "https://github.com/sametexe001/luas/raw/refs/heads/main/fonts/open-sans-px.ttf"
        };

        ["verdana-bold"] = {
            FileName = {"verdanabold.ttf", "verdanabold.json"},
            Url = "https://github.com/fayvrit/Typeface/blob/main/Fonts/VerdanaBold.ttf?raw=true"
        };
    };

    if not isfolder(Fonts.Folder) then
        makefolder(Fonts.Folder);
    end;

    for Name, FontData in Fonts do
        if type(FontData) == "table" then
            local FileName = FontData.FileName;
            
            if not isfile(Fonts.Folder .. "/" .. FileName[1]) then
                writefile(Fonts.Folder .. "/" .. FileName[1], game:HttpGet(FontData.Url));
            end;

            local Data = {
                Name = Name;
                Faces = {{
                    Name = "Regular";
                    Weight = 200;
                    Style = "Regular";
                    AssetId = getcustomasset(Fonts.Folder .. "/" .. FileName[1]);
                }};
            };

            if not isfile(Fonts.Folder .. "/" .. FileName[2]) then
                writefile(Fonts.Folder .. "/" .. FileName[2], HttpService:JSONEncode(Data));
            end;
        end;
    end;

    function Fonts.GetFont(Name)
        for FontName, FontData in Fonts do
            if FontName == Name then 
                return Font.new(getcustomasset(Fonts.Folder .. "/" .. FontData.FileName[2]));
            end;
        end;
    end;
end;

getgenv().Fonts = Fonts



local library, object, global, typeface = 
	{pointers = {}, flags = {}, configs = {}, activekeys = {}, functions = {}, hud = {}, windows = {}, popups = {}, loaded = false}, 
	{objects = {}, assets = {}, accents = {}, signals = {}, callbacks = {}}, 
	loadstring(game:HttpGet "https://github.com/fayvrit/millionware/raw/321a5dc7e7b9c274fcbff6219573670e8f2d3ed2/globals.lua")(),
	loadstring(game:HttpGet "https://github.com/fayvrit/Typeface/raw/refs/heads/main/Register.lua")()

library.bindstr = global.json("decode", global.request {Url = "https://github.com/fayvrit/millionware/raw/refs/heads/main/bindstr.json"}.Body)
library.accent = global.rgb(255, 139, 62)
library.menubind = Enum.KeyCode.Insert
library.core = global.hui

library.files = {
	directory = "millionware",
	config = "configs",
	font = "fonts"
}

library.primaryfont = Fonts.GetFont("verdana")
library.secondaryfont = Fonts.GetFont("proggy-clean")
library.boldfont = Fonts.GetFont("verdana-bold")

object.__index = object
library.__index = library
library.__lower = {
	__newindex = function(self, key, value)
		key = global.gsub(global.lower(key), "_", "")

		return global.valset(self, key, value)
	end,

	__index = function(self, key)
		key = global.gsub(global.lower(key), "_", "")

		return global.valget(self, key)
	end,
}

library.__oop = {
	__newindex = library.__lower.__newindex,

	__index = function(self, key)
		key = global.gsub(global.lower(key), "_", "")

		return global.valget(self, key) or library[key]
	end
}

--[[ Object Functions ]] do
	object.create = function(self, class, properties)
		local instance = {
			class = class,
			item = Instance.new(class)
		}

		setmetatable(instance, object)

		instance.Parent = properties.Parent or self.item or self

		for property, value in properties do
			if property == "Parent" then 
				continue 
			end

			if property == "Image" then 
				global.insert(object.assets, instance.item) 
			end

			if value == library.accent then 
				global.insert(object.accents, {item = instance.item, property = property})
			end

			instance[property] = value
		end

		global.insert(object.objects, instance)

		return instance
	end

	object.clean = function(self)
		self.item:Destroy()
		self = nil

		global.clean(object.objects, self)
	end

	object.tween = function(self, props)
		props = props or {}

		props.goal = props.goal
		props.duration = props.duration or 0.1
		props.direction = props.direction or "Out"
		props.style = props.style or "Quad"
		props.callback = props.callback or function() end

		props.tweeninfo = props.tweeninfo or TweenInfo.new(props.duration, Enum.EasingStyle[props.style], Enum.EasingDirection[props.direction])

		props.tween = global.tween:Create(self.item, props.tweeninfo, props.goal)
		props.tween:Play()

		global.wcall(props.duration, props.callback)

		return props.tween
	end

	object.drag = function(self, frame)
		self.drag = {}
		self.drag.active = false

		self.drag.start = global.dim2()
		self.drag.delta = global.dim2()

		self.drag.max = frame.Parent.AbsoluteSize - frame.AbsoluteSize

		self:connect("InputBegan", function(input)
			if not global.tfind({"MouseButton1", "Touch"}, input.UserInputType.Name) then return end

			self.drag.active = true
			self.drag.start = frame.Position - global.dim2(0, input.Position.X, 0, input.Position.Y)
		end)

		self:connect("InputEnded", function(input) 
			if not global.tfind({"MouseButton1", "Touch"}, input.UserInputType.Name) then return end

			self.drag.active = false
		end)

		object:connection(global.userinput.InputChanged, function(input) 
			if not self.drag.active or input.UserInputType.Name ~= "MouseMovement" then return end

			self.drag.max = frame.Parent.AbsoluteSize - frame.AbsoluteSize
			self.drag.delta = self.drag.start + global.dim2(0, input.Position.X, 0, input.Position.Y)
			self.drag.delta = global.dim2(
				0, global.clamp(self.drag.delta.X.Offset, 0, self.drag.max.X > 0 and self.drag.max.X or 0),
				0, global.clamp(self.drag.delta.Y.Offset, 0, self.drag.max.Y > 0 and self.drag.max.Y or 0)
			)

			frame:tween{duration = 0.17, goal = {Position = self.drag.delta}}
		end)
	end

	object.resize = function(self, frame, min, max)
		min = min or Vector2.new(500, 400)

		self.resize = {}
		self.resize.active = false

		self.resize.start = global.dim2()
		self.resize.delta = global.dim2()

		self.resize.max = max or frame.Parent.AbsoluteSize - frame.AbsolutePosition

		self:connect("InputBegan", function(input)
			if not global.tfind({"MouseButton1", "Touch"}, input.UserInputType.Name) then return end

			self.resize.active = true
			self.resize.start = frame.Size - global.dim2(0, input.Position.X, 0, input.Position.Y)
		end)

		self:connect("InputEnded", function(input) 
			if not global.tfind({"MouseButton1", "Touch"}, input.UserInputType.Name) then return end

			self.resize.active = false
		end)

		object:connection(global.userinput.InputChanged, function(input) 
			if not self.resize.active or input.UserInputType.Name ~= "MouseMovement" then return end

			self.resize.max = max or frame.Parent.AbsoluteSize - frame.AbsolutePosition
			self.resize.delta = self.resize.start + global.dim2(0, input.Position.X, 0, input.Position.Y)
			self.resize.delta = global.dim2(
				0, global.clamp(self.resize.delta.X.Offset, min.X, self.resize.max.X),
				0, global.clamp(self.resize.delta.Y.Offset, min.Y, self.resize.max.Y)
			)

			frame:tween{duration = 0.1, goal = {Size = self.resize.delta}}
		end)
	end

	object.connection = function(self, signal, callback, nothread)
		if nothread then
			local connection = signal:Connect(callback)
			global.insert(object.signals, connection)
			return connection
		end

		local connection = global.setmeta({
			signal = signal,
			callback = callback
		}, object)

		object.callbacks[signal] = object.callbacks[signal] or {}
		global.insert(object.callbacks[signal], callback)

		object.signals[signal] = object.signals[signal] or signal:Connect(function(...)
			local args = ...

			for _, callback in object.callbacks[signal] do
				global.thread(callback)(args)
			end
		end)

		return connection
	end

	object.disconnect = function(self)
		if global.is(self) ~= "table" then 
			return self:Disconnect()
		end

		local index = global.tfind(object.callbacks[self.signal], self.callback)
		assert(index, "Attempted to disconnect an invalid signal!")

		global.remove(object.callbacks[self.signal], index)
	end

	object.connect = function(self, method, callback)
		return object:connection(self[method], callback, true)
	end

	object.lowercase = function(target, info)
		info = info or {}

		info.noreplicate = info.noreplicate or false
		info.native = info.native or false
		info.oriented = info.oriented or false

		local infos = {}

		if type(target) ~= "table" then return end

		for key, value in target do
			if global.num(key) then global.insert(infos, value) continue end

			if type(value) == "table" and not info.noreplicate then
				value = info.native and global.equipmeta(value, value) or object.lowercase(value)
			end

			infos[global.lower(key)] = value
		end

		target = nil
		return global.setmeta(infos, library[info.oriented and "__oop" or "__lower"]) 
	end

	object.rgbtostr = function(color)
		return `rgb({global.round(color.R * 255, 1)},{global.round(color.G * 255, 1)},{global.round(color.B * 255, 1)})`
	end

	object.strtorgb = function(str)
		return global.rgb(global.match(str, "rgb%((%d+),(%d+),(%d+)%)"))
	end

	object.strtokey = function(str)
		return global.tfind(library.bindstr, str)
	end

	object.__newindex = function(self, key, value)
		value = global.is(value) == "table" and value.item or value

		if global.pcall(function() self.item[key] = value end) then 
			return
		end

		global.valset(self, key, value) 
	end

	object.__index = function(self, key)
		return global.valget(self, key) or object[key] or self.item[key]
	end
end

library.onload = object.lowercase({connected = {}}, {oriented = true})

-- Library:Set > Accent ( PROCEDURAL )
library.functions.accent = function(color)
	if color == library.accent then return end

	library.accent = color

	for _, obj in object.accents do
		obj.item[obj.property] = library.accent
	end
end

-- Library:Set > Bind ( PROCEDURAL )
library.functions.bind = function(key)
	if key == library.menubind then return end

	library.menubind = key
end

-- Library:Set > Keylist ( PROCEDURAL )
library.functions.keylist = function(list)
	if list == library.activekeys then return end

	library.activekeys = list
end

-- Library > Getsettings ( PROCEDURAL )
library.getsettings = function()
	local config = {}

	for key, element in library.pointers do
		if not element.config then continue end

		config[key] = {}

		if element.is == "colorpicker" then
			config[key].color = object.rgbtostr(element.color)
			config[key].alpha = element.alpha

			continue
		end

		if element.is == "keybind" then
			config[key].mode = element.mode
			config[key].key = element.str

			continue
		end

		config[key].default = element.default or element.value or element.enabled
	end

	return config
end

-- Library > Loadsettings ( PROCEDURAL )
library.loadsettings = function(config)
	for key, element in config do
		local pointer = library.pointers[key]

		if not pointer then continue end

		if pointer.is == "colorpicker" then
			element.color = object.strtorgb(element.color)
			pointer:set("color", element.color, element.alpha)

			continue
		end

		if pointer.is == "keybind" then
			pointer:set("mode", element.mode)
			pointer:set("key", element.key)

			continue
		end

		pointer:set("default", element.default)
	end
end

-- Library > Makefolders ( PROCEDURAL )
library.makefolders = function()
	if not isfolder(library.files.directory) then 
		makefolder(library.files.directory)
	end
	
	if not isfolder(library.files.directory .. "\\" .. library.files.config) then 
		makefolder(library.files.directory .. "\\" .. library.files.config)
	end
end

-- Library > Listconfigs ( PROCEDURAL )
library.listconfigs = function()
	library.makefolders()

	local files = {}
	
	for _, file in listfiles(library.files.directory .. "\\" .. library.files.config) do
		file = global.gsub(file, `^C:\\.*\\workspace\\{ library.files.directory }\\{ library.files.config }\\`, "")
		file = global.gsub(file, "%.JSON$", "")

		global.insert(files, file)
	end
	
	return files
end

-- Library > Writeconfig ( PROCEDURAL )
library.writeconfig = function(name)
	local config_json = library.getsettings()

	config_json = global.json("encode", config_json)

	library.makefolders()
	
	writefile(library.getdirectory(name), config_json)
end

-- Library > Deleteconfig ( PROCEDURAL )
library.deleteconfig = function(name)
	library.makefolders()
	
	if not library.isconfig(name) then return end

	delfile(library.getdirectory(name), config_json)
end

-- Library > Loadconfig ( PROCEDURAL )
library.loadconfig = function(name)
	if not library.isconfig(name) then return end
	
	library.makefolders()

	local config = readfile(library.getdirectory(name))
	config = global.json("decode", config)
	library.loadsettings(config)
end

-- Library > Isconfig ( PROCEDURAL )
library.isconfig = function(name)
	library.makefolders()

	return isfile(library.getdirectory(name))
end

-- Library > Getdirectory ( PROCEDURAL )
library.getdirectory = function(name)
	return library.files.directory .. "\\" .. library.files.config .. "\\" .. name .. ".JSON"
end

-- Library > Next ( PROCEDURAL )
library.next = function(key)
	local index = global.length(library.flags, key) 
	index = index > 0 and index + 1 or ""

	return (key or "") ..  index
end

-- Library OR Self > Set ( PROCEDURAL )
library.set = function(self, property, ...)
	local func = self.functions[global.lower(property)]

	return func and func(...) or nil 
end

-- Library OR Self > Connect ( PROCEDURAL )
library.connect = function(self, callback)
	local info = object.lowercase({}, {oriented = true})

	info.callback = callback
	info.signal = self

	global.insert(self.connected, callback)

	return info
end

-- Library OR Connect > Disconnect ( PROCEDURAL )
library.disconnect = function(self)
	return global.clean(self.signal.connected, self.callback)
end

-- Library > Initialize ( PROCEDURAL )
library.initialize = function(self, info)
	info = object.lowercase(info or {}, {oriented = true})

	info.loaded = 0
	info.loading = library:intro()
	info.functions = {}

	info.listener = function(...)
		for _, func in library.onload.connected do
			global.thread(func)(...)
		end
	end

	info.functions.load = function()
		if library.loaded then return end

		info.start_time = global.round(global.tick(), 0.01)

		global.content:PreloadAsync(object.assets, function(id, a)
			info.loading:set("value", (info.loaded / #object.assets) * 100)
			info.loaded += 1
		end)

		info.load_time = global.round(global.tick() - info.start_time, 0.01)
		info.loading:set("status", `completed in { info.load_time }s`)

		library.loaded = true
		library.windows[1]:set("visible", true)
		global.wcall(1, info.loading.functions.visible)
		global.thread(info.listener)()
	end

	global.wcall(1, info.functions.load)

	library.makefolders()

	object:connection(global.userinput.InputBegan, function(input)		
		if not library.loaded or input.KeyCode ~= library.menubind then return end

		for _, window in library.windows do
			window:set("visible")
		end
	end)

	return info
end

-- Library > Unload ( PROCEDURAL )
library.unload = function(self, info)
	info = object.lowercase({info or {}}, {oriented = true})

	info.signals = function()
		for _, signal in object.signals do
			signal:Disconnect()
		end

		object.callbacks = nil
		object.signals = nil
	end

	info.objects = function()
		for _, window in library.windows do
			window:Set("Visible", false)
		end

		global.wait(.1)

		for _, object in object.objects do
			object:clean()
		end

		object.objects = nil
		object.accents = nil
		object.assets = nil
	end

	global.call(info.signals)
	global.call(info.objects)
end

-- Library > Intro
library.intro = function(self, info)
	info = object.lowercase(info or {}, {oriented = true})

	info.size = info.size or Vector2.new(200, 50)
	info.position = info.position or Vector2.new((global.camera.ViewportSize.X - info.size.X) / 2, (global.camera.ViewportSize.Y - info.size.Y) / 2)
	info.status = info.status or "loading..."
	info.value = info.value or 0

	info.visible = global.declare(true, info.visible)
	info.functions = {}

	local objects = {} do
		objects ['framework'] = library ['framework'] or object:create("ScreenGui", {
			Parent = library.core,
			Name = "framework",
			IgnoreGuiInset = true,
			DisplayOrder = 100
		})

		objects ['overlay'] = library ['overlay'] or objects ['framework']:create("TextButton", {
			TextColor3 = global.rgb(0, 0, 0),
			BorderColor3 = global.rgb(0, 0, 0),
			Text = "",
			Name = "overlay",
			Modal = true,
			BackgroundTransparency = 1,
			Size = global.dim2(1, 0, 1, 0),
			BorderSizePixel = 0,
			ZIndex = 0,
			TextSize = 14,
			BackgroundColor3 = global.rgb(255, 255, 255),
		})

		objects ['background'] = objects ['framework']:create("Frame", {
			Name = "background",
			BorderColor3 = global.rgb(30, 30, 30),
			Position = global.dim2(0, info.position.X, 0, info.position.Y),
			Size = global.dim2(0, info.size.X, 0, info.size.Y),
			BorderSizePixel = 2,
			BackgroundColor3 = global.rgb(13, 13, 13)
		})

		objects ['hitbox'] = objects ['background']:create("TextButton", {
			TextColor3 = global.rgb(0, 0, 0),
			BorderColor3 = global.rgb(0, 0, 0),
			Text = "",
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			Name = "hitbox",
			Size = global.dim2(1, 0, 1, 0),
			BorderSizePixel = 0,
			TextSize = 14,
			BackgroundColor3 = global.rgb(25, 25, 25)
		})

		objects ['dragbox'] = objects ['background']:create("TextButton", {
			TextColor3 = global.rgb(0, 0, 0),
			BorderColor3 = global.rgb(0, 0, 0),
			Text = "",
			BackgroundTransparency = 1,
			Name = "dragbox",
			Size = global.dim2(1, 0, 0, 20),
			BorderSizePixel = 0,
			TextSize = 14,
			BackgroundColor3 = global.rgb(255, 255, 255),
			ZIndex = 2,
		})

		objects ['outline'] = objects ['background']:create("UIStroke", {
			LineJoinMode = Enum.LineJoinMode.Miter,
			Name = "border",
		})

		objects ['main'] = objects ['background']:create("Frame", {
			BackgroundTransparency = 1,
			Name = "main",
			BorderColor3 = global.rgb(0, 0, 0),
			Size = global.dim2(1, 0, 1, 0),
			BorderSizePixel = 0,
			BackgroundColor3 = global.rgb(255, 255, 255)
		})

		objects ['list'] = objects ['main']:create("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Name = "list"
		})

		objects ['safezone'] = objects ['main']:create("UIPadding", {
			PaddingTop = global.dim(0, 10),
			Name = "safezone",
			PaddingBottom = global.dim(0, 10),
			PaddingRight = global.dim(0, 10),
			PaddingLeft = global.dim(0, 10)
		})

		objects ['status'] = objects ['main']:create("TextLabel", {
			FontFace = library.primaryfont,
			TextColor3 = global.rgb(200, 200, 200),
			BorderColor3 = global.rgb(0, 0, 0),
			Text = info.status,
			BackgroundTransparency = 1,
			Name = "status",
			Size = global.dim2(1, 0, 0, 20),
			BorderSizePixel = 0,
			TextSize = 11,
			BackgroundColor3 = global.rgb(255, 255, 255)
		})

		objects ['safezone'] = objects ['status']:create("UIPadding", {
			Name = "safezone",
			PaddingBottom = global.dim(0, 10),
			PaddingRight = global.dim(0, 10),
			PaddingLeft = global.dim(0, 10)
		})

		objects ['progress'] = objects ['main']:create("Frame", {
			Name = "progress",
			Position = global.dim2(0, 0, 1, 0),
			BorderColor3 = global.rgb(0, 0, 0),
			Size = global.dim2(1, 0, 0, 10),
			BorderSizePixel = 2,
			BackgroundColor3 = global.rgb(13, 13, 13)
		})

		objects ['border'] = objects ['progress']:create("UIStroke", {
			Color = global.rgb(30, 30, 30),
			LineJoinMode = Enum.LineJoinMode.Miter,
			Name = "border"
		})

		objects ['accent'] = objects ['progress']:create("Frame", {
			Name = "accent",
			BorderColor3 = global.rgb(0, 0, 0),
			Size = global.dim2(info.value / 100, 0, 1, 0),
			BorderSizePixel = 0,
			BackgroundColor3 = library.accent
		})

		library ['framework'] = library ['framework'] or objects ['framework']
		library ['overlay'] = library ['overlay'] or objects ['overlay']
	end

	objects ['dragbox']:drag(objects ['background'])

	info.functions.status = function(str)
		if info.status == str then return end

		info.status = str
		objects ['status'].Text = info.status
	end

	info.functions.value = function(value)
		value = global.clamp(value, 0, 100)

		if info.value == value then return end

		info.value = value
		objects ['accent']:tween{duration = 0.1, goal = {Size = global.dim2(info.value / 100, 0, 1, 0)}}
	end

	info.functions.visible = function(bool)
		if info.visible == bool then return end

		info.visible = global.declare(not info.visible, bool)

		objects ['background'].Visible = true
		objects ['main'].Visible = false

		objects ['outline']:tween{duration = 0.5, goal = {Transparency = info.visible and 0 or 1}}
		objects ['background']:tween{duration = 0.5, goal = {BackgroundTransparency = info.visible and 0 or 1}, callback = function()
			objects ['main'].Visible = info.visible
			objects ['background'].Visible = info.visible
		end}
	end

	return info
end

-- Library > Window List
library.windowlist = function(self, info)
	info = object.lowercase(info or {}, {oriented = true})

	info.title = info.title or "List"
	info.size = info.size or Vector2.new(214, 30)
	info.visible = global.declare(true, info.visible)
	info.pointer = library.next(info.pointer or "window list")
	info.position = info.position or Vector2.new(5, (global.camera.ViewportSize.Y - info.size.Y) / 2)

	info.values = {}
	info.contents = {}
	info.functions = {}

	local objects = {} do
		objects ['framework'] = library ['framework'] or object:create("ScreenGui", {
			Parent = library.core,
			Name = "framework",
			IgnoreGuiInset = true,
			DisplayOrder = 100
		})

		objects ['window_list'] = objects ['framework']:create("Frame", {
			Size = global.dim2(0, info.size.X, 0, info.size.Y),
			Name = "window_list",
			Position = global.dim2(0, info.position.X, 0, info.position.Y),
			BorderColor3 = global.rgb(0, 0, 0),
			BorderSizePixel = 0,
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = global.rgb(14, 14, 14),
			BackgroundTransparency = info.visible and 0 or 1,
			Visible = info.visible
		})

		objects ['main_border'] = objects ['window_list']:create("UIStroke", {
			LineJoinMode = Enum.LineJoinMode.Miter,
			Name = "border",
			Transparency = info.visible and 0 or 1
		})

		objects ['hitbox'] = objects ['window_list']:create("TextButton", {
			TextColor3 = global.rgb(0, 0, 0),
			BorderColor3 = global.rgb(0, 0, 0),
			Text = "",
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			Name = "hitbox",
			Size = global.dim2(1, 0, 1, 0),
			BorderSizePixel = 0,
			TextSize = 14,
			BackgroundColor3 = global.rgb(25, 25, 25)
		})

		objects ['dragbox'] = objects ['window_list']:create("TextButton", {
			TextColor3 = global.rgb(0, 0, 0),
			BorderColor3 = global.rgb(0, 0, 0),
			Text = "",
			BackgroundTransparency = 1,
			Name = "dragbox",
			Size = global.dim2(1, 0, 0, 20),
			BorderSizePixel = 0,
			TextSize = 14,
			BackgroundColor3 = global.rgb(255, 255, 255),
			ZIndex = 2,
		})

		objects ['main'] = objects ['window_list']:create("Frame", {
			Name = "main",
			BackgroundTransparency = 1,
			Size = global.dim2(1, 0, 1, 0),
			BorderColor3 = global.rgb(0, 0, 0),
			BorderSizePixel = 0,
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = global.rgb(14, 14, 14),
			Visible = info.visible
		})

		objects ['border'] = objects ['main']:create("UIStroke", {
			LineJoinMode = Enum.LineJoinMode.Miter,
			Name = "border"
		})

		objects ['topbar'] = objects ['main']:create("Frame", {
			Name = "topbar",
			BorderColor3 = global.rgb(0, 0, 0),
			Size = global.dim2(1, 0, 0, 20),
			BorderSizePixel = 0,
			BackgroundColor3 = global.rgb(25, 25, 25),
			LayoutOrder = 4
		})

		objects ['fade'] = objects ['topbar']:create("UIGradient", {
			Rotation = 90,
			Name = "fade",
			Color = global.rgbseq{global.rgbkey(0, global.rgb(255, 255, 255)), global.rgbkey(0.37, global.rgb(231, 231, 231)), global.rgbkey(1, global.rgb(155, 155, 155))}
		})

		objects ['label'] = objects ['topbar']:create("TextLabel", {
			FontFace = library.primaryfont,
			TextColor3 = global.rgb(250, 250, 250),
			BorderColor3 = global.rgb(0, 0, 0),
			Text = info.title,
			Name = "label",
			BackgroundTransparency = 1,
			Size = global.dim2(1, 0, 1, 0),
			BorderSizePixel = 0,
			AutomaticSize = Enum.AutomaticSize.X,
			TextSize = 11,
			BackgroundColor3 = global.rgb(18, 18, 18)
		})

		objects ['safezone'] = objects ['label']:create("UIPadding", {
			PaddingTop = global.dim(0, 8),
			Name = "safezone",
			PaddingBottom = global.dim(0, 10),
			PaddingRight = global.dim(0, 2)
		})

		objects ['contents'] = objects ['main']:create("Frame", {
			Name = "contents",
			Size = global.dim2(1, -16, 0, 0),
			BorderColor3 = global.rgb(0, 0, 0),
			BorderSizePixel = 0,
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = global.rgb(20, 20, 20),
			LayoutOrder = 5,
		})

		objects ['border'] = objects ['contents']:create("UIStroke", {
			LineJoinMode = Enum.LineJoinMode.Miter,
			Name = "border"
		})

		objects ['list'] = objects ['contents']:create("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Name = "list"
		})

		objects ['list'] = objects ['main']:create("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Name = "list"
		})

		objects ['safezone'] = objects ['main']:create("UIPadding", {
			PaddingBottom = global.dim(0, 8),
			Name = "safezone"
		})

		library ['framework'] = library ['framework'] or objects ['framework']

		info.objects = objects
	end

	objects ['dragbox']:drag(objects ['window_list'])

	info.functions.visible = global.thread(function(bool)
		info.visible = global.declare(not info.visible, bool)

		objects ['window_list'].Visible = true
		objects ['main'].Visible = false

		objects ['main_border']:tween{duration = 0.1, goal = {Transparency = info.visible and 0 or 1}}
		objects ['window_list']:tween{duration = 0.1, goal = {BackgroundTransparency = info.visible and 0 or 1}, callback = function()
			objects ['main'].Visible = info.visible
			objects ['window_list'].Visible = info.visible
		end}
	end)

	global.setmeta(info.contents, {
		__newindex = function(self, index, value)
			info:info(value)

			if value.visible then return end

			global.valset(self, index, nil)
		end,
	})

	global.valset(library.pointers, info.pointer, info)
	global.insert(library.hud, info)

	return info
end

-- Window List > Info
library.info = function(self, info)
	info = object.lowercase(info or {}, {oriented = true})

	info.title = info.title or "value"
	info.visible = global.declare(true, info.visible)
	info.key = library.next(info.key or "value")

	info.value = self.values[info.key]
	info.functions = {}

	if info.value then
		info.value:set("visible", info.visible)
		info.value:set("title", info.title)

		return 
	end

	local objects = {} do
		objects ['element'] = self.objects ['contents']:create("Frame", {
			BackgroundTransparency = 1,
			Name = "element",
			BorderColor3 = global.rgb(0, 0, 0),
			Size = global.dim2(1, 0, 0, 15),
			BorderSizePixel = 0,
			Visible = info.visible,
			BackgroundColor3 = global.rgb(20, 20, 20)
		})

		objects ['safezone'] = objects ['element']:create("UIPadding", {
			PaddingBottom = global.dim(0, 1),
			PaddingLeft = global.dim(0, 5),
			Name = "safezone"
		})

		objects ['label'] = objects ['element']:create("TextLabel", {
			FontFace = library.primaryfont,
			TextColor3 = global.rgb(250, 250, 250),
			BorderColor3 = global.rgb(0, 0, 0),
			Text = info.title,
			Name = "label",
			AutomaticSize = Enum.AutomaticSize.X,
			AnchorPoint = global.vec2(0, 0.5),
			Size = global.dim2(0, 0, 1, 0),
			BackgroundTransparency = 1,
			Position = global.dim2(0, 0, 0.5, 0),
			BorderSizePixel = 0,
			ZIndex = 15,
			TextSize = 11,
			BackgroundColor3 = global.rgb(20, 20, 20)
		})

		objects ['accent'] = objects ['element']:create("TextLabel", {
			FontFace = library.boldfont,
			Name = "accent",
			TextColor3 = global.rgb(255, 139, 62),
			TextTransparency = 1,
			Text = info.title,
			AutomaticSize = Enum.AutomaticSize.X,
			Size = global.dim2(0, 0, 1, 0),
			AnchorPoint = global.vec2(0, 0.5),
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			Position = global.dim2(0, 0, 0.5, 0),
			BorderColor3 = global.rgb(0, 0, 0),
			ZIndex = 15,
			TextSize = 11,
			BackgroundColor3 = global.rgb(20, 20, 20)
		})
	end

	info.functions.title = global.thread(function(value)
		if info.title == value then return end

		info.title = value
		objects ['label'].Text = info.title
	end)

	info.functions.visible = global.thread(function(bool)
		info.visible = global.declare(not info.visible, bool)

		objects ['element'].Visible = info.visible
	end)

	global.valset(self.values, info.key, info)
	return info
end	

-- Library > Keybind List
library.keybindlist = function(self, info)
	info = library:windowlist(info or {})

	library:set("keylist", info)

	return info
end

-- Library > Window
library.window = function(self, info)
	info = object.lowercase(info or {}, {oriented = true})

	info.title = info.title or ""
	info.active = info.active or false
	info.bind = info.bind or library.menubind
	info.size = info.size or Vector2.new(680, 490)
	info.icon = info.icon or "rbxassetid://107774368443834"
	info.iconaccent = info.iconaccent or info.icon_accent or "rbxassetid://124534868267001"
	info.minsize = info.minsize or info.min_size or info.minimumsize or info.minimum_size or Vector2.new(500, 400)
	info.position = info.position or Vector2.new((global.camera.ViewportSize.X - info.size.X) / 2, (global.camera.ViewportSize.Y - info.size.Y) / 2)

	info.pages = {}
	info.functions = {}

	local objects = {} do
		objects ['framework'] = library ['framework'] or object:create("ScreenGui", {
			Parent = library.core,
			Name = "framework",
			IgnoreGuiInset = true,
			DisplayOrder = 100
		})

		objects ['overlay'] = library ['overlay'] or objects ['framework']:create("TextButton", {
			TextColor3 = global.rgb(0, 0, 0),
			BorderColor3 = global.rgb(0, 0, 0),
			Text = "",
			Name = "overlay",
			Modal = true,
			BackgroundTransparency = 1,
			Size = global.dim2(1, 0, 1, 0),
			BorderSizePixel = 0,
			ZIndex = 0,
			TextSize = 14,
			BackgroundColor3 = global.rgb(255, 255, 255),
			Visible = false
		})

		objects ['background'] = objects ['framework']:create("ImageLabel", {
			ScaleType = Enum.ScaleType.Slice,
			BorderColor3 = global.rgb(0, 0, 0),
			Image = "rbxassetid://116726732387056",
			Name = "background",
			Position = global.dim2(0, info.position.X, 0, info.position.Y),
			Size = global.dim2(0, info.size.X, 0, info.size.Y),
			BackgroundColor3 = global.rgb(255, 255, 255),
			BorderSizePixel = 0,
			SliceCenter = global.rect(global.vec2(20, 20), global.vec2(590, 380)),
			BackgroundTransparency = 1,
			ImageTransparency = 1,
			Visible = false
		})

		objects ['dragbox'] = objects ['background']:create("TextButton", {
			TextColor3 = global.rgb(0, 0, 0),
			BorderColor3 = global.rgb(0, 0, 0),
			Text = "",
			BackgroundTransparency = 1,
			Name = "dragbox",
			Size = global.dim2(1, 0, 0, 20),
			BorderSizePixel = 0,
			ZIndex = 2
		})

		objects ['resizexy'] = objects ['background']:create("TextButton", {
			TextColor3 = global.rgb(0, 0, 0),
			BorderColor3 = global.rgb(0, 0, 0),
			Text = "",
			Name = "resizexy",
			BackgroundTransparency = 1,
			Position = global.dim2(1, -5, 1, -5),
			Size = global.dim2(0, 12, 0, 12),
			BorderSizePixel = 0,
			TextSize = 14,
			BackgroundColor3 = global.rgb(255, 255, 255),
			ZIndex = 2
		})

		objects ['hitbox'] = objects ['background']:create("TextButton", {
			TextColor3 = global.rgb(0, 0, 0),
			BorderColor3 = global.rgb(0, 0, 0),
			Text = "",
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			Name = "hitbox",
			Size = global.dim2(1, 0, 1, 0),
			BorderSizePixel = 0,
			TextSize = 14,
			BackgroundColor3 = global.rgb(25, 25, 25)
		})

		objects ['main'] = objects ['background']:create("Frame", {
			Name = "main",
			Position = global.dim2(0, 10, 0, 30),
			BorderColor3 = global.rgb(0, 0, 0),
			Size = global.dim2(1, -20, 1, -40),
			BorderSizePixel = 0,
			BackgroundColor3 = global.rgb(18, 18, 18),
			Visible = false,
		})

		objects ['border'] = objects ['main']:create("UIStroke", {
			LineJoinMode = Enum.LineJoinMode.Miter,
			Name = "border"
		})

		objects ['pages'] = objects ['main']:create("Frame", {
			Name = "pages",
			Position = global.dim2(0, 130, 0, 0),
			BorderColor3 = global.rgb(0, 0, 0),
			Size = global.dim2(1, -130, 1, 0),
			BorderSizePixel = 0,
			BackgroundColor3 = global.rgb(18, 18, 18)
		})

		objects ['border'] = objects ['pages']:create("UIStroke", {
			LineJoinMode = Enum.LineJoinMode.Miter,
			Name = "border"
		})

		objects ['safezone'] = objects ['main']:create("UIPadding", {
			PaddingTop = global.dim(0, 6),
			Name = "safezone",
			PaddingBottom = global.dim(0, 6),
			PaddingRight = global.dim(0, 6)
		})

		objects ['sidepanel'] = objects ['main']:create("Frame", {
			BackgroundTransparency = 1,
			Name = "sidepanel",
			BorderColor3 = global.rgb(0, 0, 0),
			Size = global.dim2(0, 130, 1, 0),
			BorderSizePixel = 0,
			BackgroundColor3 = global.rgb(255, 255, 255)
		})

		objects ['logo'] = objects ['sidepanel']:create("Frame", {
			BackgroundTransparency = 1,
			Name = "logo",
			BorderColor3 = global.rgb(0, 0, 0),
			Size = global.dim2(1, 0, 0, 80),
			BorderSizePixel = 0,
			BackgroundColor3 = global.rgb(255, 255, 255)
		})

		objects ['icon'] = objects ['logo']:create("ImageLabel", {
			ScaleType = Enum.ScaleType.Slice,
			BorderColor3 = global.rgb(0, 0, 0),
			Image = library.icon,
			BackgroundTransparency = 1,
			Position = global.dim2(0, 14, 0, 10),
			Name = "icon",
			Size = global.dim2(0, 97, 0, 42),
			BorderSizePixel = 0,
			BackgroundColor3 = global.rgb(255, 255, 255)
		})

		objects ['dollar'] = objects ['logo']:create("ImageLabel", {
			ImageColor3 = library.accent,
			BorderColor3 = global.rgb(0, 0, 0),
			Image = info.iconaccent,
			BackgroundTransparency = 1,
			Position = global.dim2(0, 14, 0, 10),
			Name = "dollar",
			Size = global.dim2(0, 97, 0, 42),
			BorderSizePixel = 0,
			BackgroundColor3 = global.rgb(255, 255, 255)
		})

		objects ['pagebuttons'] = objects ['sidepanel']:create("Frame", {
			BorderColor3 = global.rgb(0, 0, 0),
			Name = "pagebuttons",
			BackgroundTransparency = 1,
			Position = global.dim2(0, 4, 0, 80),
			Size = global.dim2(1, -9, 1, -80),
			ZIndex = 2,
			BorderSizePixel = 0,
			BackgroundColor3 = global.rgb(255, 255, 255)
		})

		objects ['list'] = objects ['pagebuttons']:create("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Name = "list",
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
			Padding = global.dim(0, 5)
		})

		library ['framework'] = library ['framework'] or objects ['framework']
		library ['overlay'] = library ['overlay'] or objects ['overlay']

		info.objects = objects
	end

	library.menubind = info.bind

	objects ['dragbox']:drag(objects ['background'])
	objects ['resizexy']:resize(objects ['background'], info.minsize)

	info.functions.visible = global.thread(function(bool)
		info.active = global.declare(not info.active, bool)

		objects ['background'].Visible = true
		objects ['main'].Visible = false
		objects ['overlay'].Visible = info.active

		objects ['background']:tween{duration = 0.1, goal = {ImageTransparency = info.active and 0 or 1}, callback = function()
			objects ['main'].Visible = info.active
			objects ['background'].Visible = info.active
		end}
	end)

	global.insert(library.windows, info)
	return info
end

-- Window > Page
library.page = function(self, info)
	info = object.lowercase(info or {}, {oriented = true})

	info.title = info.title or "page"

	info.active = #self.pages < 1
	info.hovered = false
	info.instances = {}
	info.functions = {}

	assert(self.objects ['pagebuttons'])

	local objects = {} do
		objects ['button'] = self.objects ['pagebuttons']:create("TextButton", {
			FontFace = library.primaryfont,
			TextColor3 = global.rgb(200, 200, 200),
			BorderColor3 = global.rgb(0, 0, 0),
			Text = info.title,
			AutoButtonColor = false,
			BorderSizePixel = 0,
			Name = "button",
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = global.dim2(0, 200, 0, 28),
			ZIndex = 2,
			TextSize = 11,
			BackgroundColor3 = global.rgb(23, 23, 23),
			BackgroundTransparency = info.active and 0 or 1,
		})

		objects ['border'] = objects ['button']:create("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			LineJoinMode = Enum.LineJoinMode.Miter,
			Name = "border"
		})

		objects ['safezone'] = objects ['button']:create("UIPadding", {
			PaddingTop = global.dim(0, 8),
			Name = "safezone",
			PaddingBottom = global.dim(0, 10),
			PaddingRight = global.dim(0, 10),
			PaddingLeft = global.dim(0, 10)
		})

		objects ['disable'] = objects ['button']:create("Frame", {
			AnchorPoint = global.vec2(0.5, 0.5),
			Name = "disable",
			Position = global.dim2(0.5, 0, 0.5, 1),
			BorderColor3 = global.rgb(0, 0, 0),
			Size = global.dim2(1, 20, 1, 18),
			BorderSizePixel = 0,
			BackgroundColor3 = global.rgb(15, 15, 15),
		})

		objects ['accent'] = objects ['button']:create("Frame", {
			BorderColor3 = global.rgb(0, 0, 0),
			AnchorPoint = global.vec2(0, 0.5),
			Name = "accent",
			Position = global.dim2(0, -10, 0.5, 1),
			Size = global.dim2(0, 2, 1, 18),
			ZIndex = 2,
			BorderSizePixel = 0,
			BackgroundColor3 = library.accent,
			BackgroundTransparency = info.active and 0 or 1
		})

		objects ['page'] = self.objects ['pages']:create("Frame", {
			BackgroundTransparency = 1,
			Name = "page",
			BorderColor3 = global.rgb(0, 0, 0),
			Size = global.dim2(1, 0, 1, 0),
			BorderSizePixel = 0,
			BackgroundColor3 = global.rgb(18, 18, 18),
			Visible = info.active
		})

		objects ['subbuttons'] = objects ['page']:create("Frame", {
			Visible = false,
			BackgroundTransparency = 1,
			Name = "subbuttons",
			BorderColor3 = global.rgb(0, 0, 0),
			Size = global.dim2(1, 0, 0, 19),
			BorderSizePixel = 0,
			BackgroundColor3 = global.rgb(255, 255, 255)
		})

		objects ['list'] = objects ['subbuttons']:create("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Name = "list",
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
			Padding = global.dim(0, 1),
			SortOrder = Enum.SortOrder.LayoutOrder
		})

		objects ['content'] = objects ['page']:create("Frame", {
			BackgroundTransparency = 1,
			Name = "content",
			BorderColor3 = global.rgb(0, 0, 0),
			Size = global.dim2(1, 0, 1, 0),
			BorderSizePixel = 0,
			BackgroundColor3 = global.rgb(255, 255, 255),
			LayoutOrder = 1,
		})

		objects ['flex'] = objects ['content']:create("UIFlexItem", {
			Name = "flex",
			FlexMode = Enum.UIFlexMode.Fill
		})

		objects ['safezone'] = objects ['content']:create("UIPadding", {
			PaddingTop = global.dim(0, 3),
			Name = "safezone",
			PaddingBottom = global.dim(0, 3),
			PaddingRight = global.dim(0, 3),
			PaddingLeft = global.dim(0, 3)
		})

		objects ['list'] = objects ['page']:create("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Name = "list",
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
			Padding = global.dim(0, 6)
		})

		info.objects = objects

		info.instances.page = function()
			local objects = {}

			objects ['holder'] = info.objects ['content']:create("Frame", {
				BackgroundTransparency = 1,
				Name = "holder",
				BorderColor3 = global.rgb(0, 0, 0),
				Size = global.dim2(1, 0, 1, 0),
				BorderSizePixel = 0,
				BackgroundColor3 = global.rgb(255, 255, 255)
			})

			objects ['flex'] = objects ['holder']:create("UIFlexItem", {
				Name = "flex",
				FlexMode = Enum.UIFlexMode.Fill
			})

			objects ['list'] = objects ['holder']:create("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				Name = "list",
				HorizontalFlex = Enum.UIFlexAlignment.Fill,
				Padding = global.dim(0, 5),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalFlex = Enum.UIFlexAlignment.Fill
			})

			objects ['safezone'] = objects ['holder']:create("UIPadding", {
				PaddingBottom = global.dim(0, 1),
				PaddingTop = global.dim(0, 1),
				Name = "safezone"
			})

			return objects
		end
	end

	info.functions.hover = function(bool)
		if info.hovered == bool then return end
		info.hovered = global.declare(not info.hovered, bool)

		objects ['disable']:tween{duration = 0.1, goal = {BackgroundColor3 = info.hovered and global.rgb(20, 20, 20) or global.rgb(15, 15, 15)}}
	end

	info.functions.active = function(bool)
		if bool == info.active then return end

		info.active = global.declare(not info.active, bool)

		objects ['page'].Visible = info.active

		objects ['button']:tween{duration = 0.1, goal = {BackgroundTransparency = info.active and 0 or 1}}
		objects ['accent']:tween{duration = 0.1, goal = {BackgroundTransparency = info.active and 0 or 1}}
	end

	info.functions.default = function()
		for _, page in self.pages do
			page:set("active", page == info)
		end
	end

	objects ['holder'] = info.instances.page().holder

	objects ['button']:connect("InputBegan", function(input)
		if input.UserInputType.Name ~= "MouseButton1" then return end

		info:set("default")
	end)

	objects ['button']:connect("MouseEnter", function()
		if info.hovered then return end

		info:set("hover", true)
	end)

	objects ['button']:connect("MouseLeave", function()
		if not info.hovered then return end

		info:set("hover", false)
	end)

	global.insert(self.pages, info)
	return info
end

-- Page > Subpage
library.subpage = function(self, info)
	info = object.lowercase(info or {}, {oriented = true})

	info.title = info.title or "subpage"

	info.active = self.subpages == nil
	info.hovered = false
	info.functions = {}

	self.subpages = self.subpages or {}
	if self.objects ['holder'] then
		self.objects ['subbuttons'].Visible = true
		self.objects ['holder']:clean()
	end

	assert(self.objects ['subbuttons'])

	local objects = {} do
		objects ['subbutton'] = self.objects ['subbuttons']:create("TextButton", {
			FontFace = library.mainfont,
			TextColor3 = global.rgb(0, 0, 0),
			BorderColor3 = global.rgb(0, 0, 0),
			Text = "",
			Name = "subbutton",
			Size = global.dim2(0, 0, 1, 0),
			BorderSizePixel = 0,
			TextSize = 11,
			AutoButtonColor = false,
			BackgroundColor3 = global.rgb(25, 25, 25)
		})

		objects ['label'] = objects ['subbutton']:create("TextLabel", {
			FontFace = library.primaryfont,
			TextColor3 = global.rgb(200, 200, 200),
			BorderColor3 = global.rgb(0, 0, 0),
			Text = info.title,
			BackgroundTransparency = 1,
			Name = "label",
			Size = global.dim2(1, 0, 1, 0),
			BorderSizePixel = 0,
			TextSize = 11,
			BackgroundColor3 = global.rgb(255, 255, 255)
		})

		objects ['safezone'] = objects ['label']:create("UIPadding", {
			PaddingTop = global.dim(0, 8),
			Name = "safezone",
			PaddingBottom = global.dim(0, 10),
			PaddingRight = global.dim(0, 10),
			PaddingLeft = global.dim(0, 10)
		})

		objects ['fade'] = objects ['subbutton']:create("UIGradient", {
			Rotation = 90,
			Name = "fade",
			Color = global.rgbseq{global.rgbkey(0, global.rgb(255, 255, 255)), global.rgbkey(0.689, global.rgb(166, 166, 166)), global.rgbkey(1, global.rgb(150, 150, 150))}
		})

		objects ['border'] = objects ['subbutton']:create("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			LineJoinMode = Enum.LineJoinMode.Miter,
			Name = "border"
		})

		objects ['accent'] = objects ['subbutton']:create("Frame", {
			Name = "accent",
			Position = global.dim2(0, 0, 1, 0),
			BorderColor3 = global.rgb(0, 0, 0),
			Size = global.dim2(1, 0, 0, 1),
			BorderSizePixel = 0,
			BackgroundColor3 = library.accent,
			BackgroundTransparency = info.active and 0 or 1
		})

		objects ['holder'] = self.instances.page().holder
		objects ['holder'].Visible = info.active
		info.objects = objects
	end

	info.functions.hover = function(bool)
		if info.hovered == bool then return end

		info.hovered = global.declare(not info.hovered, bool)

		objects ['subbutton']:tween{duration = 0.1, goal = {BackgroundColor3 = info.hovered and global.rgb(35, 35, 35) or global.rgb(25, 25, 25)}}
	end

	info.functions.active = function(bool)
		if info.active == bool then return end

		info.active = global.declare(not info.active, bool)

		objects ['holder'].Visible = info.active
		objects ['accent']:tween{duration = 0.1, goal = {BackgroundTransparency = info.active and 0 or 1}}
	end

	info.functions.default = function()
		for _, page in self.subpages do
			page:set("active", page == info)
		end
	end

	objects ['subbutton']:connect("InputBegan", function(input)
		if input.UserInputType.Name ~= "MouseButton1" then return end

		info:set("default")
	end)

	objects ['subbutton']:connect("MouseEnter", function()
		if info.hovered then return end

		info:set("hover", true)
	end)

	objects ['subbutton']:connect("MouseLeave", function()
		if not info.hovered then return end

		info:set("hover", false)
	end)

	global.insert(self.subpages, info)
	return info
end

-- Page OR Subpage > Column
library.column = function(self, info)
	info = object.lowercase(info or {}, {oriented = true})

	info.sections = {}

	self.columns = self.columns or {}

	assert(self.objects ['holder'])

	local objects = {} do
		objects ['column'] = self.objects ['holder']:create("Frame", {
			BackgroundTransparency = 1,
			ClipsDescendants = true,
			BorderColor3 = global.rgb(0, 0, 0),
			Name = "column",
			BorderSizePixel = 0,
			BackgroundColor3 = global.rgb(255, 255, 255)
		})

		objects ['content'] = objects ['column']:create("ScrollingFrame", {
			Active = true,
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			BorderSizePixel = 0,
			CanvasSize = global.dim2(0, 0, 0, 0),
			ScrollBarImageColor3 = global.rgb(36, 36, 36),
			MidImage = "rbxassetid://3337834830",
			BorderColor3 = global.rgb(0, 0, 0),
			ScrollBarThickness = 2,
			VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
			BackgroundTransparency = 1,
			Name = "content",
			Size = global.dim2(1, 0, 1, 0),
			BottomImage = "rbxassetid://3337834830",
			TopImage = "rbxassetid://3337834830",
			BackgroundColor3 = global.rgb(255, 255, 255)
		})

		objects ['list'] = objects ['content']:create("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Name = "list",
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
			Padding = global.dim(0, 11)
		})

		objects ['safezone'] = objects ['content']:create("UIPadding", {
			PaddingTop = global.dim(0, 2),
			Name = "safezone",
			PaddingBottom = global.dim(0, 2),
			PaddingRight = global.dim(0, 3),
			PaddingLeft = global.dim(0, 3)
		})

		info.objects = objects
	end

	global.insert(self.columns, info)
	return info
end

-- Column > Section
library.section = function(self, info)
	info = object.lowercase(info or {}, {oriented = true})

	info.title = info.title or "Section"
	info.order = info.order or #self.sections + 1
	info.visible = global.declare(true, info.visible)

	info.elements = {}
	info.functions = {}

	assert(self.objects ['content'])

	local objects = {} do
		objects ['section'] = self.objects ['content']:create("Frame", {
			Name = "section",
			Size = global.dim2(1, 0, 0, 10),
			BorderColor3 = global.rgb(30, 30, 30),
			BorderSizePixel = 2,
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = info.order,
			BackgroundColor3 = global.rgb(18, 18, 18),
			Visible = info.visible
		})

		objects ['border'] = objects ['section']:create("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			LineJoinMode = Enum.LineJoinMode.Miter,
			Name = "border"
		})

		objects ['label'] = objects ['section']:create("TextLabel", {
			FontFace = library.primaryfont,
			TextColor3 = global.rgb(200, 200, 200),
			BorderColor3 = global.rgb(0, 0, 0),
			Text = info.title,
			BorderSizePixel = 0,
			Size = global.dim2(0, 0, 0, 5),
			Rotation = 0.0000000000001,
			Position = global.dim2(0, 12, 0, -5),
			Name = "label",
			TextXAlignment = Enum.TextXAlignment.Left,
			AutomaticSize = Enum.AutomaticSize.X,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextSize = 11,
			BackgroundColor3 = global.rgb(18, 18, 18)
		})

		objects ['safezone'] = objects ['label']:create("UIPadding", {
			PaddingTop = global.dim(0, 10),
			Name = "safezone",
			PaddingBottom = global.dim(0, 10),
			PaddingRight = global.dim(0, 1),
			PaddingLeft = global.dim(0, 1)
		})

		objects ['content'] = objects ['section']:create("Frame", {
			Name = "content",
			BackgroundTransparency = 1,
			Size = global.dim2(1, 0, 0, 10),
			BorderColor3 = global.rgb(30, 30, 30),
			BorderSizePixel = 2,
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = global.rgb(18, 18, 18)
		})

		objects ['safezone'] = objects ['content']:create("UIPadding", {
			PaddingTop = global.dim(0, 9),
			Name = "safezone",
			PaddingBottom = global.dim(0, 3),
			PaddingRight = global.dim(0, 12),
			PaddingLeft = global.dim(0, 9)
		})

		objects ['list'] = objects ['content']:create("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Name = "list",
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
			Padding = global.dim(0, 2)
		})

		info.objects = objects
	end

	info.functions.visible = function(bool)
		if info.visible == bool then return end

		info.visible = global.declare(not info.visible, bool)

		objects ['section'].Visible = info.visible
	end

	global.insert(self.sections, info)
	return info
end

-- Section > Toggle
library.toggle = function(self, info)
	info = object.lowercase(info or {}, {oriented = true})

	info.title = info.title or "Toggle"
	info.enabled = info.enabled or false
	info.order = info.order or #self.elements + 1
	info.flag = library.next(info.flag or "Toggle")
	info.pointer = info.pointer or info.flag
	info.config = global.declare(true, info.config)
	info.callback = info.callback or function() end
	info.visible = global.declare(true, info.visible)

	info.is = "toggle"

	info.keybinds = {}
	info.elements = {}
	info.connected = {}
	info.functions = {}

	info.listener = function(...)
		for _, func in info.connected do
			global.thread(func)(...)
		end
	end

	assert(self.objects ['content'])

	local objects = {} do
		objects ['element'] = self.objects ['content']:create("Frame", {
			BackgroundTransparency = 1,
			Name = "element",
			BorderColor3 = global.rgb(0, 0, 0),
			Size = global.dim2(0, 100, 0, 12),
			BorderSizePixel = 0,
			BackgroundColor3 = global.rgb(255, 255, 255),
			LayoutOrder = info.order,
			Visible = info.visible
		})

		objects ['accent'] = objects ['element']:create("Frame", {
			Name = "accent",
			BorderColor3 = global.rgb(0, 0, 0),
			Size = global.dim2(0, 8, 0, 8),
			BorderSizePixel = 0,
			BackgroundColor3 = library.accent,
			BackgroundTransparency = info.enabled and 0 or 1
		})

		objects ['border'] = objects ['accent']:create("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			LineJoinMode = Enum.LineJoinMode.Miter,
			Name = "border"
		})

		objects ['label'] = objects ['element']:create("TextLabel", {
			FontFace = library.primaryfont,
			TextColor3 = global.rgb(250, 250, 250),
			BorderColor3 = global.rgb(0, 0, 0),
			Text = info.title,
			Name = "label",
			Size = global.dim2(0, 0, 1, 0),
			Position = global.dim2(0, 14, 0, 0),
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			BorderSizePixel = 0,
			AutomaticSize = Enum.AutomaticSize.X,
			TextSize = 11,
			BackgroundColor3 = global.rgb(18, 18, 18),
			TextTransparency = info.enabled and 0 or 1
		})

		objects ['safezone'] = objects ['label']:create("UIPadding", {
			PaddingTop = global.dim(0, 5),
			Name = "safezone",
			PaddingBottom = global.dim(0, 10),
			PaddingRight = global.dim(0, 1),
			PaddingLeft = global.dim(0, 1)
		})

		objects ['inactive'] = objects ['element']:create("TextLabel", {
			FontFace = library.primaryfont,
			TextColor3 = global.rgb(200, 200, 200),
			BorderColor3 = global.rgb(0, 0, 0),
			Text = info.title,
			Name = "inactive",
			Size = global.dim2(0, 0, 1, 0),
			Position = global.dim2(0, 14, 0, 0),
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			BorderSizePixel = 0,
			AutomaticSize = Enum.AutomaticSize.X,
			TextSize = 11,
			BackgroundColor3 = global.rgb(18, 18, 18),
			TextTransparency = info.enabled and 1 or 0
		})

		objects ['safezone'] = objects ['inactive']:create("UIPadding", {
			PaddingTop = global.dim(0, 5),
			Name = "safezone",
			PaddingBottom = global.dim(0, 10),
			PaddingRight = global.dim(0, 1),
			PaddingLeft = global.dim(0, 1)
		})

		objects ['hitbox'] = objects ['element']:create("TextButton", {
			TextColor3 = global.rgb(0, 0, 0),
			BorderColor3 = global.rgb(0, 0, 0),
			Text = "",
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			Name = "hitbox",
			Size = global.dim2(1, 0, 1, 0),
			BorderSizePixel = 0,
			TextSize = 14,
			BackgroundColor3 = global.rgb(255, 255, 255)
		})

		objects ['container'] = objects ['element']:create("Frame", {
			BorderColor3 = global.rgb(0, 0, 0),
			AnchorPoint = global.vec2(1, 0),
			Name = "container",
			BackgroundTransparency = 1,
			Position = global.dim2(1, 0, 0, -1),
			Size = global.dim2(0, 0, 1, 0),
			BorderSizePixel = 0,
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundColor3 = global.rgb(255, 255, 255)
		})

		objects ['list'] = objects ['container']:create("UIListLayout", {
			VerticalAlignment = Enum.VerticalAlignment.Center,
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			Padding = global.dim(0, 10),
			Name = "list",
			SortOrder = Enum.SortOrder.LayoutOrder
		})

		info.objects = objects
	end

	info.functions.visible = function(bool)
		if info.visible == bool then return end

		info.visible = global.declare(not info.visible, bool)

		objects ['element'].Visible = info.visible
	end

	info.functions.key = global.thread(function()
		for _, keybind in info.keybinds do
			keybind:set("active")
		end
	end)

	info.functions.default = function(bool)
		info.enabled = global.declare(not info.enabled, bool)

		objects ['label']:tween{duration = 0.1, goal = {TextTransparency = info.enabled and 0 or 1}}
		objects ['inactive']:tween{duration = 0.1, goal = {TextTransparency = info.enabled and 1 or 0}}
		objects ['accent']:tween{duration = 0.1, goal = {BackgroundTransparency = info.enabled and 0 or 1}}

		global.valset(library.flags, info.flag, info.enabled)
		global.valset(library.pointers, info.pointer, info)

		global.thread(info.callback)(info.enabled)
		global.thread(info.listener)(info.enabled)

		info:set("key")
	end

	objects ['hitbox']:connect("InputBegan", function(input)
		if input.UserInputType.Name ~= "MouseButton1" then return end

		info:set("default")
	end)

	-- global.valset(library.configs, info.flag, info.config)
	global.valset(library.flags, info.flag, info.enabled)
	global.valset(library.pointers, info.pointer, info)

	global.insert(self.elements, info)

	return info
end

-- Section OR Toggle > Keybind
library.keybind = function(self, info)
	info = object.lowercase(info or {}, {oriented = true})

	info.ignore = info.ignore or false
	info.title = info.title or "Keybind"
	info.names = info.names or info.title
	info.order = info.order or #self.elements + 1
	info.callback = info.callback or function() end
	info.config = global.declare(true, info.config)
	info.visible = global.declare(true, info.visible)
	info.default = info.default or Enum.KeyCode.Unknown
	info.flag = library.next(info.flag or "Keybind")
	info.pointer = info.pointer or info.flag
	info.modes = info.modes or {"Always", "Hold", "Released", "Toggle"}
	info.mode = #info.modes > 0 and global.lower(info.mode or info.modes[1])

	info.is = "keybind"

	info.old = info.value
	info.str = library.bindstr[info.default.Name]
	info.activekeys = library.activekeys and library.activekeys.contents
	info.popuphovered = false
	info.hovered = false
	info.active = false
	info.opened = false
	info.binding = false
	info.connected = {}
	info.functions = {}
	info.parent = assert(self.objects ['content'] or self.objects ['container'])

	info.listener = function(...)
		for _, func in info.connected do
			global.thread(func)(...)
		end
	end

	local objects = {} do
		objects ['element'] = info.parent:create("Frame", {
			BackgroundTransparency = 1,
			Name = "element",
			BorderColor3 = global.rgb(0, 0, 0),
			Size = global.dim2(0, 100, 0, 12),
			BorderSizePixel = 0,
			BackgroundColor3 = global.rgb(255, 255, 255),
			LayoutOrder = info.order,
			Visible = info.visible
		})

		objects ['label'] = self.objects ['content'] and objects ['element']:create("TextLabel", {
			FontFace = library.primaryfont,
			TextColor3 = global.rgb(200, 200, 200),
			BorderColor3 = global.rgb(0, 0, 0),
			Text = info.title,
			Name = "label",
			Size = global.dim2(0, 0, 1, 0),
			Position = global.dim2(0, 14, 0, 0),
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			BorderSizePixel = 0,
			AutomaticSize = Enum.AutomaticSize.X,
			TextSize = 11,
			BackgroundColor3 = global.rgb(18, 18, 18)
		})

		objects ['safezone'] = self.objects ['content'] and objects ['label']:create("UIPadding", {
			PaddingTop = global.dim(0, 5),
			Name = "safezone",
			PaddingBottom = global.dim(0, 10),
			PaddingRight = global.dim(0, 1),
			PaddingLeft = global.dim(0, 1)
		})

		objects ['content'] = objects ['element']:create("Frame", {
			BorderColor3 = global.rgb(0, 0, 0),
			AnchorPoint = global.vec2(1, 0),
			Name = "content",
			BackgroundTransparency = 1,
			Position = global.dim2(1, 0, 0, -1),
			Size = global.dim2(0, 0, 1, 0),
			BorderSizePixel = 0,
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundColor3 = global.rgb(255, 255, 255)
		})

		objects ['keybind'] = objects ['content']:create("TextButton", {
			FontFace = library.secondaryfont,
			AutomaticSize = Enum.AutomaticSize.X,
			TextColor3 = global.rgb(80, 80, 80),
			BorderColor3 = global.rgb(0, 0, 0),
			Text = info.str,
			Name = "keybind",
			Size = global.dim2(0, 15, 0, 5),
			BorderSizePixel = 2,
			TextSize = 9,
			AutoButtonColor = false,
			BackgroundColor3 = global.rgb(18, 18, 18)
		})

		objects ['border'] = objects ['keybind']:create("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			LineJoinMode = Enum.LineJoinMode.Miter,
			Name = "border",
			Color = global.rgb(30, 30, 30)
		})

		objects ['safezone'] = objects ['keybind']:create("UIPadding", {
			PaddingTop = global.dim(0, 1),
			PaddingLeft = global.dim(0, 1),
			Name = "safezone"
		})

		objects ['list'] = objects ['content']:create("UIListLayout", {
			VerticalAlignment = Enum.VerticalAlignment.Center,
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			Padding = global.dim(0, 10),
			Name = "list",
			SortOrder = Enum.SortOrder.LayoutOrder
		})

		objects ['modes'] = objects ['element']:create("Frame", {
			BorderColor3 = global.rgb(0, 0, 0),
			Rotation = 0.0000000000001,
			Name = "modes",
			Position = global.dim2(1, -16, 0, 12),
			Size = global.dim2(0, 100, 1, 0),
			BorderSizePixel = 0,
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundColor3 = global.rgb(18, 18, 18),
			Visible = info.opened,
			ZIndex = 15
		})

		objects ['list'] = objects ['modes']:create("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			Name = "list"
		})

		objects ['border'] = objects ['modes']:create("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			LineJoinMode = Enum.LineJoinMode.Miter,
			Name = "border"
		})

		objects ['safezone'] = objects ['modes']:create("UIPadding", {
			Name = "safezone",
			PaddingBottom = global.dim(0, 3),
			PaddingRight = global.dim(0, 5),
			PaddingLeft = global.dim(0, 5)
		})

		if #info.modes > 0 then
			for _, mode in info.modes do
				objects [global.lower(mode)] = objects ['modes']:create("TextButton", {
					FontFace = library.primaryfont,
					TextColor3 = global.rgb(200, 200, 200),
					TextTransparency = global.lower(mode) == global.lower(info.mode) and 1 or 0,
					Text = mode,
					Name = "button",
					AutoButtonColor = false,
					BorderColor3 = global.rgb(0, 0, 0),
					Size = global.dim2(1, 0, 0, 15),
					BackgroundTransparency = 1,
					TextXAlignment = Enum.TextXAlignment.Left,
					BorderSizePixel = 0,
					ZIndex = 17,
					TextSize = 11,
				})

				objects [global.lower(mode) .. '_accent'] = objects [global.lower(mode)]:create("TextLabel", {
					FontFace = library.boldfont,
					TextColor3 = global.rgb(255, 139, 62),
					BorderColor3 = global.rgb(0, 0, 0),
					TextTransparency = global.lower(mode) == global.lower(info.mode) and 0 or 1,
					Text = mode,
					Name = "accent",
					AutomaticSize = Enum.AutomaticSize.X,
					BackgroundTransparency = 1,
					Size = global.dim2(0, 0, 1, 0),
					BorderSizePixel = 0,
					ZIndex = 17,
					TextSize = 11,
				})

				objects [global.lower(mode)]:connect("InputBegan", function(input)
					if input.UserInputType.Name ~= "MouseButton1" then return end

					info:set("mode", mode)
				end)
			end
		end

		global.insert(library.popups, {input = objects ['keybind'], target = objects ['modes']})
		info.objects = objects
	end

	info.functions.visible = function(bool)
		if info.visible == bool then return end

		info.visible = global.declare(not info.visible, bool)

		objects ['section'].Visible = info.visible
	end

	info.functions.hover = function(bool)
		if info.hovered == bool then return end
		info.hovered = global.declare(not info.hovered, bool)

		objects ['keybind']:tween{duration = 0.1, goal = {BackgroundColor3 = info.hovered and global.rgb(28, 28, 28) or global.rgb(18, 18, 18)}}
	end

	info.functions.popopen = #info.modes > 0 and function()
		if info.popuphovered or info.hovered or not info.opened then return end

		info:set("open", false)
	end

	info.functions.open = #info.modes > 0 and function(bool)
		info.opened = global.declare(not info.opened, bool)

		objects ['modes'].Visible = info.opened
	end

	info.functions.mode = #info.modes > 0 and function(str)
		info.mode = str or info.mode

		if global.tfind({"released", "always"}, global.lower(info.mode)) then
			info:set("active", true)
		end

		if global.lower(info.mode) == "hold" then
			info:set("active", false)
		end

		if global.lower(info.mode) == "toggle" then
			info:set("active", info.active)
		end

		for _, mode in info.modes do
			local bool = global.lower(info.mode) == global.lower(mode)

			objects [global.lower(mode) .. "_accent"]:tween{duration = 0.1, goal = {TextTransparency = bool and 0 or 1}}
			objects [global.lower(mode)]:tween{duration = 0.1, goal = {TextTransparency = bool and 1 or 0}}
		end
	end

	info.functions.bind = function(bool)
		info.binding = bool

		objects ['keybind'].Text = info.binding and "..." or info.str
	end

	info.functions.key = function(str)
		str = global.is(str) == "string" and (global.search(library.bindstr, str)) or str or info.default
		str = global.is(str) == "string" and (Enum.KeyCode[str] or Enum.UserInputType[str]) or str or info.default

		str = global.tfind({"Return", "Backspace"}, str.Name) and Enum.KeyCode.Unknown or str
		
		if info.old == str then return end

		info.default = str
		info.old = info.default
		info.str = library.bindstr[info.default.Name] or info.default.Name

		info:set("active", info.active)

		objects ['keybind'].Text = info.str
	end

	info.functions.active = function(bool)
		info.active = global.declare(not info.active, bool)

		global.valset(library.flags, info.flag, {active = info.active, key = info.default, mode = info.mode})
		global.valset(library.pointers, info.pointer, info)

		global.thread(info.callback)(library.flags[info.flag])
		global.thread(info.listener)(library.flags[info.flag])

		if info.ignore then return end

		info.activekeys[info.flag] = {
			title = `{info.names} [{info.str}] [{info.mode}]`,
			visible = global.declare(info.active, info.active and self.enabled) and global.lower(info.mode) ~= "always", 
			key = info.flag
		}
	end

	info:set("active", info.active)

	-- global.valset(library.configs, info.flag, info.config)
	global.valset(library.flags, info.flag, info.active)
	global.valset(library.pointers, info.pointer, info)

	global.insert(self.elements, info)
	if self.keybinds then
		global.insert(self.keybinds, info)
	end

	objects ['keybind']:connect("InputEnded", function(input)
		if input.UserInputType.Name ~= "MouseButton1" then return end

		info:set("bind", true)
	end)

	objects ['keybind']:connect("MouseEnter", function()
		if info.hovered then return end

		info:set("hover", true)
	end)

	objects ['keybind']:connect("MouseLeave", function()
		if not info.hovered then return end

		info:set("hover", false)
	end)

	objects ['modes']:connect("MouseEnter", function()
		if info.popuphovered then return end

		info.popuphovered = true
	end)

	objects ['modes']:connect("MouseLeave", function()
		if not info.popuphovered then return end

		info.popuphovered = false
	end)

	object:connection(global.userinput.InputBegan, function(input)
		if #info.modes > 0 then
			global.call(info.functions.popopen)
		end

		if not global.tfind({"MouseMovement"}, input.UserInputType.Name) and info.binding then 
			info:set("key", input.UserInputType.Name == "Keyboard" and input.KeyCode or input.UserInputType)
			info:set("bind", false)
		end

		if info.default.Name == "Unknown" or #info.modes < 1 or not global.tfind({input.UserInputType, input.KeyCode}, info.default) then return end

		if global.lower(info.mode) == "toggle" then 
			return info:set("active")
		end

		if global.lower(info.mode) == "hold" then 
			return info:set("active", true)
		end

		if global.lower(info.mode) == "released" then 
			info:set("active", false)
		end
	end)

	if #info.modes < 1 then return info end

	objects ['keybind']:connect("InputBegan", function(input)
		if input.UserInputType.Name ~= "MouseButton2" then return end

		info:set("open")
	end)

	object:connection(global.userinput.InputEnded, function(input)
		if info.default.Name == "Unknown" or not global.tfind({input.UserInputType, input.KeyCode}, info.default) then return end

		if global.lower(info.mode) == "hold" then 
			info:set("active", false)
		end

		if global.lower(info.mode) == "released" then 
			info:set("active", true)
		end
	end)

	return info
end

-- Section OR Toggle > Colorpicker
library.colorpicker = function(self, info) 
	info = object.lowercase(info or {}, {oriented = true})

	info.alpha = info.alpha
	info.title = info.title or "Colorpicker"
	info.order = info.order or #self.elements + 1
	info.config = global.declare(true, info.config)
	info.callback = info.callback or function() end
	info.visible = global.declare(true, info.visible)
	info.color = info.color or global.rgb(255, 255, 255)
	info.flag = library.next(info.flag or "Colorpicker")
	info.pointer = info.pointer or info.flag

	info.is = "colorpicker"

	info.popuphovered = false
	info.opened = false
	info.old = global.gethsv(info.color)
	info.old.alpha = info.alpha or 1
	info.old.color = info.color
	info.picking = {hue = false, satval = false, alpha = false}
	info.connected = {}
	info.functions = {}
	info.parent = assert(self.objects ['content'] or self.objects ['container'])

	info.listener = function(...)
		for _, func in info.connected do
			global.thread(func)(...)
		end
	end

	local objects = {} do
		objects ['element'] = info.parent:create("Frame", {
			BackgroundTransparency = 1,
			Name = "element",
			BorderColor3 = global.rgb(0, 0, 0),
			Size = global.dim2(0, 100, 0, 12),
			BorderSizePixel = 0,
			LayoutOrder = info.order,
			Visible = info.visible,
			BackgroundColor3 = global.rgb(255, 255, 255)
		})

		objects ['label'] = self.objects ['content'] and objects ['element']:create("TextLabel", {
			FontFace = library.primaryfont,
			TextColor3 = global.rgb(200, 200, 200),
			BorderColor3 = global.rgb(0, 0, 0),
			Text = info.title,
			Name = "label",
			Size = global.dim2(0, 0, 1, 0),
			Position = global.dim2(0, 14, 0, 0),
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			BorderSizePixel = 0,
			AutomaticSize = Enum.AutomaticSize.X,
			TextSize = 11,
			BackgroundColor3 = global.rgb(18, 18, 18)
		})

		objects ['safezone'] = self.objects ['content'] and objects ['label']:create("UIPadding", {
			PaddingTop = global.dim(0, 5),
			Name = "safezone",
			PaddingBottom = global.dim(0, 10),
			PaddingRight = global.dim(0, 1),
			PaddingLeft = global.dim(0, 1)
		})

		objects ['content'] = objects ['element']:create("Frame", {
			BorderColor3 = global.rgb(0, 0, 0),
			AnchorPoint = global.vec2(1, 0),
			Name = "content",
			BackgroundTransparency = 1,
			Position = global.dim2(1, 0, 0, -1),
			Size = global.dim2(0, 0, 1, 0),
			BorderSizePixel = 0,
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundColor3 = global.rgb(255, 255, 255)
		})

		objects ['list'] = objects ['content']:create("UIListLayout", {
			VerticalAlignment = Enum.VerticalAlignment.Center,
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			Padding = global.dim(0, 10),
			Name = "list",
			SortOrder = Enum.SortOrder.LayoutOrder
		})

		objects ['colorpicker'] = objects ['content']:create("TextButton", {
			FontFace = library.secondaryfont,
			TextColor3 = global.rgb(80, 80, 80),
			BorderColor3 = global.rgb(0, 0, 0),
			Text = "",
			Name = "colorpicker",
			Size = global.dim2(0, 15, 0, 5),
			BorderSizePixel = 2,
			TextSize = 9,
			BackgroundColor3 = global.rgb(18, 18, 18)
		})

		objects ['grid'] = objects ['colorpicker']:create("ImageLabel", {
			ScaleType = Enum.ScaleType.Tile,
			BorderColor3 = global.rgb(0, 0, 0),
			Name = "asset",
			Image = "rbxassetid://18274452449",
			BackgroundTransparency = 1,
			TileSize = global.dim2(0, 5, 0, 5),
			Position = global.dim2(0, -1, 0, -1),
			Size = global.dim2(1, 2, 1, 2),
			BorderSizePixel = 0,
			BackgroundColor3 = global.rgb(255, 255, 255)
		})

		objects ['fade'] = objects ['grid']:create("UIGradient", {
			Rotation = 90,
			Name = "fade",
			Color = global.rgbseq{global.rgbkey(0, global.rgb(255, 255, 255)), global.rgbkey(0.725, global.rgb(167, 167, 167)), global.rgbkey(1, global.rgb(150, 150, 150))}
		})

		objects ['color'] = objects ['colorpicker']:create("Frame", {
			Name = "color",
			Position = global.dim2(0, -1, 0, -1),
			BorderColor3 = global.rgb(0, 0, 0),
			Size = global.dim2(1, 2, 1, 2),
			BackgroundTransparency = 1 - info.old.alpha,
			BorderSizePixel = 0,
			BackgroundColor3 = info.color
		})

		objects ['fade'] = objects ['color']:create("UIGradient", {
			Rotation = 90,
			Name = "fade",
			Color = global.rgbseq{global.rgbkey(0, global.rgb(255, 255, 255)), global.rgbkey(0.725, global.rgb(167, 167, 167)), global.rgbkey(1, global.rgb(150, 150, 150))}
		})

		objects ['picker'] = objects ['colorpicker']:create("Frame", {
			BorderColor3 = global.rgb(0, 0, 0),
			Rotation = 0.0000000000001,
			Name = "picker",
			Position = global.dim2(1, 5, 0, 0),
			Size = global.dim2(0, 150, 0, 150),
			ZIndex = 20,
			Visible = info.opened,
			BorderSizePixel = 0,
			BackgroundColor3 = global.rgb(18, 18, 18)
		})

		objects ['border'] = objects ['picker']:create("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			LineJoinMode = Enum.LineJoinMode.Miter,
			Name = "border"
		})

		objects ['x'] = objects ['picker']:create("Frame", {
			Name = "x",
			BorderColor3 = global.rgb(0, 0, 0),
			Size = global.dim2(1, 0, 0, 0),
			BorderSizePixel = 0,
			BackgroundColor3 = global.rgb(255, 255, 255)
		})

		objects ['list'] = objects ['x']:create("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Wraps = true,
			Name = "list",
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
			Padding = global.dim(0, 3),
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalFlex = Enum.UIFlexAlignment.Fill
		})

		objects ['satval'] = objects ['x']:create("TextButton", {
			Name = "satval",
			Size = global.dim2(0, 0, 1, -20),
			BorderColor3 = global.rgb(0, 0, 0),
			AutoButtonColor = false,
			Text = "",
			ZIndex = 20,
			BorderSizePixel = 0,
			BackgroundColor3 = global.hsv(info.old.hue, 1, 1)
		})

		objects ['asset'] = objects ['satval']:create("ImageLabel", {
			BorderColor3 = global.rgb(0, 0, 0),
			Image = "rbxassetid://134927516942491",
			BackgroundTransparency = 1,
			Name = "asset",
			Size = global.dim2(1, 0, 1, 0),
			ZIndex = 20,
			BorderSizePixel = 0,
			BackgroundColor3 = global.rgb(255, 255, 255)
		})

		objects ['asset'] = objects ['satval']:create("ImageLabel", {
			BorderColor3 = global.rgb(0, 0, 0),
			Image = "rbxassetid://96192970265863",
			BackgroundTransparency = 1,
			Name = "asset",
			Size = global.dim2(1, 0, 1, 0),
			ZIndex = 20,
			BorderSizePixel = 0,
			BackgroundColor3 = global.rgb(255, 255, 255)
		})

		objects ['border'] = objects ['satval']:create("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			LineJoinMode = Enum.LineJoinMode.Miter,
			Name = "border"
		})

		objects ['satval_pointer'] = objects ['satval']:create("Frame", {
			AnchorPoint = global.vec2(0.5, 0.5),
			Name = "pointer",
			Size = global.dim2(0, 2, 0, 2),
			BorderColor3 = global.rgb(0, 0, 0),
			ZIndex = 20,
			BorderSizePixel = 0,
			Position = global.dim2(info.old.sat, 0, 1 - info.old.val, 0),
			BackgroundColor3 = global.rgb(255, 255, 255)
		})

		objects ['border'] = objects ['satval_pointer']:create("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Name = "border"
		})

		objects ['hue'] = objects ['x']:create("TextButton", {
			Name = "hue",
			Size = global.dim2(0, 10, 1, -20),
			BorderColor3 = global.rgb(0, 0, 0),
			ZIndex = 20,
			AutoButtonColor = false,
			Text = "",
			BorderSizePixel = 0,
			BackgroundColor3 = global.rgb(255, 255, 255)
		})

		objects ['flex'] = objects ['hue']:create("UIFlexItem", {
			Name = "flex"
		})

		objects ['asset'] = objects ['hue']:create("ImageLabel", {
			BorderColor3 = global.rgb(0, 0, 0),
			Image = "rbxassetid://133334110106525",
			BackgroundTransparency = 1,
			Name = "asset",
			Size = global.dim2(1, 0, 1, 0),
			ZIndex = 20,
			BorderSizePixel = 0,
			BackgroundColor3 = global.rgb(255, 255, 255)
		})

		objects ['border'] = objects ['hue']:create("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			LineJoinMode = Enum.LineJoinMode.Miter,
			Name = "border"
		})

		objects ['hue_pointer'] = objects ['hue']:create("Frame", {
			Name = "pointer",
			Size = global.dim2(1, 0, 0, 1),
			BorderColor3 = global.rgb(0, 0, 0),
			ZIndex = 20,
			BorderSizePixel = 0,
			Position = global.dim2(0, 0, info.old.hue, 0),
			BackgroundColor3 = global.rgb(255, 255, 255)
		})

		objects ['border'] = objects ['hue_pointer']:create("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Name = "border"
		})

		objects ['y'] = objects ['picker']:create("Frame", {
			Name = "y",
			Size = global.dim2(0, 0, 0, 0),
			BorderColor3 = global.rgb(0, 0, 0),
			BorderSizePixel = 0,
			AutomaticSize = Enum.AutomaticSize.Y,
			Visible = info.alpha ~= nil,
			BackgroundColor3 = global.rgb(255, 255, 255)
		})

		objects ['flex'] = objects ['y']:create("UIFlexItem", {
			Name = "flex"
		})

		objects ['alpha'] = objects ['y']:create("Frame", {
			Name = "alpha",
			Size = global.dim2(0, 0, 0, 10),
			BorderColor3 = global.rgb(0, 0, 0),
			ZIndex = 20,
			AutoButtonColor = false,
			Text = "",
			BorderSizePixel = 0,
			BackgroundColor3 = global.rgb(255, 255, 255)
		})

		objects ['asset'] = objects ['alpha']:create("ImageLabel", {
			ScaleType = Enum.ScaleType.Tile,
			BorderColor3 = global.rgb(0, 0, 0),
			Name = "asset",
			Image = "rbxassetid://18274452449",
			BackgroundTransparency = 1,
			TileSize = global.dim2(0, 5, 0, 5),
			Size = global.dim2(1, 0, 1, 0),
			ZIndex = 20,
			BorderSizePixel = 0,
			BackgroundColor3 = global.rgb(255, 255, 255)
		})

		objects ['border'] = objects ['alpha']:create("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			LineJoinMode = Enum.LineJoinMode.Miter,
			Name = "border"
		})

		objects ['gradient'] = objects ['alpha']:create("Frame", {
			Name = "gradient",
			Size = global.dim2(1, 0, 1, 0),
			BorderColor3 = global.rgb(0, 0, 0),
			ZIndex = 20,
			BorderSizePixel = 0,
			BackgroundColor3 = global.rgb(255, 255, 255)
		})

		objects ['fade'] = objects ['gradient']:create("UIGradient", {
			Transparency = global.numseq{global.numkey(0, 1), global.numkey(1, 0)},
			Name = "fade"
		})

		objects ['alpha_pointer'] = objects ['alpha']:create("Frame", {
			Name = "pointer",
			Size = global.dim2(0, 1, 1, 0),
			BorderColor3 = global.rgb(0, 0, 0),
			ZIndex = 20,
			BorderSizePixel = 0,
			BackgroundColor3 = global.rgb(255, 255, 255),
			Position = global.dim2(info.old.alpha, 0, 0, 0)
		})

		objects ['border'] = objects ['alpha_pointer']:create("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Name = "border"
		})

		objects ['list'] = objects ['y']:create("UIListLayout", {
			Wraps = true,
			Name = "list",
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
			Padding = global.dim(0, 3),
			SortOrder = Enum.SortOrder.LayoutOrder
		})

		objects ['safezone'] = objects ['y']:create("UIPadding", {
			Name = "safezone",
			PaddingRight = global.dim(0, 12),
			PaddingLeft = global.dim(0, 1)
		})

		objects ['list'] = objects ['picker']:create("UIListLayout", {
			Wraps = true,
			Name = "list",
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
			Padding = global.dim(0, 3),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalFlex = Enum.UIFlexAlignment.Fill
		})

		objects ['safezone'] = objects ['picker']:create("UIPadding", {
			PaddingTop = global.dim(0, 3),
			Name = "safezone",
			PaddingBottom = global.dim(0, 3),
			PaddingRight = global.dim(0, 3),
			PaddingLeft = global.dim(0, 3)
		})

		objects ['ignore'] = objects ['picker']:create("Folder", {
			Name = "ignore"
		})

		objects ['resizexy'] = objects ['ignore']:create("TextButton", {
			TextColor3 = global.rgb(0, 0, 0),
			BorderColor3 = global.rgb(0, 0, 0),
			Text = "",
			Name = "resizexy",
			BackgroundTransparency = 1,
			Position = global.dim2(1, -5, 1, -5),
			Size = global.dim2(0, 10, 0, 10),
			BorderSizePixel = 0,
			TextSize = 14,
			BackgroundColor3 = global.rgb(255, 255, 255)
		})

		global.insert(library.popups, {input = objects ['colorpicker'], target = objects ['picker']})
		info.objects = objects
	end

	objects ['resizexy']:resize(objects ['picker'], global.vec2(100, 100), global.vec2(5000, 5000))

	info.functions.visible = function(bool)
		if info.visible == bool then return end

		info.visible = global.declare(not info.visible, bool)

		objects ['section'].Visible = info.visible
	end

	info.functions.popopen = function()
		if info.popuphovered or info.hovered or not info.opened then return end

		info:set("open", false)
	end

	info.functions.open = function(bool)
		info.opened = global.declare(not info.opened, bool)

		objects ['picker'].Visible = info.opened
	end

	info.functions.hue = function(hue)
		local hsv, input

		if global.isa(hue) ~= "number" then
			input = hue

			hue = global.clamp((input.Position.Y - objects ['hue'].AbsolutePosition.Y) / objects ['hue'].AbsoluteSize.Y, 0, 1)
		end

		hsv = global.hsv(hue, info.old.sat, info.old.val)

		if hue == info.old.hue then return end

		info.old.hue = hue

		info:set("color", hsv, info.old.alpha, true)
	end

	info.functions.satval = function(sat, val)
		local hsv, input

		if not global.tfind({global.isa(sat), global.isa(val)}, "number") then
			input = sat

			sat = global.clamp((input.Position.X - objects ['satval'].AbsolutePosition.X) / objects ['satval'].AbsoluteSize.X, 0, 1)
			val = 1 - global.clamp((input.Position.Y - objects ['satval'].AbsolutePosition.Y) / objects ['satval'].AbsoluteSize.Y, 0, 1)
		end

		hsv = global.hsv(info.old.hue, sat, val)

		if hsv == info.old.color then return end

		info.old.sat = sat
		info.old.val = val

		info:set("color", hsv, info.old.alpha, true)
	end

	info.functions.alpha = function(alpha)
		local hsv, input

		if global.is(alpha) ~= "number" then
			input = alpha

			alpha = global.clamp((input.Position.X - objects ['alpha'].AbsolutePosition.X) / objects ['alpha'].AbsoluteSize.X, 0, 1)
		end

		hsv = global.hsv(info.old.hue, info.old.sat, info.old.val)

		if alpha == info.old.alpha then return end

		info.old.alpha = alpha

		info:set("color", hsv, alpha, true)
	end

	info.functions.color = function(color, alpha, input)
		if color == info.old.color and info.old.alpha ~= alpha then return end

		info.color = color
		info.alpha = alpha or info.old.alpha

		info.old = input and info.old or global.gethsv(color)
		info.old.color = input and info.old.color or info.color
		info.old.alpha = input and info.old.alpha or info.alpha

		global.valset(library.flags, info.flag, info.alpha and {info.color, info.alpha} or info.color)
		global.valset(library.pointers, info.pointer, info)

		global.thread(info.callback)(info.color, info.alpha)
		global.thread(info.listener)(info.color, info.alpha)

		objects ['color'].BackgroundColor3 = info.color
		objects ['color'].BackgroundTransparency = 1 - info.old.alpha
		objects ['satval'].BackgroundColor3 = global.hsv(info.old.hue, 1, 1)

		objects ['hue_pointer']:tween{duration = 0.1, goal = {Position = global.dim2(0, 0, info.old.hue, 0)}}
		objects ['alpha_pointer']:tween{duration = 0.1, goal = {Position = global.dim2(info.old.alpha, 0, 0, 0)}}
		objects ['satval_pointer']:tween{duration = 0.1, goal = {Position = global.dim2(info.old.sat, 0, 1 - info.old.val, 0)}}
	end

	for _, hsv in {"hue", "satval", "alpha"} do
		objects [hsv]:connect("InputBegan", function(input)
			if input.UserInputType.Name ~= "MouseButton1" then return end

			info.picking[hsv] = true
			info:set(hsv, input)
		end)

		objects [hsv]:connect("InputEnded", function(input)
			if input.UserInputType.Name ~= "MouseButton1" then return end

			info.picking[hsv] = false
		end)
	end

	objects ['colorpicker']:connect("InputBegan", function(input)
		if input.UserInputType.Name ~= "MouseButton1" then return end

		info:set("open")
	end)

	objects ['colorpicker']:connect("MouseEnter", function()
		if info.hovered then return end

		info.hovered = true
	end)

	objects ['colorpicker']:connect("MouseLeave", function()
		if not info.hovered then return end

		info.hovered = false
	end)

	objects ['picker']:connect("MouseEnter", function()
		if info.popuphovered then return end

		info.popuphovered = true
	end)

	objects ['picker']:connect("MouseLeave", function()
		if not info.popuphovered then return end

		info.popuphovered = false
	end)

	object:connection(global.userinput.InputBegan, info.functions.popopen)

	object:connection(global.userinput.InputChanged, function(input)
		if input.UserInputType.Name ~= "MouseMovement" or not info.opened or not info.visible then return end

		if info.picking.hue then
			info:set("hue", input)
		end

		if info.picking.satval then
			info:set("satval", input)
		end

		if info.picking.alpha then
			info:set("alpha", input)
		end
	end)

	-- global.valset(library.configs, info.flag, info.config)
	global.valset(library.flags, info.flag, info.alpha and {info.color, info.alpha} or info.color)
	global.valset(library.pointers, info.pointer, info)

	global.insert(self.elements, info)

	return info
end

-- Section > Slider
library.slider = function(self, info)
	info = object.lowercase(info or {}, {oriented = true})

	info.value = info.value or 50
	info.suffix = info.suffix or ""
	info.title = info.title or "Toggle"
	info.min = info.min or info.minimum or 0
	info.max = info.max or info.maximum or 100
	info.float = info.float or info.round or 1
	info.order = info.order or #self.elements + 1
	info.callback = info.callback or function() end
	info.flag = library.next(info.flag or "Slider")
	info.pointer = info.pointer or info.flag
	info.config = global.declare(true, info.config)
	info.visible = global.declare(true, info.visible)

	info.is = "slider"

	info.old = info.value
	info.active = false
	info.hovered = false
	info.connected = {}
	info.functions = {}

	info.listener = function(...)
		for _, func in info.connected do
			global.thread(func)(...)
		end
	end

	assert(self.objects ['content'])

	local objects = {} do
		objects ['element'] = self.objects ['content']:create("Frame", {
			BackgroundTransparency = 1,
			Name = "element",
			BorderColor3 = global.rgb(0, 0, 0),
			Size = global.dim2(0, 100, 0, 25),
			BorderSizePixel = 0,
			BackgroundColor3 = global.rgb(255, 255, 255),
			LayoutOrder = info.order,
			Visible = info.visible
		})

		objects ['label'] = objects ['element']:create("TextLabel", {
			FontFace = library.primaryfont,
			TextColor3 = global.rgb(200, 200, 200),
			BorderColor3 = global.rgb(0, 0, 0),
			Text = info.title,
			Name = "label",
			AutomaticSize = Enum.AutomaticSize.X,
			Size = global.dim2(0, 0, 0, 17),
			Position = global.dim2(0, 14, 0, 0),
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			BorderSizePixel = 0,
			ZIndex = 2,
			TextSize = 11,
			BackgroundColor3 = global.rgb(18, 18, 18)
		})

		objects ['safezone'] = objects ['label']:create("UIPadding", {
			PaddingTop = global.dim(0, 4),
			Name = "safezone",
			PaddingBottom = global.dim(0, 10),
			PaddingRight = global.dim(0, 1),
			PaddingLeft = global.dim(0, 1)
		})

		objects ['slider'] = objects ['element']:create("Frame", {
			Name = "slider",
			Position = global.dim2(0, 16, 0, 15),
			BorderColor3 = global.rgb(0, 0, 0),
			Size = global.dim2(1, -35, 0, 6),
			BorderSizePixel = 0,
			BackgroundColor3 = global.rgb(25, 25, 25)
		})

		objects ['border'] = objects ['slider']:create("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			LineJoinMode = Enum.LineJoinMode.Miter,
			Name = "border"
		})

		objects ['accent'] = objects ['slider']:create("Frame", {
			Name = "accent",
			BorderColor3 = global.rgb(0, 0, 0),
			Size = global.dim2((info.value - info.min) / (info.max - info.min), 0, 1, 0),
			BorderSizePixel = 0,
			BackgroundColor3 = library.accent
		})

		objects ['value'] = objects ['element']:create("TextBox", {
			FontFace = library.primaryfont,
			AnchorPoint = global.vec2(1, 0),
			PlaceholderColor3 = global.rgb(150, 150, 150),
			TextSize = 11,
			Size = global.dim2(0, 0, 0, 17),
			TextColor3 = global.rgb(150, 150, 150),
			BorderColor3 = global.rgb(0, 0, 0),
			Text = info.value .. info.suffix,
			Name = "value",
			TextWrapped = true,
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = global.dim2(1, -19, 0, -3),
			BorderSizePixel = 0,
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundColor3 = global.rgb(25, 25, 25)
		})

		objects ['hitbox'] = objects ['element']:create("TextButton", {
			TextColor3 = global.rgb(0, 0, 0),
			BorderColor3 = global.rgb(0, 0, 0),
			Text = "",
			AutoButtonColor = false,
			Name = "hitbox",
			BackgroundTransparency = 1,
			Position = global.dim2(0, 16, 0, 14),
			Size = global.dim2(1, -35, 0, 6),
			BorderSizePixel = 0,
			TextSize = 14,
			BackgroundColor3 = global.rgb(255, 255, 255),
			ZIndex = 2
		})

		objects ['safezone'] = objects ['value']:create("UIPadding", {
			PaddingBottom = global.dim(0, 1),
			PaddingLeft = global.dim(0, 4),
			Name = "safezone"
		})
	end

	info.functions.visible = function(bool)
		if info.visible == bool then return end

		info.visible = global.declare(not info.visible, bool)

		objects ['element'].Visible = info.visible
	end

	info.functions.hover = function(bool)
		if info.hovered == bool then return end
		info.hovered = global.declare(not info.hovered, bool)

		objects ['slider']:tween{duration = 0.1, goal = {BackgroundColor3 = info.hovered and global.rgb(30, 30, 30) or global.rgb(25, 25, 25)}}
	end

	info.functions.default = function(value)
		if global.is(value) ~= "number" then
			value = ((info.max - info.min) * (value.Position.X - objects ['slider'].AbsolutePosition.X) / objects ['slider'].AbsoluteSize.X)
		end

		value = global.clamp(global.round(value, info.float), info.min, info.max)

		if value == info.old then return end

		info.value = value
		info.old = value

		global.valset(library.flags, info.flag, info.value)
		global.valset(library.pointers, info.pointer, info)

		global.thread(info.callback)(value)
		global.thread(info.listener)(value)

		objects ['value'].Text = info.value .. info.suffix
		objects ['accent']:tween{duration = 0.1, goal = {Size = global.dim2((info.value - info.min) / (info.max - info.min), 0, 1, 0)}}
	end

	objects ['value']:connect("FocusLost", function()
		info.value = global.num(objects ['value'].Text) or info.value
		info.value = global.clamp(global.round(info.value, info.float), info.min, info.max)

		objects ['value'].Text = info.value

		info:set("default", info.value)
	end)

	objects ['hitbox']:connect("MouseEnter", function()
		if info.hovered then return end

		info:set("hover", true)
	end)

	objects ['hitbox']:connect("MouseLeave", function()
		if not info.hovered or info.active then return end

		info:set("hover", false)
	end)

	objects ['hitbox']:connect("InputBegan", function(input)
		if input.UserInputType.Name ~= "MouseButton1" then return end

		info:set("default", input)
		info.active = true
	end)

	objects ['hitbox']:connect("InputEnded", function(input)
		if input.UserInputType.Name ~= "MouseButton1" then return end

		info.active = false
		info:set("default", input)
		info:set("hover", info.active)
	end)

	object:connection(global.userinput.InputChanged, function(input)
		if input.UserInputType.Name ~= "MouseMovement" or not info.active then return end

		info:set("default", input)
		info:set("hover", info.active)
	end)

	-- global.valset(library.configs, info.flag, info.config)
	global.valset(library.flags, info.flag, info.value)
	global.valset(library.pointers, info.pointer, info)

	global.insert(self.elements, info)

	return info
end

-- Section > Textbox
library.textbox = function(self, info)
	info = object.lowercase(info or {}, {oriented = true})

	info.value = info.value or ""
	info.title = info.title or "Textbox"
	info.order = info.order or #self.elements + 1
	info.callback = info.callback or function() end
	info.flag = library.next(info.flag or "Textbox")
	info.pointer = info.pointer or info.flag
	info.config = global.declare(true, info.config)
	info.visible = global.declare(true, info.visible)

	info.is = "textbox"

	info.hovered = false
	info.fits = false
	info.connected = {}
	info.functions = {}

	info.listener = function(...)
		for _, func in info.connected do
			global.thread(func)(...)
		end
	end

	local objects = {} do
		objects ['element'] = self.objects ['content']:create("Frame", {
			BackgroundTransparency = 1,
			Name = "element",
			BorderColor3 = global.rgb(0, 0, 0),
			Size = global.dim2(0, 100, 0, 31),
			BorderSizePixel = 0,
			BackgroundColor3 = global.rgb(255, 255, 255),
			LayoutOrder = info.order,
			Visible = info.visible
		})

		objects ['label'] = objects ['element']:create("TextLabel", {
			FontFace = library.primaryfont,
			TextColor3 = global.rgb(200, 200, 200),
			BorderColor3 = global.rgb(0, 0, 0),
			Text = info.title,
			Name = "label",
			AutomaticSize = Enum.AutomaticSize.X,
			Size = global.dim2(0, 0, 0, 13),
			Position = global.dim2(0, 16, 0, 0),
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			BorderSizePixel = 0,
			ZIndex = 2,
			TextSize = 11,
			BackgroundColor3 = global.rgb(18, 18, 18)
		})

		objects ['safezone'] = objects ['label']:create("UIPadding", {
			PaddingTop = global.dim(0, 6),
			Name = "safezone",
			PaddingBottom = global.dim(0, 10),
			PaddingRight = global.dim(0, 1),
			PaddingLeft = global.dim(0, 1)
		})

		objects ['textbox'] = objects ['element']:create("Frame", {
			Name = "textbox",
			Position = global.dim2(0, 16, 0, 12),
			BorderColor3 = global.rgb(0, 0, 0),
			Size = global.dim2(1, -35, 0, 16),
			BorderSizePixel = 0,
			BackgroundColor3 = global.rgb(25, 25, 25)
		})

		objects ['value'] = objects ['textbox']:create("TextBox", {
			FontFace = library.primaryfont,
			TextColor3 = global.rgb(200, 200, 200),
			BorderColor3 = global.rgb(0, 0, 0),
			Text = info.value,
			Name = "input",
			Size = global.dim2(1, -8, 1, 0),
			Position = global.dim2(0, 4, 0, 0),
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			BorderSizePixel = 0,
			ClipsDescendants = true,
			TextSize = 11,
			ClearTextOnFocus = false,
			BackgroundColor3 = global.rgb(25, 25, 25)
		})

		objects ['fade'] = objects ['textbox']:create("UIGradient", {
			Rotation = 90,
			Name = "fade",
			Color = global.rgbseq{global.rgbkey(0, global.rgb(255, 255, 255)), global.rgbkey(0.37, global.rgb(231, 231, 231)), global.rgbkey(1, global.rgb(155, 155, 155))}
		})

		objects ['border'] = objects ['textbox']:create("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			LineJoinMode = Enum.LineJoinMode.Miter,
			Name = "border"
		})

		info.fits = objects ['value'].TextFits
		info.objects = objects
	end

	info.functions.hover = function(bool)
		if info.hovered == bool then return end
		info.hovered = global.declare(not info.active, bool)

		objects ['value']:tween{duration = 0.1, goal = {BackgroundColor3 = info.hovered and global.rgb(30, 30, 30) or global.rgb(25, 25, 25)}}
	end

	info.functions.value = function(str)
		if str == info.value then return end

		info.value = str
		objects ['value'].Text = info.value

		global.thread(info.callback)(info.value, info.active)
		global.thread(info.listener)(info.value, info.active)

		info.fits = objects ['value'].TextBounds.X <= objects ['value'].AbsoluteSize.X
	end

	info.functions.scroll = function()
		while library.loaded and global.wait() do
			if info.fits or info.active then continue end

			objects ['value'].Text = info.value
			global.wait(1)

			for interval = 0, global.length(info.value) do
				if objects ['value'].TextBounds.X <= objects ['value'].AbsoluteSize.X or info.active then break end

				objects ['value'].Text = global.sub(info.value, interval, global.length(info.value))
				global.wait(.15)
			end
		end
	end

	objects ['value']:connect("Focused", function()
		info.active = true

		info:set("hover", info.active)

		global.valset(library.flags, info.flag, info.value)
		global.valset(library.pointers, info.pointer, info)

		global.thread(info.callback)(info.value, info.active)
		global.thread(info.listener)(info.value, info.active)

		objects ['value'].Text = info.value
	end)

	objects ['value']:connect("FocusLost", function(entered)
		info.active = false

		info:set("value", objects ['value'].Text)
	end)

	objects ['value']:connect("MouseEnter", function()
		if info.hovered then return end

		info:set("hover", true)
	end)

	objects ['value']:connect("MouseLeave", function()
		if not info.hovered or info.active then return end

		info:set("hover", false)
	end)

	library.onload:connect(info.functions.scroll)

	-- global.valset(library.configs, info.flag, info.config)
	global.valset(library.flags, info.flag, info.value)
	global.valset(library.pointers, info.pointer, info)

	global.insert(self.elements, info)

	return info
end

-- Section > Button
library.button = function(self, info)
	info = object.lowercase(info or {}, {oriented = true})

	info.title = info.title or "Textbox"
	info.order = info.order or #self.elements + 1
	info.callback = info.callback or function() end
	info.flag = library.next(info.flag or "Button")
	info.pointer = info.pointer or info.flag
	info.visible = global.declare(true, info.visible)

	info.is = "button"

	info.hovered = false
	info.connected = {}
	info.functions = {}

	info.listener = function(...)
		for _, func in info.connected do
			global.thread(func)(...)
		end
	end

	local objects = {} do
		objects ['element'] = self.objects ['content']:create("Frame", {
			BackgroundTransparency = 1,
			Name = "element",
			BorderColor3 = global.rgb(0, 0, 0),
			Size = global.dim2(0, 100, 0, 20),
			BorderSizePixel = 0,
			BackgroundColor3 = global.rgb(255, 255, 255),
			LayoutOrder = info.order,
			Visible = info.visible
		})

		objects ['button'] = objects ['element']:create("Frame", {
			AnchorPoint = global.vec2(0, 0.5),
			Name = "button",
			Position = global.dim2(0, 16, 0.5, 0),
			BorderColor3 = global.rgb(0, 0, 0),
			Size = global.dim2(1, -35, 0, 16),
			BorderSizePixel = 0,
			BackgroundColor3 = global.rgb(25, 25, 25)
		})

		objects ['fade'] = objects ['button']:create("UIGradient", {
			Rotation = 90,
			Name = "fade",
			Color = global.rgbseq{global.rgbkey(0, global.rgb(255, 255, 255)), global.rgbkey(0.37, global.rgb(231, 231, 231)), global.rgbkey(1, global.rgb(155, 155, 155))}
		})

		objects ['border'] = objects ['button']:create("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			LineJoinMode = Enum.LineJoinMode.Miter,
			Name = "border"
		})

		objects ['label'] = objects ['button']:create("TextLabel", {
			FontFace = library.primaryfont,
			TextColor3 = global.rgb(200, 200, 200),
			BorderColor3 = global.rgb(0, 0, 0),
			Text = info.title,
			Name = "label",
			AnchorPoint = global.vec2(0.5, 0.5),
			Size = global.dim2(0, 0, 1, 0),
			BackgroundTransparency = 1,
			Position = global.dim2(0.5, 0, 0.5, -1),
			BorderSizePixel = 0,
			AutomaticSize = Enum.AutomaticSize.X,
			TextSize = 11,
			BackgroundColor3 = global.rgb(18, 18, 18)
		})

		objects ['safezone'] = objects ['label']:create("UIPadding", {
			PaddingTop = global.dim(0, 9),
			Name = "safezone",
			PaddingBottom = global.dim(0, 10),
			PaddingRight = global.dim(0, 1),
			PaddingLeft = global.dim(0, 1)
		})

		objects ['hitbox'] = objects ['element']:create("TextButton", {
			TextColor3 = global.rgb(0, 0, 0),
			BorderColor3 = global.rgb(0, 0, 0),
			Text = "",
			AutoButtonColor = false,
			AnchorPoint = global.vec2(0, 0.5),
			Name = "hitbox",
			BackgroundTransparency = 1,
			Position = global.dim2(0, 16, 0.5, 0),
			Size = global.dim2(1, -35, 0, 16),
			BorderSizePixel = 0,
			TextSize = 14,
			BackgroundColor3 = global.rgb(255, 255, 255)
		})

		info.objects = objects
	end

	info.functions.hover = function(bool)
		if info.hovered == bool then return end
		info.hovered = global.declare(not info.hovered, bool)

		objects ['button']:tween{duration = 0.1, goal = {BackgroundColor3 = info.hovered and global.rgb(30, 30, 30) or global.rgb(25, 25, 25)}}
	end

	info.functions.active = function()
		info:set("hover", false)

		global.wcall(.1, function()
			info:set("hover", true)
		end)

		global.valset(library.flags, info.flag, info.active)
		global.valset(library.pointers, info.pointer, info)

		global.thread(info.callback)(info.value, info.active)
		global.thread(info.listener)(info.value, info.active)
	end

	objects ['hitbox']:connect("InputEnded", function(input)
		if input.UserInputType.Name ~= "MouseButton1" then return end

		info:set("active")
	end)

	objects ['hitbox']:connect("MouseEnter", function()
		if info.hovered then return end

		info:set("hover", true)
	end)

	objects ['hitbox']:connect("MouseLeave", function()
		if not info.hovered then return end

		info:set("hover", false)
	end)

	global.valset(library.flags, info.flag, info.active)
	global.valset(library.pointers, info.pointer, info)

	global.insert(self.elements, info)

	return info
end

-- Section > Dropdown
library.dropdown = function(self, info)
	info = object.lowercase(info or {}, {oriented = true})

	info.multi = info.multi or false
	info.title = info.title or "Dropdown"
	info.options = info.options or {1, 2, 3}
	info.maxheight = info.maxheight or #info.options
	info.order = info.order or #self.elements + 1
	info.default = info.default or info.options[1]
	info.placeholder = info.placeholder or "None"
	info.callback = info.callback or function() end
	info.flag = library.next(info.flag or "Dropdown")
	info.pointer = info.pointer or info.flag
	info.config = global.declare(true, info.config)
	info.visible = global.declare(true, info.visible)

	info.is = "dropdown"

	info.popuphovered = false
	info.hovered = false
	info.opened = false
	info.values = {}
	info.connected = {}
	info.functions = {}

	info.listener = function(...)
		for _, func in info.connected do
			global.thread(func)(...)
		end
	end

	local objects = {} do
		objects ['element'] = self.objects ['content']:create("Frame", {
			BackgroundTransparency = 1,
			Name = "element",
			BorderColor3 = global.rgb(0, 0, 0),
			Size = global.dim2(0, 100, 0, 33),
			BorderSizePixel = 0,
			LayoutOrder = info.order,
			Visible = info.visible,
			BackgroundColor3 = global.rgb(255, 255, 255)
		})

		objects ['label'] = objects ['element']:create("TextLabel", {
			FontFace = library.primaryfont,
			TextColor3 = global.rgb(200, 200, 200),
			BorderColor3 = global.rgb(0, 0, 0),
			Text = info.title,
			Name = "label",
			AutomaticSize = Enum.AutomaticSize.X,
			Size = global.dim2(0, 0, 0, 17),
			Position = global.dim2(0, 14, 0, 0),
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			BorderSizePixel = 0,
			ZIndex = 2,
			TextSize = 11,
			BackgroundColor3 = global.rgb(18, 18, 18)
		})

		objects ['safezone'] = objects ['label']:create("UIPadding", {
			PaddingTop = global.dim(0, 6),
			Name = "safezone",
			PaddingBottom = global.dim(0, 10),
			PaddingRight = global.dim(0, 1),
			PaddingLeft = global.dim(0, 1)
		})

		objects ['dropdown'] = objects ['element']:create("Frame", {
			Name = "dropdown",
			Position = global.dim2(0, 16, 0, 14),
			BorderColor3 = global.rgb(0, 0, 0),
			Size = global.dim2(1, -35, 0, 16),
			BorderSizePixel = 0,
			BackgroundColor3 = global.rgb(25, 25, 25)
		})

		objects ['fade'] = objects ['dropdown']:create("UIGradient", {
			Rotation = 90,
			Name = "fade",
			Color = global.rgbseq{global.rgbkey(0, global.rgb(255, 255, 255)), global.rgbkey(0.37, global.rgb(231, 231, 231)), global.rgbkey(1, global.rgb(155, 155, 155))}
		})

		objects ['border'] = objects ['dropdown']:create("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			LineJoinMode = Enum.LineJoinMode.Miter,
			Name = "border"
		})

		objects ['value'] = objects ['dropdown']:create("TextLabel", {
			FontFace = library.primaryfont,
			TextColor3 = global.rgb(200, 200, 200),
			BorderColor3 = global.rgb(0, 0, 0),
			Text = info.default or info.placeholder,
			Name = "value",
			TextTruncate = Enum.TextTruncate.AtEnd,
			Size = global.dim2(1, -20, 1, 0),
			Position = global.dim2(0, 3, 0, 2),
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			BorderSizePixel = 0,
			ZIndex = 2,
			TextSize = 11,
			BackgroundColor3 = global.rgb(18, 18, 18)
		})

		objects ['safezone'] = objects ['value']:create("UIPadding", {
			PaddingTop = global.dim(0, 6),
			Name = "safezone",
			PaddingBottom = global.dim(0, 10),
			PaddingRight = global.dim(0, 1),
			PaddingLeft = global.dim(0, 1)
		})

		objects ['arrow'] = objects ['dropdown']:create("ImageLabel", {
			ScaleType = Enum.ScaleType.Fit,
			BorderColor3 = global.rgb(0, 0, 0),
			Name = "arrow",
			AnchorPoint = global.vec2(1, 0.5),
			Image = "rbxassetid://82767477824527",
			BackgroundTransparency = 1,
			Position = global.dim2(1, -3, 0.5, 0),
			Size = global.dim2(0, 6, 0, 4),
			ResampleMode = Enum.ResamplerMode.Pixelated,
			BorderSizePixel = 0,
			BackgroundColor3 = global.rgb(255, 255, 255)
		})

		objects ['hitbox'] = objects ['element']:create("TextButton", {
			TextColor3 = global.rgb(0, 0, 0),
			BorderColor3 = global.rgb(0, 0, 0),
			Text = "",
			AutoButtonColor = false,
			Name = "hitbox",
			BackgroundTransparency = 1,
			Position = global.dim2(0, 16, 0, 14),
			Size = global.dim2(1, -35, 0, 16),
			BorderSizePixel = 0,
			TextSize = 14,
			BackgroundColor3 = global.rgb(255, 255, 255)
		})

		objects ['drop'] = objects ['element']:create("Frame", {
			Size = global.dim2(1, -35, 0, info.maxheight * 15 + 3),
			Name = "drop",
			Position = global.dim2(0, 16, 0.5, 14),
			BorderColor3 = global.rgb(0, 0, 0),
			ZIndex = 15,
			BorderSizePixel = 0,
			BackgroundColor3 = global.rgb(23, 23, 23),
			Visible = info.opened
		})

		objects ['border'] = objects ['drop']:create("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			LineJoinMode = Enum.LineJoinMode.Miter,
			Name = "border"
		})

		objects ['content'] = objects ['drop']:create("ScrollingFrame", {
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollBarImageColor3 = global.rgb(255, 139, 62),
			MidImage = "rbxassetid://121616077179803",
			Active = true,
			BorderColor3 = global.rgb(0, 0, 0),
			ScrollBarThickness = 2,
			Name = "content",
			ZIndex = 15,
			Size = global.dim2(1, -5, 1, 0),
			CanvasSize = global.dim2(0, 0, 0, 0),
			BackgroundTransparency = 1,
			Position = global.dim2(0, 5, 0, 0),
			TopImage = "rbxassetid://121616077179803",
			BottomImage = "rbxassetid://121616077179803",
			BorderSizePixel = 0,
			BackgroundColor3 = global.rgb(255, 255, 255)
		})

		objects ['list'] = objects ['content']:create("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Name = "list",
			HorizontalFlex = Enum.UIFlexAlignment.Fill
		})

		global.insert(library.popups, {input = objects ['hitbox'], target = objects ['drop']})
		info.objects = objects
	end

	info.functions.visible = function(bool)
		if info.visible == bool then return end

		info.visible = global.declare(not info.visible, bool)

		objects ['element'].Visible = info.visible
	end

	info.functions.popopen = function()
		if info.popuphovered or info.hovered or not info.opened then return end

		info:set("open", false)
	end

	info.functions.hover = function(bool)
		if info.hovered == bool then return end
		info.hovered = global.declare(not info.hovered, bool)

		objects ['dropdown']:tween{duration = 0.1, goal = {BackgroundColor3 = info.hovered and global.rgb(30, 30, 30) or global.rgb(25, 25, 25)}}
	end

	info.functions.open = function(bool)
		info.opened = global.declare(not info.opened, bool)

		objects ['drop'].Visible = info.opened
	end

	info.functions.height = function()
		num = global.clamp(info.maxheight * 15, 0, objects ['list'].AbsoluteContentSize.Y) 

		objects ['drop'].Size = global.dim2(1, -35, 0, num)
	end

	info.functions.list = function()
		return info.options, info.values
	end

	info.functions.show = function(options, bool)
		options = global.is(options) ~= "table" and {options} or options

		for _, option in options do
			info.values[option]:set("visible", bool)
		end
	end

	info.functions.remove = function(self, options)
		options = global.is(options) ~= "table" and {options} or options

		for _, option in options do
			info.values[option]:remove()
		end
	end

	info.functions.default = function(options)
		options = global.is(options) ~= "table" and {options} or options

		for _, value in info.values do
			value:set("default", global.tfind(options, value.title) ~= nil)
		end

		global.valset(library.flags, info.flag, info.default)
		global.valset(library.pointers, info.pointer, info)
	end

	info.functions.refresh = function(options)
		for _, value in info.values do
			value:set("remove")
		end

		info.options = options or info.options
		for _, value in info.options do
			info:option({title = value, active = info.default == option})
		end
	end

	objects ['hitbox']:connect("InputBegan", function(input)
		if input.UserInputType.Name ~= "MouseButton1" then return end

		info:set("open")
	end)

	objects ['hitbox']:connect("MouseEnter", function()
		if info.hovered then return end

		info:set("hover", true)
	end)

	objects ['hitbox']:connect("MouseLeave", function()
		if not info.hovered then return end

		info:set("hover", false)
	end)

	objects ['drop']:connect("MouseEnter", function()
		if info.popuphovered then return end

		info.popuphovered = true
	end)

	objects ['drop']:connect("MouseLeave", function()
		if not info.popuphovered then return end

		info.popuphovered = false
	end)

	object:connection(global.userinput.InputBegan, info.functions.popopen)
	object:connection(objects ['list'].item:GetPropertyChangedSignal("AbsoluteContentSize"), info.functions.height)

	for _, option in info.options do
		info.default = info.multi and global.is(info.default) ~= "table" and {info.default} or info.default

		info:option({title = option, active = info.multi and global.tfind(info.default, option) or info.default == option})
	end

	-- global.valset(library.configs, info.flag, info.config)
	global.valset(library.flags, info.flag, info.default)
	global.valset(library.pointers, info.pointer, info)

	global.insert(self.configs, info)
	global.insert(self.elements, info)

	return info
end

-- Dropdown OR List > Option 
library.option = function(self, info)
	info = object.lowercase(info or {}, {oriented = true})

	info.active = info.active or false
	info.title = info.title

	info.parent = self
	info.visible = true
	info.hovered = false
	info.functions = {}

	local objects = {} do
		objects ['button'] = self.objects ['content']:create("TextButton", {
			FontFace = library.primaryfont,
			TextColor3 = global.rgb(200, 200, 200),
			BorderColor3 = global.rgb(0, 0, 0),
			Text = info.title,
			AutoButtonColor = false,
			BorderSizePixel = 0,
			Name = "button",
			TextTransparency = info.active and 1 or 0,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = global.dim2(1, 0, 0, 15),
			ZIndex = 15,
			TextSize = 11,
			BackgroundColor3 = global.rgb(23, 23, 23)
		})

		objects ['accent'] = objects ['button']:create("TextLabel", {
			FontFace = library.boldfont,
			TextColor3 = library.accent,
			BorderColor3 = global.rgb(0, 0, 0),
			Text = info.title,
			Size = global.dim2(0, 0, 1, 0),
			AnchorPoint = global.vec2(0, 0.5),
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundTransparency = 1,
			TextTransparency = info.active and 0 or 1,
			Name = "accent",
			Position = global.dim2(0, 0, 0.5, 0),
			BorderSizePixel = 0,
			ZIndex = 15,
			TextSize = 11,
			BackgroundColor3 = global.rgb(23, 23, 23)
		})

		objects ['safezone'] = objects ['button']:create("UIPadding", {
			PaddingBottom = global.dim(0, 1),
			Name = "safezone"
		})

		info.objects = objects
	end

	info.functions.hover = function(bool)
		if info.hovered == bool then return end
		info.hovered = global.declare(not info.hovered, bool)

		objects ['button']:tween{duration = 0.1, goal = {BackgroundColor3 = info.hovered and global.rgb(24, 24, 24) or global.rgb(23, 23, 23)}}
	end

	info.functions.adjust = function(index)
		if #info.parent.options == 0 then 
			info.parent.objects ['value'].Text = info.parent.placeholder
			return 
		end

		index += index > 1 and -1 or 1

		if not info.parent.options[index] then
			index += index > 1 and -1 or 1
		end


		info.parent:set("default", info.parent.options[index])
	end

	info.functions.visible = function(bool)
		if info.visible == bool then return end

		info.visible = global.declare(not info.visible, bool)

		local option = info.title 
		local index = global.tfind(info.parent.options, option)

		if info.visible and not index then
			global["insert"](info.parent.options, option)
		else
			global.remove(info.parent.options, index)
		end

		objects ['button'].Visible = info.visible

		if info.parent.default == option then 
			info:set("adjust", index)
		end

		if not info.parent.multi then return end 

		global.sort(info.parent.default, global.abc)
		info.parent.objects ['value'].Text = global.concat(info.parent.default, ", ") or info.parent.placeholder
	end

	info.functions.remove = function()
		local option = info.title 
		local index = global.clean(info.parent.options, option)

		global.clean(info.parent.multi and info.parent.default or {}, option)
		global.valset(info.parent.values, option, nil)
		
		objects ['button']:clean()

		if info.parent.default == option then
			info:set("adjust", index)
		end

		if not info.parent.multi then return end 

		global.sort(info.parent.default, global.abc)
		info.parent.objects ['value'].Text = global.concat(info.parent.default, ", ") or info.parent.placeholder
	end

	info.functions.active = function(bool)
		if bool == info.active then return end

		info.active = global.declare(not info.active, bool)

		objects ['button']:tween{duration = 0.1, goal = {TextTransparency = info.active and 1 or 0}}
		objects ['accent']:tween{duration = 0.1, goal = {TextTransparency = info.active and 0 or 1}}
	end

	info.functions.multi = function(bool)
		info:set("active", bool or not global.clean(info.parent.default, info.title))

		global.thread(info.parent.callback)(info.parent.default)
		global.thread(info.parent.listener)(info.parent.default)

		if info.active and not global.tfind(info.parent.default, info.title) then 
			global.insert(info.parent.default, info.title)
		end

		info.parent.objects ['value'].Text = global.concat(info.parent.default, ", ") or info.parent.placeholder
	end

	info.functions.default = function(bool)
		if bool == info.active then return end

		if info.parent.multi then info:set("multi", bool) return end

		info.parent.default = info.title
		info.parent.objects ['value'].Text = info.parent.default or info.parent.placeholder

		for _, value in info.parent.values do
			value:set("active", value == info.parent.values[info.parent.default])
		end

		global.thread(info.parent.callback)(info.parent.default)
		global.thread(info.parent.listener)(info.parent.default)
	end

	objects ['button']:connect("InputBegan", function(input)
		if input.UserInputType.Name ~= "MouseButton1" then return end

		info:set("default")
	end)

	objects ['button']:connect("MouseEnter", function()
		if info.hovered then return end

		info:set("hover", true)
	end)

	objects ['button']:connect("MouseLeave", function()
		if not info.hovered then return end

		info:set("hover", false)
	end)

	global.valset(info, "remove", info.functions.remove)
	global.valset(info.parent.values, info.title, info)

	return info
end

object.lowercase(library, {native = true})
object.lowercase(object, {native = true})
object.lowercase(global, {native = true})

return object.lowercase({
	library = object.lowercase(library, {native = true}), 
	object = object.lowercase(object, {native = true}), 
	global = object.lowercase(global, {native = true}),

	import = function(self, info)
		info = object.lowercase(info or {}, {oriented = true})

		library.primaryfont = info.primaryfont or library.primaryfont or Font.new("rbxasset://fonts/families/Bangers.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
		library.secondaryfont = info.secondaryfont or library.secondaryfont or Font.new("rbxasset://fonts/families/HighwayGothic.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
		library.boldfont = info.boldfont or library.boldfont or Font.new("rbxasset://fonts/families/Zekton.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
		
		return self.library, self.object, self.global
	end
}, {native = true})
