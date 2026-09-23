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
  final _formKey = GlobalKey<FormState>();
  final _interviewService = InterviewService();

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _occupationController = TextEditingController();
  final _achievementController = TextEditingController();
  final _regretController = TextEditingController();
  final _dissatisfactionController = TextEditingController();
  final _changeController = TextEditingController();

  int? _lifeStageIndex;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    final profile = await _interviewService.loadProfile(
      uid: user.uid,
    );

    if (!mounted || profile == null) {
      return;
    }

    final l10n = LX64Localizations.of(context);
    final index = l10n.lifeStages.indexOf(profile.lifeStage);

    setState(() {
      _nameController.text = profile.name;
      _ageController.text =
          profile.age == 0 ? '' : profile.age.toString();
      _occupationController.text = profile.occupation;
      _achievementController.text = profile.greatestAchievement;
      _regretController.text = profile.importantMistake;
      _dissatisfactionController.text = profile.dissatisfaction;
      _changeController.text = profile.desiredChange;
      _lifeStageIndex = index >= 0 ? index : null;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _occupationController.dispose();
    _achievementController.dispose();
    _regretController.dispose();
    _dissatisfactionController.dispose();
    _changeController.dispose();
    super.dispose();
  }

  Future<void> _continue(LX64Localizations l10n) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_lifeStageIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseSelectLifeStage),
        ),
      );
      return;
    }

    final age = int.tryParse(_ageController.text.trim());

    if (age == null || age <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.isChinese
                ? '请输入正确的年龄。'
                : 'Please enter a valid age.',
          ),
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.isChinese
                ? '尚未登录，暂时无法保存资料。'
                : 'You are not signed in yet.',
          ),
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isSaving = true;
    });

    final profile = InterviewProfile(
      name: _nameController.text.trim(),
      age: age,
      occupation: _occupationController.text.trim(),
      lifeStage: l10n.lifeStages[_lifeStageIndex!],
      greatestAchievement: _achievementController.text.trim(),
      importantMistake: _regretController.text.trim(),
      dissatisfaction: _dissatisfactionController.text.trim(),
      desiredChange: _changeController.text.trim(),
    );

    try {
      await _interviewService.saveProfile(
        uid: user.uid,
        profile: profile,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.interviewSaved),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.isChinese
                ? '保存失败：$e'
                : 'Failed to save: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  InputDecoration _decoration({
    required String label,
    required String hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFF11141C),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFF60A5FA),
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
    );
  }

  Widget _sectionTitle(
    String title,
    String description,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          description,
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      textInputAction:
          maxLines > 1 ? TextInputAction.newline : TextInputAction.next,
      decoration: _decoration(
        label: label,
        hint: hint,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter $label.';
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = LX64Localizations.of(context);
    final lifeStages = l10n.lifeStages;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.getToKnowYou),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle(
                l10n.getToKnowYou,
                l10n.interviewIntro,
              ),
              const SizedBox(height: 28),
              _field(
                controller: _nameController,
                label: l10n.name,
                hint: l10n.nameHint,
              ),
              const SizedBox(height: 16),
              _field(
                controller: _ageController,
                label: l10n.age,
                hint: l10n.ageHint,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _field(
                controller: _occupationController,
                label: l10n.occupation,
                hint: l10n.occupationHint,
              ),
              const SizedBox(height: 24),
              Text(
                l10n.currentLifeStage,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                initialValue: _lifeStageIndex,
                decoration: _decoration(
                  label: l10n.currentLifeStage,
                  hint: l10n.lifeStageHint,
                ),
                items: List.generate(
                  lifeStages.length,
                  (index) => DropdownMenuItem<int>(
                    value: index,
                    child: Text(lifeStages[index]),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _lifeStageIndex = value;
                  });
                },
              ),
              const SizedBox(height: 32),
              _sectionTitle(
                l10n.lifeExperience,
                l10n.lifeExperienceDescription,
              ),
              const SizedBox(height: 20),
              _field(
                controller: _achievementController,
                label: l10n.greatestAchievement,
                hint: l10n.greatestAchievementHint,
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              _field(
                controller: _regretController,
                label: l10n.importantMistake,
                hint: l10n.importantMistakeHint,
                maxLines: 4,
              ),
              const SizedBox(height: 32),
              _sectionTitle(
                l10n.yourLifeToday,
                l10n.yourLifeTodayDescription,
              ),
              const SizedBox(height: 20),
              _field(
                controller: _dissatisfactionController,
                label: l10n.dissatisfaction,
                hint: l10n.dissatisfactionHint,
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              _field(
                controller: _changeController,
                label: l10n.whatDoYouWantToChange,
                hint: l10n.whatDoYouWantToChangeHint,
                maxLines: 5,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed:
                      _isSaving ? null : () => _continue(l10n),
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          l10n.continueText,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
