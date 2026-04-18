class Reaction {
  final String type;
  final String emoji;

  const Reaction(this.type, this.emoji);
}

const reactions = [
  Reaction('LIKE', '👍'),
  Reaction('LOVE', '❤️'),
  Reaction('HAHA', '😆'),
  Reaction('WOW', '😮'),
  Reaction('SAD', '😢'),
  Reaction('ANGRY', '😡'),
];