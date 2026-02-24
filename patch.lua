-- Nova Pad v2.9 - Live Patch (Stable)
-- TTS Enabled + Find Button in Maintenance

local patchActivity = activity
local rootDirPatch = patchActivity.getExternalFilesDir(nil).toString() .. "/"

-- 🌟 SHARED UTILITIES 🌟
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

local function showErrorBox(title, msg)
    local errInput = EditText(patchActivity)
    errInput.setText(tostring(msg))
    errInput.setTextIsSelectable(true)
    AlertDialog.Builder(patchActivity)
    .setTitle(title .. " (Copy this)")
    .setView(errInput)
    .setPositiveButton("OK", nil)
    .show()
end

pcall(function()
    -- ==========================================
    -- 🔥 1. LISTEN (TTS) BUTTON (100% वर्किंग) 🔥
    -- ==========================================
    btnReaderTranslate.setText(LP("Listen 🗣️", "सुनें 🗣️"))
    btnReaderTranslate.setTextColor(0xFF4CAF50)

    -- पुराने "AI Translator" वाले मेसेज को पूरी तरह ओवरराइट कर रहे हैं
    btnReaderTranslate.setOnClickListener(View.OnClickListener{
        onClick = function()
            local ok1, err1 = pcall(function()
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
                
                _G.patch_tts_text = textToRead
                
                local ttsOpts = {
                    LP("🇮🇳 Read in Hindi", "🇮🇳 हिंदी में पढ़ें"), 
                    LP("🇬🇧 Read in English", "🇬🇧 English में पढ़ें"), 
                    LP("⚙️ Voice Settings", "⚙️ आवाज़ की सेटिंग"), 
                    LP("⏹️ Stop Reading", "⏹️ पढ़ना बंद करें")
                }
                
                showNovaMenu(LP("TTS Options", "TTS विकल्प"), ttsOpts, function(tIdx)
                    local ok2, err2 = pcall(function()
                        if tIdx == 2 then 
                            patchActivity.startActivity(Intent("com.android.settings.TTS_SETTINGS"))
                        elseif tIdx == 3 then 
                            if _G.reader_tts_player then _G.reader_tts_player.stop() end
                            Toast.makeText(patchActivity, LP("Stopped Reading ⏹️", "पढ़ना बंद किया ⏹️"), 0).show()
                        else
                            Toast.makeText(patchActivity, LP("Starting Reader... 🗣️", "रीडर शुरू हो रहा है... 🗣️"), 0).show()
                            import "java.util.Locale"
                            local loc = (tIdx == 1) and Locale("en", "US") or Locale("hi", "IN")
                            
                            if _G.reader_tts_player == nil then 
                                import "android.speech.tts.TextToSpeech"
                                _G.reader_tts_player = TextToSpeech(patchActivity, TextToSpeech.OnInitListener{
                                    onInit = function(status) 
                                        local ok3, err3 = pcall(function()
                                            if status == 0 then 
                                                _G.reader_tts_player.setLanguage(loc)
                                                _G.reader_tts_player.speak(_G.patch_tts_text, 0, nil) 
                                            else
                                                Toast.makeText(patchActivity, "TTS Engine Error", 0).show()
                                            end
                                        end)
                                        if not ok3 then showErrorBox("Engine Error", err3) end
                                    end
                                }) 
                            else 
                                _G.reader_tts_player.setLanguage(loc)
                                _G.reader_tts_player.speak(_G.patch_tts_text, 0, nil)
                            end
                        end
                    end)
                    if not ok2 then showErrorBox("Menu Error", err2) end
                end)
            end)
            if not ok1 then showErrorBox("Click Error", err1) end
        end
    })

    -- ==========================================
    -- 🛠️ 2. FIND BUTTON (MAINTENANCE MODE) 🛠️
    -- ==========================================
    btnReaderSearch.setOnClickListener(View.OnClickListener{
        onClick = function(v)
            Toast.makeText(patchActivity, LP("Find feature is under maintenance 🛠️", "सर्च फीचर अभी मेंटेनेंस में है 🛠️"), 1).show()
        end
    })
end)
