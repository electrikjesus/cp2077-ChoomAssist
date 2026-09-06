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
    opt("MotionBlur", "Motion Blur", "Developer/FeatureToggles", "On: the world smears when you or the camera move. Can cause nausea. Off: motion is sharp.", true),
    opt("FilmGrain", "Film Grain", "Developer/FeatureToggles", "On: a grainy overlay on the whole image. Makes small text harder to read. Off: a cleaner picture.", true),
    opt("ChromaticAberration", "Chromatic Aberration", "Developer/FeatureToggles", "On: color fringing at the edges of objects. Off: colors line up.", true),
    opt("DepthOfField", "Depth of Field", "Developer/FeatureToggles", "On: things out of focus are blurry. Off: more of the scene stays readable.", true),
    opt("Bloom", "Bloom", "Developer/FeatureToggles", "On: bright lights glow and can wash out details. Off: lights stay tighter.", true),
    opt("Distortion", "Distortion", "Developer/FeatureToggles", "On: heat, glass, and some effects warp the image. Can be disorienting. Off: no extra warp.", true),
    opt("ImageBasedFlares", "Image Based Flares", "Developer/FeatureToggles", "On: lens flares from bright sources. Off: no flare flashes.", true),
    opt("ScreenSpaceHeatHaze", "Heat Haze", "Developer/FeatureToggles", "On: hot surfaces shimmer. Makes distant objects harder to track. Off: no shimmer.", true),
    opt("EyeAdaptation", "Eye Adaptation", "Developer/FeatureToggles", "On: the image can flash brighter or darker when lighting changes. Off: more stable brightness.", true),
    opt("Tonemapping", "Tonemapping", "Developer/FeatureToggles", "On: normal contrast (recommended). Off: colors and brightness can look wrong. Leave this on unless you know you need it off.", true),
}

Graphics.ShadowsGI = {
    opt("GlobalIllumination", "Global Illumination", "Developer/FeatureToggles", "On: bounced lighting (heavier). Off: faster on slow GPUs, flatter lighting.", true),
    opt("DistantGI", "Distant Global Illumination", "Developer/FeatureToggles", "On: GI in the distance. Off: saves GPU time far from V.", true),
    opt("DistantShadows", "Distant Shadows", "Developer/FeatureToggles", "On: shadows far away. Off: fewer distant shadows, more FPS.", true),
    opt("CascadeShadows", "Cascade Shadows", "Developer/FeatureToggles", "On: detailed nearby shadows. Off: lighting looks flatter but FPS can rise.", true),
}

Graphics.Fog = {
    opt("DistantFog", "Distant Fog", "Developer/FeatureToggles", "On: haze in the distance. Can hide map markers. Off: farther draw, more visible skyline.", true),
    opt("VolumetricFog", "Volumetric Fog", "Developer/FeatureToggles", "On: thick god-rays and fog (heavy). Off: clearer air and more FPS.", true),
    opt("DistantVolFog", "Distant Volumetric Fog", "Developer/FeatureToggles", "On: volumetric fog far away. Off: cheaper distant fog.", true),
    opt("VolumetricClouds", "Volumetric Clouds", "Developer/FeatureToggles", "On: 3D clouds (heavy). Off: simpler sky, more FPS.", true),
}

Graphics.ScreenSpace = {
    opt("ScreenSpaceReflection", "Screen Space Reflections", "Developer/FeatureToggles", "On: reflections on wet streets and metal (costly). Off: duller reflections, more FPS.", true),
    opt("ScreenSpaceRain", "Screen Space Reflections for Rain", "Developer/FeatureToggles", "On: extra reflections when it rains. Off: cheaper rain.", true),
    opt("ScreenSpaceUnderwater", "Underwater Screen Space Reflections", "Developer/FeatureToggles", "On: reflections while swimming. Off: cheaper underwater.", true),
    opt("SSAO", "Screen Space Ambient Occlusion", "Developer/FeatureToggles", "On: contact shadows in corners (costly). Off: flatter shading, more FPS.", true),
    opt("ScreenSpacePlanarReflection", "Screen Space Planar Reflections", "Developer/FeatureToggles", "On: extra planar reflections. Off: cheaper mirrors/floors.", true),
}

Graphics.Performance = {
    opt("Antialiasing", "Antialiasing", "Developer/FeatureToggles", "On: smoother edges. Off: more FPS, jagged edges.", true),
    opt("Weather", "Weather", "Developer/FeatureToggles", "On: rain and weather systems. Off: may need a time skip. Can break lighting. Use with care.", true),
    opt("RainMap", "Rain Map", "Developer/FeatureToggles", "On: rain wetness on surfaces. Off: cheaper rain look.", true),
    opt("DynamicDecals", "Dynamic Decals", "Developer/FeatureToggles", "On: bullet holes and similar marks. Off: fewer decals, a bit more FPS.", true),
    opt("Enabled", "Static Decals", "Streaming/Culling/StaticDecals", "On: placed world decals. Off: some posters and stains disappear.", true),
    opt("Enabled", "Crowd", "Crowd", "On: pedestrians and traffic. Off: quieter streets, more FPS. May need a reload or time skip.", true),
    opt("CharacterLightBlockers", "Character Light Blockers", "Developer/FeatureToggles", "On: bodies block light correctly. Off: cheaper character lighting.", true),
    opt("CharacterRimEnhancement", "Character Rim Enhancement", "Developer/FeatureToggles", "On: extra rim light on people. Off: flatter character lighting.", true),
    opt("CharacterSubsurfaceScattering", "Character Subsurface Scattering", "Developer/FeatureToggles", "On: skin lets light through (costly). Off: cheaper faces, more FPS.", true),
    opt("Hair", "Hair", "Developer/FeatureToggles", "On: full hair rendering. Off: cheaper hair, more FPS.", true),
}

Graphics.AsyncCompute = {
    opt("Enable", "Async Compute", "Rendering/AsyncCompute", "On: GPU overlap (default). Off: may help very old GPUs if you hitch or crash.", true),
    opt("DPL", "Async Compute DPL", "Rendering/AsyncCompute", "On: async DPL. Off: may help old GPUs.", true),
    opt("SSAO", "Async Compute SSAO", "Rendering/AsyncCompute", "On: async SSAO. Off: may help old GPUs.", true),
    opt("LutGeneration", "Async Compute LUT Generation", "Rendering/AsyncCompute", "On: async color LUT. Off: may help old GPUs.", true),
    opt("DynamicTexture", "Async Compute Dynamic Texture", "Rendering/AsyncCompute", "On: async dynamic textures. Off: may help old GPUs.", true),
    opt("FlattenNormals", "Async Compute Flatten Normals", "Rendering/AsyncCompute", "On: async normals. Off: may help old GPUs.", true),
    opt("BuildDepthChain", "Async Compute Build Depth Chain", "Rendering/AsyncCompute", "On: async depth chain. Off: may help old GPUs.", true),
    opt("ExtendedDuringSSR", "Async Compute During SSR", "Rendering/AsyncCompute", "On: async during reflections. Off: may help old GPUs.", true),
    opt("UseAsyncComputeFFT", "Water Async Compute FFT", "WaterSimulation", "On: async water FFT. Off: may help old GPUs.", true),
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
