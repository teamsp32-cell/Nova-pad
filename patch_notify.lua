-- Nova Pad - Notification System Module

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
    -- 🔥 जब भी नया मैसेज भेजना हो, इस ID को बदल देना (जैसे "MSG_002") 🔥
    local notify_id = "MSG_001" 
    local lockFile = rootDirPatch .. "notify_" .. notify_id .. ".lock"
    
    local f_lock = io.open(lockFile, "r")
    if not f_lock then
        -- यहाँ अपना संदेश लिखो
        local msgTitle = LP("🎉 Important Update!", "🎉 ज़रूरी सूचना!")
        local msgBody = LP(
            "Hello Users!\n\n1. The TTS (Listen) feature is now fully stable.\n2. The 'Find' feature is currently under maintenance and will be back soon.\n\nThank you for using Nova Pad!", 
            "नमस्ते यूज़र्स!\n\n1. अब 'सुनें' (TTS) बटन पूरी तरह से काम कर रहा है।\n2. 'खोजें' (Find) बटन अभी मेंटेनेंस में है और जल्द ही वापस आएगा।\n\nNova Pad इस्तेमाल करने के लिए धन्यवाद!"
        )

        AlertDialog.Builder(patchActivity)
        .setTitle(msgTitle)
        .setMessage(msgBody)
        .setPositiveButton(LP("Got it!", "समझ गया!"), function()
            -- यह लाइन सुनिश्चित करेगी कि यह मैसेज यूज़र को दोबारा न दिखे
            local fw = io.open(lockFile, "w")
            if fw then fw:write("seen"); fw:close() end
        end)
        .setCancelable(false)
        .show()
    else
        f_lock:close()
    end
end)

