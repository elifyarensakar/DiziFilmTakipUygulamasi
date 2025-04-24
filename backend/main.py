from flask import Flask, request, jsonify
import firebase_admin
from firebase_admin import credentials, firestore
from flask_cors import CORS

app = Flask(__name__)
CORS(app)  # CORS ayarları



# Firebase initialization
cred = credentials.Certificate("C:/Users/Elif yaren/Desktop/DiziFilmTakipUygulamas-/backend/firebase_config.json")
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

    if not data:
        return jsonify({"hata": "Veri yok"}), 400

    db.collection('kullanicilar').add(data)

    return jsonify({"durum": "Kayıt başarılı!"}), 201


if __name__ == '__main__':
    app.run(debug=True)