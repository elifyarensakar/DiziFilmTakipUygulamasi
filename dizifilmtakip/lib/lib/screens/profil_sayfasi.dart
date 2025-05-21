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

  final baseUrl = 'http://172.18.151.65:5000'; // Gerçek cihazdaysan IP'yi değiştir

  @override
  void initState() {
    super.initState();
    izlemeListesiniGetir();
  }

  Future<void> izlemeListesiniGetir() async {
    final url = Uri.parse('$baseUrl/izleme-kaydi-listele/${widget.kullaniciEmail}');
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
        "type": "dizi", // veya "film"
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
    final url = Uri.parse('$baseUrl/izleme-kaydi-sil/${widget.kullaniciEmail}/$watchId');
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
      appBar: AppBar(title: Text('Profilim')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: icerikController,
              decoration: InputDecoration(
                labelText: 'Yeni dizi/film ekle',
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: icerikEkle,
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: izlemeListesi.isEmpty
                  ? Center(child: Text("İçerik bulunamadı."))
                  : ListView.builder(
                      itemCount: izlemeListesi.length,
                      itemBuilder: (context, index) {
                        final item = izlemeListesi[index];
                        return ListTile(
                          title: Text(item['title'] ?? 'Başlıksız'),
                          subtitle: Text('${item['type']} - ${item['status']}'),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => icerikSil(item['id']),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
