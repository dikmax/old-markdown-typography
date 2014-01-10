library Typographer;

import 'dart:collection';
import 'package:markdown/markdown.dart';

part 'MarkdownRenderer.dart';
part 'MarkdownRendererOptions.dart';
part 'TokenTransformer.dart';

class Typographer {
  static String transform(String markdown, {inlineSyntaxes, linkResolver}) {
    final document = new Document(inlineSyntaxes: inlineSyntaxes, linkResolver: linkResolver);

    // Replace windows line endings with unix line endings, and split.
    final lines = markdown.replaceAll('\r\n','\n').split('\n');
    document.parseRefLinks(lines);
    final blocks = document.parseLines(lines);

    return new MarkdownRenderer().render(blocks, document.refLinks);
  }
}