import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum DTextFieldType { text, dropdown }

class DTextFieldConfig {
  final String hintText;
  final Widget? leftView;
  final Widget? rightView;
  final ValueChanged<String>? onTextChanged;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool isDisabled;
  final bool obscureText;
  final RegExp? regex;
  final String? errorText;
  final bool autofocus;
  final List<String>? dropdownItems;
  final DTextFieldType type;
  final bool isUpperCase;

  DTextFieldConfig({
    required this.hintText,
    required this.controller,
    this.leftView,
    this.rightView,
    this.onTextChanged,
    this.keyboardType = TextInputType.text,
    this.isDisabled = false,
    this.obscureText = false,
    this.regex,
    this.errorText,
    this.autofocus = false,
    this.type = DTextFieldType.text,
    this.dropdownItems,
    this.isUpperCase = false,
  });
}

class DTextField extends StatefulWidget {
  final DTextFieldConfig config;
  final VoidCallback? onAppear;

  const DTextField({super.key, required this.config, this.onAppear = null});

  @override
  State<DTextField> createState() => DTextFieldState();
}

class DTextFieldState extends State<DTextField> {
  late FocusNode _focusNode;
  String? _localErrorText;
  String? selectedDropdownValue;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.onAppear != null) {
        widget.onAppear!();
      }
    });
    _focusNode = FocusNode();
    widget.config.controller.addListener(_validate);
    _focusNode.addListener(() {
      setState(() {});
    });

    if (widget.config.dropdownItems != null &&
        widget.config.dropdownItems!.isNotEmpty) {
      final existingValue = widget.config.controller.text;

      if (widget.config.dropdownItems!.contains(existingValue)) {
        selectedDropdownValue = existingValue;
      } else {
        selectedDropdownValue = null;
        // selectedDropdownValue = widget.config.dropdownItems!.first;
        // widget.config.controller.text = selectedDropdownValue!;
      }
    } else {
      selectedDropdownValue = null;
    }
  }

  void _validate() {
    final text = widget.config.controller.text;
    if (text.isEmpty) {
      selectedDropdownValue = null;
    } else {
      selectedDropdownValue = text;
    }
    String? error;
    if (widget.config.regex != null &&
        widget.config.errorText != null &&
        text.isNotEmpty &&
        (!widget.config.regex!.hasMatch(text))) {
      error = widget.config.errorText;
    } else {
      error = null;
    }

    if (_localErrorText != error) {
      setState(() {
        _localErrorText = error;
      });
    }
  }

  @override
  void dispose() {
    widget.config.controller.removeListener(_validate);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inputDecoration = InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      border: OutlineInputBorder(),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey, width: 1.0),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black, width: 2.0),
        borderRadius: BorderRadius.circular(12),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: _localErrorText == null ? Colors.grey : Colors.red,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      disabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey, width: 1.0),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: _localErrorText == null ? Colors.black : Colors.red,
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      labelText: widget.config.hintText,
      errorText: _localErrorText,
      errorStyle: TextStyle().copyWith(
        color: _localErrorText != null ? Colors.red : Colors.grey,
        fontSize: _localErrorText != null ? 12 : 0,
      ),
      prefixIcon: (widget.config.leftView != null)
          ? Padding(
              padding: const EdgeInsets.only(right: 8),
              child: widget.config.leftView!,
            )
          : null,
      suffixIcon: (widget.config.rightView != null)
          ? Padding(
              padding: const EdgeInsets.only(left: 8),
              child: widget.config.rightView!,
            )
          : null,
      labelStyle: TextStyle().copyWith(
        color: _localErrorText != null
            ? Colors.red
            : _focusNode.hasFocus
            ? Colors.black
            : Colors.grey,
      ),
    );

    return Container(
      child:
          widget.config.dropdownItems != null &&
              widget.config.type == DTextFieldType.dropdown
          ? DropdownButtonFormField<String>(
              isExpanded: true,
              value: selectedDropdownValue,
              onChanged: widget.config.isDisabled
                  ? null
                  : (value) {
                      if (value != null &&
                          widget.config.dropdownItems!.contains(value)) {
                        setState(() {
                          selectedDropdownValue = value;
                          widget.config.controller.text = value;
                        });
                        widget.config.onTextChanged?.call(value);
                      }
                    },
              items: (widget.config.dropdownItems ?? [])
                  .toSet()
                  .map(
                    (item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    ),
                  )
                  .toList(),
              dropdownColor: Colors.grey[50],
              decoration: inputDecoration,
              validator: (value) {
                _validate();
                if (value == null)
                  return widget.config.errorText ?? 'This field is required';
                if (widget.config.regex != null &&
                    !widget.config.regex!.hasMatch(value)) {
                  return widget.config.errorText;
                }
                return null;
              },
            )
          : TextFormField(
              autofocus: widget.config.autofocus,
              obscureText: widget.config.obscureText,
              focusNode: _focusNode,
              controller: widget.config.controller,
              keyboardType: widget.config.keyboardType,
              autocorrect: false,
              enabled: !widget.config.isDisabled,
              onChanged: widget.config.onTextChanged,
              inputFormatters: widget.config.isUpperCase
                  ? [
                      TextInputFormatter.withFunction((oldValue, newValue) {
                        return newValue.copyWith(
                          text: newValue.text.toUpperCase(),
                          selection: newValue.selection,
                        );
                      }),
                    ]
                  : null,
              validator: (value) {
                _validate();
                if (value == null) return null;
                if (widget.config.regex != null &&
                    !widget.config.regex!.hasMatch(value)) {
                  return widget.config.errorText;
                }
                return null;
              },
              decoration: inputDecoration,
            ),
    );
  }
}
