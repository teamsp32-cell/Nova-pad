-- 🌟 LIVE PATCH v19: FIND CRASH FIX + Bird Radio HTTPS + Multi-Select + Notice 🌟
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
    ambientPlayer.setOnErrorListener(MediaPlayer.OnErrorListener{onError=function(mp, w, e) Toast.makeText(activity, "Stream failed. Link error!", 0).show(); return true end})
  else 
    Toast.makeText(activity, "Music Stopped ⏹️", 0).show() 
  end
end
-- 🎧 2. ULTIMATE MEDITATION & RADIO MENU (100% HTTPS Secure)
function showAmbientMenu()
