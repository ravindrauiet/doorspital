// // lib/custom_text_field.dart

// import 'package:flutter/material.dart';

// class CustomTextFormField extends StatefulWidget {
//   final String hintText;
//   final IconData icon;
//   final bool isPassword;
//   final TextEditingController? controller;
//   final FormFieldValidator<String>? validator;
//   final TextInputType? keyboardType;
//   final TextInputAction? textInputAction;

//   const CustomTextFormField({
//     super.key,
//     required this.hintText,
//     required this.icon,
//     this.isPassword = false,
//     this.controller,
//     this.validator,
//     this.keyboardType,
//     this.textInputAction,
//   });

//   @override
//   State<CustomTextFormField> createState() => _CustomTextFormFieldState();
// }

// class _CustomTextFormFieldState extends State<CustomTextFormField> {
//   bool _obscureText = true;

//   @override
//   Widget build(BuildContext context) {
//     return TextFormField(
//       controller: widget.controller,
//       validator: widget.validator,
//       keyboardType: widget.keyboardType,
//       textInputAction: widget.textInputAction,
//       obscureText: widget.isPassword ? _obscureText : false,
//       decoration: InputDecoration(
//         hintText: widget.hintText,
//         hintStyle: const TextStyle(color: Color(0xFF959595)),
//         prefixIcon: Icon(widget.icon, color: const Color(0xFF959595)),
//         suffixIcon: widget.isPassword
//             ? IconButton(
//                 icon: Icon(
//                   _obscureText
//                       ? Icons.visibility_off_outlined
//                       : Icons.visibility_outlined,
//                   color: const Color(0xFF959595),
//                 ),
//                 onPressed: () {
//                   setState(() {
//                     _obscureText = !_obscureText;
//                   });
//                 },
//               )
//             : null,
//         filled: true,
//         fillColor: Colors.white,
//         contentPadding: const EdgeInsets.all(16),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: Color(0xFFE8E8E8), width: 1),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: Color(0xFF3669F5), width: 1),
//         ),
//       ),
//     );
//   }
// }
