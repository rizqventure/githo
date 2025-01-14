/* 
 * Githo – An app that helps you gradually form long-lasting habits.
 * Copyright (C) 2021 Florian Thaler
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import 'package:flutter/material.dart';
import 'package:githo/config/custom_widget_themes.dart';
import 'package:githo/models/habit_plan.dart';
import 'package:githo/models/progress_data.dart';
import 'package:githo/widgets/alert_dialogs/base_dialog.dart';

class ConfirmDeletion extends StatelessWidget {
  /// Returns a dialog that asks 'Do you really want to delete the habit-plan?'
  /// If the user says confirms, the habit-plan is deleted.
  const ConfirmDeletion({
    required this.habitPlan,
    required this.onConfirmation,
  });

  final HabitPlan habitPlan;
  final void Function() onConfirmation;

  @override
  Widget build(BuildContext context) {
    return BaseDialog(
      title: const Text(
        'Confirm deletion',
      ),
      content: Text(
        habitPlan.isActive
            ? 'All previous progress will be lost.'
            : 'Do you want to delete this habit-plan?',
        style: Theme.of(context).textTheme.bodyText2,
      ),
      actions: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <ElevatedButton>[
            ElevatedButton.icon(
              icon: const Icon(
                Icons.cancel,
              ),
              label: Text(
                'Cancel',
                style: Theme.of(context).textTheme.bodyText1!.copyWith(
                      color: Colors.white,
                    ),
              ),
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(ThemedColors.orange),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            ElevatedButton.icon(
              icon: const Icon(
                Icons.delete,
              ),
              label: Text(
                'Delete',
                style: Theme.of(context).textTheme.bodyText1!.copyWith(
                      color: Colors.white,
                    ),
              ),
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(ThemedColors.red),
              ),
              onPressed: () async {
                if (habitPlan.isActive) {
                  final ProgressData progressData = ProgressData.emptyData();
                  progressData.save();
                }

                await habitPlan.delete();

                onConfirmation();

                Navigator.pop(context); // Pop dialog
                Navigator.pop(context); // Pop habit-details-screen
              },
            ),
          ],
        ),
      ],
    );
  }
}
