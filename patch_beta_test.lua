-- ==========================================
-- 🎧 DHYAN & LIVE RADIO MODULE (OVERRIDE)
-- ==========================================
local patchActivity = activity
local rootDirPatch = patchActivity.getExternalFilesDir(nil).toString() .. "/"

local MediaPlayer = luajava.bindClass("android.media.MediaPlayer")

-- ग्लोबल प्लेयर (ताकि बैकग्राउंड में बजता रहे)
if not _G.novaRadioPlayer then
    _G.novaRadioPlayer = MediaPlayer()
end

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

-- 📻 3 पुराने ऑडिओज़ + 24/7 लाइव रेडियो की मास्टर लिस्ट
local radioStations = {
    {name = "🛑 " .. LP("Stop Music", "म्यूजिक बंद करें"), url = "STOP"},
    
    -- ⬇️ तुम्हारे पुराने वाले 3 ध्यान संगीत ⬇️
    {name = "🧘 " .. LP("Meditation 1 (Original)", "ध्यान संगीत 1 (पुराना)"), url = "https://raw.githubusercontent.com/teamsp32-cell/Nova-pad/main/Meditation%20Music%20(1).mp3"},
    {name = "🧘 " .. LP("Meditation 2 (Original)", "ध्यान संगीत 2 (पुराना)"), url = "https://raw.githubusercontent.com/teamsp32-cell/Nova-pad/main/Meditation%20music%202.mp3"},
    {name = "🧘 " .. LP("Meditation 3 (Original)", "ध्यान संगीत 3 (पुराना)"), url = "https://raw.githubusercontent.com/teamsp32-cell/Nova-pad/main/Meditation%20Music%20-%201%2C.mp3"},

    -- ⬇️ 24/7 लाइव रिलैक्सिंग रेडियो ⬇️
    {name = "🌧️ " .. LP("Rain & Nature", "बारिश और प्रकृति"), url = "http://stream.laut.fm/nature"},
    {name = "🎵 " .. LP("Lo-Fi Chill", "लो-फाई चिल"), url = "http://stream.laut.fm/lofi"},
    {name = "🎹 " .. LP("Relaxing Piano", "रिलैक्सिंग पियानो"), url = "http://stream.laut.fm/piano"},
    {name = "🎻 " .. LP("Classical Focus", "क्लासिकल फोकस"), url = "http://stream.laut.fm/classical"},
    {name = "🎷 " .. LP("Smooth Jazz", "स्मूथ जैज़"), url = "http://stream.laut.fm/jazz"},
    {name = "🧘 " .. LP("Deep Meditation", "गहरा ध्यान"), url = "http://stream.laut.fm/meditation"},
    {name = "🌌 " .. LP("Ambient Space", "एम्बिएंट स्पेस"), url = "http://stream.laut.fm/ambient"}
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
                -- अगर ऐप का पुराना प्लेयर चल रहा है, तो उसे भी चुपचाप बंद कर दो
                pcall(function() if mediaPlayer and mediaPlayer.isPlaying() then mediaPlayer.stop() end end)
                
                if _G.novaRadioPlayer:isPlaying() then
                    _G.novaRadioPlayer:stop()
                end
                _G.novaRadioPlayer:reset()
                local msg = LP("Music Stopped 🛑", "म्यूजिक बंद कर दिया गया 🛑")
                Toast.makeText(patchActivity, msg, 0).show()
                list.announceForAccessibility(msg) -- TalkBack सपोर्ट
                dlg.dismiss()
                return
            end

            local startMsg = LP("Connecting to " .. selected.name .. " ⏳", selected.name .. " शुरू हो रहा है... ⏳")
            Toast.makeText(patchActivity, startMsg, 0).show()
            list.announceForAccessibility(startMsg)
            
            pcall(function()
                -- नया चलाने से पहले पुराने वाले सारे प्लेयर बंद करो
                pcall(function() if mediaPlayer and mediaPlayer.isPlaying() then mediaPlayer.stop() end end)
                
                if _G.novaRadioPlayer:isPlaying() then _G.novaRadioPlayer:stop() end
                _G.novaRadioPlayer:reset()
                _G.novaRadioPlayer:setDataSource(selected.url)
                _G.novaRadioPlayer:prepareAsync()
                
                _G.novaRadioPlayer:setOnPreparedListener(MediaPlayer.OnPreparedListener{
                    onPrepared = function(mp)
                        -- 🔥 वॉल्यूम 20% सेट किया ताकि TalkBack बिल्कुल साफ सुनाई दे!
                        mp:setVolume(0.2, 0.2)
                        mp:setLooping(true) -- फाइल खत्म होने पर अपने आप दोबारा शुरू हो जाएगी
                        mp:start()
                        local playMsg = LP("🎶 Playing: " .. selected.name, "🎶 बजना शुरू: " .. selected.name)
                        Toast.makeText(patchActivity, playMsg, 0).show()
                    end
                })
                
                _G.novaRadioPlayer:setOnErrorListener(MediaPlayer.OnErrorListener{
                    onError=function(mp, what, extra) 
                        Toast.makeText(patchActivity, LP("Audio Fail! Check Internet.", "ऑडियो फेल! इंटरनेट चेक करें।"), 0).show()
                        return true 
                    end
                })
            end)
            dlg.dismiss()
        end
    })
end
