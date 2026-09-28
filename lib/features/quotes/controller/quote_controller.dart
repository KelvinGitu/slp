import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solartide/core/enums/quote_status.dart';
import 'package:solartide/core/widgets/snackbar.dart';
import 'package:solartide/features/auth/controller/auth_controller.dart';
import 'package:solartide/features/business/providers/business_providers.dart';
import 'package:solartide/features/catalogue/providers/catalogue_providers.dart';
import 'package:solartide/features/quotes/logic/quote_calculator.dart';
import 'package:solartide/features/quotes/repository/quote_repository.dart';
import 'package:solartide/features/sizing/logic/sizing_calculator.dart';
import 'package:solartide/models/business_profile.dart';
import 'package:solartide/models/client_model.dart';
import 'package:solartide/models/quote_model.dart';
import 'package:solartide/models/sizing_result.dart';

final quoteControllerProvider = StateNotifierProvider<QuoteController, bool>(QuoteController.new);

class QuoteController extends StateNotifier<bool> {
  QuoteController(this._ref) : super(false);

  final Ref _ref;

  QuoteRepository get _repo => _ref.read(quoteRepositoryProvider);
  String? get _uid => _ref.read(currentUidProvider);

  /// Starts a quote for [client] with every active catalogue item as a "To
  /// do" line, prefilled from [sizing] when given. Returns the new quote's
  /// id, or null if it couldn't be saved.
  Future<String?> create({required ClientModel client, SizingResult? sizing, required BuildContext context}) async {
    final uid = _uid;
    if (uid == null) return null;
    final catalogue = _ref.read(catalogueProvider).valueOrNull ?? const [];
    final profile = _ref.read(businessProfileProvider).valueOrNull ?? const BusinessProfile(name: '');

    var lines = QuoteCalculator.linesFor(catalogue);
    if (sizing != null) lines = SizingCalculator.applyToLines(lines, sizing, catalogue);

    final now = DateTime.now();
    final draft = QuoteModel(
      id: '',
      number: '',
      client: client.toSnapshot(),
      status: QuoteStatus.draft,
      lines: lines,
      markupPercent: profile.markupPercent,
      vatPercent: profile.vatPercent,
      totals: QuoteCalculator.totals(lines, markupPercent: profile.markupPercent, vatPercent: profile.vatPercent),
      createdAt: now,
      updatedAt: now,
      validUntil: now.add(Duration(days: profile.quoteValidityDays)),
      sizing: sizing,
    );

    state = true;
    final result = await _repo.create(uid, draft);
    state = false;
    return result.fold((f) {
      if (context.mounted) showSnackBar(context, f.message);
      return null;
    }, (q) => q.id);
  }

  /// Saves [quote] after an edit. Totals are recomputed here too, so a
  /// caller can't store lines and totals that disagree.
  Future<bool> save(QuoteModel quote, BuildContext context) async {
    final uid = _uid;
    if (uid == null) return false;
    final priced = QuoteCalculator.withRates(quote).copyWith(updatedAt: DateTime.now());
    state = true;
    final result = await _repo.save(uid, priced);
    state = false;
    return result.fold((f) {
      if (context.mounted) showSnackBar(context, f.message);
      return false;
    }, (_) => true);
  }

  Future<bool> saveLine(QuoteModel quote, QuoteLine line, BuildContext context) =>
      save(QuoteCalculator.withLine(quote, line), context);

  Future<void> setStatus(QuoteModel quote, QuoteStatus status, BuildContext context) async {
    final uid = _uid;
    if (uid == null || quote.status == status) return;
    final result = await _repo.setStatus(uid, quote.id, status);
    if (!context.mounted) return;
    result.fold(
      (f) => showSnackBar(context, f.message),
      (_) => showSnackBar(context, 'Marked as ${status.label.toLowerCase()}.'),
    );
  }

  /// Soft delete with an Undo on the snackbar.
  Future<bool> delete(QuoteModel quote, BuildContext context) async {
    final uid = _uid;
    if (uid == null) return false;
    final result = await _repo.setDeleted(uid, quote.id, deleted: true);
    return result.fold((f) {
      if (context.mounted) showSnackBar(context, f.message);
      return false;
    }, (_) {
      if (context.mounted) {
        showSnackBar(
          context,
          '${quote.number} deleted.',
          actionLabel: 'Undo',
          onAction: () => _repo.setDeleted(uid, quote.id, deleted: false),
        );
      }
      return true;
    });
  }

  /// A copy with a new number, back in draft, dated today. Lines keep their
  /// frozen prices; the installer re-opens any line to pick up new ones.
  Future<String?> duplicate(QuoteModel quote, BuildContext context) async {
    final uid = _uid;
    if (uid == null) return null;
    final profile = _ref.read(businessProfileProvider).valueOrNull;
    final now = DateTime.now();
    final draft = quote.copyWith(
      status: QuoteStatus.draft,
      createdAt: now,
      updatedAt: now,
      validUntil: now.add(Duration(days: profile?.quoteValidityDays ?? 30)),
    );
    state = true;
    final result = await _repo.create(uid, draft);
    state = false;
    return result.fold((f) {
      if (context.mounted) showSnackBar(context, f.message);
      return null;
    }, (q) {
      if (context.mounted) showSnackBar(context, 'Copied to ${q.number}.');
      return q.id;
    });
  }
}
