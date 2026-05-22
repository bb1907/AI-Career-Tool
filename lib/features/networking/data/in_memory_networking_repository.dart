import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/networking_message.dart';

class NetworkingListNotifier extends AsyncNotifier<List<NetworkingMessage>> {
  static const _kMessages = 'networking_messages';

  @override
  Future<List<NetworkingMessage>> build() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kMessages);
    if (raw == null) return [];
    try {
      final list = (jsonDecode(raw) as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(NetworkingMessage.fromJson)
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    } catch (_) {
      return [];
    }
  }

  Future<void> add(NetworkingMessage message) async {
    final current = state.asData?.value ?? [];
    final updated = [message, ...current];
    await _persist(updated);
    state = AsyncData(updated);
  }

  Future<void> delete(String id) async {
    final current = state.asData?.value ?? [];
    final updated = current.where((m) => m.id != id).toList();
    await _persist(updated);
    state = AsyncData(updated);
  }

  Future<void> _persist(List<NetworkingMessage> messages) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kMessages,
      jsonEncode(messages.map((m) => m.toJson()).toList()),
    );
  }
}

final networkingListProvider =
    AsyncNotifierProvider<NetworkingListNotifier, List<NetworkingMessage>>(
      NetworkingListNotifier.new,
    );
