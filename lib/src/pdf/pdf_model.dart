class Invoice {
  final InvoiceInfo info;
  final Supplier supplier;
  final Customer customer;
  final List<InvoiceItem> items;
  final int quotation;

  const Invoice({
    required this.info,
    required this.supplier,
    required this.customer,
    required this.items,
    required this.quotation,
  });
}

class InvoiceInfo {
  final String description;
  final String number;
  final DateTime date;
  final DateTime dueDate;

  const InvoiceInfo({
    required this.description,
    required this.number,
    required this.date,
    required this.dueDate,
  });
}

class InvoiceItem {
  final String description;
  final int units;
  final int cost;
  final int unitPrice;
  final List<SpecificInvoiceItem> specificItems;

  const InvoiceItem({
    required this.description,
    required this.cost,
    required this.units,
    required this.unitPrice,
    required this.specificItems,
  });
}

class SpecificInvoiceItem {
  final String description;
  final String units;


  const SpecificInvoiceItem({
    required this.description,
    required this.units,
  });
}

class Customer {
  final String name;
  final String address;

  const Customer({
    required this.name,
    required this.address,
  });
}

class Supplier {
  final String name;
  final String address;
  final String paymentInfo;

  const Supplier({
    required this.name,
    required this.address,
    required this.paymentInfo,
  });
}
