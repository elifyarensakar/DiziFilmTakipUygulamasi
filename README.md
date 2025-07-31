# Dizi Film Takip Uygulaması

Bu proje, kullanıcıların dizi ve film izleme deneyimlerini kişiselleştirebileceği, geçmişte izlediklerini takip edebileceği ve yeni içerikler keşfedebileceği bir mobil uygulamadır. Uygulama; Flutter tabanlı frontend, Flask (Python) ile yazılmış backend ve Firebase destekli bir veritabanından oluşan üç katmanlı bir mimariye sahiptir.

---

## Proje Özellikleri

### Profilim
- Kullanıcı profili oluşturma, düzenleme ve takip
- İzlenilen içeriklerin ve puanlamaların görüntülenmesi
- Sosyal etkileşim: Başka kullanıcıların aktivitelerini görme

### Chatbot
- OpenAI GPT-4 API ile entegre akıllı öneri sistemi
- Ruh haline, türe ve geçmişe göre içerik önerileri

### Devam Et
- Yarım bırakılan diziler için kullanıcıya özel quiz sistemi
- Kullanıcının verdiği yanıtlara göre devam etmesi gereken bölüm tahmini

---

## Geliştirici Takımı

| İsim | GitHub |
|------|--------|
| Melisa Zobali | [MelisaZobali](https://github.com/MelisaZobali) |
| Elif Yaren Şakar | [elifyarensakar](https://github.com/elifyarensakar) |

---

## Elif Yaren Şakar'ın Katkıları

### Backend (Python & Flask)
- Kullanıcı kayıt/giriş sisteminin geliştirilmesi
- Firestore tabanlı veri modellerinin yazımı
- OpenAI API ile chatbot servislerinin oluşturulması
- Quiz ve öneri motoru modüllerinin backend'deki iş mantığının kodlanması
- API endpoint'lerinin test edilmesi (`pytest`, Postman)
- Kodların versiyon kontrolü ve yorumlanması

###  Frontend (Flutter)
- Flutter ile yazılmış uygulamanın API'lere bağlanması
- Chatbot ve “devam et” ekranlarının düzenlenmesi
- Flutter’da test senaryolarının yazılması

---

## 👣 Katkı Kayıtları

Commit geçmişiyle tüm katkılar şeffaf biçimde doğrulanabilir:
```bash
git log --author="Elif"
