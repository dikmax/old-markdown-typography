part of Typographer;

/// Translates a parsed AST to Markdown.
class MarkdownRenderer implements NodeVisitor {
  StringBuffer buffer;
  ListQueue<StringBuffer> stack;
  ListQueue<String> tagsStack;
  Map<String, Link> refLinks;
  MarkdownRendererOptions options;
  TokenTransformer tokenTransformer = new TokenTransformer();

  MarkdownRenderer([this.options = null]) {
    if (this.options == null) {
      this.options = new MarkdownRendererOptions();
    }
  }

  String render(List<Node> nodes, [Map<String, Link> refLinks = null]) {
    buffer = new StringBuffer();
    stack = new ListQueue<StringBuffer>();
    tagsStack = new ListQueue<String>();
    this.refLinks = refLinks == null ? {} : refLinks;

    for (final node in nodes) node.accept(this);

    // Sorting references
    var refs = this.refLinks.values.toList();
    refs
      ..sort((a, b) {
        if (a.id < b.id) {
          return -1;
        } else if (a.id > b.id) {
          return 1;
        } else {
          return 0;
        }
      })
      ..forEach((link) {
        buffer.write('[${link.id}]: ${link.url}');
        if (link.title != null) {
          buffer.write(' "${link.title}"');
        }
        buffer.writeln();
      });

    return buffer.toString();
  }

  /// Called when a Text node has been reached.
  void visitText(Text text) {
    String str = text.text;

    if (tagsStack.last != 'pre' && tagsStack.last != 'code') {
      List<TransformContext> context = <TransformContext>[];
      str.splitMapJoin(new RegExp(r'(\s|&nbps;|\\ )+', multiLine: true),
          onMatch: (match) => context.add(new TransformContext(match[0], true)),
          onNonMatch: (str) => context.add(new TransformContext(str, false))
      );
      for (int i = 0; i < context.length; ++i) {
        if (context[i].isSpace) {
          context[i].token = tokenTransformer.transformSpace(context[i].token, i, context);
        } else {
          context[i].token = tokenTransformer.transform(context[i].token, i, context);
        }
      }

      context.forEach((e) => stack.last.write(e.token));
    } else {
      stack.last.write(str);
    }
  }

  /// Called when an Element has been reached, before its children have been
  /// visited. Return `false` to skip its children.
  bool visitElementBefore(Element element) {
    print('<${element.tag}>');
    var buffer = new StringBuffer();
    stack.addLast(buffer);
    tagsStack.addLast(element.tag);
    return true;
  }

  /// Called when an Element has been reached, after its children have been
  /// visited. Will not be called if [visitElementBefore] returns `false`.
  void visitElementAfter(Element element) {
    print('</${element.tag}>');
    var b = stack.removeLast();
    tagsStack.removeLast();

    var last = stack.isEmpty ? buffer : stack.last;

    String blockData = '';
    bool align = false;

    switch (element.tag) {
    // Block elements
    case 'h1':
      blockData += '# ';
      align = true;
      break;

    case 'h2':
      blockData += '## ';
      align = true;
      break;

    case 'h3':
      blockData += '### ';
      align = true;
      break;

    case 'h4':
      blockData += '#### ';
      align = true;
      break;

    case 'h5':
      blockData += '##### ';
      align = true;
      break;

    case 'h6':
      blockData += '###### ';
      align = true;
      break;

    case 'pre':
      blockData += '```';
      if (element.attributes['class'] != null) {
        blockData += element.attributes['class'];
      }
      blockData += '\n';
      break;

    case 'p':
      align = true;
      break;

    // Inline elements
    case 'a':
      blockData += '[';
      break;

    case 'em':
      blockData += '*';
      break;

    case 'strong':
      blockData += '**';
      break;

    case 'code':
      if (tagsStack.length > 0 && tagsStack.last != 'pre') {
        blockData += '`';
      }
      break;

    default:
      assert(element.tag == null);
    }


    blockData += b.toString();

    switch (element.tag) {
      case 'pre':
        blockData += '```';
        break;

      case 'a':
        // TODO implement link transform options
        var url = element.attributes['href'];
        String refId;
        refLinks.forEach((id, link) {
          if (link.url == url) {
            refId = id;
          }
        });
        if (refId == null) {
          blockData += '](${url}';
          if (element.attributes['title'] != null) {
            blockData += ' "${element.attributes["title"]}"';
          }
          blockData += ')';
        } else {
          blockData += '][${refId}]';
        }
        break;

      case 'em':
        blockData += '*';
        break;

      case 'strong':
        blockData += '**';
        break;

      case 'code':
        if (tagsStack.length > 0 && tagsStack.last != 'pre') {
          blockData += '`';
        }
        break;
    }

    if (align) {
      var regExp = new RegExp(r'[^\\]? ');
      while (blockData.length > 80) { // TODO size in options
        var ind = blockData.lastIndexOf(regExp, 80);
        if (ind == -1) {
          ind = blockData.indexOf(regExp);
          if (ind == -1) {
            break;
          }
        }
        if (blockData[ind] != ' ') {
          ind++;
        }
        last.writeln(blockData.substring(0, ind));
        blockData = blockData.substring(ind + 1);
      }
      if (blockData.length > 0) {
        last.write(blockData);
      }
    } else {
      last.write(blockData);
    }

    if (stack.isEmpty) {
      tokenTransformer.clearState();
      buffer.writeln();
      buffer.writeln();
    }
  }

}