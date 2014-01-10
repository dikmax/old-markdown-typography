part of Typographer;

class TokenTransformer {
  void clearState() {

  }

  final List<String> prepositionsAndConjuctions = <String>[
    'без', 'в', 'до', 'для', 'за', 'из', 'к', 'на', 'над', 'о', 'об', 'по', 'под', 'пред', 'при', 'про', 'с', 'у',
    'через',
    'и', 'а', 'но', 'да', 'или', 'либо', 'то', 'не', 'ни'
  ];

  final List<String> particles = <String>[
    'б', 'бы', 'ли'
  ];

  String transform(String token, int index, List<TransformContext> context) {
    String lc = token.toLowerCase();
    if (prepositionsAndConjuctions.contains(lc)) {
      if (context[index + 1] != null && context[index + 1].isSpace) {
        context[index + 1].token = '\\ ';
      }
    } else if (particles.contains(lc)) {
      if (context[index - 1] != null && context[index - 1].isSpace) {
        context[index - 1].token = '\\ ';
      }
    }
    return token;
  }

  String transformSpace(String token, int index, List<TransformContext> context) {
    if (token.contains('&nbsp;') || token.contains('\\ ')) {
      return '\\ ';
    }
    return ' ';
  }
}

class TransformContext {
  final bool isSpace;
  String token;

  TransformContext(this.token, this.isSpace);
}