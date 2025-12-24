## 📸 Preview Aplikasi

[![Download APK](https://img.shields.io/badge/Download-APK-blue?logo=android&style=for-the-badge)](https://github.com/GhaniPutra/Weather-Vista/releases/latest/download/WeatherVista.apk)

*Screenshots removed from README to keep file lightweight. Lihat folder `assets/images/` untuk melihat gambar preview secara lokal.*


# 🌦️ WeatherVista — Aplikasi Cuaca (Flutter)

WeatherVista adalah aplikasi cuaca ringan dan modern yang dibangun dengan **Flutter**. Aplikasi ini menampilkan informasi cuaca real-time berdasarkan lokasi GPS atau nama kota, meliputi cuaca saat ini, ringkasan per jam, dan prakiraan 7 hari. Aplikasi juga menyediakan notifikasi in-app & sistem, serta kemampuan menyimpan lokasi favorit.

---

## ✨ Fitur Utama
- Penentuan lokasi otomatis via **GPS** atau input manual (kota / koordinat)
- Cuaca saat ini: suhu, kondisi, feels-like, kelembapan, tekanan, kecepatan angin, UV index
- Ringkasan per jam (hourly) dan prakiraan 7 hari
- Notifikasi in-app (banner) dan notifikasi sistem
- Simpan lokasi **Favorit** (persisten menggunakan `SharedPreferences`)
- Light & Dark mode dengan preferensi yang tersimpan

---

## 🛠️ Teknologi
- Flutter & Dart
- Geolocator (GPS)
- SharedPreferences (persistensi)
- flutter_local_notifications (notifikasi sistem)
- overlay_support (in-app banner)
- Provider (state management)

---

## ▶️ Download Aplikasi

- **Link langsung (one-click):** [Download APK (Latest release)](https://github.com/GhaniPutra/Weather-Vista/releases/latest/download/WeatherVista.apk)

> Pastikan file APK di-attach pada release dengan nama `WeatherVista.apk` agar tautan di atas berfungsi.

**Cara cepat membuat Release dan menambahkan APK:**
1. Buka repo → klik **Releases** → **Draft a new release**
2. Isi tag (mis. `v1.0.0`), judul, dan deskripsi
3. Seret file APK ke area **Attach binaries by dropping them here** (beri nama `WeatherVista.apk`)
4. Klik **Publish release**

---

## ▶️ Menjalankan (opsional untuk developer)
Jika tim Anda ingin menjalankan atau membangun aplikasi dari sumber:

### Install dependency
```bash
flutter pub get
```

### Menjalankan aplikasi
```bash
flutter run
```

### Build APK release
```bash
flutter build apk --release
```

Hasil build akan berada di `build/app/outputs/flutter-apk/` (mis. `app-release.apk`).
