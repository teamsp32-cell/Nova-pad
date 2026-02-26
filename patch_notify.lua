-- 🚀 NOVA PAD - AUTO POP-UP NOTIFICATION (System Language Detector) 🚀

require "import"
import "android.app.AlertDialog"
import "java.util.Locale" -- 🔥 THE FIX: फोन की असली भाषा पकड़ने वाला टूल

-- 🌍 1. भाषा का ऑटो-डिटेक्शन
local lang = _G.appLanguage

-- अगर ऐप का वेरिएबल खाली है, तो फोन की सिस्टम भाषा (System Language) निकालो
if not lang or lang == "" then
    local sysLang = tostring(Locale.getDefault().getLanguage())
    if sysLang == "hi" then
        lang = "hi"
    else
        lang = "en" -- हिंदी छोड़कर बाकी पूरी दुनिया के लिए इंग्लिश
    end
end

-- 🌍 2. डिक्शनरी
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

-- बटन का टेक्स्ट भी भाषा के हिसाब से
local btnText = "Awesome!"
if lang == "hi" then btnText = "कमाल है!" end

-- 🔥 3. पॉप-अप दिखाना
pcall(function()
    local dlg = AlertDialog.Builder(activity)
    dlg.setTitle(finalTitle)
    dlg.setMessage(finalMessage)
    dlg.setPositiveButton(btnText, nil)
    dlg.show()
end)
