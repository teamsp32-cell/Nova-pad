-- 🌐 NOVA PAD - PUBLIC SMART TOOLS (Multi-lingual Build) 🌐

require "import"
import "android.view.*"
import "android.widget.*"
import "android.app.AlertDialog"
import "android.graphics.Color"
import "java.lang.System"
import "java.lang.String" 
import "android.content.*"

local publicActivity = activity

-- ⚙️ ग्लोबल सेटिंग्स और भाषा (Language)
_G.appLanguage = _G.appLanguage or "hi" -- यहाँ "hi" (Hindi) या "en" (English) सेट होगा
_G.betaClipboard = _G.betaClipboard or {"[Empty]", "[Empty]", "[Empty]"}
_G.smartClipboardEnabled = _G.smartClipboardEnabled or false
_G.volNavEnabled = _G.volNavEnabled or false
_G.curtainView = _G.curtainView or nil

-- ==========================================
-- 🌍 1. स्मार्ट भाषा डिक्शनरी (Language Dictionary)
-- ==========================================
local langData = {
    hi = {
        empty = "[खाली]",
        slot_empty = "यह स्लॉट खाली है!",
        clip_title = "📋 क्लिपबोर्ड मैनेजर",
        slot = "स्लॉट",
        paste = "📋 टेक्स्ट पेस्ट करें",
        share = "📤 शेयर करें",
        clear = "🗑️ डिलीट करें",
        pasted = "पेस्ट हो गया!",
        open_editor = "पहले एडिटर (Editor) खोलें!",
        cleared = "स्लॉट साफ कर दिया गया!",
        fnr_title = "🔄 फाइंड एंड रिप्लेस",
        find_hint = "पुराना शब्द (क्या ढूँढना है?)",
        replace_hint = "नया शब्द (किससे बदलना है?)",
        replace_all = "सब बदलें",
        close = "बंद करें",
        req_find = "पुराना शब्द डालना ज़रूरी है!",
        success_fnr = "✨ कमाल! सारे शब्द बदल दिए गए!",
        fail_fnr = "❌ यह शब्द फाइल में कहीं नहीं मिला!",
        copied = "कॉपी हो गया!",
        nothing_copy = "कॉपी करने के लिए कुछ नहीं मिला!",
        where_copy = "कहाँ कॉपी करें?",
        save_slot = "में सेव करें",
        curtain_on = "🥷 प्राइवेसी कर्टेन चालू! (डबल टैप से हटाएं)",
        curtain_off = "कर्टेन हट गया",
        vol_on = "🔊 वॉल्यूम कर्सर चालू हो गया!",
        vol_off = "🔊 वॉल्यूम कर्सर बंद कर दिया गया।",
        tool_title = "🧰 स्मार्ट टेक्स्ट टूल्स",
        tool_clip = "📋 क्लिपबोर्ड मैनेजर (Share/Paste)",
        tool_fnr = "🔄 फाइंड एंड रिप्लेस (शब्द बदलें)",
        tool_smart_clip = "✂️ स्मार्ट क्लिपबोर्ड टॉगल: ",
        tool_curtain = "🥷 प्राइवेसी कर्टेन (Black Screen)",
        tool_vol = "🔊 वॉल्यूम कर्सर टॉगल: ",
        toggled = "टॉगल किया गया!"
    },
    en = {
        empty = "[Empty]",
        slot_empty = "This slot is empty!",
        clip_title = "📋 Clipboard Manager",
        slot = "Slot",
        paste = "📋 Paste Text",
        share = "📤 Share Text",
        clear = "🗑️ Clear Slot",
        pasted = "Pasted successfully!",
        open_editor = "Please open the Editor first!",
        cleared = "Slot cleared!",
        fnr_title = "🔄 Find & Replace",
        find_hint = "Old word (Find)",
        replace_hint = "New word (Replace)",
        replace_all = "Replace All",
        close = "Close",
        req_find = "Old word is required!",
        success_fnr = "✨ Success! Words replaced!",
        fail_fnr = "❌ Word not found in file!",
        copied = "Copied successfully!",
        nothing_copy = "Nothing to copy!",
        where_copy = "Copy to where?",
        save_slot = "Save in Slot",
        curtain_on = "🥷 Privacy Curtain ON! (Double tap to remove)",
        curtain_off = "Curtain removed",
        vol_on = "🔊 Volume Cursor ON!",
        vol_off = "🔊 Volume Cursor OFF!",
        tool_title = "🧰 Smart Text Tools",
        tool_clip = "📋 Clipboard Manager (Share/Paste)",
        tool_fnr = "🔄 Find & Replace (Bulk change)",
        tool_smart_clip = "✂️ Smart Clipboard Toggle: ",
        tool_curtain = "🥷 Privacy Curtain (Black Screen)",
        tool_vol = "🔊 Volume Cursor Toggle: ",
        toggled = "Toggled successfully!"
    }
}

-- 🗣️ यह फंक्शन तुरंत सही भाषा का शब्द निकाल कर देगा
local function L(key)
    local lang = _G.appLanguage or "hi"
    if not langData[lang] then lang = "en" end
    return langData[lang][key] or key
end

-- ==========================================
-- 📋 2. क्लिपबोर्ड मैनेजर (Multilingual)
-- ==========================================
local function openClipboardManager()
    -- खाली स्लॉट्स को वर्तमान भाषा के अनुसार अपडेट करना
    for i=1,3 do
        if _G.betaClipboard[i] == "[खाली]" or _G.betaClipboard[i] == "[Empty]" then
            _G.betaClipboard[i] = L("empty")
        end
    end

    local opts = {
        L("slot") .. " 1: " .. string.sub(_G.betaClipboard[1], 1, 20) .. "...",
        L("slot") .. " 2: " .. string.sub(_G.betaClipboard[2], 1, 20) .. "...",
        L("slot") .. " 3: " .. string.sub(_G.betaClipboard[3], 1, 20) .. "..."
    }
    
    local lv = ListView(publicActivity)
    lv.setAdapter(ArrayAdapter(publicActivity, android.R.layout.simple_list_item_1, opts))
    
    local dlg = AlertDialog.Builder(publicActivity).setTitle(L("clip_title")).setView(lv).setNegativeButton(L("close"), nil).show()

    lv.setOnItemClickListener(AdapterView.OnItemClickListener{
        onItemClick = function(parent, view, position, id)
            dlg.dismiss()
            local slotIndex = position + 1
            local content = _G.betaClipboard[slotIndex]
            
            if content == L("empty") then Toast.makeText(publicActivity, L("slot_empty"), 0).show() return end
            
            local actionOpts = {L("paste"), L("share"), L("clear")}
            local actLv = ListView(publicActivity)
            actLv.setAdapter(ArrayAdapter(publicActivity, android.R.layout.simple_list_item_1, actionOpts))
            
            local actDlg = AlertDialog.Builder(publicActivity).setTitle(L("slot") .. " " .. slotIndex).setView(actLv).show()
            actLv.setOnItemClickListener(AdapterView.OnItemClickListener{
                onItemClick = function(p, v, pos2, i2)
                    actDlg.dismiss()
                    if pos2 == 0 then
                        if noteEditor and noteEditor.getVisibility() == 0 then
                            noteEditor.getText().insert(noteEditor.getSelectionStart(), content)
                            Toast.makeText(publicActivity, L("pasted"), 0).show()
                        else
                            Toast.makeText(publicActivity, L("open_editor"), 0).show()
                        end
                    elseif pos2 == 1 then
                        local i = Intent(Intent.ACTION_SEND); i.setType("text/plain"); i.putExtra(Intent.EXTRA_TEXT, content)
                        publicActivity.startActivity(Intent.createChooser(i, L("share")))
                    elseif pos2 == 2 then
                        _G.betaClipboard[slotIndex] = L("empty")
                        Toast.makeText(publicActivity, L("cleared"), 0).show()
                    end
                end
            })
        end
    })
end

-- ==========================================
-- 🔄 3. स्मार्ट फाइंड एंड रिप्लेस (Multilingual)
-- ==========================================
local function openFindAndReplace()
    local layout = LinearLayout(publicActivity)
    layout.setOrientation(LinearLayout.VERTICAL)
    layout.setPadding(40, 20, 40, 20)

    local editFind = EditText(publicActivity)
    editFind.setHint(L("find_hint"))
    
    local editReplace = EditText(publicActivity)
    editReplace.setHint(L("replace_hint"))

    layout.addView(editFind)
    layout.addView(editReplace)

    local dlg = AlertDialog.Builder(publicActivity)
    .setTitle(L("fnr_title"))
    .setView(layout)
    .setPositiveButton(L("replace_all"), nil)
    .setNegativeButton(L("close"), nil)
    .show()

    local posBtn = dlg.getButton(AlertDialog.BUTTON_POSITIVE)
    posBtn.setOnClickListener(View.OnClickListener{
        onClick = function()
            local findText = tostring(String(editFind.getText().toString()).trim())
            local replaceText = tostring(String(editReplace.getText().toString()).trim())
            
            if #findText == 0 then Toast.makeText(publicActivity, L("req_find"), 0).show() return end
            
            local jFind = String(findText)
            local jReplace = String(replaceText)
            local success = false
            
            pcall(function()
                if noteEditor and noteEditor.getText then
                    local text = tostring(noteEditor.getText())
                    if String(text).contains(jFind) then
                        local newText = String(text).replace(jFind, jReplace)
                        noteEditor.setText(newText)
                        success = true
                    end
                end
            end)
            
            pcall(function()
                if readerBody and readerBody.getText then
                    local text = tostring(readerBody.getText())
                    if String(text).contains(jFind) then
                        local newText = String(text).replace(jFind, jReplace)
                        readerBody.setText(newText)
                        success = true
                    end
                end
            end)

            if success then
                Toast.makeText(publicActivity, L("success_fnr"), 1).show()
                dlg.dismiss()
            else
                Toast.makeText(publicActivity, L("fail_fnr"), 1).show()
            end
        end
    })
end

-- ==========================================
-- ✂️ 4. कॉपी बटन ओवरराइड
-- ==========================================
pcall(function()
    if btnReaderCopy then
        btnReaderCopy.setOnClickListener(nil)
        btnReaderCopy.setOnClickListener(View.OnClickListener{
            onClick = function()
                local textToCopy = ""
                if noteEditor and noteEditor.getVisibility() == 0 then
                    textToCopy = noteEditor.getText().toString()
                elseif readerBody then
                    textToCopy = readerBody.getText().toString()
                end
                
                if #textToCopy:gsub("%s+", "") == 0 then Toast.makeText(publicActivity, L("nothing_copy"), 0).show() return end
                
                if _G.smartClipboardEnabled then
                    local opts = {L("slot").." 1 "..L("save_slot"), L("slot").." 2 "..L("save_slot"), L("slot").." 3 "..L("save_slot")}
                    local lv = ListView(publicActivity)
                    lv.setAdapter(ArrayAdapter(publicActivity, android.R.layout.simple_list_item_1, opts))
                    local dlg = AlertDialog.Builder(publicActivity).setTitle(L("where_copy")).setView(lv).show()
                    
                    lv.setOnItemClickListener(AdapterView.OnItemClickListener{
                        onItemClick = function(p, v, pos, id)
                            dlg.dismiss()
                            _G.betaClipboard[pos + 1] = textToCopy
                            Toast.makeText(publicActivity, L("copied"), 0).show()
                        end
                    })
                else
                    publicActivity.getSystemService(Context.CLIPBOARD_SERVICE).setPrimaryClip(ClipData.newPlainText("Nova", textToCopy))
                    Toast.makeText(publicActivity, L("copied"), 0).show()
                end
            end
        })
    end
end)

-- ==========================================
-- 🧰 5. स्मार्ट टूल्स मेनू (Multilingual)
-- ==========================================
local function toggleCurtain()
    if _G.curtainView then
        local parent = _G.curtainView.getParent()
        if parent then parent.removeView(_G.curtainView) end
        _G.curtainView = nil
        Toast.makeText(publicActivity, L("curtain_off"), 0).show()
    else
        _G.curtainView = FrameLayout(publicActivity)
        _G.curtainView.setBackgroundColor(Color.BLACK)
        _G.curtainView.setClickable(true)
        local lastClickTime = 0
        _G.curtainView.setOnClickListener(View.OnClickListener{
            onClick = function()
                local clickTime = System.currentTimeMillis()
                if clickTime - lastClickTime < 300 then toggleCurtain() end
                lastClickTime = clickTime
            end
        })
        local params = ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT)
        publicActivity.getWindow().addContentView(_G.curtainView, params)
        Toast.makeText(publicActivity, L("curtain_on"), 1).show()
    end
end

local function toggleVolumeNav()
    _G.volNavEnabled = not _G.volNavEnabled
    if _G.volNavEnabled then
        if not _G.old_onKeyDown then _G.old_onKeyDown = onKeyDown end
        _G.onKeyDown = function(code, event)
            if _G.volNavEnabled and noteEditor and noteEditor.isFocused() then
                if code == 24 then
                    local layout = noteEditor.getLayout()
                    if layout then
                        local currentLine = layout.getLineForOffset(noteEditor.getSelectionStart())
                        if currentLine > 0 then noteEditor.setSelection(layout.getLineStart(currentLine - 1)); return true end
                    end
                elseif code == 25 then
                    local layout = noteEditor.getLayout()
                    if layout then
                        local currentLine = layout.getLineForOffset(noteEditor.getSelectionStart())
                        if currentLine < layout.getLineCount() - 1 then noteEditor.setSelection(layout.getLineStart(currentLine + 1)); return true end
                    end
                end
            end
            if _G.old_onKeyDown then return _G.old_onKeyDown(code, event) end
        end
        Toast.makeText(publicActivity, L("vol_on"), 0).show()
    else
        Toast.makeText(publicActivity, L("vol_off"), 0).show()
    end
end

_G.openSmartTextCleaner = function()
    local cbStatus = _G.smartClipboardEnabled and "ON 🟢" or "OFF 🔴"
    local volStatus = _G.volNavEnabled and "ON 🟢" or "OFF 🔴"
    
    local opts = {
        L("tool_clip"),
        L("tool_fnr"),
        L("tool_smart_clip") .. cbStatus,
        L("tool_curtain"),
        L("tool_vol") .. volStatus
    }
    
    local lv = ListView(publicActivity)
    lv.setAdapter(ArrayAdapter(publicActivity, android.R.layout.simple_list_item_1, opts))
    local dlg = AlertDialog.Builder(publicActivity).setTitle(L("tool_title")).setNegativeButton(L("close"), nil).setView(lv).show()
    
    lv.setOnItemClickListener(AdapterView.OnItemClickListener{
        onItemClick = function(parent, view, position, id)
            dlg.dismiss()
            if position == 0 then openClipboardManager()
            elseif position == 1 then openFindAndReplace() 
            elseif position == 2 then _G.smartClipboardEnabled = not _G.smartClipboardEnabled; Toast.makeText(publicActivity, L("toggled"), 0).show()
            elseif position == 3 then toggleCurtain()
            elseif position == 4 then toggleVolumeNav()
            end
        end
    })
end
