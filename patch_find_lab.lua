-- Nova Pad - Beta Find Lab 🔬
-- External Dependency Powered: Java Native Regex Engine (UTF-8/Unicode Safe)

local patchActivity = activity
local rootDirPatch = patchActivity.getExternalFilesDir(nil).toString() .. "/"

-- भाषा सेट करने का फॉर्मूला
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

pcall(function()
    btnReaderSearch.setOnClickListener(View.OnClickListener{
        onClick = function(v)
            local findInput = EditText(patchActivity)
            findInput.setHint(LP("Type to search...", "खोजने के लिए यहाँ लिखें..."))
            findInput.setTextColor(0xFF000000)

            AlertDialog.Builder(patchActivity)
            .setTitle(LP("Find Lab (Beta) 🔬", "सर्च लैब (बीटा) 🔬"))
            .setView(findInput)
            .setPositiveButton(LP("Search", "खोजें"), function()
                
                local rawQuery = tostring(findInput.getText() or "")
                if rawQuery == "" then
                    Toast.makeText(patchActivity, LP("Please type something!", "कुछ टाइप करें!"), 0).show()
                    return
                end

                -- 🔥 EXTERNAL DEPENDENCY: Importing Java Native Engines 🔥
                import "java.lang.String"
                import "java.util.regex.Pattern"
                
                -- Pattern.CASE_INSENSITIVE (2) + Pattern.UNICODE_CASE (64) = 66
                -- यह फ्लैग (66) अंग्रेजी को केस-फ्री रखेगा और हिंदी (Unicode) को टूटने नहीं देगा!
                local pattern = Pattern.compile(Pattern.quote(rawQuery), 66)

                if paraList and paraList.getVisibility() == 0 then
                    -- पैराग्राफ मोड
                    local adapter = paraList.getAdapter()
                    local foundIndex = -1
                    
                    if adapter then
                        for i = 0, adapter.getCount() - 1 do
                            local itemText = tostring(adapter.getItem(i) or "")
                            
                            -- शुद्ध जावा के स्ट्रिंग में बदलकर मैच करना
                            local jItemText = String(itemText)
                            local matcher = pattern.matcher(jItemText)
                            
                            -- अगर शब्द मिला
                            if matcher.find() then
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
                    
                    -- पूरा टेक्स्ट जावा के हवाले कर दिया
                    local jFullText = String(fullText)
                    local matcher = pattern.matcher(jFullText)
                    
                    if matcher.find() then
                        -- जावा का नेटिव स्टार्ट और एंड पोज़िशन (Characters में, Bytes में नहीं!)
                        local startPos = matcher.start()
                        local endPos = matcher.end()
                        
                        readerBody.requestFocus()
                        -- बिल्कुल सही जगह पर सिलेक्शन
                        readerBody.setSelection(startPos, endPos)
                        Toast.makeText(patchActivity, LP("Word found!", "शब्द मिल गया!"), 0).show()
                    else
                        Toast.makeText(patchActivity, LP("Word not found.", "यह शब्द इस लेख में नहीं मिला।"), 0).show()
                    end
                end
            end)
            .setNegativeButton(LP("Cancel", "रद्द करें"), nil)
            .show()
        end)
    })
end)
