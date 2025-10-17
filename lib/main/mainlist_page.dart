import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../test/test_page.dart';
import '../result/results_history_page.dart'; // 1. 새로 만든 페이지 import

class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  State<MainPage> createState() => _MainPage();
}

class _MainPage extends State<MainPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('심리 테스트'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('personality_tests').orderBy('orderIndex').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No tests found.'));
          }
          var tests = snapshot.data!.docs;
          return ListView.builder(
            itemCount: tests.length,
            itemBuilder: (context, index) {
              var test = tests[index];
              var testData = test.data() as Map<String, dynamic>;

              // title이 있는지, 그리고 비어있지 않은지 확인
              if (testData.containsKey('title') && testData['title'] != null && testData['title'].toString().isNotEmpty) {
                // title이 있으면 Card를 정상적으로 보여줌
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TestPage(testId: test.id),
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text(testData['title'].toString()),
                      trailing: const Icon(Icons.arrow_forward_ios),
                    ),
                  ),
                );
              } else {
                // title이 없으면 아무것도 표시하지 않음
                return const SizedBox.shrink();
              }
            },
          );
        },
      ),
      // 2. '결과 보기' 버튼
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ResultsHistoryPage()),
          );
        },
        child: const Icon(Icons.history),
      ),
    );
  }
}