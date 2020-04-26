import 'package:flutter/material.dart';
import 'package:iltempo/models/training.dart';
import 'package:iltempo/widgets/single_training_card.dart';

class TrainingsList extends StatelessWidget {
  TrainingsList(this.trainings);
  final List<Training> trainings;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (ctx, index) => SingleTrainingCard(trainings[index]),
      itemCount: trainings.length,

    );
  }
}
