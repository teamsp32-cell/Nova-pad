-- 🔍 Nova Pad v3.0 - Public Smart Find Patch (Stable & Crash-Proof)
-- Smart Intent, TalkBack Accessibility & Java Engine

if APP_VERSION_NAME == "v3.0" then
    pcall(function()
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

        local function convertHindiDigits(str)
            local s = tostring(str)
            s = string.gsub(s, "०", "0"); s = string.gsub(s, "१", "1"); s = string.gsub(s, "२", "2")
            s = string.gsub(s, "३", "3"); s = string.gsub(s, "४", "4"); s = string.gsub(s, "५", "5")
            s = string.gsub(s, "६", "6"); s = string.gsub(s, "७", "7"); s = string.gsub(s, "८", "8")
            s = string.gsub(s, "९", "9")
            return s
        end

        -- 🌟 SUPER FIX: 100% Crash-Proof Java Lowercase Engine 🌟
        local function safeLower(str)
            if not str or str == "" then return "" end
            local ok, res = pcall(function()
                local JString = luajava.bindClass("java.lang.String")
                return JString.valueOf(tostring(str)):toLowerCase():toString()
            end)
            if ok and res then return res end
            return string.lower(tostring(str)) -- Fallback
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

        -- 🔥 Main Find Button Injection
        if btnReaderSearch then
            btnReaderSearch.setOnClickListener(nil)
            
            btnReaderSearch.setOnClickListener(View.OnClickListener{
                onClick = function()
                    pcall(function()
                        local l = LinearLayout(patchActivity); l.setOrientation(1); l.setPadding(50,20,50,20)
                        local findInput = EditText(patchActivity)
                        findInput.setHint(LP("Type word OR 'Para 10' / 'लाइन 5' 🎤", "सर्च करने के लिए शब्द लिखें या बोलें 'पैरा 10' 🎤"))
                        findInput.setTextColor(0xFF000000)
                        l.addView(findInput)

                        AlertDialog.Builder(patchActivity)
                        .setTitle(LP("Find in Notes 🔍", "नोटिस में खोजें 🔍"))
                        .setView(l)
                        .setPositiveButton(LP("Search", "खोजें"), function()
                            
                            pcall(function()
                                local rawQuery = tostring(findInput.getText() or "")
                                local queryWithEngNums = convertHindiDigits(rawQuery)
                                local trimmedQuery = string.gsub(queryWithEngNums, "^%s*(.-)%s*$", "%1")
                                if trimmedQuery == "" then return end

                                local isCommand = false
                                local reqNum = 0
                                
                                local numText = string.match(trimmedQuery, "%d+")
                                if numText then
                                    reqNum = tonumber(numText)
                                    local safeQ = safeLower(trimmedQuery)
                                    if string.find(safeQ, "para") or string.find(safeQ, "पैरा") or string.find(safeQ, "पेरा") or string.find(safeQ, "अनुच्छेद") or string.find(safeQ, "line") or string.find(safeQ, "लाइन") or string.find(safeQ, "पंक्ति") then
                                        isCommand = true
                                    end
                                end

                                if isCommand and reqNum > 0 then
                                    if paraList and paraList.getVisibility() == 0 then
                                        local adapter = paraList.getAdapter()
                                        if adapter and reqNum <= adapter.getCount() then
                                            paraList.setSelection(reqNum - 1)
                                            local msg = LP("Paragraph " .. reqNum .. " selected", "पैराग्राफ " .. reqNum .. " चुना गया")
                                            Toast.makeText(patchActivity, msg, 0).show()
                                            pcall(function() patchActivity.getWindow().getDecorView().announceForAccessibility(msg) end)
                                        else
                                            Toast.makeText(patchActivity, LP("Invalid Number!", "यह नंबर मौजूद नहीं है!"), 0).show()
                                        end
                                    elseif readerBody then
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
                                            pcall(function() patchActivity.getWindow().getDecorView().announceForAccessibility(msg) end)
                                        else
                                            Toast.makeText(patchActivity, LP("Invalid Number!", "यह नंबर मौजूद नहीं है!"), 0).show()
                                        end
                                    end
                                    return 
                                end

                                -- 🔥 NORMAL TEXT SEARCH WITH SAFE JAVA ENGINE 🔥
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
                                        pcall(function() patchActivity.getWindow().getDecorView().announceForAccessibility(msg) end)
                                    else
                                        local failMsg = LP("Word not found.", "यह शब्द इस लेख में नहीं मिला।")
                                        Toast.makeText(patchActivity, failMsg, 0).show()
                                        pcall(function() patchActivity.getWindow().getDecorView().announceForAccessibility(failMsg) end)
                                    end

                                elseif readerBody then
                                    local fullText = tostring(readerBody.getText() or "")
                                    local cleanFullText = smartClean(fullText)
                                    local safeFullText = safeLower(cleanFullText) -- 👈 Now 100% Crash Proof
                                    
                                    local startByte, endByte = string.find(safeFullText, safeQ, 1, true)
                                    if startByte and endByte then
                                        local startChar, endChar = getJavaIndices(cleanFullText, startByte, endByte)
                                        readerBody.requestFocus()
                                        readerBody.setSelection(startChar, endChar)
                                        local msg = LP("Word found and selected", "शब्द मिल गया और चुन लिया गया")
                                        Toast.makeText(patchActivity, msg, 0).show()
                                        pcall(function() patchActivity.getWindow().getDecorView().announceForAccessibility(msg) end)
                                    else
                                        local failMsg = LP("Word not found.", "यह शब्द इस लेख में नहीं मिला।")
                                        Toast.makeText(patchActivity, failMsg, 0).show()
                                        pcall(function() patchActivity.getWindow().getDecorView().announceForAccessibility(failMsg) end)
                                    end
                                end
                            end)
                        end)
                        .setNegativeButton(LP("Cancel", "कैंसिल"), nil)
                        .show()
                    end)
                end
            })
        end
    end)
end
