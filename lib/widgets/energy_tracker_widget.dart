import 'package:flutter/material.dart';

class EnergyTrackerWidget extends StatefulWidget {
  final Function(int) onEnergyRecorded;

  const EnergyTrackerWidget({
    Key? key,
    required this.onEnergyRecorded,
  }) : super(key: key);

  @override
  State<EnergyTrackerWidget> createState() => _EnergyTrackerState();
}

class _EnergyTrackerState extends State<EnergyTrackerWidget> {
  int _currentEnergy = 50;
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Color _getEnergyColor(int level) {
    if (level <= 20) return Colors.red;
    if (level <= 40) return Colors.orange;
    if (level <= 60) return Colors.yellow;
    if (level <= 80) return Colors.lightGreen;
    return Colors.green;
  }

  String _getEnergyLabel(int level) {
    if (level <= 20) return 'Very Low';
    if (level <= 40) return 'Low';
    if (level <= 60) return 'Moderate';
    if (level <= 80) return 'High';
    return 'Very High';
  }

  void _recordEnergy() async {
    widget.onEnergyRecorded(_currentEnergy);
    _noteController.clear();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Energy level recorded: ${_getEnergyLabel(_currentEnergy)}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How\'s your energy right now?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            // Energy level display
            Center(
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _getEnergyColor(_currentEnergy).withAlpha(100),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$_currentEnergy',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _getEnergyLabel(_currentEnergy),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Slider
                  Slider(
                    value: _currentEnergy.toDouble(),
                    min: 1,
                    max: 100,
                    activeColor: _getEnergyColor(_currentEnergy),
                    onChanged: (value) {
                      setState(() {
                        _currentEnergy = value.toInt();
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Very Low'),
                      Text('Very High'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Note field
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                hintText: 'Add a note (optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.note),
              ),
              maxLines: null,
            ),
            const SizedBox(height: 16),
            // Record button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _recordEnergy,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: _getEnergyColor(_currentEnergy),
                ),
                child: const Text(
                  'Record Energy Level',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
