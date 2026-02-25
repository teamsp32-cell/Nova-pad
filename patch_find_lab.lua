-- Nova Pad - Beta Find Lab 🔬
-- TalkBack Accessibility + Direct Paragraph/Line Jump Engine

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

local function safeLower(str)
    if not str then return "" end
    return (string.gsub(tostring(str), "[A-Z]", string.lower))
end

local function smartClean(str)
    if not str then return "" end
    local s = tostring(str)
    s = string.gsub(s, "[.,?!।]", "") 
    s = string.gsub(s, "^%s*(.-)%s*$", "%1")
    s = string.gsub(s, "न्द्र", "ंद्र")
    s = string.gsub(s, "न्त", "ंत")
    s = string.gsub(s, "न्द", "ंद")
    return s
end

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
            findInput.setHint(LP("Type word OR 'Para 10' / 'लाइन 5' 🎤", "शब्द लिखें या बोलें 'पैराग्राफ 10' 🎤"))
            findInput.setTextColor(0xFF000000)

            AlertDialog.Builder(patchActivity)
            .setTitle(LP("Smart Search & Jump 🔬", "स्मार्ट खोज व जम्प 🔬"))
            .setView(findInput)
            .setPositiveButton(LP("Go", "खोजें"), function()
                
                pcall(function()
                    local rawQuery = tostring(findInput.getText() or "")
                    local trimmedQuery = string.gsub(rawQuery, "^%s*(.-)%s*$", "%1")
                    
                    if trimmedQuery == "" then return end

                    -- 🔥 1. COMMAND DETECTOR (पैराग्राफ या लाइन नंबर ढूँढना) 🔥
                    local isCommand = false
                    local reqType = ""
                    local reqNum = 0
                    
                    -- चेक करते हैं कि क्या यूज़र ने अंत में कोई नंबर (1, 2, 30...) लिखा है?
                    local numText = string.match(trimmedQuery, "(%d+)$")
                    if numText then
                        -- नंबर से पहले का शब्द निकालते हैं (जैसे "पैराग्राफ ", "line ")
                        local prefixLen = string.len(trimmedQuery) - string.len(numText)
                        local cmdText = string.sub(trimmedQuery, 1, prefixLen)
                        
                        -- स्पेस हटाकर चेक करते हैं
                        local cleanCmd = string.gsub(safeLower(cmdText), "[%s%p]", "")
                        
                        -- हिंदी और इंग्लिश दोनों कमांड्स सपोर्टेड!
                        if cleanCmd == "para" or cleanCmd == "paragraph" or cleanCmd == "पैराग्राफ" or cleanCmd == "अनुच्छेद" then
                            isCommand = true; reqType = "para"; reqNum = tonumber(numText)
                        elseif cleanCmd == "line" or cleanCmd == "लाइन" or cleanCmd == "पंक्ति" then
                            isCommand = true; reqType = "line"; reqNum = tonumber(numText)
                        end
                    end

                    -- 🔥 2. ACTION: JUMP TO COMMAND (डायरेक्ट जम्प) 🔥
                    if isCommand then
                        if paraList and paraList.getVisibility() == 0 then
                            local adapter = paraList.getAdapter()
                            if adapter and reqNum > 0 and reqNum <= adapter.getCount() then
                                paraList.setSelection(reqNum - 1)
                                local msg = LP("Paragraph " .. reqNum .. " selected", "पैराग्राफ " .. reqNum .. " चुना गया")
                                Toast.makeText(patchActivity, msg, 0).show()
                                -- 🎤 TALKBACK MAGIC: यह दृष्टिबाधित यूज़र्स को बोलकर बताएगा!
                                paraList.announceForAccessibility(msg) 
                            else
                                Toast.makeText(patchActivity, LP("Invalid Number!", "यह नंबर मौजूद नहीं है!"), 0).show()
                            end
                        elseif readerBody then
                            -- फुल टेक्स्ट मोड में जम्प
                            local fullText = tostring(readerBody.getText() or "")
                            local currentLine = 1
                            local startByte = 1
                            
                            while currentLine < reqNum do
                                local nextNewline = string.find(fullText, "\n", startByte, true)
                                if not nextNewline then break end
                                startByte = nextNewline + 1
                                currentLine = currentLine + 1
                            end
                            
                            if currentLine == reqNum then
                                local endByte = string.find(fullText, "\n", startByte, true)
                                if not endByte then endByte = string.len(fullText) else endByte = endByte - 1 end
                                
                                local sChar, eChar = getJavaIndices(fullText, startByte, endByte)
                                readerBody.requestFocus()
                                readerBody.setSelection(sChar, eChar)
                                local msg = LP("Line " .. reqNum .. " selected", "लाइन " .. reqNum .. " चुनी गई")
                                Toast.makeText(patchActivity, msg, 0).show()
                                -- 🎤 TALKBACK MAGIC!
                                readerBody.announceForAccessibility(msg) 
                            else
                                Toast.makeText(patchActivity, LP("Invalid Number!", "यह नंबर मौजूद नहीं है!"), 0).show()
                            end
                        end
                        return -- कमांड पूरी हो गई, आगे का साधारण सर्च रोक दो
                    end

                    -- 🔥 3. NORMAL TEXT SEARCH (अगर कोई कमांड नहीं है) 🔥
                    local cleanQuery = smartClean(trimmedQuery)
                    local safeQ = safeLower(cleanQuery)

                    if paraList and paraList.getVisibility() == 0 then
                        local adapter = paraList.getAdapter()
                        local foundIndex = -1
                        if adapter then
                            for i = 0, adapter.getCount() - 1 do
                                local itemText = tostring(adapter.getItem(i) or "")
                                local safeItem = safeLower(smartClean(itemText))
                                if string.find(safeItem, safeQ, 1, true) then
                                    foundIndex = i; break
                                end
                            end
                        end

                        if foundIndex ~= -1 then
                            paraList.setSelection(foundIndex) 
                            local msg = LP("Found at paragraph " .. (foundIndex + 1), "मिल गया! पैराग्राफ " .. (foundIndex + 1) .. " चुना गया")
                            Toast.makeText(patchActivity, msg, 0).show()
                            paraList.announceForAccessibility(msg) -- 🎤 TalkBack
                        else
                            Toast.makeText(patchActivity, LP("Word not found.", "यह शब्द नहीं मिला।"), 0).show()
                        end

                    elseif readerBody then
                        local fullText = tostring(readerBody.getText() or "")
                        local cleanFullText = smartClean(fullText)
                        local safeFullText = safeLower(cleanFullText)
                        
                        local startByte, endByte = string.find(safeFullText, safeQ, 1, true)
                        if startByte and endByte then
                            local startChar, endChar = getJavaIndices(cleanFullText, startByte, endByte)
                            readerBody.requestFocus()
                            readerBody.setSelection(startChar, endChar)
                            local msg = LP("Word found and selected", "शब्द मिल गया और चुन लिया गया")
                            Toast.makeText(patchActivity, msg, 0).show()
                            readerBody.announceForAccessibility(msg) -- 🎤 TalkBack
                        else
                            Toast.makeText(patchActivity, LP("Word not found.", "यह शब्द नहीं मिला।"), 0).show()
                        end
                    end
                end)
            end)
            .setNegativeButton(LP("Cancel", "रद्द करें"), nil)
            .show()
        end)
    end
end)
