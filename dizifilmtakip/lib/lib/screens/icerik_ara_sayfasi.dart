import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class IcerikAraSayfasi extends StatefulWidget {
  final String kullaniciEmail;
  IcerikAraSayfasi({required this.kullaniciEmail});

  @override
  _IcerikAraSayfasiState createState() => _IcerikAraSayfasiState();
}

class _IcerikAraSayfasiState extends State<IcerikAraSayfasi> {
  TextEditingController aramaController = TextEditingController();
  TextEditingController bolumController = TextEditingController();
  List<dynamic> icerikListesi = [];
  bool loading = false;

  final String baseUrl = 'http://172.18.151.65:5000';

  Future<void> icerikAra(String aramaKelimesi) async {
    setState(() => loading = true);
    try {
      final url = Uri.parse('$baseUrl/icerik-listesi?q=$aramaKelimesi');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          icerikListesi = jsonDecode(response.body);
        });
      } else {
        setState(() => icerikListesi = []);
        _showToast("Sunucudan cevap alınamadı.");
      }
    } catch (e) {
      setState(() => icerikListesi = []);
      _showToast("Bağlantı hatası: $e");
    }
    setState(() => loading = false);
  }

  Future<void> icerikEkle(Map<String, dynamic> secilenIcerik) async {
    String baslik = secilenIcerik['Title'] ?? 'Başlıksız';
    String tur = secilenIcerik['Type'] ?? 'movie';
    String id =
        secilenIcerik['imdbID'] ??
        DateTime.now().millisecondsSinceEpoch.toString();

    int? bolumNumarasi;

    if (tur == "series") {
      bolumController.clear();
      await showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Kaçıncı bölümdesin?'),
              content: TextField(
                controller: bolumController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(hintText: 'Bölüm Numarası'),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Tamam'),
                ),
              ],
            ),
      );
      bolumNumarasi = int.tryParse(bolumController.text) ?? 1;
    }

    final url = Uri.parse('$baseUrl/izleme-kaydi-ekle');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userId": widget.kullaniciEmail,
        "contentId": id,
        "title": baslik,
        "type": tur == "series" ? "dizi" : "film",
        "status": "izleniyor",
        "currentSeason": tur == "series" ? 1 : null,
        "currentEpisode": bolumNumarasi ?? 1,
      }),
    );

    final cevap = jsonDecode(response.body);
    if (response.statusCode == 201) {
      _showToast("İçerik başarıyla eklendi.");
    } else {
      _showToast(cevap['message'] ?? 'Bir hata oluştu.');
    }
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    aramaController.dispose();
    bolumController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF03003F),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextField(
                controller: aramaController,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: 'Dizi veya Film ara ...',
                  prefixIcon: Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) icerikAra(value.trim());
                },
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child:
                  loading
                      ? Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                      : icerikListesi.isEmpty
                      ? Center(
                        child: Text(
                          "Sonuç bulunamadı",
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                      : ListView.builder(
                        itemCount: icerikListesi.length,
                        itemBuilder: (context, index) {
                          final item = icerikListesi[index];
                          return ListTile(
                            title: Text(
                              item['Title'] ?? '-',
                              style: TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              item['Type'] ?? '',
                              style: TextStyle(color: Colors.white54),
                            ),
                            trailing: Icon(Icons.add, color: Colors.white),
                            onTap: () => icerikEkle(item),
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
