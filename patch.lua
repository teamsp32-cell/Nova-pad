-- 🌟 LIVE PATCH v16: 24/7 LIVE RADIO + Multi-Select + Find Fix + Notice + TTS 🌟

import "android.media.MediaPlayer"
import "android.speech.tts.TextToSpeech"
import "java.util.Locale"
import "android.widget.Button"
import "android.view.View"
import "android.text.SpannableString"
import "android.text.style.BackgroundColorSpan"
import "java.lang.String"

-- 🔥 1. FORCE LOOP & STREAM AUDIO PLAYER
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

-- 🎧 2. ULTIMATE MEDITATION & RADIO MENU
function showAmbientMenu()
  local opts = {
      "🧘 ध्यान संगीत 1 (GitHub)", "🧘 ध्यान संगीत 2 (GitHub)", "🧘 ध्यान संगीत 3 (GitHub)", 
      "🌧️ बारिश की आवाज़", "🎵 लो-फाई बीट्स", "🎹 रिलैक्सिंग पियानो",
      "🌌 डीप फोकस रेडियो (24/7 Live)", "🪐 डीप स्पेस रेडियो (24/7 Live)", 
      "🐦 प्रकृति की आवाज़ (24/7 Live)", "🎻 क्लासिकल रेडियो (24/7 Live)",
      "⏹️ बंद करें (Stop)"
  }
  showNovaMenu("ध्यान और फोकस (Meditation)", opts, function(w)
    if w==0 then controlAmbientAudio("https://raw.githubusercontent.com/teamsp32-cell/Nova-pad/main/Meditation%20Music%20(1).mp3", "Meditation 1")
    elseif w==1 then controlAmbientAudio("https://raw.githubusercontent.com/teamsp32-cell/Nova-pad/main/Meditation%20music%202.mp3", "Meditation 2")
    elseif w==2 then controlAmbientAudio("https://raw.githubusercontent.com/teamsp32-cell/Nova-pad/main/Meditation%20Music%20-%201%2C.mp3", "Meditation 3")
    elseif w==3 then controlAmbientAudio("https://actions.google.com/sounds/v1/weather/rain_heavy_loud.ogg", "Rain Sounds")
    elseif w==4 then controlAmbientAudio("https://streams.ilovemusic.de/iloveradio17.mp3", "Lofi Beats")
    elseif w==5 then controlAmbientAudio("https://streams.ilovemusic.de/iloveradio18.mp3", "Relaxing Piano")
    -- 📡 LIVE RADIO STATIONS
    elseif w==6 then controlAmbientAudio("http://ice1.somafm.com/dronezone-128-mp3", "Deep Focus Radio")
    elseif w==7 then controlAmbientAudio("http://ice1.somafm.com/deepspaceone-128-mp3", "Deep Space Radio")
    elseif w==8 then controlAmbientAudio("http://streaming.radio.co/s5c5da6a36/listen", "Nature Sounds")
    elseif w==9 then controlAmbientAudio("http://174.36.206.197:8000/stream", "Classic Radio")
    elseif w==10 then controlAmbientAudio(nil) end
  end)
end

-- 🧰 3. SMART TEXT TOOLS (TTS)
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

-- 🚨 4. AUTO-POPUP NOTICE ENGINE
function checkGlobalNotice()
   local noticeUrl = "https://raw.githubusercontent.com/teamsp32-cell/Nova-pad/main/notice.txt?t=" .. tostring(os.time())
   local localNoticeFile = activity.getExternalFilesDir(nil).toString() .. "/last_notice.txt"

   Http.get(noticeUrl, function(code, content)
      if code == 200 and content and #content > 2 then
         local f = io.open(localNoticeFile, "r")
         local lastNotice = ""
         if f then lastNotice = f:read("*a"); f:close() end

         if content ~= lastNotice then
            AlertDialog.Builder(activity)
            .setTitle("📢 Nova Pad सूचना")
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

-- ✅ 5. MULTI-SELECT ENGINE LOGIC
function showMultiSelectDialog()
    local rootDir = activity.getExternalFilesDir(nil).toString() .. "/"
    local binDir = rootDir .. "RecycleBin/"

    if currentPath == rootDir then
        Toast.makeText(activity, "कृपया पहले कोई फोल्डर (Category) खोलें!", 0).show()
        return
    end

    local files = File(currentPath).listFiles()
    local fileNames = {}
    if files then
        for i=0, #files-1 do
            local n = files[i].getName()
            if n:find(".txt") then table.insert(fileNames, n) end
        end
    end

    if #fileNames == 0 then
        Toast.makeText(activity, "इस फोल्डर में कोई नोट्स नहीं हैं!", 0).show()
        return
    end

    local lv = ListView(activity)
    lv.setChoiceMode(ListView.CHOICE_MODE_MULTIPLE)
    local adp = ArrayAdapter(activity, android.R.layout.simple_list_item_multiple_choice, fileNames)
    lv.setAdapter(adp)

    local dlg = AlertDialog.Builder(activity)
    dlg.setTitle("✅ मल्टी-सेलेक्ट (Multi-Select)")
    dlg.setView(lv)

    dlg.setPositiveButton("🗑️ डिलीट करें", {onClick=function(d)
        local checked = lv.getCheckedItemPositions()
        local count = 0
        for i=0, #fileNames-1 do
            if checked.get(i) then
                local fName = fileNames[i+1]
                os.rename(currentPath.."/"..fName, binDir..fName)
                count = count + 1
            end
        end
        if count > 0 then
            Toast.makeText(activity, count .. " नोट्स डिलीट हो गए!", 0).show()
            if loadFileList then loadFileList(false) end
        else
            Toast.makeText(activity, "कोई नोट सेलेक्ट नहीं किया!", 0).show()
        end
    end})

    dlg.setNeutralButton("📁 फोल्डर बदलें (Move)", {onClick=function(d)
        local checked = lv.getCheckedItemPositions()
        local selectedFiles = {}
        for i=0, #fileNames-1 do
            if checked.get(i) then table.insert(selectedFiles, fileNames[i+1]) end
        end
        if #selectedFiles == 0 then return end

        local cats = {}
        local allFiles = File(rootDir).listFiles()
        if allFiles then
            for i=0, #allFiles-1 do
                if allFiles[i].isDirectory() then
                    local n = allFiles[i].getName()
                    if n ~= "RecycleBin" and not n:find("^%.") then table.insert(cats, n) end
                end
            end
        end

        showNovaMenu("कहाँ Move करना है?", cats, function(w)
            local destFolder = rootDir .. cats[w+1] .. "/"
            for _, fName in ipairs(selectedFiles) do
                local src = currentPath.."/"..fName
                local dst = destFolder..fName
                local f1 = io.open(src, "r")
                if f1 then
                    local c = f1:read("*a"); f1:close()
                    local f2 = io.open(dst, "w+")
                    if f2 then f2:write(c); f2:close(); os.remove(src) end
                end
            end
            Toast.makeText(activity, #selectedFiles.." नोट्स Move हो गए!", 0).show()
            if loadFileList then loadFileList(false) end
        end)
    end})

    dlg.setNegativeButton("कैंसिल", nil)
    dlg.show()
end

pcall(function()
    if btnImport then
        local parent = btnImport.getParent()
        local isAdded = false
        for i=0, parent.getChildCount()-1 do
            local child = parent.getChildAt(i)
            if child.getText and child.getText() == "✅ Multi-Select" then isAdded = true end
        end
        if not isAdded then
            local newBtn = Button(activity)
            newBtn.setText("✅ Multi-Select")
            newBtn.setLayoutParams(btnImport.getLayoutParams()) 
            newBtn.setOnClickListener(View.OnClickListener{onClick=function() showMultiSelectDialog() end})
            parent.addView(newBtn)
        end
    end
end)

-- 🔍 6. SEARCH BUG FIX (Hindi Unicode Support)
if btnReaderSearch then
  btnReaderSearch.setOnClickListener(View.OnClickListener{onClick=function()
    local e = EditText(activity); e.setHint("सर्च करने के लिए शब्द लिखें...")
    AlertDialog.Builder(activity).setTitle("नोटिस में खोजें").setView(e).setPositiveButton("Find", function()
       local query = e.getText().toString()
       if #query > 0 then
          if isParaMode then 
              isParaMode = false; spinReadMode.setSelection(0); updateReaderView() 
              Toast.makeText(activity, "हाईलाइट करने के लिए फुल टेक्स्ट मोड में बदला गया", 1).show()
          end
          local jText = String(currentFullText).toLowerCase()
          local jQuery = String(query).toLowerCase()
          local span = SpannableString(currentFullText)
          local count = 0
          local startPos = jText.indexOf(jQuery)
          while startPos >= 0 do
             count = count + 1
             span.setSpan(BackgroundColorSpan(0xFFFFFF00), startPos, startPos + jQuery.length(), 33)
             startPos = jText.indexOf(jQuery, startPos + jQuery.length())
          end
          if count > 0 then 
              readerBody.setText(span)
              Toast.makeText(activity, "कुल " .. count .. " जगह मिला! (पीले रंग से हाईलाइट किया गया)", 1).show()
          else 
              Toast.makeText(activity, "यह शब्द नहीं मिला।", 0).show() 
          end
       end
    end).setNegativeButton("कैंसिल", nil).show()
  end})
end
