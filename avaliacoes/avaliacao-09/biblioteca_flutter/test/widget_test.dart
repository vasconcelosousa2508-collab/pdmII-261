import 'package:busca_uni/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Biblioteca app renders', (WidgetTester tester) async {
    await tester.pumpWidget(const BibliotecaApp());
    await tester.pump();

    expect(find.text('Biblioteca Acadêmica'), findsOneWidget);
    expect(
      find.text('Buscar livros (ex: algoritmos, python, redes)...'),
      findsOneWidget,
    );
  });
}
