import 'package:flutter/material.dart';
import 'package:flutter_wubbachat/l10n/l10n.dart';

final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
final TextEditingController _textEditingController = TextEditingController();

Future<String?> showAddChatDialog(BuildContext context) {
  final l10n = context.l10n;

  _textEditingController.clear();
  var createNew = false;

  void _onAdd() {
    Navigator.pop(context, createNew ? '' : _textEditingController.text);
  }

  void _onCancel() {
    Navigator.pop(context);
  }

  return showDialog<String>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(l10n.dialogTitleNewChat),
            content: Form(
              onChanged: () {
                setState(() {});
              },
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: createNew
                          ? l10n.dialogTextHintCreateNew
                          : l10n.dialogTextHintJoinExisting,
                    ),
                    controller: _textEditingController,
                    onFieldSubmitted: (_) => _onAdd,
                    enabled: !createNew,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.dialogCheckboxCreateNewChat),
                      Checkbox(
                        value: createNew,
                        onChanged: (checked) {
                          setState(() {
                            createNew = checked == true;
                            _textEditingController.clear();
                          });
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: _onCancel,
                child: Text(l10n.dialogActionCancel),
              ),
              TextButton(
                onPressed: (createNew || _textEditingController.text.isNotEmpty)
                    ? _onAdd
                    : null,
                child: Text(
                  createNew
                      ? l10n.dialogActionCreateNewChat
                      : l10n.dialogActionJoinExistingChat,
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
