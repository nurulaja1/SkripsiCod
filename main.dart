import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';

// IMPORT HALAMAN
import 'halaman_admin.dart';
import 'beli_sekarang.dart';
import 'halaman_tentang.dart';
import 'splash_screen.dart';
import 'scan_page.dart';
import 'harga_udang.dart';

final GlobalKey<NavigatorState> navigatorKey =
    GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF02203A),
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const MyApp());
}

// ================= APP =================
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription? sub;

  @override
  void initState() {
    super.initState();

    _appLinks.getInitialLink().then((Uri? uri) {
      if (!mounted) return;
      if (uri != null) {
        debugPrint("INITIAL LINK: $uri");
        _handleDeepLink(uri);
      }
    });

    sub = _appLinks.uriLinkStream.listen((Uri? uri) {
      if (!mounted) return;
      if (uri == null) return;

      debugPrint("DEEP LINK: $uri");
      _handleDeepLink(uri);
    });
  }

  void _handleDeepLink(Uri uri) {
    if (uri.host == "harga-udang") {
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => HargaUdangPage(),
        ),
        (route) => route.isFirst,
      );
    }

    if (uri.host == "scan") {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => const ScanPage(),
        ),
      );
    }
  }

  @override
  void dispose() {
    sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

// ================= MENU UTAMA =================
class MenuUtama extends StatefulWidget {
  const MenuUtama({super.key});

  @override
  State<MenuUtama> createState() => _MenuUtamaState();
}

class _MenuUtamaState extends State<MenuUtama>
    with SingleTickerProviderStateMixin {

  late AnimationController controller;
  late Animation<double> fade;
  late Animation<Offset> slide;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    fade = Tween<double>(begin: 0, end: 1).animate(controller);

    slide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeOut,
    ));

    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void loginAdmin() {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("Login Admin"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Password"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                if (emailController.text == "admin@gmail.com" &&
                    passwordController.text == "admin123") {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminPage(),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Login gagal")),
                  );
                }
              },
              child: const Text("Login"),
            ),
          ],
        );
      },
    );
  }

  void konfirmasiKeluar() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Keluar"),
          content: const Text("Apakah Anda yakin ingin keluar?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Tidak"),
            ),
            ElevatedButton(
              onPressed: () => SystemNavigator.pop(),
              child: const Text("Iya"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE066),

      appBar: AppBar(
        backgroundColor: const Color(0xFF02203A),
        title: const Text(
          "Menu Utama",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings, color: Colors.white),
            onPressed: loginAdmin,
          )
        ],
      ),

      body: FadeTransition(
        opacity: fade,
        child: SlideTransition(
          position: slide,
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF02203A),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

// ================= LOGO FIX =================
// ================= LOGO BULAT TANPA BORDER =================
ClipOval(
  child: Image.asset(
    "assets/images/logo.png",
    width: 120,
    height: 120,
    fit: BoxFit.cover,
  ),
),

                  menuButton(
                    icon: Icons.qr_code_scanner,
                    text: "Scan",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ScanPage(),
                        ),
                      );
                    },
                  ),

                  menuButton(
                    icon: Icons.shopping_cart,
                    text: "Beli Sekarang",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BeliSekarangPage(),
                        ),
                      );
                    },
                  ),

                  menuButton(
                    icon: Icons.info,
                    text: "Tentang",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TentangPage(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 15),

                  ElevatedButton(
                    onPressed: konfirmasiKeluar,
                    child: const Text("Keluar"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget menuButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(icon),
              const SizedBox(width: 15),
              Expanded(child: Text(text)),
            ],
          ),
        ),
      ),
    );
  }
}