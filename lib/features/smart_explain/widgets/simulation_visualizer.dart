import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'topic_visualization_helper.dart';

/// Rich Interactive Simulation for physical equations and reactive models (e.g. Ohm's Law).
///
/// Features:
/// 1. Dynamic Circuit Model: Real-time visual bulb brightness, electron flow rate, and circuit elements.
/// 2. Live sliders for Voltage & Resistance with instant mathematical recalculation of Current ($I = V / R$).
/// 3. Guided Experiment Demo with [Previous] [Play Demo/Pause] [Restart] [Next] slow pedagogical walkthrough.
/// 4. "What happens if resistance increases?" Socratic experimentation insight card.
/// 5. "Try it yourself" interactive test scenarios and quick presets.
class SimulationVisualizer extends StatefulWidget {
  final String topic;
  final Map<String, dynamic>? visualizationData;

  const SimulationVisualizer({
    super.key,
    required this.topic,
    this.visualizationData,
  });

  @override
  State<SimulationVisualizer> createState() => _SimulationVisualizerState();
}

class _SimulationVisualizerState extends State<SimulationVisualizer>
    with SingleTickerProviderStateMixin {
  late String _formula;
  late String _secondaryFormula;
  late String _outputLabel;
  late String _outputUnit;

  late String _varALabel;
  late String _varAUnit;
  late double _varAMin;
  late double _varAMax;
  late double _varAValue;

  late String _varBLabel;
  late String _varBUnit;
  late double _varBMin;
  late double _varBMax;
  late double _varBValue;

  late String _experimentQuestion;
  late String _experimentAnswer;
  late String _whyWorksText;

  late AnimationController _pulseController;
  int _currentScenarioIndex = 0;
  bool _isPlaying = false;
  Timer? _demoTimer;

  static const List<Map<String, dynamic>> _demoScenarios = [
    {
      'title': '1. Low Voltage + High Resistance',
      'v': 3.0,
      'r': 300.0,
      'desc': 'Low electrical pressure with high opposition produces minimal current flow (~10 mA). The bulb is very dim.',
    },
    {
      'title': '2. High Voltage + High Resistance',
      'v': 18.0,
      'r': 300.0,
      'desc': 'Increasing voltage pushes electrons with 6x more force, raising current proportionally (~60 mA).',
    },
    {
      'title': '3. High Voltage + Low Resistance',
      'v': 18.0,
      'r': 50.0,
      'desc': 'Removing resistance creates a low-friction conduit, producing strong current flow (~360 mA). The bulb glows brightly.',
    },
    {
      'title': '4. Balanced Standard Circuit',
      'v': 9.0,
      'r': 100.0,
      'desc': 'Standard operating balance: 9V battery with 100Ω resistor generates a stable 90 mA.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _initFromData();
  }

  @override
  void dispose() {
    _demoTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SimulationVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.visualizationData != widget.visualizationData ||
        oldWidget.topic != widget.topic) {
      _initFromData();
    }
  }

  void _applyScenario(int index) {
    if (index >= 0 && index < _demoScenarios.length) {
      final s = _demoScenarios[index];
      setState(() {
        _currentScenarioIndex = index;
        _varAValue = (s['v'] as double).clamp(_varAMin, _varAMax);
        _varBValue = (s['r'] as double).clamp(_varBMin, _varBMax);
      });
    }
  }

  void _startDemo() {
    _demoTimer?.cancel();
    setState(() => _isPlaying = true);
    _demoTimer = Timer.periodic(const Duration(milliseconds: 2800), (timer) {
      if (_currentScenarioIndex < _demoScenarios.length - 1) {
        _nextScenario(fromDemo: true);
      } else {
        _stopDemo();
      }
    });
  }

  void _stopDemo() {
    _demoTimer?.cancel();
    if (_isPlaying) {
      setState(() => _isPlaying = false);
    }
  }

  void _toggleDemo() {
    if (_isPlaying) {
      _stopDemo();
    } else {
      if (_currentScenarioIndex >= _demoScenarios.length - 1) {
        _restartDemo();
      }
      _startDemo();
    }
  }

  void _nextScenario({bool fromDemo = false}) {
    if (!fromDemo) _stopDemo();
    if (_currentScenarioIndex < _demoScenarios.length - 1) {
      _applyScenario(_currentScenarioIndex + 1);
    }
  }

  void _prevScenario() {
    _stopDemo();
    if (_currentScenarioIndex > 0) {
      _applyScenario(_currentScenarioIndex - 1);
    }
  }

  void _restartDemo() {
    _stopDemo();
    _applyScenario(0);
  }

  void _initFromData() {
    final rawData = widget.visualizationData;
    final bool hasValidControls = rawData != null &&
        rawData['controls'] is List &&
        (rawData['controls'] as List).isNotEmpty;

    final data = hasValidControls
        ? rawData
        : TopicVisualizationHelper.getSimulationData(widget.topic, rawData);

    _formula = data['formula'] as String? ?? 'V = I × R';
    _secondaryFormula = data['secondary_formula'] as String? ?? 'I = V / R';

    final output = data['primary_output'] as Map<String, dynamic>? ?? {};
    _outputLabel = output['label'] as String? ?? 'Current (I)';
    _outputUnit = output['unit'] as String? ?? 'mA';

    final controls = data['controls'] as List<dynamic>?;
    if (controls != null && controls.isNotEmpty) {
      final cA = controls[0] as Map<String, dynamic>? ?? {};
      _varALabel = cA['label'] as String? ?? 'Voltage (Push Force)';
      _varAUnit = cA['unit'] as String? ?? 'V';
      _varAMin = (cA['min'] as num?)?.toDouble() ?? 1.0;
      _varAMax = (cA['max'] as num?)?.toDouble() ?? 24.0;
      _varAValue = (cA['initial'] as num?)?.toDouble() ?? 9.0;

      if (controls.length > 1) {
        final cB = controls[1] as Map<String, dynamic>? ?? {};
        _varBLabel = cB['label'] as String? ?? 'Resistance (Obstacle)';
        _varBUnit = cB['unit'] as String? ?? 'Ω';
        _varBMin = (cB['min'] as num?)?.toDouble() ?? 10.0;
        _varBMax = (cB['max'] as num?)?.toDouble() ?? 500.0;
        _varBValue = (cB['initial'] as num?)?.toDouble() ?? 100.0;
      } else {
        _varBLabel = 'Resistance (Obstacle)';
        _varBUnit = 'Ω';
        _varBMin = 10.0;
        _varBMax = 500.0;
        _varBValue = 100.0;
      }
    } else {
      _varALabel = 'Voltage (Push Force)';
      _varAUnit = 'V';
      _varAMin = 1.0;
      _varAMax = 24.0;
      _varAValue = 9.0;

      _varBLabel = 'Resistance (Obstacle)';
      _varBUnit = 'Ω';
      _varBMin = 10.0;
      _varBMax = 500.0;
      _varBValue = 100.0;
    }

    _experimentQuestion = data['experiment_question'] as String? ?? 'What happens if resistance increases?';
    _experimentAnswer = data['experiment_answer'] as String? ??
        'Higher resistance restricts electron flow, reducing Current and causing the bulb to dim.';
    _whyWorksText = data['why_this_works'] as String? ??
        'Current flows when Voltage pushes electrons through Resistance. Increasing voltage increases current, while higher resistance restricts the flow.';
  }

  double get _calculatedCurrentMa {
    if (_varBValue <= 0) return 0.0;
    return (_varAValue / _varBValue) * 1000;
  }

  @override
  Widget build(BuildContext context) {
    final currentMa = _calculatedCurrentMa;
    final glowIntensity = (currentMa / 150).clamp(0.08, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Main Interactive Simulation Canvas
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: AppColors.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header: Topic, Formulas & Real-time Output
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.topic.isNotEmpty ? widget.topic : "Ohm's Law",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$_formula  •  $_secondaryFormula',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.tealPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.tealLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.tealBorder),
                    ),
                    child: Text(
                      '$_outputLabel: ${currentMa.toStringAsFixed(1)} $_outputUnit',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.tealPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Visual Circuit Representation (Battery -> Resistor -> Glowing Bulb)
              _buildCircuitVisual(currentMa, glowIntensity),
              const SizedBox(height: 20),

              // Voltage Control Slider
              _buildSliderRow(
                label: _varALabel,
                valueText: '${_varAValue.toStringAsFixed(1)} $_varAUnit',
                value: _varAValue.clamp(_varAMin, _varAMax),
                min: _varAMin,
                max: _varAMax,
                activeColor: AppColors.tealPrimary,
                inactiveColor: AppColors.tealLight,
                onChanged: (val) {
                  _stopDemo();
                  setState(() => _varAValue = val);
                },
              ),
              const SizedBox(height: 12),

              // Resistance Control Slider
              _buildSliderRow(
                label: _varBLabel,
                valueText: '${_varBValue.toInt()} $_varBUnit',
                value: _varBValue.clamp(_varBMin, _varBMax),
                min: _varBMin,
                max: _varBMax,
                activeColor: AppColors.orangePrimary,
                inactiveColor: AppColors.orangeLight,
                onChanged: (val) {
                  _stopDemo();
                  setState(() => _varBValue = val);
                },
              ),
              const SizedBox(height: 18),

              // Guided Scenario Walkthrough Banner & Controls
              _buildGuidedScenarioBanner(),
              const SizedBox(height: 14),
              _buildDemoControls(),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // 2. "What happens if resistance increases?" Experimentation Card
        _buildExperimentationCard(),
        const SizedBox(height: 18),

        // 3. "Try it yourself" Preset Challenges
        _buildTryItYourselfCard(),
      ],
    );
  }

  Widget _buildGuidedScenarioBanner() {
    final s = _demoScenarios[_currentScenarioIndex];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.tealLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.tealBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  s['title'] as String,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.tealPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              // Dots
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(_demoScenarios.length, (i) {
                  final isActive = i == _currentScenarioIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    width: isActive ? 14 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.tealPrimary : AppColors.cardBorder,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            s['desc'] as String,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoControls() {
    final isFirst = _currentScenarioIndex == 0;
    final isLast = _currentScenarioIndex == _demoScenarios.length - 1;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: isFirst ? null : _prevScenario,
            icon: const Icon(Icons.arrow_back_rounded, size: 16),
            label: const Text('Previous', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: AppColors.cardBorder),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              backgroundColor: AppColors.surface,
              disabledForegroundColor: AppColors.textMuted.withValues(alpha: 0.4),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filledTonal(
          tooltip: _isPlaying ? 'Pause Demo' : 'Play Demo',
          onPressed: _toggleDemo,
          icon: Icon(
            _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            size: 20,
            color: AppColors.tealPrimary,
          ),
          style: IconButton.styleFrom(
            padding: const EdgeInsets.all(12),
            backgroundColor: _isPlaying ? AppColors.tealLight : AppColors.surfaceSecondary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: _isPlaying ? AppColors.tealPrimary : AppColors.cardBorder,
                width: _isPlaying ? 1.5 : 1.0,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: _restartDemo,
          icon: const Icon(Icons.replay_rounded, size: 16),
          label: const Text('Restart', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
            side: const BorderSide(color: AppColors.cardBorder),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: AppColors.surfaceSecondary,
            foregroundColor: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isLast ? _restartDemo : () => _nextScenario(),
            icon: Icon(isLast ? Icons.check_circle_rounded : Icons.arrow_forward_rounded, size: 16),
            label: Text(
              isLast ? 'Restart' : 'Next',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.tealPrimary,
              foregroundColor: AppColors.textLight,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCircuitVisual(double currentMa, double glowIntensity) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Battery / Voltage Source
              _buildCircuitComponent(
                icon: Icons.battery_charging_full_rounded,
                label: 'Battery Source',
                value: '${_varAValue.toStringAsFixed(1)} V',
                color: AppColors.tealPrimary,
                bgColor: AppColors.tealLight,
              ),

              // Flow Arrow
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final pulse = (_pulseController.value * 0.4 + 0.6);
                  return Opacity(
                    opacity: glowIntensity.clamp(0.3, 1.0) * pulse,
                    child: const Icon(Icons.arrow_forward_rounded, color: AppColors.tealPrimary, size: 20),
                  );
                },
              ),

              // Resistor Obstacle
              _buildCircuitComponent(
                icon: Icons.tune_rounded,
                label: 'Resistor Drag',
                value: '${_varBValue.toInt()} Ω',
                color: AppColors.orangePrimary,
                bgColor: AppColors.orangeLight,
              ),

              // Flow Arrow
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final pulse = (_pulseController.value * 0.4 + 0.6);
                  return Opacity(
                    opacity: glowIntensity.clamp(0.3, 1.0) * pulse,
                    child: const Icon(Icons.arrow_forward_rounded, color: AppColors.tealPrimary, size: 20),
                  );
                },
              ),

              // Glowing Light Bulb Output
              _buildCircuitComponent(
                icon: Icons.lightbulb_rounded,
                label: 'Bulb Output',
                value: '${(glowIntensity * 100).toInt()}% glow',
                color: Color.lerp(AppColors.textMuted, AppColors.orangePrimary, glowIntensity)!,
                bgColor: Color.lerp(AppColors.surface, AppColors.orangeLight, glowIntensity)!,
                glow: glowIntensity > 0.4,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Dynamic Current Status Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.electric_bolt_rounded,
                  size: 15,
                  color: currentMa > 80 ? AppColors.orangePrimary : AppColors.tealPrimary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Flow Rate: ${currentMa.toStringAsFixed(1)} mA (${currentMa > 120 ? "High Current" : (currentMa > 50 ? "Moderate Flow" : "Low Current")})',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircuitComponent({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color bgColor,
    bool glow = false,
  }) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
            boxShadow: glow
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.35),
                      blurRadius: 14,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Icon(icon, color: color, size: 24),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: color),
        ),
      ],
    );
  }

  Widget _buildSliderRow({
    required String label,
    required String valueText,
    required double value,
    required double min,
    required double max,
    required Color activeColor,
    required Color inactiveColor,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            Text(
              valueText,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: activeColor),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          activeColor: activeColor,
          inactiveColor: inactiveColor,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildExperimentationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology_rounded, size: 18, color: AppColors.orangePrimary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _experimentQuestion,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.orangeLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.orangeBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _experimentAnswer,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _whyWorksText,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTryItYourselfCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.science_rounded, size: 18, color: AppColors.tealPrimary),
              SizedBox(width: 8),
              Text(
                'Try it yourself',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Test these preset circuit conditions to see how the system behaves:',
            style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildPresetChip(
                label: 'High Voltage Glow (24V, 50Ω)',
                onTap: () => setState(() {
                  _varAValue = 24.0;
                  _varBValue = 50.0;
                }),
              ),
              _buildPresetChip(
                label: 'Standard (9V, 100Ω)',
                onTap: () => setState(() {
                  _varAValue = 9.0;
                  _varBValue = 100.0;
                }),
              ),
              _buildPresetChip(
                label: 'High Resistance Dim (5V, 400Ω)',
                onTap: () => setState(() {
                  _varAValue = 5.0;
                  _varBValue = 400.0;
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPresetChip({required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
