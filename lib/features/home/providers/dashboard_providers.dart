import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solartide/core/enums/quote_status.dart';
import 'package:solartide/features/quotes/providers/quote_providers.dart';

/// Numbers for the Home dashboard, derived from the quote list so they never
/// need a separate query or counter document.
class DashboardStats {
  const DashboardStats({
    this.byStatus = const {},
    this.wonThisMonth = 0,
    this.wonCountThisMonth = 0,
    this.openValue = 0,
  });

  final Map<QuoteStatus, int> byStatus;

  /// Accepted or installed quotes created this calendar month, in shillings.
  final int wonThisMonth;
  final int wonCountThisMonth;

  /// Drafts and sent quotes: business still to win.
  final int openValue;

  int count(QuoteStatus s) => byStatus[s] ?? 0;
}

final dashboardStatsProvider = Provider<AsyncValue<DashboardStats>>((ref) {
  final now = DateTime.now();
  return ref.watch(quotesProvider).whenData((quotes) {
    final byStatus = <QuoteStatus, int>{};
    var won = 0, wonCount = 0, open = 0;
    for (final q in quotes) {
      byStatus[q.status] = (byStatus[q.status] ?? 0) + 1;
      final thisMonth = q.createdAt.year == now.year && q.createdAt.month == now.month;
      if (q.status.isWon && thisMonth) {
        won += q.totals.total;
        wonCount++;
      }
      if (q.status == QuoteStatus.draft || q.status == QuoteStatus.sent) open += q.totals.total;
    }
    return DashboardStats(byStatus: byStatus, wonThisMonth: won, wonCountThisMonth: wonCount, openValue: open);
  });
});
