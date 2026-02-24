-- Nova Pad v2.9 - Live Patch
-- TTS + 100% Safe Hindi/English Search (No Java, No Encoding Bugs)

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

-- 🔥 जादुई सुरक्षित सर्च फंक्शन (सिर्फ अंग्रेजी को छोटा करेगा, हिंदी को सुरक्षित रखेगा) 🔥
local function safeLower(str)
    if not str then return "" end
    return (string.gsub(tostring(str), "%u", string.lower))
end

-- ==========================================
-- 🔥 1. LISTEN (TTS) BUTTON (यह एकदम परफेक्ट है) 🔥
-- ==========================================
pcall(function()
    btnReaderTranslate.setText(LP("Listen 🗣️", "सुनें 🗣️"))
    btnReaderTranslate.setTextColor(0xFF4CAF50)

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
end)

-- ==========================================
-- 🔥 2. FIND BUTTON (SAFE UTF-8 OVERWRITE) 🔥
-- ==========================================
pcall(function()
    btnReaderSearch.setOnClickListener(View.OnClickListener{
        onClick = function(v)
            local okFind, errFind = pcall(function()
                local findInput = EditText(patchActivity)
                findInput.setHint(LP("Type to search...", "खोजने के लिए यहाँ लिखें..."))
                findInput.setTextColor(0xFF000000)

                AlertDialog.Builder(patchActivity)
                .setTitle(LP("Find Word 🔍", "शब्द खोजें 🔍"))
                .setView(findInput)
                .setPositiveButton(LP("Search", "खोजें"), function()
                    
                    local rawQuery = tostring(findInput.getText() or "")
                    if rawQuery == "" then
                        Toast.makeText(patchActivity, LP("Please type something!", "कृपया खोजने के लिए कुछ लिखें!"), 0).show()
                        return
                    end

                    -- अब हमारा जादुई फॉर्मूला काम करेगा!
                    local query = safeLower(rawQuery)

                    if paraList and paraList.getVisibility() == 0 then
                        local adapter = paraList.getAdapter()
                        local foundIndex = -1
                        
                        if adapter then
                            for i = 0, adapter.getCount() - 1 do
                                local itemText = safeLower(adapter.getItem(i) or "")
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
                            Toast.makeText(patchActivity, LP("Word not found.", "यह शब्द इस लेख में नहीं मिला।"), 0).show()
                        end

                    elseif readerBody then
                        local fullText = safeLower(readerBody.getText() or "")
                        local startPos = string.find(fullText, query, 1, true)

                        if startPos then
                            readerBody.requestFocus()
                            -- सही जगह कर्सर ले जाने के लिए
                            readerBody.setSelection(startPos - 1, startPos - 1 + string.len(rawQuery))
                            Toast.makeText(patchActivity, LP("Word found!", "शब्द मिल गया!"), 0).show()
                        else
                            Toast.makeText(patchActivity, LP("Word not found.", "यह शब्द इस लेख में नहीं मिला।"), 0).show()
                        end
                    end
                end)
                .setNegativeButton(LP("Cancel", "रद्द करें"), nil)
                .show()
            end)
            if not okFind then showErrorBox("Find Setup Error", errFind) end
        end
    })
end)
