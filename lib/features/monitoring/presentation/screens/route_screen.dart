import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/route_cubit.dart';
import '../../cubit/route_state.dart';

class RouteScreen extends StatefulWidget {
  final String mmsi;

  const RouteScreen({super.key, required this.mmsi});

  @override
  State<RouteScreen> createState() => _RouteScreenState();
}

class _RouteScreenState extends State<RouteScreen> {
  @override
  void initState() {
    super.initState();
    context.read<RouteCubit>().loadRoute(widget.mmsi);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lộ trình tàu ${widget.mmsi} (M07)')),
      body: BlocBuilder<RouteCubit, RouteState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.points.length,
            separatorBuilder: (_, _) => const Divider(),
            itemBuilder: (context, index) {
              final pt = state.points[index];
              return ListTile(
                leading: const Icon(Icons.location_on_outlined),
                title: Text('Lat: ${pt.latitude}, Lon: ${pt.longitude}'),
                subtitle: Text('Thời gian: ${pt.timestamp.toLocal()}'),
              );
            },
          );
        },
      ),
    );
  }
}

