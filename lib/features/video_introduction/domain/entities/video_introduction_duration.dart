enum VideoIntroductionDuration {
  seconds30,
  seconds60,
  seconds90;

  String get label => switch (this) {
    VideoIntroductionDuration.seconds30 => '30 sec',
    VideoIntroductionDuration.seconds60 => '60 sec',
    VideoIntroductionDuration.seconds90 => '90 sec',
  };
}
