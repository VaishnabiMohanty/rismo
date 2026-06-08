import 'dart:math';

class MascotLines {
  MascotLines._();

  static final _random = Random();

  // ── Daily narrative lines (streak journey, day by day) ───────────────────

  static const List<String> _dailyLines = [
    // Week 1 — Building the habit
    "Day 1 of your new life starts now. No pressure. Okay maybe a little.",
    "Two days in. Your future self just smiled.",
    "Three mornings strong. The snooze button is losing its power over you.",
    "Day 4. You're officially more consistent than most people ever get.",
    "Five days! Your body is starting to actually expect this. Wild, right?",
    "Day 6. One more and you hit your first big milestone. You've got this.",
    "A whole week! You did something most people only plan to do. You actually did it.",

    // Week 2 — Finding rhythm
    "Day 8. Last week wasn't a fluke. This is who you are now.",
    "Day 9. Notice how mornings feel a little less painful? That's the streak talking.",
    "Day 10. Double digits! Your discipline is quietly leveling up.",
    "Day 11. Most people quit before now. You're not most people.",
    "Day 12. Your mornings are becoming your superpower.",
    "Day 13. Unlucky for some, but not for someone on a 13-day streak.",
    "Two weeks! You've rewired your brain a little. Science agrees.",

    // Week 3 — The habit locks in
    "Day 15. Halfway to the 30-day badge. Keep your eyes on the prize.",
    "Day 16. Some people are still planning to start. You're already here.",
    "Day 17. Your alarm doesn't scare you anymore. You scare your alarm.",
    "Day 18. Three days to 21. That's the magic number where habits stick.",
    "Day 19. You're building character one morning at a time.",
    "Day 20. Twenty mornings of choosing yourself. That's love.",
    "21 days! Habit officially formed. Scientists confirm you're a morning person now.",

    // Week 4 — Ownership
    "Day 22. You own your mornings. Your mornings don't own you.",
    "Day 23. Still here. Still showing up. Respect.",
    "Day 24. Six days to the 30-day badge. Don't stop now.",
    "Day 25. A quarter of a hundred days. That's a stat worth bragging about.",
    "Day 26. You've been waking up on time longer than most diets last.",
    "Day 27. Three more days. The finish line is right there.",
    "Day 28. Four weeks of pure consistency. That's rare air.",
    "Day 29. Tomorrow you hit 30. Sleep well tonight. You've earned it.",
    "30 days! One month of showing up for yourself every single morning. Legendary.",

    // Days 31–50 — Deep consistency
    "Day 31. A new month, same unstoppable you.",
    "Day 32. Streaks this long start to feel effortless. That's the goal.",
    "Day 33. Three in a row that nobody talks about. But you know.",
    "Day 34. Your consistency is quietly inspiring people around you.",
    "Day 35. Five weeks. Your alarm clock respects you now.",
    "Day 36. Still going. Still winning.",
    "Day 37. The fact that you don't even think about it anymore? That's mastery.",
    "Day 38. Some habits take a month. Yours took less.",
    "Day 39. Tomorrow is 40. Not that you're counting. (You're counting.)",
    "Day 40. Forty mornings. Forty wins. That's a 100% win rate.",
    "Day 41. Most people gave up 40 days ago. Look at you.",
    "Day 42. The answer to life, the universe, and getting up on time.",
    "Day 43. You're in rare company up here.",
    "Day 44. Every single morning, you choose discipline. Every single time.",
    "Day 45. Halfway to 90. Just saying.",
    "Day 46. If waking up on time was a sport, you'd be in the playoffs.",
    "Day 47. Consistency like yours doesn't happen by accident.",
    "Day 48. Two days to 50. This is the home stretch.",
    "Day 49. Tomorrow's a big one. One more sleep.",
    "Day 50! Fifty days of not letting your bed win. You are the boss.",

    // Days 51–100 — Elite territory
    "Day 51. You're in the top 1% of alarm-dismissers worldwide. Probably.",
    "Day 52. Not even a Monday can stop you.",
    "Day 53. Your streak is old enough to have its own personality.",
    "Day 54. Still waking up. Still choosing yourself.",
    "Day 55. Five weeks and a half. The dedication is real.",
    "Day 56. Eight weeks. Two solid months on the horizon.",
    "Day 57. You've been doing this longer than most TV shows last.",
    "Day 58. Forty-two days to 100. But who's counting? (Everyone.)",
    "Day 59. Tomorrow is 60. Two months. Start the countdown.",
    "Day 60. Two months! That's sixty sunrises you chose to start right.",
    "Day 61. Sixty-one and counting. The streak lives on.",
    "Day 62. You've forgotten what snooze even feels like.",
    "Day 63. Nine weeks. Your streak can legally attend elementary school.",
    "Day 64. Thirty-six days to the century mark.",
    "Day 65. Each morning is a quiet reminder of who you've become.",
    "Day 66. Two-thirds of the way to 100.",
    "Day 67. Thirty-three more. You've got this in your sleep. (But don't sleep in.)",
    "Day 68. Your consistency has its own fan club. We're all in it.",
    "Day 69. Nice streak. (Had to.)",
    "Day 70. Ten weeks of pure, unbroken discipline.",
    "Day 71. Twenty-nine days to 100.",
    "Day 72. The kind of streak people tell stories about.",
    "Day 73. Still here. Every single morning.",
    "Day 74. Twenty-six days to 100. Keep the momentum.",
    "Day 75. Three-quarters of the way to 100. The finish line is near.",
    "Day 76. Your mornings are art at this point.",
    "Day 77. Lucky number 77. Not that you need luck.",
    "Day 78. Twenty-two more. You could do this in your sleep. (But please don't.)",
    "Day 79. Tomorrow is 80. Twenty days from the century. Unreal.",
    "Day 80. Eighty mornings. Eighty right choices. You're a machine.",
    "Day 81. Nineteen to go. This is the final stretch.",
    "Day 82. Eighteen days. Your streak is almost a full season.",
    "Day 83. Seventeen. Every morning is a gift you give yourself.",
    "Day 84. Twelve weeks. Your streak could run a marathon.",
    "Day 85. Fifteen days to 100. You can see the finish line.",
    "Day 86. Fourteen days. Two weeks to legend status.",
    "Day 87. Thirteen days. This time next week you'll be at 94.",
    "Day 88. Twelve days. Getting close.",
    "Day 89. Eleven. One more week plus four days.",
    "Day 90. Ninety days. That's a whole season of showing up. NINETY.",
    "Day 91. Nine days to 100. Single digits to a century.",
    "Day 92. Eight days. You've basically already done it.",
    "Day 93. Seven. One week.",
    "Day 94. Six days. The week will fly.",
    "Day 95. Five days. So close you can smell it.",
    "Day 96. Four days. Almost there.",
    "Day 97. Three days. The final stretch.",
    "Day 98. Two days. Tomorrow is day 99. The day before glory.",
    "Day 99. One more sleep. ONE. MORE. SLEEP.",
    "DAY 100. ONE HUNDRED DAYS. You didn't just build a habit. You built a new identity. 🏆",
  ];

  // ── Funny lines ───────────────────────────────────────────────────────────

  static const List<String> _funnyLines = [
    "You actually woke up. I'm impressed. Genuinely.",
    "Rise and shine! Or just rise. Shining is optional.",
    "Look at you, not hitting snooze. Who even are you?",
    "Your bed is crying right now. Worth it.",
    "You did it! Gravity tried to keep you down. You won.",
    "Breaking news: local person wakes up on time. Shocking.",
    "Scientists baffled as human leaves bed voluntarily.",
    "You're basically a superhero. Except your power is... waking up.",
    "The alarm rang. You listened. Respect.",
    "Your pillow hates you right now. That means you're winning.",
    "Somewhere out there, your past self who said 'I'll sleep early' is proud.",
    "Fun fact: your bed wanted you to stay. You said no. Power move.",
    "You just out-disciplined 90% of people who are still asleep right now.",
    "Alert: morning person detected. Authorities have been notified.",
    "You woke up before your excuses could. That's elite.",
    "Your alarm clock just let out a sigh of relief. Finally, someone listens.",
    "Plot twist: the bed lost. Again.",
    "You're awake. The coffee isn't even ready yet. You're THAT committed.",
    "Morning achieved. Difficulty: hard. You: unbothered.",
    "Another day, another victory over the gravitational pull of your mattress.",
  ];

  // ── Wholesome lines ───────────────────────────────────────────────────────

  static const List<String> _wholesomeLines = [
    "Good morning, champion. The world is a little better with you awake.",
    "You showed up for yourself today. That matters more than you know.",
    "Proud of you. For real.",
    "Your consistency is quietly inspiring everyone around you.",
    "This is what glow-up looks like. One morning at a time.",
    "You're building something great. Keep going.",
    "Every morning you wake up on time is a promise to yourself kept.",
    "Small wins every day add up to a life well lived.",
    "Your future self is already proud of you.",
    "Today started the right way because of you.",
    "You chose yourself this morning. That's always the right choice.",
    "Not everyone gets a fresh start every morning. You're making the most of yours.",
    "The version of you that started this streak would be amazed at where you are.",
    "You're not just waking up. You're showing up.",
    "There's something beautiful about someone who keeps their promises to themselves.",
    "You gave yourself the gift of a great morning. That's self-love.",
    "The world needs more people who do what they said they'd do. You're one of them.",
    "Every streak starts with one morning. Yours has had many. Keep adding.",
    "Quiet discipline is the loudest kind of confidence.",
    "You didn't feel like it. You did it anyway. That's everything.",
  ];

  // ── Motivational lines ────────────────────────────────────────────────────

  static const List<String> _motivationalLines = [
    "Champions aren't born in the gym. They're born when the alarm goes off.",
    "The early bird doesn't just get the worm — it gets the whole day.",
    "You chose discipline over comfort. That's rare.",
    "One more day closer to the best version of you.",
    "Consistency is the secret ingredient. You've got it.",
    "Success isn't owned. It's rented. And the rent is due every morning.",
    "The difference between who you are and who you want to be is what you do when the alarm rings.",
    "Your morning routine is your foundation. You just reinforced it.",
    "Great days don't happen by accident. They start exactly like this.",
    "You can't control everything. You can control this. And you did.",
    "Discipline is choosing between what you want now and what you want most.",
    "The hardest step is always the one out of bed. You nailed it.",
    "Every expert was once a beginner who refused to quit their morning routine.",
    "First win of the day: unlocked. What's next?",
    "People who win the morning tend to win the day. Today is yours.",
    "Your commitment to waking up says a lot about your commitment to everything else.",
    "Excellence isn't a destination. It's a daily decision. Made.",
    "The most successful people in the world guard their mornings fiercely. Like you do.",
    "You just did what most people will never do. Be proud.",
    "A good morning routine is a love letter to your future self.",
  ];

  // ── Milestone lines ───────────────────────────────────────────────────────

  static const Map<int, String> _milestoneLines = {
    1:   "Day 1! Every legend has a first chapter. This is yours. Let's go. 🚀",
    3:   "3 days in a row! You've beaten the 48-hour slump. The hardest part is behind you. 💪",
    5:   "5 day streak! High five! ✋ Your future self is already grateful.",
    7:   "A whole week! 7 days of choosing yourself over your pillow. That's character. 🔥",
    14:  "14 days! Two full weeks. Your brain has started to rewire itself. Science is proud. 🧠",
    21:  "21 days! This is the magic number. Habit officially formed. You're a morning person now. ✨",
    30:  "30 days! ONE MONTH of pure consistency. Most people only dream about this. You lived it. 🏅",
    50:  "50 days! Half a century of daily wins. You're in the top 1% of alarm dismissers. 💎",
    100: "100 DAYS! 🏆 That's not a streak. That's a transformation. You didn't just change your mornings — you changed yourself.",
  };

  // ── Day-of-week lines ─────────────────────────────────────────────────────

  static const Map<int, String> _dayOfWeekLines = {
    1: "Happy Monday! The week is yours to shape. Start strong. 💼",
    2: "Tuesday! Monday warmed you up. Today you mean business.",
    3: "Wednesday! Hump day conquered. You're over the hill and flying. 🐪",
    4: "Thursday! One day from Friday. Finish the week like you started it.",
    5: "Friday! You made it through the whole week waking up on time. That's a full sweep. 🎉",
    6: "Saturday! Even on weekends, you show up. That's next-level dedication.",
    7: "Sunday! Setting the tone for the whole week ahead. Smart move.",
  };

  // ── Public API ────────────────────────────────────────────────────────────

  /// Main method — use this in mascot_popup.dart
  /// Returns milestone line → daily narrative → random funny/wholesome/motivational
  static String combined(int streak) {
    // Always show milestone lines on milestone days
    if (_milestoneLines.containsKey(streak)) {
      return _milestoneLines[streak]!;
    }

    // Show day-of-week lines on Mondays and Fridays for extra flavor
    final weekday = DateTime.now().weekday;
    if (weekday == 1 || weekday == 5) {
      return _dayOfWeekLines[weekday]!;
    }

    // For streaks within the daily narrative range use the story line
    if (streak >= 1 && streak <= _dailyLines.length) {
      return _dailyLines[streak - 1];
    }

    // Beyond 100 days — rotate through all pools randomly
    return _randomFromAllPools();
  }

  /// Returns a random funny line
  static String funny() => _funnyLines[_random.nextInt(_funnyLines.length)];

  /// Returns a random wholesome line
  static String wholesome() =>
      _wholesomeLines[_random.nextInt(_wholesomeLines.length)];

  /// Returns a random motivational line
  static String motivational() =>
      _motivationalLines[_random.nextInt(_motivationalLines.length)];

  /// Returns a purely random line from ALL pools
  static String random() => _randomFromAllPools();

  /// Returns the daily narrative line for the current streak day
  static String forStreak(int streak) {
    if (_milestoneLines.containsKey(streak)) return _milestoneLines[streak]!;
    if (streak >= 1 && streak <= _dailyLines.length) {
      return _dailyLines[streak - 1];
    }
    return _randomFromAllPools();
  }

  /// Returns the day-of-week line for today
  static String forDayOfWeek() {
    return _dayOfWeekLines[DateTime.now().weekday] ?? random();
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  static String _randomFromAllPools() {
    final all = [
      ..._funnyLines,
      ..._wholesomeLines,
      ..._motivationalLines,
    ];
    return all[_random.nextInt(all.length)];
  }
}