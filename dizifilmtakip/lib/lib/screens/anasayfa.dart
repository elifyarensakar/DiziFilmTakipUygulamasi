import 'package:flutter/material.dart';
import 'package:dizifilmtakip/lib/screens/oneri_chatbot_ekrani.dart';
import 'package:dizifilmtakip/lib/screens/icerik_ara_sayfasi.dart';
import 'package:dizifilmtakip/lib/screens/profil_sayfasi.dart';
import 'package:dizifilmtakip/lib/screens/devam_tahmin_ekrani.dart';

class AnaSayfa extends StatefulWidget {
  final String kullaniciEmail;
  AnaSayfa({required this.kullaniciEmail});

  @override
  _AnaSayfaState createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  int seciliIndex = 1;

  @override
  Widget build(BuildContext context) {
    final sayfalar = [
      OneriChatbotEkrani(),
      AnaEkran(email: widget.kullaniciEmail),
      ProfilSayfasi(kullaniciEmail: widget.kullaniciEmail),
      DevamTahminEkrani(),
    ];

    return Scaffold(
      body: sayfalar[seciliIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: seciliIndex,
        onTap: (index) {
          setState(() {
            seciliIndex = index;
          });
        },
        backgroundColor: Colors.grey.shade300,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.black87,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: '',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.help_outline), label: ''),
        ],
      ),
    );
  }
}

class AnaEkran extends StatelessWidget {
  final String email;
  const AnaEkran({required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF03003F),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.movie, color: Colors.white, size: 80),
            SizedBox(height: 16),
            Text(
              'Hoş geldin 👋',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            SizedBox(height: 8),
            Text(email, style: TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}
