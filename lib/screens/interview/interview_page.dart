import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../app/localization.dart';
import '../../models/interview_profile.dart';
import '../../services/interview_service.dart';

class InterviewPage extends StatefulWidget {
  const InterviewPage({super.key});

  @override
  State<InterviewPage> createState() => _InterviewPageState();
}

class _InterviewPageState extends State<InterviewPage> {

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _occupationController = TextEditingController();
  final _achievementController = TextEditingController();
  final _mistakeController = TextEditingController();
  final _dissatisfactionController = TextEditingController();
  final _desiredChangeController = TextEditingController();

  final InterviewService _interviewService = InterviewService();

  int _currentStep = 0;
  String? _lifeStage;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _occupationController.dispose();
    _achievementController.dispose();
    _mistakeController.dispose();
    _dissatisfactionController.dispose();
    _desiredChangeController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    try {
      final profile = await _interviewService.loadProfile(uid: user.uid);

      if (profile != null && mounted) {
        _nameController.text = profile.name;
        _ageController.text = profile.age == 0 ? '' : profile.age.toString();
        _occupationController.text = profile.occupation;
        _lifeStage = profile.lifeStage;
        _achievementController.text = profile.greatestAchievement;
        _mistakeController.text = profile.importantMistake;
        _dissatisfactionController.text = profile.dissatisfaction;
        _desiredChangeController.text = profile.desiredChange;
      }
    } catch (_) {
      // Loading an existing interview is optional.
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _validateCurrentStep() {
    final l10n = LX64Localizations.of(context);

    switch (_currentStep) {
      case 0:
        if (_nameController.text.trim().isEmpty) {
          _showMessage(l10n.pleaseEnter(l10n.name));
          return false;
        }
        return true;

      case 1:
        final age = int.tryParse(_ageController.text.trim());
        if (age == null || age < 1 || age > 120) {
          _showMessage(
            l10n.isChinese ? '请输入正确的年龄。' : 'Please enter a valid age.',
          );
          return false;
        }
        return true;

      case 2:
        if (_occupationController.text.trim().isEmpty) {
          _showMessage(l10n.pleaseEnter(l10n.occupation));
          return false;
        }
        return true;

      case 3:
        if (_lifeStage == null || _lifeStage!.isEmpty) {
          _showMessage(l10n.pleaseSelectLifeStage);
          return false;
        }
        return true;

      case 4:
        if (_achievementController.text.trim().isEmpty) {
          _showMessage(
            l10n.isChinese
                ? '请分享一个让你感到骄傲的成就。'
                : 'Please share an achievement you are proud of.',
          );
          return false;
        }
        return true;

      case 5:
        if (_mistakeController.text.trim().isEmpty) {
          _showMessage(
            l10n.isChinese
                ? '请分享一次重要的人生经验。'
                : 'Please share an important life experience.',
          );
          return false;
        }
        return true;

      case 6:
        if (_dissatisfactionController.text.trim().isEmpty) {
          _showMessage(
            l10n.isChinese
                ? '请告诉我们目前最想改善的地方。'
                : 'Please tell us what you most want to improve.',
          );
          return false;
        }
        return true;

      case 7:
        if (_desiredChangeController.text.trim().isEmpty) {
          _showMessage(
            l10n.isChinese
                ? '请告诉 LX-64 你最想改变什么。'
                : 'Please tell LX-64 what you most want to change.',
          );
          return false;
        }
        return true;
    }

    return false;
  }

  void _next() {
    if (!_validateCurrentStep()) {
      return;
    }

    if (_currentStep < 7) {
      setState(() {
        _currentStep++;
      });
      return;
    }

    _saveProfile();
  }

  void _back() {
    if (_currentStep == 0) {
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _currentStep--;
    });
  }

  Future<void> _saveProfile() async {
    if (_isSaving) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage(
        LX64Localizations.of(context).isChinese
            ? '请先登录。'
            : 'Please log in first.',
      );
      return;
    }

    final age = int.tryParse(_ageController.text.trim());

    if (age == null) {
      return;
    }

    final profile = InterviewProfile(
      name: _nameController.text.trim(),
      age: age,
      occupation: _occupationController.text.trim(),
      lifeStage: _lifeStage ?? '',
      greatestAchievement: _achievementController.text.trim(),
      importantMistake: _mistakeController.text.trim(),
      dissatisfaction: _dissatisfactionController.text.trim(),
      desiredChange: _desiredChangeController.text.trim(),
    );

    setState(() {
      _isSaving = true;
    });

    try {
      await _interviewService.saveProfile(
        uid: user.uid,
        profile: profile,
      );

      if (!mounted) {
        return;
      }

      final l10n = LX64Localizations.of(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.interviewSaved),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(
        LX64Localizations.of(context).isChinese
            ? '保存失败，请稍后再试。'
            : 'Unable to save. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = LX64Localizations.of(context);

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF08090D),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(l10n),
            _buildProgress(),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: SingleChildScrollView(
                  key: ValueKey(_currentStep),
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                  child: _buildStep(l10n),
                ),
              ),
            ),
            _buildBottomButton(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(LX64Localizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 20, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: _isSaving ? null : _back,
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            l10n.isChinese ? '人生访谈' : 'Life Interview',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            '${_currentStep + 1} / 8',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgress() {
    final progress = (_currentStep + 1) / 8;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: LinearProgressIndicator(
          value: progress,
          minHeight: 4,
          backgroundColor: Colors.white.withValues(alpha: 0.08),
          valueColor: const AlwaysStoppedAnimation<Color>(
            Color(0xFF8B7CFF),
          ),
        ),
      ),
    );
  }

  Widget _buildStep(LX64Localizations l10n) {
    switch (_currentStep) {
      case 0:
        return _question(
          emoji: '👋',
          title: l10n.name,
          description: l10n.nameHint,
          child: _textField(
            controller: _nameController,
            hint: l10n.nameHint,
            keyboardType: TextInputType.name,
          ),
        );

      case 1:
        return _question(
          emoji: '🎂',
          title: l10n.age,
          description: l10n.ageHint,
          child: _textField(
            controller: _ageController,
            hint: l10n.ageHint,
            keyboardType: TextInputType.number,
          ),
        );

      case 2:
        return _question(
          emoji: '💼',
          title: l10n.occupation,
          description: l10n.occupationHint,
          child: _textField(
            controller: _occupationController,
            hint: l10n.occupationHint,
            keyboardType: TextInputType.text,
          ),
        );

      case 3:
        return _question(
          emoji: '🧭',
          title: l10n.currentLifeStage,
          description: l10n.lifeStageHint,
          child: _lifeStageSelector(l10n),
        );

      case 4:
        return _question(
          emoji: '🏆',
          title: l10n.greatestAchievement,
          description: l10n.greatestAchievementHint,
          child: _textField(
            controller: _achievementController,
            hint: l10n.greatestAchievementHint,
            maxLines: 5,
            keyboardType: TextInputType.multiline,
          ),
        );

      case 5:
        return _question(
          emoji: '💭',
          title: l10n.importantMistake,
          description: l10n.importantMistakeHint,
          child: _textField(
            controller: _mistakeController,
            hint: l10n.importantMistakeHint,
            maxLines: 5,
            keyboardType: TextInputType.multiline,
          ),
        );

      case 6:
        return _question(
          emoji: '🔍',
          title: l10n.dissatisfaction,
          description: l10n.dissatisfactionHint,
          child: _textField(
            controller: _dissatisfactionController,
            hint: l10n.dissatisfactionHint,
            maxLines: 5,
            keyboardType: TextInputType.multiline,
          ),
        );

      case 7:
        return _question(
          emoji: '🌱',
          title: l10n.whatDoYouWantToChange,
          description: l10n.whatDoYouWantToChangeHint,
          child: _textField(
            controller: _desiredChangeController,
            hint: l10n.whatDoYouWantToChangeHint,
            maxLines: 6,
            keyboardType: TextInputType.multiline,
            highlight: true,
          ),
        );
    }

    return const SizedBox.shrink();
  }

  Widget _question({
    required String emoji,
    required String title,
    required String description,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 34),
        ),
        const SizedBox(height: 24),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 31,
            height: 1.15,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          description,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.58),
            fontSize: 16,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),
        child,
      ],
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required TextInputType keyboardType,
    int maxLines = 1,
    bool highlight = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      textInputAction:
          maxLines > 1 ? TextInputAction.newline : TextInputAction.next,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 17,
        height: 1.4,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.28),
          fontSize: 16,
          height: 1.4,
        ),
        filled: true,
        fillColor: highlight
            ? const Color(0xFF11121A)
            : const Color(0xFF0E1017),
        contentPadding: const EdgeInsets.all(18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: highlight
                ? const Color(0xFF8B7CFF).withValues(alpha: 0.45)
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: highlight
                ? const Color(0xFF8B7CFF).withValues(alpha: 0.45)
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: Color(0xFF8B7CFF),
            width: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _lifeStageSelector(LX64Localizations l10n) {
    return Column(
      children: l10n.lifeStages.map((stage) {
        final selected = _lifeStage == stage;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: _isSaving
                ? null
                : () {
                    setState(() {
                      _lifeStage = stage;
                    });
                  },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 17,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFF8B7CFF).withValues(alpha: 0.14)
                    : const Color(0xFF0E1017),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected
                      ? const Color(0xFF8B7CFF)
                      : Colors.white.withValues(alpha: 0.08),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      stage,
                      style: TextStyle(
                        color: selected
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.78),
                        fontSize: 16,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                  if (selected)
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF8B7CFF),
                      size: 21,
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomButton(LX64Localizations l10n) {
    final isLast = _currentStep == 7;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 18),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: FilledButton(
          onPressed: _isSaving ? null : _next,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF8B7CFF),
            foregroundColor: Colors.white,
            disabledBackgroundColor: const Color(0xFF3A374D),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isLast
                          ? (l10n.isChinese ? '完成访谈' : 'Complete Interview')
                          : l10n.continueText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      isLast
                          ? Icons.check_rounded
                          : Icons.arrow_forward_rounded,
                      size: 20,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
