import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meyaoo_new/src/global/global.dart';

Widget callOptionsContainer({
  required String image,
  void Function()? onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      height: 60,
      width: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            appColorBlack.withOpacity(0.14),
            const Color(0xFF666666).withOpacity(0),
          ],
          begin: Alignment.topRight,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: appbarColor.withOpacity(0.17),
        ),
        child: Image.asset(
          image,
          scale: 3.5,
        ),
      ).paddingAll(3),
    ),
  );
}
