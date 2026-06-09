import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KeluarPage extends StatelessWidget {
  const KeluarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE066),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const Text(
              "Keluar dari aplikasi?",
              style: TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Tidak"),
                ),

                const SizedBox(width: 15),

                ElevatedButton(
                  onPressed: () {
                    SystemNavigator.pop();
                  },
                  child: const Text("Iya"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}