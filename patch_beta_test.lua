-- 🚀 NOVA PAD - PRO UX BETA PATCH 🚀
-- 100% Numbered Paragraph Combo Box & Auto-Scroll

require "import"
import "android.view.*"
import "android.widget.*"
import "android.app.AlertDialog"
import "android.graphics.Color"
import "java.lang.System"
import "android.content.*"

local patchActivity = activity
local rootDirPatch = patchActivity.getExternalFilesDir(nil).toString() .. "/"

-- 💾 ग्लोबल वेरिएबल्स
_G.betaClipboard = _G.betaClipboard or {"[खाली]", "[खाली]", "[खाली]"}
_G.smartClipboardEnabled = _G.smartClipboardEnabled or false
_G.volNavEnabled = _G.volNavEnabled or false
_G.curtainView = _G.curtainView or nil

-- 🔍 स्क्रीन से टेक्स्ट उठाने का फंक्शन
local function getVisibleText()
    local biggestText = ""
    pcall(function()
        if noteEditor and noteEditor.getText() then
            local t = tostring(noteEditor.getText())
            if #t > #biggestText then biggestText = t end
        end
    end)
    if #biggestText:gsub("%s+", "") < 5 then
        local function scanViews(v)
            pcall(function()
                if v and v.getText then
                    local t = tostring(v.getText())
                    if #t > #biggestText then biggestText = t end
                end
            end)
            pcall(function()
                if v and v.getChildCount then
                    for i = 0, v.getChildCount() - 1 do
                        scanViews(v.getChildAt(i))
                    end
                end
            end)
        end
        pcall(function()
            local rootView = patchActivity.getWindow().getDecorView()
            scanViews(rootView)
        end)
    end
    return biggestText
end

-- ==========================================
-- 1. 📋 स्मार्ट क्लिपबोर्ड मैनेजर
-- ==========================================
local function openClipboardManager()
    local opts = {
        "स्लॉट 1: " .. string.sub(_G.betaClipboard[1], 1, 20) .. "...",
        "स्लॉट 2: " .. string.sub(_G.betaClipboard[2], 1, 20) .. "...",
        "स्लॉट 3: " .. string.sub(_G.betaClipboard[3], 1, 20) .. "..."
    }
    
    local lv = ListView(patchActivity)
    lv.setAdapter(ArrayAdapter(patchActivity, android.R.layout.simple_list_item_1, opts))
    
    local dlg = AlertDialog.Builder(patchActivity).setTitle("📋 क्लिपबोर्ड मैनेजर").setView(lv).setNegativeButton("बंद करें", nil).show()

    lv.setOnItemClickListener(AdapterView.OnItemClickListener{
        onItemClick = function(parent, view, position, id)
            dlg.dismiss()
            local slotIndex = position + 1
            local content = _G.betaClipboard[slotIndex]
            
            if content == "[खाली]" then
                Toast.makeText(patchActivity, "यह स्लॉट खाली है!", 0).show()
                return
            end
            
            local actionOpts = {"📋 टेक्स्ट पेस्ट करें (Paste)", "📤 शेयर करें (Share)", "🗑️ डिलीट करें (Clear)"}
            local actLv = ListView(patchActivity)
            actLv.setAdapter(ArrayAdapter(patchActivity, android.R.layout.simple_list_item_1, actionOpts))
            
            local actDlg = AlertDialog.Builder(patchActivity).setTitle("स्लॉट " .. slotIndex .. " ऑप्शंस").setView(actLv).show()
            actLv.setOnItemClickListener(AdapterView.OnItemClickListener{
                onItemClick = function(p, v, pos2, i2)
                    actDlg.dismiss()
                    if pos2 == 0 then
                        if noteEditor and noteEditor.getVisibility() == 0 then
                            noteEditor.getText().insert(noteEditor.getSelectionStart(), content)
                            Toast.makeText(patchActivity, "पेस्ट हो गया!", 0).show()
                        else
                            Toast.makeText(patchActivity, "पहले एडिटर खोलें!", 0).show()
                        end
                    elseif pos2 == 1 then
                        local i = Intent(Intent.ACTION_SEND)
                        i.setType("text/plain")
                        i.putExtra(Intent.EXTRA_TEXT, content)
                        patchActivity.startActivity(Intent.createChooser(i, "टेक्स्ट शेयर करें"))
                    elseif pos2 == 2 then
                        _G.betaClipboard[slotIndex] = "[खाली]"
                        Toast.makeText(patchActivity, "स्लॉट साफ कर दिया गया!", 0).show()
                    end
                end
            })
        end
    })
end

-- ==========================================
-- 2. 🗺️ रीडर मोड स्ट्रक्चर जम्पर (Number Combo Box)
-- ==========================================
local function openStructureJumperReader()
    local text = getVisibleText()
    
    if #text:gsub("%s+", "") == 0 then 
        Toast.makeText(patchActivity, "स्क्रीन पर कोई टेक्स्ट नहीं मिला!", 0).show() 
        return 
    end
    
    text = text:gsub("\r\n", "\n")
    local lines = {}
    local positions = {}
    local paraNum = 1
    
    local startIdx = 1
    while true do
        local endIdx = string.find(text, "\n", startIdx)
        local line
        if endIdx then
            line = string.sub(text, startIdx, endIdx - 1)
        else
            line = string.sub(text, startIdx)
        end
        
        local trimmed = line:gsub("^%s+", ""):gsub("%s+$", "")
        if #trimmed > 0 then
            -- 🔥 नया कोंबो बॉक्स डिज़ाइन (TalkBack फ्रेंडली)
            table.insert(lines, "पैराग्राफ " .. paraNum .. " ➡️ " .. string.sub(trimmed, 1, 15) .. "...")
            table.insert(positions, startIdx - 1) 
            paraNum = paraNum + 1
        end
        
        if not endIdx then break end
        startIdx = endIdx + 1
    end
    
    if #lines == 0 then 
        Toast.makeText(patchActivity, "कोई पैराग्राफ नहीं मिला!", 0).show() 
        return 
    end
    
    local lv = ListView(patchActivity)
    lv.setAdapter(ArrayAdapter(patchActivity, android.R.layout.simple_list_item_1, lines))
    
    -- 🔥 हेडिंग में टोटल पैराग्राफ काउंट
    local dlg = AlertDialog.Builder(patchActivity)
    .setTitle("📊 कुल " .. #lines .. " पैराग्राफ मिले")
    .setView(lv)
    .setNegativeButton("बंद करें", nil)
    .show()
    
    lv.setOnItemClickListener(AdapterView.OnItemClickListener{
        onItemClick = function(parent, view, position, id)
            dlg.dismiss()
            local targetPos = positions[position + 1]
            
            pcall(function()
                if readerBody then
                    readerBody.requestFocus()
                    
                    if readerBody.setSelection then
                        readerBody.setSelection(targetPos)
                    end
                    
                    -- 🔥 100% पक्का ऑटो-स्क्रोल फिक्स
                    local layout = readerBody.getLayout()
                    if layout then
                        local lineNum = layout.getLineForOffset(targetPos)
                        local y = layout.getLineTop(lineNum)
                        
                        -- अगर खुद TextView स्क्रॉल होता है
                        pcall(function() readerBody.scrollTo(0, y) end)
                        
                        -- अगर ScrollView के अंदर है
                        if scrollFullText then
                            scrollFullText.scrollTo(0, y)
                        end
                    end
                end
            end)
            Toast.makeText(patchActivity, "📌 पैराग्राफ " .. (position + 1) .. " पर आ गए!", 0).show()
        end
    })
end

-- 🔥 'Find' बटन पर Long-Press जम्पर सेट
pcall(function()
    if btnReaderSearch then
        btnReaderSearch.setOnLongClickListener(View.OnLongClickListener{
            onLongClick = function()
                openStructureJumperReader()
                return true
            end
        })
    end
end)

-- ==========================================
-- 3. ✂️ कॉपी बटन का ओवरराइड (रीडर मोड के लिए)
-- ==========================================
pcall(function()
    if btnReaderCopy then
        btnReaderCopy.setOnClickListener(nil)
        btnReaderCopy.setOnClickListener(View.OnClickListener{
            onClick = function()
                local textToCopy = getVisibleText()
                
                if #textToCopy:gsub("%s+", "") == 0 then
                    Toast.makeText(patchActivity, "कॉपी करने के लिए कुछ नहीं मिला!", 0).show()
                    return
                end
                
                if _G.smartClipboardEnabled then
                    local opts = {"स्लॉट 1 में सेव करें", "स्लॉट 2 में सेव करें", "स्लॉट 3 में सेव करें"}
                    local lv = ListView(patchActivity)
                    lv.setAdapter(ArrayAdapter(patchActivity, android.R.layout.simple_list_item_1, opts))
                    local dlg = AlertDialog.Builder(patchActivity).setTitle("कहाँ कॉपी करें?").setView(lv).show()
                    
                    lv.setOnItemClickListener(AdapterView.OnItemClickListener{
                        onItemClick = function(p, v, pos, id)
                            dlg.dismiss()
                            _G.betaClipboard[pos + 1] = textToCopy
                            Toast.makeText(patchActivity, "स्लॉट " .. (pos + 1) .. " में कॉपी हो गया!", 0).show()
                        end
                    })
                else
                    patchActivity.getSystemService(Context.CLIPBOARD_SERVICE).setPrimaryClip(ClipData.newPlainText("Nova", textToCopy))
                    Toast.makeText(patchActivity, "पूरा टेक्स्ट कॉपी हो गया!", 0).show()
                end
            end
        })
    end
end)

-- ==========================================
-- 4. 🧰 स्मार्ट टूल्स का ओवरराइड (सब कुछ एक जगह)
-- ==========================================
local function cleanTextSmartly()
    local text = getVisibleText()
    if noteEditor and noteEditor.getVisibility() == 0 then
        local cleanText = text:gsub(" +", " "):gsub("\n%s*\n+", "\n\n")
        noteEditor.setText(cleanText)
        Toast.makeText(patchActivity, "✨ टेक्स्ट एकदम साफ कर दिया गया!", 0).show()
    else
        Toast.makeText(patchActivity, "पहले एडिटर (Editor) खोलें!", 0).show()
    end
end

local function toggleCurtain()
    if _G.curtainView then
        local parent = _G.curtainView.getParent()
        if parent then parent.removeView(_G.curtainView) end
        _G.curtainView = nil
        Toast.makeText(patchActivity, "कर्टेन हट गया", 0).show()
    else
        _G.curtainView = FrameLayout(patchActivity)
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
        patchActivity.getWindow().addContentView(_G.curtainView, params)
        Toast.makeText(patchActivity, "🥷 प्राइवेसी कर्टेन चालू! (डबल टैप से हटाएं)", 1).show()
    end
end

local function toggleVolumeNav()
    _G.volNavEnabled = not _G.volNavEnabled
    if _G.volNavEnabled then
        if not _G.old_onKeyDown then _G.old_onKeyDown = onKeyDown end
        _G.onKeyDown = function(code, event)
            if _G.volNavEnabled and noteEditor and noteEditor.isFocused() then
                if code == 24 then -- Vol UP
                    local layout = noteEditor.getLayout()
                    if layout then
                        local currentLine = layout.getLineForOffset(noteEditor.getSelectionStart())
                        if currentLine > 0 then
                            noteEditor.setSelection(layout.getLineStart(currentLine - 1))
                            return true
                        end
                    end
                elseif code == 25 then -- Vol DOWN
                    local layout = noteEditor.getLayout()
                    if layout then
                        local currentLine = layout.getLineForOffset(noteEditor.getSelectionStart())
                        if currentLine < layout.getLineCount() - 1 then
                            noteEditor.setSelection(layout.getLineStart(currentLine + 1))
                            return true
                        end
                    end
                end
            end
            if _G.old_onKeyDown then return _G.old_onKeyDown(code, event) end
        end
        Toast.makeText(patchActivity, "🔊 वॉल्यूम कर्सर चालू हो गया!", 0).show()
    else
        Toast.makeText(patchActivity, "🔊 वॉल्यूम कर्सर बंद कर दिया गया।", 0).show()
    end
end

_G.openSmartTextCleaner = function()
    local cbStatus = _G.smartClipboardEnabled and "ON 🟢" or "OFF 🔴"
    local volStatus = _G.volNavEnabled and "ON 🟢" or "OFF 🔴"
    
    local opts = {
        "📋 क्लिपबोर्ड मैनेजर (Share/Paste)",
        "✂️ स्मार्ट क्लिपबोर्ड टॉगल: " .. cbStatus,
        "🧹 स्मार्ट टेक्स्ट क्लीनर (Space/Lines)",
        "🥷 प्राइवेसी कर्टेन (Black Screen)",
        "🔊 वॉल्यूम कर्सर टॉगल: " .. volStatus,
        "📞 फोन नंबर निकालें",
        "🔗 लिंक्स निकालें",
        "🗣️ टेक्स्ट पढ़ें (TTS)"
    }
    
    local lv = ListView(patchActivity)
    lv.setAdapter(ArrayAdapter(patchActivity, android.R.layout.simple_list_item_1, opts))
    
    local dlg = AlertDialog.Builder(patchActivity).setTitle("🧰 स्मार्ट टेक्स्ट टूल्स").setView(lv).setNegativeButton("बंद करें", nil).show()
    
    lv.setOnItemClickListener(AdapterView.OnItemClickListener{
        onItemClick = function(parent, view, position, id)
            dlg.dismiss()
            if position == 0 then openClipboardManager()
            elseif position == 1 then 
                _G.smartClipboardEnabled = not _G.smartClipboardEnabled
                Toast.makeText(patchActivity, "स्मार्ट क्लिपबोर्ड टॉगल किया गया!", 0).show()
            elseif position == 2 then cleanTextSmartly()
            elseif position == 3 then toggleCurtain()
            elseif position == 4 then toggleVolumeNav()
            elseif position == 5 then Toast.makeText(patchActivity, "यह पुराना फीचर है, ऊपर के नए ट्राई करें!", 0).show()
            end
        end
    })
end

Toast.makeText(patchActivity, "✨ Pro UX Patch Loaded! (Numbered Combo Box Fix)", 1).show()
