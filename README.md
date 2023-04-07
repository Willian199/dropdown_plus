# dropdown_plus

Simple and easy to use Dropdown in forms with search, keyboard navigation, offiline data source, remote data source and easy customization.

## Getting Started

Simple Text Dropdown.

![](https://github.com/crawlinknetworks/dropdown_plus/blob/master/screenshots/screen1.png?raw=true)
![](https://github.com/crawlinknetworks/dropdown_plus/blob/master/screenshots/screen6.png?raw=true)

```
TextDropdownFormField<String>(
    options: ["Male", "Female"],
    decoration: InputDecoration(
        border: OutlineInputBorder(),
        suffixIcon: Icon(Icons.arrow_drop_down),
        labelText: "Gender"),
    dropdownMaxHeight: 120,
),
```

## Install

##### packages.yaml
```
dropdown_plus: <lastest version>
```

## Customizable Example

![](https://github.com/crawlinknetworks/dropdown_plus/blob/master/screenshots/screen4.png?raw=true)
![](https://github.com/crawlinknetworks/dropdown_plus/blob/master/screenshots/screen7.png?raw=true)
![](https://github.com/crawlinknetworks/dropdown_plus/blob/master/screenshots/screen8.png?raw=true)

```

  String rolesJson = '''
    [
      {"name": "Super Admin", "desc": "Having full access rights", "role": 1},
      {"name": "Admin", "desc": "Having full access rights of a Organization", "role": 2},
      {"name": "Manager", "desc": "Having Magenent access rights of a Organization", "role": 3},
      {"name": "Technician", "desc": "Having Technician Support access rights", "role": 4},
      {"name": "Customer Support", "desc": "Having Customer Support access rights", "role": 5},
      {"name": "User", "desc": "Having End User access rights", "role": 6}
    ]
  ''';

// ...
// ...
 List<Role> roles = Role.rolesFromJson();


// ...
// ...

  DropdownFormField<Role>(
      dropdownColor: Theme.of(context).colorScheme.secondary,
      emptyText: 'Role not found',
      dropdownMaxHeight: 350,
      searchCursorColor: Colors.grey[800],
      searchInpuType: TextInputType.text,
      searchInitialValue: roles[5],
      autoFocus: false,
      searchTextStyle: TextStyle(
        color: Theme.of(context).colorScheme.secondaryContainer,
        fontSize: 18,
      ),
      controller: _controllerRole,
      decoration: InputDecoration(
        border: const UnderlineInputBorder(),
        suffixIcon: const Icon(Icons.arrow_drop_down),
        hintText: "Select a Role",
        errorBorder: const UnderlineInputBorder(),
        errorText: _errorMessage,
      ),
      emptyActionText: 'Create a new Role',
      onEmptyActionPressed: (String valueFromfield) async {
        setState(() {
          roles.add(Role(
              name: valueFromfield,
              description: 'Set a description for: $valueFromfield',
              id: roles.map((Role e) => e.id).reduce(max)));
        });
      },
      onSaved: (Role? str) {
        _showModal('Role ${str?.name} as been selected.');
      },
      onChanged: (Role? str) {
        _showModal('Role ${str?.name ?? ''} as been changed.');
      },
      validator: (Role? str) {
        if (_errorMessage == null && str == null) {
          return null;
        }
        _errorMessage =
            str != null && str.name == 'User' ? 'Oh noo' : null;

        return _errorMessage;
      },
      displayItemFn: (Role? item) => Text(
        (item?.name ?? ''),
        style: const TextStyle(fontSize: 16),
      ),
      //can make a http request
      findFn: (dynamic str) async => roles,
      selectedFn: (Role? item1, Role? item2) {
        if (item1 != null && item2 != null) {
          return item1.name == item2.name;
        }
        return false;
      },
      filterFn: (Role? item, String str) =>
          item?.name.toLowerCase().contains(str.toLowerCase()) ?? false,
      dropdownItemFn: (Role? item, int position, bool focused,
          bool selected, void Function() onTap) {
        return Column(
          children: [
            ListTile(
              title: Text(
                item?.name ?? '',
                style: TextStyle(
                  color: selected ? Colors.white : Colors.black,
                ),
              ),
              subtitle: Text(
                item?.description ?? '',
                style: TextStyle(
                  color: selected ? Colors.white : Colors.black,
                ),
              ),
              tileColor: Colors.transparent,
              onTap: onTap,
            ),
            const Divider(
              height: 3,
              color: Colors.white60,
            )
          ],
        );
      },
    )
  ),
```

## Options

```
  /// [filterFn] An optional function that takes a generic type `T` and a string and returns a boolean. <br>
  /// This function is used to filter the items in the dropdown list based on the search text entered by the user.
  final bool Function(T item, String str)? filterFn;

  /// Check item is selectd
  final bool Function(T? item1, T? item2)? selectedFn;

  /// [dropdownItemFn] A required function that takes a generic type `T` and returns a widget that represents a dropdown item for that value. <br>
  /// This function is used to render each item in the dropdown list.
  /// [item] = [dynamic value] List item to build dropdown Listtile
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

  /// An optional function that takes a generic type T and is called when the selected value is changed.
  final void Function(T? item)? onChanged;

  /// An optional function that takes a generic type T and is called when the form is saved.
  final void Function(T?)? onSaved;

  /// An optional function that takes a generic type T and returns a string. This function is used to validate the selected value.
  final String? Function(T? item)? validator;

  /// this functon triggers on click of emptyAction button
  final Future<void> Function(String)? onEmptyActionPressed;

  ///An optional boolean that determines whether the dropdown field should be focused automatically when the widget is loaded.
  final bool autoFocus;
  final DropdownEditingController<T>? controller;

  /// An optional decoration for the text field that is used to enter search text.
  final InputDecoration? decoration;

  /// [displayItemFn] A required function that takes a generic type `T` and returns a string that represents the display text for that value. <br>
  /// This function is used to display the selected value in the dropdown field.
  final Widget Function(T? item) displayItemFn;

  /// An optional color for the dropdown list background.
  final Color? dropdownColor;

  /// Max height of the dropdown overlay, Default: 240
  final double? dropdownMaxHeight;

  /// Give action text if you want handle the empty search.
  final String emptyActionText;

  /// Message to display if the search dows not match with any item, Default : "No matching found!"
  final String emptyText;

  /// [findFn] A required function that takes a string and returns a Future that resolves to a list of generic type. <br>
  /// This function is used to retrieve the list of items that match the search text entered by the user.
  /// Return list of items what need to list for dropdown.
  /// The list may be offline, or remote data from server.
  final Future<List<T>> Function(String str) findFn;

  /// Cursor color of the search box text
  final Color? searchCursorColor;

  /// An optional initial value for the search text field.
  final T? searchInitialValue;

  /// TextInputType of the search box text
  final TextInputType searchInpuType;

  /// An optional style for the search text field.
  final TextStyle? searchTextStyle;

```