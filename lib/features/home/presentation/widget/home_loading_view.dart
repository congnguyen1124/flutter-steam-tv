import 'package:flutter/material.dart';

final class HomeLoadingView extends StatelessWidget {
  const HomeLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: .min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text('Loading your StreamTV home...'),
        ],
      ),
    );
  }
}
