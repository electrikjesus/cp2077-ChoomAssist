-- ChoomAssist graphics / GameOptions catalog (CET-only)
-- Copyright (C) 2021-2026 Jon West <electrikjesus@gmail.com>
-- SPDX-License-Identifier: GPL-3.0-or-later

local Graphics = {}

local function opt(option, name, location, note, defaultvalue)
    return {
        option = option,
        name = name,
        location = location,
        note = note or "",
        defaultvalue = defaultvalue,
    }
end

Graphics.VisualComfort = {
    opt("MotionBlur", "Motion Blur", "Developer/FeatureToggles", "Can cause nausea or motion sickness.", true),
    opt("FilmGrain", "Film Grain", "Developer/FeatureToggles", "Makes text and UI harder to read.", true),
    opt("ChromaticAberration", "Chromatic Aberration", "Developer/FeatureToggles", "Color fringing that reduces clarity.", true),
    opt("DepthOfField", "Depth of Field", "Developer/FeatureToggles", "Blurs what you are not focused on.", true),
    opt("Bloom", "Bloom", "Developer/FeatureToggles", "Bright glow that can wash out details.", true),
    opt("Distortion", "Distortion", "Developer/FeatureToggles", "Warps the image. Can be disorienting.", true),
    opt("ImageBasedFlares", "Image Based Flares", "Developer/FeatureToggles", "Lens flare flashes.", true),
    opt("ScreenSpaceHeatHaze", "Heat Haze", "Developer/FeatureToggles", "Shimmer that makes objects harder to see.", true),
    opt("EyeAdaptation", "Eye Adaptation", "Developer/FeatureToggles", "Sudden brightness changes when entering new lighting.", true),
    opt("Tonemapping", "Tonemapping", "Developer/FeatureToggles", "Leave on unless you know you need it off. Turning it off can look wrong.", true),
}

Graphics.ShadowsGI = {
    opt("GlobalIllumination", "Global Illumination", "Developer/FeatureToggles", "Disabling can help low-end GPUs.", true),
    opt("DistantGI", "Distant Global Illumination", "Developer/FeatureToggles", "Disabling can help low-end GPUs.", true),
    opt("DistantShadows", "Distant Shadows", "Developer/FeatureToggles", "Disabling can help low-end GPUs.", true),
    opt("CascadeShadows", "Cascade Shadows", "Developer/FeatureToggles", "Disabling flattens lighting but can raise FPS.", true),
}

Graphics.Fog = {
    opt("DistantFog", "Distant Fog", "Developer/FeatureToggles", "Fog can hide distant objectives and NPCs.", true),
    opt("VolumetricFog", "Volumetric Fog", "Developer/FeatureToggles", "Heavy on low-end GPUs and it cuts visibility.", true),
    opt("DistantVolFog", "Distant Volumetric Fog", "Developer/FeatureToggles", "Heavy on low-end GPUs.", true),
    opt("VolumetricClouds", "Volumetric Clouds", "Developer/FeatureToggles", "Heavy on low-end GPUs.", true),
}

Graphics.ScreenSpace = {
    opt("ScreenSpaceReflection", "Screen Space Reflections", "Developer/FeatureToggles", "Reflections. Costly on low-end GPUs.", true),
    opt("ScreenSpaceRain", "Screen Space Reflections for Rain", "Developer/FeatureToggles", "", true),
    opt("ScreenSpaceUnderwater", "Underwater Screen Space Reflections", "Developer/FeatureToggles", "", true),
    opt("SSAO", "Screen Space Ambient Occlusion", "Developer/FeatureToggles", "Soft shadows in corners. Costly on low-end GPUs.", true),
    opt("ScreenSpacePlanarReflection", "Screen Space Planar Reflections", "Developer/FeatureToggles", "", true),
}

Graphics.Performance = {
    opt("Antialiasing", "Antialiasing", "Developer/FeatureToggles", "Smoothing edges. Off can raise FPS, but edges look harsher.", true),
    opt("Weather", "Weather", "Developer/FeatureToggles", "May need a time skip. Can break lighting.", true),
    opt("RainMap", "Rain Map", "Developer/FeatureToggles", "", true),
    opt("DynamicDecals", "Dynamic Decals", "Developer/FeatureToggles", "Bullet holes and similar marks.", true),
    opt("Enabled", "Static Decals", "Streaming/Culling/StaticDecals", "", true),
    opt("Enabled", "Crowd", "Crowd", "Roaming pedestrians and traffic. May need a reload or time skip.", true),
    opt("CharacterLightBlockers", "Character Light Blockers", "Developer/FeatureToggles", "", true),
    opt("CharacterRimEnhancement", "Character Rim Enhancement", "Developer/FeatureToggles", "", true),
    opt("CharacterSubsurfaceScattering", "Character Subsurface Scattering", "Developer/FeatureToggles", "Skin lighting. Disabling can help low-end GPUs.", true),
    opt("Hair", "Hair", "Developer/FeatureToggles", "Disabling can help low-end GPUs.", true),
}

Graphics.AsyncCompute = {
    opt("Enable", "Async Compute", "Rendering/AsyncCompute", "Disabling may help old GPUs.", true),
    opt("DPL", "Async Compute DPL", "Rendering/AsyncCompute", "Disabling may help old GPUs.", true),
    opt("SSAO", "Async Compute SSAO", "Rendering/AsyncCompute", "Disabling may help old GPUs.", true),
    opt("LutGeneration", "Async Compute LUT Generation", "Rendering/AsyncCompute", "Disabling may help old GPUs.", true),
    opt("DynamicTexture", "Async Compute Dynamic Texture", "Rendering/AsyncCompute", "Disabling may help old GPUs.", true),
    opt("FlattenNormals", "Async Compute Flatten Normals", "Rendering/AsyncCompute", "Disabling may help old GPUs.", true),
    opt("BuildDepthChain", "Async Compute Build Depth Chain", "Rendering/AsyncCompute", "Disabling may help old GPUs.", true),
    opt("ExtendedDuringSSR", "Async Compute During SSR", "Rendering/AsyncCompute", "Disabling may help old GPUs.", true),
    opt("UseAsyncComputeFFT", "Water Async Compute FFT", "WaterSimulation", "Disabling may help old GPUs.", true),
}

function Graphics.groups()
    return {
        { id = "visual", title = "Visual Comfort", list = Graphics.VisualComfort },
        { id = "shadows", title = "Shadows / Global Illumination", list = Graphics.ShadowsGI },
        { id = "fog", title = "Fog / Clouds", list = Graphics.Fog },
        { id = "ss", title = "Screen Space", list = Graphics.ScreenSpace },
        { id = "perf", title = "World / Characters", list = Graphics.Performance },
        { id = "async", title = "Async Compute (old GPUs)", list = Graphics.AsyncCompute },
    }
end

function Graphics.eachOption(callback)
    for _, group in ipairs(Graphics.groups()) do
        for _, graphicsOption in ipairs(group.list) do
            callback(graphicsOption)
        end
    end
end

function Graphics.export()
    local exported = {}
    Graphics.eachOption(function(graphicsOption)
        Graphics.syncFromGame(graphicsOption)
        exported[graphicsOption.name] = graphicsOption.defaultvalue
    end)
    return exported
end

function Graphics.applyOption(graphicsOption, value)
    graphicsOption.defaultvalue = value
    pcall(function()
        GameOptions.SetBool(graphicsOption.location, graphicsOption.option, value)
    end)
end

function Graphics.syncFromGame(graphicsOption)
    local ok, value = pcall(function()
        return GameOptions.GetBool(graphicsOption.location, graphicsOption.option)
    end)
    if ok and value ~= nil then
        graphicsOption.defaultvalue = value
    end
end

function Graphics.applySaved(saved)
    if type(saved) ~= "table" then
        return
    end
    Graphics.eachOption(function(graphicsOption)
        local value = saved[graphicsOption.name]
        if value ~= nil then
            Graphics.applyOption(graphicsOption, value)
        end
    end)
end

local function setNamed(name, value)
    Graphics.eachOption(function(graphicsOption)
        if graphicsOption.name == name then
            Graphics.applyOption(graphicsOption, value)
        end
    end)
end

function Graphics.applyVanilla()
    Graphics.eachOption(function(graphicsOption)
        Graphics.applyOption(graphicsOption, true)
    end)
end

function Graphics.applyVisualComfort()
    setNamed("Motion Blur", false)
    setNamed("Film Grain", false)
    setNamed("Chromatic Aberration", false)
    setNamed("Depth of Field", false)
    setNamed("Bloom", false)
    setNamed("Distortion", false)
    setNamed("Image Based Flares", false)
    setNamed("Heat Haze", false)
    setNamed("Eye Adaptation", false)
    setNamed("Tonemapping", true)
end

function Graphics.applyLowEnd()
    Graphics.applyVisualComfort()
    setNamed("Global Illumination", false)
    setNamed("Distant Global Illumination", false)
    setNamed("Distant Shadows", false)
    setNamed("Cascade Shadows", false)
    setNamed("Distant Fog", false)
    setNamed("Volumetric Fog", false)
    setNamed("Distant Volumetric Fog", false)
    setNamed("Volumetric Clouds", false)
    setNamed("Screen Space Reflections", false)
    setNamed("Screen Space Reflections for Rain", false)
    setNamed("Underwater Screen Space Reflections", false)
    setNamed("Screen Space Ambient Occlusion", false)
    setNamed("Screen Space Planar Reflections", false)
    setNamed("Antialiasing", false)
    setNamed("Weather", true)
    setNamed("Rain Map", false)
    setNamed("Dynamic Decals", false)
    setNamed("Static Decals", false)
    setNamed("Crowd", false)
    setNamed("Character Subsurface Scattering", false)
    setNamed("Hair", false)
    setNamed("Character Rim Enhancement", false)
    setNamed("Async Compute", false)
    setNamed("Async Compute DPL", false)
    setNamed("Async Compute SSAO", false)
    setNamed("Async Compute LUT Generation", false)
    setNamed("Async Compute Dynamic Texture", false)
    setNamed("Async Compute Flatten Normals", false)
    setNamed("Async Compute Build Depth Chain", false)
    setNamed("Async Compute During SSR", false)
    setNamed("Water Async Compute FFT", false)
end

function Graphics.applyBalanced()
    Graphics.applyVisualComfort()
    setNamed("Global Illumination", true)
    setNamed("Distant Global Illumination", false)
    setNamed("Distant Shadows", false)
    setNamed("Cascade Shadows", true)
    setNamed("Distant Fog", false)
    setNamed("Volumetric Fog", false)
    setNamed("Distant Volumetric Fog", false)
    setNamed("Volumetric Clouds", false)
    setNamed("Screen Space Reflections", false)
    setNamed("Screen Space Ambient Occlusion", true)
    setNamed("Antialiasing", true)
    setNamed("Crowd", true)
    setNamed("Hair", true)
    setNamed("Async Compute", true)
end

return Graphics
