-- Nova Pad v2.9 - Live Patch (OTA)
-- Replace 'Trans' button with 'Listen (TTS)'

local ok, err = pcall(function()
    local patchActivity = activity
    local rootDirPatch = patchActivity.getExternalFilesDir(nil).toString() .. "/"

    -- 1. 'Trans 🌐' बटन को बदलकर 'Listen 🗣️' कर रहे हैं (यह 100% काम करेगा)
    btnReaderTranslate.setText("Listen 🗣️")
    btnReaderTranslate.setTextColor(0xFF4CAF50) -- हरा रंग

    -- 2. बटन दबाने पर पढ़ने वाला लॉजिक
    btnReaderTranslate.setOnClickListener(View.OnClickListener{
        onClick = function()
            local textToRead = ""
            -- टेक्स्ट निकाल रहे हैं
            if scrollFullText.getVisibility() == 0 then
                textToRead = readerBody.getText().toString()
            elseif paraList.getVisibility() == 0 then
                local adapter = paraList.getAdapter()
                if adapter then
                    for i = 0, adapter.getCount() - 1 do
                        textToRead = textToRead .. tostring(adapter.getItem(i)) .. "\n"
                    end
                end
            end
            
            if textToRead == nil or textToRead == "" then
                Toast.makeText(patchActivity, "पढ़ने के लिए कुछ नहीं है!", 0).show()
                return
            end
            
            local ttsOpts = {"🇮🇳 हिंदी में पढ़ें", "🇬🇧 English में पढ़ें", "⚙️ आवाज़ की सेटिंग", "⏹️ पढ़ना बंद करें"}
            
            showNovaMenu("TTS विकल्प", ttsOpts, function(tIdx)
                if tIdx == 2 then 
                    pcall(function() patchActivity.startActivity(Intent("com.android.settings.TTS_SETTINGS")) end)
                elseif tIdx == 3 then 
                    if reader_tts_player then reader_tts_player.stop() end
                    Toast.makeText(patchActivity, "पढ़ना बंद किया ⏹️", 0).show()
                else
                    Toast.makeText(patchActivity, "रीडर शुरू हो रहा है... 🗣️", 0).show()
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

    -- 3. स्मार्ट पॉपअप
    local patchLockFile = rootDirPatch .. "tts_patch_seen2.lock"
    local f_lock = io.open(patchLockFile, "r")
    if not f_lock then
        AlertDialog.Builder(patchActivity)
        .setTitle("🎉 नया फीचर जुड़ा!")
        .setMessage("अब आप 'रीड मोड' में अपने नोट्स को सुन भी सकते हैं।\n\nऊपर दिए गए 'Trans' बटन को अब 'Listen 🗣️' में बदल दिया गया है!")
        .setPositiveButton("OK", function()
            local fw = io.open(patchLockFile, "w")
            if fw then fw:write("seen"); fw:close() end
        end)
        .setCancelable(false)
        .show()
    else
        f_lock:close()
    end
end)

-- अगर पैच में कोई एरर होगा, तो स्क्रीन पर दिखेगा
if not ok then
    Toast.makeText(activity, "Patch Error: " .. tostring(err), 1).show()
end
