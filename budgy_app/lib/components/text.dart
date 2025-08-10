import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppText extends StatelessWidget {
  final String text;
  final String size;
  final Color color;
  final bool isBold;
  final bool isJustify;
  final bool isCenter;
  final bool isUpper;
  final TextOverflow? overflow;

  const AppText({
    super.key,
    required this.text,
    required this.size,
    required this.color,
    this.isBold = false,
    this.isJustify = false,
    this.isCenter = false,
    this.isUpper = false,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      isUpper ? text.toUpperCase() : text,
      textAlign: isJustify ? TextAlign.justify : (isCenter ? TextAlign.center : TextAlign.left),
      style: GoogleFonts.poppins(
        fontSize: size == "xxxlarge"
            ? 40
            : size == "xxlarge"
                ? 30
                : size == "xlarge"
                    ? 22
                    : size == "large"
                        ? 20
                        : size == "medium"
                            ? 16
                            : size == "small"
                                ? 14
                                : size == "xsmall"
                                    ? 12
                                    : 1,
        color: color,
        fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}
