-- 🌟 LIVE PATCH: 100% Working Ambient Sounds 🌟
function showAmbientMenu()
  local opts = {"🌧️ Rain Sounds", "🎵 Lofi Study Beats", "🎹 Relaxing Piano", "⏹️ Stop Music"}
  showNovaMenu("Ambient Focus Mode", opts, function(w)
    if w==0 then 
        controlAmbientAudio("https://actions.google.com/sounds/v1/weather/rain_heavy_loud.ogg", "Rain Sounds")
    elseif w==1 then 
        controlAmbientAudio("https://streams.ilovemusic.de/iloveradio17.mp3", "Lofi Beats")
    elseif w==2 then 
        controlAmbientAudio("https://streams.ilovemusic.de/iloveradio18.mp3", "Relaxing Piano")
    elseif w==3 then 
        controlAmbientAudio(nil) 
    end
  end)
end
