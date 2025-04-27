// TODO Implement this library.
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

  Future<void> icerikAra(String aramaKelimesi) async {
    setState(() {
      loading = true;
    });

    final url = Uri.parse('http://10.0.2.2:5000/icerik-listesi?q=$aramaKelimesi');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> cevap = jsonDecode(response.body);
        setState(() {
          icerikListesi = cevap;
          loading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('İçerik bulunamadı.')),
        );
        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      print('Hata: $e');
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> icerikEkle(Map<String, dynamic> secilenIcerik) async {
    String baslik = secilenIcerik['Title'];
    String tur = secilenIcerik['Type']; // movie veya series

    int? bolumNumarasi;
    if (tur == "series") {
      // Eğer dizi seçildiyse bölüm sor
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Kaçıncı Bölümdesin?'),
            content: TextField(
              controller: bolumController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(hintText: 'Bölüm Numarası'),
            ),
            actions: [
              TextButton(
                child: Text('Tamam'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
      bolumNumarasi = int.tryParse(bolumController.text);
    }

    final ekleUrl = Uri.parse('http://10.0.2.2:5000/icerik-ekle');

    try {
      final response = await http.post(
        ekleUrl,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": widget.kullaniciEmail,
          "baslik": baslik,
          "tur": tur,
          "bolum": bolumNumarasi
        }),
      );

      final cevap = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(cevap['durum'] ?? 'İçerik eklendi!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(cevap['hata'] ?? 'Bir hata oluştu')),
        );
      }
    } catch (e) {
      print('Hata oluştu: $e');
    }
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
            loading
                ? CircularProgressIndicator()
                : Expanded(
                    child: ListView.builder(
                      itemCount: icerikListesi.length,
                      itemBuilder: (context, index) {
                        final item = icerikListesi[index];
                        return ListTile(
                          title: Text(item['Title']),
                          subtitle: Text(item['Type']),
                          trailing: Icon(Icons.add),
                          onTap: () {
                            icerikEkle(item);
                          },
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
