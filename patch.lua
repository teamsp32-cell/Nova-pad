-- 🌟 LIVE PATCH v10: Auto-Popup Notice + Menu Notice Board + Meditation Loop + TTS 🌟

import "android.media.MediaPlayer"
import "android.speech.tts.TextToSpeech"
import "java.util.Locale"

-- 🔥 1. FORCE LOOP AUDIO PLAYER (म्यूज़िक फिक्स)
function controlAmbientAudio(url, title)
  if ambientPlayer then 
     pcall(function() ambientPlayer.stop() end)
     pcall(function() ambientPlayer.release() end)
     ambientPlayer = nil 
  end
  if url then
    Toast.makeText(activity, "Loading "..title.." ⏳", 0).show()
    ambientPlayer = MediaPlayer()
    ambientPlayer.setDataSource(url)
    ambientPlayer.setLooping(true) 
    ambientPlayer.setOnCompletionListener(MediaPlayer.OnCompletionListener{
        onCompletion=function(mp) mp.seekTo(0); mp.start() end
    })
    ambientPlayer.prepareAsync()
    ambientPlayer.setOnPreparedListener(MediaPlayer.OnPreparedListener{onPrepared=function(mp) mp.start(); Toast.makeText(activity, "Playing "..title.." 🎶", 0).show() end})
    ambientPlayer.setOnErrorListener(MediaPlayer.OnErrorListener{onError=function(mp, w, e) Toast.makeText(activity, "Stream failed.", 0).show(); return true end})
  else 
    Toast.makeText(activity, "Music Stopped ⏹️", 0).show() 
  end
end

-- 🎧 2. MEDITATION MENU
function showAmbientMenu()
  local opts = {
      "🧘 ध्यान संगीत 1 (Meditation 1)", "🧘 ध्यान संगीत 2 (Meditation 2)", "🧘 ध्यान संगीत 3 (Meditation 3)", 
      "🌧️ बारिश की आवाज़ (Rain Sounds)", "🎵 लो-फाई बीट्स (Lofi Study)", "🎹 रिलैक्सिंग पियानो (Relaxing Piano)", "⏹️ बंद करें (Stop)"
  }
  showNovaMenu("ध्यान और फोकस (Meditation)", opts, function(w)
    if w==0 then controlAmbientAudio("https://raw.githubusercontent.com/teamsp32-cell/Nova-pad/main/Meditation%20Music%20(1).mp3", "Meditation 1")
    elseif w==1 then controlAmbientAudio("https://raw.githubusercontent.com/teamsp32-cell/Nova-pad/main/Meditation%20music%202.mp3", "Meditation 2")
    elseif w==2 then controlAmbientAudio("https://raw.githubusercontent.com/teamsp32-cell/Nova-pad/main/Meditation%20Music%20-%201%2C.mp3", "Meditation 3")
    elseif w==3 then controlAmbientAudio("https://actions.google.com/sounds/v1/weather/rain_heavy_loud.ogg", "Rain Sounds")
    elseif w==4 then controlAmbientAudio("https://streams.ilovemusic.de/iloveradio17.mp3", "Lofi Beats")
    elseif w==5 then controlAmbientAudio("https://streams.ilovemusic.de/iloveradio18.mp3", "Relaxing Piano")
    elseif w==6 then controlAmbientAudio(nil) end
  end)
end

-- 🧰 3. SMART TEXT TOOLS (TTS & Case Converter)
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
    elseif w == 5 then 
        local ttsOpts = {"🇮🇳 Read in Hindi", "🇬🇧 Read in English", "⚙️ Voice Settings (Phone)", "⏹️ Stop Reading"}
        showNovaMenu("TTS Options", ttsOpts, function(tIdx)
            if tIdx == 2 then
                pcall(function() activity.startActivity(Intent("com.android.settings.TTS_SETTINGS")) end)
            elseif tIdx == 3 then
                if tts_player then tts_player.stop() end
                Toast.makeText(activity, "Stopped Reading ⏹️", 0).show()
            else
                Toast.makeText(activity, "Starting Reader... 🗣️", 0).show()
                local loc = Locale("hi", "IN")
                if tIdx == 1 then loc = Locale("en", "US") end
                if tts_player == nil then
                   tts_player = TextToSpeech(activity, TextToSpeech.OnInitListener{
                      onInit = function(status) if status == TextToSpeech.SUCCESS then tts_player.setLanguage(loc); tts_player.speak(text, TextToSpeech.QUEUE_FLUSH, nil) end end
                   })
                else tts_player.setLanguage(loc); tts_player.speak(text, TextToSpeech.QUEUE_FLUSH, nil) end
            end
        end)
    elseif w == 6 then noteEditor.setText(string.upper(text)); Toast.makeText(activity, "Converted to UPPERCASE! 🔠", 0).show()
    elseif w == 7 then noteEditor.setText(string.lower(text)); Toast.makeText(activity, "Converted to lowercase! 🔡", 0).show()
    end
  end)
end

-- 📢 4. MAIN MENU OVERRIDE ('Notice Board' बटन के साथ)
function showToolsMenu()
  local opts = {
     "🔔 सूचनाएं (Notice Board)", 
     "Stats ON/OFF", "🎧 Ambient Focus Mode", "🧰 Smart Text Tools", 
     "📑 Add Bullet Points", "🧹 Clean Empty Lines", "🗑️ Remove Duplicate Lines", 
     "Focus Mode", "Rhyme Finder", "Thesaurus", "Snippet Manager", 
     "Copy All", "Share", "Aa Text Size", "🚀 More Features >", "⚙️ Settings >"
  }
  showNovaMenu("Menu", opts, function(w)
     if w==0 then 
        Toast.makeText(activity, "सूचनाएं चेक की जा रही हैं... ⏳", 0).show()
        Http.get("https://raw.githubusercontent.com/teamsp32-cell/Nova-pad/main/notice.txt", function(code, content)
           if code == 200 and content and #content > 2 then
              AlertDialog.Builder(activity).setTitle("📢 Notice Board").setMessage(content).setPositiveButton("Close", nil).show()
           else
              Toast.makeText(activity, "अभी कोई नई सूचना नहीं है।", 0).show()
           end
        end)
     elseif w==1 then toggleStats()
     elseif w==2 then showAmbientMenu()
     elseif w==3 then openSmartTextCleaner()
     elseif w==4 then addBulletPoints()
     elseif w==5 then cleanEmptyLines()
     elseif w==6 then removeDuplicateLines()
     elseif w==7 then if topBar.getVisibility()==0 then topBar.setVisibility(8); bottomNav.setVisibility(8); Toast.makeText(activity,"Focus ON",0).show() else topBar.setVisibility(0); bottomNav.setVisibility(0) end
     elseif w==8 then local e=EditText(activity); AlertDialog.Builder(activity).setTitle("Rhyme").setView(e).setPositiveButton("Go",function() activity.startActivity(Intent(Intent.ACTION_VIEW,Uri.parse("https://google.com/search?q=rhyme+"..e.getText().toString()))) end).show()
     elseif w==9 then local e=EditText(activity); AlertDialog.Builder(activity).setTitle("Thesaurus").setView(e).setPositiveButton("Go",function() activity.startActivity(Intent(Intent.ACTION_VIEW,Uri.parse("https://google.com/search?q=synonym+"..e.getText().toString()))) end).show()
     elseif w==10 then showSnippetManager()
     elseif w==11 then activity.getSystemService(Context.CLIPBOARD_SERVICE).setPrimaryClip(ClipData.newPlainText("NP",noteEditor.getText().toString())); Toast.makeText(activity,"Copied",0).show()
     elseif w==12 then local i=Intent(Intent.ACTION_SEND); i.setType("text/plain"); i.putExtra(Intent.EXTRA_TEXT,noteEditor.getText().toString()); activity.startActivity(Intent.createChooser(i,"Share"))
     elseif w==13 then showTextSizeDialog()
     elseif w==14 then showPremiumSubMenu()
     elseif w==15 then switchTab(3) end
  end)
end

-- 🚨 5. AUTO-POPUP NOTICE ENGINE (सिर्फ नई सूचना होने पर खुलेगा)
function checkGlobalNotice()
   local noticeUrl = "https://raw.githubusercontent.com/teamsp32-cell/Nova-pad/main/notice.txt"
   local localNoticeFile = activity.getExternalFilesDir(nil).toString() .. "/last_notice.txt"

   Http.get(noticeUrl, function(code, content)
      if code == 200 and content and #content > 2 then
         local f = io.open(localNoticeFile, "r")
         local lastNotice = ""
         if f then lastNotice = f:read("*a"); f:close() end

         if content ~= lastNotice then
            AlertDialog.Builder(activity)
            .setTitle("📢 Nova Pad नई सूचना")
            .setMessage(content)
            .setPositiveButton("ठीक है", {onClick=function(d)
                local fw = io.open(localNoticeFile, "w")
                if fw then fw:write(content); fw:close() end
                d.dismiss()
            end})
            .setCancelable(false)
            .show()
         end
      end
   end)
end

pcall(checkGlobalNotice)
