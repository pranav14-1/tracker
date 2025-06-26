import 'package:flutter/material.dart';

class PasswordLogin extends StatefulWidget {
  final TextEditingController password;
  final FocusNode passwordNode;
  final String labelledText;

  const PasswordLogin({
    super.key,
    required this.password,
    required this.passwordNode,
    required this.labelledText,
  });

  @override
  State<PasswordLogin> createState() => _PasswordLoginState();
}

class _PasswordLoginState extends State<PasswordLogin> {
  bool _obscurePassword = true;
  bool _isPasswordFocused = false;

  @override
  void initState() {
    super.initState();
    widget.passwordNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    setState(() {
      _isPasswordFocused = widget.passwordNode.hasFocus;
    });
  }

  @override
  void dispose() {
    widget.passwordNode.removeListener(_handleFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.password,
      focusNode: widget.passwordNode,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: widget.labelledText,
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        suffixIcon:
            _isPasswordFocused
                ? IconButton(
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                )
                : null,
      ),
    );
  }
}
