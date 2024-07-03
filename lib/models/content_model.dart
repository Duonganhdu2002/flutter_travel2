class ContentModel {
  final String title;
  final String description;
  final String imagePath;

  ContentModel(
      {required this.title,
      required this.description,
      required this.imagePath});
}

List<ContentModel> contents = [
  ContentModel(
      title: "Life is short and the world is wide",
      description:
          "At Friends tours and travel, we customize reliable and trutworthy educational tours to destinations all over the world",
      imagePath: "assets/onboarding/1.png"),
  ContentModel(
      title: "It’s a big world out there go explore",
      description:
          "To get the best of your adventure you just need to leave and go where you like. we are waiting for you",
      imagePath: "assets/onboarding/2.png"),
  ContentModel(
      title: "People don’t take trips, trips take people",
      description:
          "To get the best of your adventure you just need to leave and go where you like. we are waiting for you",
      imagePath: "assets/onboarding/3.png"),
];
