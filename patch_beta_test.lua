-- 🚀 NOVA PAD - PRO UX BETA PATCH 🚀
-- एंड्रॉइड की मेमोरी लिमिट को बायपास करने वाला 'Hidden Editor Hack'

require "import"
import "android.view.*"
import "android.widget.*"
import "android.app.AlertDialog"
import "android.graphics.Color"
import "java.lang.System"
import "java.lang.String" 
import "android.content.*"

local patchActivity = activity
local rootDirPatch = patchActivity.getExternalFilesDir(nil).toString() .. "/"

-- 💾 ग्लोबल वेरिएबल्स
_G.betaClipboard = _G.betaClipboard or {"[खाली]", "[खाली]", "[खाली]"}
_G.smartClipboardEnabled = _G.smartClipboardEnabled or false
_G.volNavEnabled = _G.volNavEnabled or false
_G.curtainView = _G.curtainView or nil

-- 🎯 THE HACK: स्क्रीन के बजाय सीधे 'छुपे हुए एडिटर' से पूरी कहानी निकालना
local function getFullRawText()
    local fullText = ""
    
    -- 1. मास्टर सोर्स: बैकग्राउंड में छुपे एडिटर से टेक्स्ट खींचो (यहाँ 100% टेक्स्ट होता है)
    pcall(function()
        if noteEditor and noteEditor.getText() then
            fullText = tostring(noteEditor.getText())
        end
    end)
    
    -- 2. बैकअप सोर्स: अगर एडिटर नहीं मिला, तो ग्लोबल मेमोरी चेक करो
    if #fullText:gsub("%s+", "") < 5 then
        if _G.currentFullText then
            fullText = _G.currentFullText
        end
    end
    
    return fullText
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
            
            if content == "[खाली]" then Toast.makeText(patchActivity, "यह स्लॉट खाली है!", 0).show() return end
            
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
                        end
                    elseif pos2 == 1 then
                        local i = Intent(Intent.ACTION_SEND); i.setType("text/plain"); i.putExtra(Intent.EXTRA_TEXT, content)
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
-- 2. 🗺️ रीडर मोड स्ट्रक्चर जम्पर (Raw Fetch Engine)
-- ==========================================
local function openStructureJumperReader()
    local text = getFullRawText() -- 🔥 यहाँ हमारा नया जुगाड़ काम कर रहा है!
    
    if #text:gsub("%s+", "") == 0 then 
        Toast.makeText(patchActivity, "कोई टेक्स्ट नहीं मिला!", 0).show() 
        return 
    end
    
    text = text:gsub("\r\n", "\n"):gsub("\r", "\n")
    local lines = {}
    local positions = {}
    local paraNum = 1
    local currentPos = 0
    
    local javaText = String(text)
    local linesArray = javaText.split("\n")
    
    for i = 0, linesArray.length - 1 do
        local lineObj = linesArray[i]
        local luaLine = tostring(lineObj)
        
        local trimmed = luaLine:gsub("^%s+", ""):gsub("%s+$", "")
        
        if #trimmed > 2 then
            table.insert(lines, "पैराग्राफ " .. paraNum .. " ➡️ " .. string.sub(trimmed, 1, 40) .. "...")
            table.insert(positions, currentPos)
            paraNum = paraNum + 1
        end
        
        currentPos = currentPos + lineObj.length() + 1
    end
    
    if #lines == 0 then 
        Toast.makeText(patchActivity, "कोई पैराग्राफ नहीं मिला!", 0).show() 
        return 
    end
    
    local lv = ListView(patchActivity)
    lv.setAdapter(ArrayAdapter(patchActivity, android.R.layout.simple_list_item_1, lines))
    
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
                    
                    local layout = readerBody.getLayout()
                    if layout then
                        local lineNum = layout.getLineForOffset(targetPos)
                        local y = layout.getLineTop(lineNum)
                        
                        pcall(function() readerBody.scrollTo(0, y) end)
                        if scrollFullText then scrollFullText.scrollTo(0, y) end
                    end
                end
            end)
            Toast.makeText(patchActivity, "📌 पैराग्राफ " .. (position + 1) .. " पर पहुँच गए!", 0).show()
        end
    })
end

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
-- 3. ✂️ कॉपी बटन का ओवरराइड
-- ==========================================
pcall(function()
    if btnReaderCopy then
        btnReaderCopy.setOnClickListener(nil)
        btnReaderCopy.setOnClickListener(View.OnClickListener{
            onClick = function()
                local textToCopy = getFullRawText() -- 🔥 यहाँ भी वही मास्टर हैक
                if #textToCopy:gsub("%s+", "") == 0 then return end
                
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
-- 4. 🧰 स्मार्ट टूल्स मेनू
-- ==========================================
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
        "🥷 प्राइवेसी कर्टेन (Black Screen)",
        "🔊 वॉल्यूम कर्सर टॉगल: " .. volStatus
    }
    
    local lv = ListView(patchActivity)
    lv.setAdapter(ArrayAdapter(patchActivity, android.R.layout.simple_list_item_1, opts))
    local dlg = AlertDialog.Builder(patchActivity).setTitle("🧰 स्मार्ट टेक्स्ट टूल्स").setView(lv).setNegativeButton("बंद करें", nil).show()
    
    lv.setOnItemClickListener(AdapterView.OnItemClickListener{
        onItemClick = function(parent, view, position, id)
            dlg.dismiss()
            if position == 0 then openClipboardManager()
            elseif position == 1 then _G.smartClipboardEnabled = not _G.smartClipboardEnabled; Toast.makeText(patchActivity, "स्मार्ट क्लिपबोर्ड टॉगल किया गया!", 0).show()
            elseif position == 2 then toggleCurtain()
            elseif position == 3 then toggleVolumeNav()
            end
        end
    })
end

Toast.makeText(patchActivity, "✨ Pro UX Patch Loaded! (Hidden Editor Hack ON)", 1).show()
