import 'dart:typed_data';

extension TensorPatch on Uint8List {
  Uint8List get unmodifiable => Uint8List.fromList(this);
}