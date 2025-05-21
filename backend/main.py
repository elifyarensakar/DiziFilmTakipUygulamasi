from flask import Flask, request, jsonify
import firebase_admin
from firebase_admin import credentials, firestore
from flask_cors import CORS
import requests
from openai import OpenAI
from dotenv import load_dotenv
import os

load_dotenv()
client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))
print("API KEY:", os.getenv("OPENAI_API_KEY"))



app = Flask(__name__)
CORS(app) 

cred = credentials.Certificate("C:/Users/Elif yaren/Desktop/DiziFilmTakipUygulamas-/backend/firebase_config.json")  
if not firebase_admin._apps:
    firebase_admin.initialize_app(cred)



db = firestore.client()

OMDB_API_KEY= '157be653'



@app.route('/devam-noktasi-tahmin', methods=['POST'])
def devam_noktasi_tahmin():
    try:
        data = request.get_json()
        diziAdi = data.get("diziAdi")
        cevaplar = data.get("cevaplar", [])

        if not diziAdi or not cevaplar:
            return jsonify({"message": "Eksik veri."}), 400
        
        # DENEMEK İÇİN YAZDIM (chatgpt yok burası devrede)
        dummy_tahmin = "Sezon 3, Bölüm 5"
        return jsonify({"tahmin": dummy_tahmin}), 200
        prompt = (
            f"Kullanıcı '{diziAdi}' dizisinde nerde kaldığını hatırlamıyor. "
            f"Aşağıda dizinin bazı bölümleriyle ilgili cevaplar var:\n"
            f"{cevaplar}\n"
            f"Bu verilere göre izlemeye devam etmesi gereken sezon ve bölümü tahmin et. "
            f"Sadece şu formatta yanıt ver: Sezon X, Bölüm Y"
     )


       
       

        response = client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[{"role": "user", "content": prompt}],
            temperature=0.7
        )

        yanit = response.choices[0].message.content


        print("Prompt:", prompt)

        print("OpenAI yanıtı:", response)

        yanit = response['choices'][0]['message']['content']
        return jsonify({"tahmin": yanit}), 200

    except Exception as e:
        print("Tahmin hatası:", str(e))
        return jsonify({"message": "Sunucu hatası."}), 500


@app.route('/icerik-listesi', methods=['GET'])
def icerik_listesi():
    query= request.args.get('q','batman')
    tur= request.args.get('type','')

    if not query:
        return jsonify({"hata": "Arama terimi girin."}), 400
    url= f'http://www.omdbapi.com/?apikey={OMDB_API_KEY}&s={query}'
    if tur:
        url+= f'&type={tur}'

    response= requests.get(url)

    if response.status_code!=200:
        return jsonify({"hata": "veri alinamadi."}), 500
    
    data = response.json()




    if data.get('Response')=='True':
        return jsonify(data['Search']), 200
    else:   
        return jsonify([]), 200
    
@app.route('/izleme-kaydi-ekle', methods=['POST'])
def izleme_kaydi_ekle():
    data = request.json

    required_fields = ['userId', 'contentId', 'title', 'type', 'status']
    if not all(field in data for field in required_fields):
        return jsonify({"message": "Eksik alan var."}), 400

    user_id = data['userId']
    content_id = data['contentId']
    title = data['title']
    content_type = data['type']
    status = data['status']
    current_season = data.get('currentSeason', 1 if content_type == 'dizi' else None)
    current_episode = data.get('currentEpisode', 1 if content_type == 'dizi' else None)

    # Firestore'a ekleme
    doc_ref = db.collection('users').document(user_id).collection('watchlist').document()

    doc_ref.set({
        "contentId": content_id,
        "title": title,
        "type": content_type,
        "status": status,
        "currentSeason": current_season,
        "currentEpisode": current_episode,
        "rating": None,
        "comment": None,
        "createdAt": firestore.SERVER_TIMESTAMP,
        "updatedAt": firestore.SERVER_TIMESTAMP
    })

    return jsonify({"message": "İzleme kaydı başarıyla eklendi."}), 201

@app.route('/izleme-kaydi-listele/<user_id>', methods=['GET'])
def izleme_kaydi_listele(user_id):
    try:
        watchlist_ref = db.collection('users').document(user_id).collection('watchlist')
        docs = watchlist_ref.stream()

        watchlist = []
        for doc in docs:
            data = doc.to_dict()
            data['id'] = doc.id  # doküman ID'sini de dahil edelim
            watchlist.append(data)

        return jsonify(watchlist), 200

    except Exception as e:
        print("Hata:", e)
        return jsonify({"message": "Sunucu hatası"}), 500


@app.route('/izleme-kaydi-guncelle/<user_id>/<watch_id>', methods=['PATCH'])
def izleme_kaydi_guncelle(user_id, watch_id):
    try:
        data = request.json

        update_fields = {}
        for field in ['status', 'currentSeason', 'currentEpisode', 'rating', 'comment']:
            if field in data:
                update_fields[field] = data[field]

        if not update_fields:
            return jsonify({"message": "Güncellenecek alan yok."}), 400

        update_fields['updatedAt'] = firestore.SERVER_TIMESTAMP

        print(f"GÜNCELLENECEK -> user_id: {user_id}, watch_id: {watch_id}")
        print(f"UPDATE FIELDS: {update_fields}")

        doc_ref = db.collection('users').document(user_id).collection('watchlist').document(watch_id)
        doc_ref.update(update_fields)

        print(" Güncelleme başarılı!")
        return jsonify({"message": "İzleme kaydı güncellendi."}), 200

    except Exception as e:
        print(" Güncelleme hatası:", str(e))
        return jsonify({"message": "Sunucu hatası."}), 500


@app.route('/izleme-kaydi-sil/<user_id>/<watch_id>', methods=['DELETE'])
def izleme_kaydi_sil(user_id, watch_id):
    try:
        doc_ref = db.collection('users').document(user_id).collection('watchlist').document(watch_id)
        doc_ref.delete()
        return jsonify({"message": "İzleme kaydı silindi."}), 200

    except Exception as e:
        print("Hata:", e)
        return jsonify({"message": "Sunucu hatası."}), 500




# Flask uygulaması için gerekli ayarlar
@app.route('/')
def hello():
    return "Merhaba Dunya! Backend çalisiyor :)"

@app.route('/selamla', methods=['POST'])
def selamla():
    data = request.json  
    isim = data.get('isim', 'isim yok')
    return jsonify({"mesaj": f"Merhaba {isim}!"})

@app.route('/oneri-chatbotu', methods=['POST'])
def oneri_chatbotu():
    data = request.get_json()
    mesaj = data.get("mesaj")

    if not mesaj:
        return jsonify({"message": "Mesaj boş olamaz."}), 400
    
    print("Mesaj:", mesaj)

    dummy_cevap = "Önerim: 'The Office' ve 'Modern Family'. Çünkü ruh halin biraz hüzünlü ama keyif arıyorsun :)"
    return jsonify({"message": dummy_cevap}), 200

    prompt = (
        f"Kullanıcı şu isteği yazdı: '{mesaj}'. "
        f"Buna göre ruh haline ve tür tercihlerine uygun 1-2 dizi veya film öner. "
        f"Sadece öneri isimlerini ve neden uygun olduklarını kısa şekilde belirt."
    )

    try:
        response = client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[{"role": "user", "content": prompt}],
            temperature=0.7
        )

        yanit = response.choices[0].message.content
        return jsonify({"message": yanit}), 200

    except Exception as e:
        print("Chatbot hatası:", str(e))
        return jsonify({"message": "Chatbot hatası"}), 500



#firebase ile kullanıcı kaydı için bir endpoint ekleyelim

@app.route('/kaydol', methods=['POST'])
def kaydol():
    data = request.json
    print("gelen veri:", data)  # Gelen veriyi kontrol et

    if not data:
        return jsonify({"hata": "Veri yok"}), 400
    
    email = data.get("email")
    sifre = data.get("sifre")
    kullanici_adi = data.get("kullanici_adi")
    dogum_tarihi = data.get("dogum_tarihi")
    if not all([email, sifre, kullanici_adi, dogum_tarihi]):
        return jsonify({"hata": "Tüm alanlar gereklidir"}), 400

    user_ref = db.collection('kullanicilar').document(email)
    if user_ref.get().exists:
        return jsonify({"hata": "Bu e-posta ile kullanıcı zaten var"}), 400

    user_ref.set({
        "email": email,
        "sifre": sifre,
        "kullanici_adi": kullanici_adi,
        "dogum_tarihi": dogum_tarihi,
    })

    return jsonify({"durum": "Kayıt başarılı"}), 201


    

@app.route('/giris', methods=['POST'])
def giris():
    data = request.get_json()
    email = data.get('email')
    sifre = data.get('sifre')

    if not email or not sifre:
        return jsonify({"hata": "Email ve şifre gerekli"}), 400

    user_ref = db.collection('kullanicilar').document(email)
    user = user_ref.get()

    if not user.exists or user.to_dict().get("sifre") != sifre:
        return jsonify({"hata": "Email veya şifre yanlış"}), 401

    return jsonify({"durum": "Giriş başarılı"}), 200


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000,debug=True) 