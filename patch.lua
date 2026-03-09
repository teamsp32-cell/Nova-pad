-- 🚀 NOVA PAD - THE MASTER ROUTER (v3.0 Internal Mode)

if APP_VERSION_NAME == "v2.9" then
    -- 🛑 2.9 को पूरी तरह बंद कर दिया गया है (Force Update Message)
    pcall(function()
        AlertDialog.Builder(activity)
        .setTitle("⚠️ Update Required")
        .setMessage("Nova Pad v2.9 has been discontinued. Please update to v3.0 for new features and the best experience.")
        .setPositiveButton("OK", nil)
        .setCancelable(false)
        .show()
    end)

elseif APP_VERSION_NAME == "v3.0" then
    -- ✅ 3.0 के लिए मास्टर राऊटर (अभी कोई पैच नहीं है, सब कुछ इंटरनल चलेगा)
    pcall(function()
        local patchActivity = activity
        local rootDirPatch = patchActivity.getExternalFilesDir(nil).toString() .. "/"
        local devFile = rootDirPatch .. "developer_mode.txt"

        -- 🌟 तुम्हारा सीक्रेट बीटा पासवर्ड 🌟
        local mySecretBetaCode = "Mayank@123"

        -- 🚨 सीक्रेट बीटा स्विच (Top Title पर लॉन्ग प्रेस) 🚨
        if topTitle then
            topTitle.setOnLongClickListener(View.OnLongClickListener{
                onLongClick = function()
                    local f = io.open(devFile, "r")
                    if f then
                        AlertDialog.Builder(patchActivity)
                        .setTitle("👨‍💻 Beta Mode Active")
                        .setMessage("क्या आप Beta टेस्टिंग से बाहर निकलकर Public वर्ज़न में जाना चाहते हैं?")
                        .setPositiveButton("Yes (Leave Beta)", function()
                            f:close(); os.remove(devFile)
                            Toast.makeText(patchActivity, "🌍 Public Mode ON", 1).show()
                        end)
                        .setNegativeButton("Cancel", nil)
                        .show()
                    else
                        local codeInput = EditText(patchActivity)
                        codeInput.setHint("Enter Secret Beta Code...")                        
                        AlertDialog.Builder(patchActivity)
                        .setTitle("🔒 Beta Access Required")
                        .setView(codeInput)
                        .setPositiveButton("Unlock", function()
                            local enteredCode = tostring(codeInput.getText() or "")
                            if enteredCode == mySecretBetaCode then
                                local fw = io.open(devFile, "w")
                                if fw then fw:write("active"); fw:close() end
                                Toast.makeText(patchActivity, "🎉 Welcome to Beta Team!", 1).show()
                            else
                                Toast.makeText(patchActivity, "❌ Invalid Beta Code!", 1).show()
                            end
                        end)
                        .setNegativeButton("Cancel", nil)
                        .show()
                    end
                    return true
                end
            })
        end

        -- 🚥 चेक करो कि यूज़र टेस्टर है या पब्लिक 🚥
        local isBetaUser = false
        local f_check = io.open(devFile, "r")
        if f_check then isBetaUser = true; f_check:close() end

        -- 📁 पैच फाइल्स की लिस्ट 
        local patchList = {}
        
        -- 🔥 मैंने यहाँ से 2.9 की सारी पुरानी फाइल्स हटा दी हैं 🔥
        -- ताकि 3.0 सिर्फ अपने 'इंटरनल' सोर्स कोड पर चले और कोई ओवरराइडिंग ना हो!

        if isBetaUser then
            Toast.makeText(patchActivity, "🛠️ Beta Channel: Running on Internal Code", 0).show()
            
            -- भविष्य में अगर कभी 3.0 के बीटा टेस्टर्स को कोई नया पैच देना हो, 
            -- तो बस उसका लिंक यहाँ नीचे डाल देना:
            -- table.insert(patchList, "https://raw.githubusercontent.com/.../beta_patch.lua")
        else
            -- भविष्य में 3.0 के पब्लिक यूज़र्स के लिए पैच यहाँ डलेंगे।
        end

        -- 🚀 बैकग्राउंड पैच रनर (अभी लिस्ट खाली है, इसलिए यह चुपचाप इग्नोर कर देगा)
        for i, url in ipairs(patchList) do
            Http.get(url, function(code, content)
                if code == 200 and content and #content > 5 then
                    pcall(load(content))
                end
            end)
        end
    end)
end
