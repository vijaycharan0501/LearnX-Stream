import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'topic_visualization_helper.dart';

/// Rich Interactive Simulation for physical equations, circuits, and reactive models.
///
/// Features:
/// 1. Closed Conceptual Circuit Canvas: Battery (V) -> Lightbulb (I) -> Resistor (R).
/// 2. Animated Electron Particle Flow: Circulating dots with velocity proportional to current ($I = V / R$).
/// 3. Dynamic Formula Bar: Real-time mathematical display ($I = \frac{V}{R} = \frac{12.0\text{V}}{4.0\Omega} = 3.00\text{A}$).
/// 4. Interactive Sliders: Live Voltage ($1\text{V} - 24\text{V}$) and Resistance ($1\Omega - 20\Omega$) controls.
/// 5. Guided Experiment Scenarios with [Previous] [Play Demo/Pause] [Restart] [Next] slow pedagogical pacing.
/// 6. Synchronous "What's happening?" explanation and concise Key Idea takeaway.
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

  late AnimationController _electronAnimController;
  int _currentScenarioIndex = 0;
  bool _isPlaying = false;
  Timer? _demoTimer;

  static const List<Map<String, dynamic>> _demoScenarios = [
    {
      'title': '1. Low Voltage + High Resistance',
      'v': 4.0,
      'r': 16.0,
      'desc': 'Low electrical pressure with high resistance produces slow electron flow (0.25 A). The bulb is very dim.',
    },
    {
      'title': '2. High Voltage + High Resistance',
      'v': 20.0,
      'r': 16.0,
      'desc': 'Increasing voltage pushes electrons with 5x more force, raising current proportionally (1.25 A).',
    },
    {
      'title': '3. High Voltage + Low Resistance',
      'v': 20.0,
      'r': 4.0,
      'desc': 'Decreasing resistance allows electrons to flow freely, producing strong current (5.00 A). The bulb glows brightly.',
    },
    {
      'title': '4. Balanced Standard Circuit',
      'v': 12.0,
      'r': 4.0,
      'desc': 'Standard operating balance: 12V battery with 4Ω resistor generates a steady 3.00 A current.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _electronAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _initFromData();
  }

  @override
  void dispose() {
    _demoTimer?.cancel();
    _electronAnimController.dispose();
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
    final bool hasValidSimulation = rawData != null &&
        (rawData['formula'] != null ||
            rawData['variable_a'] != null ||
            rawData['primary_output'] != null ||
            rawData['controls'] != null);

    final data = hasValidSimulation
        ? rawData
        : TopicVisualizationHelper.getSimulationData(widget.topic, rawData);

    _formula = data['formula'] as String? ?? 'I = V / R';
    _secondaryFormula = data['secondary_formula'] as String? ?? 'V = I × R';

    final primaryOutput = data['primary_output'] as Map<String, dynamic>?;
    _outputLabel = primaryOutput?['label'] as String? ?? data['output_label'] as String? ?? 'Current (I)';
    _outputUnit = primaryOutput?['unit'] as String? ?? data['output_unit'] as String? ?? 'A';

    final controls = data['controls'] as List<dynamic>?;
    if (controls != null && controls.isNotEmpty) {
      final c0 = controls[0] as Map<String, dynamic>;
      _varALabel = c0['label'] as String? ?? 'Voltage (V)';
      _varAUnit = c0['unit'] as String? ?? 'V';
      _varAMin = (c0['min'] as num?)?.toDouble() ?? 1.0;
      _varAMax = (c0['max'] as num?)?.toDouble() ?? 30.0;
      _varAValue = (c0['initial'] as num?)?.toDouble() ?? (c0['default'] as num?)?.toDouble() ?? 12.0;

      if (controls.length > 1) {
        final c1 = controls[1] as Map<String, dynamic>;
        _varBLabel = c1['label'] as String? ?? 'Resistance (R)';
        _varBUnit = c1['unit'] as String? ?? 'Ω';
        _varBMin = (c1['min'] as num?)?.toDouble() ?? 1.0;
        _varBMax = (c1['max'] as num?)?.toDouble() ?? 600.0;
        _varBValue = (c1['initial'] as num?)?.toDouble() ?? (c1['default'] as num?)?.toDouble() ?? 120.0;
      }
    } else {
      final varA = data['variable_a'] as Map<String, dynamic>? ?? {};
      _varALabel = varA['label'] as String? ?? 'Voltage (V)';
      _varAUnit = varA['unit'] as String? ?? 'V';
      _varAMin = (varA['min'] as num?)?.toDouble() ?? 1.0;
      _varAMax = (varA['max'] as num?)?.toDouble() ?? 24.0;
      _varAValue = (varA['default'] as num?)?.toDouble() ?? 12.0;

      final varB = data['variable_b'] as Map<String, dynamic>? ?? {};
      _varBLabel = varB['label'] as String? ?? 'Resistance (R)';
      _varBUnit = varB['unit'] as String? ?? 'Ω';
      _varBMin = (varB['min'] as num?)?.toDouble() ?? 1.0;
      _varBMax = (varB['max'] as num?)?.toDouble() ?? 20.0;
      _varBValue = (varB['default'] as num?)?.toDouble() ?? 4.0;
    }

    final experiment = data['experiment'] as Map<String, dynamic>? ?? {};
    _experimentQuestion = experiment['question'] as String? ??
        'What happens to current (I) when resistance (R) increases?';
    _experimentAnswer = experiment['answer'] as String? ??
        'Because resistance opposes electron flow, increasing resistance causes current to decrease inversely when voltage is constant.';

    _whyWorksText = data['why_this_works'] as String? ??
        'Voltage acts as electrical pressure, while resistance opposes flow. Current is the resulting rate of charge movement (I = V / R).';

    _currentScenarioIndex = 0;
  }

  double get _calculatedOutput {
    if (_varBValue <= 0) return 0.0;
    final ratio = _varAValue / _varBValue;
    if (_outputUnit.toLowerCase() == 'ma') {
      return ratio * 1000.0;
    }
    return ratio;
  }

  @override
  Widget build(BuildContext context) {
    final currentA = _calculatedOutput;
    final currentAmps = _outputUnit.toLowerCase() == 'ma' ? currentA / 1000.0 : currentA;
    final glowIntensity = (currentAmps / 6.0).clamp(0.1, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. DOMINANT CIRCUIT VISUALIZATION CANVAS
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: AppColors.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header: Topic, Formulas & Real-time Output
              _buildHeader(currentA),
              const SizedBox(height: 14),

              // Visual Closed Circuit Schematic (Battery -> Bulb -> Resistor Loop)
              _buildClosedCircuitCanvas(currentA, glowIntensity),
              const SizedBox(height: 14),

              // Dynamic Mathematical Calculation Bar
              _buildFormulaCalculationBar(currentA),
              const SizedBox(height: 14),

              // Guided Scenario Walkthrough Banner
              _buildGuidedScenarioBanner(),
              const SizedBox(height: 12),

              // Unified Demo Pacing Controls
              _buildDemoControls(),
              const SizedBox(height: 16),

              // Interactive Voltage Slider
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
              const SizedBox(height: 10),

              // Interactive Resistance Slider
              _buildSliderRow(
                label: _varBLabel,
                valueText: '${_varBValue.toStringAsFixed(1)} $_varBUnit',
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
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 2. "Why this works" Key Takeaway
        _buildWhyThisWorksCard(),
        const SizedBox(height: 16),

        // 3. Socratic Experimentation Insight Card
        _buildExperimentationCard(),
      ],
    );
  }

  Widget _buildHeader(double currentA) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 6,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
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
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.tealLight,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.tealBorder),
          ),
          child: Text(
            '$_outputLabel: ${_outputUnit.toLowerCase() == 'ma' ? currentA.toStringAsFixed(1) : currentA.toStringAsFixed(2)} $_outputUnit',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.tealPrimary,
            ),
          ),
        ),
      ],
    );
  }

  /// Large Conceptual Circuit Schematic (Battery on left, Bulb on top, Resistor on right)
  Widget _buildClosedCircuitCanvas(double currentA, double glowIntensity) {
    return Container(
      constraints: const BoxConstraints(minHeight: 180),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          // Top Wire: Light Bulb Output
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCircuitComponent(
                icon: Icons.lightbulb_rounded,
                label: '💡 Lightbulb Load',
                value: '${(glowIntensity * 100).toInt()}% Luminescence',
                color: Color.lerp(AppColors.textMuted, AppColors.orangePrimary, glowIntensity)!,
                bgColor: Color.lerp(AppColors.surface, AppColors.orangeLight, glowIntensity)!,
                glow: glowIntensity > 0.35,
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Middle Row: Left Battery <---> Right Resistor with connecting wires & electron flow
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Battery / Voltage Source
              _buildCircuitComponent(
                icon: Icons.battery_charging_full_rounded,
                label: '🔋 Voltage Source',
                value: '${_varAValue.toStringAsFixed(1)} V',
                color: AppColors.tealPrimary,
                bgColor: AppColors.tealLight,
              ),

              // Animated Electron Wire Path
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.cardBorder,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      AnimatedBuilder(
                        animation: _electronAnimController,
                        builder: (context, child) {
                          final t = _electronAnimController.value;
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(4, (i) {
                              final offset = (t + (i * 0.25)) % 1.0;
                              return Transform.translate(
                                offset: Offset((offset - 0.5) * 50, 0),
                                child: Container(
                                  width: 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    color: currentA > 2.0 ? AppColors.orangePrimary : AppColors.tealPrimary,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.tealPrimary.withValues(alpha: 0.5),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Resistor Obstacle
              _buildCircuitComponent(
                icon: Icons.tune_rounded,
                label: 'Ω Resistor Load',
                value: '${_varBValue.toStringAsFixed(1)} Ω',
                color: AppColors.orangePrimary,
                bgColor: AppColors.orangeLight,
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Flow Rate Status Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                  size: 13,
                  color: currentA > 2.5 ? AppColors.orangePrimary : AppColors.tealPrimary,
                ),
                const SizedBox(width: 5),
                Text(
                  'Flow Rate: ${currentA.toStringAsFixed(2)} A (${currentA > 3.0 ? "High Current" : (currentA > 1.0 ? "Moderate Flow" : "Low Current")})',
                  style: const TextStyle(
                    fontSize: 10.5,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
        boxShadow: glow
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.35),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 11.5,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormulaCalculationBar(double currentA) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.tealLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.tealBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.calculate_rounded, size: 15, color: AppColors.tealPrimary),
          const SizedBox(width: 6),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'I = V / R  =  ${_varAValue.toStringAsFixed(1)}V / ${_varBValue.toStringAsFixed(1)}Ω  =  ${_outputUnit.toLowerCase() == 'ma' ? currentA.toStringAsFixed(1) : currentA.toStringAsFixed(2)} $_outputUnit',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'monospace',
                  color: AppColors.tealPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: activeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  valueText,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'monospace',
                    color: activeColor,
                  ),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: activeColor,
              inactiveTrackColor: inactiveColor,
              thumbColor: activeColor,
              trackHeight: 3.5,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuidedScenarioBanner() {
    final s = _demoScenarios[_currentScenarioIndex];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.tealLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.tealBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              Text(
                s['title'] as String,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.tealPrimary,
                ),
              ),
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
          const SizedBox(height: 5),
          Text(
            s['desc'] as String,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoControls() {
    final isFirst = _currentScenarioIndex == 0;
    final isLast = _currentScenarioIndex == _demoScenarios.length - 1;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 560;

        if (isCompact) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: isFirst ? null : _prevScenario,
                      icon: const Icon(Icons.arrow_back_rounded, size: 14),
                      label: const Text('Previous', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                        side: const BorderSide(color: AppColors.cardBorder),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        backgroundColor: AppColors.surface,
                        disabledForegroundColor: AppColors.textMuted.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _restartDemo,
                      icon: const Icon(Icons.replay_rounded, size: 14),
                      label: const Text('Restart', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                        side: const BorderSide(color: AppColors.cardBorder),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        backgroundColor: AppColors.surfaceSecondary,
                        foregroundColor: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton.filledTonal(
                    tooltip: _isPlaying ? 'Pause Demo' : 'Play Demo',
                    onPressed: _toggleDemo,
                    icon: Icon(
                      _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      size: 18,
                      color: AppColors.tealPrimary,
                    ),
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(10),
                      backgroundColor: _isPlaying ? AppColors.tealLight : AppColors.surfaceSecondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: _isPlaying ? AppColors.tealPrimary : AppColors.cardBorder,
                          width: _isPlaying ? 1.5 : 1.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isLast ? _restartDemo : () => _nextScenario(),
                      icon: Icon(isLast ? Icons.check_circle_rounded : Icons.arrow_forward_rounded, size: 14),
                      label: Text(
                        isLast ? 'Restart' : 'Next',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.tealPrimary,
                        foregroundColor: AppColors.textLight,
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: isFirst ? null : _prevScenario,
                icon: const Icon(Icons.arrow_back_rounded, size: 14),
                label: const Text('Previous', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 4),
                  side: const BorderSide(color: AppColors.cardBorder),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: AppColors.surface,
                  disabledForegroundColor: AppColors.textMuted.withValues(alpha: 0.4),
                ),
              ),
            ),
            const SizedBox(width: 6),
            IconButton.filledTonal(
              tooltip: _isPlaying ? 'Pause Demo' : 'Play Demo',
              onPressed: _toggleDemo,
              icon: Icon(
                _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                size: 18,
                color: AppColors.tealPrimary,
              ),
              style: IconButton.styleFrom(
                padding: const EdgeInsets.all(10),
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
            const SizedBox(width: 6),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _restartDemo,
                icon: const Icon(Icons.replay_rounded, size: 14),
                label: const Text('Restart', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 4),
                  side: const BorderSide(color: AppColors.cardBorder),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: AppColors.surfaceSecondary,
                  foregroundColor: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: isLast ? _restartDemo : () => _nextScenario(),
                icon: Icon(isLast ? Icons.check_circle_rounded : Icons.arrow_forward_rounded, size: 14),
                label: Text(
                  isLast ? 'Restart' : 'Next',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.tealPrimary,
                  foregroundColor: AppColors.textLight,
                  padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWhyThisWorksCard() {
    return Container(
      padding: const EdgeInsets.all(18),
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
              Icon(Icons.lightbulb_rounded, size: 18, color: AppColors.tealPrimary),
              SizedBox(width: 8),
              Text(
                '💡 Key Idea',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _whyWorksText,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExperimentationCard() {
    return Container(
      padding: const EdgeInsets.all(18),
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
              Icon(Icons.help_outline_rounded, size: 18, color: AppColors.orangePrimary),
              SizedBox(width: 8),
              Text(
                'Experimentation Insight',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _experimentQuestion,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.orangePrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _experimentAnswer,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
