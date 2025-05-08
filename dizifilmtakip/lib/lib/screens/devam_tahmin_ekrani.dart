import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DevamTahminEkrani extends StatefulWidget {
  @override
  _DevamTahminEkraniState createState() => _DevamTahminEkraniState();
}

class _DevamTahminEkraniState extends State<DevamTahminEkrani> {
  TextEditingController diziAdiController = TextEditingController();
  String? tahminSonucu;
  bool yukleniyor = false;

  Future<void> tahminYap(String diziAdi) async {
    setState(() {
      yukleniyor = true;
      tahminSonucu = null;
    });

    final url = Uri.parse('http://10.0.2.2:5000/devam-noktasi-tahmin');

    final cevap = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "diziAdi": diziAdi,
        "cevaplar": [
          "Karakterler arasındaki son olayları tam hatırlamıyorum.",
          "Ana karakterin ne yaptığına emin değilim.",
          "Hangi ilişkiler bozuldu ya da ilerledi, net değil."
        ]
      }),
    );

    if (cevap.statusCode == 200) {
      final json = jsonDecode(cevap.body);
      setState(() {
        tahminSonucu = json['tahmin'];
        yukleniyor = false;
      });
    } else {
      setState(() {
        tahminSonucu = "Tahmin alınamadı. Hata kodu: ${cevap.statusCode}";
        yukleniyor = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Devam Noktası Tahmini")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: diziAdiController,
              decoration: InputDecoration(
                labelText: "Dizi Adı",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final diziAdi = diziAdiController.text.trim();
                if (diziAdi.isNotEmpty) {
                  tahminYap(diziAdi);
                }
              },
              child: Text("Tahmini Göster"),
            ),
            SizedBox(height: 24),
            if (yukleniyor) CircularProgressIndicator(),
            if (!yukleniyor && tahminSonucu != null)
              Text(
                "Tahmin: $tahminSonucu",
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}
