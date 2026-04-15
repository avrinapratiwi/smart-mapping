<?php
/**
 * ============================================================
 * KONFIGURASI KONEKSI DATABASE
 * Smart Mapping BPS - Sensus Ekonomi 2026
 * ============================================================
 * 
 * File ini bertanggung jawab untuk membuat koneksi ke database
 * MySQL menggunakan PDO (PHP Data Objects).
 * 
 * PDO dipilih karena:
 * - Mendukung prepared statements (aman dari SQL Injection)
 * - Mendukung berbagai jenis database
 * - Penanganan error yang lebih baik
 */

// --- Variabel Konfigurasi Database ---
$host     = "localhost";       // Alamat server database
$db_name  = "smart_mapping_bps"; // Nama database
$username = "root";            // Username database (default Laragon)
$password = "";                // Password database (kosong untuk default lokal)

// --- Variabel untuk menyimpan objek koneksi ---
$koneksi = null;

try {
    /**
     * Membuat koneksi PDO baru ke MySQL.
     * 
     * Parameter DSN (Data Source Name):
     * - mysql:host  = alamat server
     * - dbname      = nama database yang digunakan
     * - charset=utf8mb4 = mendukung karakter unicode penuh (termasuk emoji)
     */
    $koneksi = new PDO(
        "mysql:host={$host};dbname={$db_name};charset=utf8mb4",
        $username,
        $password
    );

    /**
     * Mengatur atribut PDO:
     * 
     * ERRMODE_EXCEPTION  = Melempar exception saat terjadi error SQL,
     *                      sehingga bisa ditangkap oleh blok catch.
     * 
     * FETCH_ASSOC        = Hasil query dikembalikan sebagai array asosiatif
     *                      (menggunakan nama kolom sebagai key).
     */
    $koneksi->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $koneksi->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);

} catch (PDOException $e) {
    /**
     * Jika koneksi gagal, kirim respons JSON dengan kode HTTP 500
     * dan hentikan eksekusi script.
     */
    http_response_code(500);
    echo json_encode([
        "sukses"  => false,
        "pesan"   => "Koneksi database gagal.",
        "detail"  => $e->getMessage() // Tampilkan detail error (nonaktifkan di produksi)
    ]);
    exit();
}
