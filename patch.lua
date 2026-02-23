-- Nova Pad v2.9 - Live Patch (OTA)
-- Safe TTS Click Handler & 100% Accurate Language Fix

pcall(function()
    local patchActivity = activity
    local rootDirPatch = patchActivity.getExternalFilesDir(nil).toString() .. "/"

    -- 🌟 100% SAFE LANGUAGE CHECKER FOR PATCH
    local function getPatchLang()
        local lang = "en"
        local f = io.open(rootDirPatch .. "lang_pref.txt", "r")
        if f then
            local content = f:read("*a")
            f:close()
            if content and content:match("hi") then lang = "hi" end
        end
        return lang
    end

    local function LP(en, hi)
        return (getPatchLang() == "hi") and hi or en
    end

    -- 1. 'Trans 🌐' बटन को बदलकर 'Listen 🗣️' कर रहे हैं (भाषा के हिसाब से)
    btnReaderTranslate.setText(LP("Listen 🗣️", "सुनें 🗣️"))
    btnReaderTranslate.setTextColor(0xFF4CAF50)

    -- 2. क्लिक लॉजिक
    btnReaderTranslate.onClick = function()
        local ok, err = pcall(function()
            local textToRead = ""
            
            -- पैराग्राफ या फुल टेक्स्ट मोड से टेक्स्ट निकालना
            if paraList.getVisibility() == 0 then
                local adapter = paraList.getAdapter()
                if adapter then
                    for i = 0, adapter.getCount() - 1 do
                        textToRead = textToRead .. tostring(adapter.getItem(i)) .. "\n"
                    end
                end
            else
                textToRead = readerBody.getText().toString()
            end
            
            -- बैकअप (अगर रीडर खाली मिले)
            if textToRead == nil or textToRead == "" then
                textToRead = noteEditor.getText().toString()
            end
            
            if textToRead == nil or textToRead == "" then
                Toast.makeText(patchActivity, LP("Nothing to read!", "पढ़ने के लिए कुछ नहीं मिला!"), 0).show()
                return
            end
            
            -- 🌐 सही भाषा में ऑप्शंस
            local ttsOpts = {
                LP("🇮🇳 Read in Hindi", "🇮🇳 हिंदी में पढ़ें"), 
                LP("🇬🇧 Read in English", "🇬🇧 English में पढ़ें"), 
                LP("⚙️ Voice Settings (Phone)", "⚙️ आवाज़ की सेटिंग"), 
                LP("⏹️ Stop Reading", "⏹️ पढ़ना बंद करें")
            }
            
            showNovaMenu(LP("TTS Options", "TTS विकल्प"), ttsOpts, function(tIdx)
                if tIdx == 2 then 
                    pcall(function() patchActivity.startActivity(Intent("com.android.settings.TTS_SETTINGS")) end)
                elseif tIdx == 3 then 
                    if reader_tts_player then reader_tts_player.stop() end
                    Toast.makeText(patchActivity, LP("Stopped Reading ⏹️", "पढ़ना बंद किया ⏹️"), 0).show()
                else
                    Toast.makeText(patchActivity, LP("Starting Reader... 🗣️", "रीडर शुरू हो रहा है... 🗣️"), 0).show()
                    local loc = (tIdx == 1) and java.util.Locale("en", "US") or java.util.Locale("hi", "IN")
                    
                    if reader_tts_player == nil then 
                        import "android.speech.tts.TextToSpeech"
                        reader_tts_player = TextToSpeech(patchActivity, TextToSpeech.OnInitListener{
                            onInit = function(status) 
                                if status == TextToSpeech.SUCCESS then 
                                    reader_tts_player.setLanguage(loc)
                                    reader_tts_player.speak(textToRead, TextToSpeech.QUEUE_FLUSH, nil) 
                                end 
                            end
                        }) 
                    else 
                        reader_tts_player.setLanguage(loc)
                        reader_tts_player.speak(textToRead, TextToSpeech.QUEUE_FLUSH, nil) 
                    end
                end
            end)
        end)
        
        if not ok then
            Toast.makeText(patchActivity, "Patch Error: " .. tostring(err), 1).show()
        end
    end

    -- 3. स्मार्ट पॉपअप (एकदम सही भाषा के साथ)
    local patchLockFile = rootDirPatch .. "tts_patch_seen_langfix.lock"
    local f_lock = io.open(patchLockFile, "r")
    if not f_lock then
        AlertDialog.Builder(patchActivity)
        .setTitle(LP("🎉 New Feature Added!", "🎉 नया फीचर जुड़ा!"))
        .setMessage(LP("You can now listen to your notes in Reader Mode.\n\nThe 'Trans' button at the top is now the 'Listen 🗣️' button!", "अब आप 'रीड मोड' में अपने नोट्स को सुन भी सकते हैं।\n\nऊपर दिए गए 'Trans' बटन को अब 'Listen 🗣️' में बदल दिया गया है!"))
        .setPositiveButton(LP("Awesome!", "बहुत बढ़िया!"), function()
            local fw = io.open(patchLockFile, "w")
            if fw then fw:write("seen"); fw:close() end
        end)
        .setCancelable(false)
        .show()
    else
        f_lock:close()
    end
end)
