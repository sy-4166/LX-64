import 'package:flutter/material.dart';

class LX64Localizations {
  final Locale locale;

  const LX64Localizations(this.locale);

  bool get isChinese => locale.languageCode == 'zh';

  static LX64Localizations of(BuildContext context) {
    return Localizations.of<LX64Localizations>(
          context,
          LX64Localizations,
        ) ??
        const LX64Localizations(Locale('en'));
  }

  String get appName => 'LX-64';

  String get start => isChinese ? '开始' : 'Start';

  String get understandYourself =>
      isChinese ? '了解自己。\n建立属于你的人生。' : 'Understand Yourself.\nBuild Your Life.';

  String get welcomeDescription => isChinese
      ? 'LX-64 会先了解你是谁，再帮助你建立适合你的人生计划。'
      : 'LX-64 will first understand who you are, '
          'then help you build a life plan that fits you.';

  String get lifeJourney =>
      isChinese ? '你的人生。你的方向。你的旅程。' : 'Your life. Your direction. Your journey.';

  String get getToKnowYou => isChinese ? '认识你' : 'Get to Know You';

  String get interviewIntro => isChinese
      ? '在建立你的性格档案和人生计划之前，LX-64 需要先了解你现在的人生状态。'
      : 'Before creating your personality profile and life plans, '
          'LX-64 needs to understand where you are today.';

  String get name => isChinese ? '姓名' : 'Name';

  String get nameHint => isChinese ? 'LX-64 应该怎么称呼你？' : 'What should LX-64 call you?';

  String get age => isChinese ? '年龄' : 'Age';

  String get ageHint => isChinese ? '你的年龄' : 'Your age';

  String get occupation => isChinese ? '职业' : 'Occupation';

  String get occupationHint => isChinese ? '你目前从事什么工作？' : 'What do you currently do?';

  String get currentLifeStage => isChinese ? '目前人生阶段' : 'Current Life Stage';

  String get lifeStageHint =>
      isChinese ? '选择最符合你目前状态的阶段' : 'Choose the stage closest to you';

  List<String> get lifeStages => isChinese
      ? [
          '学生阶段',
          '刚开始工作',
          '职业发展阶段',
          '家庭与稳定阶段',
          '职业转型阶段',
          '创业阶段',
          '寻找新方向',
          '其他',
        ]
      : [
          'Student',
          'Starting Career',
          'Career Development',
          'Family & Stability',
          'Career Transition',
          'Building a Business',
          'Looking for a New Direction',
          'Other',
        ];

  String get lifeExperience => isChinese ? '你的人生经历' : 'Your Life Experience';

  String get lifeExperienceDescription => isChinese
      ? '你的过去经历可以帮助 LX-64 更了解你现在的人生方向。'
      : 'Your past experiences help LX-64 understand your current direction.';

  String get greatestAchievement => isChinese ? '最值得骄傲的成就' : 'Greatest Achievement';

  String get greatestAchievementHint =>
      isChinese ? '到目前为止，你最为自己感到骄傲的事情是什么？' : 'What are you most proud of so far?';

  String get importantMistake =>
      isChinese ? '重要的错误或错误决定' : 'Important Mistake or Wrong Decision';

  String get importantMistakeHint => isChinese
      ? '过去什么经历让你学到了重要的人生教训？'
      : 'What experience taught you an important lesson?';

  String get yourLifeToday => isChinese ? '你现在的人生' : 'Your Life Today';

  String get yourLifeTodayDescription => isChinese
      ? '告诉 LX-64 你目前正在经历什么。'
      : 'Tell LX-64 what is happening in your life right now.';

  String get dissatisfaction =>
      isChinese ? '你对什么感到不满意？' : 'What are you dissatisfied with?';

  String get dissatisfactionHint => isChinese
      ? '你希望改善目前人生中的哪一个部分？'
      : 'What part of your current life do you want to improve?';

  String get whatDoYouWantToChange =>
      isChinese ? '你想改变什么？' : 'What do you want to change?';

  String get whatDoYouWantToChangeHint => isChinese
      ? '如果 LX-64 可以帮助你改变一件事情，你希望是什么？'
      : 'If LX-64 could help you change one thing, what would it be?';

  String get continueText => isChinese ? '继续' : 'Continue';

  String get pleaseSelectLifeStage =>
      isChinese ? '请选择你目前的人生阶段。' : 'Please select your current life stage.';

  String pleaseEnter(String field) {
    return isChinese ? '请输入$field。' : 'Please enter $field.';
  }

  String get interviewSaved =>
      isChinese ? '访谈资料已保存。' : 'Interview information saved.';
}

class LX64LocalizationsDelegate
    extends LocalizationsDelegate<LX64Localizations> {
  const LX64LocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return locale.languageCode == 'en' || locale.languageCode == 'zh';
  }

  @override
  Future<LX64Localizations> load(Locale locale) async {
    if (locale.languageCode == 'zh') {
      return const LX64Localizations(Locale('zh'));
    }

    return const LX64Localizations(Locale('en'));
  }

  @override
  bool shouldReload(LX64LocalizationsDelegate old) => false;
}
