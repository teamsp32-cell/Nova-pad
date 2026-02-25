-- Nova Pad - Smart Dhyan & Radio Module 🎧
-- 100% Bulletproof Audio Player (Fresh Instance Every Time)

local patchActivity = activity
local rootDirPatch = patchActivity.getExternalFilesDir(nil).toString() .. "/"

local MediaPlayer = luajava.bindClass("android.media.MediaPlayer")

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

-- 📻 3 पुराने ऑडिओज़ + 100% वर्किंग सुरक्षित (HTTPS) लाइव रेडियो 
local radioStations = {
    {name = "🛑 " .. LP("Stop Music", "म्यूजिक बंद करें"), url = "STOP"},
    
    -- ⬇️ तुम्हारे पुराने वाले 3 ध्यान संगीत ⬇️
    {name = "🧘 " .. LP("Meditation 1 (Original)", "ध्यान संगीत 1 (पुराना)"), url = "https://raw.githubusercontent.com/teamsp32-cell/Nova-pad/main/Meditation%20Music%20(1).mp3"},
    {name = "🧘 " .. LP("Meditation 2 (Original)", "ध्यान संगीत 2 (पुराना)"), url = "https://raw.githubusercontent.com/teamsp32-cell/Nova-pad/main/Meditation%20music%202.mp3"},
    {name = "🧘 " .. LP("Meditation 3 (Original)", "ध्यान संगीत 3 (पुराना)"), url = "https://raw.githubusercontent.com/teamsp32-cell/Nova-pad/main/Meditation%20Music%20-%201%2C.mp3"},

    -- ⬇️ नए 24/7 लाइव सुरक्षित (HTTPS) रेडियो ⬇️
    {name = "🎵 " .. LP("Lo-Fi Chill", "लो-फाई चिल"), url = "https://streams.ilovemusic.de/iloveradio17.mp3"},
    {name = "🎹 " .. LP("Relaxing Piano", "रिलैक्सिंग पियानो"), url = "https://stream.srg-ssr.ch/m/rsc_de/mp3_128"},
    {name = "🎻 " .. LP("Classical Focus", "क्लासिकल फोकस"), url = "https://strm112.1.fm/aclassic_mobile_mp3"},
    {name = "🎷 " .. LP("Smooth Jazz", "स्मूथ जैज़"), url = "https://strm112.1.fm/smoothjazz_mobile_mp3"},
    {name = "🧘 " .. LP("Deep Sleep & Ambient", "गहरा ध्यान व शांति"), url = "https://maggie.torontocast.com:8076/stream"},
    {name = "🎸 " .. LP("Acoustic Guitar", "अकॉस्टिक गिटार"), url = "https://strm112.1.fm/guitars_mobile_mp3"},
    {name = "☕ " .. LP("Chillout Lounge", "चिलआउट लाउंज"), url = "https://strm112.1.fm/chilloutlounge_mobile_mp3"}
}

-- 🔥 THE MAGIC: पुराने मेनू को ओवरराइट कर रहे हैं 🔥
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
                -- किसी भी पुराने प्लेयर को पूरी तरह से नष्ट (Kill) करो
                pcall(function() if _G.novaRadioPlayer then _G.novaRadioPlayer:stop(); _G.novaRadioPlayer:release(); _G.novaRadioPlayer = nil end end)
                local msg = LP("Music Stopped 🛑", "म्यूजिक बंद कर दिया गया 🛑")
                Toast.makeText(patchActivity, msg, 0).show()
                list.announceForAccessibility(msg) 
                dlg.dismiss()
                return
            end

            local startMsg = LP("Connecting to " .. selected.name .. " ⏳", selected.name .. " लोड हो रहा है... ⏳")
            Toast.makeText(patchActivity, startMsg, 0).show()
            list.announceForAccessibility(startMsg)
            
            pcall(function()
                -- 1. पुराने प्लेयर को पूरी तरह से बंद और नष्ट करो
                pcall(function() if _G.novaRadioPlayer then _G.novaRadioPlayer:stop(); _G.novaRadioPlayer:release(); _G.novaRadioPlayer = nil end end)
                
                -- 2. बिल्कुल नया फ्रेश प्लेयर बनाओ
                local freshPlayer = MediaPlayer()
                _G.novaRadioPlayer = freshPlayer
                
                freshPlayer:setDataSource(selected.url)
                
                -- 3. लिस्नर (Listener) को prepareAsync से **पहले** सेट करना बहुत ज़रूरी है!
                freshPlayer:setOnPreparedListener(MediaPlayer.OnPreparedListener{
                    onPrepared = function(mp)
                        mp:setVolume(0.2, 0.2)
                        mp:setLooping(true) 
                        mp:start()
                        local playMsg = LP("🎶 Playing: " .. selected.name, "🎶 बजना शुरू: " .. selected.name)
                        Toast.makeText(patchActivity, playMsg, 0).show()
                    end
                })
                
                freshPlayer:setOnErrorListener(MediaPlayer.OnErrorListener{
                    onError = function(mp, what, extra) 
                        Toast.makeText(patchActivity, LP("Audio Fail! Error Code: ", "ऑडियो फेल! एरर कोड: ") .. tostring(what), 1).show()
                        return true 
                    end
                })
                
                -- 4. अब आख़िर में लोड करना शुरू करो
                freshPlayer:prepareAsync()
            end)
            dlg.dismiss()
        end
    })
end
