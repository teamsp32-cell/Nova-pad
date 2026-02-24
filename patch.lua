-- Nova Pad v2.9 - Live Patch (OTA)
-- Combined Patch: TTS Engine + Find Bug (Ghost-Killer) Fix

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

-- ==========================================
-- 🔥 FEATURE 1: LISTEN (TTS) BUTTON 🔥
-- ==========================================
pcall(function()
    btnReaderTranslate.setText(LP("Listen 🗣️", "सुनें 🗣️"))
    btnReaderTranslate.setTextColor(0xFF4CAF50)

    btnReaderTranslate.onClick = function()
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
end)

-- ==========================================
-- 🔥 FEATURE 2: FIND BUTTON (GHOST-KILLER) 🔥
-- ==========================================
pcall(function()
    -- 🚨 1. पुराने क्रैश वाले कोड को पूरी तरह मार दो 🚨
    btnReaderFind.setOnClickListener(nil)
    btnReaderFind.onClick = nil

    -- 2. अब अपना नया और सेफ कोड लगाओ
    btnReaderFind.onClick = function()
        local okFind, errFind = pcall(function()
            local findInput = EditText(patchActivity)
            findInput.setHint(LP("Type to search...", "खोजने के लिए यहाँ लिखें..."))
            findInput.setTextColor(0xFF000000)

            AlertDialog.Builder(patchActivity)
            .setTitle(LP("Find Word 🔍", "शब्द खोजें 🔍"))
            .setView(findInput)
            .setPositiveButton(LP("Search", "खोजें"), function()
                
                local okSearch, errSearch = pcall(function()
                    -- जावा स्ट्रिंग का इस्तेमाल ताकि हिंदी/इंग्लिश दोनों एकदम सटीक काम करें
                    import "java.lang.String"
                    local query = String(findInput.getText().toString()):toLowerCase():toString()
                    
                    if query == "" then
                        Toast.makeText(patchActivity, LP("Please type something!", "कुछ टाइप तो करो भाई!"), 0).show()
                        return
                    end

                    if paraList and paraList.getVisibility() == 0 then
                        local adapter = paraList.getAdapter()
                        local foundIndex = -1
                        
                        if adapter then
                            for i = 0, adapter.getCount() - 1 do
                                local itemText = String(tostring(adapter.getItem(i) or "")):toLowerCase():toString()
                                if string.find(itemText, query, 1, true) then
                                    foundIndex = i
                                    break
                                end
                            end
                        end

                        if foundIndex ~= -1 then
                            paraList.setSelection(foundIndex) 
                            Toast.makeText(patchActivity, LP("Found at paragraph: ", "मिल गया! पैराग्राफ: ") .. tostring(foundIndex + 1), 0).show()
                        else
                            Toast.makeText(patchActivity, LP("Word not found.", "यह शब्द इस नोट में नहीं मिला।"), 0).show()
                        end

                    elseif readerBody then
                        local fullText = String(tostring(readerBody.getText() or "")):toLowerCase():toString()
                        local startPos = string.find(fullText, query, 1, true)

                        if startPos then
                            readerBody.requestFocus()
                            readerBody.setSelection(startPos - 1, startPos - 1 + string.len(query))
                            Toast.makeText(patchActivity, LP("Word found!", "शब्द मिल गया!"), 0).show()
                        else
                            Toast.makeText(patchActivity, LP("Word not found.", "यह शब्द इस नोट में नहीं मिला।"), 0).show()
                        end
                    end
                end)
                if not okSearch then showErrorBox("Search Error", errSearch) end
                
            end)
            .setNegativeButton(LP("Cancel", "रद्द करें"), nil)
            .show()
        end)
        if not okFind then showErrorBox("Find Setup Error", errFind) end
    end
end)

-- ==========================================
-- 🔥 SMART POPUP ANNOUNCEMENT 🔥
-- ==========================================
pcall(function()
    local patchLockFile = rootDirPatch .. "tts_find_patch_v3.lock"
    local f_lock = io.open(patchLockFile, "r")
    if not f_lock then
        AlertDialog.Builder(patchActivity)
        .setTitle(LP("🎉 New Updates!", "🎉 नए अपडेट्स!"))
        .setMessage(LP("1. Listen 🗣️: You can now listen to your notes.\n2. Find 🔍: The search bug is 100% fixed!", "1. सुनें 🗣️: अब आप अपने नोट्स को सुन सकते हैं।\n2. खोजें 🔍: सर्च वाला बग अब पूरी तरह ठीक हो गया है!"))
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
