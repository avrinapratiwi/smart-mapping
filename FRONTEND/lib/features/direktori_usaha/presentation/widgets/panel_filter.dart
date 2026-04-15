import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/filter_model.dart';
import '../direktori_bloc.dart';

class PanelFilter extends StatefulWidget {
  const PanelFilter({super.key});

  @override
  State<PanelFilter> createState() => _PanelFilterState();
}

class _PanelFilterState extends State<PanelFilter> {
  // Input fields controlling the active filters
  late TextEditingController _ctrlIdsbr;
  late TextEditingController _ctrlNamaUsaha;
  late TextEditingController _ctrlAlamatUsaha;
  late TextEditingController _ctrlDesa;

  // Selected values for dropdowns & switches
  late String _valProvinsi;
  late String _valKabupaten;
  late String _valKecamatan;
  late String _valSkalaUsaha;

  // Constant references for dropdown items
  static const List<String> _listProvinsi = ['Semua', 'SULAWESI SELATAN'];
  static const List<String> _listKabupaten = ['Semua', 'KEPULAUAN SELAYAR'];
  static const List<String> _listKecamatan = [
    'Semua', 'Benteng', 'Bontoharu', 'Bontomanai', 'Bontomatene', 
    'Bontosikuyu', 'Buki', 'Pasilambena', 'Pasimarannu', 
    'Pasimasunggu', 'Pasimasunggu Timur', 'Takabonerate'
  ];
  static const List<String> _listSkalaUsaha = ['Semua', 'UMKM', 'UB'];

  @override
  void initState() {
    super.initState();
    _inisialisasiData();
  }

  void _inisialisasiData() {
    // Ambil data langsung dari BLoC State untuk persistence
    final state = context.read<DirektoriBloc>().state;
    FilterDirektori filter = const FilterDirektori();
    if (state is DirektoriLoaded) {
      filter = state.filterSaatIni;
    }

    _ctrlIdsbr = TextEditingController(text: filter.idsbr);
    _ctrlNamaUsaha = TextEditingController(text: filter.namaUsaha);
    _ctrlAlamatUsaha = TextEditingController(text: filter.alamatUsaha);
    _ctrlDesa = TextEditingController(
      text: filter.desa == 'Semua' ? '' : filter.desa,
    );

    _valProvinsi = _listProvinsi.contains(filter.provinsi) ? filter.provinsi : 'Semua';
    _valKabupaten = _listKabupaten.contains(filter.kabupaten) ? filter.kabupaten : 'Semua';
    _valKecamatan = _listKecamatan.contains(filter.kecamatan) ? filter.kecamatan : 'Semua';
    _valSkalaUsaha = _listSkalaUsaha.contains(filter.skalaUsaha) ? filter.skalaUsaha : 'Semua';
  }

  @override
  void dispose() {
    _ctrlIdsbr.dispose();
    _ctrlNamaUsaha.dispose();
    _ctrlAlamatUsaha.dispose();
    _ctrlDesa.dispose();
    super.dispose();
  }

  void _kirimTerapkan() {
    final filterBaru = FilterDirektori(
      idsbr: _ctrlIdsbr.text.trim(),
      namaUsaha: _ctrlNamaUsaha.text.trim(),
      alamatUsaha: _ctrlAlamatUsaha.text.trim(),
      provinsi: _valProvinsi,
      kabupaten: _valKabupaten,
      kecamatan: _valKecamatan,
      desa: _ctrlDesa.text.trim().isEmpty ? 'Semua' : _ctrlDesa.text.trim(),
      skalaUsaha: _valSkalaUsaha,
    );

    // Kirim event secara de-coupling via bloc
    final state = context.read<DirektoriBloc>().state;
    final perHalaman = state is DirektoriLoaded ? state.perHalaman : 10;

    context.read<DirektoriBloc>().add(
      AmbilDirektoriEvent(filter: filterBaru, halaman: 1, perHalaman: perHalaman),
    );
    Navigator.of(context).pop(); // Tutup Drawer
  }
  
  void _reset() {
    final state = context.read<DirektoriBloc>().state;
    final perHalaman = state is DirektoriLoaded ? state.perHalaman : 10;

    context.read<DirektoriBloc>().add(
      AmbilDirektoriEvent(
        filter: const FilterDirektori(),
        halaman: 1,
        perHalaman: perHalaman,
      ),
    );
    Navigator.of(context).pop(); // Tutup Drawer
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 400,
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeaderDrawer(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(8),
                children: [
                  _buildBagianPencarian(),
                  _buildBagianWilayah(),
                  _buildBagianLanjutan(),
                ],
              ),
            ),
            _buildFooterAksi(),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // WIDGET BAGIAN UI
  // --------------------------------------------------------------------------

  Widget _buildHeaderDrawer() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFFFFA500),
      child: Row(
        children: [
          const Icon(Icons.tune, color: Colors.white),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Filter & Pencarian',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          )
        ],
      ),
    );
  }

  Widget _buildBagianPencarian() {
    return ExpansionTile(
      initiallyExpanded: true,
      leading: const Icon(Icons.search, color: Color(0xFFFFA500)),
      title: const Text('Pencarian Data', style: TextStyle(fontWeight: FontWeight.bold)),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              _buildInputTeks('Mencari berdasarkan IDSBR', _ctrlIdsbr, 'Kode IDSBR'),
              const SizedBox(height: 12),
              _buildInputTeks('Mencari Nama Usaha/Perusahaan', _ctrlNamaUsaha, 'Nama Usaha'),
              const SizedBox(height: 12),
              _buildInputTeks('Mencari Alamat spesifik', _ctrlAlamatUsaha, 'Alamat Usaha'),
              const SizedBox(height: 8),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildBagianWilayah() {
    return ExpansionTile(
      initiallyExpanded: true,
      leading: const Icon(Icons.map, color: Color(0xFFFFA500)),
      title: const Text('Filter Wilayah', style: TextStyle(fontWeight: FontWeight.bold)),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              _buildDropdown('Provinsi', _listProvinsi, _valProvinsi, (v) => setState(() => _valProvinsi = v!)),
              const SizedBox(height: 12),
              _buildDropdown('Kabupaten / Kota', _listKabupaten, _valKabupaten, (v) => setState(() => _valKabupaten = v!)),
              const SizedBox(height: 12),
              _buildDropdown('Kecamatan', _listKecamatan, _valKecamatan, (v) => setState(() => _valKecamatan = v!)),
              const SizedBox(height: 12),
              _buildInputTeks('Ketik Nama Kelurahan / Desa', _ctrlDesa, 'Desa'),
              const SizedBox(height: 8),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildBagianLanjutan() {
    return ExpansionTile(
      initiallyExpanded: true,
      leading: const Icon(Icons.category, color: Color(0xFFFFA500)),
      title: const Text('Filter Lanjutan', style: TextStyle(fontWeight: FontWeight.bold)),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              _buildDropdown('Skala Usaha', _listSkalaUsaha, _valSkalaUsaha, (v) => setState(() => _valSkalaUsaha = v!)),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildFooterAksi() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Color(0xFFFFA500)),
              ),
              onPressed: _reset,
              child: const Text('Reset', style: TextStyle(color: Color(0xFFFFA500))),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFFFFA500),
              ),
              onPressed: _kirimTerapkan,
              child: const Text('Terapkan', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // STANDARDISED INPUT COMPONENTS
  // --------------------------------------------------------------------------

  Widget _buildInputTeks(String hint, TextEditingController ctrl, String label) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String value, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      initialValue: value,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
    );
  }
}
