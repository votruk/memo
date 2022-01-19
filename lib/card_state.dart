import 'package:flip_card/flip_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';

class CardState {
  final GlobalKey<FlipCardState> key;
  final String id;
  final String path;
  final bool opened;
  final bool found;

  CardState(
      {required this.key,
      required this.id,
      required this.path,
      this.opened = false,
      this.found = false});

  factory CardState.initial(
      final GlobalKey<FlipCardState> key, final String path) {
    return CardState(key: key, id: Uuid().v4(), path: path);
  }

  CardState solve() {
    return CardState(key: key, id: id, path: path, opened: true, found: true);
  }

  CardState open() {
    return CardState(key: key, id: id, path: path, opened: true, found: false);
  }

  CardState close() {
    return CardState(key: key, id: id, path: path, opened: false, found: false);
  }

  CardState changeState({
    required final bool opened,
    required final bool found,
  }) {
    return CardState(
      key: key,
      id: id,
      path: path,
      opened: opened,
      found: found,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardState &&
          runtimeType == other.runtimeType &&
          key == other.key &&
          id == other.id &&
          path == other.path &&
          opened == other.opened &&
          found == other.found;

  @override
  int get hashCode =>
      key.hashCode ^
      id.hashCode ^
      path.hashCode ^
      opened.hashCode ^
      found.hashCode;

  @override
  String toString() {
    return 'CardState{key: $key, id: $id, path: $path, opened: $opened, found: $found}';
  }
}
