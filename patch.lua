-- 🌟 LIVE PATCH: Ambient Sound Fix (v2.8.1) 🌟
-- यह कोड बिना ऐप अपडेट किए पुराने खराब लिंक्स को तुरंत बदल देगा।

function showAmbientMenu()
  local opts = {"🌧️ Rain Sounds", "🌊 Ocean Waves", "🌲 Forest Morning", "⏹️ Stop Music"}
  showNovaMenu("Ambient Focus Mode", opts, function(w)
    if w==0 then 
        controlAmbientAudio("https://upload.wikimedia.org/wikipedia/commons/3/30/Rain_Sounds.ogg", "Rain Sounds")
    elseif w==1 then 
        controlAmbientAudio("https://upload.wikimedia.org/wikipedia/commons/7/77/Ocean_Waves_Crashing.ogg", "Ocean Waves")
    elseif w==2 then 
        controlAmbientAudio("https://upload.wikimedia.org/wikipedia/commons/6/6e/Bialowieza_forest_morning_birds.ogg", "Forest Morning")
    elseif w==3 then 
        controlAmbientAudio(nil) 
    end
  end)
end
