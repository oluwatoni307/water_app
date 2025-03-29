import 'package:flutter/material.dart';

class NewDialog extends StatelessWidget {
  final TextEditingController _metricController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final Function(String, int) onMetricAdded;

  NewDialog({super.key, required this.onMetricAdded});

  @override
  Widget build(BuildContext context) {
    // Define the primary color explicitly
    final Color primaryColor = Color(0xFF369FFF);

    return Container(
      padding: const EdgeInsets.all(24.0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Add New Metric',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                  letterSpacing: 0.5,
                ),
              ),
              Material(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(30),
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () => Navigator.pop(context),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.close_rounded,
                      color: Colors.grey.shade700,
                      size: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Divider(color: Colors.grey.shade200, thickness: 1),
          const SizedBox(height: 16),
          _buildInputField(
            controller: _metricController,
            label: "Metric Name",
            hint: "Enter metric name",
            icon: Icons.label_outline,
            context: context,
            primaryColor: primaryColor,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: _quantityController,
            label: "Water Quantity",
            hint: "Enter quantity in liters",
            icon: Icons.water_drop_outlined,
            keyboardType: TextInputType.number,
            context: context,
            primaryColor: primaryColor,
          ),
          const SizedBox(height: 30),
          Center(
            child: ElevatedButton(
                onPressed: () {
                  String metricName = _metricController.text;
                  int waterQuantity =
                      int.tryParse(_quantityController.text) ?? 0;
                  onMetricAdded(metricName, waterQuantity);

                  Navigator.pop(context);
                },
                child: Text(
                  "Submit",
                  style: TextStyle(color: Colors.black),
                )),
          )
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required BuildContext context,
    required Color primaryColor,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              prefixIcon: Icon(icon, color: primaryColor.withOpacity(0.7)),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            keyboardType: keyboardType,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade800),
          ),
        ),
      ],
    );
  }

  Widget _buildButton({
    required String label,
    required VoidCallback onPressed,
    required Color backgroundColor,
    required Color textColor,
    required BuildContext context,
    bool hasBorder = false,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        elevation: backgroundColor == Colors.transparent ? 0 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: hasBorder
              ? BorderSide(color: Colors.grey.shade300)
              : BorderSide.none,
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
