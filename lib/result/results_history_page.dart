import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ResultsHistoryPage extends StatefulWidget {
  const ResultsHistoryPage({super.key});

  @override
  State<ResultsHistoryPage> createState() => _ResultsHistoryPageState();
}

class _ResultsHistoryPageState extends State<ResultsHistoryPage> {
  Future<QuerySnapshot> _fetchResults() {
    // 정렬 없이 모든 결과를 한 번만 가져옵니다.
    return FirebaseFirestore.instance.collection('test_results').get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('나의 결과 보기'),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: _fetchResults(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('저장된 결과가 없습니다.'));
          }

          var allResults = snapshot.data!.docs;

          // --- 각 테스트별 최신 결과 필터링 및 orderIndex 기준 정렬 로직 ---
          final Map<String, DocumentSnapshot> latestResults = {};
          for (var result in allResults) {
            var resultData = result.data() as Map<String, dynamic>;
            String title = resultData['title'];

            // 맵에 결과가 없거나, 현재 결과가 맵에 있는 결과보다 더 최신이면 교체
            if (!latestResults.containsKey(title) ||
                (resultData['timestamp'] as Timestamp).compareTo(
                    (latestResults[title]!.data()
                    as Map<String, dynamic>)['timestamp'] as Timestamp) > 0) {
              latestResults[title] = result;
            }
          }

          // 맵의 값들(최신 결과 문서들)을 리스트로 변환
          final uniqueLatestResults = latestResults.values.toList();

          // orderIndex를 기준으로 최종 리스트를 오름차순으로 정렬
          uniqueLatestResults.sort((a, b) {
            var aData = a.data() as Map<String, dynamic>;
            var bData = b.data() as Map<String, dynamic>;
            return (aData['orderIndex'] as int).compareTo(bData['orderIndex'] as int);
          });
          // --- 여기까지가 핵심 로직입니다 ---

          return ListView.builder(
            itemCount: uniqueLatestResults.length,
            itemBuilder: (context, index) {
              var result = uniqueLatestResults[index];
              var resultData = result.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(resultData['title'] ?? '알 수 없는 테스트'),
                  subtitle: Text(resultData['result'] ?? '결과 없음'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}