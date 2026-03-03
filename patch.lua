-- 🚀 NOVA PAD - THE MASTER ROUTER (Beta Channel & Multi-Patch System)
-- Supports: v2.9 & v3.0

if APP_VERSION_NAME == "v2.9" or APP_VERSION_NAME == "v3.0" then
    pcall(function()
        local patchActivity = activity
        local rootDirPatch = patchActivity.getExternalFilesDir(nil).toString() .. "/"
        local devFile = rootDirPatch .. "developer_mode.txt"

        -- 🌟 1. तुम्हारा सीक्रेट बीटा पासवर्ड 🌟
        local mySecretBetaCode = "Mayank@123"

        -- 🚨 2. सीक्रेट बीटा स्विच (Top Title पर लॉन्ग प्रेस) 🚨
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

        -- 🚥 3. ट्रैफिक कंट्रोलर (चेक करो कि यूज़र टेस्टर है या पब्लिक) 🚥
        local isBetaUser = false
        local f_check = io.open(devFile, "r")
        if f_check then isBetaUser = true; f_check:close() end

        -- 📁 4. पैच फाइल्स की लिस्ट (Raw Links)
        local patchList = {}
        
        -- ✅ यह फाइल्स सबको मिलेंगी (Public + Beta)
        table.insert(patchList, "https://raw.githubusercontent.com/teamsp32-cell/Nova-pad/main/patch_tts.lua")
        table.insert(patchList, "https://raw.githubusercontent.com/teamsp32-cell/Nova-pad/main/patch_notify.lua")
        table.insert(patchList, "https://raw.githubusercontent.com/teamsp32-cell/Nova-pad/main/patch_stable_ui.lua")
        table.insert(patchList, "https://raw.githubusercontent.com/teamsp32-cell/Nova-pad/main/patch_tools.lua")

        -- 🔥 बीटा और पब्लिक का अलग-अलग रास्ता 🔥
        if isBetaUser then
            -- 🔬 सिर्फ बीटा टेस्टर्स के लिए (Find Lab और Beta Test)
            table.insert(patchList, "https://raw.githubusercontent.com/teamsp32-cell/Nova-pad/main/patch_find_lab.lua")
            table.insert(patchList, "https://raw.githubusercontent.com/teamsp32-cell/Nova-pad/main/patch_beta_test.lua")
            Toast.makeText(patchActivity, "🛠️ Master: Beta Channel Loaded", 0).show()
        else
            -- 🌍 सिर्फ आम यूज़र्स के लिए (Stable Find)
            table.insert(patchList, "https://raw.githubusercontent.com/teamsp32-cell/Nova-pad/main/patch_find.lua") 
        end

        -- 🚀 5. सभी पैचेस को बैकग्राउंड में सुरक्षित तरीके से चलाना
        for i, url in ipairs(patchList) do
            Http.get(url, function(code, content)
                if code == 200 and content and #content > 5 then
                    local ok, err = pcall(load(content))
                    if not ok and isBetaUser then
                        -- अगर कोई पैच फेल होता है, तो सिर्फ तुम्हें (Beta) एरर दिखेगा
                        local errInput = EditText(patchActivity)
                        errInput.setText("Patch Failed: " .. url .. "\n\n" .. tostring(err))
                        errInput.setTextIsSelectable(true)
                        AlertDialog.Builder(patchActivity)
                        .setTitle("Beta Crash Report")
                        .setView(errInput)
                        .setPositiveButton("OK", nil)
                        .show()
                    end
                end
            end)
        end
    end)
end
