-- Nova Pad - Beta Find Lab 🔬
-- The "Android Native" Fix v3: 100% UTF-8 SafeLower + TextUtils

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

-- 🚨 जाल (The Error Catcher Net) 🚨
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

-- 🔥 जादुई फॉर्मूला: %u की जगह [A-Z] लगाया। अब हिंदी के शब्द बिल्कुल नहीं टूटेंगे! 🔥
local function safeLower(str)
    if not str then return "" end
    -- यह सिर्फ अंग्रेज़ी के A-Z को a-z करेगा, बाकी किसी भाषा को हाथ भी नहीं लगाएगा।
    return (string.gsub(tostring(str), "[A-Z]", string.lower))
end

pcall(function()
    btnReaderSearch.setOnClickListener(nil)

    btnReaderSearch.onClick = function()
        -- पहला जाल: फाइंड बॉक्स खोलने के लिए
        local okFind, errFind = pcall(function()
            local findInput = EditText(patchActivity)
            findInput.setHint(LP("Type to search...", "खोजने के लिए यहाँ लिखें..."))
            findInput.setTextColor(0xFF000000)

            AlertDialog.Builder(patchActivity)
            .setTitle(LP("Find Lab (Beta) 🔬", "सर्च लैब (बीटा) 🔬"))
            .setView(findInput)
            .setPositiveButton(LP("Search", "खोजें"), function()
                
                -- दूसरा जाल: सर्च एग्जीक्यूट करने के लिए
                local okSearch, errSearch = pcall(function()
                    local rawQuery = tostring(findInput.getText() or "")
                    if rawQuery == "" then
                        Toast.makeText(patchActivity, LP("Please type something!", "कुछ टाइप करें!"), 0).show()
                        return
                    end

                    -- 1. सुरक्षित लोअरकेस (अब हिंदी के शब्द सुरक्षित हैं)
                    local safeQ = safeLower(rawQuery)
                    
                    -- 2. एंड्रॉइड का नेटिव सर्च टूल (TextUtils)
                    import "android.text.TextUtils"
                    
                    -- 3. सर्च बॉक्स से सटीक जावा कैरेक्टर लंबाई निकाली
                    local qCharLen = findInput.length()

                    if paraList and paraList.getVisibility() == 0 then
                        -- पैराग्राफ मोड
                        local adapter = paraList.getAdapter()
                        local foundIndex = -1
                        
                        if adapter then
                            for i = 0, adapter.getCount() - 1 do
                                local itemText = tostring(adapter.getItem(i) or "")
                                local safeItem = safeLower(itemText)
                                
                                -- TextUtils सीधा सटीक जगह खोज निकालेगा
                                if TextUtils.indexOf(safeItem, safeQ) >= 0 then
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
                        
                        -- यह एंड्रॉइड का नेटिव टूल हमें एकदम सही कैरेक्टर की जगह देगा
                        local startPos = TextUtils.indexOf(safeFullText, safeQ)

                        if startPos >= 0 then
                            readerBody.requestFocus()
                            -- सही जगह पर कर्सर और सिलेक्शन (Highlight)
                            readerBody.setSelection(startPos, startPos + qCharLen)
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
