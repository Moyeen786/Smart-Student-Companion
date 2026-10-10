import 'package:flutter/material.dart';
import 'package:smart_student_companion/core/theme/app_colors.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffix,
    this.validator,
<<<<<<< HEAD
    this.onChanged,
=======
    this.onSubmitted,
>>>>>>> 5125038e8e0da1c8cf022d7aa913103fbdee7df2
  });

  final String label;
  final TextEditingController controller;
  final String? hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final IconData? prefixIcon;
  final Widget? suffix;
  final String? Function(String?)? validator;
<<<<<<< HEAD
  final ValueChanged<String>? onChanged;
=======
  final ValueChanged<String>? onSubmitted;
>>>>>>> 5125038e8e0da1c8cf022d7aa913103fbdee7df2

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
<<<<<<< HEAD
      onChanged: onChanged,
=======
      textInputAction: TextInputAction.done,
      onFieldSubmitted: onSubmitted,
>>>>>>> 5125038e8e0da1c8cf022d7aa913103fbdee7df2
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppColors.primary)
            : null,
        suffixIcon: suffix,
      ),
    );
  }
}
