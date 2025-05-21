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

  final String baseUrl = 'http://172.18.151.65:5000'; // Gerçek cihazda IP ile değiştir

  Future<void> icerikAra(String aramaKelimesi) async {
  setState(() {
    loading = true;
  });

  try {
    final url = Uri.parse('http://172.18.151.65:5000/icerik-listesi?q=$aramaKelimesi');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> cevap = jsonDecode(response.body);
      setState(() {
        icerikListesi = cevap;
        loading = false;
      });
    } else {
      setState(() {
        icerikListesi = [];
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sunucudan cevap alınamadı")),
      );
    }
  } catch (e) {
    setState(() {
      icerikListesi = [];
      loading = false;
    });
    print("Arama hatası: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Bağlantı hatası: $e")),
    );
  }
}


  Future<void> icerikEkle(Map<String, dynamic> secilenIcerik) async {
    String baslik = secilenIcerik['Title'] ?? 'Başlıksız';
    String tur = secilenIcerik['Type'] ?? 'movie';
    String id = secilenIcerik['imdbID'] ?? DateTime.now().millisecondsSinceEpoch.toString();

    int? bolumNumarasi;

    if (tur == "series") {
      bolumController.clear();
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
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
        "currentEpisode": bolumNumarasi ?? 1
      }),
    );

    final cevap = jsonDecode(response.body);
    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("İçerik başarıyla eklendi.")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(cevap['message'] ?? 'Bir hata oluştu')),
      );
    }
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
      appBar: AppBar(title: Text('İçerik Ara')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: aramaController,
              decoration: InputDecoration(
                hintText: 'Dizi/Film ara',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    if (aramaController.text.isNotEmpty) {
                      icerikAra(aramaController.text);
                    }
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: loading
                  ? Center(child: CircularProgressIndicator())
                  : icerikListesi.isEmpty
                      ? Center(child: Text("Sonuç bulunamadı"))
                      : ListView.builder(
                          itemCount: icerikListesi.length,
                          itemBuilder: (context, index) {
                            final item = icerikListesi[index];
                            return ListTile(
                              title: Text(item['Title'] ?? 'Başlıksız'),
                              subtitle: Text(item['Type'] ?? ''),
                              trailing: Icon(Icons.add),
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
