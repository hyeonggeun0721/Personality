import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import '../test/test_page.dart';
import '../result/results_history_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  State<MainPage> createState() => _MainPage();
}

class _MainPage extends State<MainPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // 1. Remote Config 인스턴스 가져오기
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  // 2. Remote Config로 제어할 변수들
  String welcomeTitle = "심리 테스트"; // 기본값 설정
  bool bannerUse = false;        // 기본값 설정
  double itemHeight = 100.0;      // ListTile의 기본 높이에 맞춰 기본값 수정

  @override
  void initState() {
    super.initState();
    // 3. 위젯이 생성될 때 Remote Config 설정 및 값 가져오기
    _setupRemoteConfig();
  }

  // 4. Remote Config를 설정하고 값을 가져오는 함수
  Future<void> _setupRemoteConfig() async {
    // 원활한 테스트를 위해 fetch 간격을 짧게 설정 (실제 출시 시에는 더 길게 설정)
    await _remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: const Duration(seconds: 10),
    ));

    // 5. 앱 내 기본값 설정 (서버에서 값을 못 가져올 경우 대비)
    await _remoteConfig.setDefaults(const {
      "welcome_title": "심리 테스트",
      "banner_use": false,
      "item_height": 100,
    });

    // 6. 서버에서 최신 값을 가져와서 활성화
    await _fetchAndActivateRemoteConfig();
  }

  Future<void> _fetchAndActivateRemoteConfig() async {
    try {
      await _remoteConfig.fetchAndActivate();

      // 7. 가져온 값으로 상태 변수 업데이트
      setState(() {
        welcomeTitle = _remoteConfig.getString('welcome');
        bannerUse = _remoteConfig.getBool('banner');
        itemHeight = _remoteConfig.getDouble('item_height');
      });
    } catch (e) {
      // 에러 처리
      print('Remote Config fetch failed: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 8. Remote Config에서 받아온 제목 사용
        title: Text(welcomeTitle),
      ),
      body: Column(
        children: [
          // 9. Remote Config의 banner_use 값에 따라 배너 표시 여부 결정
          if (bannerUse)
            Container(
              color: Colors.amber,
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              child: const Center(
                child: Text('서버에서 제어하는 배너입니다!', style: TextStyle(color: Colors.black)),
              ),
            ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
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

                    if (testData.containsKey('title') && testData['title'] != null && testData['title'].toString().isNotEmpty) {
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TestPage(testId: test.id),
                            ),
                          );
                        },
                        // 10. Card를 SizedBox로 감싸 높이를 Remote Config 값으로 제어
                        child: SizedBox(
                          height: itemHeight, // double 타입이어야 함
                          child: Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Center( // ListTile 대신 Center로 텍스트를 중앙에 배치
                              child: Text(
                                testData['title'].toString(),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
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