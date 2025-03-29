class BoxModel {
  final String title;
  final int value;
  final String? icon;

  const BoxModel({
    this.icon,
    required this.title,
    required this.value,
  });
}

final List<BoxModel> template = [
  BoxModel(title: 'Summer time', value: 3000, icon: 'images/palm.png'),
  BoxModel(title: 'Sporty ', value: 4000, icon: 'images/basketball.png'),
  BoxModel(title: 'Snow day', value: 1500, icon: 'images/snowflake.png'),
  BoxModel(title: 'Chill time', value: 2500, icon: 'images/rainbow.png'),
];

final List<BoxModel> metric = [
  BoxModel(title: 'Orange', value: 30),
  BoxModel(title: 'Banana ', value: 40),
  BoxModel(title: 'Pineapple', value: 55),
  BoxModel(title: 'Watermelon', value: 70),
];
