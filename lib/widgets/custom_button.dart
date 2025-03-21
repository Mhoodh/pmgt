import 'package:flutter/material.dart';
import '../utils/constants.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isPrimary;
  final bool isFullWidth;
  final IconData? icon;
  final double height;
  final double? width;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? textColor;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isPrimary = true,
    this.isFullWidth = true,
    this.icon,
    this.height = AppDimensions.buttonHeight,
    this.width,
    this.borderRadius = AppDimensions.radiusL,
    this.backgroundColor,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color bgColor = backgroundColor ?? 
        (isPrimary ? AppColors.primaryColor : Colors.transparent);
    
    final Color txtColor = textColor ?? 
        (isPrimary ? Colors.white : AppColors.primaryColor);
    
    return SizedBox(
      height: height,
      width: isFullWidth ? double.infinity : width,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: txtColor,
          elevation: isPrimary ? 2 : 0,
          shadowColor: isPrimary ? AppColors.shadowColor : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: isPrimary 
                ? BorderSide.none 
                : BorderSide(color: AppColors.primaryColor),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
        ),
        child: isLoading 
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isPrimary ? Colors.white : AppColors.primaryColor,
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    SizedBox(width: AppDimensions.paddingS),
                  ],
                  Text(
                    text,
                    style: AppTextStyles.button.copyWith(
                      color: txtColor,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// زر أيقونة دائري
class CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final double iconSize;
  final String? tooltip;

  const CircleIconButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = 40.0,
    this.iconSize = 20.0,
    this.tooltip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(size / 2),
        child: Ink(
          decoration: BoxDecoration(
            color: backgroundColor ?? AppColors.surfaceColor,
            shape: BoxShape.circle,
          ),
          child: Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: iconSize,
              color: iconColor ?? AppColors.primaryColor,
            ),
          ),
        ),
      ),
    );
  }
}