import 'package:flutter/material.dart';
import 'package:solartide/core/theme/app_palette.dart';
import 'package:solartide/core/theme/app_tokens.dart';
import 'package:solartide/core/utils/responsive.dart';

/// Tells a [SubPage] it is shown in a dashboard panel rather than pushed, and
/// how to close it (STYLE_GUIDE §6.3).
class DetailPanelScope extends InheritedWidget {
  const DetailPanelScope({super.key, required this.onClose, required super.child});

  final VoidCallback onClose;

  static DetailPanelScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<DetailPanelScope>();

  @override
  bool updateShouldNotify(DetailPanelScope oldWidget) => oldWidget.onClose != onClose;
}

/// Closes a detail page after its action: clears the panel on the dashboard,
/// pops the page on a phone.
Future<void> closeSubPage(BuildContext context) async {
  final scope = DetailPanelScope.maybeOf(context);
  if (scope != null) {
    scope.onClose();
  } else {
    await Navigator.of(context).maybePop();
  }
}

/// A list with its detail (STYLE_GUIDE §6.3). On a large layout the detail is
/// a panel beside the list; on an expanded one it takes the list's place
/// until closed. [detail] is a page built from [SubPage].
class MasterDetail extends StatelessWidget {
  const MasterDetail({super.key, required this.master, required this.detail, required this.onClose});

  final Widget master;
  final Widget? detail;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final detail = this.detail;
    if (detail == null) return master;
    final panel = DetailPanelScope(
      onClose: onClose,
      child: _Panel(child: detail),
    );
    if (!context.hasSidePanel) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(AppSpace.screenH, AppSpace.xl, AppSpace.screenH, AppSpace.lg),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppBreakpoint.mediumMaxContent),
            child: panel,
          ),
        ),
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: master),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, AppSpace.xl, AppSpace.screenH, AppSpace.lg),
          child: SizedBox(width: AppSize.detailPanel, child: panel),
        ),
      ],
    );
  }
}

/// Canvas-toned with a hairline border, so the content cards inside keep
/// their own tone. Flat, no shadow (§1, §4).
class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: p.scaffold,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: p.border),
      ),
      child: child,
    );
  }
}
