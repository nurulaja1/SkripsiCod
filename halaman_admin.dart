import 'package:flutter/material.dart';
import 'data_udang.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  static const Color blueDark = Color.fromARGB(255, 2, 32, 58);

  String selectedField = '';
  bool showHistory = true;

  // ================= TOTAL STOK =================
  int get totalStok {
    int total = 0;
    for (var item in DataUdang.hargaUdang) {
      total += int.tryParse(item['Stok/Kg'] ?? '0') ?? 0;
    }
    return total;
  }

  // ================= TAMBAH DATA =================
  void tambahData() {
    setState(() {
      int next = DataUdang.hargaUdang.length + 1;

      DataUdang.hargaUdang.add({
        'No': next.toString(),
        'Tanggal Update Harga': '',
        'Kode_Peti': '',
        'Size': '',
        'Harga/Kg': '',
        'Tanggal Restock': '',
        'Inbound': '',
        'Stok/Kg': '',
        'Outbound': '',
        'Status': '',
      });
    });
  }

  // ================= HAPUS DATA =================
  void hapusData() {
    setState(() {
      if (DataUdang.hargaUdang.isNotEmpty) {
        DataUdang.hargaUdang.removeLast();
      }
    });
  }

  // ================= UPDATE DATA =================
  void updateData() {
    setState(() {
      showHistory = true;
      DataUdang.history.clear();

      for (var item in DataUdang.hargaUdang) {
        DataUdang.history.add({
          'jenis': 'UPDATE',
          'Tanggal Update Harga': item['Tanggal Update Harga'] ?? '-',
          'Kode_Peti': item['Kode_Peti'] ?? '-',
          'Size': item['Size'] ?? '-',
          'Harga/Kg': item['Harga/Kg'] ?? '-',
          'Tanggal Restock': item['Tanggal Restock'] ?? '-',
          'Inbound': item['Inbound'] ?? '-',
          'Stok/Kg': item['Stok/Kg'] ?? '-',
          'Outbound': item['Outbound'] ?? '-',
          'Status': item['Status'] ?? '-',
        });
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Data berhasil diupdate"),
      ),
    );
  }

  // ================= UPDATE STATUS PESANAN =================
  void updateStatusPesanan(int index, String newStatus) {
    setState(() {
      DataUdang.pesananMasuk[index]['StatusPesanan'] = newStatus;
    });
  }

  // ================= TEXT KECIL =================
  Text smallText(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 11),
    );
  }

  // ================= BUTTON FIELD =================
  Widget buildButton(String title, String fieldName) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedField = fieldName;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: blueDark,
        foregroundColor: Colors.white,
      ),
      child: Text(title),
    );
  }

  // ================= FORM INPUT =================
  Widget buildFilteredData() {
    if (selectedField.isEmpty) {
      return const Text(
        "Klik tombol untuk melihat / mengedit data",
        style: TextStyle(fontSize: 12),
      );
    }

    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            onPressed: () {
              setState(() {
                selectedField = '';
              });
            },
            icon: const Icon(Icons.close),
            color: Colors.red,
          ),
        ),
        Column(
          children: DataUdang.hargaUdang.map((item) {
            return Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: blueDark,
                      child: Text(
                        item['No'] ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        initialValue: item[selectedField] ?? '',
                        onChanged: (value) {
                          setState(() {
                            item[selectedField] = value;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: selectedField,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ================= TABLE HISTORY =================
  Widget buildHistoryTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        border: TableBorder.all(color: blueDark),
        headingRowColor: MaterialStateProperty.all(blueDark),
        dataRowColor: MaterialStateProperty.all(Colors.white),
        headingTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
        columns: const [
          DataColumn(label: Text("Jenis")),
          DataColumn(label: Text("Tgl Update")),
          DataColumn(label: Text("Kode Peti")),
          DataColumn(label: Text("Size")),
          DataColumn(label: Text("Harga/Kg")),
          DataColumn(label: Text("Tgl Restock")),
          DataColumn(label: Text("Inbound")),
          DataColumn(label: Text("Stok/Kg")),
          DataColumn(label: Text("Outbound")),
          DataColumn(label: Text("Status")),
        ],
        rows: DataUdang.history.isEmpty
            ? []
            : DataUdang.history.map((item) {
                return DataRow(
                  cells: [
                    DataCell(smallText(item['jenis'] ?? '-')),
                    DataCell(smallText(item['Tanggal Update Harga'] ?? '-')),
                    DataCell(smallText(item['Kode_Peti'] ?? '-')),
                    DataCell(smallText(item['Size'] ?? '-')),
                    DataCell(smallText(item['Harga/Kg'] ?? '-')),
                    DataCell(smallText(item['Tanggal Restock'] ?? '-')),
                    DataCell(smallText(item['Inbound'] ?? '-')),
                    DataCell(smallText(item['Stok/Kg'] ?? '-')),
                    DataCell(smallText(item['Outbound'] ?? '-')),
                    DataCell(smallText(item['Status'] ?? '-')),
                  ],
                );
              }).toList(),
      ),
    );
  }

  // ================= TABLE PESANAN =================
  Widget buildPesananTable() {
    // Daftar pilihan status pesanan
    const List<String> statusOptions = [
      'Menunggu Konfirmasi',
      'Dikonfirmasi',
      'Diproses',
      'Dikirim',
      'Selesai',
      'Dibatalkan',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        border: TableBorder.all(color: blueDark),
        headingRowColor: MaterialStateProperty.all(blueDark),
        dataRowColor: MaterialStateProperty.all(Colors.white),
        headingTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
        columns: const [
          DataColumn(label: Text("Nama")),
          DataColumn(label: Text("Alamat")),
          DataColumn(label: Text("No HP")),
          DataColumn(label: Text("Tgl Pesan")),
          DataColumn(label: Text("Outbound")),
          DataColumn(label: Text("Size")),
          DataColumn(label: Text("Jumlah")),
          DataColumn(label: Text("Metode")),
          DataColumn(label: Text("Total")),
          DataColumn(label: Text("Bukti Pembayaran")),
          DataColumn(label: Text("Status Pesanan")),
        ],
        rows: DataUdang.pesananMasuk.isEmpty
            ? []
            : DataUdang.pesananMasuk.asMap().entries.map((entry) {
                int index = entry.key;
                Map<String, String> item = entry.value;

                // Nilai status saat ini, default 'Menunggu Konfirmasi'
                String currentStatus =
                    item['StatusPesanan'] ?? 'Menunggu Konfirmasi';

                // Warna badge status
                Color statusColor = _getStatusColor(currentStatus);

                return DataRow(
                  cells: [
                    DataCell(smallText(item['Nama'] ?? '-')),
                    DataCell(smallText(item['Alamat'] ?? '-')),
                    DataCell(smallText(item['No HP'] ?? '-')),
                    DataCell(smallText(item['TanggalPesan'] ?? '-')),
                    DataCell(smallText(item['Outbound'] ?? '-')),
                    DataCell(smallText(item['Size'] ?? '-')),
                    DataCell(smallText(item['Qty'] ?? '-')),
                    DataCell(smallText(item['Metode'] ?? '-')),
                    DataCell(smallText(item['Total'] ?? '-')),

                    // ===== KOLOM BUKTI PEMBAYARAN =====
                    DataCell(
                      item['BuktiPembayaran'] != null &&
                              item['BuktiPembayaran']!.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                _showBuktiDialog(
                                    item['BuktiPembayaran']!);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green[100],
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                      color: Colors.green),
                                ),
                                child: const Text(
                                  "Lihat",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.grey),
                              ),
                              child: const Text(
                                "Belum Ada",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                    ),

                    // ===== KOLOM STATUS PESANAN =====
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: statusColor),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: statusOptions.contains(currentStatus)
                                ? currentStatus
                                : statusOptions.first,
                            isDense: true,
                            icon: Icon(Icons.arrow_drop_down,
                                color: statusColor, size: 16),
                            style: TextStyle(
                              fontSize: 11,
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                            dropdownColor: Colors.white,
                            items: statusOptions.map((status) {
                              return DropdownMenuItem<String>(
                                value: status,
                                child: Text(
                                  status,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: _getStatusColor(status),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (newStatus) {
                              if (newStatus != null) {
                                updateStatusPesanan(index, newStatus);
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
      ),
    );
  }

  // ================= WARNA STATUS =================
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Menunggu Konfirmasi':
        return Colors.orange;
      case 'Dikonfirmasi':
        return Colors.blue;
      case 'Diproses':
        return Colors.purple;
      case 'Dikirim':
        return Colors.teal;
      case 'Selesai':
        return Colors.green;
      case 'Dibatalkan':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // ================= DIALOG BUKTI PEMBAYARAN =================
  void _showBuktiDialog(String bukti) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Bukti Pembayaran"),
        content: Text(bukti),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE066),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFE066),
        title: const Text("Halaman Admin"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            const Text(
              "DATA HARGA UDANG",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 10),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                buildButton("Tanggal Update", "Tanggal Update Harga"),
                buildButton("Kode Peti", "Kode_Peti"),
                buildButton("Size", "Size"),
                buildButton("Harga/Kg", "Harga/Kg"),
                buildButton("Tanggal Restock", "Tanggal Restock"),
                buildButton("Inbound", "Inbound"),
                buildButton("Stok/Kg", "Stok/Kg"),
                buildButton("Outbound", "Outbound"),
                buildButton("Status", "Status"),
              ],
            ),

            const SizedBox(height: 15),

            buildFilteredData(),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: hapusData,
                  icon: const Icon(Icons.remove),
                  color: Colors.red,
                ),
                ElevatedButton(
                  onPressed: updateData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: blueDark,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Update"),
                ),
                IconButton(
                  onPressed: tambahData,
                  icon: const Icon(Icons.add),
                  color: Colors.green,
                ),
              ],
            ),

            const SizedBox(height: 20),

            const Text(
              "HISTORY",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            if (showHistory)
              Stack(
                children: [
                  buildHistoryTable(),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          showHistory = false;
                        });
                      },
                      icon: const Icon(Icons.close),
                      color: Colors.red,
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 20),

            const Text(
              "DATA PESANAN MASUK",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            buildPesananTable(),

            const SizedBox(height: 20),

            Text(
              "Total Semua Stok: $totalStok Kg",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}