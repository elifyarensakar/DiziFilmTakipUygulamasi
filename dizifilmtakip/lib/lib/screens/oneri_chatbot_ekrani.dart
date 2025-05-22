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
        yanit = data['message'];
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
      backgroundColor: Color(0xFF03003F),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              SizedBox(height: 12),
              Center(
                child: Text(
                  "Chatbot",
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade700,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    yanit ?? "Sohbet buraya gelecek...",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: mesajController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Sana nasıl yardımcı olabilirim ?",
                        hintStyle: TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.grey.shade600,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Icon(
                          Icons.chat_bubble_outline,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: oneriAl,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlueAccent,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    child: Text(
                      "Gönder",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
