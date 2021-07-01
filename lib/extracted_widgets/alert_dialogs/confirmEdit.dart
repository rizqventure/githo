import 'package:flutter/material.dart';
import 'package:githo/extracted_data/styleData.dart';

class ConfirmEdit extends StatelessWidget {
  final Function confirmationFunc;

  const ConfirmEdit({required this.confirmationFunc});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        "Confirm edit",
        style: StyleData.textStyle,
      ),
      content: const Text(
        "When editing a habit-plan, all progress is reset.\n\nYou will need to re-activate the plan after changing it.",
        style: StyleData.textStyle,
      ),
      actions: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton.icon(
              icon: const Icon(
                Icons.cancel,
                color: Colors.white,
              ),
              label: Text(
                "Cancel",
                style: coloredTextStyle(Colors.white),
              ),
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.orange),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton.icon(
              icon: const Icon(
                Icons.edit,
                color: Colors.white,
              ),
              label: Text(
                "Edit",
                style: coloredTextStyle(Colors.white),
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
              ),
              onPressed: () {
                Navigator.pop(context);
                confirmationFunc();
              },
            ),
          ],
        ),
      ],
    );
  }
}