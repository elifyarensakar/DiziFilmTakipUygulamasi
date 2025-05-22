import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfilSayfasi extends StatefulWidget {
  final String kullaniciEmail;
  ProfilSayfasi({required this.kullaniciEmail});

  @override
  _ProfilSayfasiState createState() => _ProfilSayfasiState();
}

class _ProfilSayfasiState extends State<ProfilSayfasi> {
  List<Map<String, dynamic>> izlemeListesi = [];
  TextEditingController icerikController = TextEditingController();
  final String baseUrl = 'http://172.18.151.65:5000';

  @override
  void initState() {
    super.initState();
    izlemeListesiniGetir();
  }

  Future<void> izlemeListesiniGetir() async {
    final url = Uri.parse(
      '$baseUrl/izleme-kaydi-listele/${widget.kullaniciEmail}',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        izlemeListesi = data.cast<Map<String, dynamic>>();
      });
    } else {
      print('Listeleme hatası: ${response.statusCode}');
    }
  }

  Future<void> icerikEkle() async {
    final url = Uri.parse('$baseUrl/izleme-kaydi-ekle');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "userId": widget.kullaniciEmail,
        "contentId": DateTime.now().millisecondsSinceEpoch.toString(),
        "title": icerikController.text.trim(),
        "type": "dizi",
        "status": "izleniyor",
      }),
    );

    if (response.statusCode == 201) {
      icerikController.clear();
      await izlemeListesiniGetir();
    } else {
      print('Ekleme hatası: ${response.statusCode}');
    }
  }

  Future<void> icerikSil(String watchId) async {
    final url = Uri.parse(
      '$baseUrl/izleme-kaydi-sil/${widget.kullaniciEmail}/$watchId',
    );
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      await izlemeListesiniGetir();
    } else {
      print('Silme hatası: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF03003F),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.account_circle, size: 80, color: Colors.white),
              SizedBox(height: 12),
              Text(
                "Profil",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade700,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "İsim - Soyisim:",
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "E-posta: ${widget.kullaniciEmail}",
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Doğum Tarihi:",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Wrap(
                spacing: 16,
                runSpacing: 12,
                children: [
                  ElevatedButton(
                    onPressed: izlemeListesiniGetir,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlueAccent,
                    ),
                    child: Text(
                      "Listele",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: icerikEkle,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlueAccent,
                    ),
                    child: Text("Ekle", style: TextStyle(color: Colors.black)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (izlemeListesi.isNotEmpty) {
                        final id = izlemeListesi.last['id'];
                        icerikSil(id);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlueAccent,
                    ),
                    child: Text("Sil", style: TextStyle(color: Colors.black)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Güncelleme özelliği aktif değil"),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlueAccent,
                    ),
                    child: Text(
                      "Güncelle",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
