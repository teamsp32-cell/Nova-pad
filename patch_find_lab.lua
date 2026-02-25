-- Nova Pad - Beta Find Lab 🔬
-- The "Pure Lua" Engine + Smart Voice/Keyboard Auto-Cleanup

local patchActivity = activity
local rootDirPatch = patchActivity.getExternalFilesDir(nil).toString() .. "/"

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

-- 1. सुरक्षित लोअरकेस
local function safeLower(str)
    if not str then return "" end
    return (string.gsub(tostring(str), "[A-Z]", string.lower))
end

-- 🔥 2. वाशिंग मशीन (Smart Auto-Cleanup for Voice & Keyboard) 🔥
local function smartClean(str)
    if not str then return "" end
    local s = tostring(str)
    
    -- A) वॉइस टाइपिंग के फालतू निशान हटाना (कोमा, डॉट, प्रश्नवाचक आदि)
    s = string.gsub(s, "[.,?!।]", "") 
    
    -- B) आगे-पीछे के स्पेस हटाना (Trim)
    s = string.gsub(s, "^%s*(.-)%s*$", "%1")
    
    -- C) हिंदी की आम स्पेलिंग को एक जैसा करना (Normalization)
    s = string.gsub(s, "न्द्र", "ंद्र")
    s = string.gsub(s, "न्त", "ंत")
    s = string.gsub(s, "न्द", "ंद")
    
    return s
end

-- 3. जादुई कनवर्टर (Bytes to Characters)
local function getJavaIndices(str, startByte, endByte)
    local startChar, endChar, chars = 0, 0, 0
    local i, len = 1, string.len(str)
    
    while i <= len do
        if i == startByte then startChar = chars end
        if i == endByte + 1 then endChar = chars; break end
        
        local b = string.byte(str, i)
        if b >= 0 and b <= 127 then i = i + 1; chars = chars + 1
        elseif b >= 192 and b <= 223 then i = i + 2; chars = chars + 1
        elseif b >= 224 and b <= 239 then i = i + 3; chars = chars + 1
        elseif b >= 240 and b <= 247 then i = i + 4; chars = chars + 2
        else i = i + 1 end
    end
    if endByte >= len then endChar = chars end
    return startChar, endChar
end

pcall(function()
    btnReaderSearch.setOnClickListener(nil)

    btnReaderSearch.onClick = function()
        pcall(function()
            local findInput = EditText(patchActivity)
            findInput.setHint(LP("Type or use Voice... 🎤", "टाइप करें या बोलें... 🎤"))
            findInput.setTextColor(0xFF000000)

            AlertDialog.Builder(patchActivity)
            .setTitle(LP("Find Lab (Beta) 🔬", "सर्च लैब (बीटा) 🔬"))
            .setView(findInput)
            .setPositiveButton(LP("Search", "खोजें"), function()
                
                pcall(function()
                    local rawQuery = tostring(findInput.getText() or "")
                    
                    -- 🔥 सर्च करने से पहले शब्द को वाशिंग मशीन में डाला 🔥
                    local cleanQuery = smartClean(rawQuery)
                    
                    if cleanQuery == "" then
                        Toast.makeText(patchActivity, LP("Please type something!", "कुछ टाइप करें!"), 0).show()
                        return
                    end

                    local safeQ = safeLower(cleanQuery)

                    if paraList and paraList.getVisibility() == 0 then
                        -- पैराग्राफ मोड
                        local adapter = paraList.getAdapter()
                        local foundIndex = -1
                        
                        if adapter then
                            for i = 0, adapter.getCount() - 1 do
                                local itemText = tostring(adapter.getItem(i) or "")
                                -- पैराग्राफ को भी साफ़ किया ताकि दोनों मैच हो जाएं
                                local safeItem = safeLower(smartClean(itemText))
                                
                                if string.find(safeItem, safeQ, 1, true) then
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
                        -- फुल टेक्स्ट मोड
                        local fullText = tostring(readerBody.getText() or "")
                        -- टेक्स्ट को भी साफ़ किया
                        local cleanFullText = smartClean(fullText)
                        local safeFullText = safeLower(cleanFullText)
                        
                        local startByte, endByte = string.find(safeFullText, safeQ, 1, true)

                        if startByte and endByte then
                            local startChar, endChar = getJavaIndices(cleanFullText, startByte, endByte)
                            readerBody.requestFocus()
                            readerBody.setSelection(startChar, endChar)
                            Toast.makeText(patchActivity, LP("Word found!", "शब्द मिल गया!"), 0).show()
                        else
                            Toast.makeText(patchActivity, LP("Word not found.", "यह शब्द इस लेख में नहीं मिला।"), 0).show()
                        end
                    end
                end)
            end)
            .setNegativeButton(LP("Cancel", "रद्द करें"), nil)
            .show()
        end)
    end
end)
