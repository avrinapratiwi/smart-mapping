import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'direktori_bloc.dart';
import '../data/direktori_service.dart';
import 'widgets/panel_filter.dart';
import 'widgets/direktori_header.dart';
import 'widgets/direktori_content_view.dart';

class DirektoriHalaman extends StatelessWidget {
  const DirektoriHalaman({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          DirektoriBloc(DirektoriService())
            ..add(AmbilDirektoriEvent(halaman: 1, perHalaman: 10)),
      child: const DirektoriView(),
    );
  }
}

class DirektoriView extends StatefulWidget {
  const DirektoriView({super.key});

  @override
  State<DirektoriView> createState() => _DirektoriViewState();
}

class _DirektoriViewState extends State<DirektoriView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: const PanelFilter(), // PanelFilter independent tanpa props
      backgroundColor: const Color(0xFFF5F6FA),
      body: Column(
        children: [
          // Header Pencarian independent & BLoC-driven
          DirektoriHeader(
            onOpenFilter: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),

          // Konten List Dinamis Diekstrak ke DirektoriContentView
          Expanded(
            child: BlocBuilder<DirektoriBloc, DirektoriState>(
              builder: (context, state) {
                return DirektoriContentView(state: state);
              },
            ),
          ),
        ],
      ),
    );
  }
}
