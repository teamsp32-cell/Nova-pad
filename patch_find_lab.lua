-- Nova Pad - Beta Find Lab 🔬
-- The "Pure Lua" Fix: Zero Java, Custom Byte-to-Char Converter

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

-- सिर्फ A-Z को a-z करेगा (हिंदी के बाइट्स सुरक्षित रहेंगे)
local function safeLower(str)
    if not str then return "" end
    return (string.gsub(tostring(str), "[A-Z]", string.lower))
end

-- 🔥 जादुई कनवर्टर: लुआ की जगह (Bytes) को एंड्रॉइड की जगह (Chars) में बदलता है 🔥
local function getJavaIndices(str, startByte, endByte)
    local startChar = 0
    local endChar = 0
    local chars = 0
    local i = 1
    local len = string.len(str)
    
    while i <= len do
        if i == startByte then startChar = chars end
        if i == endByte + 1 then endChar = chars; break end
        
        local b = string.byte(str, i)
        if b >= 0 and b <= 127 then i = i + 1; chars = chars + 1
        elseif b >= 192 and b <= 223 then i = i + 2; chars = chars + 1
        elseif b >= 224 and b <= 239 then i = i + 3; chars = chars + 1
        elseif b >= 240 and b <= 247 then i = i + 4; chars = chars + 2 -- (Emoji / Surrogate)
        else i = i + 1 end
    end
    if endByte >= len then endChar = chars end
    
    return startChar, endChar
end

pcall(function()
    btnReaderSearch.setOnClickListener(nil)

    btnReaderSearch.onClick = function()
        local okFind, errFind = pcall(function()
            local findInput = EditText(patchActivity)
            findInput.setHint(LP("Type to search...", "खोजने के लिए यहाँ लिखें..."))
            findInput.setTextColor(0xFF000000)

            AlertDialog.Builder(patchActivity)
            .setTitle(LP("Find Lab (Beta) 🔬", "सर्च लैब (बीटा) 🔬"))
            .setView(findInput)
            .setPositiveButton(LP("Search", "खोजें"), function()
                
                local okSearch, errSearch = pcall(function()
                    local rawQuery = tostring(findInput.getText() or "")
                    
                    -- फालतू स्पेस हटाना
                    local trimmedQuery = string.gsub(rawQuery, "^%s*(.-)%s*$", "%1")
                    
                    if trimmedQuery == "" then
                        Toast.makeText(patchActivity, LP("Please type something!", "कुछ टाइप करें!"), 0).show()
                        return
                    end

                    local safeQ = safeLower(trimmedQuery)

                    if paraList and paraList.getVisibility() == 0 then
                        -- पैराग्राफ मोड
                        local adapter = paraList.getAdapter()
                        local foundIndex = -1
                        
                        if adapter then
                            for i = 0, adapter.getCount() - 1 do
                                local itemText = tostring(adapter.getItem(i) or "")
                                local safeItem = safeLower(itemText)
                                
                                -- शुद्ध लुआ सर्च! कोई जावा नहीं!
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
                        local safeFullText = safeLower(fullText)
                        
                        -- शुद्ध लुआ सर्च: यह हमें बाइट्स की जगह देगा
                        local startByte, endByte = string.find(safeFullText, safeQ, 1, true)

                        if startByte and endByte then
                            -- 🔥 बाइट्स को एंड्रॉइड के अक्षरों में बदल दिया 🔥
                            local startChar, endChar = getJavaIndices(fullText, startByte, endByte)
                            
                            readerBody.requestFocus()
                            readerBody.setSelection(startChar, endChar)
                            Toast.makeText(patchActivity, LP("Word found!", "शब्द मिल गया!"), 0).show()
                        else
                            Toast.makeText(patchActivity, LP("Word not found.", "यह शब्द इस लेख में नहीं मिला।"), 0).show()
                        end
                    end
                end)
                if not okSearch then showErrorBox("Search Execution Error", errSearch) end
            end)
            .setNegativeButton(LP("Cancel", "रद्द करें"), nil)
            .show()
        end)
        if not okFind then showErrorBox("Find Setup Error", errFind) end
    end
end)
