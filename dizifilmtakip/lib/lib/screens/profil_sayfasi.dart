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

  final baseUrl = 'http://172.18.151.65:5000';

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
    }
  }

  Future<void> icerikSil(String watchId) async {
    final url = Uri.parse(
      '$baseUrl/izleme-kaydi-sil/${widget.kullaniciEmail}/$watchId',
    );
    final response = await http.delete(url);
    if (response.statusCode == 200) {
      await izlemeListesiniGetir();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF03003F),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 24),
            Text(
              'Profil',
              style: TextStyle(
                fontSize: 26,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Container(
              color: Color(0xFF3C3C5C),
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.account_circle, color: Colors.white, size: 40),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "İsim - Soyisim:",
                            style: TextStyle(color: Colors.white70),
                          ),
                          Text(
                            "E-posta: ${widget.kullaniciEmail}",
                            style: TextStyle(color: Colors.white70),
                          ),
                          Text(
                            "Doğum Tarihi: -",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                _profilButton("Listele", izlemeListesiniGetir),
                _profilButton("Ekle", icerikEkle),
                _profilButton(
                  "Güncelle",
                  () => print("Güncelle logic eklenecek"),
                ),
                _profilButton("Sil", () {
                  if (izlemeListesi.isNotEmpty) {
                    icerikSil(izlemeListesi.last['id']);
                  }
                }),
              ],
            ),
            SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextField(
                controller: icerikController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Yeni dizi/film ekle",
                  hintStyle: TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child:
                  izlemeListesi.isEmpty
                      ? Center(
                        child: Text(
                          "İçerik bulunamadı.",
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                      : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        itemCount: izlemeListesi.length,
                        itemBuilder: (context, index) {
                          final item = izlemeListesi[index];
                          return ListTile(
                            title: Text(
                              item['title'] ?? 'Başlıksız',
                              style: TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              "${item['type']} - ${item['status']}",
                              style: TextStyle(color: Colors.white60),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () => icerikSil(item['id']),
                            ),
                          );
                        },
                      ),
            ),
            Container(
              padding: EdgeInsets.only(top: 8, bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: BottomNavigationBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                selectedItemColor: Colors.deepPurple,
                unselectedItemColor: Colors.black87,
                type: BottomNavigationBarType.fixed,
                showSelectedLabels: false,
                showUnselectedLabels: false,
                onTap: (index) {},
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.chat_bubble_outline),
                    label: '',
                  ),
                  BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline),
                    label: '',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.help_outline),
                    label: '',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profilButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.lightBlueAccent,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(text, style: TextStyle(color: Colors.black)),
    );
  }
}
