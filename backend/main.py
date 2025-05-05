from flask import Flask, request, jsonify
import firebase_admin
from firebase_admin import credentials, firestore
from flask_cors import CORS
import requests


OMDB_API_KEY= '157be653'

app = Flask(__name__)
CORS(app)  # CORS ayarları

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
        return jsonify({"hata": data.get('Hata', 'İcerik bulunamadi')}), 404
    
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




# Firebase initialization
cred = credentials.Certificate("C:/Users/Elif yaren/Desktop/DiziFilmTakipUygulamasi/backend/firebase_config.json")
firebase_admin.initialize_app(cred)
db = firestore.client()
 

# Flask uygulaması için gerekli ayarlar
@app.route('/')
def hello():
    return "Merhaba Dunya! Backend çalisiyor :)"

@app.route('/selamla', methods=['POST'])
def selamla():
    data = request.json  
    isim = data.get('isim', 'isim yok')
    return jsonify({"mesaj": f"Merhaba {isim}!"})


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

    if not email or not sifre or not kullanici_adi or not dogum_tarihi:
        return jsonify({"hata": "Email, şifre, kullanıcı adı ve doğum tarihi zorunludur."}), 400
    
    kullanici_bilgisi = {
        "email": email,
        "sifre": sifre,
        "kullanici_adi": kullanici_adi,
        "dogum_tarihi": dogum_tarihi
    }


    db.collection('kullanicilar').add(data)

    return jsonify({"durum": "Kayıt başarılı!"}), 201

@app.route('/giris', methods=['POST'])
def giris():
    data = request.json
    email = data.get("email")
    sifre = data.get("sifre")

    if not email or not sifre:
        return jsonify({"hata": "Email ve şifre zorunludur."}), 400

    # Firestore'dan kullanıcıyı ara
    kullanici_ref = db.collection('kullanicilar')
    sorgu = kullanici_ref.where("email", "==", email).where("sifre", "==", sifre).stream()

    for doc in sorgu:
        return jsonify({"mesaj": "Giriş başarılı!", "kullanici_id": doc.id}), 200

    return jsonify({"hata": "Email veya şifre yanlış."}), 401

if __name__ == '__main__':
    app.run(debug=True) 