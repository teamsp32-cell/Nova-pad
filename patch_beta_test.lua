-- 🚀 NOVA PAD - PRO UX BETA PATCH 🚀
-- 100% Working Find & Replace (Auto-Trim & Reader Mode Support)

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
-- 2. 🔄 स्मार्ट फाइंड एंड रिप्लेस (The Ultimate Fix)
-- ==========================================
local function openFindAndReplace()
    local layout = LinearLayout(patchActivity)
    layout.setOrientation(LinearLayout.VERTICAL)
    layout.setPadding(40, 20, 40, 20)

    local editFind = EditText(patchActivity)
    editFind.setHint("पुराना शब्द (क्या ढूँढना है?)")
    
    local editReplace = EditText(patchActivity)
    editReplace.setHint("नया शब्द (किससे बदलना है?)")

    layout.addView(editFind)
    layout.addView(editReplace)

    local dlg = AlertDialog.Builder(patchActivity)
    .setTitle("🔄 फाइंड एंड रिप्लेस")
    .setView(layout)
    .setPositiveButton("सब बदलें", nil)
    .setNegativeButton("बंद करें", nil)
    .show()

    local posBtn = dlg.getButton(AlertDialog.BUTTON_POSITIVE)
    posBtn.setOnClickListener(View.OnClickListener{
        onClick = function()
            -- 🔥 THE FIX: दोनों शब्दों के आगे-पीछे के फालतू स्पेस हटाना (Auto-Trim)
            local findText = editFind.getText().toString():gsub("^%s*(.-)%s*$", "%1")
            local replaceText = editReplace.getText().toString():gsub("^%s*(.-)%s*$", "%1")
            
            if #findText == 0 then
                Toast.makeText(patchActivity, "पुराना शब्द डालना ज़रूरी है!", 0).show()
                return
            end
            
            local jFind = String(findText)
            local jReplace = String(replaceText)
            local success = false
            
            -- 1. एडिटर मोड (Editor) में चेक और रिप्लेस करें
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
            
            -- 2. रीडर मोड (Reader) में चेक और रिप्लेस करें
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
                Toast.makeText(patchActivity, "✨ कमाल! सारे '" .. findText .. "' को '" .. replaceText .. "' में बदल दिया गया!", 1).show()
                dlg.dismiss()
            else
                Toast.makeText(patchActivity, "❌ '" .. findText .. "' शब्द फाइल में कहीं नहीं मिला!", 1).show()
            end
        end
    })
end

-- ==========================================
-- 3. ✂️ कॉपी बटन का ओवरराइड (स्मार्ट क्लिपबोर्ड के लिए)
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
        "🔄 फाइंड एंड रिप्लेस (बल्क में शब्द बदलें)",
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
            elseif position == 1 then openFindAndReplace() 
            elseif position == 2 then _G.smartClipboardEnabled = not _G.smartClipboardEnabled; Toast.makeText(patchActivity, "स्मार्ट क्लिपबोर्ड टॉगल किया गया!", 0).show()
            elseif position == 3 then toggleCurtain()
            elseif position == 4 then toggleVolumeNav()
            end
        end
    })
end

Toast.makeText(patchActivity, "✨ Pro UX Patch Loaded! (Smart Replacer Fix)", 1).show()
