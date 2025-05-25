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
  final TextEditingController aramaController = TextEditingController();
  final TextEditingController bolumController = TextEditingController();
  final String baseUrl = 'http://172.18.151.65:5000';

  List<dynamic> icerikListesi = [];
  bool loading = false;

  Future<void> icerikAra(String query) async {
    if (query.isEmpty) return;
    setState(() => loading = true);

    try {
      final response = await http.get(Uri.parse('$baseUrl/icerik-listesi?q=$query'));
      if (response.statusCode == 200) {
        setState(() {
          icerikListesi = jsonDecode(response.body);
        });
      } else {
        _showToast("Sunucudan cevap alınamadı (${response.statusCode}).");
      }
    } catch (e) {
      _showToast("Bağlantı hatası: $e");
    }

    setState(() => loading = false);
  }

  Future<void> icerikEkle(Map<String, dynamic> secilen) async {
    final String title = secilen['Title'] ?? 'Başlıksız';
    final String type = secilen['Type'] ?? 'movie';
    final String contentId = secilen['imdbID'] ?? DateTime.now().millisecondsSinceEpoch.toString();

    int? currentEpisode;
    if (type == "series") {
      bolumController.clear();
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Kaçıncı bölümde kaldın?"),
          content: TextField(
            controller: bolumController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: "Bölüm numarası"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Tamam"),
            ),
          ],
        ),
      );
      currentEpisode = int.tryParse(bolumController.text) ?? 1;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/izleme-kaydi-ekle'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userId": widget.kullaniciEmail,
        "contentId": contentId,
        "title": title,
        "type": type == "series" ? "dizi" : "film",
        "status": "izleniyor",
        "currentSeason": type == "series" ? 1 : null,
        "currentEpisode": currentEpisode ?? 1,
      }),
    );

    if (response.statusCode == 201) {
      _showToast("İçerik başarıyla eklendi.");
    } else {
      final hata = jsonDecode(response.body)['message'] ?? "Hata oluştu.";
      _showToast("Ekleme başarısız: $hata");
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
                  hintText: "Dizi veya Film ara...",
                  prefixIcon: Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (val) => icerikAra(val.trim()),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: loading
                  ? Center(child: CircularProgressIndicator(color: Colors.white))
                  : icerikListesi.isEmpty
                      ? Center(child: Text("Sonuç bulunamadı", style: TextStyle(color: Colors.white70)))
                      : ListView.builder(
                          itemCount: icerikListesi.length,
                          itemBuilder: (context, index) {
                            final item = icerikListesi[index];
                            return ListTile(
                              title: Text(item['Title'] ?? '-', style: TextStyle(color: Colors.white)),
                              subtitle: Text(item['Type'] ?? '', style: TextStyle(color: Colors.white54)),
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