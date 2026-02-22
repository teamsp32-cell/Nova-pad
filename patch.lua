-- 🌟 LIVE PATCH v19: FIND CRASH FIX + Bird Radio HTTPS + Multi-Select + Notice 🌟
import "android.media.MediaPlayer"
import "android.speech.tts.TextToSpeech"
import "java.util.Locale"
import "android.widget.Button"
import "android.view.View"
import "android.text.SpannableString"
import "android.text.style.BackgroundColorSpan"
import "java.lang.String"

-- 🔥 1. FORCE LOOP & STREAM AUDIO PLAYER
function controlAmbientAudio(url, title)
  if ambientPlayer then 
     pcall(function() ambientPlayer.stop() end)
     pcall(function() ambientPlayer.release() end)
     ambientPlayer = nil 
  end
  if url then
    Toast.makeText(activity, "Loading "..title.." ⏳", 0).show()
    ambientPlayer = MediaPlayer()
    ambientPlayer.setDataSource(url)
    ambientPlayer.setLooping(true) 
    ambientPlayer.setOnCompletionListener(MediaPlayer.OnCompletionListener{
        onCompletion=function(mp) mp.seekTo(0); mp.start() end
    })
    ambientPlayer.prepareAsync()
    ambientPlayer.setOnPreparedListener(MediaPlayer.OnPreparedListener{onPrepared=function(mp) mp.start(); Toast.makeText(activity, "Playing "..title.." 🎶", 0).show() end})
    ambientPlayer.setOnErrorListener(MediaPlayer.OnErrorListener{onError=function(mp, w, e) Toast.makeText(activity, "Stream failed. Link error!", 0).show(); return true end})
  else 
    Toast.makeText(activity, "Music Stopped ⏹️", 0).show() 
  end
end

-- 🎧 2. ULTIMATE MEDITATION & RADIO MENU (100% HTTPS Secure)
function showAmbientMenu()
    -- (यहाँ तुम्हारा रेडियो और मेडिटेशन मेनू वाला बाकी का कोड आएगा)
end

-- 🔍 3. HINDI TEXT SEARCH FIX (Normalizer + NFC)
function searchHindiWord(queryText)
    local success, errorMessage = pcall(function()
        
        -- Java की ज़रूरी क्लासेस को बुला रहे हैं
        local String = luajava.bindClass("java.lang.String")
        local Normalizer = luajava.bindClass("java.text.Normalizer")
        local Form = luajava.bindClass("java.text.Normalizer$Form")
        
        -- टेक्स्ट और सर्च वर्ड को लाना
        local rawText = noteEditor.getText().toString()
        local rawQuery = tostring(queryText)
        
        -- अगर लेख या सर्च बॉक्स खाली है तो वापस लौटें
        if rawText == nil or rawText == "" then
            Toast.makeText(activity, "लेख खाली है।", 0).show()
            return
        end
        if rawQuery == nil or rawQuery == "" then
            Toast.makeText(activity, "खोजने के लिए शब्द नहीं है।", 0).show()
            return
        end
        
        -- सबसे महत्वपूर्ण कदम: लेख और शब्द दोनों को एक ही यूनिकोड फॉर्मेट (NFC) में बदलना
        local normalizedText = Normalizer.normalize(rawText, Form.NFC)
        local normalizedQuery = Normalizer.normalize(rawQuery, Form.NFC)
        
        -- अब इन्हें Java String बनाना ताकि हम indexOf का इस्तेमाल कर सकें
        local javaText = String(normalizedText)
        local javaQuery = String(normalizedQuery)
        
        -- सर्च वर्ड से फालतू अदृश्य अक्षर (Zero Width Space आदि) हटाना और स्पेस साफ करना
        javaQuery = javaQuery:replaceAll("[\u200B\uFEFF\u200C\u200D]", ""):trim()
        
        -- खोजना शुरू करना
        local startIndex = javaText:indexOf(javaQuery)
        
        -- अगर शब्द मिल जाता है
        if startIndex ~= -1 then
            local wordLength = javaQuery:length()
            local endIndex = startIndex + wordLength
            
            noteEditor.setSelection(startIndex, endIndex)
            noteEditor.requestFocus()
            Toast.makeText(activity, "शब्द मिल गया!", 0).show()
        else
            Toast.makeText(activity, "नो टेक्स्ट फाउंड (शब्द नहीं मिला)।", 0).show()
        end
        
    end)

    if not success then
        -- अगर कोई एरर आता है तो वह भी टोस्ट के रूप में दिखेगा
        Toast.makeText(activity, "सर्च एरर: " .. tostring(errorMessage), 1).show()
    end
end
