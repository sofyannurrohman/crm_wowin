# Wowin CRM - Sales & Management Workflow Documentation

Dokumen ini menjelaskan alur kerja (workflow) lengkap dalam ekosistem Wowin CRM, mulai dari sisi lapangan (Mobile App) hingga pemantauan manajerial (Web Dashboard).

---

## 📱 Alur Kerja Sales (Flutter Mobile)

Aplikasi mobile dirancang untuk mendukung produktivitas sales di lapangan secara *end-to-end*.

### 1. Product Knowledge & Catalog
*   **Menu Products:** Sales dapat melihat daftar lengkap katalog produk beserta harga terbaru.
*   **Detail Produk:** Informasi deskripsi, harga unit, dan SKU produk untuk mempermudah presentasi ke pelanggan.
*   **Pencarian Cepat:** Fitur search di katalog untuk menemukan produk dalam hitungan detik.

### 2. Lead Management & Visit Wizard
*   **Tambah Lead:** Saat menemukan potensi bisnis baru, sales menambahkan data ke menu **"Leads"**.
*   **Multi-Step Visit Wizard:** Sales melakukan kunjungan melalui alur terpandu 4-langkah:
    1.  **Selection:** Memilih pelanggan/lead (otomatis terisi jika dari halaman Detail Deal).
    2.  **Verification (Geofencing):** Verifikasi jarak real-time. Check-in hanya dapat dilakukan dalam radius 200 meter.
    3.  **Live Snapshot:** Mengambil foto lokasi secara langsung melalui viewport kamera terintegrasi.
    4.  **Summary & Sync:** Penambahan catatan dan sinkronisasi otomatis ke server.

### 3. Konversi ke Deal & Penawaran Produk
*   **Konversi Lead:** Jika prospek berminat, sales mengubah status **Lead** menjadi **Customer**.
*   **Manajemen Deal:** Sales membuat **Deal** (peluang penjualan) baru.
*   **Product Offering:** Di dalam halaman Detail Deal, sales dapat:
    1.  Menambah produk dari katalog ke dalam penawaran.
    2.  Menentukan jumlah (quantity) dan harga (secara otomatis mengambil harga katalog).
    3.  Melihat otomatis kalkulasi total nilai deal berdasarkan item yang ditambahkan.

### 4. Closing & Realisasi Omzet
*   **Pipeline Tracking:** Sales mengelola tahapan deal (Discovery -> Proposal -> Negotiation -> Won).
*   **Closing Won:** Saat deal ditandai sebagai **"Won"**, nominal transaksi akan secara otomatis dihitung sebagai **Omzet (Revenue)** sales tersebut.
*   **Target KPI:** Progres pencapaian target target vs realisasi omzet dapat dilihat langsung di Dashboard Mobile.

---

## 💻 Manajemen & Monitoring (Vue Web)

Dashboard Web digunakan oleh Manajer atau Owner untuk memantau performa seluruh tim secara *real-time*.

### 1. Executive Dashboard (Analytics)
*   **Total Pelanggan Aktif:** Menampilkan pertumbuhan jumlah database pelanggan secara keseluruhan.
*   **Total Pipeline (Deals Value):** Total akumulasi rupiah dari seluruh peluang penjualan yang sedang berjalan.
*   **Win Rate:** Persentase kesuksesan tim dalam memenangkan deal dibandingkan total deal yang dibuat.
*   **Kunjungan Hari Ini:** Grafik progres kunjungan sales hari ini terhadap target harian perusahaan.

### 2. Monitoring Performa & Validitas
*   **Top Sales Performer:** Daftar peringkat sales berdasarkan revenue (omzet) tertinggi dan jumlah kunjungan yang valid.
*   **Tren Pendapatan:** Grafik bulanan proyeksi revenue dari deal yang 'Closed Won'.
*   **Validasi Bukti Lapangan:** Manajer dapat melihat detail koordinat GPS, foto selfie, dan foto tempat setiap kunjungan untuk memastikan akurasi data.

---

## 🚀 Keunggulan Sistem integration
*   **Automated Calculation:** Total nilai deal dihitung otomatis berdasarkan item produk, meminimalkan kesalahan input manual.
*   **Storage Efficiency:** Foto bukti kunjungan dikompresi di backend untuk efisiensi penyimpanan VPS tanpa mengurangi kejelasan visual.
*   **Real-time Synchronization:** Data dari aplikasi lapangan langsung tersinkronisasi ke dashboard manajerial dalam hitungan detik.
*   **Premium & State-of-the-art UI:** Antarmuka modern menggunakan **Flutter & Vue with Shadcn UI** untuk pengalaman pengguna yang premium.
