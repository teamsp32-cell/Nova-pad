-- 🌐 NOVA PAD - FULL PUBLIC MASTER BUILD 🌐
-- Features: Find/Replace, Clipboard, Curtain (Silent Load + SUPER RADAR)

local ok, err = pcall(function()
    require "import"
    import "android.view.*"
    import "android.widget.*"
    import "android.app.AlertDialog"
    import "android.graphics.Color"
    import "java.lang.System"
    import "java.lang.String" 
    import "android.content.*"
    import "android.graphics.PixelFormat"

    local publicActivity = activity

    -- ⚙️ ग्लोबल सेटिंग्स
    _G.betaClipboard = _G.betaClipboard or {"[Empty]", "[Empty]", "[Empty]"}
    _G.smartClipboardEnabled = _G.smartClipboardEnabled or false
    _G.curtainView = _G.curtainView or nil

    -- 🌍 लैंग्वेज डिक्शनरी
    local langData = {
        hi = {
            empty = "[खाली]", slot_empty = "यह स्लॉट खाली है!", clip_title = "📋 क्लिपबोर्ड मैनेजर",
            slot = "स्लॉट", paste = "📋 पेस्ट करें", share = "📤 शेयर करें", clear = "🗑️ डिलीट करें",
            pasted = "पेस्ट हो गया!", open_editor = "पहले एडिटर (Editor) खोलें!", cleared = "स्लॉट साफ!",
            fnr_title = "🔄 फाइंड एंड रिप्लेस", find_hint = "पुराना शब्द", replace_hint = "नया शब्द",
            replace_all = "सब बदलें", close = "बंद करें", req_find = "पुराना शब्द डालना ज़रूरी है!",
            success_fnr = "✨ कमाल! शब्द बदल दिए गए!", fail_fnr = "❌ यह शब्द फाइल में नहीं मिला!",
            copied = "कॉपी हो गया!", nothing_copy = "कॉपी करने के लिए कुछ नहीं मिला!",
            where_copy = "कहाँ कॉपी करें?", save_slot = "में सेव करें",
            curtain_on = "🥷 प्राइवेसी कर्टेन चालू!", curtain_off = "कर्टेन हट गया"
        },
        en = {
            empty = "[Empty]", slot_empty = "This slot is empty!", clip_title = "📋 Clipboard Manager",
            slot = "Slot", paste = "📋 Paste", share = "📤 Share", clear = "🗑️ Clear",
            pasted = "Pasted!", open_editor = "Open the Editor first!", cleared = "Slot cleared!",
            fnr_title = "🔄 Find & Replace", find_hint = "Old Word", replace_hint = "New Word",
            replace_all = "Replace All", close = "Close", req_find = "Old word is required!",
            success_fnr = "✨ Awesome! Words replaced!", fail_fnr = "❌ Word not found in file!",
            copied = "Copied!", nothing_copy = "Nothing found to copy!",
            where_copy = "Where to copy?", save_slot = "Save to",
            curtain_on = "🥷 Privacy Curtain ON!", curtain_off = "Curtain removed"
        }
    }

    local function getPatchLang()
        local lang = "en"
        local rootDirPatch = publicActivity.getExternalFilesDir(nil).toString() .. "/"
        local f = io.open(rootDirPatch .. "lang_pref.txt", "r")
        if f then
            local content = f:read("*a"); f:close()
            if content and content:match("hi") then lang = "hi" end
        end
        return lang
    end
    _G.appLanguage = getPatchLang()
    local function L(key) return langData[_G.appLanguage][key] or langData["en"][key] or key end

    -- 📋 1. SMART CLIPBOARD
    _G.smartCopy = function(txt)
        local opOk, opErr = pcall(function()
            if not txt or #txt == 0 then Toast.makeText(publicActivity, L("nothing_copy"), 0).show(); return end
            local opts = {L("slot").." 1", L("slot").." 2", L("slot").." 3"}
            local lv = ListView(publicActivity)
            lv.setAdapter(ArrayAdapter(publicActivity, android.R.layout.simple_list_item_1, opts))
            local dlg = AlertDialog.Builder(publicActivity).setTitle(L("where_copy")).setView(lv).show()
            lv.setOnItemClickListener(AdapterView.OnItemClickListener{
                onItemClick = function(p,v,pos,id)
                    dlg.dismiss()
                    _G.betaClipboard[pos+1] = txt
                    Toast.makeText(publicActivity, L("copied").." ("..L("slot").." "..(pos+1)..")", 0).show()
                end
            })
        end)
        if not opOk then AlertDialog.Builder(publicActivity).setTitle("🚨 Crash in smartCopy").setMessage(tostring(opErr)).show() end
    end

    _G.openClipboardManager = function()
        local opOk, opErr = pcall(function()
            local items = {}
            for i=1,3 do 
                local preview = string.sub(_G.betaClipboard[i], 1, 30)
                if string.len(_G.betaClipboard[i]) > 30 then preview = preview .. "..." end
                table.insert(items, L("slot").." "..i..": " .. preview) 
            end
            local lv = ListView(publicActivity)
            lv.setAdapter(ArrayAdapter(publicActivity, android.R.layout.simple_list_item_1, items))
            local dlg = AlertDialog.Builder(publicActivity).setTitle(L("clip_title")).setView(lv).show()
            lv.setOnItemClickListener(AdapterView.OnItemClickListener{
                onItemClick = function(p,v,pos,id)
                    dlg.dismiss()
                    if _G.betaClipboard[pos+1] == "[Empty]" or _G.betaClipboard[pos+1] == "[खाली]" then
                        Toast.makeText(publicActivity, L("slot_empty"), 0).show(); return
                    end
                    local opts = {L("paste"), L("share"), L("clear")}
                    local lvOpts = ListView(publicActivity)
                    lvOpts.setAdapter(ArrayAdapter(publicActivity, android.R.layout.simple_list_item_1, opts))
                    local dlgOpts = AlertDialog.Builder(publicActivity).setTitle(L("slot").." "..(pos+1)).setView(lvOpts).show()
                    lvOpts.setOnItemClickListener(AdapterView.OnItemClickListener{
                        onItemClick = function(p2,v2,pos2,id2)
                            dlgOpts.dismiss()
                            if pos2 == 0 then
                                if noteEditor and noteEditor.getVisibility() == 0 then
                                    noteEditor.getText().insert(noteEditor.getSelectionStart(), _G.betaClipboard[pos+1])
                                    Toast.makeText(publicActivity, L("pasted"), 0).show()
                                else Toast.makeText(publicActivity, L("open_editor"), 0).show() end
                            elseif pos2 == 1 then
                                local i = Intent(Intent.ACTION_SEND); i.setType("text/plain"); i.putExtra(Intent.EXTRA_TEXT, _G.betaClipboard[pos+1])
                                publicActivity.startActivity(Intent.createChooser(i, L("share")))
                            elseif pos2 == 2 then
                                _G.betaClipboard[pos+1] = L("empty")
                                Toast.makeText(publicActivity, L("cleared"), 0).show()
                            end
                        end
                    })
                end
            })
        end)
        if not opOk then AlertDialog.Builder(publicActivity).setTitle("🚨 Crash in openClipboardManager").setMessage(tostring(opErr)).show() end
    end

    -- 🔄 2. FIND & REPLACE
    _G.showFindReplace = function()
        local opOk, opErr = pcall(function()
            local l = LinearLayout(publicActivity); l.setOrientation(1); l.setPadding(50,20,50,20)
            local f = EditText(publicActivity); f.setHint(L("find_hint"))
            local r = EditText(publicActivity); r.setHint(L("replace_hint"))
            l.addView(f); l.addView(r)
            AlertDialog.Builder(publicActivity)
            .setTitle(L("fnr_title")).setView(l)
            .setPositiveButton(L("replace_all"), function()
                local ft = f.getText().toString()
                local rt = r.getText().toString()
                if #ft > 0 then 
                    local JString = luajava.bindClass("java.lang.String")
                    local jContent = JString.valueOf(noteEditor.getText().toString())
                    if jContent.contains(ft) then
                        local nc = jContent.replace(ft, rt) 
                        noteEditor.setText(nc)
                        pcall(function() if toneGen then toneGen.startTone(24, 100) end end)
                        Toast.makeText(publicActivity, L("success_fnr"), 0).show()
                    else Toast.makeText(publicActivity, L("fail_fnr"), 0).show() end
                else Toast.makeText(publicActivity, L("req_find"), 0).show() end
            end).show()
        end)
        if not opOk then AlertDialog.Builder(publicActivity).setTitle("🚨 Crash in showFindReplace").setMessage(tostring(opErr)).show() end
    end

    -- 🥷 3. PRIVACY CURTAIN
    _G.togglePrivacyCurtain = function()
        local opOk, opErr = pcall(function()
            local wm = publicActivity.getSystemService(Context.WINDOW_SERVICE)
            if _G.curtainView then
                wm.removeView(_G.curtainView)
                _G.curtainView = nil
                Toast.makeText(publicActivity, L("curtain_off"), 0).show()
            else
                _G.curtainView = FrameLayout(publicActivity)
                _G.curtainView.setBackgroundColor(0xFF000000)
                local params = WindowManager.LayoutParams(WindowManager.LayoutParams.MATCH_PARENT, WindowManager.LayoutParams.MATCH_PARENT, WindowManager.LayoutParams.TYPE_APPLICATION, WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE, PixelFormat.TRANSLUCENT)
                wm.addView(_G.curtainView, params)
                Toast.makeText(publicActivity, L("curtain_on"), 0).show()
                _G.curtainView.setOnClickListener(View.OnClickListener{
                    onClick = function() _G.togglePrivacyCurtain() end
                })
            end
        end)
        if not opOk then AlertDialog.Builder(publicActivity).setTitle("🚨 Crash in togglePrivacyCurtain").setMessage(tostring(opErr)).show() end
    end

    -- =======================================================
    -- 🤖 4. THE SUPER RADAR (Auto-Finder)
    -- =======================================================
    pcall(function()
        -- यह फंक्शन स्क्रीन के हर हिस्से को स्कैन करेगा
        local function scanForSmartTool(view)
            local ok, count = pcall(function() return view.getChildCount() end)
            if ok and count then
                for i = 0, count - 1 do
                    local child = view.getChildAt(i)
                    
                    -- टॉकबैक जो पढ़ता है (ContentDescription) चेक करो
                    local okDesc, desc = pcall(function() return tostring(child.getContentDescription() or ""):lower() end)
                    if okDesc and desc ~= "" then
                        if desc:find("टूल बॉक्स") or desc:find("smart text tool") or desc:find("toolbox") then
                            return child
                        end
                    end
                    
                    -- बटन पर जो लिखा है (Text) वो चेक करो
                    local okTxt, txt = pcall(function() return tostring(child.getText() or ""):lower() end)
                    if okTxt and txt ~= "" then
                        if txt:find("टूल बॉक्स") or txt:find("smart text tool") or txt:find("toolbox") then
                            return child
                        end
                    end
                    
                    -- अंदर के फोल्डर्स (Views) में जाओ
                    local found = scanForSmartTool(child)
                    if found then return found end
                end
            end
            return nil
        end

        -- पूरे स्क्रीन के रूट व्यू से स्कैनिंग शुरू करो
        local rootView = publicActivity.getWindow().getDecorView()
        local mySmartBtn = scanForSmartTool(rootView)
        
        -- अगर राडार को कुछ नहीं मिला, तो पुराने नाम भी चेक कर लो
        if not mySmartBtn then
            mySmartBtn = SmartTextTools or smartTextTools or smart_text_tools or btnSmartTextTools or toolbox or tool_box or btnToolbox
        end

        if mySmartBtn then
            -- 🌟 राडार ने बटन पकड़ लिया! अब क्लिक लगा दो 🌟
            mySmartBtn.setOnClickListener(View.OnClickListener{
                onClick = function()
                    local opOk, opErr = pcall(function()
                        local opts = {"📋 Clipboard Manager", "🔄 Find & Replace", "🥷 Privacy Curtain"}
                        local lv = ListView(publicActivity)
                        lv.setAdapter(ArrayAdapter(publicActivity, android.R.layout.simple_list_item_1, opts))
                        local dlg = AlertDialog.Builder(publicActivity).setTitle("🧰 Smart Text Tools").setView(lv).show()
                        
                        lv.setOnItemClickListener(AdapterView.OnItemClickListener{
                            onItemClick = function(p,v,pos,id)
                                dlg.dismiss()
                                if pos == 0 then _G.openClipboardManager()
                                elseif pos == 1 then _G.showFindReplace()
                                elseif pos == 2 then _G.togglePrivacyCurtain()
                                end
                            end
                        })
                    end)
                    if not opOk then AlertDialog.Builder(publicActivity).setTitle("🚨 Crash").setMessage(tostring(opErr)).show() end
                end
            })
        else
            -- 🚨 अगर सुपर राडार भी फेल हो जाए!
            AlertDialog.Builder(publicActivity)
            .setTitle("⚠️ Ultimate Radar Failed!")
            .setMessage("राडार को 'टूल बॉक्स' नाम की कोई चीज़ स्क्रीन पर नहीं मिली।\n\nप्लीज़ एक बार अपना Source Code (layout) खोलकर देखो कि उसका असली id क्या है!")
            .setPositiveButton("OK", nil)
            .show()
        end
    end)

end)

if not ok then
    local act = activity or _G.activity
    if act then
        local AlertDialog = luajava.bindClass("android.app.AlertDialog")
        AlertDialog.Builder(act).setTitle("🚨 Patch Load Crash!").setMessage(tostring(err)).show()
    end
end
