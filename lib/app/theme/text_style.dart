import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Custom text styles for the app
class AppTextStyles {
  AppTextStyles._();

  // Headline styles
  static TextStyle headlineLarge() {
    return GoogleFonts.inter(fontSize: 32.sp, fontWeight: FontWeight.w600);
  }

  static TextStyle headlineMedium() {
    return GoogleFonts.inter(fontSize: 28.sp, fontWeight: FontWeight.w600);
  }

  static TextStyle headlineSmall() {
    return GoogleFonts.inter(fontSize: 24.sp, fontWeight: FontWeight.w600);
  }

  static TextStyle headlineSmall2({Color? color}) {
    return GoogleFonts.inter(
      fontSize: 24.sp,
      fontWeight: FontWeight.w500,
      color: color,
    );
  }

  // Title styles
  static TextStyle titleLarge({Color? color}) {
    return GoogleFonts.inter(
      fontSize: 22.sp,
      fontWeight: FontWeight.w600,
      color: color,
    );
  }

  static TextStyle titleMediumIcon() {
    return GoogleFonts.inter(
      fontSize: 19.sp,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
    );
  }

  // ===========================================================================
  // Hệ thống TextStyle chuẩn theo Size (10 -> 18) & FontWeight (400, 500, 600)
  // ===========================================================================

  // --- Size 10 ---
  static TextStyle s10w400({Color? color, double? height}) => GoogleFonts.inter(
    fontSize: 10.sp,
    fontWeight: FontWeight.w400,
    color: color ?? AppColors.textPrimary,
    height: height,
  );

  static TextStyle s10w500({Color? color, double? height}) => GoogleFonts.inter(
    fontSize: 10.sp,
    fontWeight: FontWeight.w500,
    color: color ?? AppColors.textPrimary,
    height: height,
  );

  static TextStyle s10w600({Color? color, double? height}) => GoogleFonts.inter(
    fontSize: 10.sp,
    fontWeight: FontWeight.w600,
    color: color ?? AppColors.textPrimary,
    height: height,
  );

  // --- Size 11 ---
  static TextStyle s11w400({Color? color, double? height}) => GoogleFonts.inter(
    fontSize: 11.sp,
    fontWeight: FontWeight.w400,
    color: color ?? AppColors.textPrimary,
    height: height,
  );

  static TextStyle s11w500({Color? color, double? height}) => GoogleFonts.inter(
    fontSize: 11.sp,
    fontWeight: FontWeight.w500,
    color: color ?? AppColors.textPrimary,
    height: height,
  );

  static TextStyle s11w600({Color? color, double? height}) => GoogleFonts.inter(
    fontSize: 11.sp,
    fontWeight: FontWeight.w600,
    color: color ?? AppColors.textPrimary,
    height: height,
  );

  // --- Size 12 ---
  static TextStyle s12w400({Color? color, double? height}) => GoogleFonts.inter(
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    color: color ?? AppColors.textPrimary,
    height: height,
  );

  static TextStyle s12w500({Color? color, double? height}) => GoogleFonts.inter(
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
    color: color ?? AppColors.textPrimary,
    height: height,
  );

  static TextStyle s12w600({Color? color, double? height}) => GoogleFonts.inter(
    fontSize: 12.sp,
    fontWeight: FontWeight.w600,
    color: color ?? AppColors.textPrimary,
    height: height,
  );

  // --- Size 13 ---
  static TextStyle s13w400({Color? color, double? height}) => GoogleFonts.inter(
    fontSize: 13.sp,
    fontWeight: FontWeight.w400,
    color: color ?? AppColors.textPrimary,
    height: height,
  );

  static TextStyle s13w500({Color? color, double? height}) => GoogleFonts.inter(
    fontSize: 13.sp,
    fontWeight: FontWeight.w500,
    color: color ?? AppColors.textPrimary,
    height: height,
  );

  static TextStyle s13w600({Color? color, double? height}) => GoogleFonts.inter(
    fontSize: 13.sp,
    fontWeight: FontWeight.w600,
    color: color ?? AppColors.textPrimary,
    height: height,
  );

  // --- Size 14 ---
  static TextStyle s14w400({Color? color, double? height}) => GoogleFonts.inter(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    color: color ?? AppColors.textPrimary,
    height: height,
  );

  static TextStyle s14w500({Color? color, double? height}) => GoogleFonts.inter(
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    color: color ?? AppColors.textPrimary,
    height: height,
  );

  static TextStyle s14w600({Color? color, double? height}) => GoogleFonts.inter(
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    color: color ?? AppColors.textPrimary,
    height: height,
  );

  // --- Size 15 ---
  static TextStyle s15w400({Color? color, double? height}) => GoogleFonts.inter(
    fontSize: 15.sp,
    fontWeight: FontWeight.w400,
    color: color ?? AppColors.textPrimary,
    height: height,
  );

  static TextStyle s15w500({Color? color, double? height}) => GoogleFonts.inter(
    fontSize: 15.sp,
    fontWeight: FontWeight.w500,
    color: color ?? AppColors.textPrimary,
    height: height,
  );

  static TextStyle s15w600({Color? color, double? height}) => GoogleFonts.inter(
    fontSize: 15.sp,
    fontWeight: FontWeight.w600,
    color: color ?? AppColors.textPrimary,
    height: height,
  );

  // --- Size 16 ---
  static TextStyle s16w400({Color? color, double? height}) => GoogleFonts.inter(
    fontSize: 16.sp,
    fontWeight: FontWeight.w400,
    color: color ?? AppColors.textPrimary,
    height: height,
  );

  static TextStyle s16w500({Color? color, double? height}) => GoogleFonts.inter(
    fontSize: 16.sp,
    fontWeight: FontWeight.w500,
    color: color ?? AppColors.textPrimary,
    height: height,
  );

  static TextStyle s16w600({Color? color, double? height}) => GoogleFonts.inter(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    color: color ?? AppColors.textPrimary,
    height: height,
  );

  // --- Size 17 ---
  static TextStyle s17w400({Color? color, double? height}) => GoogleFonts.inter(
    fontSize: 17.sp,
    fontWeight: FontWeight.w400,
    color: color ?? AppColors.textPrimary,
    height: height,
  );

  static TextStyle s17w500({Color? color, double? height}) => GoogleFonts.inter(
    fontSize: 17.sp,
    fontWeight: FontWeight.w500,
    color: color ?? AppColors.textPrimary,
    height: height,
  );

  static TextStyle s17w600({Color? color, double? height}) => GoogleFonts.inter(
    fontSize: 17.sp,
    fontWeight: FontWeight.w600,
    color: color ?? AppColors.textPrimary,
    height: height,
  );

  // --- Size 18 ---
  static TextStyle s18w400({Color? color, double? height}) => GoogleFonts.inter(
    fontSize: 18.sp,
    fontWeight: FontWeight.w400,
    color: color ?? AppColors.textPrimary,
    height: height,
  );

  static TextStyle s18w500({Color? color, double? height}) => GoogleFonts.inter(
    fontSize: 18.sp,
    fontWeight: FontWeight.w500,
    color: color ?? AppColors.textPrimary,
    height: height,
  );

  static TextStyle s18w600({Color? color, double? height}) => GoogleFonts.inter(
    fontSize: 18.sp,
    fontWeight: FontWeight.w600,
    color: color ?? AppColors.textPrimary,
    height: height,
  );
}
