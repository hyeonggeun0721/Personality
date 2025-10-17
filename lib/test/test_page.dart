import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../result/result_page.dart';

var log = Logger();

class TestPage extends StatefulWidget {
  final String testId;

  const TestPage({super.key, required this.testId});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Firestore에서 testId에 해당하는 특정 문서 하나를 가져오는 함수
  Future<DocumentSnapshot> _loadTest() async {
    return await _firestore.collection('personality_tests').doc(widget.testId).get();
  }

  void _answer(Map<String, dynamic> testData, int selectedIndex) async {
    String title = testData['title'];
    log.i('선택한 답변 번호: $selectedIndex');

    await FirebaseAnalytics.instance.logEvent(
      name: 'test_answer',
      parameters: {
        'test_name': title,
        'selected_index': selectedIndex,
      },
    );

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultPage(
          testId: widget.testId,
          testData: testData,
          answerIndex: selectedIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder<DocumentSnapshot>(
        future: _loadTest(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Failed to load test.'));
          }

          var testData = snapshot.data!.data() as Map<String, dynamic>;

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  testData['question'],
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                ...List.generate(
                  (testData['selects'] as List).length,
                      (index) => ElevatedButton(
                    onPressed: () => _answer(testData, index),
                    child: Text(testData['selects'][index]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}