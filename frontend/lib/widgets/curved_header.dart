import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class CurvedHeader extends StatelessWidget {
  final String title;
  final bool showBack;

  const CurvedHeader({
    super.key,
    this.title = 'Welcome to the Health App!',
    this.showBack = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        ClipPath(
          clipper: TopCurveClipper(),
          child: Container(
            height: size.height * 0.25,
            width: double.infinity,
            color: AppColors.softGrey,
            alignment: Alignment.center,
            child: Text(
              title,
              style: AppTextStyles.welcomeHeader,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        if (showBack)
          const SafeArea(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: BackButton(color: AppColors.primaryRed),
            ),
          ),
      ],
    );
  }
}



class TopCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.75);
    path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height * 0.75);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
