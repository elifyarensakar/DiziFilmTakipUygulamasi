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

    final url = Uri.parse('http://172.18.151.65:5000/devam-noktasi-tahmin');
    final cevap = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "diziAdi": diziAdi,
        "cevaplar": [
          "Karakterler arasındaki son olayları tam hatırlamıyorum.",
          "Ana karakterin ne yaptığına emin değilim.",
          "Hangi ilişkiler bozuldu ya da ilerledi, net değil.",
        ],
      }),
    );

    setState(() {
      yukleniyor = false;
      if (cevap.statusCode == 200) {
        tahminSonucu = jsonDecode(cevap.body)['tahmin'];
      } else {
        tahminSonucu = "Tahmin alınamadı. Hata kodu: ${cevap.statusCode}";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF03003F),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 24),
            Center(
              child: Text(
                "Quiz - Devam Tahmin",
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextField(
                controller: diziAdiController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Dizi Adı",
                  hintStyle: TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.grey.shade600,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final diziAdi = diziAdiController.text.trim();
                if (diziAdi.isNotEmpty) tahminYap(diziAdi);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
              child: Text(
                "Tahmini Göster",
                style: TextStyle(color: Colors.black),
              ),
            ),
            SizedBox(height: 24),
            if (yukleniyor)
              CircularProgressIndicator()
            else if (tahminSonucu != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade600,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "Tahmin: $tahminSonucu",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            Spacer(),

            Container(
              padding: EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: BottomNavigationBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                type: BottomNavigationBarType.fixed,
                selectedItemColor: Colors.deepPurple,
                unselectedItemColor: Colors.black87,
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
}
