import 'package:audio_client/presentation/components/customs_office_tree.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CustomsOfficeSelector extends StatefulWidget {
  final void Function(String id, String label)? onSelectionChanged;

  const CustomsOfficeSelector({
    super.key,
    this.onSelectionChanged
  });

  @override
  State<CustomsOfficeSelector> createState() => _CustomsOfficeSelectorState();
}

class _CustomsOfficeSelectorState extends State<CustomsOfficeSelector> {
  String? selectedLabel;
  String? selectedId;

  void _openTreeDialog() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => const CustomsOfficeTree(),
    );

    if (result != null) {
      setState(() {
        selectedLabel = result['label'];
        selectedId = result['id'];
      });
      if (widget.onSelectionChanged != null) {
        widget.onSelectionChanged!(result['label']!, result['id']!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _openTreeDialog,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context)!.placement,
          border: const OutlineInputBorder(),
        ),
        child: Text(
          selectedLabel ?? AppLocalizations.of(context)!.selectPlacement,
          style: TextStyle(
            color: selectedLabel == null ? Colors.grey : Colors.black87,
          ),
        ),
      ),
    );
  }
}
