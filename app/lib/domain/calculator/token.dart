enum TokenType {
  number,
  identifier, // function or constant name
  plus,
  minus,
  multiply,
  divide,
  power,
  modulo,
  factorial,
  percent,
  openParen,
  closeParen,
  comma,
  unaryMinus,
  unaryPlus,
  eof,
}

class Token {
  final TokenType type;
  final String text;
  final num? value;
  final int position;

  const Token({
    required this.type,
    required this.text,
    this.value,
    required this.position,
  });

  @override
  String toString() => 'Token($type, "$text", pos: $position)';
}
