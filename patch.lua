function searchHindiWord(query)
    local success, errorMessage = pcall(function()
        
        -- तरीका बदला गया: अब यह एकदम शुद्ध स्ट्रिंग निकालेगा
        local text = noteEditor.getText().toString()
        
        if text == nil or text == "" then
            print("टेक्स्ट बॉक्स खाली है।")
            return
        end
        if query == nil or query == "" then
            print("खोजने के लिए कोई शब्द नहीं दिया गया।")
            return
        end

        -- सर्च करने वाले शब्द के आगे-पीछे से फालतू स्पेस हटा रहे हैं
        local cleanQuery = query:match("^%s*(.-)%s*$")
        
        -- स्क्रीन पर देखने के लिए कि असल में क्या खोजा जा रहा है (ब्रैकेट के अंदर)
        print("हम यह शब्द खोज रहे हैं: [" .. cleanQuery .. "]")

        local String = luajava.bindClass("java.lang.String")
        local javaText = String(text)
        local javaQuery = String(cleanQuery)

        local startIndex = javaText:indexOf(javaQuery)

        if startIndex ~= -1 then
            local wordLength = javaQuery:length()
            local endIndex = startIndex + wordLength
            
            noteEditor.setSelection(startIndex, endIndex)
            noteEditor.requestFocus()
            print("शब्द मिल गया और सेलेक्ट हो गया!")
        else
            print("शब्द मौजूद है पर मैच नहीं हुआ।")
        end
        
    end)

    if not success then
        print("सर्च में यह एरर आया: " .. tostring(errorMessage))
    end
end
