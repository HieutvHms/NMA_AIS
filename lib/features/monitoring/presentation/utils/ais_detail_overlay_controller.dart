import 'package:flutter/material.dart';
import '../../domain/entities/ais_target_entity.dart';
import '../widgets/ais_target_detail_sheet.dart';

/// Quản lý vòng đời `OverlayEntry` cho `AisTargetDetailSheet` trên `rootOverlay`.
/// Giúp panel chi tiết đè lên Bottom Navigation Bar nhưng không chặn thao tác kéo/zoom bản đồ.
class AisDetailOverlayController {
  OverlayEntry? _entry;
  AisTargetEntity? _currentTarget;

  void sync(
    BuildContext context, {
    required AisTargetEntity? target,
    required ValueChanged<AisTargetEntity> onCenterCamera,
    required VoidCallback onClose,
  }) {
    _currentTarget = target;
    if (target == null) {
      hide();
      return;
    }

    if (_entry != null) {
      _entry!.markNeedsBuild();
      return;
    }

    _entry = OverlayEntry(
      builder: (_) {
        final current = _currentTarget;
        if (current == null) return const SizedBox.shrink();

        return Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: TweenAnimationBuilder<Offset>(
            tween: Tween(begin: const Offset(0, 1), end: Offset.zero),
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            builder: (context, offset, child) {
              return FractionalTranslation(translation: offset, child: child);
            },
            child: Material(
              type: MaterialType.transparency,
              child: AisTargetDetailSheet(
                target: current,
                onCenterCamera: () => onCenterCamera(current),
                onClose: onClose,
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context, rootOverlay: true).insert(_entry!);
  }

  void hide() {
    _entry?.remove();
    _entry = null;
  }

  void dispose() {
    hide();
    _currentTarget = null;
  }
}
