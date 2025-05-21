import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OneriChatbotEkrani extends StatefulWidget {
  @override
  _OneriChatbotEkraniState createState() => _OneriChatbotEkraniState();
}

class _OneriChatbotEkraniState extends State<OneriChatbotEkrani> {
  TextEditingController mesajController = TextEditingController();
  String? yanit;
  bool yukleniyor = false;

  Future<void> oneriAl() async {
    setState(() {
      yukleniyor = true;
      yanit = null;
    });

    final response = await http.post(
      Uri.parse('http://172.18.151.65:5000/oneri-chatbotu'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"mesaj": mesajController.text.trim()}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        yanit = data['oneri'];
        yukleniyor = false;
      });
    } else {
      setState(() {
        yanit = "Bir hata oluştu. Kod: ${response.statusCode}";
        yukleniyor = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Öneri Chatbotu")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: mesajController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Ne izlemek istersin?",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: oneriAl,
              child: Text("Öneri Al"),
            ),
            SizedBox(height: 24),
            if (yukleniyor) CircularProgressIndicator(),
            if (yanit != null)
              Text(
                "Chatbot: $yanit",
                style: TextStyle(fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }
}
