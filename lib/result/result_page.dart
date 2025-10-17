import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

var log = Logger();

class ResultPage extends StatefulWidget {
  final String testId; // test_page에서 전달받을 ID
  final Map<String, dynamic> testData;
  final int answerIndex;

  const ResultPage({
    super.key,
    required this.testId,
    required this.testData,
    required this.answerIndex,
  });

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  @override
  void initState() {
    super.initState();
    _saveResult();
  }

  Future<void> _saveResult() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    String resultText = widget.testData['answer'][widget.answerIndex];
    // ... (다른 변수 선언은 동일)

    try {
      // .add() 대신 .doc(ID).set()을 사용합니다.
      await firestore.collection('test_results').doc(widget.testId).set({
        'title': widget.testData['title'],
        'result': resultText,
        'timestamp': FieldValue.serverTimestamp(),
        'orderIndex': widget.testData['orderIndex'],
      });
      log.i("결과가 성공적으로 덮어쓰기/저장되었습니다.");
    } catch (e, s) {
      log.e("결과 저장 중 오류 발생", error: e, stackTrace: s);
    }
  }

  String _calculateResult() {
    return widget.testData['answer'][widget.answerIndex];
  }

  @override
  Widget build(BuildContext context) {
    // ... (UI 부분은 변경 없음)
    String resultText = _calculateResult();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.testData['title']),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '당신의 결과는...',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                resultText,
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text('처음으로 돌아가기'),
            ),
          ],
        ),
      ),
    );
  }
}