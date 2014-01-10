part of Typographer;

class TransformLinks {
  static const AS_IS = const TransformLinks._(0);
  static const INLINE = const TransformLinks._(1);
  static const REFERENCE = const TransformLinks._(2);

  static get values => [AS_IS, INLINE, REFERENCE];

  final int value;

  const TransformLinks._(this.value);
}

class MarkdownRendererOptions {
  TransformLinks transformLinks;
  // TODO header type === or #
  MarkdownRendererOptions({this.transformLinks: TransformLinks.AS_IS});
}