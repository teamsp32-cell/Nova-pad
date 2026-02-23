-- Nova Pad v2.9 - Live Patch (OTA)
-- Ultimate Async TTS Fix & Error Catcher

pcall(function()
    local patchActivity = activity
    local rootDirPatch = patchActivity.getExternalFilesDir(nil).toString() .. "/"

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
                        
                        -- 🔥 इंजन के अंदर का नया सेफ जाल (Async Catcher) 🔥
                        local function safeSpeak(ttsObj)
                            local sOk, sErr = pcall(function()
                                -- QUEUE_FLUSH की जगह सीधा 0 लगा दिया, यह 100% सेफ है
                                ttsObj.speak(textToRead, 0, nil)
                            end)
                            if not sOk then
                                local errInput = EditText(patchActivity)
                                errInput.setText(tostring(sErr))
                                errInput.setTextIsSelectable(true)
                                AlertDialog.Builder(patchActivity)
                                .setTitle(LP("TTS Engine Error (Copy this)", "TTS इंजन क्रैश (इसे कॉपी करें)"))
                                .setView(errInput)
                                .setPositiveButton("OK", nil)
                                .show()
                            end
                        end

                        local loc = (tIdx == 1) and java.util.Locale("en", "US") or java.util.Locale("hi", "IN")
                        
                        if reader_tts_player == nil then 
                            import "android.speech.tts.TextToSpeech"
                            reader_tts_player = TextToSpeech(patchActivity, TextToSpeech.OnInitListener{
                                onInit = function(status) 
                                    if status == TextToSpeech.SUCCESS then 
                                        reader_tts_player.setLanguage(loc)
                                        safeSpeak(reader_tts_player)
                                    else
                                        Toast.makeText(patchActivity, "TTS Engine Load Failed!", 0).show()
                                    end 
                                end
                            }) 
                        else 
                            reader_tts_player.setLanguage(loc)
                            safeSpeak(reader_tts_player)
                        end
                    end
                end)
            end)
            
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
end)
