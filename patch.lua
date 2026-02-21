-- 🌟 LIVE PATCH v4: Meditation Sounds + Smart TTS Menu 🌟

function showAmbientMenu()
  local opts = {"🕉️ ओम ध्यान (Om Chanting)", "🥣 तिब्बती बाउल (Singing Bowl)", "🌧️ बारिश (Rain Sounds)", "🎵 लो-फाई बीट्स (Lofi Study)", "⏹️ बंद करें (Stop)"}
  showNovaMenu("ध्यान और फोकस (Meditation)", opts, function(w)
    if w==0 then 
        controlAmbientAudio("https://archive.org/download/OmChanting_201602/Om%20Chanting.mp3", "Om Chanting")
    elseif w==1 then 
        controlAmbientAudio("https://upload.wikimedia.org/wikipedia/commons/f/f6/Tibetan_Singing_Bowl.ogg", "Singing Bowl")
    elseif w==2 then 
        controlAmbientAudio("https://actions.google.com/sounds/v1/weather/rain_heavy_loud.ogg", "Rain Sounds")
    elseif w==3 then 
        controlAmbientAudio("https://streams.ilovemusic.de/iloveradio17.mp3", "Lofi Beats")
    elseif w==4 then 
        controlAmbientAudio(nil) 
    end
  end)
end

import "android.speech.tts.TextToSpeech"
import "java.util.Locale"
local tts_player = nil

function openSmartTextCleaner()
  local text = noteEditor.getText().toString()
  if #text == 0 then Toast.makeText(activity, "Write something first!", 0).show(); return end
  
  local opts = {"📞 Extract Phone Numbers", "🔗 Extract Links", "✂️ Remove Symbols", "🗑️ Remove Emojis", "✨ Auto-Format Article", "🗣️ Read Text Aloud (TTS)", "🔠 Convert to UPPERCASE", "🔡 Convert to lowercase"}
  
  showNovaMenu("Smart Text Tools", opts, function(w)
    local jText = String(text)
    if w == 0 then
        local matcher = Pattern.compile("(?:\\+?\\d{1,3}[- ]?)?\\d{10}").matcher(jText); local nums = {}; while matcher.find() do table.insert(nums, matcher.group()) end
        if #nums > 0 then activity.getSystemService(Context.CLIPBOARD_SERVICE).setPrimaryClip(ClipData.newPlainText("Nums", table.concat(nums, "\n"))); Toast.makeText(activity, #nums.." Numbers Copied!", 0).show() else Toast.makeText(activity, "No numbers found.", 0).show() end
    elseif w == 1 then
        local matcher = Pattern.compile("https?://[a-zA-Z0-9\\-\\.]+\\.[a-zA-Z]{2,}(/\\S*)?").matcher(jText); local links = {}; while matcher.find() do table.insert(links, matcher.group()) end
        if #links > 0 then activity.getSystemService(Context.CLIPBOARD_SERVICE).setPrimaryClip(ClipData.newPlainText("Links", table.concat(links, "\n"))); Toast.makeText(activity, #links.." Links Copied!", 0).show() else Toast.makeText(activity, "No links found.", 0).show() end
    elseif w == 2 then noteEditor.setText(jText.replaceAll("[*#_~`|^]", "")); Toast.makeText(activity, "Symbols removed!", 0).show()
    elseif w == 3 then noteEditor.setText(jText.replaceAll("[\\x{1F300}-\\x{1F6FF}|\\x{2600}-\\x{26FF}|\\x{2700}-\\x{27BF}|\\x{1F900}-\\x{1F9FF}|\\x{1F1E6}-\\x{1F1FF}]", "")); Toast.makeText(activity, "Emojis removed!", 0).show()
    elseif w == 4 then local ft = jText.replaceAll(" +", " "); ft = ft.replaceAll("([.,])([A-Za-z\\u0900-\\u097F])", "$1 $2"); noteEditor.setText(ft.trim()); Toast.makeText(activity, "Formatted beautifully!", 0).show() 
    
    -- 🆕 ADVANCED TTS MENU
    elseif w == 5 then 
        local ttsOpts = {"🇮🇳 Read in Hindi", "🇬🇧 Read in English", "⚙️ Voice Settings (Phone)", "⏹️ Stop Reading"}
        showNovaMenu("TTS Options", ttsOpts, function(tIdx)
            if tIdx == 2 then
                local intent = Intent("com.android.settings.TTS_SETTINGS")
                pcall(function() activity.startActivity(intent) end)
            elseif tIdx == 3 then
                if tts_player then tts_player.stop() end
                Toast.makeText(activity, "Stopped Reading ⏹️", 0).show()
            else
                Toast.makeText(activity, "Starting Reader... 🗣️", 0).show()
                local loc = Locale("hi", "IN")
                if tIdx == 1 then loc = Locale("en", "US") end
                
                if tts_player == nil then
                   tts_player = TextToSpeech(activity, TextToSpeech.OnInitListener{
                      onInit = function(status)
                         if status == TextToSpeech.SUCCESS then
                            tts_player.setLanguage(loc)
                            tts_player.speak(text, TextToSpeech.QUEUE_FLUSH, nil)
                         end
                      end
                   })
                else
                   tts_player.setLanguage(loc)
                   tts_player.speak(text, TextToSpeech.QUEUE_FLUSH, nil)
                end
            end
        end)
        
    elseif w == 6 then noteEditor.setText(string.upper(text)); Toast.makeText(activity, "Converted to UPPERCASE! 🔠", 0).show()
    elseif w == 7 then noteEditor.setText(string.lower(text)); Toast.makeText(activity, "Converted to lowercase! 🔡", 0).show()
    end
  end)
end
