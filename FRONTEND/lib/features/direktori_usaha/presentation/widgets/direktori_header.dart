import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../direktori_bloc.dart';

class DirektoriHeader extends StatelessWidget {
  final VoidCallback onOpenFilter;

  const DirektoriHeader({
    super.key,
    required this.onOpenFilter,
  });

  @override
  Widget build(BuildContext context) {
    // Membaca state langsung tanpa parameter (No Props Drilling)
    final state = context.watch<DirektoriBloc>().state;
    final bool isFilterAktif = state is DirektoriLoaded && !state.filterSaatIni.isEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0))),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        runSpacing: 12,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              const Icon(Icons.business, color: Color(0xFFFFA500)),
              const Text(
                'Data Direktori Usaha',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              if (isFilterAktif)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.orange.shade300),
                  ),
                  child: const Text(
                    'Filter Aktif',
                    style: TextStyle(
                      color: Color(0xFFE65100),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: onOpenFilter,
            icon: const Icon(Icons.filter_list),
            label: const Text('Filter Data'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFA500),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}
