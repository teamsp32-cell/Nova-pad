-- 🌐 NOVA PAD - FULL PUBLIC MASTER BUILD (SMART PATCH) 🌐
-- Features: 14 Languages, Smart Backward Compatibility, Mega Tools

local ok, err = pcall(function()
    require "import"
    import "android.view.*"
    import "android.widget.*"
    import "android.app.AlertDialog"
    import "android.graphics.Color"
    import "java.lang.System"
    import "java.lang.String" 
    import "android.content.*"
    import "android.graphics.PixelFormat"
    import "android.speech.tts.TextToSpeech"
    import "java.util.Locale"

    local publicActivity = activity

    -- ⚙️ ग्लोबल सेटिंग्स
    _G.betaClipboard = _G.betaClipboard or {"[Empty]", "[Empty]", "[Empty]"}
    _G.curtainView = _G.curtainView or nil

    -- =======================================================
    -- 🌍 1. THE 14-LANGUAGE DICTIONARY (For Older Versions)
    -- =======================================================
    local langData = {
        en = { empty="[Empty]", slot_empty="This slot is empty!", clip_title="📋 Clipboard Manager", slot="Slot", paste="📋 Paste", share="📤 Share", clear="🗑️ Clear", pasted="Pasted!", open_editor="Open the Editor first!", cleared="Slot cleared!", fnr_title="🔄 Find & Replace", find_hint="Old Word", replace_hint="New Word", replace_all="Replace All", req_find="Old word is required!", success_fnr="✨ Awesome! Words replaced!", fail_fnr="❌ Word not found!", curtain_on="🥷 Privacy Curtain ON!", curtain_off="Curtain removed", menu_title="🧰 Smart Text Tools", tools={"📞 Extract Phone Numbers", "🔗 Extract Links", "✂️ Remove Symbols", "🗑️ Remove Emojis", "✨ Auto-Format Article", "🗣️ Read Text Aloud (TTS)", "🔠 Convert to UPPERCASE", "🔡 Convert to lowercase", "📋 Clipboard Manager", "🔄 Find & Replace", "🥷 Privacy Curtain"} },
        hi = { empty="[खाली]", slot_empty="यह स्लॉट खाली है!", clip_title="📋 क्लिपबोर्ड मैनेजर", slot="स्लॉट", paste="📋 पेस्ट करें", share="📤 शेयर करें", clear="🗑️ डिलीट करें", pasted="पेस्ट हो गया!", open_editor="पहले एडिटर खोलें!", cleared="स्लॉट साफ!", fnr_title="🔄 फाइंड एंड रिप्लेस", find_hint="पुराना शब्द", replace_hint="नया शब्द", replace_all="सब बदलें", req_find="पुराना शब्द डालना ज़रूरी है!", success_fnr="✨ कमाल! शब्द बदल दिए गए!", fail_fnr="❌ शब्द नहीं मिला!", curtain_on="🥷 प्राइवेसी कर्टेन चालू!", curtain_off="कर्टेन हट गया", menu_title="🧰 स्मार्ट टेक्स्ट टूल्स", tools={"📞 फोन नंबर निकालें", "🔗 लिंक निकालें", "✂️ सिंबल हटाएं", "🗑️ इमोजी हटाएं", "✨ ऑटो-फॉर्मेट लेख", "🗣️ टेक्स्ट पढ़कर सुनाएं (TTS)", "🔠 बड़े अक्षरों (UPPERCASE) में बदलें", "🔡 छोटे अक्षरों (lowercase) में बदलें", "📋 क्लिपबोर्ड मैनेजर", "🔄 फाइंड एंड रिप्लेस", "🥷 प्राइवेसी कर्टेन"} },
        id = { empty="[Kosong]", slot_empty="Slot ini kosong!", clip_title="📋 Manajer Papan Klip", slot="Slot", paste="📋 Tempel", share="📤 Bagikan", clear="🗑️ Hapus", pasted="Ditempel!", open_editor="Buka Editor dulu!", cleared="Slot dihapus!", fnr_title="🔄 Cari & Ganti", find_hint="Kata Lama", replace_hint="Kata Baru", replace_all="Ganti Semua", req_find="Kata lama wajib diisi!", success_fnr="✨ Hebat! Kata diganti!", fail_fnr="❌ Kata tidak ditemukan!", curtain_on="🥷 Tirai Privasi AKTIF!", curtain_off="Tirai dilepas", menu_title="🧰 Alat Teks Pintar", tools={"📞 Ekstrak Nomor Telepon", "🔗 Ekstrak Tautan", "✂️ Hapus Simbol", "🗑️ Hapus Emoji", "✨ Format Otomatis", "🗣️ Baca Teks (TTS)", "🔠 Ubah ke HURUF BESAR", "🔡 Ubah ke huruf kecil", "📋 Manajer Papan Klip", "🔄 Cari & Ganti", "🥷 Tirai Privasi"} },
        mr = { empty="[रिकामे]", slot_empty="हा स्लॉट रिकामा आहे!", clip_title="📋 क्लिपबोर्ड मॅनेजर", slot="स्लॉट", paste="📋 पेस्ट करा", share="📤 शेअर करा", clear="🗑️ डिलीट करा", pasted="पेस्ट झाले!", open_editor="आधी एडिटर उघडा!", cleared="स्लॉट साफ!", fnr_title="🔄 शोधा आणि बदला", find_hint="जुना शब्द", replace_hint="नवीन शब्द", replace_all="सर्व बदला", req_find="जुना शब्द टाकणे आवश्यक आहे!", success_fnr="✨ कमाल! शब्द बदलले!", fail_fnr="❌ शब्द सापडला नाही!", curtain_on="🥷 प्रायव्हसी कर्टेन चालू!", curtain_off="कर्टेन हटवले", menu_title="🧰 स्मार्ट टेक्स्ट टूल्स", tools={"📞 फोन नंबर काढा", "🔗 लिंक काढा", "✂️ चिन्हे (Symbols) काढा", "🗑️ इमोजी काढा", "✨ ऑटो-फॉर्मेट लेख", "🗣️ मजकूर वाचून दाखवा (TTS)", "🔠 मोठ्या अक्षरात (UPPERCASE) करा", "🔡 छोट्या अक्षरात (lowercase) करा", "📋 क्लिपबोर्ड मॅनेजर", "🔄 शोधा आणि बदला", "🥷 प्रायव्हसी कर्टेन"} },
        gu = { empty="[ખાલી]", slot_empty="આ સ્લોટ ખાલી છે!", clip_title="📋 ક્લિપબોર્ડ મેનેજર", slot="સ્લોટ", paste="📋 પેસ્ટ કરો", share="📤 શેર કરો", clear="🗑️ કાઢી નાખો", pasted="પેસ્ટ થઈ ગયું!", open_editor="પહેલા એડિટર ખોલો!", cleared="સ્લોટ સાફ!", fnr_title="🔄 શોધો અને બદલો", find_hint="જૂનો શબ્દ", replace_hint="નવો શબ્દ", replace_all="બધું બદલો", req_find="જૂનો શબ્દ જરૂરી છે!", success_fnr="✨ કમાલ! શબ્દ બદલાઈ ગયો!", fail_fnr="❌ શબ્દ મળ્યો નથી!", curtain_on="🥷 પ્રાઇવસી કર્ટેન ચાલુ!", curtain_off="કર્ટેન હટી ગયું", menu_title="🧰 સ્માર્ટ ટેક્સ્ટ ટૂલ્સ", tools={"📞 ફોન નંબર કાઢો", "🔗 લિંક કાઢો", "✂️ ચિહ્નો (Symbols) હટાવો", "🗑️ ઇમોજી હટાવો", "✨ ઓટો-ફોર્મેટ લેખ", "🗣️ ટેક્સ્ટ વાંચી સંભળાવો (TTS)", "🔠 મોટા અક્ષરોમાં (UPPERCASE) કરો", "🔡 નાના અક્ષરોમાં (lowercase) કરો", "📋 ક્લિપબોર્ડ મેનેજર", "🔄 શોધો અને બદલો", "🥷 પ્રાઇવસી કર્ટેન"} },
        bn = { empty="[খালি]", slot_empty="এই স্লট খালি!", clip_title="📋 ক্লিপবোর্ড ম্যানেজার", slot="স্লট", paste="📋 পেস্ট করুন", share="📤 শেয়ার করুন", clear="🗑️ মুছুন", pasted="পেস্ট করা হয়েছে!", open_editor="প্রথমে এডিটর খুলুন!", cleared="স্লট পরিষ্কার!", fnr_title="🔄 খুঁজুন ও প্রতিস্থাপন করুন", find_hint="পুরানো শব্দ", replace_hint="নতুন শব্দ", replace_all="সব পরিবর্তন করুন", req_find="পুরানো শব্দ প্রয়োজন!", success_fnr="✨ দারুণ! শব্দ পরিবর্তন করা হয়েছে!", fail_fnr="❌ শব্দ পাওয়া যায়নি!", curtain_on="🥷 প্রাইভেসি কার্টেন চালু!", curtain_off="কার্টেন সরানো হয়েছে", menu_title="🧰 স্মার্ট টেক্সট টুলস", tools={"📞 ফোন নম্বর বের করুন", "🔗 লিঙ্ক বের করুন", "✂️ চিহ্ন (Symbols) মুছুন", "🗑️ ইমোজি মুছুন", "✨ অটো-ফরম্যাট আর্টিকেল", "🗣️ টেক্সট পড়ে শোনান (TTS)", "🔠 বড় অক্ষরে (UPPERCASE) পরিবর্তন", "🔡 ছোট অক্ষরে (lowercase) পরিবর্তন", "📋 ক্লিপবোর্ড ম্যানেজার", "🔄 খুঁজুন ও প্রতিস্থাপন করুন", "🥷 প্রাইভেসি কার্টেন"} },
        ta = { empty="[காலி]", slot_empty="இந்த ஸ்லாட் காலியாக உள்ளது!", clip_title="📋 கிளிப்போர்டு", slot="ஸ்லாட்", paste="📋 ஒட்டு", share="📤 பகிர்", clear="🗑️ அழி", pasted="ஒட்டப்பட்டது!", open_editor="முதலில் எடிட்டரை திறக்கவும்!", cleared="ஸ்லாட் அழிக்கப்பட்டது!", fnr_title="🔄 தேடு & மாற்று", find_hint="பழைய சொல்", replace_hint="புதிய சொல்", replace_all="அனைத்தையும் மாற்று", req_find="பழைய சொல் தேவை!", success_fnr="✨ அருமை! சொற்கள் மாற்றப்பட்டன!", fail_fnr="❌ சொல் கிடைக்கவில்லை!", curtain_on="🥷 திரை ஆன்!", curtain_off="திரை நீக்கப்பட்டது", menu_title="🧰 ஸ்மார்ட் கருவிகள்", tools={"📞 எண்களை எடு", "🔗 இணைப்புகளை எடு", "✂️ குறிகளை நீக்கு", "🗑️ எமோஜிகளை நீக்கு", "✨ ஆட்டோ-ஃபார்மேட்", "🗣️ படித்து காட்டு (TTS)", "🔠 பெரிய எழுத்துக்களுக்கு மாற்று", "🔡 சிறிய எழுத்துக்களுக்கு மாற்று", "📋 கிளிப்போர்டு", "🔄 தேடு & மாற்று", "🥷 பிரைவசி திரை"} },
        te = { empty="[ఖాళీ]", slot_empty="ఈ స్లాట్ ఖాళీగా ఉంది!", clip_title="📋 క్లిప్‌బోర్డ్", slot="స్లాట్", paste="📋 అతికించు", share="📤 షేర్ చేయండి", clear="🗑️ క్లియర్ చేయండి", pasted="అతికించబడింది!", open_editor="ముందుగా ఎడిటర్‌ను తెరవండి!", cleared="స్లాట్ క్లియర్ చేయబడింది!", fnr_title="🔄 వెతుకు & మార్చు", find_hint="పాత పదం", replace_hint="కొత్త పదం", replace_all="అన్నింటినీ మార్చు", req_find="పాత పదం అవసరం!", success_fnr="✨ అద్భుతం! పదాలు మార్చబడ్డాయి!", fail_fnr="❌ పదం దొరకలేదు!", curtain_on="🥷 ప్రైవసీ కర్టెన్ ఆన్!", curtain_off="కర్టెన్ తొలగించబడింది", menu_title="🧰 స్మార్ట్ టూల్స్", tools={"📞 ఫోన్ నంబర్లు తీయండి", "🔗 లింక్‌లు తీయండి", "✂️ చిహ్నాలు తీసివేయండి", "🗑️ ఎమోజీలు తీసివేయండి", "✨ ఆటో-ఫార్మాట్", "🗣️ చదివి వినిపించు (TTS)", "🔠 పెద్ద అక్షరాలకు మార్చు", "🔡 చిన్న అక్షరాలకు మార్చు", "📋 క్లిప్‌బోర్డ్", "🔄 వెతుకు & మార్చు", "🥷 ప్రైవసీ కర్టెన్"} },
        ur = { empty="[خالی]", slot_empty="یہ سلاٹ خالی ہے!", clip_title="📋 کلپ بورڈ مینیجر", slot="سلاٹ", paste="📋 پیسٹ کریں", share="📤 شیئر کریں", clear="🗑️ حذف کریں", pasted="پیسٹ ہو گیا!", open_editor="پہلے ایڈیٹر کھولیں!", cleared="سلاٹ صاف!", fnr_title="🔄 تلاش اور تبدیل", find_hint="پرانا لفظ", replace_hint="نیا لفظ", replace_all="سب تبدیل کریں", req_find="پرانا لفظ درکار ہے!", success_fnr="✨ زبردست! لفظ تبدیل ہو گیا!", fail_fnr="❌ لفظ نہیں ملا!", curtain_on="🥷 پرائیویسی پردہ آن!", curtain_off="پردہ ہٹ گیا", menu_title="🧰 سمارٹ ٹیکسٹ ٹولز", tools={"📞 فون نمبر نکالیں", "🔗 لنک نکالیں", "✂️ علامات ہٹائیں", "🗑️ ایموجی ہٹائیں", "✨ آٹو فارمیٹ مضمون", "🗣️ متن پڑھ کر سنائیں (TTS)", "🔠 بڑے حروف (UPPERCASE) میں کریں", "🔡 چھوٹے حروف (lowercase) میں کریں", "📋 کلپ بورڈ مینیجر", "🔄 تلاش اور تبدیل کریں", "🥷 پرائیویسی پردہ"} },
        es = { empty="[Vacío]", slot_empty="¡Este espacio está vacío!", clip_title="📋 Portapapeles", slot="Espacio", paste="📋 Pegar", share="📤 Compartir", clear="🗑️ Borrar", pasted="¡Pegado!", open_editor="¡Abre el editor primero!", cleared="¡Espacio borrado!", fnr_title="🔄 Buscar y Reemplazar", find_hint="Palabra antigua", replace_hint="Palabra nueva", replace_all="Reemplazar todo", req_find="¡Se requiere palabra antigua!", success_fnr="✨ ¡Genial! ¡Reemplazado!", fail_fnr="❌ ¡Palabra no encontrada!", curtain_on="🥷 ¡Cortina de privacidad ON!", curtain_off="Cortina eliminada", menu_title="🧰 Herramientas de Texto", tools={"📞 Extraer Teléfonos", "🔗 Extraer Enlaces", "✂️ Quitar Símbolos", "🗑️ Quitar Emojis", "✨ Auto-Formatear", "🗣️ Leer en voz alta (TTS)", "🔠 Convertir a MAYÚSCULAS", "🔡 Convertir a minúsculas", "📋 Administrar Portapapeles", "🔄 Buscar y Reemplazar", "🥷 Cortina de Privacidad"} },
        fr = { empty="[Vide]", slot_empty="Cet emplacement est vide !", clip_title="📋 Presse-papiers", slot="Emplacement", paste="📋 Coller", share="📤 Partager", clear="🗑️ Effacer", pasted="Collé !", open_editor="Ouvrez l'éditeur d'abord !", cleared="Emplacement effacé !", fnr_title="🔄 Rechercher et Remplacer", find_hint="Ancien mot", replace_hint="Nouveau mot", replace_all="Tout remplacer", req_find="Ancien mot requis !", success_fnr="✨ Super ! Mots remplacés !", fail_fnr="❌ Mot introuvable !", curtain_on="🥷 Rideau de confidentialité ON !", curtain_off="Rideau retiré", menu_title="🧰 Outils de Texte", tools={"📞 Extraire Numéros", "🔗 Extraire Liens", "✂️ Supprimer Symboles", "🗑️ Supprimer Emojis", "✨ Formatage Auto", "🗣️ Lire à haute voix (TTS)", "🔠 Mettre en MAJUSCULES", "🔡 Mettre en minuscules", "📋 Presse-papiers", "🔄 Rechercher et Remplacer", "🥷 Rideau de confidentialité"} },
        pt = { empty="[Vazio]", slot_empty="Este slot está vazio!", clip_title="📋 Área de Transferência", slot="Slot", paste="📋 Colar", share="📤 Compartilhar", clear="🗑️ Limpar", pasted="Colado!", open_editor="Abra o Editor primeiro!", cleared="Slot limpo!", fnr_title="🔄 Localizar e Substituir", find_hint="Palavra Antiga", replace_hint="Nova Palavra", replace_all="Substituir Tudo", req_find="Palavra antiga é necessária!", success_fnr="✨ Incrível! Substituído!", fail_fnr="❌ Palavra não encontrada!", curtain_on="🥷 Cortina de Privacidade ON!", curtain_off="Cortina removida", menu_title="🧰 Ferramentas de Texto", tools={"📞 Extrair Telefones", "🔗 Extrair Links", "✂️ Remover Símbolos", "🗑️ Remover Emojis", "✨ Auto-Formatar", "🗣️ Ler em voz alta (TTS)", "🔠 Converter para MAIÚSCULAS", "🔡 Converter para minúsculas", "📋 Área de Transferência", "🔄 Localizar e Substituir", "🥷 Cortina de Privacidade"} },
        ru = { empty="[Пусто]", slot_empty="Этот слот пуст!", clip_title="📋 Буфер обмена", slot="Слот", paste="📋 Вставить", share="📤 Поделиться", clear="🗑️ Очистить", pasted="Вставлено!", open_editor="Откройте редактор!", cleared="Слот очищен!", fnr_title="🔄 Найти и заменить", find_hint="Старое слово", replace_hint="Новое слово", replace_all="Заменить всё", req_find="Нужно старое слово!", success_fnr="✨ Отлично! Заменено!", fail_fnr="❌ Слово не найдено!", curtain_on="🥷 Шторка приватности ВКЛ!", curtain_off="Шторка убрана", menu_title="🧰 Инструменты текста", tools={"📞 Извлечь номера", "🔗 Извлечь ссылки", "✂️ Удалить символы", "🗑️ Удалить эмодзи", "✨ Авто-формат", "🗣️ Прочитать текст (TTS)", "🔠 В ВЕРХНИЙ РЕГИСТР", "🔡 В нижний регистр", "📋 Буфер обмена", "🔄 Найти и заменить", "🥷 Шторка приватности"} },
        ar = { empty="[فارغ]", slot_empty="هذه الخانة فارغة!", clip_title="📋 مدير الحافظة", slot="خانة", paste="📋 لصق", share="📤 مشاركة", clear="🗑️ مسح", pasted="تم اللصق!", open_editor="افتح المحرر أولاً!", cleared="تم مسح الخانة!", fnr_title="🔄 بحث واستبدال", find_hint="الكلمة القديمة", replace_hint="الكلمة الجديدة", replace_all="استبدال الكل", req_find="الكلمة القديمة مطلوبة!", success_fnr="✨ رائع! تم استبدال الكلمات!", fail_fnr="❌ لم يتم العثور على الكلمة!", curtain_on="🥷 ستارة الخصوصية مفعلة!", curtain_off="تمت إزالة الستارة", menu_title="🧰 أدوات النصوص", tools={"📞 استخراج الأرقام", "🔗 استخراج الروابط", "✂️ إزالة الرموز", "🗑️ إزالة الإيموجي", "✨ تنسيق تلقائي", "🗣️ قراءة النص (TTS)", "🔠 تحويل لأحرف كبيرة", "🔡 تحويل لأحرف صغيرة", "📋 مدير الحافظة", "🔄 بحث واستبدال", "🥷 ستارة الخصوصية"} }
    }

    local function getSafeLang()
        local lang = "en"
        local rootDirPatch = publicActivity.getExternalFilesDir(nil).toString() .. "/"
        local ok_file, f = pcall(function() return io.open(rootDirPatch .. "lang_pref.txt", "r") end)
        if ok_file and f then 
            local content = f:read("*a"); f:close()
            if content then 
                local code = content:match("%a%a") 
                if code and langData[code] then lang = code end
            end
        end
        return lang
    end
    
    _G.appLanguage = getSafeLang()
    local function L(key) return langData[_G.appLanguage][key] or langData["en"][key] or key end

    -- =======================================================
    -- 🚀 2. SMART AUTO-INJECTOR: SETTINGS LANGUAGE BUTTON
    -- (यह 3.1 को पहचान लेगा और डबल बटन नहीं बनाएगा!)
    -- =======================================================
    pcall(function()
        -- 🔥 THE FIX: Added `not btnLangSettings` to ensure it only runs on v2.9 / v3.0 🔥
        if tabSettings and not btnLangSettings and not _G.langBtnInjected then
            local btnLang = Button(publicActivity)
            btnLang.setText("🌍 Change App Language (14 Languages)")
            btnLang.setBackgroundColor(0xFF2196F3) 
            btnLang.setTextColor(0xFFFFFFFF)
            
            tabSettings.addView(btnLang, 1)
            
            btnLang.onClick = function()
                local langNames = {"🇬🇧 English", "🇮🇳 हिन्दी", "🇮🇩 Bahasa Indonesia", "🇮🇳 मराठी", "🇮🇳 ગુજરાતી", "🇧🇩 বাংলা", "🇮🇳 தமிழ்", "🇮🇳 తెలుగు", "🇵🇰 اردو", "🇪🇸 Español", "🇫🇷 Français", "🇵🇹 Português", "🇷🇺 Русский", "🇸🇦 العربية"}
                local langCodes = {"en", "hi", "id", "mr", "gu", "bn", "ta", "te", "ur", "es", "fr", "pt", "ru", "ar"}
                
                local lv = ListView(publicActivity)
                lv.setAdapter(ArrayAdapter(publicActivity, android.R.layout.simple_list_item_1, langNames))
                local dlg = AlertDialog.Builder(publicActivity).setTitle("🌍 Select Language").setView(lv).show()
                
                lv.setOnItemClickListener(AdapterView.OnItemClickListener{
                    onItemClick = function(p,v,pos,id)
                        dlg.dismiss()
                        local selectedCode = langCodes[pos+1]
                        local rootDir = publicActivity.getExternalFilesDir(nil).toString() .. "/"
                        local f = io.open(rootDir .. "lang_pref.txt", "w")
                        if f then 
                            f:write(selectedCode); f:close()
                            _G.appLanguage = selectedCode
                            Toast.makeText(publicActivity, "Language Updated! Please Restart App.", 1).show()
                        end
                    end
                })
            end
            _G.langBtnInjected = true
        end
    end)

    -- =======================================================
    -- 🌟 3. NEW FEATURES (Clipboard, Find/Replace, Curtain)
    -- =======================================================

    _G.openClipboardManager = function()
        pcall(function()
            local items = {}
            for i=1,3 do 
                local preview = string.sub(_G.betaClipboard[i], 1, 30)
                if string.len(_G.betaClipboard[i]) > 30 then preview = preview .. "..." end
                table.insert(items, L("slot").." "..i..": " .. preview) 
            end
            local lv = ListView(publicActivity)
            lv.setAdapter(ArrayAdapter(publicActivity, android.R.layout.simple_list_item_1, items))
            local dlg = AlertDialog.Builder(publicActivity).setTitle(L("clip_title")).setView(lv).show()
            lv.setOnItemClickListener(AdapterView.OnItemClickListener{
                onItemClick = function(p,v,pos,id)
                    dlg.dismiss()
                    local isSlotEmpty = false
                    for _, lData in pairs(langData) do if _G.betaClipboard[pos+1] == lData.empty then isSlotEmpty = true; break end end
                    if isSlotEmpty then Toast.makeText(publicActivity, L("slot_empty"), 0).show(); return end
                    
                    local opts = {L("paste"), L("share"), L("clear")}
                    local lvOpts = ListView(publicActivity)
                    lvOpts.setAdapter(ArrayAdapter(publicActivity, android.R.layout.simple_list_item_1, opts))
                    local dlgOpts = AlertDialog.Builder(publicActivity).setTitle(L("slot").." "..(pos+1)).setView(lvOpts).show()
                    lvOpts.setOnItemClickListener(AdapterView.OnItemClickListener{
                        onItemClick = function(p2,v2,pos2,id2)
                            dlgOpts.dismiss()
                            if pos2 == 0 then
                                if noteEditor and noteEditor.getVisibility() == 0 then
                                    noteEditor.getText().insert(noteEditor.getSelectionStart(), _G.betaClipboard[pos+1])
                                    Toast.makeText(publicActivity, L("pasted"), 0).show()
                                else Toast.makeText(publicActivity, L("open_editor"), 0).show() end
                            elseif pos2 == 1 then
                                local i = Intent(Intent.ACTION_SEND); i.setType("text/plain"); i.putExtra(Intent.EXTRA_TEXT, _G.betaClipboard[pos+1])
                                publicActivity.startActivity(Intent.createChooser(i, L("share")))
                            elseif pos2 == 2 then
                                _G.betaClipboard[pos+1] = L("empty"); Toast.makeText(publicActivity, L("cleared"), 0).show()
                            end
                        end
                    })
                end
            })
        end)
    end

    _G.showFindReplace = function()
        pcall(function()
            local l = LinearLayout(publicActivity); l.setOrientation(1); l.setPadding(50,20,50,20)
            local f = EditText(publicActivity); f.setHint(L("find_hint")); local r = EditText(publicActivity); r.setHint(L("replace_hint"))
            l.addView(f); l.addView(r)
            AlertDialog.Builder(publicActivity).setTitle(L("fnr_title")).setView(l).setPositiveButton(L("replace_all"), function()
                local btnOk, btnErr = pcall(function()
                    local rawFt = tostring(f.getText() or "")
                    local rawRt = tostring(r.getText() or "")
                    local ft = rawFt:gsub("^%s*(.-)%s*$", "%1")
                    local rt = rawRt:gsub("^%s*(.-)%s*$", "%1")
                    
                    if #ft > 0 then 
                        local JString = luajava.bindClass("java.lang.String")
                        local Pattern = luajava.bindClass("java.util.regex.Pattern")
                        local jContent = JString.valueOf(tostring(noteEditor.getText() or ""))
                        local quotedFt = Pattern.quote(ft)
                        local matcher = Pattern.compile(quotedFt, Pattern.CASE_INSENSITIVE).matcher(jContent)
                        
                        if matcher.find() then
                            noteEditor.setText(matcher.replaceAll(rt))
                            pcall(function() if toneGen then toneGen.startTone(24, 100) end end)
                            Toast.makeText(publicActivity, L("success_fnr"), 0).show()
                        else Toast.makeText(publicActivity, L("fail_fnr"), 0).show() end
                    else Toast.makeText(publicActivity, L("req_find"), 0).show() end
                end)
            end).show()
        end)
    end

    _G.togglePrivacyCurtain = function()
        pcall(function()
            local wm = publicActivity.getSystemService(Context.WINDOW_SERVICE)
            if _G.curtainView then
                wm.removeView(_G.curtainView); _G.curtainView = nil; Toast.makeText(publicActivity, L("curtain_off"), 0).show()
            else
                _G.curtainView = FrameLayout(publicActivity); _G.curtainView.setBackgroundColor(0xFF000000)
                local params = WindowManager.LayoutParams(WindowManager.LayoutParams.MATCH_PARENT, WindowManager.LayoutParams.MATCH_PARENT, WindowManager.LayoutParams.TYPE_APPLICATION, WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE, PixelFormat.TRANSLUCENT)
                wm.addView(_G.curtainView, params); Toast.makeText(publicActivity, L("curtain_on"), 0).show()
                _G.curtainView.setOnClickListener(View.OnClickListener{onClick = function() _G.togglePrivacyCurtain() end})
            end
        end)
    end

    -- =======================================================
    -- 🎯 4. MASTER OVERRIDE (AUTO-TRANSLATING SMART TOOLS)
    -- =======================================================
    local Pattern = luajava.bindClass("java.util.regex.Pattern")
    
    _G.openSmartTextCleaner = function()
        local text = ""
        if noteEditor then text = noteEditor.getText().toString() end
        
        local safeLang = getSafeLang()
        local opts = langData[safeLang].tools
        local menuTitle = langData[safeLang].menu_title
        
        showNovaMenu(menuTitle, opts, function(w)
            pcall(function()
                local JString = luajava.bindClass("java.lang.String")
                local jText = JString.valueOf(text)
                
                if w == 0 then
                    if #text == 0 then return end
                    local matcher = Pattern.compile("(?:\\+?\\d{1,3}[- ]?)?\\d{10}").matcher(jText); local nums = {}; while matcher.find() do table.insert(nums, matcher.group()) end
                    if #nums > 0 then activity.getSystemService(Context.CLIPBOARD_SERVICE).setPrimaryClip(ClipData.newPlainText("Nums", table.concat(nums, "\n"))); Toast.makeText(activity, "Copied!", 0).show() end
                elseif w == 1 then
                    if #text == 0 then return end
                    local matcher = Pattern.compile("https?://[a-zA-Z0-9\\-\\.]+\\.[a-zA-Z]{2,}(/\\S*)?").matcher(jText); local links = {}; while matcher.find() do table.insert(links, matcher.group()) end
                    if #links > 0 then activity.getSystemService(Context.CLIPBOARD_SERVICE).setPrimaryClip(ClipData.newPlainText("Links", table.concat(links, "\n"))); Toast.makeText(activity, "Copied!", 0).show() end
                elseif w == 2 then noteEditor.setText(jText.replaceAll("[*#_~`|^]", "")); Toast.makeText(activity, "Done!", 0).show()
                elseif w == 3 then noteEditor.setText(jText.replaceAll("[\\x{1F300}-\\x{1F6FF}|\\x{2600}-\\x{26FF}|\\x{2700}-\\x{27BF}|\\x{1F900}-\\x{1F9FF}|\\x{1F1E6}-\\x{1F1FF}]", "")); Toast.makeText(activity, "Done!", 0).show()
                elseif w == 4 then local ft = jText.replaceAll(" +", " "); ft = ft.replaceAll("([.,])([A-Za-z\\u0900-\\u097F])", "$1 $2"); noteEditor.setText(ft.trim()); Toast.makeText(activity, "Done!", 0).show() 
                elseif w == 5 then 
                    if #text == 0 then return end
                    local ttsOpts = {"🇮🇳 Hindi", "🇬🇧 English", "🇮🇩 Indonesian", "🇪🇸 Spanish", "🇫🇷 French", "🇷🇺 Russian", "⚙️ Voice Settings", "⏹️ Stop Reading"}
                    showNovaMenu("🗣️ Select Voice Language", ttsOpts, function(tIdx)
                        if tIdx == 6 then pcall(function() activity.startActivity(Intent("com.android.settings.TTS_SETTINGS")) end)
                        elseif tIdx == 7 then if _G.tts_player then _G.tts_player.stop() end; Toast.makeText(activity, "Stopped ⏹️", 0).show()
                        else
                            Toast.makeText(activity, "Starting Reader... 🗣️", 0).show()
                            local loc = Locale("hi", "IN")
                            if tIdx == 1 then loc = Locale("en", "US")
                            elseif tIdx == 2 then loc = Locale("id", "ID")
                            elseif tIdx == 3 then loc = Locale("es", "ES")
                            elseif tIdx == 4 then loc = Locale("fr", "FR")
                            elseif tIdx == 5 then loc = Locale("ru", "RU") end
                            
                            if _G.tts_player == nil then
                               _G.tts_player = TextToSpeech(activity, TextToSpeech.OnInitListener{
                                  onInit = function(status) if status == TextToSpeech.SUCCESS then _G.tts_player.setLanguage(loc); _G.tts_player.speak(text, TextToSpeech.QUEUE_FLUSH, nil) end end
                               })
                            else _G.tts_player.setLanguage(loc); _G.tts_player.speak(text, TextToSpeech.QUEUE_FLUSH, nil) end
                        end
                    end)
                elseif w == 6 then noteEditor.setText(string.upper(text))
                elseif w == 7 then noteEditor.setText(string.lower(text))
                elseif w == 8 then _G.openClipboardManager()
                elseif w == 9 then _G.showFindReplace()
                elseif w == 10 then _G.togglePrivacyCurtain()
                end
            end)
        end)
    end

end)
