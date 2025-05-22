import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:dizifilmtakip/lib/screens/icerik_ara_sayfasi.dart';
import 'package:dizifilmtakip/lib/screens/devam_tahmin_ekrani.dart';
import 'package:dizifilmtakip/lib/screens/oneri_chatbot_ekrani.dart';
import 'package:dizifilmtakip/lib/screens/profil_sayfasi.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dizi Film Takip',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      initialRoute: '/',
      routes: {
        '/': (context) => GirisSayfasi(),
        '/kayit': (context) => KayitSayfasi(),
        '/anasayfa': (context) {
          final email = ModalRoute.of(context)!.settings.arguments as String;
          return AnaSayfa(kullaniciEmail: email);
        },
        '/arama': (context) {
          final email = ModalRoute.of(context)!.settings.arguments as String;
          return IcerikAraSayfasi(kullaniciEmail: email);
        },
        '/quiz': (context) => DevamTahminEkrani(),
        '/chatbot': (context) => OneriChatbotEkrani(),
        '/profil': (context) {
          final email = ModalRoute.of(context)!.settings.arguments as String;
          return ProfilSayfasi(kullaniciEmail: email);
        },
      },
    );
  }
}

// ======================== GİRİŞ SAYFASI ========================

class GirisSayfasi extends StatefulWidget {
  @override
  _GirisSayfasiState createState() => _GirisSayfasiState();
}

class _GirisSayfasiState extends State<GirisSayfasi> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController sifreController = TextEditingController();
  bool yukleniyor = false;

  Future<void> girisYap() async {
    setState(() => yukleniyor = true);

    final url = Uri.parse(
      'http://172.18.151.65:5000/giris',
    ); // IP adresini kendi bilgisayarına göre değiştir
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": emailController.text.trim(),
        "sifre": sifreController.text,
      }),
    );

    setState(() => yukleniyor = false);
    final cevap = jsonDecode(response.body);

    if (response.statusCode == 200) {
      Navigator.pushNamed(
        context,
        '/anasayfa',
        arguments: emailController.text.trim(),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(cevap['hata'] ?? 'Giriş başarısız')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Giriş Yap',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 40),

              TextField(
                controller: emailController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'E-posta',
                  labelStyle: TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 16),

              TextField(
                controller: sifreController,
                obscureText: true,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Şifre',
                  labelStyle: TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: yukleniyor ? null : girisYap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      yukleniyor
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text('Giriş Yap', style: TextStyle(fontSize: 16)),
                ),
              ),
              SizedBox(height: 12),

              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/kayit');
                },
                child: Text(
                  'Hesabın yok mu? Kaydol',
                  style: TextStyle(color: Colors.deepPurpleAccent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ======================== KAYIT SAYFASI ========================

class KayitSayfasi extends StatefulWidget {
  @override
  _KayitSayfasiState createState() => _KayitSayfasiState();
}

class _KayitSayfasiState extends State<KayitSayfasi> {
  final emailController = TextEditingController();
  final sifreController = TextEditingController();
  final kullaniciAdiController = TextEditingController();
  final dogumTarihiController = TextEditingController();
  bool yukleniyor = false;

  Future<void> kaydol() async {
    setState(() => yukleniyor = true);

    final response = await http.post(
      Uri.parse('http://172.18.151.65:5000/kaydol'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": emailController.text.trim(),
        "sifre": sifreController.text,
        "kullanici_adi": kullaniciAdiController.text,
        "dogum_tarihi": dogumTarihiController.text,
      }),
    );

    setState(() => yukleniyor = false);
    final cevap = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(cevap['durum'] ?? 'Kayıt başarılı')),
      );
      Navigator.pop(context); // Giriş ekranına geri dön
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(cevap['hata'] ?? 'Kayıt başarısız')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 40),
                Text(
                  'Kayıt Ol',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 32),

                buildTextField("E-posta", emailController),
                SizedBox(height: 16),

                buildTextField("Şifre", sifreController, obscure: true),
                SizedBox(height: 16),

                buildTextField("Kullanıcı Adı", kullaniciAdiController),
                SizedBox(height: 16),

                buildTextField(
                  "Doğum Tarihi (GG/AA/YYYY)",
                  dogumTarihiController,
                ),
                SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: yukleniyor ? null : kaydol,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child:
                        yukleniyor
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text('Kaydol', style: TextStyle(fontSize: 16)),
                  ),
                ),
                SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Zaten hesabın var mı? Giriş Yap',
                    style: TextStyle(color: Colors.deepPurpleAccent),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
    String label,
    TextEditingController controller, {
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[900],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// ======================== ANA SAYFA ========================

// ======================== FİGMA UYUMLU ANA SAYFA ========================

class AnaSayfa extends StatelessWidget {
  final String kullaniciEmail;
  AnaSayfa({required this.kullaniciEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF03003F), // Figma'daki lacivert arka plan
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Text(
                  "Anasayfa",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 40),
              TextField(
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: 'Dizi veya Film ara ...',
                  prefixIcon: Icon(Icons.search, color: Colors.black),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              // Geri kalan içerik burada olacaksa eklenebilir
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(bottom: 8, top: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Colors.deepPurple,
          unselectedItemColor: Colors.black87,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          onTap: (index) {
            // Navigation işlemleri
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              label: "",
            ),
            BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: "",
            ),
            BottomNavigationBarItem(icon: Icon(Icons.help_outline), label: ""),
          ],
        ),
      ),
    );
  }
}






/*class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Backend Test',
      home:Scaffold(
        appBar:AppBar(
          title: Text('Kayit testi'),
          ),
          body: Center(
            child: KayitButonu(),
          ),),
      //theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        //colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      );
     // home: const MyHomePage(title: 'Flutter Demo Home Page'),
  }
}



class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});


  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
*/