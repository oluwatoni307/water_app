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
  BoxModel(title: 'Dry Season', value: 4000, icon: 'images/suny.png'),
  BoxModel(
      title: 'Rainy Season', value: 3000, icon: 'images/raining season.png'),
  BoxModel(title: 'Harmattan', value: 3500, icon: 'images/Hamattan.png'),
];

final List<BoxModel> fruits = [
  BoxModel(
    title: 'Watermelon',
    value: 4600,
    icon: 'images/fruits/watermelon.png',
  ),
  BoxModel(
    title: 'Pawpaw',
    value: 440,
    icon: 'images/fruits/pawpaw.png',
  ),
  BoxModel(
    title: 'Orange',
    value: 155,
    icon: 'images/fruits/orange.png',
  ),
  BoxModel(
    title: 'Pineapple',
    value: 1290,
    icon: 'images/fruits/pineapple.png',
  ),
  BoxModel(
    title: 'Banana',
    value: 89,
    icon: 'images/fruits/banana.png',
  ),
  BoxModel(
    title: 'Apple',
    value: 155,
    icon: 'images/fruits/apple.png',
  ),
  BoxModel(
    title: 'Mango',
    value: 166,
    icon: 'images/fruits/mango.png',
  ),
  BoxModel(
    title: 'Cucumber',
    value: 192,
    icon: 'images/fruits/cucumber.png',
  ),
  BoxModel(
    title: 'Tangerine',
    value: 200,
    icon: 'images/fruits/tangerine.png',
  ),
  BoxModel(
    title: 'Guava',
    value: 203,
    icon: 'images/fruits/guava.png',
  ),
];
