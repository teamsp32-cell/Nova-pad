-- 🌟 LIVE PATCH v12: Auto-Popup Notice (No Menu Button) + Meditation + TTS 🌟
import "android.media.MediaPlayer"
import "android.speech.tts.TextToSpeech"
import "java.util.Locale"
-- 🔥 1. FORCE LOOP AUDIO PLAYER
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

-- 📢 AUTO-POPUP NOTICE ENGINE (इसे फाइल के सबसे नीचे जोड़ें)
function checkGlobalNotice()
   -- ध्यान रहे: फाइल का नाम गिटहब पर notice.txt ही होना चाहिए
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
