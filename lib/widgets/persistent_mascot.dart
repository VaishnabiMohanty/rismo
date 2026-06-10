import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Context categories for mascot lines
enum MascotContext { home, calendar, settings, stopwatch, profile, todo, ringing }

class PersistentMascot extends StatefulWidget {
  final MascotContext context;
  const PersistentMascot({super.key, required this.context});

  @override
  State<PersistentMascot> createState() => _PersistentMascotState();
}

class _PersistentMascotState extends State<PersistentMascot>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceCtrl;
  late String _line;
  int _lineIndex = 0;
  bool _expanded = true;

  static const Map<MascotContext, List<String>> _lines = {
    MascotContext.home: [
      "Psst — your future self set this alarm. Don't let them down! ⏰",
      "Every alarm you set is a promise to tomorrow-you. Keep it! 💪",
      "Fun fact: The snooze button was invented in 1956. Don't worship it. 😤",
      "Consistency is a superpower. Set that alarm! 🦸",
      "Time is the only resource you can't get back. Spend it wisely! ⏳",
      "The early bird doesn't just get the worm — it gets the whole buffet. 🐦",
      "Your streak is a living thing. Feed it with wakefulness! 🔥",
      "Did you know? Morning light resets your circadian rhythm in 30 sec! ☀️",
      "Alarm set = battle plan ready. Sleep well, warrior. 🛡️",
      "The universe started 13.8 billion years ago. You have no excuse to sleep in. 🌌",
    ],
    MascotContext.calendar: [
      "Time is a flat circle… but your schedule doesn't have to be. 🗓️",
      "Ancient Romans had an 8-day week. Bet they still procrastinated. 📅",
      "A goal without a date is just a wish. Add that deadline! ✨",
      "Fun fact: The calendar you're using was fixed by Julius Caesar. Thanks, Jules! 🏛️",
      "The Mayans had 17 different calendars. You just need this one. 🌀",
      "Plan tomorrow today — your future self will send you thank-you notes. 💌",
      "Holidays are reminders that rest is productive too! 🎉",
      "Every day is a page. Write something worth reading! 📖",
      "Time blocking is the secret habit of high performers. 🧠",
      "The best time to plan was yesterday. The second best time is now! ⚡",
    ],
    MascotContext.settings: [
      "Customize me! I promise I won't tell anyone about your weird preferences. 🤫",
      "Behind every great app is someone who spent 3 hours in Settings. 🔧",
      "Fun fact: The gear icon became universal in 1997. Timeless design! ⚙️",
      "Tweak away — even the universe got fine-tuned over 13 billion years. 🌠",
      "The best settings are the ones that make you forget they exist. 🪄",
      "Your preferences are valid. All of them. Even dark mode at noon. 🌙",
      "Great settings = great mornings. Spend the time here! ⚙️",
      "I support your right to change your mind about notification sounds. 🔔",
      "Personalization is how tools become companions. That's what I am! 🤖",
      "Fun fact: The first digital alarm clock had exactly 0 settings. Lucky you! 😄",
    ],
    MascotContext.stopwatch: [
      "Every second is 9,192,631,770 oscillations of a cesium atom. Wild, right? ⚛️",
      "The fastest human 100m is 9.58s. What are you timing? 🏃",
      "Time flies whether you're having fun or not. Might as well have fun! 🕊️",
      "Fun fact: The word 'stopwatch' appeared in English in 1737. Ticking since! ⌚",
      "A watched pot never boils, but a watched stopwatch always ticks. 👀",
      "You can't stop time, but you can measure it. Power move! ⏱️",
      "The Pomodoro technique says 25 minutes of focus changes everything. Try it! 🍅",
      "Your focus is a superpower. This clock is just the receipt. 🧾",
      "Light takes 8 minutes to reach Earth from the Sun. What took YOU 8 minutes? ☀️",
      "Every great achievement was once just a ticking clock and a decision to start. 🚀",
    ],
    MascotContext.profile: [
      "You are the main character. Act accordingly! 🌟",
      "Fun fact: Your name is literally unique in spacetime. Own it! 🪐",
      "A good profile picture is worth 1000 words. Choose wisely! 📸",
      "The universe spent 13.8 billion years making you. Don't undersell that! 💫",
      "Your streak tells your story better than any bio. Keep building it! 📊",
      "Identity is built one morning at a time. You're doing great! 🌅",
      "Rismo remembers your wins even when you forget them. That's what I'm here for! 🏆",
      "Personal growth is just a streak by another name. Keep it alive! 🔥",
      "You are not a morning person or a night owl — you're a YOU person! 🦋",
      "Your best alarm sound says more about you than your star sign ever could. 😄",
    ],
    MascotContext.todo: [
      "A task written down is 42% more likely to get done. Science! 📝",
      "The ancient Egyptians made to-do lists too. Yours probably involves fewer pyramids. 🏺",
      "Done is better than perfect. Check that box! ✅",
      "Fun fact: GTD (Getting Things Done) was published in 2001. Still works! 📚",
      "Each task you complete is a tiny victory. Collect them all! 🎯",
      "Your brain uses energy to remember tasks. Write them here, free up RAM! 🧠",
      "The Zeigarnik effect: unfinished tasks nag your brain. Finish them! ⚡",
      "Benjamin Franklin kept a daily task list. So did Einstein. Just saying. 🎓",
      "One task at a time — multitasking is a myth invented by computers. 💻",
      "Every crossed-off item is proof you showed up today. That matters! 🌟",
    ],
    MascotContext.ringing: [
      "WAKE UP! The best version of you is already awake! 🌅",
      "Your alarm is ringing because you made a promise. Keep it! 💪",
      "Fun fact: Hitting snooze fragments your sleep cycle. Not worth it! 🚫",
      "The Sun rose just for you today. Don't make it wait! ☀️",
      "Every legend has an origin story. Yours starts NOW! ⚡",
      "Your future self is already awake in a parallel universe. Catch up! 🌌",
      "TIME IS NOW. ROBOT IS WATCHING. PLEASE WAKE UP. 🤖",
      "The day is fresh, the coffee is hot, and your potential is unlimited! ☕",
      "Rise and shine — the world needs what only you can bring today! 🌟",
      "Courage is waking up when every cell in your body says 'five more minutes'. 🦁",
    ],
  };

  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    final lines = _lines[widget.context] ?? _lines[MascotContext.home]!;
    _lineIndex = DateTime.now().second % lines.length;
    _line = lines[_lineIndex];
  }

  void _nextLine() {
    _bounceCtrl.forward(from: 0);
    final lines = _lines[widget.context] ?? _lines[MascotContext.home]!;
    setState(() {
      _lineIndex = (_lineIndex + 1) % lines.length;
      _line = lines[_lineIndex];
    });
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        setState(() => _expanded = !_expanded);
        if (!_expanded) _nextLine();
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Robot ──────────────────────────────────────────────────────
          GestureDetector(
            onTap: _nextLine,
            child: AnimatedBuilder(
              animation: _bounceCtrl,
              builder: (_, child) {
                final t = _bounceCtrl.value;
                final dy = t < 0.5 ? -12 * (t * 2) : -12 * (1 - (t - 0.5) * 2);
                return Transform.translate(
                  offset: Offset(0, dy),
                  child: child,
                );
              },
              child: SizedBox(
                width: 72,
                height: 72,
                child: Lottie.asset(
                  'assets/animations/robot.json',
                  repeat: true,
                  animate: true,
                ),
              ),
            ),
          ),

          // ── Speech bubble ──────────────────────────────────────────────
          if (_expanded)
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width - 100,
              ),
              child: GestureDetector(
                onTap: _nextLine,
                child: Container(
                  margin: const EdgeInsets.only(left: 6, bottom: 18),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      topRight: Radius.circular(14),
                      bottomRight: Radius.circular(14),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.10),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: Text(
                          _line,
                          key: ValueKey(_line),
                          style: TextStyle(
                            fontSize: 11.5,
                            color: cs.onPrimaryContainer,
                            height: 1.45,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'tap me for more ✨',
                        style: TextStyle(
                          fontSize: 9,
                          color: cs.onPrimaryContainer.withValues(alpha: 0.45),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 250.ms).slideX(begin: -0.08),
              ),
            ),
        ],
      ),
    );
  }
}