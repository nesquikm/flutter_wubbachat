import 'package:flutter/material.dart';
import 'package:flutter_wubbachat/l10n/l10n.dart';

class _AddChatDialog extends StatefulWidget {
  const _AddChatDialog();

  @override
  State<_AddChatDialog> createState() => _AddChatDialogState();
}

class _AddChatDialogState extends State<_AddChatDialog> {
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _textEditingController;
  late final FocusNode _textEditingFocusNode;
  bool _createNew = false;

  @override
  void initState() {
    super.initState();

    _formKey = GlobalKey<FormState>();
    _textEditingController = TextEditingController();
    _textEditingFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _textEditingFocusNode.dispose();

    super.dispose();
  }

  void _onAdd() {
    Navigator.pop(context, _createNew ? '' : _textEditingController.text);
  }

  void _onCancel() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
              focusNode: _textEditingFocusNode,
              decoration: InputDecoration(
                hintText: _createNew
                    ? l10n.dialogTextHintCreateNew
                    : l10n.dialogTextHintJoinExisting,
              ),
              controller: _textEditingController,
              onFieldSubmitted: (_) => _onAdd,
              enabled: !_createNew,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.dialogCheckboxCreateNewChat),
                Checkbox(
                  value: _createNew,
                  onChanged: (checked) {
                    setState(() {
                      _createNew = checked == true;
                      if (_createNew) {
                        _textEditingController.clear();
                      }
                    });
                    if (!_createNew) {
                      WidgetsBinding.instance.addPostFrameCallback(
                        (timeStamp) => _textEditingFocusNode.requestFocus(),
                      );
                    }
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
          onPressed: (_createNew || _textEditingController.text.isNotEmpty)
              ? _onAdd
              : null,
          child: Text(
            _createNew
                ? l10n.dialogActionCreateNewChat
                : l10n.dialogActionJoinExistingChat,
          ),
        ),
      ],
    );
  }
}

Future<String?> showAddChatDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (context) {
      return const _AddChatDialog();
    },
  );
}
