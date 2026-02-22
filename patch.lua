function searchHindiWord(query)
    -- pcall (एरर कैचिंग नेट) शुरू कर रहे हैं
    local success, errorMessage = pcall(function()
        
        -- टेक्स्ट बॉक्स का सारा टेक्स्ट ले रहे हैं
        local text = tostring(noteEditor.getText())
        
        -- अगर टेक्स्ट बॉक्स खाली है या सर्च वर्ड नहीं है तो वापस लौट जाओ
        if text == nil or text == "" then
            print("टेक्स्ट बॉक्स खाली है।")
            return
        end
        if query == nil or query == "" then
            print("खोजने के लिए कोई शब्द नहीं दिया गया।")
            return
        end

        -- Java String क्लास को कॉल कर रहे हैं ताकि कैरेक्टर सही से गिने जाएं
        local String = luajava.bindClass("java.lang.String")
        local javaText = String(text)
        local javaQuery = String(query)

        -- Java के तरीके से सर्च वर्ड की पोजीशन निकाल रहे हैं
        local startIndex = javaText:indexOf(javaQuery)

        -- अगर शब्द मिल जाता है (यानी इंडेक्स -1 नहीं है)
        if startIndex ~= -1 then
            local wordLength = javaQuery:length()
            local endIndex = startIndex + wordLength
            
            -- टेक्स्ट को सेलेक्ट या हाईलाइट कर रहे हैं
            noteEditor.setSelection(startIndex, endIndex)
            noteEditor.requestFocus()
            print("शब्द मिल गया!")
        else
            print("शब्द नहीं मिला।")
        end
        
    end)

    -- अगर pcall के अंदर कोई भी एरर आता है, तो success 'false' हो जाएगा
    if not success then
        -- यह सीधा स्क्रीन पर एरर का कारण बता देगा और ऐप क्रैश नहीं होगा
        print("सर्च में यह एरर आया: " .. tostring(errorMessage))
    end
end

-- इस फंक्शन को ऐसे इस्तेमाल करना है:
-- searchHindiWord("तुम्हारा_हिंदी_शब्द")
