import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'data_udang.dart';

class BeliSekarangPage extends StatefulWidget {
  const BeliSekarangPage({super.key});

  @override
  State<BeliSekarangPage> createState() => _BeliSekarangPageState();
}

class _BeliSekarangPageState extends State<BeliSekarangPage> {
  int qty1 = 0;
  int? size1;
  DateTime? tanggal1;

  String metodeBayar = "Cash";
  String jamCheckout = "";

  final TextEditingController namaController = TextEditingController();
  final TextEditingController alamatController = TextEditingController();
  final TextEditingController hpController = TextEditingController();

  bool isProcessing = false;

  // ================= FORMAT =================
  String formatTanggal(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String formatJam(DateTime date) {
    return DateFormat('HH:mm:ss').format(date);
  }

  DateTime parseTanggal(String tgl) {
    try {
      List<String> parts = tgl.split('/');
      return DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      );
    } catch (e) {
      return DateTime(2000);
    }
  }

  // ================= HARGA =================
  int getHarga(int size, DateTime? tanggalDipilih) {
    if (tanggalDipilih == null) return 0;

    List<Map<String, String>> data = DataUdang.hargaUdang
        .where((item) =>
            item['Size'] != null && item['Size'] == size.toString())
        .toList();

    if (data.isEmpty) return 0;

    List<Map<String, String>> valid = data.where((item) {
      String tglStr = item['Tanggal Update Harga'] ?? '01/01/2000';
      DateTime tgl = parseTanggal(tglStr);
      return tgl.isBefore(tanggalDipilih) ||
          tgl.isAtSameMomentAs(tanggalDipilih);
    }).toList();

    List<Map<String, String>> finalData = valid.isNotEmpty ? valid : data;

    finalData.sort((a, b) {
      DateTime a1 = parseTanggal(a['Tanggal Update Harga'] ?? '01/01/2000');
      DateTime b1 = parseTanggal(b['Tanggal Update Harga'] ?? '01/01/2000');
      return b1.compareTo(a1);
    });

    String hargaStr = finalData.first['Harga/Kg'] ?? '0';
    return int.tryParse(hargaStr.replaceAll('.', '')) ?? 0;
  }

  // ================= STOK =================
  void kurangiStok(int size, int qty) {
    for (var item in DataUdang.hargaUdang) {
      String itemSize = item['Size']?.trim() ?? '';
      if (itemSize == size.toString()) {
        int stok = int.tryParse(item['Stok/Kg'] ?? '0') ?? 0;
        int sisa = stok - qty;
        item['Stok/Kg'] = sisa > 0 ? sisa.toString() : '0';
        print("STOK BERHASIL DIKURANGI: $stok -> ${item['Stok/Kg']}");
        break;
      }
    }
  }

  // ================= TOTAL =================
  int get totalHarga {
    return (size1 == null) ? 0 : qty1 * getHarga(size1!, tanggal1);
  }

  int get totalKg => qty1;

  // ================= VALIDASI =================
  bool validasiForm() {
    String nama = namaController.text.trim();
    String alamat = alamatController.text.trim();
    String hp = hpController.text.trim();

    // VALIDASI NAMA
    if (nama.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nama tidak boleh kosong")),
      );
      return false;
    }

    if (nama.length < 3 || nama.length > 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nama harus 3 - 20 karakter")),
      );
      return false;
    }

    // VALIDASI ALAMAT
    if (alamat.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Alamat tidak boleh kosong")),
      );
      return false;
    }

    if (alamat.length < 5 || alamat.length > 30) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Alamat harus 5 - 30 huruf")),
      );
      return false;
    }

    // VALIDASI HP
    if (hp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No HP tidak boleh kosong")),
      );
      return false;
    }

    hp = hp.replaceAll(' ', '');

    if (!RegExp(r'^[0-9]+$').hasMatch(hp)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No HP harus berupa angka")),
      );
      return false;
    }

    if (hp.length < 10 || hp.length > 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No HP harus 10 - 12 digit")),
      );
      return false;
    }

    // VALIDASI PRODUK
    if (size1 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih size terlebih dahulu")),
      );
      return false;
    }

    if (qty1 == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Jumlah tidak boleh 0")),
      );
      return false;
    }

    return true;
  }

  // ================= PROSES PESANAN =================
  void prosesPesanan() {
    if (!validasiForm()) return;

    DateTime sekarang = DateTime.now();
    String tanggalCheckout = formatTanggal(sekarang);
    jamCheckout = formatJam(sekarang);

    // SIMPAN PESANAN
    DataUdang.pesananMasuk.add({
      "Nama": namaController.text,
      "Alamat": alamatController.text,
      "No HP": hpController.text,
      "TanggalPesan": tanggalCheckout,
      "Outbound": jamCheckout,
      "Tanggal": tanggal1 != null ? formatTanggal(tanggal1!) : "-",
      "Size": size1 != null ? "$size1" : "-",
      "Qty": "$totalKg Kg",
      "Metode": metodeBayar,
      "Total": "Rp ${NumberFormat('#,###').format(totalHarga)}",
    });

    // KURANGI STOK
    if (size1 != null && qty1 > 0) {
      kurangiStok(size1!, qty1);
    }

    // UPDATE HISTORY
    for (var item in DataUdang.hargaUdang) {
      DataUdang.history.add({
        'jenis': 'PESANAN',
        'Tanggal Update Harga': item['Tanggal Update Harga'] ?? '-',
        'Kode_Peti': item['Kode_Peti'] ?? '-',
        'Size': item['Size'] ?? '-',
        'Harga/Kg': item['Harga/Kg'] ?? '-',
        'Tanggal Restock': item['Tanggal Restock'] ?? '-',
        'Inbound': item['Inbound'] ?? '-',
        'Stok/Kg': item['Stok/Kg'] ?? '-',
        'Outbound': item['Outbound'] ?? '-',
        'Status': 'Stok Berkurang',
      });
    }

    setState(() {
      isProcessing = true;
    });
  }

  // ================= TANGGAL =================
  Future<void> pilihTanggal() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: tanggal1 ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    setState(() {
      tanggal1 = picked; // null jika batal, DateTime jika dipilih
    });
  }

  // ================= SIZE =================
  void pilihSize() {
    List<int> sizeList = [
      20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100
    ];

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return ListView(
          children: sizeList.map((size) {
            return ListTile(
              title: Text("Size $size"),
              onTap: () {
                setState(() {
                  size1 = size;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
    );
  }

  void resetSize() {
    setState(() {
      size1 = null;
      qty1 = 0;
      tanggal1 = null;
    });
  }

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE066),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFE066),
        title: const Text("Beli Sekarang"),
      ),
      body: isProcessing ? halamanNotifikasi() : halamanForm(),
    );
  }

  Widget halamanForm() {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          // ---- Form Input ----
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                inputField("Nama", namaController),
                inputField("Alamat", alamatController),
                inputField("No HP", hpController,
                    keyboard: TextInputType.phone),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ---- Produk (hanya 1) ----
          Expanded(
            child: ListView(
              children: [
                produkItem(),
              ],
            ),
          ),

          // ---- Total ----
          Text(
            "Total: Rp ${NumberFormat('#,###').format(totalHarga)}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          // ---- Metode Pembayaran ----
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 8, bottom: 5),
                child: Text(
                  "Metode Pembayaran",
                  style: TextStyle(fontSize: 12),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: metodeBayar,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down),
                    items: const [
                      DropdownMenuItem(value: "Cash", child: Text("Cash")),
                      DropdownMenuItem(
                          value: "Transfer", child: Text("Transfer")),
                    ],
                    onChanged: (value) {
                      setState(() {
                        metodeBayar = value!;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ---- Tombol Pesan ----
          ElevatedButton(
            onPressed: prosesPesanan,
            child: const Text("Pesan Sekarang"),
          ),
        ],
      ),
    );
  }

  Widget inputField(
    String label,
    TextEditingController controller, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black54),
          floatingLabelStyle: const TextStyle(color: Colors.black87),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black26),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
        ),
      ),
    );
  }

  // ================= WIDGET PRODUK (1 item saja) =================
  Widget produkItem() {
    int harga = (size1 == null) ? 0 : getHarga(size1!, tanggal1);

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.yellow[300],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/images/udang_windu.png',
            width: 70,
            height: 70,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---- Pilih Size ----
                Row(
                  children: [
                    Text("Size: ${size1 ?? '-'}"),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: pilihSize,
                      child: const Text("Pilih Size"),
                    ),
                    if (size1 != null)
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: resetSize,
                      ),
                  ],
                ),

                const SizedBox(height: 5),

                // ---- Pilih Tanggal ----
                InkWell(
                  onTap: pilihTanggal,
                  child: Text(
                    tanggal1 == null
                        ? "Pilih Tanggal"
                        : formatTanggal(tanggal1!),
                  ),
                ),

                const SizedBox(height: 5),

                // ---- Qty ----
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          if (qty1 > 0) qty1--;
                        });
                      },
                      icon: const Icon(Icons.remove),
                    ),
                    Text("$qty1 Kg"),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          qty1++;
                        });
                      },
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),

                // ---- Harga ----
                Text(
                  tanggal1 == null
                      ? "Harga: -"
                      : "Harga: Rp ${NumberFormat('#,###').format(harga)}",
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= HALAMAN NOTIFIKASI =================
  Widget halamanNotifikasi() {
    if (DataUdang.pesananMasuk.isEmpty) {
      return const Center(child: Text("Tidak ada data"));
    }

    final Map<String, String> data = DataUdang.pesananMasuk.last;

    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 60),
            const SizedBox(height: 10),
            const Text(
              "PESANAN BERHASIL",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 15),
            Text("Nama          : ${data["Nama"] ?? ''}"),
            Text("Alamat        : ${data["Alamat"] ?? ''}"),
            Text("No HP         : ${data["No HP"] ?? ''}"),
            Text("Tanggal Pesan : ${data["TanggalPesan"] ?? ''}"),
            Text("Outbound      : ${data["Outbound"] ?? ''}"),
            Text("Size          : ${data["Size"] ?? ''}"),
            Text("Jumlah        : ${data["Qty"] ?? ''}"),
            Text("Metode        : ${data["Metode"] ?? ''}"),
            Text("Total         : ${data["Total"] ?? ''}"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Kembali"),
            ),
          ],
        ),
      ),
    );
  }
}