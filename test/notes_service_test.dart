import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:urbantutorsapp/services/api_exception.dart';
import 'package:urbantutorsapp/services/notes_service.dart';

void main() {
  late Map<String, String> sent;

  http.Client client(String body, {int status = 200}) =>
      MockClient((req) async {
        sent = Uri.splitQueryString(req.body);
        return http.Response(body, status);
      });

  test('fetchClasses sends the selected board and content type', () async {
    final classes = await http.runWithClient(
      () => NotesService().fetchClasses(boardId: 2, type: 'pyq'),
      () => client(jsonEncode({
        'success': true,
        'data': [
          {'board_id': 2, 'class_id': 3, 'ClassName': 'Year 1', 'type': 'pyq'}
        ],
      })),
    );

    expect(sent['board_id'], '2');
    expect(sent['type'], 'pyq');
    expect(classes, hasLength(1));
  });

  test('"not found" responses (data: []) give an empty list', () async {
    final classes = await http.runWithClient(
      () => NotesService().fetchClasses(boardId: 9),
      () => client(jsonEncode(
          {'success': true, 'data': [], 'message': 'Class Data Not Found'})),
    );
    expect(classes, isEmpty);
  });

  test('non-JSON responses raise a readable error', () async {
    await expectLater(
      http.runWithClient(
        () => NotesService().fetchSubjects(classId: 1),
        () => client('<html>oops</html>'),
      ),
      throwsA(isA<ApiException>()),
    );
  });
}
