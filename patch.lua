-- Nova Pad v2.9 - Live Patch (OTA)
-- Ultimate Async TTS Fix (No Memory Loss)

pcall(function()
    local patchActivity = activity
    local rootDirPatch = patchActivity.getExternalFilesDir(nil).toString() .. "/"

    -- 🌟 100% SAFE LANGUAGE CHECKER
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

    btnReaderTranslate.setText(LP("Listen 🗣️", "सुनें 🗣️"))
    btnReaderTranslate.setTextColor(0xFF4CAF50)

    btnReaderTranslate.setOnClickListener(View.OnClickListener{
        onClick = function()
            local textToRead = ""
            
            -- सेफ तरीके से टेक्स्ट निकालना
            if paraList and paraList.getVisibility() == 0 then
                local adapter = paraList.getAdapter()
                if adapter then
                    for i = 0, adapter.getCount() - 1 do
                        textToRead = textToRead .. tostring(adapter.getItem(i)) .. "\n"
                    end
                end
            elseif readerBody then
                textToRead = tostring(readerBody.getText() or "")
            end
            
            if textToRead == nil or textToRead == "" then
                if noteEditor then textToRead = tostring(noteEditor.getText() or "") end
            end
            
            if textToRead == nil or textToRead == "" then
                Toast.makeText(patchActivity, LP("Nothing to read!", "पढ़ने के लिए कुछ नहीं मिला!"), 0).show()
                return
            end
            
            -- 🔥 टेक्स्ट को 'ग्लोबल' बना दिया ताकि मेमोरी से डिलीट न हो!
            _G.patch_tts_text = textToRead
            
            local ttsOpts = {
                LP("🇮🇳 Read in Hindi", "🇮🇳 हिंदी में पढ़ें"), 
                LP("🇬🇧 Read in English", "🇬🇧 English में पढ़ें"), 
                LP("⚙️ Voice Settings", "⚙️ आवाज़ की सेटिंग"), 
                LP("⏹️ Stop Reading", "⏹️ पढ़ना बंद करें")
            }
            
            showNovaMenu(LP("TTS Options", "TTS विकल्प"), ttsOpts, function(tIdx)
                if tIdx == 2 then 
                    pcall(function() patchActivity.startActivity(Intent("com.android.settings.TTS_SETTINGS")) end)
                elseif tIdx == 3 then 
                    if _G.reader_tts_player then _G.reader_tts_player.stop() end
                    Toast.makeText(patchActivity, LP("Stopped Reading ⏹️", "पढ़ना बंद किया ⏹️"), 0).show()
                else
                    Toast.makeText(patchActivity, LP("Starting Reader... 🗣️", "रीडर शुरू हो रहा है... 🗣️"), 0).show()
                    
                    local loc = (tIdx == 1) and java.util.Locale("en", "US") or java.util.Locale("hi", "IN")
                    
                    if _G.reader_tts_player == nil then 
                        import "android.speech.tts.TextToSpeech"
                        -- 🔥 सबसे सेफ TTS इनिशियलाइज़ेशन (बिना इंटरफ़ेस प्रॉक्सी के)
                        _G.reader_tts_player = TextToSpeech(patchActivity, function(status)
                            if status == 0 then -- 0 मतलब SUCCESS
                                _G.reader_tts_player.setLanguage(loc)
                                _G.reader_tts_player.speak(_G.patch_tts_text, 0, nil) -- 0 मतलब QUEUE_FLUSH
                            else
                                Toast.makeText(patchActivity, "TTS Load Error!", 0).show()
                            end
                        end)
                    else 
                        _G.reader_tts_player.setLanguage(loc)
                        _G.reader_tts_player.speak(_G.patch_tts_text, 0, nil)
                    end
                end
            end)
        end
    })
    
    -- पॉपअप (नाम बदल दिया है ताकि दोबारा टेस्ट कर सको)
    local patchLockFile = rootDirPatch .. "tts_patch_final.lock"
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
