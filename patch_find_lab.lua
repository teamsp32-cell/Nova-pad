-- Nova Pad - Beta Find Lab 🔬
-- The "Pure Java String" Fix (UTF-8 Safe, Auto-Trim & Exact Indexing)

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
                    
                    -- 1. TRIM: शब्द के आगे-पीछे के फालतू स्पेस हटाना
                    local trimmedQuery = string.gsub(rawQuery, "^%s*(.-)%s*$", "%1")
                    
                    if trimmedQuery == "" then
                        Toast.makeText(patchActivity, LP("Please type something!", "कुछ टाइप करें!"), 0).show()
                        return
                    end

                    -- 2. SAFE LOWER: सिर्फ A-Z को a-z में बदलना (हिंदी एकदम सुरक्षित)
                    local safeQ = string.gsub(trimmedQuery, "[A-Z]", string.lower)
                    
                    -- 3. PURE JAVA BINDING: अब सब कुछ शुद्ध जावा के हवाले!
                    local JString = luajava.bindClass("java.lang.String")
                    local jQuery = JString(safeQ)
                    local qLen = jQuery:length()

                    if paraList and paraList.getVisibility() == 0 then
                        -- पैराग्राफ मोड
                        local adapter = paraList.getAdapter()
                        local foundIndex = -1
                        
                        if adapter then
                            for i = 0, adapter.getCount() - 1 do
                                local itemText = tostring(adapter.getItem(i) or "")
                                local safeItem = string.gsub(itemText, "[A-Z]", string.lower)
                                
                                -- शुद्ध जावा का ऑब्जेक्ट
                                local jItem = JString(safeItem)
                                
                                -- शुद्ध जावा का सटीक सर्च
                                if jItem:indexOf(jQuery) >= 0 then
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
                        local safeFullText = string.gsub(fullText, "[A-Z]", string.lower)
                        
                        -- शुद्ध जावा का ऑब्जेक्ट
                        local jFullText = JString(safeFullText)
                        
                        -- शुद्ध जावा का सटीक इंडेक्स सर्च
                        local startPos = jFullText:indexOf(jQuery)

                        if startPos >= 0 then
                            readerBody.requestFocus()
                            -- बिल्कुल सटीक कैरेक्टर पर कर्सर और हाईलाइट
                            readerBody.setSelection(startPos, startPos + qLen)
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
