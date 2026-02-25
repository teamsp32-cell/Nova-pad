-- Nova Pad - Smart Dhyan & Radio Module 🎧
-- 100% Working (Fixed AndroLua Import Bug & Added Nature Sounds)

require "import"
import "android.media.MediaPlayer"

local patchActivity = activity
local rootDirPatch = patchActivity.getExternalFilesDir(nil).toString() .. "/"

local function getPatchLang()
    local lang = "en"
    local f = io.open(rootDirPatch .. "lang_pref.txt", "r")
    if f then
        local content = f:read("*a"); f:close()
        if content and content:match("hi") then lang = "hi" end
    end
    return lang
end
local function LP(en, hi) return (getPatchLang() == "hi") and hi or en end

-- 📻 15 बेहतरीन 24/7 लाइव और सुरक्षित (HTTPS) रेडियो 
local radioStations = {
    {name = "🛑 " .. LP("Stop Music", "म्यूजिक बंद करें"), url = "STOP"},
    
    -- ⬇️ 1. तुम्हारे ओरिजिनल ध्यान संगीत ⬇️
    {name = "🧘 " .. LP("Meditation 1 (Original)", "ध्यान संगीत 1 (पुराना)"), url = "https://raw.githubusercontent.com/teamsp32-cell/Nova-pad/main/Meditation%20Music%20(1).mp3"},
    {name = "🧘 " .. LP("Meditation 2 (Original)", "ध्यान संगीत 2 (पुराना)"), url = "https://raw.githubusercontent.com/teamsp32-cell/Nova-pad/main/Meditation%20music%202.mp3"},
    {name = "🧘 " .. LP("Meditation 3 (Original)", "ध्यान संगीत 3 (पुराना)"), url = "https://raw.githubusercontent.com/teamsp32-cell/Nova-pad/main/Meditation%20Music%20-%201%2C.mp3"},

    -- ⬇️ 2. प्रकृति और शांति (Nature Sounds) ⬇️
    {name = "🌧️ " .. LP("Rain Drops", "शांत बारिश की आवाज़"), url = "https://stream.laut.fm/regen"},
    {name = "🐦 " .. LP("Forest & Birds", "जंगल और पंछियों की आवाज़"), url = "https://stream.laut.fm/waldgeraeusche"},
    {name = "🌊 " .. LP("River & Ocean", "नदी और समंदर की लहरें"), url = "https://stream.laut.fm/meer"},
    {name = "🔥 " .. LP("Campfire Vibe", "कैंपफायर और रात"), url = "https://stream.laut.fm/ambient"},

    -- ⬇️ 3. डीप फोकस और लो-फाई (Focus & Lo-Fi) ⬇️
    {name = "🎵 " .. LP("Lo-Fi Chill Beats", "लो-फाई चिल बीट्स"), url = "https://streams.ilovemusic.de/iloveradio17.mp3"},
    {name = "☕ " .. LP("Chillout Lounge", "चिलआउट लाउंज (फोकस)"), url = "https://strm112.1.fm/chilloutlounge_mobile_mp3"},
    
    -- ⬇️ 4. क्लासिकल और इंस्ट्रूमेंटल (Classical & Instruments) ⬇️
    {name = "🎻 " .. LP("Violin & Strings", "वायलिन और क्लासिकल"), url = "https://stream.laut.fm/klassik"},
    {name = "🎹 " .. LP("Relaxing Piano", "सुकून भरा पियानो"), url = "https://stream.srg-ssr.ch/m/rsc_de/mp3_128"},
    {name = "🎸 " .. LP("Acoustic Guitar", "अकॉस्टिक गिटार"), url = "https://strm112.1.fm/guitars_mobile_mp3"},
    {name = "🎷 " .. LP("Smooth Jazz", "स्मूथ जैज़"), url = "https://strm112.1.fm/smoothjazz_mobile_mp3"},

    -- ⬇️ 5. योग और गहरा ध्यान (Yoga & Deep Zen) ⬇️
    {name = "🕉️ " .. LP("Yoga & Zen", "योग और गहरा ध्यान"), url = "https://stream.laut.fm/yoga"},
    {name = "🌌 " .. LP("Deep Sleep Space", "स्लीप और स्पेस एम्बियंस"), url = "https://maggie.torontocast.com:8076/stream"}
}

_G.showAmbientMenu = function()
    local list = ListView(patchActivity)
    local adapter = ArrayAdapter(patchActivity, android.R.layout.simple_list_item_1)
    
    for i, station in ipairs(radioStations) do
        adapter.add(station.name)
    end
    list.setAdapter(adapter)

    local dlg = AlertDialog.Builder(patchActivity)
    .setTitle(LP("🎧 Focus Music & Radio", "🎧 ध्यान संगीत व रेडियो"))
    .setView(list)
    .setNegativeButton(LP("Close", "बंद करें"), nil)
    .show()

    list.setOnItemClickListener(AdapterView.OnItemClickListener{
        onItemClick = function(parent, view, position, id)
            local selected = radioStations[position + 1]
            
            if selected.url == "STOP" then
                pcall(function() if _G.mediaPlayer then _G.mediaPlayer.stop(); _G.mediaPlayer.release(); _G.mediaPlayer = nil end end)
                pcall(function() if _G.novaRadioPlayer then _G.novaRadioPlayer.stop(); _G.novaRadioPlayer.release(); _G.novaRadioPlayer = nil end end)
                
                local msg = LP("Music Stopped 🛑", "म्यूजिक बंद कर दिया गया 🛑")
                Toast.makeText(patchActivity, msg, 0).show()
                list.announceForAccessibility(msg) 
                dlg.dismiss()
                return
            end

            local startMsg = LP("Loading " .. selected.name .. " ⏳", selected.name .. " लोड हो रहा है... ⏳")
            Toast.makeText(patchActivity, startMsg, 0).show()
            list.announceForAccessibility(startMsg)
            
            pcall(function()
                pcall(function() if _G.mediaPlayer then _G.mediaPlayer.stop(); _G.mediaPlayer.release(); _G.mediaPlayer = nil end end)
                pcall(function() if _G.novaRadioPlayer then _G.novaRadioPlayer.stop(); _G.novaRadioPlayer.release(); _G.novaRadioPlayer = nil end end)
                
                _G.novaRadioPlayer = MediaPlayer()
                _G.novaRadioPlayer.setDataSource(selected.url)
                _G.novaRadioPlayer.setAudioStreamType(3)
                
                _G.novaRadioPlayer.setOnPreparedListener(MediaPlayer.OnPreparedListener{
                    onPrepared = function(mp)
                        mp.setVolume(0.2, 0.2)
                        mp.setLooping(true) 
                        mp.start()
                        local playMsg = LP("🎶 Playing: " .. selected.name, "🎶 बजना शुरू: " .. selected.name)
                        Toast.makeText(patchActivity, playMsg, 0).show()
                        list.announceForAccessibility(playMsg)
                    end
                })
                
                _G.novaRadioPlayer.setOnErrorListener(MediaPlayer.OnErrorListener{
                    onError = function(mp, what, extra) 
                        local errMsg = LP("Audio Error. Check Internet.", "ऑडियो एरर! इंटरनेट चेक करें।")
                        Toast.makeText(patchActivity, errMsg, 1).show()
                        list.announceForAccessibility(errMsg)
                        return true 
                    end
                })
                
                _G.novaRadioPlayer.prepareAsync()
            end)
            dlg.dismiss()
        end
    })
end
