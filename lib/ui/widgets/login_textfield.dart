import 'package:flutter/material.dart';

class LoginTextfield extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData prefixIcon;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Color? bgColor;
  final Color? borderColor;
  final Color? labelColor;
  final Color? iconColor;

  const LoginTextfield({
    super.key,
    required this.controller,
    required this.labelText,
    required this.prefixIcon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.bgColor,
    this.borderColor,
    this.labelColor,
    this.iconColor,
  });

  @override
  State<LoginTextfield> createState() => _LoginTextfieldState();
}

class _LoginTextfieldState extends State<LoginTextfield>
    with SingleTickerProviderStateMixin {
  bool isPasswordHidden = true;

  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scale = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(20),
    borderSide: BorderSide(color: color, width: 1),
  );

  @override
  Widget build(BuildContext context) {
    final Color fill = widget.bgColor ?? Colors.white;
    final Color border = widget.borderColor ?? Colors.grey;
    final Color label = widget.labelColor ?? Colors.grey.shade700;
    final Color icon = widget.iconColor ?? Colors.blueGrey;

    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 5,
                offset: const Offset(0, 10),
              ),
            ],borderRadius: BorderRadius.circular(20)
          ),
          child: TextFormField(
            cursorColor: Colors.blue.shade300,
            controller: widget.controller,
            keyboardType: widget.keyboardType,
            validator: widget.validator,
            obscureText: widget.isPassword ? isPasswordHidden : false,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              labelText: widget.labelText,
              labelStyle: TextStyle(color: label, fontWeight: FontWeight.w500),
              filled: true,
              fillColor: fill,
              prefixIcon: Icon(widget.prefixIcon, color: icon),
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        isPasswordHidden
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        color: icon,
                      ),
                      onPressed: () {
                        setState(() {
                          isPasswordHidden = !isPasswordHidden;
                        });
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
              enabledBorder: _border(border),
              focusedBorder: _border(Colors.blue.shade300),
              errorBorder: _border(Colors.red.shade400),
              focusedErrorBorder: _border(Colors.redAccent),
            ),
          ),
        ),
      ),
    );
  }
}
