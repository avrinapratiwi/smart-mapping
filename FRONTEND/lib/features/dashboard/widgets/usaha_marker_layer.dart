import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import '../../direktori_usaha/direktori_usaha.dart';

class UsahaMarkerLayer extends StatelessWidget {
  final List<UsahaModel> listUsaha;
  final Function(UsahaModel) onMarkerTapped;
  final int clusterRadius;
  final double markerSize;

  const UsahaMarkerLayer({
    super.key,
    required this.listUsaha,
    required this.onMarkerTapped,
    this.clusterRadius = 100,
    this.markerSize = 40.0,
  });

  @override
  Widget build(BuildContext context) {
    // Memilah usaha berkoordinat dengan camelCase variables
    final listUsahaTerfilter = listUsaha.where((u) => u.punyaKoordinat).toList();

    // Pembuatan list <Marker> untuk merender komponen Leaflet/Map
    final List<Marker> markers = listUsahaTerfilter.map((usaha) {
      return Marker(
        point: usaha.toLatLng!,
        width: markerSize,
        height: markerSize,
        child: GestureDetector(
          onTap: () => onMarkerTapped(usaha),
          child: const Icon(
            Icons.location_on,
            color: Colors.orange,
            size: 40.0,
          ),
        ),
      );
    }).toList();

    // Kembalikan widget konstan untuk Cluster Group
    return MarkerClusterLayerWidget(
      options: MarkerClusterLayerOptions(
        maxClusterRadius: clusterRadius,
        markers: markers,
        builder: (context, clusterMarkers) {
          return Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.orange,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                clusterMarkers.length.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
