-- 🚨 NOVA PAD - THE NIL FIX MASTER ROUTER 🚨

pcall(function()
    local patchActivity = activity
    
    -- 🕵️‍♂️ Android सिस्टम से सीधा वर्ज़न निकालने का असली तरीका
    local vName = "nil"
    pcall(function()
        local pm = patchActivity.getPackageManager()
        local pi = pm.getPackageInfo(patchActivity.getPackageName(), 0)
        vName = tostring(pi.versionName)
    end)

    -- अगर फिर भी nil आए, तो पुराना ग्लोबल वेरिएबल चेक करें
    if vName == "nil" or vName == "" then
        vName = tostring(APP_VERSION_NAME)
    end

    -- सायरन!
    Toast.makeText(patchActivity, "🌐 Master Active! Version: " .. vName, 1).show()

    local rootDirPatch = patchActivity.getExternalFilesDir(nil).toString() .. "/"
    local devFile = rootDirPatch .. "developer_mode.txt"

    -- 🛑 2.9 DISCONTINUED (अगर वर्ज़न में 2.9 लिखा है)
    if string.find(vName, "2.9") then
        AlertDialog.Builder(patchActivity)
        .setTitle("⚠️ Update Required")
        .setMessage("Nova Pad v2.9 has been discontinued. Please update to v3.0.")
        .setPositiveButton("OK", nil)
        .setCancelable(false)
        .show()

    -- ✅ 3.0 ACTIVE (अगर वर्ज़न 3.0 है, या 'nil' है, तो भी यही चलेगा!)
    else
        
        -- 🌟 सीक्रेट बीटा स्विच 
        local mySecretBetaCode = "Mayank@123"
        if _G.topTitle then
            _G.topTitle.setOnLongClickListener(View.OnLongClickListener{
                onLongClick = function(v)
                    local f = io.open(devFile, "r")
                    if f then
                        AlertDialog.Builder(patchActivity)
                        .setTitle("👨‍💻 Beta Mode Active")
                        .setMessage("क्या आप Beta टेस्टिंग से बाहर निकलकर Public वर्ज़न में जाना चाहते हैं?")
                        .setPositiveButton("Yes", function()
                            f:close(); os.remove(devFile)
                            Toast.makeText(patchActivity, "🌍 Public Mode ON", 1).show()
                        end).show()
                    else
                        local codeInput = EditText(patchActivity)
                        codeInput.setHint("Enter Secret Beta Code...")                        
                        AlertDialog.Builder(patchActivity)
                        .setTitle("🔒 Beta Access")
                        .setView(codeInput)
                        .setPositiveButton("Unlock", function()
                            if tostring(codeInput.getText() or "") == mySecretBetaCode then
                                local fw = io.open(devFile, "w")
                                if fw then fw:write("active"); fw:close() end
                                Toast.makeText(patchActivity, "🎉 Welcome to Beta Team!", 1).show()
                            else
                                Toast.makeText(patchActivity, "❌ Invalid Code!", 1).show()
                            end
                        end).show()
                    end
                    return true
                end
            })
        end

        local isBetaUser = false
        local f_check = io.open(devFile, "r")
        if f_check then isBetaUser = true; f_check:close() end

        -- 📁 3.0 पैच फाइल्स
        local patchList = {
            "https://raw.githubusercontent.com/teamsp32-cell/Nova-pad/main/patch_find.lua",
            "https://raw.githubusercontent.com/teamsp32-cell/Nova-pad/main/patch_tools.lua"
        }

        if isBetaUser then
            Toast.makeText(patchActivity, "🛠️ Beta Mode Active", 0).show()
        end

        -- 🚀 बुलेटप्रूफ पैच रनर (क्रैश प्रूफ इंजन)
        for i, url in ipairs(patchList) do
            Http.get(url, function(code, content)
                if code == 200 and content and #content > 5 then
                    local func, err = load(content)
                    if func then
                        local ok, runErr = pcall(func)
                        if not ok and isBetaUser then
                            Toast.makeText(patchActivity, "Run Error: " .. tostring(runErr), 1).show()
                        end
                    elseif isBetaUser then
                        Toast.makeText(patchActivity, "Syntax Error in: " .. url, 1).show()
                    end
                end
            end)
        end
    end
end)
