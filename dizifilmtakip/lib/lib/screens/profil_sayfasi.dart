import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dizifilmtakip/lib/screens/icerik_ara_sayfasi.dart';

class ProfilSayfasi extends StatefulWidget {
  final String kullaniciEmail;
  ProfilSayfasi({required this.kullaniciEmail});

  @override
  _ProfilSayfasiState createState() => _ProfilSayfasiState();
}

class _ProfilSayfasiState extends State<ProfilSayfasi> {
  List<Map<String, dynamic>> izlemeListesi = [];
  final String baseUrl = 'http://172.18.151.65:5000';

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
      _showToast('Listeleme hatası: ${response.statusCode}');
    }
  }

  Future<void> icerikSil(String watchId) async {
    final url = Uri.parse('$baseUrl/izleme-kaydi-sil/${widget.kullaniciEmail}/$watchId');
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      _showToast("Silme başarılı");
      await izlemeListesiniGetir();
    } else {
      _showToast('Silme hatası: ${response.statusCode}');
    }
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
  // Güncelleme dialogu
void _durumGuncelleDialog(String watchId) {
  String secilenDurum = "izleniyor";

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("İçerik Durumunu Güncelle"),
        content: StatefulBuilder(
          builder: (context, setState) {
            return DropdownButton<String>(
              value: secilenDurum,
              isExpanded: true,
              items: [
                "izleniyor",
                "tamamlandı",
                "bırakıldı",
                "izlenecek",
              ].map((durum) {
                return DropdownMenuItem(
                  value: durum,
                  child: Text(durum),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  secilenDurum = value!;
                });
              },
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await icerikDurumunuGuncelle(watchId, secilenDurum);
            },
            child: Text("Güncelle"),
          ),
        ],
      );
    },
  );
}

// Backend'e PATCH isteği
Future<void> icerikDurumunuGuncelle(String watchId, String yeniDurum) async {
  final url = Uri.parse('$baseUrl/izleme-kaydi-guncelle/${widget.kullaniciEmail}/$watchId');

  final response = await http.patch(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      "status": yeniDurum,
    }),
  );

  if (response.statusCode == 200) {
    _showToast("Durum güncellendi");
    await izlemeListesiniGetir();
  } else {
    _showToast("Güncelleme hatası: ${response.statusCode}");
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
                    Text("E-posta: ${widget.kullaniciEmail}", style: TextStyle(color: Colors.white)),
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
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlueAccent),
                    child: Text("Listele", style: TextStyle(color: Colors.black)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => IcerikAraSayfasi(
                            kullaniciEmail: widget.kullaniciEmail,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlueAccent),
                    child: Text("Ekle", style: TextStyle(color: Colors.black)),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        if (izlemeListesi.isNotEmpty) {
                          final sonIcerik = izlemeListesi.last;
                          _durumGuncelleDialog(sonIcerik['id']);
                        } else {
                          _showToast("Güncellenecek içerik yok.");
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlueAccent),
                      child: Text("Güncelle", style: TextStyle(color: Colors.black)),
                    ),
                ],
              ),
              SizedBox(height: 20),
              Expanded(
                child: izlemeListesi.isEmpty
                    ? Center(child: Text("Henüz içerik eklenmemiş.", style: TextStyle(color: Colors.white70)))
                    : ListView.builder(
                        itemCount: izlemeListesi.length,
                        itemBuilder: (context, index) {
                          final icerik = izlemeListesi[index];
                          return Card(
                            color: Colors.white10,
                            child: ListTile(
                              title: Text(icerik['title'] ?? '-', style: TextStyle(color: Colors.white)),
                              subtitle: Text("Durum: ${icerik['status']}", style: TextStyle(color: Colors.white60)),
                              trailing: IconButton(
                                icon: Icon(Icons.delete, color: Colors.redAccent),
                                onPressed: () => icerikSil(icerik['id']),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}