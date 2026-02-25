-- Nova Pad - Beta Find Lab 🔬
-- The "Ultimate Hybrid" Fix: SafeLower + Java String IndexOf

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

-- 🔥 जादुई फॉर्मूला: सिर्फ अंग्रेज़ी (A-Z) को छोटा करेगा, हिंदी को एकदम सुरक्षित रखेगा! 🔥
local function safeLower(str)
    if not str then return "" end
    return (string.gsub(tostring(str), "%u", string.lower))
end

pcall(function()
    -- 🚨 पुराने लिसनर को पूरी तरह मिटाने के लिए 🚨
    btnReaderSearch.setOnClickListener(nil)

    -- नया 'हार्ड-ओवरराइट' जाल
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

                    -- 1. सुरक्षित तरीके से शब्द को छोटा किया (हिंदी सुरक्षित रहेगी)
                    local safeQ = safeLower(rawQuery)
                    
                    -- 2. जावा के बेसिक String का इस्तेमाल (कोई जटिल Regex नहीं)
                    local JString = luajava.bindClass("java.lang.String")
                    local jQuery = JString(safeQ)
                    local qCharLen = jQuery:length()

                    if paraList and paraList.getVisibility() == 0 then
                        -- पैराग्राफ मोड
                        local adapter = paraList.getAdapter()
                        local foundIndex = -1
                        
                        if adapter then
                            for i = 0, adapter.getCount() - 1 do
                                local itemText = tostring(adapter.getItem(i) or "")
                                local safeItem = safeLower(itemText)
                                local jItem = JString(safeItem)
                                
                                -- शुद्ध जावा का indexOf (सटीक कैरेक्टर मैच)
                                if jItem:indexOf(safeQ) >= 0 then
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
                        local jFullText = JString(safeFullText)
                        
                        -- यह हमें एकदम सटीक 'कैरेक्टर' की जगह (Index) देगा
                        local startPos = jFullText:indexOf(safeQ)

                        if startPos >= 0 then
                            readerBody.requestFocus()
                            -- बिल्कुल सही जगह पर सिलेक्शन
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
