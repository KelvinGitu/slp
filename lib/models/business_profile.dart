import 'package:solartide/core/constants/app_constants.dart';
import 'package:solartide/core/utils/firestore_json.dart';

/// `users/{uid}/business/profile`. The installer's company as it appears on
/// quotes, plus the defaults every new quote starts from.
class BusinessProfile {
  const BusinessProfile({
    required this.name,
    this.logoUrl,
    this.phone,
    this.email,
    this.address,
    this.kraPin,
    this.mpesaPaybill,
    this.mpesaAccount,
    this.mpesaTill,
    this.bankName,
    this.bankAccountName,
    this.bankAccountNumber,
    this.bankBranch,
    this.vatPercent = AppConstants.defaultVatPercent,
    this.markupPercent = AppConstants.defaultMarkupPercent,
    this.quoteValidityDays = AppConstants.defaultQuoteValidityDays,
    this.quotePrefix = AppConstants.defaultQuotePrefix,
    this.nextQuoteNumber = 1,
    this.quoteNumberYear,
  });

  final String name;
  final String? logoUrl;
  final String? phone;
  final String? email;
  final String? address;
  final String? kraPin;

  // M-Pesa: a paybill with an account, or a till, or both.
  final String? mpesaPaybill;
  final String? mpesaAccount;
  final String? mpesaTill;

  final String? bankName;
  final String? bankAccountName;
  final String? bankAccountNumber;
  final String? bankBranch;

  final double vatPercent;
  final double markupPercent;
  final int quoteValidityDays;

  /// "ST" in "ST-2026-0007".
  final String quotePrefix;

  /// Allocated in a transaction when a quote is created. Restarts at 1 when
  /// the year changes; [quoteNumberYear] is the year it belongs to.
  final int nextQuoteNumber;
  final int? quoteNumberYear;

  bool get hasMpesa => (mpesaPaybill?.isNotEmpty ?? false) || (mpesaTill?.isNotEmpty ?? false);
  bool get hasBank => (bankAccountNumber?.isNotEmpty ?? false);

  factory BusinessProfile.fromMap(Map<String, dynamic> map) => BusinessProfile(
        name: map['name'] as String? ?? '',
        logoUrl: map['logoUrl'] as String?,
        phone: map['phone'] as String?,
        email: map['email'] as String?,
        address: map['address'] as String?,
        kraPin: map['kraPin'] as String?,
        mpesaPaybill: map['mpesaPaybill'] as String?,
        mpesaAccount: map['mpesaAccount'] as String?,
        mpesaTill: map['mpesaTill'] as String?,
        bankName: map['bankName'] as String?,
        bankAccountName: map['bankAccountName'] as String?,
        bankAccountNumber: map['bankAccountNumber'] as String?,
        bankBranch: map['bankBranch'] as String?,
        vatPercent: doubleFrom(map['vatPercent']) ?? AppConstants.defaultVatPercent,
        markupPercent: doubleFrom(map['markupPercent']) ?? AppConstants.defaultMarkupPercent,
        quoteValidityDays: intFrom(map['quoteValidityDays']) ?? AppConstants.defaultQuoteValidityDays,
        quotePrefix: map['quotePrefix'] as String? ?? AppConstants.defaultQuotePrefix,
        nextQuoteNumber: intFrom(map['nextQuoteNumber']) ?? 1,
        quoteNumberYear: intFrom(map['quoteNumberYear']),
      );

  /// Everything except the counter, which only the quote-number transaction
  /// writes. Saving the profile form must never rewind it.
  Map<String, dynamic> toMap() => {
        'name': name,
        'logoUrl': logoUrl,
        'phone': phone,
        'email': email,
        'address': address,
        'kraPin': kraPin,
        'mpesaPaybill': mpesaPaybill,
        'mpesaAccount': mpesaAccount,
        'mpesaTill': mpesaTill,
        'bankName': bankName,
        'bankAccountName': bankAccountName,
        'bankAccountNumber': bankAccountNumber,
        'bankBranch': bankBranch,
        'vatPercent': vatPercent,
        'markupPercent': markupPercent,
        'quoteValidityDays': quoteValidityDays,
        'quotePrefix': quotePrefix,
      };

  BusinessProfile copyWith({String? logoUrl}) => BusinessProfile(
        name: name,
        logoUrl: logoUrl ?? this.logoUrl,
        phone: phone,
        email: email,
        address: address,
        kraPin: kraPin,
        mpesaPaybill: mpesaPaybill,
        mpesaAccount: mpesaAccount,
        mpesaTill: mpesaTill,
        bankName: bankName,
        bankAccountName: bankAccountName,
        bankAccountNumber: bankAccountNumber,
        bankBranch: bankBranch,
        vatPercent: vatPercent,
        markupPercent: markupPercent,
        quoteValidityDays: quoteValidityDays,
        quotePrefix: quotePrefix,
        nextQuoteNumber: nextQuoteNumber,
        quoteNumberYear: quoteNumberYear,
      );
}
