-- Nova Pad - Notification System Module (Update 002)

local patchActivity = activity
local rootDirPatch = patchActivity.getExternalFilesDir(nil).toString() .. "/"

-- भाषा चेक 
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

pcall(function()
    -- 🔥 नया मैसेज ID: MSG_002 🔥
    local notify_id = "MSG_002" 
    local lockFile = rootDirPatch .. "notify_" .. notify_id .. ".lock"
    
    local f_lock = io.open(lockFile, "r")
    if not f_lock then
        -- यहाँ नया और प्रोफेशनल रिलीज़ नोट (Release Notes) है
        local msgTitle = LP("🚀 New Feature: Smart Search!", "🚀 नया अपडेट: स्मार्ट खोज!")
        local msgBody = LP(
            "Great news! The 'Find' feature is back and is now smarter than ever.\n\n✨ What's New:\n• Screen Reader Optimized: Fully accessible with automatic voice announcements for search results.\n• Direct Jump: Just type or say 'Para 10' or 'Line 5' to jump directly to that location!\n• Smart Voice Search: Perfectly handles voice typing inputs and accurately finds text.\n\nEnjoy the upgraded Nova Pad!", 
            "खुशखबरी! 'Find' (खोजें) बटन वापस आ गया है और अब यह पहले से कहीं ज्यादा स्मार्ट है।\n\n✨ नया क्या है:\n• स्क्रीन रीडर सपोर्ट: सर्च रिज़ल्ट्स की ऑटोमैटिक अनाउंसमेंट के साथ, यह पूरी तरह से एक्सेसिबल है।\n• डायरेक्ट जम्प: सीधे किसी जगह जाने के लिए बस टाइप करें या बोलें 'पैराग्राफ 10' या 'लाइन 5'!\n• स्मार्ट वॉइस सर्च: वॉइस टाइपिंग के साथ एकदम सटीक काम करता है और शब्दों को आसानी से खोजता है।\n\nअपग्रेड किए गए Nova Pad का आनंद लें!"
        )

        AlertDialog.Builder(patchActivity)
        .setTitle(msgTitle)
        .setMessage(msgBody)
        .setPositiveButton(LP("Awesome!", "बहुत बढ़िया!"), function()
            local fw = io.open(lockFile, "w")
            if fw then fw:write("seen"); fw:close() end
        end)
        .setCancelable(false)
        .show()
    else
        f_lock:close()
    end
end)
