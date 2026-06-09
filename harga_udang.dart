import 'package:flutter/material.dart';
import 'data_udang.dart';

class HargaUdangPage extends StatefulWidget {
  const HargaUdangPage({super.key});

  @override
  State<HargaUdangPage> createState() => _HargaUdangPageState();
}

class _HargaUdangPageState extends State<HargaUdangPage> {

  @override
  void initState() {
    super.initState();
    hasilFilter = DataUdang.hargaUdang;
  }

  String? selectedBulan;
  String? selectedSize;
  String? selectedHargaRange;

  List<Map<String, String>> hasilFilter = [];
  String mode = "";

  bool hanyaReady = false;
  bool sudahCekReady = false; 
  bool sudahKlikTampilkan = false;

  final List<String> bulanList = [
    "Januari","Februari","Maret","April","Mei","Juni",
    "Juli","Agustus","September","Oktober","November","Desember"
  ];

  final List<String> sizeList = [
    "20","25","30","35","40","45","50","55","60","65",
    "70","75","80","85","90","95","100"
  ];

  final List<String> hargaRangeList = [
    "50Rp-100Rp","100Rp-150Rp","150Rp-200Rp","200Rp-250Rp"
  ];

  String getBulanNumber(String bulan) {
    Map<String, String> map = {
      "Januari": "01","Februari": "02","Maret": "03",
      "April": "04","Mei": "05","Juni": "06",
      "Juli": "07","Agustus": "08","September": "09",
      "Oktober": "10","November": "11","Desember": "12",
    };
    return map[bulan]!;
  }

  // ================= FILTER =================
  void tampilInformasi() {
    setState(() {

      sudahKlikTampilkan = true; 

      sudahCekReady = false;

      if (selectedBulan != null) {
        List<String> bulanValid = ["Januari", "Februari", "Maret", "April"];

        if (!bulanValid.contains(selectedBulan)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Informasi belum di update"),
              backgroundColor: Colors.red,
            ),
          );

          hasilFilter = [];
          mode = "filter";
          return;
        }
      }

      mode = "filter";

      hasilFilter = DataUdang.hargaUdang.where((item) {

        String tanggal = item['Tanggal Update Harga'] ?? "";

        String bulanData = "";
        if (tanggal.contains("/")) {
          List<String> parts = tanggal.split('/');
          if (parts.length > 1) {
            bulanData = parts[1];
          }
        }

        String sizeData = item['Size'] ?? item['size'] ?? "";
        String hargaString = item['Harga/Kg'] ?? item['harga/kg'] ?? "0";

        int harga = int.tryParse(
          hargaString.replaceAll('.', '').trim()
        ) ?? 0;

        String status = item['Status'] ?? "";

        bool bulanMatch = true;
        if (selectedBulan != null) {
          bulanMatch = bulanData == getBulanNumber(selectedBulan!);
        }

        bool sizeMatch = true;
        if (selectedSize != null) {
          sizeMatch = sizeData == selectedSize;
        }

        bool hargaMatch = true;
        if (selectedHargaRange != null) {
          var range = selectedHargaRange!.split('-');

          int min = int.parse(range[0]) * 1000;
          int max = int.parse(range[1]) * 1000;

          hargaMatch = harga >= min && harga <= max;
        }

        bool statusMatch = true;
        if (hanyaReady) {
          statusMatch = status.trim().toLowerCase() == "ready";
        }

        return bulanMatch && sizeMatch && hargaMatch && statusMatch;

      }).toList();

      hasilFilter.sort((a, b) {
        int sA = int.tryParse(a['Size'] ?? "") ?? 0;
        int sB = int.tryParse(b['Size'] ?? "") ?? 0;

        if (sA != sB) return sA.compareTo(sB);

        return (a['Tanggal Update Harga'] ?? "")
            .compareTo(b['Tanggal Update Harga'] ?? "");
      });
    });
  }

  void tampilStok() {
    setState(() {
      sudahKlikTampilkan = true; 
      sudahCekReady = false;
      mode = "stok";
      hasilFilter = DataUdang.dataPeti;
    });
  }

  void tampilSemua() {
    setState(() {
      sudahKlikTampilkan = true; 
      sudahCekReady = false;
      mode = "semua";
      selectedBulan = null;
      selectedSize = null;
      selectedHargaRange = null;
      hanyaReady = false;
      hasilFilter = DataUdang.hargaUdang;
    });
  }

  // ================= DROPDOWN =================
  Widget dropdown(String hint, String? value, List<String> items,
      Function(String?) onChanged, VoidCallback onClear) {

    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: value,
              hint: Text(hint,
                  style: const TextStyle(
                      fontFamily: 'Poppins', fontSize: 12)),
              decoration: const InputDecoration(border: InputBorder.none),
              items: items.map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text(e,
                      style: const TextStyle(
                          fontFamily: 'Poppins', fontSize: 12)),
                );
              }).toList(),
              onChanged: (v) => onChanged(v?.trim()),
            ),
          ),
          if (value != null)
            GestureDetector(
              onTap: onClear,
              child: const Icon(Icons.close, color: Colors.red, size: 18),
            ),
        ],
      ),
    );
  }

  DataColumn col(String text) {
    return DataColumn(
      label: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
          fontSize: 12,
        ),
      ),
    );
  }

  // ================= TABLE =================
  Widget buildTable() {
    return DataTable(
      columnSpacing: 10,
      dataRowMinHeight: 30,
      dataRowMaxHeight: 40,
      headingRowColor: MaterialStateProperty.all(const Color(0xFF02203A)),

      columns: mode == "stok"
          ? [
              col("No"), col("Tanggal"), col("Size"),
              col("Kode"), col("In"),
              col("Stok"), col("Out"), col("Status"),
            ]
          : mode == "filter"
              ? [
                  col("No"), col("Tanggal"), col("Size"),
                  col("Harga"), col("Status"),
                ]
              : [
                  col("No"), col("Tanggal"), col("Size"),
                  col("Harga"), col("Restock"),
                  col("Kode"), col("In"),
                  col("Stok"), col("Out"), col("Status"),
                ],

      rows: hasilFilter.asMap().entries.map((e) {
        int i = e.key + 1;
        var item = e.value;

        TextStyle dataStyle = const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 12,
        );

        List<DataCell> cells = [];

        if (mode == "stok") {
          cells = [
            "$i",
            item['Tanggal Restock'],
            item['Size'],
            item['Kode_Peti'],
            item['Inbound'],
            item['Stok/Kg'],
            item['Outbound'],
            item['Status'],
          ].map((e) => DataCell(Text(e ?? "-", style: dataStyle))).toList();
        } else if (mode == "filter") {
          cells = [
            "$i",
            item['Tanggal Update Harga'],
            item['Size'],
            item['Harga/Kg'],
            item['Status'],
          ].map((e) => DataCell(Text(e ?? "-", style: dataStyle))).toList();
        } else {
          cells = [
            "$i",
            item['Tanggal Update Harga'],
            item['Size'],
            item['Harga/Kg'],
            item['Tanggal Restock'],
            item['Kode_Peti'],
            item['Inbound'],
            item['Stok/Kg'],
            item['Outbound'],
            item['Status'],
          ].map((e) => DataCell(Text(e ?? "-", style: dataStyle))).toList();
        }

        return DataRow(cells: cells);
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE066),

      appBar: AppBar(
        title: const Text("Informasi Harga Udang"),
        backgroundColor: const Color(0xFFFFE066),
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [

            dropdown(
              "Bulan",
              selectedBulan,
              bulanList,
              (v) => setState(() => selectedBulan = v),
              () => setState(() => selectedBulan = null),
            ),

            const SizedBox(height: 6),

            Row(
              children: [
                Expanded(
                  child: dropdown(
                    "Size Udang",
                    selectedSize,
                    sizeList,
                    (v) => setState(() => selectedSize = v),
                    () => setState(() => selectedSize = null),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: dropdown(
                    "Harga Udang",
                    selectedHargaRange,
                    hargaRangeList,
                    (v) => setState(() => selectedHargaRange = v),
                    () => setState(() => selectedHargaRange = null),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: tampilStok,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text("Stok Udang"),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: ElevatedButton(
                    onPressed: tampilInformasi,
                    child: const Text("Tampilkan"),
                  ),
                ),
              ],
            ),

    Align(
  alignment: Alignment.centerLeft,
  child: Row(
    children: [
      Transform.scale(
        scale: 0.8,
        child: Checkbox(
          value: hanyaReady,
          onChanged: (value) {
  setState(() {
    hanyaReady = value!;
    sudahCekReady = true;

    if (hanyaReady == false) {
      hasilFilter = [];
    }
  });

  if (value == true) {
    bool adaReady = DataUdang.hargaUdang.any(
      (item) => item['Status']?.trim().toLowerCase() == "ready"
    );

    if (!adaReady) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Belum ada data READY"),
          backgroundColor: Colors.orange,
        ),
      );
    } else {
      tampilInformasi();
    }
  }
},
        ),
      ),
      const Text(
        "Ready",
        style: TextStyle(fontSize: 12),
      ),
    ],
  ),
),

            const SizedBox(height: 6),

            ElevatedButton(
              onPressed: tampilSemua,
              child: const Text("Semua Data"),
            ),

            const SizedBox(height: 10),

    Expanded(
  child: !sudahKlikTampilkan 
      ? const Center(
          child: Text("Tidak ada data"),
        )
      : hasilFilter.isEmpty
          ? const Center(
              child: Text("Tidak ada data"),
            )
                  : Scrollbar(
                      thumbVisibility: true,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: SingleChildScrollView(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: buildTable(),
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}