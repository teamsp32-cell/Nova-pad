-- Nova Pad v2.9 - Live Patch (OTA)
-- Feature: Reader Mode TTS Engine with Announcement Popup

pcall(function()
    -- ==========================================
    -- 1. नया "Listen 🗣️" बटन जोड़ने का लॉजिक
    -- ==========================================
    if not _G.isReaderTTSAdded then
        _G.isReaderTTSAdded = true
        
        local ttsBtn = Button(activity)
        ttsBtn.setText(L("Listen 🗣️", "सुनें 🗣️"))
        ttsBtn.setTextSize(10)
        ttsBtn.setTextColor(0xFF4CAF50) -- हरा रंग ताकि अलग से दिखे
        ttsBtn.setTypeface(android.graphics.Typeface.DEFAULT_BOLD)
        
        local params = LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.WRAP_CONTENT, 
            LinearLayout.LayoutParams.WRAP_CONTENT, 
            1.0
        )
        ttsBtn.setLayoutParams(params)
        
        -- 'readerBar' (ऊपर वाली पट्टी) में 5वें नंबर पर (Share के बगल में) जोड़ रहे हैं
        readerBar.addView(ttsBtn, 5)
        
        ttsBtn.setOnClickListener(View.OnClickListener{
            onClick = function()
                local textToRead = currentFullText
                if textToRead == nil or #textToRead == 0 then
                    Toast.makeText(activity, L("Nothing to read!", "पढ़ने के लिए कुछ नहीं है!"), 0).show()
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
                        pcall(function() activity.startActivity(Intent("com.android.settings.TTS_SETTINGS")) end)
                    elseif tIdx == 3 then 
                        if reader_tts_player then reader_tts_player.stop() end
                        Toast.makeText(activity, L("Stopped Reading ⏹️", "पढ़ना बंद किया ⏹️"), 0).show()
                    else
                        Toast.makeText(activity, L("Starting Reader... 🗣️", "रीडर शुरू हो रहा है... 🗣️"), 0).show()
                        local loc = (tIdx == 1) and Locale("en", "US") or Locale("hi", "IN")
                        
                        if reader_tts_player == nil then 
                            import "android.speech.tts.TextToSpeech"
                            reader_tts_player = TextToSpeech(activity, TextToSpeech.OnInitListener{
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
    local patchLockFile = rootDir .. "tts_patch_seen.lock"
    local f_lock = io.open(patchLockFile, "r")
    
    if not f_lock then
        -- अगर यूज़र ने यह पॉपअप पहले नहीं देखा है, तो उसे दिखाओ
        AlertDialog.Builder(activity)
        .setTitle(L("🎉 New Feature Added!", "🎉 नया फीचर जुड़ा!"))
        .setMessage(L("Great news! You can now listen to your notes in Reader Mode.\n\nJust open any note in 'Read Mode' and click the new 'Listen 🗣️' button at the top!", "खुशखबरी! अब आप 'रीड मोड' में अपने नोट्स को सुन भी सकते हैं।\n\nकोई भी नोट 'रीड मोड' में खोलें और ऊपर दिए गए नए 'सुनें 🗣️' बटन पर क्लिक करें!"))
        .setPositiveButton(L("Awesome!", "बहुत बढ़िया!"), function()
            -- बटन दबाते ही लॉक फाइल बना दो, ताकि दोबारा न दिखे
            local fw = io.open(patchLockFile, "w")
            if fw then fw:write("seen"); fw:close() end
        end)
        .setCancelable(false)
        .show()
    else
        f_lock:close()
    end
end)
