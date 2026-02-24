-- Nova Pad - Find Button (Maintenance Mode for Public)

local patchActivity = activity
local rootDirPatch = patchActivity.getExternalFilesDir(nil).toString() .. "/"

-- भाषा सेट करने का फॉर्मूला
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
    -- 🛠️ FIND BUTTON (MAINTENANCE MODE) 🛠️
    -- जब भी कोई फाइंड बटन दबाएगा, तो ऐप क्रैश होने के बजाय यह मैसेज दिखाएगा
    btnReaderSearch.setOnClickListener(View.OnClickListener{
        onClick = function(v)
            Toast.makeText(patchActivity, LP("Find feature is under maintenance 🛠️", "सर्च फीचर अभी मेंटेनेंस में है 🛠️"), 1).show()
        end
    })
end)
