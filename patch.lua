-- Nova Pad v2.9 - Live Patch (OTA)
-- Feature: Reader Mode TTS Engine with Popup (Local Variable Fix)

pcall(function()
    -- लोकल डायरेक्टरी का रास्ता खुद निकाल रहे हैं ताकि एरर न आए
    local patchActivity = activity
    local rootDirPatch = patchActivity.getExternalFilesDir(nil).toString() .. "/"

    -- ==========================================
    -- 1. "Listen 🗣️" बटन जोड़ने का लॉजिक
    -- ==========================================
    if not _G.isReaderTTSAdded then
        _G.isReaderTTSAdded = true
        
        local ttsBtn = Button(patchActivity)
        ttsBtn.setText(L("Listen 🗣️", "सुनें 🗣️"))
        ttsBtn.setTextSize(10)
        ttsBtn.setTextColor(0xFF4CAF50) -- हरा रंग
        ttsBtn.setTypeface(android.graphics.Typeface.DEFAULT_BOLD)
        
        local params = LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.WRAP_CONTENT, 
            LinearLayout.LayoutParams.WRAP_CONTENT, 
            1.0
        )
        ttsBtn.setLayoutParams(params)
        
        -- 'Share' बटन के बगल में जोड़ रहे हैं
        readerBar.addView(ttsBtn, 5)
        
        ttsBtn.setOnClickListener(View.OnClickListener{
            onClick = function()
                -- स्क्रीन (UI) से सीधा टेक्स्ट निकाल रहे हैं (Local variable का चक्कर ख़त्म)
                local textToRead = ""
                if scrollFullText.getVisibility() == 0 then
                    textToRead = readerBody.getText().toString()
                elseif paraList.getVisibility() == 0 then
                    local adapter = paraList.getAdapter()
                    if adapter then
                        for i = 0, adapter.getCount() - 1 do
                            textToRead = textToRead .. adapter.getItem(i) .. "\n"
                        end
                    end
                end
                
                if textToRead == nil or textToRead == "" then
                    Toast.makeText(patchActivity, L("Nothing to read!", "पढ़ने के लिए कुछ नहीं है!"), 0).show()
                    return
                end
                
                local ttsOpts = {
                    L("🇮🇳 Read in Hindi", "🇮🇳 हिंदी में पढ़ें"), 
                    L("🇬🇧 Read in English", "🇬🇧 इंग्लिश में पढ़ें"), 
                    L("⚙️ Voice Settings (Phone)", "⚙️ आवाज़ की सेटिंग"), 
                    L("⏹️ Stop Reading", "⏹️ पढ़ना बंद करें")
                }
                
                showNovaMenu(L("TTS Options", "TTS विकल्प"), ttsOpts, function(tIdx)
                    if tIdx == 2 then 
                        pcall(function() patchActivity.startActivity(Intent("com.android.settings.TTS_SETTINGS")) end)
                    elseif tIdx == 3 then 
                        if reader_tts_player then reader_tts_player.stop() end
                        Toast.makeText(patchActivity, L("Stopped Reading ⏹️", "पढ़ना बंद किया ⏹️"), 0).show()
                    else
                        Toast.makeText(patchActivity, L("Starting Reader... 🗣️", "रीडर शुरू हो रहा है... 🗣️"), 0).show()
                        local loc = (tIdx == 1) and Locale("en", "US") or Locale("hi", "IN")
                        
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
            end
        })
    end

    -- ==========================================
    -- 2. स्मार्ट वन-टाइम पॉपअप (Smart One-Time Popup)
    -- ==========================================
    local patchLockFile = rootDirPatch .. "tts_patch_seen.lock"
    local f_lock = io.open(patchLockFile, "r")
    
    if not f_lock then
        AlertDialog.Builder(patchActivity)
        .setTitle(L("🎉 New Feature Added!", "🎉 नया फीचर जुड़ा!"))
        .setMessage(L("Great news! You can now listen to your notes in Reader Mode.\n\nJust open any note in 'Read Mode' and click the new 'Listen 🗣️' button at the top!", "खुशखबरी! अब आप 'रीड मोड' में अपने नोट्स को सुन भी सकते हैं।\n\nकोई भी नोट 'रीड मोड' में खोलें और ऊपर दिए गए नए 'सुनें 🗣️' बटन पर क्लिक करें!"))
        .setPositiveButton(L("Awesome!", "बहुत बढ़िया!"), function()
            local fw = io.open(patchLockFile, "w")
            if fw then fw:write("seen"); fw:close() end
        end)
        .setCancelable(false)
        .show()
    else
        f_lock:close()
    end
end)
