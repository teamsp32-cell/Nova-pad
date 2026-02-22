function searchHindiWord(queryText)
    local success, errorMessage = pcall(function()
        
        -- Java String क्लास को बुला रहे हैं
        local String = luajava.bindClass("java.lang.String")
        
        -- EditText का पूरा टेक्स्ट सीधा Java String में बदल रहे हैं
        local text = String(noteEditor.getText().toString())
        
        -- जो शब्द खोजना है, उसे भी सीधा Java String में बदल रहे हैं
        local query = String(tostring(queryText))
        
        -- अब Lua की जगह Java का trim() इस्तेमाल कर रहे हैं ताकि हिंदी के अक्षर सुरक्षित रहें
        query = query:trim()

        -- अगर टेक्स्ट बॉक्स खाली है तो...
        if text:isEmpty() then
            print("टेक्स्ट बॉक्स खाली है।")
            return
        end
        
        -- अगर सर्च बॉक्स खाली है तो...
        if query:isEmpty() then
            print("खोजने के लिए कोई शब्द नहीं दिया गया।")
            return
        end

        print("हम यह खोज रहे हैं: [" .. query .. "]")

        -- पूरी तरह से Java के indexOf का उपयोग करके शब्द खोज रहे हैं
        local startIndex = text:indexOf(query)

        -- अगर शब्द मिल जाता है
        if startIndex ~= -1 then
            local wordLength = query:length()
            local endIndex = startIndex + wordLength
            
            noteEditor:setSelection(startIndex, endIndex)
            noteEditor:requestFocus()
            print("शब्द मिल गया और सेलेक्ट हो गया!")
        else
            print("नो टेक्स्ट फाउंड (No Text Found)।")
        end
        
    end)

    if not success then
        print("सर्च में यह एरर आया: " .. tostring(errorMessage))
    end
end
