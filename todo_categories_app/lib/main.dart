import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/todo_provider.dart';
import 'screens/category_list_screen.dart';

void main() => runApp(const TodoApp());

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF6C4CF6);

    return ChangeNotifierProvider(
      create: (_) => TodoProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Registro de tareas',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: seed),
          scaffoldBackgroundColor: const Color(0xFFF5F6FA),
          cardTheme: const CardThemeData(
            elevation: 0,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
          ),
        ),
        home: const _MgmShell(child: CategoryListScreen()),
      ),
    );
  }
}

class _MgmShell extends StatelessWidget {
  final Widget child;
  const _MgmShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const _Header(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE7EAF2)),
                    ),
                    child: child,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(22),
        bottomRight: Radius.circular(22),
      ),
      child: Container(
        height: 230,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E1B5A),
              Color(0xFF3D2AA6),
              Color(0xFF6C4CF6),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _WavesAndGridPainter(),
              ),
            ),
            Positioned(
              right: -10,
              top: 10,
              child: Opacity(
                opacity: 0.22,
                child: CustomPaint(
                  size: const Size(180, 180),
                  painter: _BuildingPainter(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(10),
                          border:
                              Border.all(color: Colors.white.withOpacity(0.25)),
                        ),
                        child: const Icon(
                          Icons.star_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Registro de tareas',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'Bienvenido a\nTu registro de tareas',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          height: 1.05,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Organiza mejor tu dia a dia.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.85),
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WavesAndGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p1 = Paint()
      ..color = Colors.white.withOpacity(0.14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final path = Path()
      ..moveTo(0, size.height * 0.62)
      ..cubicTo(
        size.width * 0.25,
        size.height * 0.40,
        size.width * 0.55,
        size.height * 0.88,
        size.width,
        size.height * 0.52,
      );
    canvas.drawPath(path, p1);

    final path2 = Path()
      ..moveTo(0, size.height * 0.75)
      ..cubicTo(
        size.width * 0.22,
        size.height * 0.55,
        size.width * 0.6,
        size.height * 1.02,
        size.width,
        size.height * 0.66,
      );
    canvas.drawPath(path2, p1);

    final p2 = Paint()
      ..color = Colors.white.withOpacity(0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final center = Offset(size.width * 0.62, size.height * 0.70);
    for (int i = 1; i <= 4; i++) {
      final r = size.width * (0.16 + i * 0.08);
      canvas.drawCircle(center, r, p2);
    }

    final p3 = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 0; i < 10; i++) {
      final x = size.width * (0.1 + i * 0.09);
      canvas.drawLine(
        Offset(x, size.height * 0.35),
        Offset(x, size.height),
        p3,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BuildingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    final base = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.18, h * 0.35, w * 0.64, h * 0.55),
      const Radius.circular(10),
    );
    canvas.drawRRect(base, paint);

    final tower = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.58, h * 0.18, w * 0.18, h * 0.72),
      const Radius.circular(10),
    );
    canvas.drawRRect(tower, paint);

    final cap = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.56, h * 0.10, w * 0.22, h * 0.14),
      const Radius.circular(10),
    );
    canvas.drawRRect(cap, paint);

    final windowPaint = Paint()
      ..blendMode = BlendMode.clear
      ..style = PaintingStyle.fill;

    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.drawRRect(base, paint);
    canvas.drawRRect(tower, paint);
    canvas.drawRRect(cap, paint);

    for (int row = 0; row < 5; row++) {
      for (int col = 0; col < 4; col++) {
        final rx = w * 0.25 + col * (w * 0.12);
        final ry = h * 0.43 + row * (h * 0.09);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(rx, ry, w * 0.07, h * 0.05),
            const Radius.circular(6),
          ),
          windowPaint,
        );
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
