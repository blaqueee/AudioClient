import 'package:audio_client/di.dart';
import 'package:flutter/material.dart';

import '../bloc/connection_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _wsController = TextEditingController();
  final TextEditingController _tcpController = TextEditingController();
  final List<String> _backendList = ["Item 1", "Item 2", "Item 3"];
  String? _selectedItem;

  late final ConnectionBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = getIt<ConnectionBloc>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6FF),
      body: Center(
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Connection Manager',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // WebSocket field
              SizedBox(
                height: 50,
                child: TextField(
                  controller: _wsController,
                  decoration: const InputDecoration(
                    labelText: 'WebSocket URL',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // TCP field
              SizedBox(
                height: 50,
                child: TextField(
                  controller: _tcpController,
                  decoration: const InputDecoration(
                    labelText: 'TCP Address (host:port)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Dropdown
              SizedBox(
                height: 50,
                child: DropdownButtonFormField<String>(
                  value: _selectedItem,
                  onChanged: (value) => setState(() => _selectedItem = value),
                  items: _backendList.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  decoration: const InputDecoration(
                    labelText: 'Select Item',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (final label in ['Connect', 'Reconnect', 'Disconnect'])
                    SizedBox(
                      width: 130,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: () {
                          // your logic here
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple[100],
                          foregroundColor: Colors.deepPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(label),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Status
              Center(
                child: Text(
                  'Status: ${_bloc.state.status}',
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _wsController.dispose();
    _tcpController.dispose();
    super.dispose();
  }
}