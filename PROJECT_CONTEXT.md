# TravelEase - Mobile Travel App (Flutter + Firebase)

## 🚀 Project Overview
TravelEase adalah aplikasi mobile berbasis Flutter yang menyediakan informasi wisata di Indonesia.
Aplikasi ini ditujukan untuk tugas kuliah dengan fokus pada UI modern, pengalaman pengguna yang baik, dan integrasi Firebase Firestore sebagai backend utama.

Tujuan utama aplikasi:
- Menampilkan daftar destinasi wisata Indonesia
- Memberikan detail informasi wisata
- Memungkinkan pengguna menyimpan destinasi favorit
- Menggunakan Firebase Firestore sebagai database cloud

---

## 🎯 MVP (Minimum Viable Product)

Aplikasi ini hanya fokus pada fitur inti berikut:

### 1. Home Screen
- Menampilkan daftar destinasi wisata populer
- UI berbentuk card modern (image + nama + lokasi + rating)
- Search bar di bagian atas

### 2. Search Feature
- Pencarian destinasi berdasarkan nama
- Filter sederhana (opsional: kategori wisata)

### 3. Destination Detail Screen
- Gambar destinasi
- Nama tempat
- Lokasi
- Deskripsi
- Rating
- Tombol "Add to Favorite"

### 4. Favorite Screen
- Menampilkan destinasi yang disimpan user
- Data tersimpan di Firebase Firestore

### 5. Simple Navigation
- Bottom Navigation Bar:
  - Home
  - Search
  - Favorites

---

## 🔥 Firebase Integration

Gunakan Firebase sebagai backend utama:

### Firestore Collections:

#### Collection: `destinations`
Fields:
- id (string)
- name (string)
- location (string)
- description (string)
- imageUrl (string)
- rating (double)
- category (string)

#### Collection: `favorites`
Fields:
- userId (string)
- destinationId (string)
- createdAt (timestamp, optional)

#### Collection: `users`
Fields:
- uid (string)
- name (string)
- email (string)
- role (string: `admin` | `user`)

---

## 🧠 Tech Stack

- Flutter (latest stable)
- Dart
- Firebase Firestore
- Firebase Core
- Material 3 Design

---

## 🎨 UI/UX Direction

- Clean & modern design
- Inspired by Traveloka / Airbnb style UI
- Card-based layout
- Soft colors (white, green, blue tone)
- Mobile-first responsive design
- Smooth navigation

---

## 🧱 Architecture (Simple Clean Structure)

Gunakan struktur folder berikut:

lib/
  models/
  screens/
    home/
    search/
    detail/
    favorite/
  widgets/
  services/
    firebase_service.dart
  main.dart

---

## ⚙️ Development Rules for AI (IMPORTANT)

When generating code:
1. Prioritize simplicity over over-engineering
2. Use Firebase Firestore for real data operations
3. Avoid unnecessary backend (no Node.js needed)
4. Use dummy data only if Firebase is not yet connected
5. Ensure every screen is UI-complete before adding features
6. Use Material 3 consistently
7. Keep code modular and reusable

---

## 📌 Development Goal

At the end of this project:
- App must be runnable on Android
- Must have working navigation
- Must display Firestore data (or fallback dummy data)
- Must look presentable for college presentation
- must using english language