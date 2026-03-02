-- 🎛️ NOVA PAD 3.0 - MASTER REMOTE CONTROL 🎛️
-- इस फाइल से तुम पूरे ऐप को कंट्रोल कर सकते हो!

local app_control = {
    -- 🛑 मेंटेनेंस मोड (इसे true करते ही दुनिया भर में ऐप लॉक हो जाएगा)
    maintenance = false, 
    maintenance_message = "सर्वर अपग्रेड चल रहा है। कृपया कुछ समय बाद वापस आएं!",
    
    -- 🔐 फीचर कंट्रोल (true = चालू, false = बंद)
    features = {
        smart_clipboard = true,
        find_replace = true,
        privacy_curtain = true,
        vol_cursor = true
    }
}

return app_control
