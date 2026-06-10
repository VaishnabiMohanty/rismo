import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class StopwatchScreen extends StatefulWidget {
  const StopwatchScreen({super.key});

  @override
  State<StopwatchScreen> createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends State<StopwatchScreen> {
  final Stopwatch _sw = Stopwatch();
  Timer? _timer;
  final List<Duration> _laps = [];

  void _start() {
    _sw.start();
    _timer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      setState(() {});
    });
  }

  void _pause() {
    _sw.stop();
    _timer?.cancel();
    setState(() {});
  }

  void _reset() {
    _sw.stop();
    _sw.reset();
    _timer?.cancel();
    setState(() => _laps.clear());
  }

  void _lap() {
    setState(() => _laps.insert(0, _sw.elapsed));
  }

  String _format(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    final ms = ((d.inMilliseconds % 1000) ~/ 10).toString().padLeft(2, '0');
    if (d.inHours > 0) return '$h:$m:$s.$ms';
    return '$m:$s.$ms';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final running = _sw.isRunning;

    return Scaffold(
      appBar: AppBar(title: const Text('Stopwatch')),
      body: Column(
        children: [
          // ── Timer display ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text(
                _format(_sw.elapsed),
                style: TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.w200,
                  letterSpacing: 2,
                  color: running ? cs.primary : cs.onSurface,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),

          // ── Controls ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Reset / Lap
                _CircleButton(
                  icon: running ? Icons.flag_rounded : Icons.refresh_rounded,
                  label: running ? 'Lap' : 'Reset',
                  color: cs.surfaceContainerHighest,
                  iconColor: cs.onSurface,
                  onTap: running ? _lap : _reset,
                ),

                // Start / Pause — big center button
                _CircleButton(
                  icon: running
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  label: running ? 'Pause' : 'Start',
                  color: running ? cs.error : cs.primary,
                  iconColor: running ? Colors.white : Colors.white,
                  onTap: running ? _pause : _start,
                  size: 80,
                  iconSize: 36,
                ),

                // Spacer button (invisible but keeps layout)
                Opacity(
                  opacity: 0,
                  child: _CircleButton(
                    icon: Icons.refresh_rounded,
                    label: '',
                    color: Colors.transparent,
                    iconColor: Colors.transparent,
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Divider(height: 1),

          // ── Lap list ─────────────────────────────────────────────────────
          Expanded(
            child: _laps.isEmpty
                ? Center(
              child: Text(
                'No laps yet',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.3),
                ),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _laps.length,
              itemBuilder: (_, i) {
                final lapNum = _laps.length - i;
                Duration? delta;
                if (i < _laps.length - 1) {
                  delta = _laps[i] - _laps[i + 1];
                } else {
                  delta = _laps[i];
                }
                final isFastest = _laps.length > 1 &&
                    _laps[i] ==
                        _laps.reduce((a, b) => a < b ? a : b);
                final isSlowest = _laps.length > 1 &&
                    _laps[i] ==
                        _laps.reduce((a, b) => a > b ? a : b);

                return ListTile(
                  dense: true,
                  leading: Text(
                    'Lap $lapNum',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isFastest
                          ? Colors.green
                          : isSlowest
                          ? cs.error
                          : cs.onSurface,
                    ),
                  ),
                  trailing: Text(
                    _format(_laps[i]),
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w500,
                      color: cs.primary,
                    ),
                  ),
                  subtitle: delta != null
                      ? Text(
                    '+${_format(delta)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: cs.onSurface.withValues(alpha: 0.4),
                    ),
                  )
                      : null,
                ).animate().fadeIn(duration: 200.ms);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;
  final double size;
  final double iconSize;

  const _CircleButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.iconColor,
    required this.onTap,
    this.size = 64,
    this.iconSize = 28,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: iconSize),
          ),
        ),
        if (label.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color:
              Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ],
    );
  }
}