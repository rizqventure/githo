import 'package:flutter/material.dart';
import 'package:githo/extracted_data/dataShortcut.dart';

import 'package:githo/extracted_data/fullDatabaseImport.dart';
import 'package:githo/extracted_data/styleData.dart';
import 'package:githo/extracted_functions/getStatusString.dart';
import 'package:githo/extracted_widgets/headings.dart';
import 'package:githo/screens/habitList.dart';
import 'package:githo/screens/singlelHabitDisplay.dart';

class ToDoScreen extends StatefulWidget {
  @override
  _ToDoScreenState createState() => _ToDoScreenState();
}

class _ToDoScreenState extends State<ToDoScreen> {
  late Future<List<HabitPlan>> _habitPlan;
  late Future<ProgressData> _progressData;
  //late DateTime DateTime.now();

  @override
  void initState() {
    super.initState();
    _reloadScreen();
  }

  void _reloadScreen() {
    setState(() {
      _habitPlan = DatabaseHelper.instance.getActiveHabitPlan();
      _progressData = DatabaseHelper.instance.getProgressData();
      //DateTime.now() = DateTime.now();
      _catchUpProgressData();
    });
  }

  void _catchUpProgressData() async {
    if ((await _habitPlan).length != 0) {
      ProgressData progressData = await _progressData;
      final DateTime challengeStartingDate = progressData.challengeStartingDate;
      final DateTime lastActive = progressData.lastActiveDate;
      print(progressData.level);

      print("Start $challengeStartingDate");
      print("Last  $lastActive");
      print("Now   $DateTime.now()");
      if (DateTime.now().isAfter(challengeStartingDate)) {
        HabitPlan habitPlan = (await _habitPlan)[0];
        final int trainingTimeIndex = habitPlan.trainingTimeIndex;
        const List<int> timePeriodLength = DataShortcut.maxTrainings;

        // Get the number of time-units passed since {insert first date} (for dayly challenges days)
        final int repDurationInHours =
            DataShortcut.repDurationInHours[trainingTimeIndex];
        final int lastActiveDiff =
            (lastActive.difference(challengeStartingDate).inHours /
                    repDurationInHours)
                .floor();
        final int nowDiff =
            (DateTime.now().difference(challengeStartingDate).inHours /
                    repDurationInHours)
                .floor();

        // Check if we're in a new "time span". (For dayly challenges, that would be the next day).
        final bool inNewTimeFrame = (lastActiveDiff != nowDiff);
        if (inNewTimeFrame) {
          // If this is the first day of the challenge, reset the previous, uncounted reps and
          // make the user the level 1
          if (lastActive.isBefore(challengeStartingDate)) {
            progressData.level = 1;
            progressData.completedReps = 0;
          }
          // Reset reps
          if (progressData.completedReps >= habitPlan.requiredReps) {
            progressData.completedTrainings++;
          }
          progressData.completedReps = 0;
          progressData.lastActiveDate = DateTime.now();

          // Calculate the number of time-periods passed. For dayly challenges, that would be how many weeks have passed.
          final int timePeriodsPassed =
              (nowDiff / timePeriodLength[trainingTimeIndex]).floor();
          // If we are in a new time-period...
          for (int i = 0; i < timePeriodsPassed; i++) {
            print("A WEEK HAS PASSED");
            // Move the starting date for the current challenge
            progressData.challengeStartingDate =
                progressData.challengeStartingDate.add(
              Duration(
                hours: DataShortcut.stepDurationInHours[trainingTimeIndex],
              ),
            );
            // Adjust the user's level according to his score
            if (progressData.completedTrainings >=
                habitPlan.requiredTrainings) {
              final int maxLevel = habitPlan.challenges.length *
                  habitPlan.requiredTrainingPeriods;
              print(maxLevel);
              print(progressData.level);
              if (progressData.level < maxLevel) {
                progressData.level++;
              }
            } else if (progressData.level > 1) {
              progressData.level--;
            }
            print(progressData.level);

            progressData.completedTrainings = 0;
          }
          DatabaseHelper.instance.updateProgressData(progressData);
        }
      }
    }
    print("\n\n\n");
  }

  Widget _getToDoScreen(HabitPlan habitPlan) {
    return TextButton(
      style: ButtonStyle(
        padding: MaterialStateProperty.all<EdgeInsets>(
          EdgeInsets.all(0),
        ),
      ),
      child: Container(
        width: double.infinity,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Column(
              children: [
                TextButton(
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all<EdgeInsets>(
                      EdgeInsets.all(0),
                    ),
                  ),
                  child: Container(
                    padding: StyleData.screenPadding,
                    width: double.infinity,
                    child: FutureBuilder(
                      future: this._progressData,
                      builder: (context, AsyncSnapshot<ProgressData> snapshot) {
                        if (snapshot.hasData) {
                          final ProgressData progressData = snapshot.data!;
                          return ScreenTitle(
                            title: habitPlan.goal,
                            subTitle: getStatusString(habitPlan, progressData),
                          );
                        } else {
                          return CircularProgressIndicator();
                        }
                      },
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SingleHabitDisplay(
                          updateFunction: _reloadScreen,
                          habitPlan: habitPlan,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            Padding(
              padding: StyleData.screenPadding,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FutureBuilder(
                    future: this._progressData,
                    builder: (context, AsyncSnapshot<ProgressData> snapshot) {
                      if (snapshot.hasData) {
                        final ProgressData progressData = snapshot.data!;
                        return Text(
                          "${progressData.completedReps}/${habitPlan.requiredReps}",
                          style: StyleData.textStyle,
                        );
                      } else {
                        return CircularProgressIndicator();
                      }
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Icon(
                      Icons.done,
                      color: Colors.black,
                    ),
                  ),
                  FutureBuilder(
                    future: this._progressData,
                    builder: (context, AsyncSnapshot<ProgressData> snapshot) {
                      if (snapshot.hasData) {
                        final ProgressData progressData = snapshot.data!;

                        final int challengeIndex;
                        if (progressData.level == 0) {
                          challengeIndex = 0;
                        } else {
                          challengeIndex = ((progressData.level - 1) /
                                  habitPlan.requiredTrainingPeriods)
                              .floor();
                        }

                        final String currentChallenge =
                            habitPlan.challenges[challengeIndex];
                        return Text(
                          currentChallenge,
                          style: StyleData.textStyle,
                        );
                      } else {
                        return CircularProgressIndicator();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      onPressed: () {
        setState(() {
          _catchUpProgressData();
          _incrementProgressData(habitPlan);
        });
      },
    );
  }

  void _incrementProgressData(HabitPlan habitPlan) async {
    // Increment requiredReps-data.
    ProgressData progressData = await _progressData;
    progressData
        .completedReps++; // For some reason, this directly changes the future _progressData

    if (progressData.completedReps == habitPlan.requiredReps) {
      progressData.completedTrainings++;
    }

    DatabaseHelper.instance.updateProgressData(progressData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _habitPlan,
        builder: (context, AsyncSnapshot<List<HabitPlan>> snapshot) {
          List<Widget> returnWidgets = [];
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              if (snapshot.data!.length == 0) {
                // If no HabitPlan is active
                double screenHeight = MediaQuery.of(context).size.height;
                return Container(
                  padding: EdgeInsets.only(
                    top: screenHeight * 0.25,
                    right: StyleData.screenPaddingValue,
                    left: StyleData.screenPaddingValue,
                  ),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Heading1("No habit-plan is active."),
                      Text(
                        "Click on the settings-icon to add or activate your habit-plan",
                        style: StyleData.textStyle,
                      ),
                    ],
                  ),
                );
              } else {
                // If there is an active habitPlan

                HabitPlan habitPlan = snapshot.data![0];
                return _getToDoScreen(habitPlan);
              }
            } else if (snapshot.hasError) {
              // If something went wrong with the database
              returnWidgets.add(
                Expanded(
                  child: Center(
                    child: Column(
                      children: [
                        Heading1(
                            "There was an error connecting to the database."),
                        Text(
                          snapshot.error.toString(),
                          style: StyleData.textStyle,
                        ),
                      ],
                    ),
                  ),
                ),
              );
              returnWidgets.add(
                Text(
                  snapshot.error.toString(),
                  style: StyleData.textStyle,
                ),
              );
              print(snapshot.error);
            }
          } else {
            // While loading, do this:
            returnWidgets.add(
              Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          }
          return Column(
            children: returnWidgets,
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: StyleData.floatingActionButtonPadding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            FloatingActionButton(
              tooltip: "Go to settings",
              child: Icon(Icons.settings),
              backgroundColor: Colors.orange,
              heroTag: null, //"settingsHero",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HabitList(
                      updateFunction: _reloadScreen,
                    ),
                  ),
                );
              },
            ),
            /* FloatingActionButton(
              backgroundColor: Colors.transparent,
              splashColor: Colors.purple,
              elevation: 0,
              onPressed: () {
                setState(() {
                  DateTime.now() = DateTime(
                    DateTime.now().year,
                    DateTime.now().month,
                    DateTime.now().day + 1,
                    DateTime.now().hour,
                    DateTime.now().minute,
                    DateTime.now().second,
                    DateTime.now().millisecond,
                  );
                  _catchUpProgressData();
                });
              },
            ), */
            FutureBuilder(
              future: this._habitPlan,
              builder: (context, AsyncSnapshot<List<HabitPlan>> snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data!.length > 0) {
                    final HabitPlan habitPlan = snapshot.data![0];
                    return FloatingActionButton(
                      tooltip: "Mark challenge as done",
                      child: Icon(Icons.done),
                      heroTag: null,
                      onPressed: () {
                        setState(() {
                          _catchUpProgressData();
                          _incrementProgressData(habitPlan);
                        });
                      },
                    );
                  }
                }
                return SizedBox();
              },
            ),
          ],
        ),
      ),
    );
  }
}
