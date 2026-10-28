# Prompt AI Review — Senior Flutter Developer

Dokumentasi prompt yang digunakan untuk memicu audit kode (*code review*) otomatis dari sudut pandang *Senior Flutter Developer*.

---

## 1. Metadata Eksekusi

* **Model:** Gemini 3.8 Flash (High) / Antigravity AI
* **Role Persona:** Senior Flutter Developer
* **Target Repositori:** `244107020202-mobile-course`
* **Target Branch:** `feat/notes-validation` vs `main`
* **Project:** `week5_offline_notes` (Mid-Project Review Minggu 8)

---

## 2. Salinan Prompt Asli

```text
Review PR Flutter ini sebagai senior Flutter dev.
Konteks: Aplikasi catatan offline (`week5_offline_notes`) dengan struktur folder per jenis/layer (`lib/pages`, `lib/utils`, `lib/models`, `lib/providers`, `lib/services`), menggunakan Riverpod dan SQLite.
Periksa perubahan kode pada branch `feat/notes-validation` terhadap branch utama (`main`).
Fokus: kebenaran logika (terutama validasi input & duplikasi), batas arsitektur/layering, dan kelengkapan test. Abaikan style/formatting.
Berikan 5 temuan teratas + level (blocker/saran) + alasan teknis + usulan potongan kode perbaikan.
```

