# Odi - Tasarım Sistemi (Design System)

## 1. Marka Kimliği ve Vizyon
**Odi**, yapay zeka destekli, etkileşimli ve kesintisiz bir dil öğrenme ve konuşma pratiği asistanıdır. İsmi "Odjek" (Yankı) kelimesinden türetilen Odi, kullanıcının sesini anlayan, analiz eden ve ona yankı vererek gelişimini sağlayan samimi bir yol arkadaşıdır.

**Logo Felsefesi:** Logo, sonsuzluk (infinity) sembolü ile ses dalgalarının (sound waves) modern bir birleşimidir. Sonsuzluk döngüsü sürekli öğrenmeyi ve akıcı konuşmayı, içindeki ses dalgaları ise insan sesi ile yapay zekanın diyaloğunu simgeler.

---

## 2. Renk Paleti (Color Palette)
Logodan ilham alınan canlı, enerjik ama aynı zamanda teknolojik ve güven verici renkler, UI/UX standartlarına uygun şekilde standardize edilmiştir.

### Ana Renkler (Primary Colors)
Konuşma cesaretini, enerjiyi ve yapay zeka teknolojisini yansıtan ana renkler:
* **Odi Coral (Mercan/Turuncu):** `#FF6B35` - Enerji, motivasyon ve konuşma eylemi. (Gradient başlangıcı)
* **Odi Sunset (Koyu Turuncu):** `#E8481D` - Vurgular ve aktif durumlar için.
* **Odi Ocean (Turkuaz/Mavi):** `#51B5BA` - Yapay zeka, dinleme modu, güven ve teknoloji. (Gradient bitişi)
* **Odi Deep Sea (Koyu Mavi):** `#3A8094` - İkincil butonlar ve teknolojik vurgular.

### Nötr Renkler (Neutral Colors)
Temiz, okunaklı ve modern bir arayüz (Stripe/Shopify tarzı) için destekleyici renkler:
* **Koyu Antrasit (Dark Anthracite):** `#2A2D34` - Ana metinler (Heading ve Body) için. Siyah yerine kullanılarak göz yorgunluğunu azaltır.
* **Orta Gri (Mid Grey):** `#8A8D93` - İkincil metinler, placeholder ve ikonlar.
* **Açık Gri (Light Grey):** `#F4F5F7` - Arka planlar, kart zeminleri ve input alanları.
* **Saf Beyaz (White):** `#FFFFFF` - Ana arka plan, kartlar ve kontrast.

### Semantik Renkler (Semantic Colors)
* **Doğru/Başarı (Success):** `#2ECA7F` (Yapay zeka telaffuzu doğru bulduğunda)
* **Hata/Düzeltme (Warning):** `#FFB800` (Telaffuz geliştirilebilir olduğunda)

---

## 3. Tipografi (Typography)
Modern, samimi, okunabilirliği yüksek ve yuvarlak hatlara sahip **Poppins** font ailesi tercih edilmiştir. Bu font, logonun yuvarlak ve akıcı hatlarıyla mükemmel bir uyum sağlar.

* **Font Ailesi:** Poppins (Google Fonts)
* **Başlıklar (Headings):** Poppins SemiBold (600)
    * H1: 32px - Sürükleyici Karşılama Ekranları
    * H2: 24px - Bölüm Başlıkları
    * H3: 20px - Kart Başlıkları
* **Gövde Metni (Body Text):** Poppins Regular (400) & Medium (500)
    * Body 1: 16px - Ana okuma metinleri, geri bildirimler.
    * Body 2: 14px - Açıklamalar ve alt metinler.
* **Butonlar (Buttons):** Poppins Medium (500), 16px, Harf Aralığı: %2 (Letter Spacing: 0.02em)

---

## 4. İkonografi ve Şekiller (Iconography & Shapes)
Minimalist, vektörel ve Dribbble stilini yansıtan bir ikon seti kullanılmalıdır. İkonlar, çok ince olmayan (medium stroke), köşeleri hafif yuvarlatılmış çizgilerden oluşmalıdır.

* **Köşe Yuvarlama (Border Radius):**
    * Butonlar ve Inputlar: `12px` (Yumuşak ve samimi bir his)
    * Kartlar ve Modallar: `16px` ile `24px` arası
* **Gölge (Drop Shadows):** Çok hafif, geniş yayılımlı gölgeler (Soft shadows). Keskin kenarlardan ve koyu gölgelerden kaçınılmalıdır.
    * Örnek CSS: `box-shadow: 0px 8px 24px rgba(42, 45, 52, 0.06);`

---

## 5. UI Bileşenleri (UI Components)

### Butonlar
* **Primary Button (Ses Kaydet / Konuş):** Odi Coral arka plan, beyaz metin. İçinde logodaki gibi bir ses dalgası veya mikrofon ikonu. Hover/Pressed durumunda Odi Sunset rengine geçer.
* **Secondary Button (Dinle / AI Geri Bildirimi):** Odi Ocean arka plan, beyaz metin.
* **Ghost Button:** Arka plan şeffaf, metin Koyu Antrasit. Altı çizili veya hover'da hafif gri arka plan (`#F4F5F7`).

### Kartlar (Cards)
Öğrenme istatistikleri veya AI geri bildirimleri için beyaz zeminli, `16px` border-radius değerine sahip ve çok hafif gölgeli kartlar kullanılır.

### Ses Dalgaları (Waveforms)
Uygulama aktif olarak dinlerken (Listening state), logodaki ses dalgalarının animasyonlu bir versiyonu (Turuncu'dan Turkuaz'a geçen gradient) ekranda hareket etmelidir. Bu, yapay zekanın aktif olduğunu gösteren ana etkileşim öğesidir.

---

## 6. Etkileşim ve Ses Tonu (Voice & Tone)
* **Dil ve Üslup:** Odi, katı bir öğretmen değil, samimi bir dil partneridir. Hataları düzeltirken motive edici bir dil kullanır.
* **Mikro etkileşimler (Micro-interactions):** Kullanıcı konuştuğunda sesin şiddetine göre büyüyüp küçülen logodaki ses dalgaları merkeze alınır. Başarı durumunda hafif ve tatmin edici bir haptik titreşim (titreşim geri bildirimi) verilir.
