import 'package:flutter/material.dart';
import 'package:plantify/theme/color.dart';

class LoginTextfield extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String? errorText;
  final Function(String)? onChanged;
  final bool isPassword;

  const LoginTextfield({
    super.key,
    required this.controller,
    required this.hintText,
    this.errorText,
    this.onChanged,
    this.isPassword = false,
  });

  @override
  State<LoginTextfield> createState() => _LoginTextfieldState();
}

class _LoginTextfieldState extends State<LoginTextfield> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      keyboardType: TextInputType.emailAddress,
      onChanged: widget.onChanged,
      obscureText: widget.isPassword ? _obscure : false,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(color: Color(MyColor.pr3)),
        errorText: widget.errorText,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        isDense: true,
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_off : Icons.visibility,
                  color: Color(MyColor.pr3),
                ),
                onPressed: () {
                  setState(() {
                    _obscure = !_obscure;
                  });
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: widget.errorText != null ? Colors.red : Color(MyColor.pr2),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: widget.errorText != null ? Colors.red : Color(MyColor.pr2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: widget.errorText != null ? Colors.red : Color(MyColor.pr2),
          ),
        ),
      ),
    );
  }
}
