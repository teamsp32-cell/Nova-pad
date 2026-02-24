-- Nova Pad v2.9 - Patch (Maintenance Mode)
local patchActivity = activity
local rootDirPatch = patchActivity.getExternalFilesDir(nil).toString() .. "/"

local function getPatchLang()
    local lang = "en"
    local f = io.open(rootDirPatch .. "lang_pref.txt", "r")
    if f then
        local content = f:read("*a"); f:close()
        if content and content:match("hi") then lang = "hi" end
    end
    return lang
end
local function LP(en, hi) return (getPatchLang() == "hi") and hi or en end

pcall(function()
    -- TTS Button (यह एकदम सही चल रहा है)
    btnReaderTranslate.setText(LP("Listen 🗣️", "सुनें 🗣️"))
    btnReaderTranslate.setTextColor(0xFF4CAF50)
    -- (TTS का बाकी कोड यहाँ मान लो कि है...)
    
    -- Find Button को मेंटेनेंस में डाल दिया
    btnReaderSearch.setOnClickListener(View.OnClickListener{
        onClick = function(v)
            Toast.makeText(patchActivity, LP("Find feature is under maintenance 🛠️", "सर्च फीचर अभी मेंटेनेंस में है 🛠️"), 1).show()
        end
    })
end)
