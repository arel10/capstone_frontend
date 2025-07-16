import 'package:flutter/material.dart';

class PlaceholderScreen extends StatelessWidget {
  final String title;
  final bool showContent;
  final Widget? customContent;

  const PlaceholderScreen({
    super.key,
    required this.title,
    this.showContent = true,
    this.customContent,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body:
          customContent ??
          (showContent
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.construction,
                        size: 80,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Halaman $title',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const Text('Fitur ini sedang dalam pengembangan.'),
                    ],
                  ),
                )
              : const SizedBox.shrink()),
    );
  }
}
