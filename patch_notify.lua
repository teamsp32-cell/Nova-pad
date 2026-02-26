-- 🚀 NOVA PAD - AUTO POP-UP NOTIFICATION (Cloud Master) 🚀

require "import"
import "android.app.AlertDialog"

-- 🌍 1. यूज़र की सेट की हुई भाषा (Language) चेक करें
local lang = _G.appLanguage or "hi" 

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

-- 🔥 2. THE FIX: जैसे ही मास्टर इस फाइल को पढ़ेगा, यह डायलॉग तुरंत स्क्रीन पर आ जाएगा!
pcall(function()
    local dlg = AlertDialog.Builder(activity)
    dlg.setTitle(finalTitle)
    dlg.setMessage(finalMessage)
    dlg.setPositiveButton("कमाल है! (Awesome)", nil)
    dlg.show()
end)
