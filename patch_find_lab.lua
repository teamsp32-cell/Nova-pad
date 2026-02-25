-- Nova Pad - Beta Find Lab 🔬
-- The "Android Native" Fix: TextUtils + SafeLower (No Java String Clash)

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

-- 🔥 जादुई फॉर्मूला: हिंदी सुरक्षित रहेगी, अंग्रेज़ी छोटी हो जाएगी 🔥
local function safeLower(str)
    if not str then return "" end
    return (string.gsub(tostring(str), "%u", string.lower))
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
                    if rawQuery == "" then
                        Toast.makeText(patchActivity, LP("Please type something!", "कुछ टाइप करें!"), 0).show()
                        return
                    end

                    -- 1. सुरक्षित लोअरकेस
                    local safeQ = safeLower(rawQuery)
                    
                    -- 2. एंड्रॉइड का अपना टूल (इसमें लुआ और जावा आपस में नहीं लड़ेंगे)
                    import "android.text.TextUtils"
                    
                    -- 3. सर्च बॉक्स से ही एकदम सटीक लंबाई निकाल ली (No crash guaranteed)
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
                            -- सही जगह पर कर्सर और सिलेक्शन
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
