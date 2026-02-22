function searchHindiWord(queryText)
    local success, errorMessage = pcall(function()
        
        -- Java की ज़रूरी क्लासेस को बुला रहे हैं
        local String = luajava.bindClass("java.lang.String")
        local Pattern = luajava.bindClass("java.util.regex.Pattern")
        
        -- EditText का पूरा टेक्स्ट ले रहे हैं
        local text = String(noteEditor.getText().toString())
        
        -- सर्च करने वाले शब्द को सीधे Java String बना रहे हैं (Lua का tostring हटा दिया गया है)
        local query = String(queryText)
        
        -- सर्च वर्ड में से किसी भी प्रकार के अदृश्य अक्षर (Zero Width Space) और खाली जगह को हटा रहे हैं
        query = query:replaceAll("[\u200B\uFEFF]", ""):trim()
        
        -- खाली होने की स्थिति जाँचना
        if text:isEmpty() then
            print("लेख खाली है।")
            return
        end
        if query:isEmpty() then
            print("खोजने के लिए कोई शब्द नहीं दिया गया।")
            return
        end

        -- Pattern.quote का उपयोग कर रहे हैं ताकि शब्द बिल्कुल उसी रूप में खोजा जाए जैसा लिखा है
        local pattern = Pattern:compile(Pattern:quote(query))
        local matcher = pattern:matcher(text)

        -- अगर शब्द मिल जाता है
        if matcher:find() then
            local startIndex = matcher:start()
            local endIndex = matcher:end()
            
            -- सटीक जगह पर टेक्स्ट को हाईलाइट करना
            noteEditor:setSelection(startIndex, endIndex)
            noteEditor:requestFocus()
            print("शब्द मिल गया!")
        else
            print("नो टेक्स्ट फाउंड (शब्द नहीं मिला)।")
        end
        
    end)

    if not success then
        print("सर्च में यह एरर आया: " .. tostring(errorMessage))
    end
end
