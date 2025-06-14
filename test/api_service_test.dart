import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:kabachok_lasalsa_front/api/task_api.dart';
import 'mock_http_client.mocks.dart';

void main() {
  group('TaskApi', () {
    late MockClient mockClient;
    late TaskApi taskApi;

    setUp(() {
      mockClient = MockClient();
      taskApi = TaskApi(client: mockClient);
    });

    test('fetchTasks returns a list of tasks', () async {
      when(mockClient.get(Uri.parse('http://localhost:8008/tasks'))).thenAnswer(
        (_) async => Response(
          '[{ "id": 0, "status": "TODO", "name": "string", "planned_at": "2025-06-14T18:44:26.871Z", "project_id": 0}]',
          200,
        ),
      );

      final tasks = await taskApi.fetchTasks();

      expect(tasks, isA<List>());
      expect(tasks.first.id, '0');
      expect(tasks.first.name, 'string');
      expect(tasks.first.status, 'TODO');
      expect(tasks.first.plannedAt, isA<DateTime>());
    });
  });
}
