local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Rayfield | Delta Version",
    LoadingTitle = "Rayfield UI",
    LoadingSubtitle = "By SiriusSoftwareLtd",
    ConfigurationSaving = {
        Enabled = false
    }
})

local Tab = Window:CreateTab("Main", 4483362458)

Tab:CreateButton({
    Name = "Test Button",
    Callback = function()
        Rayfield:Notify({
            Title = "Rayfield",
            Content = "Button works!",
            Duration = 3
        })
    end
})

local toggle = Tab:CreateToggle({
    Name = "Example Toggle",
    CurrentValue = false,
    Callback = function(Value)
        print("Toggle:", Value)
    end
})

local slider = Tab:CreateSlider({
    Name = "Example Slider",
    Range = {1, 100},
    Increment = 1,
    CurrentValue = 50,
    Callback = function(Value)
        print("Slider:", Value)
    end
})

local dropdown = Tab:CreateDropdown({
    Name = "Example Dropdown",
    Options = {"A", "B", "C", "D"},
    CurrentOption = {"A"},
    Callback = function(Option)
        print("Dropdown:", Option)
    end
})
