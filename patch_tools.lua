-- 🌐 NOVA PAD - FULL PUBLIC MASTER BUILD 🌐
-- Features: Clipboard, Find/Replace (FIXED), Curtain + Original Smart Tools

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
        hi = { empty = "[खाली]", slot_empty = "यह स्लॉट खाली है!", clip_title = "📋 क्लिपबोर्ड मैनेजर", slot = "स्लॉट", paste = "📋 पेस्ट करें", share = "📤 शेयर करें", clear = "🗑️ डिलीट करें", pasted = "पेस्ट हो गया!", open_editor = "पहले एडिटर खोलें!", cleared = "स्लॉट साफ!", fnr_title = "🔄 फाइंड एंड रिप्लेस", find_hint = "पुराना शब्द", replace_hint = "नया शब्द", replace_all = "सब बदलें", req_find = "पुराना शब्द डालना ज़रूरी है!", success_fnr = "✨ कमाल! शब्द बदल दिए गए!", fail_fnr = "❌ शब्द नहीं मिला!", curtain_on = "🥷 प्राइवेसी कर्टेन चालू!", curtain_off = "कर्टेन हट गया" },
        en = { empty = "[Empty]", slot_empty = "This slot is empty!", clip_title = "📋 Clipboard Manager", slot = "Slot", paste = "📋 Paste", share = "📤 Share", clear = "🗑️ Clear", pasted = "Pasted!", open_editor = "Open the Editor first!", cleared = "Slot cleared!", fnr_title = "🔄 Find & Replace", find_hint = "Old Word", replace_hint = "New Word", replace_all = "Replace All", req_find = "Old word is required!", success_fnr = "✨ Awesome! Words replaced!", fail_fnr = "❌ Word not found!", curtain_on = "🥷 Privacy Curtain ON!", curtain_off = "Curtain removed" }
    }

    local function getPatchLang()
        local lang = "en"
        local rootDirPatch = publicActivity.getExternalFilesDir(nil).toString() .. "/"
        local f = io.open(rootDirPatch .. "lang_pref.txt", "r")
        if f then local content = f:read("*a"); f:close(); if content and content:match("hi") then lang = "hi" end end
        return lang
    end
    _G.appLanguage = getPatchLang()
    local function L(key) return langData[_G.appLanguage][key] or langData["en"][key] or key end

    -- =======================================================
    -- 🌟 1. हमारे नए जादुई फीचर्स (NEW FEATURES)
    -- =======================================================

    _G.openClipboardManager = function()
        pcall(function()
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
                    if _G.betaClipboard[pos+1] == "[Empty]" or _G.betaClipboard[pos+1] == "[खाली]" then Toast.makeText(publicActivity, L("slot_empty"), 0).show(); return end
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
                                _G.betaClipboard[pos+1] = L("empty"); Toast.makeText(publicActivity, L("cleared"), 0).show()
                            end
                        end
                    })
                end
            })
        end)
    end

    -- 🚨 BUG FIX: Bulletproof Find & Replace Engine 🚨
    _G.showFindReplace = function()
        pcall(function()
            local l = LinearLayout(publicActivity); l.setOrientation(1); l.setPadding(50,20,50,20)
            local f = EditText(publicActivity); f.setHint(L("find_hint")); local r = EditText(publicActivity); r.setHint(L("replace_hint"))
            l.addView(f); l.addView(r)
            
            AlertDialog.Builder(publicActivity).setTitle(L("fnr_title")).setView(l).setPositiveButton(L("replace_all"), function()
                
                -- 🚨 असली क्रैश कैचर बटन क्लिक के अंदर!
                local btnOk, btnErr = pcall(function()
                    local ft = tostring(f.getText() or "")
                    local rt = tostring(r.getText() or "")
                    
                    if #ft > 0 then 
                        local JString = luajava.bindClass("java.lang.String")
                        -- Lua String को Java String में बदलना (Hindi Text Fix)
                        local jContent = JString.valueOf(tostring(noteEditor.getText() or ""))
                        local jFt = JString.valueOf(ft)
                        local jRt = JString.valueOf(rt)
                        
                        if jContent.contains(jFt) then
                            -- सुरक्षित रिप्लेसमेंट और उसे वापस Lua स्ट्रिंग बनाना
                            local nc = jContent.replace(jFt, jRt):toString()
                            noteEditor.setText(nc)
                            
                            pcall(function() if toneGen then toneGen.startTone(24, 100) end end)
                            Toast.makeText(publicActivity, L("success_fnr"), 0).show()
                        else 
                            Toast.makeText(publicActivity, L("fail_fnr"), 0).show() 
                        end
                    else 
                        Toast.makeText(publicActivity, L("req_find"), 0).show() 
                    end
                end)
                
                -- अगर अब भी कोई एरर आया तो यह तुम्हें स्क्रीन पर बता देगा
                if not btnOk then 
                    AlertDialog.Builder(publicActivity)
                    .setTitle("🚨 Replace Action Error")
                    .setMessage(tostring(btnErr))
                    .setPositiveButton("OK", nil)
                    .show() 
                end

            end).show()
        end)
    end

    _G.togglePrivacyCurtain = function()
        pcall(function()
            local wm = publicActivity.getSystemService(Context.WINDOW_SERVICE)
            if _G.curtainView then
                wm.removeView(_G.curtainView); _G.curtainView = nil; Toast.makeText(publicActivity, L("curtain_off"), 0).show()
            else
                _G.curtainView = FrameLayout(publicActivity); _G.curtainView.setBackgroundColor(0xFF000000)
                local params = WindowManager.LayoutParams(WindowManager.LayoutParams.MATCH_PARENT, WindowManager.LayoutParams.MATCH_PARENT, WindowManager.LayoutParams.TYPE_APPLICATION, WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE, PixelFormat.TRANSLUCENT)
                wm.addView(_G.curtainView, params); Toast.makeText(publicActivity, L("curtain_on"), 0).show()
                _G.curtainView.setOnClickListener(View.OnClickListener{onClick = function() _G.togglePrivacyCurtain() end})
            end
        end)
    end

    -- =======================================================
    -- 🎯 2. THE MASTER OVERRIDE (तुम्हारे + मेरे फीचर्स का कॉम्बिनेशन)
    -- =======================================================
    
    local Pattern = luajava.bindClass("java.util.regex.Pattern")
    
    _G.openSmartTextCleaner = function()
        local text = ""
        if noteEditor then text = noteEditor.getText().toString() end
        
        local opts = {
            "📞 Extract Phone Numbers", "🔗 Extract Links", 
            "✂️ Remove Symbols", "🗑️ Remove Emojis", 
            "✨ Auto-Format Article", "🗣️ Read Text Aloud (TTS)", 
            "🔠 Convert to UPPERCASE", "🔡 Convert to lowercase",
            "📋 Clipboard Manager",      -- New 1
            "🔄 Find & Replace",         -- New 2
            "🥷 Privacy Curtain"         -- New 3
        }
        
        showNovaMenu("🧰 Smart Text Tools", opts, function(w)
            local JString = luajava.bindClass("java.lang.String")
            local jText = JString.valueOf(text)
            
            if w == 0 then
                if #text == 0 then Toast.makeText(activity, "Write something first!", 0).show(); return end
                local matcher = Pattern.compile("(?:\\+?\\d{1,3}[- ]?)?\\d{10}").matcher(jText); local nums = {}; while matcher.find() do table.insert(nums, matcher.group()) end
                if #nums > 0 then activity.getSystemService(Context.CLIPBOARD_SERVICE).setPrimaryClip(ClipData.newPlainText("Nums", table.concat(nums, "\n"))); Toast.makeText(activity, #nums.." Numbers Copied!", 0).show() else Toast.makeText(activity, "No numbers found.", 0).show() end
            elseif w == 1 then
                if #text == 0 then Toast.makeText(activity, "Write something first!", 0).show(); return end
                local matcher = Pattern.compile("https?://[a-zA-Z0-9\\-\\.]+\\.[a-zA-Z]{2,}(/\\S*)?").matcher(jText); local links = {}; while matcher.find() do table.insert(links, matcher.group()) end
                if #links > 0 then activity.getSystemService(Context.CLIPBOARD_SERVICE).setPrimaryClip(ClipData.newPlainText("Links", table.concat(links, "\n"))); Toast.makeText(activity, #links.." Links Copied!", 0).show() else Toast.makeText(activity, "No links found.", 0).show() end
            elseif w == 2 then noteEditor.setText(jText.replaceAll("[*#_~`|^]", "")); Toast.makeText(activity, "Symbols removed!", 0).show()
            elseif w == 3 then noteEditor.setText(jText.replaceAll("[\\x{1F300}-\\x{1F6FF}|\\x{2600}-\\x{26FF}|\\x{2700}-\\x{27BF}|\\x{1F900}-\\x{1F9FF}|\\x{1F1E6}-\\x{1F1FF}]", "")); Toast.makeText(activity, "Emojis removed!", 0).show()
            elseif w == 4 then local ft = jText.replaceAll(" +", " "); ft = ft.replaceAll("([.,])([A-Za-z\\u0900-\\u097F])", "$1 $2"); noteEditor.setText(ft.trim()); Toast.makeText(activity, "Formatted beautifully!", 0).show() 
            elseif w == 5 then 
                if #text == 0 then Toast.makeText(activity, "Write something first!", 0).show(); return end
                import "android.speech.tts.TextToSpeech"
                import "java.util.Locale"
                local ttsOpts = {"🇮🇳 Read in Hindi", "🇬🇧 Read in English", "⚙️ Voice Settings", "⏹️ Stop Reading"}
                showNovaMenu("TTS Options", ttsOpts, function(tIdx)
                    if tIdx == 2 then pcall(function() activity.startActivity(Intent("com.android.settings.TTS_SETTINGS")) end)
                    elseif tIdx == 3 then if _G.tts_player then _G.tts_player.stop() end; Toast.makeText(activity, "Stopped Reading ⏹️", 0).show()
                    else
                        Toast.makeText(activity, "Starting Reader... 🗣️", 0).show()
                        local loc = Locale("hi", "IN"); if tIdx == 1 then loc = Locale("en", "US") end
                        if _G.tts_player == nil then
                           _G.tts_player = TextToSpeech(activity, TextToSpeech.OnInitListener{
                              onInit = function(status) if status == TextToSpeech.SUCCESS then _G.tts_player.setLanguage(loc); _G.tts_player.speak(text, TextToSpeech.QUEUE_FLUSH, nil) end end
                           })
                        else _G.tts_player.setLanguage(loc); _G.tts_player.speak(text, TextToSpeech.QUEUE_FLUSH, nil) end
                    end
                end)
            elseif w == 6 then noteEditor.setText(string.upper(text)); Toast.makeText(activity, "Converted to UPPERCASE! 🔠", 0).show()
            elseif w == 7 then noteEditor.setText(string.lower(text)); Toast.makeText(activity, "Converted to lowercase! 🔡", 0).show()
            
            -- 🔥 मेरे 3 नए फीचर्स (8, 9, 10) 🔥
            elseif w == 8 then _G.openClipboardManager()
            elseif w == 9 then _G.showFindReplace()
            elseif w == 10 then _G.togglePrivacyCurtain()
            end
        end)
    end

end)

-- साइलेंट एरर कैचर (बैकग्राउंड के लिए)
if not ok then print("Tools Patch Error: " .. tostring(err)) end
