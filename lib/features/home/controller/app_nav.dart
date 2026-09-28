import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:solartide/core/utils/responsive.dart';

/// Bottom nav on a phone, rail on a wide layout (STYLE_GUIDE §5.9, §6.3).
enum AppTab { home, quotes, clients, settings }

/// What the wide layout shows in its detail panel.
sealed class DetailSelection {
  const DetailSelection();
}

class QuoteSelection extends DetailSelection {
  const QuoteSelection(this.quoteId);
  final String quoteId;
}

class ClientSelection extends DetailSelection {
  const ClientSelection(this.clientId);
  final String clientId;
}

class BusinessSelection extends DetailSelection {
  const BusinessSelection();
}

class CatalogueSelection extends DetailSelection {
  const CatalogueSelection();
}

final appTabProvider = StateProvider<AppTab>((ref) => AppTab.home);
final detailSelectionProvider = StateProvider<DetailSelection?>((ref) => null);

/// App navigation. On a phone these push the usual pages; on a wide layout
/// they switch the tab and fill the detail panel, so the list stays in view.
/// Full-screen tasks (editing a line, the PDF, sizing) push a page on both.
abstract final class AppNav {
  static ProviderContainer _c(BuildContext context) => ProviderScope.containerOf(context, listen: false);

  static void openTab(BuildContext context, AppTab tab) {
    final c = _c(context);
    c.read(appTabProvider.notifier).state = tab;
    c.read(detailSelectionProvider.notifier).state = null;
  }

  /// [replace] swaps out the current page on a phone, for flows that end in
  /// a new quote (sizing) where going back should skip the finished step.
  static void openQuote(BuildContext context, String quoteId, {bool replace = false}) {
    if (replace && !context.isWide) {
      Routemaster.of(context).replace('/quotes/$quoteId');
      return;
    }
    _open(context, '/quotes/$quoteId', AppTab.quotes, QuoteSelection(quoteId));
  }

  static void openClient(BuildContext context, String clientId) =>
      _open(context, '/clients/$clientId', AppTab.clients, ClientSelection(clientId));

  static void openBusinessProfile(BuildContext context) =>
      _open(context, '/settings/business', AppTab.settings, const BusinessSelection());

  static void openCatalogue(BuildContext context) =>
      _open(context, '/settings/catalogue', AppTab.settings, const CatalogueSelection());

  static void openLine(BuildContext context, String quoteId, String itemId) =>
      Routemaster.of(context).push('/quotes/$quoteId/lines/$itemId');

  /// [list] opens the components list instead of the quote.
  static void openDocument(BuildContext context, String quoteId, {bool list = false}) =>
      Routemaster.of(context).push('/quotes/$quoteId/document${list ? '?type=list' : ''}');

  static void openCatalogueItem(BuildContext context, String itemId) =>
      Routemaster.of(context).push('/settings/catalogue/$itemId');

  /// The calculator, for [clientId] when started from a client.
  static void openSizing(BuildContext context, {String? clientId}) =>
      Routemaster.of(context).push(clientId == null ? '/sizing' : '/sizing?clientId=$clientId');

  static void closeDetail(BuildContext context) => _c(context).read(detailSelectionProvider.notifier).state = null;

  /// Shows [selection] in the wide layout. Used for deep links too.
  static void select(ProviderContainer c, AppTab tab, DetailSelection? selection) {
    c.read(appTabProvider.notifier).state = tab;
    c.read(detailSelectionProvider.notifier).state = selection;
  }

  static void _open(BuildContext context, String path, AppTab tab, DetailSelection selection) {
    if (!context.isWide) {
      Routemaster.of(context).push(path);
      return;
    }
    // Wide: stay on the shell. If a page is pushed over it (the line
    // editor), return to the shell first.
    Routemaster.of(context).replace('/');
    select(_c(context), tab, selection);
  }
}
