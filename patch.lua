-- 🚀 NOVA PAD - THE MASTER ROUTER (v3.0 Active, v2.9 Dead)

if APP_VERSION_NAME == "v2.9" then
    -- 🛑 2.9 को पूरी तरह बंद कर दिया गया है
    pcall(function()
        AlertDialog.Builder(activity)
        .setTitle("⚠️ Update Required")
        .setMessage("Nova Pad v2.9 has been discontinued. Please update to v3.0 for new features and the best experience.")
        .setPositiveButton("OK", nil)
        .setCancelable(false)
        .show()
    end)

elseif APP_VERSION_NAME == "v3.0" then
    -- ✅ 3.0 के लिए मास्टर राऊटर शुरू
    pcall(function()
        local patchActivity = activity
        local rootDirPatch = patchActivity.getExternalFilesDir(nil).toString() .. "/"
        local devFile = rootDirPatch .. "developer_mode.txt"

        -- 🌟 तुम्हारा सीक्रेट बीटा पासवर्ड 🌟
        local mySecretBetaCode = "Mayank@123"

        -- 🚨 सीक्रेट बीटा स्विच (100% Working Global Hook) 🚨
        if _G.topTitle then
            _G.topTitle.setOnLongClickListener(View.OnLongClickListener{
                onLongClick = function(v)
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

        local isBetaUser = false
        local f_check = io.open(devFile, "r")
        if f_check then isBetaUser = true; f_check:close() end

        -- 📁 3.0 के लिए पैच फाइल्स की लिस्ट 
        local patchList = {}
        
        -- 🔥 दोनों 3.0 वाले पैच (Find और Tools) यहाँ से लोड होंगे 🔥
        table.insert(patchList, "https://raw.githubusercontent.com/teamsp32-cell/Nova-pad/main/patch_find.lua")
        table.insert(patchList, "https://raw.githubusercontent.com/teamsp32-cell/Nova-pad/main/patch_tools.lua")

        if isBetaUser then
            Toast.makeText(patchActivity, "🛠️ Beta Channel Loaded", 0).show()
            -- अगर भविष्य में कोई और बीटा फाइल डालनी हो, तो यहाँ डाल देना:
            -- table.insert(patchList, "https://raw.githubusercontent.com/.../beta_extra.lua")
        end

        -- 🚀 बैकग्राउंड पैच रनर
        for i, url in ipairs(patchList) do
            Http.get(url, function(code, content)
                if code == 200 and content and #content > 5 then
                    pcall(load(content))
                end
            end)
        end
    end)
end
