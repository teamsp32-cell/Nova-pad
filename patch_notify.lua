-- 🚀 NOVA PAD - ONE-TIME AUTO NOTIFICATION 🚀

require "import"
import "android.app.AlertDialog"
import "java.util.Locale"
import "android.content.Context"

-- 🔥 1. अपडेट का वर्ज़न (जब भी नया अपडेट दो, इस नंबर को 3 से 4, 4 से 5 कर देना)
local update_version_code = 3 

-- 🧠 2. फोन की 'याददाश्त' चेक करना (SharedPreferences)
local prefs = activity.getSharedPreferences("NovaPadUpdateMemory", Context.MODE_PRIVATE)
local last_seen_version = prefs.getInt("seen_version", 0)

-- अगर यूज़र ने यह वर्ज़न पहले ही देख लिया है, तो कोड यहीं रुक जाएगा (कोई पॉप-अप नहीं आएगा)
if last_seen_version >= update_version_code then
    return 
end

-- 🌍 3. भाषा का ऑटो-डिटेक्शन
local lang = _G.appLanguage
if not lang or lang == "" then
    local sysLang = tostring(Locale.getDefault().getLanguage())
    if sysLang == "hi" then lang = "hi" else lang = "en" end
end

-- 🌍 4. डिक्शनरी
local titles = {
    hi = "🎉 Nova Pad का नया 'प्रो' अपडेट!",
    en = "🎉 Nova Pad 'Pro' Update is Here!"
}

local messages = {
    hi = "नमस्कार साथियों! Nova Pad को और भी शानदार बनाने के लिए हमने कुछ धांसू फीचर्स जोड़े हैं:\n\n" ..
         "🔄 स्मार्ट फाइंड एंड रिप्लेस: अब एक क्लिक में पूरी कहानी के शब्द बदलें।\n" ..
         "📋 मल्टी-स्लॉट क्लिपबोर्ड: एक साथ 3 अलग-अलग टेक्स्ट कॉपी, पेस्ट और शेयर करें।\n" ..
         "🥷 प्राइवेसी कर्टेन (Black Screen): स्क्रीन को 100% काला करके लिखें।\n" ..
         "🔊 वॉल्यूम कर्सर: वॉल्यूम बटन से कर्सर ऊपर-नीचे खिसकाएं।\n\n" ..
         "स्मार्ट टूल्स में जाकर अभी आज़माएं!",
         
    en = "Hello friends! We've added some advanced features to make Nova Pad even better:\n\n" ..
         "🔄 Smart Find & Replace: Bulk word changing.\n" ..
         "📋 Multi-Slot Clipboard: Copy & save 3 texts at once.\n" ..
         "🥷 Privacy Curtain: 100% black screen for typing privacy.\n" ..
         "🔊 Volume Cursor: Move cursor with volume keys.\n\n" ..
         "Check them out in Smart Tools!"
}

local finalTitle = titles[lang] or titles["en"]
local finalMessage = messages[lang] or messages["en"]

local btnText = "Awesome!"
if lang == "hi" then btnText = "कमाल है!" end

-- 🔥 5. पॉप-अप दिखाना और 'मेमोरी' में सेव करना
pcall(function()
    local dlg = AlertDialog.Builder(activity)
    dlg.setTitle(finalTitle)
    dlg.setMessage(finalMessage)
    
    -- जब यूज़र बटन दबाएगा, तो मेमोरी में सेव हो जाएगा कि उसने यह वर्ज़न देख लिया है
    dlg.setPositiveButton(btnText, function()
        local editor = prefs.edit()
        editor.putInt("seen_version", update_version_code)
        editor.apply()
    end)
    
    -- अगर यूज़र बाहर क्लिक करके पॉप-अप हटा दे, तब भी सेव कर लो ताकि बार-बार न आए
    dlg.setOnCancelListener{
        onCancel = function(dialog)
            local editor = prefs.edit()
            editor.putInt("seen_version", update_version_code)
            editor.apply()
        end
    }
    
    dlg.show()
end)
