import 'dart:html';
import 'package:ace/ace.dart' as ace;
import 'Typographer.dart';

void main () {
  var editor = ace.edit(querySelector('#editor'))
    ..theme = new ace.Theme('ace/theme/monokai')
    ..session.mode = new ace.Mode('ace/mode/markdown');

  Element btn = query('#btnTypography');
  btn.onClick.listen((_) {
    var result = Typographer.transform(editor.value);
    print(result);
  });
}
