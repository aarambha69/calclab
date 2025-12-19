import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gap/gap.dart';
import 'dart:math';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../data/models/emi_plan.dart';
import '../providers/emi_provider.dart';
import 'saved_emi_plans_screen.dart';

class EmiCalculatorScreen extends ConsumerStatefulWidget {
  const EmiCalculatorScreen({super.key});

  @override
  ConsumerState<EmiCalculatorScreen> createState() =>
      _EmiCalculatorScreenState();
}

class _EmiCalculatorScreenState extends ConsumerState<EmiCalculatorScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _tenureController = TextEditingController();

  double _emi = 0.0;
  double _totalInterest = 0.0;
  double _totalPayment = 0.0;

  bool _isYearly = true;

  @override
  void dispose() {
    _amountController.dispose();
    _rateController.dispose();
    _tenureController.dispose();
    super.dispose();
  }

  void _calculate() {
    final double amount = double.tryParse(_amountController.text) ?? 0.0;
    final double rate = double.tryParse(_rateController.text) ?? 0.0;
    final double tenure = double.tryParse(_tenureController.text) ?? 0.0;

    if (amount <= 0 || rate <= 0 || tenure <= 0) return;

    final double monthlyRate = rate / 12 / 100;
    final double months = _isYearly ? tenure * 12 : tenure;

    final double emi =
        (amount * monthlyRate * pow(1 + monthlyRate, months)) /
        (pow(1 + monthlyRate, months) - 1);

    final double totalPayment = emi * months;
    final double totalInterest = totalPayment - amount;

    setState(() {
      _emi = emi;
      _totalPayment = totalPayment;
      _totalInterest = totalInterest;
    });
  }

  Future<void> _savePlan() async {
    final nameController = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Plan'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Plan Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, nameController.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (name != null && name.isNotEmpty) {
      final plan = EmiPlan.create(
        name: name,
        amount: double.tryParse(_amountController.text) ?? 0,
        rate: double.tryParse(_rateController.text) ?? 0,
        tenure: double.tryParse(_tenureController.text) ?? 0,
        isYearly: _isYearly,
      );
      await ref.read(emiPlansProvider.notifier).addPlan(plan);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Plan Saved!')));
      }
    }
  }

  Future<void> _generatePdf() async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.nunitoExtraLight();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              children: [
                pw.Text(
                  'EMI Calculation Report',
                  style: pw.TextStyle(font: font, fontSize: 24),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Principal Amount: ${_amountController.text}',
                  style: pw.TextStyle(font: font, fontSize: 18),
                ),
                pw.Text(
                  'Interest Rate: ${_rateController.text}%',
                  style: pw.TextStyle(font: font, fontSize: 18),
                ),
                pw.Text(
                  'Tenure: ${_tenureController.text} ${_isYearly ? 'Years' : 'Months'}',
                  style: pw.TextStyle(font: font, fontSize: 18),
                ),
                pw.SizedBox(height: 20),
                pw.Divider(),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Monthly EMI: ${_emi.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'Total Interest: ${_totalInterest.toStringAsFixed(2)}',
                  style: pw.TextStyle(font: font, fontSize: 18),
                ),
                pw.Text(
                  'Total Payment: ${_totalPayment.toStringAsFixed(2)}',
                  style: pw.TextStyle(font: font, fontSize: 18),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  void _openSavedPlans() async {
    final EmiPlan? selectedPlan = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SavedEmiPlansScreen()),
    );

    if (selectedPlan != null) {
      setState(() {
        _amountController.text = selectedPlan.amount.toString();
        _rateController.text = selectedPlan.rate.toString();
        _tenureController.text = selectedPlan.tenure.toString();
        _isYearly = selectedPlan.isYearly;
      });
      _calculate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Listen for selected plan from Dashboard/Saved Plans
    ref.listen<EmiPlan?>(selectedEmiPlanProvider, (previous, next) {
      if (next != null) {
        _amountController.text = next.amount.toString();
        _rateController.text = next.rate.toString();
        _tenureController.text = next.tenure.toString();
        setState(() {
          _isYearly = next.isYearly;
        });
        _calculate();
        // Clear the selection after loading
        Future.microtask(() {
          ref.read(selectedEmiPlanProvider.notifier).state = null;
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'EMI Calculator',
        ), // Since it's inside HomeScreen normally, this might hide if not careful.
        // But HomeScreen sets the title.
        // Wait, HomeScreen has `_screens` which are widgets. The AppBar is in HomeScreen.
        // So I CANNOT add AppBar here if I am inside HomeScreen body.
        // BUT I can add a Row/Toolbar inside the body OR use a sliver.
        // Or I can add Floating Action Button?
        // Or I can just put icons in the top row.
        // Let's assume for now I put a row of buttons at the top of the body.
        toolbarHeight: 0, // Hide inherent app bar if Scaffold is used
      ),
      // Actually, since HomeScreen provides Scaffold, I should probably return a Column/ListView directly, NOT a Scaffold.
      // But if I need FloatingActionButton or SnackBar context...
      // The previous code returned `SingleChildScrollView`.
      // Let's stick to returning the content widget, but I'll add a Row for actions at the top.
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Toolbar
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton.filledTonal(
                  onPressed: _openSavedPlans,
                  icon: const Icon(Icons.folder_open),
                  tooltip: 'Saved Plans',
                ),
                const Gap(8),
                IconButton.filledTonal(
                  onPressed: _emi > 0 ? _savePlan : null,
                  icon: const Icon(Icons.save_outlined),
                  tooltip: 'Save',
                ),
                const Gap(8),
                IconButton.filledTonal(
                  onPressed: _emi > 0 ? _generatePdf : null,
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  tooltip: 'Export PDF',
                ),
              ],
            ),
            const Gap(16),

            // Inputs
            Card(
              elevation: 0,
              color: colorScheme.surfaceContainer,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Principal Amount',
                        prefixIcon: Padding(
                          padding: EdgeInsets.all(12),
                          child: Text(
                            'NPR',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const Gap(16),
                    TextField(
                      controller: _rateController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Interest Rate (%)',
                        prefixIcon: Icon(Icons.percent),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const Gap(16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _tenureController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Tenure',
                              prefixIcon: Icon(Icons.calendar_today),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const Gap(8),
                        ToggleButtons(
                          isSelected: [_isYearly, !_isYearly],
                          onPressed: (index) {
                            setState(() {
                              _isYearly = index == 0;
                            });
                          },
                          children: const [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text('Yr'),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text('Mo'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Gap(24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _calculate,
                        child: const Text('Calculate'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Gap(24),

            // Results
            if (_emi > 0) ...[
              Card(
                elevation: 0,
                color: colorScheme.secondaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Monthly EMI',
                        style: TextStyle(
                          color: colorScheme.onSecondaryContainer,
                        ),
                      ),
                      Text(
                        _emi.toStringAsFixed(2),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Interest'),
                          Text(_totalInterest.toStringAsFixed(2)),
                        ],
                      ),
                      const Gap(8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Amount'),
                          Text(_totalPayment.toStringAsFixed(2)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const Gap(24),

              // Chart
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 0,
                    centerSpaceRadius: 40,
                    sections: [
                      PieChartSectionData(
                        color: colorScheme.primary,
                        value: double.tryParse(_amountController.text) ?? 0,
                        title: 'Principal',
                        radius: 50,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      PieChartSectionData(
                        color: colorScheme.error,
                        value: _totalInterest,
                        title: 'Interest',
                        radius: 50,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Gap(8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: 12, height: 12, color: colorScheme.primary),
                  const SizedBox(width: 4),
                  const Text('Principal'),
                  const SizedBox(width: 16),
                  Container(width: 12, height: 12, color: colorScheme.error),
                  const SizedBox(width: 4),
                  const Text('Interest'),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
