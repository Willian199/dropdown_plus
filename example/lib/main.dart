import 'dart:math';

import 'package:dropdown_plus/dropdown_plus.dart';
import 'package:example/model.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dropdown Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Role> roles = Role.rolesFromJson();

  final DropdownEditingController<Role> _controllerRole =
      DropdownEditingController<Role>();

  final DropdownEditingController<String> _controllerGender =
      DropdownEditingController<String>();

  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    void _showModal(String value) {
      showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return Wrap(
            children: [
              Container(
                height: 50,
                color: Colors.white,
                child: Center(
                  child: Text(value),
                ),
              )
            ],
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dropdown Plus Demo'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextDropdownFormField<String>(
              options: const ["Male", "Female"],
              controller: _controllerGender,
              validator: (String? value) {
                return value?.isEmpty ?? false ? 'Select one' : null;
              },
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.arrow_drop_down),
                  labelText: "Gender"),
              dropdownHeight: 120,
            ),
            const SizedBox(
              height: 16,
            ),
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
            ),
            const SizedBox(
              height: 50,
            ),
            ElevatedButton(
              onPressed: () {
                _controllerRole.clear();
                _controllerGender.clear();
              },
              child: const Text('Clear value selected'),
            )
          ],
        ),
      ),
    );
  }
}
