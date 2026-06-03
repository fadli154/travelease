# TravelEase - Project Context

## Project Overview

TravelEase adalah aplikasi mobile informasi wisata Indonesia yang dibangun menggunakan Flutter dan Firebase.

Aplikasi ini bertujuan membantu pengguna menemukan destinasi wisata, melihat informasi lengkap wisata, menyimpan destinasi favorit, memberikan ulasan, dan mendapatkan pengalaman eksplorasi wisata yang modern.

Aplikasi memiliki dua role:

* User
* Admin

Project ini merupakan tugas kuliah sehingga fokus utama adalah:

* UI modern dan profesional
* Fitur yang berjalan dengan baik
* Firebase sebagai backend utama
* Mudah dipresentasikan

---

# Technology Stack

Frontend:

* Flutter
* Dart
* Material 3

Backend:

* Firebase Authentication
* Google Sign In
* Cloud Firestore
* Firebase Storage

State Management:

* Provider

Maps:

* Google Maps Flutter

---

# User Roles

## User

User dapat:

* Register

* Login menggunakan Email dan Password

* Login menggunakan Google

* Logout

* Melihat daftar destinasi wisata

* Mencari destinasi wisata

* Melihat detail destinasi

* Menyimpan destinasi favorit

* Menghapus destinasi favorit

* Memberikan rating

* Memberikan ulasan

* Mengunggah foto ulasan

* Mengedit ulasan sendiri

* Menghapus ulasan sendiri

* Melihat lokasi wisata pada Google Maps

* Mengubah profil

* Mengubah foto profil

---

## Admin

Admin dapat:

* Login

* Logout

* Melihat seluruh data destinasi

* Menambah destinasi wisata

* Mengedit destinasi wisata

* Menghapus destinasi wisata

* Mengelola lokasi wisata

* Mengubah koordinat latitude dan longitude

* Menghapus ulasan pengguna

* Mengakses dashboard admin

* Mengakses halaman profil admin

---

# Firestore Database Structure

## Collection: users

Document ID = Firebase Auth UID

Fields:

* uid
* name
* email
* photoUrl
* role
* createdAt

Role values:

* admin
* user

---

## Collection: destinations

Fields:

* id
* name
* description
* imageUrl
* locationName
* latitude
* longitude
* category
* ticketPrice
* averageRating
* totalReviews
* createdAt

---

## Collection: favorites

Fields:

* userId
* destinationId
* createdAt

---

## Collection: reviews

Fields:

* id
* destinationId
* userId
* userName
* userPhoto
* rating
* comment
* imageUrl
* createdAt
* updatedAt

---

# Rating System

Destination rating must be calculated automatically.

Rules:

When review added:

* Recalculate average rating

When review edited:

* Recalculate average rating

When review deleted:

* Recalculate average rating

Store results in:

destinations.averageRating

destinations.totalReviews

---

# Authentication

Supported methods:

1. Email and Password
2. Google Sign In

When a new account is created:

Automatically create Firestore document:

users/{uid}

Default role:

user

Admin role is assigned manually through Firestore.

---

# Application Screens

## Public

* Splash Screen
* Onboarding Screen

## Authentication

* Login Screen
* Register Screen

## User Area

* Home Screen
* Search Screen
* Destination Detail Screen
* Favorites Screen
* Profile Screen
* Edit Profile Screen

## Admin Area

* Admin Dashboard
* Destination Management Screen
* Add Destination Screen
* Edit Destination Screen
* Admin Profile Screen

---

# Onboarding Experience

Create a premium onboarding experience.

Page 1:
Discover Amazing Destinations

Page 2:
Plan Your Perfect Journey

Page 3:
Save Favorites and Share Reviews

Features:

* Smooth animations
* Skip button
* Next button
* Get Started button

Show only on first launch.

---

# UI / UX Guidelines

Design inspiration:

* Traveloka
* Airbnb

Requirements:

* Modern
* Clean
* Professional
* Mobile-first

Use:

* Card-based layouts
* Rounded corners
* Material 3
* Dark Mode
* Light Mode

Dark mode must work for:

* User area
* Admin area

---

# Profile Features

Users and Admins can:

* View profile
* Update profile photo
* Update display name

Profile photos must be stored in Firebase Storage.

Store URL in:

users.photoUrl

---

# Maps Integration

Admin manages:

* Latitude
* Longitude

User can:

* View destination location
* Open destination in Google Maps

---

# Important Development Rules

1. Analyze the current codebase before making changes.
2. Do not rewrite the entire project.
3. Extend existing architecture.
4. Fix bugs before adding new features.
5. Keep Provider architecture.
6. Keep Firebase integration.
7. Maintain clean and reusable code.
8. Ensure application is production-ready.
9. Prevent rendering errors and layout exceptions.
10. Ensure smooth navigation and loading states.

---

# Current Known Issues

1. Favorite removal sometimes causes rendering issues.
2. SliverAppBar layout assertion errors must be fixed.
3. Profile photo feature is not implemented.
4. Admin profile page is missing.
5. Admin dark mode is missing.

These issues should be prioritized before implementing new features.
