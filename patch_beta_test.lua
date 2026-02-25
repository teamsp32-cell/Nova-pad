-- 🚀 NOVA PAD BETA HUB (5-in-1 Super Patch) 🚀
-- सिर्फ Beta यूज़र्स के लिए (Menu बटन लॉन्ग-प्रेस)

require "import"
import "android.view.*"
import "android.widget.*"
import "android.app.AlertDialog"
import "android.graphics.Color"
import "java.lang.System"

local patchActivity = activity

-- ग्लोबल वेरिएबल्स (ताकि डेटा सेव रहे)
_G.betaClipboard = _G.betaClipboard or {"[खाली]", "[खाली]", "[खाली]"}
_G.volNavEnabled = _G.volNavEnabled or false
_G.curtainView = _G.curtainView or nil

-- 1. 📋 मल्टी-स्लॉट क्लिपबोर्ड लॉजिक
local function openMultiClipboard()
    local opts = {
        "स्लॉट 1: " .. string.sub(_G.betaClipboard[1], 1, 15) .. "...",
        "स्लॉट 2: " .. string.sub(_G.betaClipboard[2], 1, 15) .. "...",
        "स्लॉट 3: " .. string.sub(_G.betaClipboard[3], 1, 15) .. "..."
    }
    
    local lv = ListView(patchActivity)
    lv.setAdapter(ArrayAdapter(patchActivity, android.R.layout.simple_list_item_1, opts))
    
    local dlg = AlertDialog.Builder(patchActivity)
    .setTitle("📋 मल्टी-क्लिपबोर्ड")
    .setView(lv)
    .setNegativeButton("बंद करें", nil)
    .show()

    lv.setOnItemClickListener(AdapterView.OnItemClickListener{
        onItemClick = function(parent, view, position, id)
            dlg.dismiss()
            local slotIndex = position + 1
            local actionOpts = {"📝 यहाँ सेव करें (Copy)", "📋 यहाँ से पेस्ट करें (Paste)"}
            
            local actLv = ListView(patchActivity)
            actLv.setAdapter(ArrayAdapter(patchActivity, android.R.layout.simple_list_item_1, actionOpts))
            
            local actDlg = AlertDialog.Builder(patchActivity).setTitle("स्लॉट " .. slotIndex).setView(actLv).show()
            actLv.setOnItemClickListener(AdapterView.OnItemClickListener{
                onItemClick = function(p, v, pos2, i2)
                    actDlg.dismiss()
                    if pos2 == 0 then
                        -- Copy
                        local selectedText = noteEditor.getText().toString()
                        local startSel = noteEditor.getSelectionStart()
                        local endSel = noteEditor.getSelectionEnd()
                        if startSel ~= endSel then
                            selectedText = string.sub(selectedText, startSel + 1, endSel)
                        else
                            Toast.makeText(patchActivity, "पूरा टेक्स्ट कॉपी हो रहा है...", 0).show()
                        end
                        _G.betaClipboard[slotIndex] = selectedText
                        Toast.makeText(patchActivity, "स्लॉट " .. slotIndex .. " में सेव हो गया!", 0).show()
                    else
                        -- Paste
                        if _G.betaClipboard[slotIndex] == "[खाली]" then
                            Toast.makeText(patchActivity, "यह स्लॉट खाली है!", 0).show()
                        else
                            noteEditor.getText().insert(noteEditor.getSelectionStart(), _G.betaClipboard[slotIndex])
                            Toast.makeText(patchActivity, "पेस्ट हो गया!", 0).show()
                        end
                    end
                end
            })
        end
    })
end

-- 2. 🗺️ स्ट्रक्चर जम्पर (Outline Navigator)
local function openStructureJumper()
    local text = noteEditor.getText().toString()
    if #text == 0 then Toast.makeText(patchActivity, "पहले कुछ लिखें!", 0).show() return end
    
    local lines = {}
    local positions = {}
    local currentPos = 0
    
    for line in string.gmatch(text .. "\n", "(.-)\n") do
        if #line:gsub("%s+", "") > 0 then
            table.insert(lines, "📌 " .. string.sub(line, 1, 30) .. "...")
            table.insert(positions, currentPos)
        end
        currentPos = currentPos + #line + 1
    end
    
    local lv = ListView(patchActivity)
    lv.setAdapter(ArrayAdapter(patchActivity, android.R.layout.simple_list_item_1, lines))
    
    local dlg = AlertDialog.Builder(patchActivity).setTitle("🗺️ पैराग्राफ जम्पर").setView(lv).show()
    lv.setOnItemClickListener(AdapterView.OnItemClickListener{
        onItemClick = function(parent, view, position, id)
            noteEditor.setSelection(positions[position + 1])
            noteEditor.requestFocus()
            Toast.makeText(patchActivity, "कर्सर सेट हो गया!", 0).show()
            dlg.dismiss()
        end
    })
end

-- 3. 🧹 स्मार्ट टेक्स्ट क्लीनर
local function cleanTextSmartly()
    local text = noteEditor.getText().toString()
    local cleanText = text:gsub(" +", " "):gsub("\n%s*\n+", "\n\n")
    noteEditor.setText(cleanText)
    Toast.makeText(patchActivity, "✨ टेक्स्ट एकदम साफ कर दिया गया!", 0).show()
end

-- 4. 🥷 प्राइवेसी कर्टेन मोड
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
                if clickTime - lastClickTime < 300 then
                    toggleCurtain() 
                end
                lastClickTime = clickTime
            end
        })
        
        local params = ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT)
        patchActivity.getWindow().addContentView(_G.curtainView, params)
        Toast.makeText(patchActivity, "🥷 प्राइवेसी कर्टेन चालू! (हटाने के लिए स्क्रीन पर डबल टैप करें)", 1).show()
    end
end

-- 5. 🔊 वॉल्यूम कर्सर कंट्रोल
local function toggleVolumeNav()
    _G.volNavEnabled = not _G.volNavEnabled
    if _G.volNavEnabled then
        if not _G.old_onKeyDown then _G.old_onKeyDown = onKeyDown end
        _G.onKeyDown = function(code, event)
            if _G.volNavEnabled and noteEditor.isFocused() then
                if code == 24 then 
                    local layout = noteEditor.getLayout()
                    if layout then
                        local currentLine = layout.getLineForOffset(noteEditor.getSelectionStart())
                        if currentLine > 0 then
                            noteEditor.setSelection(layout.getLineStart(currentLine - 1))
                            return true
                        end
                    end
                elseif code == 25 then 
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

-- 🛠️ मुख्य बीटा हब मेनू
local function openBetaHub()
    local opts = {
        "1. 📋 मल्टी-स्लॉट क्लिपबोर्ड",
        "2. 🗺️ स्ट्रक्चर जम्पर (पैराग्राफ खोजें)",
        "3. 🧹 स्मार्ट टेक्स्ट क्लीनर",
        "4. 🥷 प्राइवेसी कर्टेन (Black Screen)",
        "5. 🔊 वॉल्यूम कर्सर (ON/OFF)"
    }
    
    local lv = ListView(patchActivity)
    lv.setAdapter(ArrayAdapter(patchActivity, android.R.layout.simple_list_item_1, opts))
    
    local dlg = AlertDialog.Builder(patchActivity)
    .setTitle("🧪 Beta Features Hub")
    .setView(lv)
    .setNegativeButton("बंद करें", nil)
    .show()

    lv.setOnItemClickListener(AdapterView.OnItemClickListener{
        onItemClick = function(parent, view, position, id)
            dlg.dismiss()
            if position == 0 then openMultiClipboard()
            elseif position == 1 then openStructureJumper()
            elseif position == 2 then cleanTextSmartly()
            elseif position == 3 then toggleCurtain()
            elseif position == 4 then toggleVolumeNav()
            end
        end
    })
end

-- 🚀 THE FIX: 'Menu' बटन के लॉन्ग-प्रेस पर बीटा हब लगाना
pcall(function()
    if btnMenuTop then
        btnMenuTop.setOnLongClickListener(View.OnLongClickListener{
            onLongClick = function(v)
                openBetaHub()
                return true -- true का मतलब है कि लॉन्ग-प्रेस का काम हो गया
            end
        })
        -- जैसे ही पैच लोड होगा, यह मैसेज आएगा!
        Toast.makeText(patchActivity, "🧪 Beta पैच लोड हो गया! 'Menu' बटन को लॉन्ग-प्रेस करें।", 1).show()
    end
end)
