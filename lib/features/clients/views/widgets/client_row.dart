import 'package:flutter/material.dart';
import 'package:solartide/core/widgets/list_row.dart';
import 'package:solartide/models/client_model.dart';

/// A client in a list (§5.7): initials avatar, name, location and phone.
class ClientRow extends StatelessWidget {
  const ClientRow({super.key, required this.client, this.onPressed, this.trailing});

  final ClientModel client;
  final VoidCallback? onPressed;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final subtitle = [client.location, client.phone].whereType<String>().join(' - ');
    return ListRow(
      leading: PersonAvatar(name: client.name),
      title: client.name,
      subtitle: subtitle.isEmpty ? null : subtitle,
      trailing: trailing,
      onPressed: onPressed,
    );
  }
}
