import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

/// Create a dropdown form field
class DropdownFormField<T> extends StatefulWidget {
  const DropdownFormField({
    required this.dropdownItemFn,
    required this.displayItemFn,
    required this.findFn,
    Key? key,
    this.filterFn,
    this.autoFocus = false,
    this.controller,
    this.validator,
    this.decoration,
    this.dropdownColor,
    this.onChanged,
    this.onSaved,
    this.dropdownMaxHeight,
    this.searchTextStyle,
    this.emptyText = "No matching found!",
    this.emptyActionText = 'Create new',
    this.onEmptyActionPressed,
    this.selectedFn,
    this.searchCursorColor,
    this.searchInitialValue,
    this.searchInpuType = TextInputType.emailAddress,
  }) : super(key: key);

  /// It will trigger on user search
  final bool Function(T item, String str)? filterFn;

  /// Check item is selectd
  final bool Function(T? item1, T? item2)? selectedFn;

  /// Build dropdown Items, it get called for all dropdown items
  ///  [item] = [dynamic value] List item to build dropdown Listtile
  /// [lasSelectedItem] = [null | dynamic value] last selected item, it gives user chance to highlight selected item
  /// [position] = [0,1,2...] Index of the list item
  /// [focused] = [true | false] is the item if focused, it gives user chance to highlight focused item
  /// [onTap] = [Function] *important! just assign this function to Listtile.onTap  = onTap, incase you missed this,
  /// the click event if the dropdown item will not work.
  ///
  final Widget Function(
    T item,
    int position,
    bool focused,
    bool selected,
    void Function() onTap,
  ) dropdownItemFn;

  final void Function(T? item)? onChanged;
  final void Function(T?)? onSaved;
  final String? Function(T? item)? validator;

  /// this functon triggers on click of emptyAction button
  final Future<void> Function(String)? onEmptyActionPressed;

  final bool autoFocus;
  final DropdownEditingController<T>? controller;
  final InputDecoration? decoration;

  /// Build widget to display selected item inside Form Field
  final Widget Function(T? item) displayItemFn;

  final Color? dropdownColor;

  /// Max height of the dropdown overlay, Default: 240
  final double? dropdownMaxHeight;

  /// Give action text if you want handle the empty search.
  final String emptyActionText;

  /// Message to display if the search dows not match with any item, Default : "No matching found!"
  final String emptyText;

  /// Return list of items what need to list for dropdown.
  /// The list may be offline, or remote data from server.
  final Future<List<T>> Function(String str) findFn;

  /// Cursor color of the search box text
  final Color? searchCursorColor;

  final T? searchInitialValue;

  /// TextInputType of the search box text
  final TextInputType searchInpuType;

  /// Style the search box text
  final TextStyle? searchTextStyle;

  @override
  DropdownFormFieldState<T> createState() => DropdownFormFieldState<T>();
}

class DropdownFormFieldState<T> extends State<DropdownFormField<T>>
    with SingleTickerProviderStateMixin {
  DropdownFormFieldState() : super() {}

  final DropdownEditingController<T>? _controller =
      DropdownEditingController<T>();

  Timer? _debounce;
  Widget? _displayItem;
  bool _isFocused = false;
  String? _lastSearchString;
  final LayerLink _layerLink = LayerLink();
  int _listItemFocusedPosition = 0;
  final ValueNotifier<List<T>> _listItemsValueNotifier =
      ValueNotifier<List<T>>(<T>[]);

  List<T>? _options;
  late OverlayEntry _overlayBackdropEntry;
  OverlayEntry? _overlayEntry;
  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchTextController = TextEditingController();
  T? _selectedItem;
  final FocusNode _widgetFocusNode = FocusNode();

  @override
  void dispose() {
    super.dispose();
    _debounce?.cancel();
    _searchTextController.dispose();
    _widgetFocusNode.dispose();
  }

  @override
  void initState() {
    super.initState();

    if (widget.autoFocus) {
      _widgetFocusNode.requestFocus();
    }
    _selectedItem = _effectiveController!.value;

    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus && _overlayEntry != null) {
        _removeOverlay();
      }
    });

    _effectiveController!.addListener(() {
      if (_effectiveController!.value == null) {
        _clearValue();
      }
    });
  }

  final bool Function(T?, T?) _selectedFn =
      (T? item1, T? item2) => item1 == item2;

  bool get _isEmpty => _selectedItem == null;

  DropdownEditingController<T>? get _effectiveController =>
      widget.controller ?? _controller;

  OverlayEntry _createOverlayEntry() {
    final RenderBox renderObject = context.findRenderObject() as RenderBox;
    // print(renderObject);
    final Size size = renderObject.size;

    OverlayEntry overlay = OverlayEntry(
      builder: (BuildContext context) {
        return Positioned(
          width: size.width,
          child: CompositedTransformFollower(
            link: this._layerLink,
            showWhenUnlinked: false,
            offset: Offset(0.0, size.height + 3.0),
            child: Material(
              elevation: 10.0,
              color: Colors.transparent,
              shadowColor: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: widget.dropdownColor ?? Theme.of(context).primaryColor,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(20),
                  ),
                ),
                constraints:
                    BoxConstraints(maxHeight: widget.dropdownMaxHeight ?? 240),
                child: ValueListenableBuilder<List<T>>(
                  valueListenable: _listItemsValueNotifier,
                  builder:
                      (BuildContext context, List<T> items, Widget? child) {
                    return _options?.isNotEmpty ?? false
                        ? ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: _options!.length,
                            itemBuilder: (BuildContext context, int position) {
                              T item = _options![position];

                              void Function() onTap = () {
                                _listItemFocusedPosition = position;
                                _searchTextController.value = TextEditingValue(
                                  text: item.toString(),
                                  selection: TextSelection.collapsed(
                                    offset: item.toString().length,
                                  ),
                                );
                                _removeOverlay();
                                _setValue();
                              };

                              Widget listTile = widget.dropdownItemFn(
                                item,
                                position,
                                position == _listItemFocusedPosition,
                                (widget.selectedFn ?? _selectedFn)(
                                    _selectedItem, item),
                                onTap,
                              );

                              return listTile;
                            })
                        : Container(
                            padding: const EdgeInsets.all(16),
                            height:
                                widget.onEmptyActionPressed == null ? 80 : 120,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  widget.emptyText,
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                if (widget.onEmptyActionPressed != null)
                                  ElevatedButton(
                                    onPressed: () async {
                                      await widget.onEmptyActionPressed!(
                                          _searchTextController.value.text);
                                      _search(_searchTextController.value.text);
                                    },
                                    child: Text(widget.emptyActionText),
                                  ),
                              ],
                            ),
                          );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );

    return overlay;
  }

  OverlayEntry _createBackdropOverlay() {
    return OverlayEntry(
      builder: (BuildContext context) => Positioned(
        left: 0,
        top: 0,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: GestureDetector(
          onTap: () {
            _removeOverlay();
          },
        ),
      ),
    );
  }

  void _addOverlay() {
    if (_overlayEntry == null) {
      unawaited(_search(""));
      _overlayBackdropEntry = _createBackdropOverlay();
      _overlayEntry = _createOverlayEntry();
      if (_overlayEntry != null) {
        // Overlay.of(context)!.insert(_overlayEntry!);
        Overlay.of(context)
            .insertAll(<OverlayEntry>[_overlayBackdropEntry, _overlayEntry!]);
        setState(() {
          _searchFocusNode.requestFocus();
        });
      }
    }
  }

  /// Dettach overlay from the dropdown widget
  void _removeOverlay() {
    if (_overlayEntry != null) {
      _overlayBackdropEntry.remove();
      _overlayEntry!.remove();
      _overlayEntry = null;
      _searchTextController.value = TextEditingValue.empty;
      setState(() {});
    }
  }

  void _toggleOverlay() {
    if (_overlayEntry == null) {
      _addOverlay();
    } else {
      _removeOverlay();
    }
  }

  void _onTextChanged(String? str) {
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }
    _debounce = Timer(const Duration(milliseconds: 300), () {
      // print("_onChanged: $_lastSearchString = $str");
      if (_lastSearchString != str) {
        _lastSearchString = str;
        unawaited(_search(str ?? ""));
      }
    });
  }

  KeyEventResult _onKeyPressed(RawKeyEvent event) {
    // print('_onKeyPressed : ${event.character}');
    if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
      if (_searchFocusNode.hasFocus) {
        _toggleOverlay();
      } else {
        _toggleOverlay();
      }
      return KeyEventResult.ignored;
    } else if (event.isKeyPressed(LogicalKeyboardKey.escape)) {
      _removeOverlay();
      return KeyEventResult.handled;
    } else if (event.isKeyPressed(LogicalKeyboardKey.arrowDown)) {
      int v = _listItemFocusedPosition;
      v++;
      if (v >= _options!.length) {
        v = 0;
      }
      _listItemFocusedPosition = v;
      _listItemsValueNotifier.value = List<T>.from(_options ?? <T>[]);
      return KeyEventResult.handled;
    } else if (event.isKeyPressed(LogicalKeyboardKey.arrowUp)) {
      int v = _listItemFocusedPosition;
      v--;
      if (v < 0) {
        v = _options!.length - 1;
      }
      _listItemFocusedPosition = v;
      _listItemsValueNotifier.value = List<T>.from(_options ?? <T>[]);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  Future<void> _search(String str) async {
    List<T> items = await widget.findFn(str);

    if (str.isNotEmpty && widget.filterFn != null) {
      items = items.where((T item) => widget.filterFn!(item, str)).toList();
    }

    _options = items;

    _listItemsValueNotifier.value = items;
  }

  void _setValue() {
    if (_options?.isNotEmpty ?? false) {
      T item = _options![_listItemFocusedPosition];
      _selectedItem = item;

      _effectiveController!.value = _selectedItem;

      if (widget.onChanged != null) {
        widget.onChanged!(_selectedItem);
      }

      setState(() {});
    }
  }

  void _clearValue() {
    T? item;
    _effectiveController!.value = item;
    _selectedItem = item;

    _listItemFocusedPosition = 0;

    if (widget.onChanged != null) {
      widget.onChanged!(_selectedItem);
    }
    _searchTextController.value = const TextEditingValue();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // print("_overlayEntry : $_overlayEntry");

    _displayItem = widget.displayItemFn(_selectedItem);

    return CompositedTransformTarget(
      link: this._layerLink,
      child: GestureDetector(
        onTap: () {
          _widgetFocusNode.requestFocus();
          _toggleOverlay();
        },
        child: Focus(
          autofocus: widget.autoFocus,
          focusNode: _widgetFocusNode,
          onFocusChange: (bool focused) {
            setState(() {
              _isFocused = focused;
            });
          },
          onKey: (FocusNode focusNode, RawKeyEvent event) {
            return _onKeyPressed(event);
          },
          child: FormField(
            autovalidateMode: AutovalidateMode.always,
            initialValue: widget.searchInitialValue,
            validator: (T? str) {
              if (widget.validator != null) {
                return 'error'; //widget.validator!(_effectiveController!.value);
              }
              return null;
            },
            onSaved: (T? str) {
              if (widget.onSaved != null) {
                widget.onSaved!(_effectiveController!.value);
              }
            },
            builder: (FormFieldState<T?> state) {
              return InputDecorator(
                decoration: widget.decoration ??
                    const InputDecoration(
                      border: UnderlineInputBorder(),
                      suffixIcon: Icon(Icons.arrow_drop_down),
                    ),
                isEmpty: _isEmpty && _searchTextController.text.isEmpty,
                isFocused: _isFocused,
                child: this._overlayEntry == null
                    ? _displayItem ?? Container()
                    : EditableText(
                        controller: _searchTextController,
                        cursorColor: widget.searchCursorColor ??
                            Theme.of(context).colorScheme.primary,
                        focusNode: _searchFocusNode,
                        keyboardType: widget.searchInpuType,
                        backgroundCursorColor: Colors.transparent,
                        style: widget.searchTextStyle ??
                            Theme.of(context).textTheme.titleMedium ??
                            const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                        onChanged: (String str) {
                          if (_overlayEntry == null) {
                            _addOverlay();
                          }
                          _onTextChanged(str);
                          setState(() {});
                        },
                        onSubmitted: (String str) {
                          _searchTextController.value =
                              const TextEditingValue();
                          _listItemFocusedPosition = 0;
                          _setValue();
                          _removeOverlay();
                          _widgetFocusNode.nextFocus();
                        },
                        onEditingComplete: () {},
                      ),
              );
            },
          ),
        ),
      ),
    );
  }
}
