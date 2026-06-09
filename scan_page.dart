import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'harga_udang.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final MobileScannerController controller = MobileScannerController();

  String result = "Belum ada scan";
  bool isScanned = false;

  void resetScan() {
    setState(() {
      isScanned = false;
      result = "Belum ada scan";
    });
  }

  void handleScan(String code) {
    if (isScanned) return;

    setState(() {
      isScanned = true;
      result = code;
    });

    // ===== CEK QR =====
    if (code == "myapp://harga-udang") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HargaUdangPage(),
        ),
      ).then((_) {
        // reset saat kembali
        resetScan();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("QR tidak dikenali"),
        ),
      );

      Future.delayed(const Duration(seconds: 2), () {
        resetScan();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan QR"),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            onPressed: resetScan,
            icon: const Icon(Icons.refresh),
          )
        ],
      ),

      body: Column(
        children: [
          // ===== CAMERA SCANNER =====
          Expanded(
            flex: 4,
            child: MobileScanner(
              controller: controller,
              onDetect: (capture) {
                final barcode = capture.barcodes.first;
                final String? code = barcode.rawValue;

                if (code != null) {
                  handleScan(code);
                }
              },
            ),
          ),

          // ===== RESULT INFO =====
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              color: Colors.black,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Hasil Scan:",
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    result,
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}