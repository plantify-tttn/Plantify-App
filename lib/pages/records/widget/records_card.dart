import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:plantify/models/record_model.dart';

class RecordsCard extends StatelessWidget {
  const RecordsCard({
    super.key,
    required this.record,
    required this.dateFmt,
    this.onTap,
  });

  final RecordModel record;
  final DateFormat dateFmt;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final r = record;

    Widget leading;
    if (r.image.isNotEmpty) {
      leading = ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          r.image,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
        ),
      );
    } else {
      leading = const CircleAvatar(child: Icon(Icons.local_florist));
    }

    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: 1,
      borderRadius: BorderRadius.circular(12),
      child: ListTile(
        leading: leading,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(r.name, style: const TextStyle(fontWeight: FontWeight.w600)), // 👈 name
        subtitle: Row(
          children: [
            Icon(Icons.schedule, size: 16, color: Theme.of(context).hintColor),
            const SizedBox(width: 4),
            Text(dateFmt.format(r.createdAt)),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
