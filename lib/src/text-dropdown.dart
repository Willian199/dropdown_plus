import 'package:dropdown_plus/dropdown_plus.dart';
import 'package:flutter/material.dart';

/// Simple dropdown whith plain text as a dropdown items.
class TextDropdownFormField<T> extends StatelessWidget {
  const TextDropdownFormField({
    required this.options,
    required this.onChanged,
    Key? key,
    this.decoration,
    this.onSaved,
    this.controller,
    this.validator,
    this.findFn,
    this.filterFn,
    this.dropdownMaxHeight,
    this.dropdownItemFn,
    this.searchInpuType = TextInputType.emailAddress,
    this.dropdownColor,
  }) : super(key: key);

  ///[onChanged]  A callback function that is called whenever the value of the input changes. <br>
  ///The function takes an optional argument of type T, which represents the new value of the input.
  final void Function(T?) onChanged;

  ///[onSaved] A callback function that is called when the form is saved. <br>
  ///The function takes an optional argument of type T, which represents the current sellected value.
  final void Function(T?)? onSaved;

  ///[validator]A function that is used to validate the current sellected value. <br>
  ///The function takes an optional argument of type T, which represents the current sellected value, and returns a String message indicating the validation error, or null if the input is valid.
  final String? Function(T?)? validator;

  ///[filterFn]A function that is used to filter the options displayed in an autocomplete or dropdown list. <br>
  /// The function takes two arguments: the first is an item of type `T`, and the second is a String that represents the current filter text. <br>
  /// The function returns a bool indicating whether the item should be included in the filtered list.
  final bool Function(T item, String str)? filterFn;

  /// [findFn] A function that is used to fetch a list of items that match a given query string. <br>
  /// The function takes a String argument representing the query string, and returns a Future that resolves to a list of items of type T.
  final Future<List<T>> Function(String str)? findFn;

  /// Build dropdown Items, it get called for all dropdown items
  ///  [item] = [dynamic value] List item to build dropdown Listtile
  /// [lasSelectedItem] = [null | dynamic value] last selected item, it gives user chance to highlight selected item
  /// [position] = [0,1,2...] Index of the list item
  /// [focused] = [true | false] is the item if focused, it gives user chance to highlight focused item
  /// [onTap] = [Function] *important! just assign this function to Listtile.onTap  = onTap, incase you missed this,
  /// the click event if the dropdown item will not work.
  ///
  final ListTile Function(T item, int position, bool focused, bool selected,
      void Function() onTap)? dropdownItemFn;

  final DropdownEditingController<T>? controller;
  final InputDecoration? decoration;
  final Color? dropdownColor;
  final double? dropdownMaxHeight;
  final List<T> options;
  final TextInputType searchInpuType;

  @override
  Widget build(BuildContext context) {
    return DropdownFormField<T>(
      decoration: decoration,
      onSaved: onSaved,
      controller: controller,
      onChanged: onChanged,
      validator: validator,
      dropdownMaxHeight: dropdownMaxHeight,
      searchInpuType: searchInpuType,
      dropdownColor: dropdownColor,
      displayItemFn: (T? str) => Text(
        str?.toString() ?? '',
        style: const TextStyle(fontSize: 16),
      ),
      findFn: findFn ?? (String str) async => options,
      filterFn: filterFn ??
          (T item, String str) {
            return item.toString().toLowerCase().contains(str.toLowerCase());
          },
      dropdownItemFn: dropdownItemFn ??
          (T item, int position, bool focused, bool selected,
              void Function() onTap) {
            return ListTile(
              title: Text(
                item.toString(),
                style:
                    TextStyle(color: selected ? Colors.white : Colors.black87),
              ),
              tileColor: Colors.transparent,
              onTap: onTap,
            );
          },
    );
  }
}
