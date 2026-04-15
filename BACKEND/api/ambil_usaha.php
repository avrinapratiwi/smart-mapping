<?php
/**
 * ============================================================
 * ENDPOINT API: Ambil Data Direktori Usaha
 * Smart Mapping BPS - Sensus Ekonomi 2026
 * ============================================================
 * 
 * URL     : /api/ambil_usaha.php
 * Method  : GET
 * 
 * Parameter Query (opsional):
 *   - search : Kata kunci pencarian (mencari di kolom nama_usaha & idsbr)
 * 
 * Contoh Penggunaan:
 *   GET /api/ambil_usaha.php              → Ambil semua data
 *   GET /api/ambil_usaha.php?search=toko  → Cari data dengan kata "toko"
 */

// ============================================================
// 1. PENGATURAN HEADER HTTP
// ============================================================

/**
 * CORS (Cross-Origin Resource Sharing):
 * Mengizinkan frontend dari domain/port yang berbeda
 * untuk mengakses API ini (penting untuk Flutter Web).
 */
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

/**
 * Mengatur format respons sebagai JSON
 * agar klien (frontend) bisa mem-parsing data dengan mudah.
 */
header("Content-Type: application/json; charset=UTF-8");

/**
 * Menangani preflight request dari browser (metode OPTIONS).
 * Browser mengirim ini sebelum request sebenarnya untuk memeriksa CORS.
 */
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// ============================================================
// 2. IMPOR KONEKSI DATABASE
// ============================================================

/**
 * Memuat file konfigurasi database.
 * Variabel $koneksi akan tersedia setelah file ini di-include.
 */
require_once __DIR__ . '/../config/db.php';

// ============================================================
// 3. PROSES QUERY DATA
// ============================================================

try {
    /**
     * Mengambil parameter pencarian dari URL.
     * Fungsi trim() digunakan untuk menghapus spasi kosong di awal/akhir.
     * Jika parameter 'search' tidak ada, nilainya akan kosong ("").
     */
    $kata_kunci = isset($_GET['search']) ? trim($_GET['search']) : "";

    // --- Membangun Query SQL ---
    if (!empty($kata_kunci)) {
        /**
         * MODE PENCARIAN:
         * Menggunakan LIKE dengan wildcard (%) untuk mencari data
         * yang MENGANDUNG kata kunci di kolom nama_usaha ATAU idsbr.
         * 
         * PENTING: Menggunakan prepared statement (:keyword)
         * untuk mencegah serangan SQL Injection.
         */
        $sql = "SELECT * FROM direktori_usaha 
                WHERE nama_usaha LIKE :keyword 
                   OR idsbr LIKE :keyword 
                ORDER BY id ASC";

        $stmt = $koneksi->prepare($sql);

        // Menambahkan wildcard (%) di sekitar kata kunci untuk pencarian parsial
        $param_keyword = "%" . $kata_kunci . "%";
        $stmt->bindParam(':keyword', $param_keyword, PDO::PARAM_STR);

    } else {
        /**
         * MODE TAMPIL SEMUA:
         * Jika tidak ada kata kunci pencarian, ambil seluruh data.
         */
        $sql = "SELECT * FROM direktori_usaha ORDER BY id ASC";
        $stmt = $koneksi->prepare($sql);
    }

    // --- Eksekusi Query ---
    $stmt->execute();

    // --- Ambil Semua Hasil ---
    $hasil = $stmt->fetchAll();

    // --- Hitung Jumlah Data ---
    $jumlah = count($hasil);

    // ============================================================
    // 4. KIRIM RESPONS SUKSES
    // ============================================================

    http_response_code(200);
    echo json_encode([
        "sukses"      => true,
        "pesan"       => $jumlah > 0
            ? "Berhasil mengambil {$jumlah} data usaha."
            : "Tidak ada data yang ditemukan.",
        "jumlah_data" => $jumlah,
        "pencarian"   => $kata_kunci ?: null,
        "data"        => $hasil
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);

} catch (PDOException $e) {
    // ============================================================
    // 5. PENANGANAN ERROR
    // ============================================================

    /**
     * Jika terjadi error saat eksekusi query,
     * kirim respons error dengan kode HTTP 500.
     */
    http_response_code(500);
    echo json_encode([
        "sukses" => false,
        "pesan"  => "Gagal mengambil data dari database.",
        "detail" => $e->getMessage() // Nonaktifkan di produksi untuk keamanan
    ], JSON_PRETTY_PRINT);
}
