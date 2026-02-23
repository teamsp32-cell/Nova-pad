-- Nova Pad v2.9 - Live Patch (OTA)
-- Safe TTS Click Handler & toString() Fix

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

    btnReaderTranslate.setText(LP("Listen 🗣️", "सुनें 🗣️"))
    btnReaderTranslate.setTextColor(0xFF4CAF50)

    btnReaderTranslate.setOnClickListener(View.OnClickListener{
        onClick = function()
            local ok, err = pcall(function()
                local textToRead = ""
                
                -- सेफ तरीके से टेक्स्ट निकाल रहे हैं
                if paraList and paraList.getVisibility() == 0 then
                    local adapter = paraList.getAdapter()
                    if adapter then
                        for i = 0, adapter.getCount() - 1 do
                            textToRead = textToRead .. tostring(adapter.getItem(i)) .. "\n"
                        end
                    end
                elseif readerBody then
                    -- 🔥 FIX: .toString() हटा दिया, अब लुआ का सेफ tostring() यूज़ कर रहे हैं
                    textToRead = tostring(readerBody.getText() or "")
                end
                
                -- बैकअप
                if textToRead == nil or textToRead == "" then
                    if noteEditor then textToRead = tostring(noteEditor.getText() or "") end
                end
                
                if textToRead == nil or textToRead == "" then
                    Toast.makeText(patchActivity, LP("Nothing to read!", "पढ़ने के लिए कुछ नहीं मिला!"), 0).show()
                    return
                end
                
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
            
            -- अगर फिर भी क्रैश हुआ तो डायलॉग बॉक्स आएगा
            if not ok then
                local errInput = EditText(patchActivity)
                errInput.setText(tostring(err))
                errInput.setTextIsSelectable(true)
                AlertDialog.Builder(patchActivity)
                .setTitle(LP("Patch Error (Copy this)", "पैच एरर (इसे कॉपी करें)"))
                .setView(errInput)
                .setPositiveButton("OK", nil)
                .show()
            end
        end
    })

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
