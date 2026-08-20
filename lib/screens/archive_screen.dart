import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import '../services/message_service.dart';
import '../theme/app_theme.dart';
import '../widgets/postcard.dart';

/// Álbum tipo "colección de estampillas" con todas las cartas ya abiertas.
class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key});

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  final _service = MessageService();
  List<DeliveredLetter> _letters = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final history = await _service.getHistory();
    setState(() {
      _letters = history.where((l) => l.opened).toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Álbum de cartas')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.rust))
          : _letters.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      'Todavía no hay cartas guardadas.\nCuando abras la de hoy, aparecerá aquí.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _letters.length,
                  itemBuilder: (context, index) {
                    final letter = _letters[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Postcard(text: letter.message.text, date: letter.date),
                    );
                  },
                ),
    );
  }
}
