import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/grao_logo.dart';
import 'main_shell.dart';

/// Três telinhas rápidas: quem é o Grão, como funciona, como te chamar.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _lastPage = 2;

  final _pages = PageController();
  final _nameController = TextEditingController();
  int _page = 0;

  @override
  void dispose() {
    _pages.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _goTo(int page) {
    _pages.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<void> _next() async {
    if (_page < _lastPage) {
      _goTo(_page + 1);
      return;
    }
    final state = AppScope.read(context);
    final nav = Navigator.of(context);
    await state.completeOnboarding(_nameController.text);
    nav.pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const MainShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 12, 0),
                child: TextButton(
                  onPressed: _page == _lastPage ? null : () => _goTo(_lastPage),
                  child: const Text('Pular'),
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pages,
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  const _InfoPage(
                    illustration: GraoMark(size: 84, light: false),
                    title: 'Oi, eu sou o Grão.',
                    text:
                        'Um jeito simples de entender pra onde vai o seu dinheiro. '
                        'Sem planilha e sem termo difícil.',
                  ),
                  const _InfoPage(
                    illustration: Icon(Icons.bolt_rounded,
                        size: 68, color: AppColors.primary),
                    title: 'Anotar leva uns 10 segundos.',
                    text:
                        'Valor, categoria e pronto. Depois você vê no gráfico '
                        'o que mais pesou no mês.',
                  ),
                  _NamePage(controller: _nameController, onDone: _next),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i <= _lastPage; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _page ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _page
                          ? AppColors.primary
                          : AppColors.primaryLight.withAlpha(110),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _next,
                  child: Text(_page == _lastPage ? 'Bora começar' : 'Continuar'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoPage extends StatelessWidget {
  const _InfoPage({
    required this.illustration,
    required this.title,
    required this.text,
  });

  final Widget illustration;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height * 0.5,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: const BoxDecoration(
                color: AppColors.primaryFaint,
                shape: BoxShape.circle,
              ),
              child: Center(child: illustration),
            ),
            const SizedBox(height: 32),
            Text(title, textAlign: TextAlign.center, style: AppText.title),
            const SizedBox(height: 12),
            Text(text, textAlign: TextAlign.center, style: AppText.body),
          ],
        ),
      ),
    );
  }
}

class _NamePage extends StatelessWidget {
  const _NamePage({required this.controller, required this.onDone});

  final TextEditingController controller;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height * 0.5,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: const BoxDecoration(
                color: AppColors.primaryFaint,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.waving_hand_rounded,
                    size: 66, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Como você quer ser chamado?',
              textAlign: TextAlign.center,
              style: AppText.title,
            ),
            const SizedBox(height: 12),
            const Text(
              'É só pra gente conversar direito. Dá pra mudar depois.',
              textAlign: TextAlign.center,
              style: AppText.body,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: controller,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => onDone(),
              textAlign: TextAlign.center,
              decoration: const InputDecoration(hintText: 'Seu nome ou apelido'),
            ),
          ],
        ),
      ),
    );
  }
}
