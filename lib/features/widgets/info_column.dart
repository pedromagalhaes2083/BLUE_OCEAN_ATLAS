import 'package:flutter/material.dart';

class InfoColumn extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;

  const InfoColumn({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 28),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontSize: 15), textAlign: TextAlign.center),
      ],
    );
  }
}
