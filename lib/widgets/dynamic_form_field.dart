import 'package:flutter/material.dart';

class DynamicFormField extends StatelessWidget {
  final int index;
  final VoidCallback onRemove;
  final Function(String?) onSave;

  const DynamicFormField({
    super.key,
    required this.index,
    required this.onRemove,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            decoration: InputDecoration(labelText: 'Item ${index + 1}'),
            onSaved: onSave,
          ),
        ),
        IconButton(
          onPressed: onRemove,
          icon: const Icon(Icons.remove_circle),
        ),
      ],
    );
  }
}
