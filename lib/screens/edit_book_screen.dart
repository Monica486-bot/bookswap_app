import 'package:flutter/material.dart';

class EditBookScreen extends StatelessWidget {
  const EditBookScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Book'),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: const Center(child: Text('Edit Book Screen - To be implemented')),
    );
  }
}
