import 'package:atfind/atgroups/utils/colors.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:at_common_flutter/at_common_flutter.dart';

class CustomTextStyles {
  CustomTextStyles._();
  static final CustomTextStyles _instance = CustomTextStyles._();
  factory CustomTextStyles() => _instance;

  TextStyle LIGHT_RED16 = TextStyle(
    color: AllColors().LIGHT_RED,
    fontSize: 16.toFont,
  );

  TextStyle LIGHT_RED12 = TextStyle(
    color: AllColors().LIGHT_RED,
    fontSize: 12.toFont,
  );

  TextStyle LIGHT_RED14 = TextStyle(
    color: AllColors().LIGHT_RED,
    fontSize: 14.toFont,
  );

  TextStyle LIGHT_RED18 = TextStyle(
    color: AllColors().LIGHT_RED,
    fontSize: 18.toFont,
  );

  TextStyle primaryBold18 = TextStyle(
    color: AllColors().Black,
    fontWeight: FontWeight.w700,
    fontSize: 18.toFont,
  );

  TextStyle primaryMedium14 = TextStyle(
    color: AllColors().DARK_GREY,
    fontSize: 14.toFont,
    fontWeight: FontWeight.w500,
  );

  TextStyle grey16 = TextStyle(color: AllColors().GREY, fontSize: 16.toFont);

  TextStyle grey14 = TextStyle(color: AllColors().GREY, fontSize: 14.toFont);
}
