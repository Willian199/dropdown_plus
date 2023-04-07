import 'package:flutter/foundation.dart';

class DropdownEditingController<T> extends ChangeNotifier {
  DropdownEditingController({T? value}) : _value = value;

  T? _value;

  @override
  String toString() => '${describeIdentity(this)}($value)';

  T? get value => _value;

  set value(T? newValue) {
    if (_value == newValue) {
      return;
    }
    _value = newValue;
    notifyListeners();
  }

  void clear() {
    T? _item;
    _value = _item;

    notifyListeners();
  }
}
