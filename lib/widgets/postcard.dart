import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import '../theme/app_theme.dart';

/// Tarjeta postal con borde de sello, texto tipo máquina de escribir
/// y un pequeño matasellos con la fecha.
class Postcard extends StatelessWidget {
  final String text;
  final DateTime date;

  const Postcard({super.key, required this.text, required this.date});

  @override
  Widget build(BuildContext context) {
    final formattedDate = intl.DateFormat("d 'de' MMMM, y", 'es').format(date);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.stampBorder, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'VÍA POSTAL',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.rust,
                      fontSize: 12,
                    ),
              ),
              _StampMark(date: formattedDate),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: AppColors.stampBorder.withOpacity(0.5)),
          const SizedBox(height: 12),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              '— con cariño, Sebas',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StampMark extends StatelessWidget {
  final String date;
  const _StampMark({required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.fadedBrown.withOpacity(0.6)),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        date,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 10,
          color: AppColors.fadedBrown,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
