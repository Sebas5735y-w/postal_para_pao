import 'package:flutter/material.dart';
import '../data/messages.dart';
import '../services/message_service.dart';
import '../theme/app_theme.dart';
import '../widgets/postcard.dart';
import '../widgets/wax_seal.dart';
import 'archive_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final _service = MessageService();
  LoveMessage? _todayMessage;
  bool _opened = false;
  bool _loading = true;
  int _streak = 0;

  late final AnimationController _revealController;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fade = CurvedAnimation(parent: _revealController, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _revealController, curve: Curves.easeOutCubic));
    _load();
  }

  @override
  void dispose() {
    _revealController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final msg = await _service.getTodayMessage();
    final opened = await _service.isTodayOpened();
    final streak = await _service.getStreak();
    setState(() {
      _todayMessage = msg;
      _opened = opened;
      _streak = streak;
      _loading = false;
    });
    if (opened) _revealController.value = 1;
  }

  Future<void> _breakSeal() async {
    await _service.markTodayAsOpened();
    final streak = await _service.getStreak();
    setState(() {
      _opened = true;
      _streak = streak;
    });
    _revealController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Postal para Pao'),
            Text(
              'con cariño, para ti',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11),
            ),
          ],
        ),
        actions: [
          if (_streak > 0)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.mustard.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.mustard, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🔥', style: TextStyle(fontSize: 13)),
                      const SizedBox(width: 4),
                      Text(
                        '$_streak',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.rust,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.collections_bookmark_outlined),
            tooltip: 'Álbum de cartas',
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ArchiveScreen()),
              );
              _load();
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.rust))
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Correo de hoy',
                        style: Theme.of(context).textTheme.displayMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _opened
                            ? 'Ya rompiste el sello. Puedes releerla cuando quieras.'
                            : 'Llegó una carta nueva. Rompe el sello para leerla.',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      if (!_opened)
                        _EnvelopeWithSeal(onBreak: _breakSeal)
                      else if (_todayMessage != null)
                        FadeTransition(
                          opacity: _fade,
                          child: SlideTransition(
                            position: _slide,
                            child: Postcard(text: _todayMessage!.text, date: DateTime.now()),
                          ),
                        ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class _EnvelopeWithSeal extends StatelessWidget {
  final VoidCallback onBreak;
  const _EnvelopeWithSeal({required this.onBreak});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.kraftPaperDark,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.stampBorder, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.mail_outline, size: 40, color: AppColors.fadedBrown),
          const SizedBox(height: 20),
          WaxSeal(onBreak: onBreak),
          const SizedBox(height: 20),
          Text(
            'Toca el sello para abrir',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
