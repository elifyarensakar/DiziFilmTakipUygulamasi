import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OneriChatbotEkrani extends StatefulWidget {
  @override
  _OneriChatbotEkraniState createState() => _OneriChatbotEkraniState();
}

class _OneriChatbotEkraniState extends State<OneriChatbotEkrani> {
  final TextEditingController mesajController = TextEditingController();
  final List<String> mesajlar = ["Sohbet buraya gelecek..."];
  bool yukleniyor = false;

  Future<void> oneriAl() async {
    final mesaj = mesajController.text.trim();
    if (mesaj.isEmpty) return;

    setState(() {
      yukleniyor = true;
      mesajlar.add("Sen: $mesaj");
    });

    final response = await http.post(
      Uri.parse('http://172.18.151.65:5000/oneri-chatbotu'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"mesaj": mesaj}),
    );

    setState(() {
      yukleniyor = false;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        mesajlar.add("Chatbot: ${data['message']}");
      } else {
        mesajlar.add("Chatbot: Bir hata oluştu. Kod: ${response.statusCode}");
      }
      mesajController.clear();
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
                'Chatbot',
                style: TextStyle(
                  fontSize: 26,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF3C3C5C),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: EdgeInsets.all(16),
                  child: ListView.builder(
                    itemCount: mesajlar.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          mesajlar[index],
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: mesajController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Sana nasıl yardımcı olabilirim ?',
                        hintStyle: TextStyle(color: Colors.white60),
                        filled: true,
                        fillColor: Color(0xFF3C3C5C),
                        prefixIcon: Icon(
                          Icons.chat_bubble_outline,
                          color: Colors.white60,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: yukleniyor ? null : oneriAl,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlueAccent,
                      padding: EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      "Gönder",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 8),
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
}
