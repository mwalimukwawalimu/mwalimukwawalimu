import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mwalimukwawalimu/common/card.dart';
import 'package:mwalimukwawalimu/common/constants.dart';
import 'package:mwalimukwawalimu/screens/ask_questions.dart';
import 'package:mwalimukwawalimu/features/search.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _questions = [];
  String? _username;

  Future<void> _getUsername() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String uid = user.uid;
        DocumentSnapshot userDoc =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();

        if (userDoc.exists) {
          setState(() {
            _username = userDoc['username'];
          });
        } else {
          debugPrint('User document not found');
        }
      }
    } catch (e) {
      debugPrint('Error fetching username: $e');
    }
  }

  Future<void> _fetchQuestions() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('questions').get();

      final List<Map<String, dynamic>> fetchedQuestions =
          snapshot.docs.map((doc) {
        Timestamp timestamp = doc['createdAt'];
        DateTime dateTime = timestamp.toDate().toUtc();

        return {
          'id': doc.id,
          'questionText': doc['questionText'],
          'author': doc['authorId'] ?? 'Anonymous',
          'authorId': doc['authorId'] ?? 'Anonymous',
          'topicId': doc['topicId'],
          'createdAt': dateTime.toIso8601String().split('T').first,
        };
      }).toList();

      setState(() {
        _questions = fetchedQuestions;
      });
    } catch (e) {
      debugPrint("Error fetching questions: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load questions.')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
    _getUsername();
  }

  void _addNewQuestion(String questionText, String topic) {
    setState(() {
      _questions.insert(0, {
        'questionText': questionText,
        'author': 'You',
        'createdAt': DateTime.now().toString(),
        'topicId': topic,
        'id': '',
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepPurpleAccent,
          title: Center(
            child: Text(
              _username != null ? 'Hello $_username 👋' : 'Hello 👋',
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AskQuestionPage(onPost: _addNewQuestion),
              ),
            );
          },
          backgroundColor: Colors.purple,
          child: Image.asset(
            'assets/images/ask (1).png',
            width: 50,
            height: 50,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              expandedHeight: 350,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: _buildHeaderSection(),
                title: const Text(''),
                centerTitle: true,
              ),
              bottom: const TabBar(
                labelColor: kPrimary,
                unselectedLabelColor: Colors.grey,
                indicatorColor: kOffWhite,
                indicatorWeight: 4.0,
                tabs: [
                  Tab(text: 'Questions'),
                  Tab(text: 'Trending'),
                  Tab(text: 'Topics'),
                ],
              ),
            ),
            SliverFillRemaining(
              child: TabBarView(
                children: [
                  // Replace SliverList with ListView
                  ListView.builder(
                    itemCount: _questions.length,
                    itemBuilder: (context, index) {
                      String time =
                          _questions[index]['createdAt'] ?? 'Unknown time';
                      return FutureBuilder<String?>(
                        future: getUsernameById(_questions[index]['author']),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          String author = snapshot.data ?? 'Anonymous';
                          return CustomCard(
                            questionId: _questions[index]['id'] ?? '',
                            question: _questions[index]['questionText'] ??
                                'No question text',
                            authorId: _questions[index]['authorId'] ?? '0',
                            author: author,
                            time: time,
                            docid: _questions[index]['id'] ?? '',
                            onPressed: () {},
                          );
                        },
                      );
                    },
                  ),
                  const Center(child: Text('Trending content here')),
                  const Center(child: Text('Topics content here')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Stack(
      children: [
        Container(
          height: 350,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurpleAccent, Colors.black],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          padding: const EdgeInsets.only(top: 110, left: 16, right: 16),
          child: Column(
            children: [
              const Text(
                'What do you want to ask today?',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              _buildSearchBar(),
              const SizedBox(height: 20),
              _buildTags(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: ListTile(
        leading: const Icon(Icons.search, color: Colors.grey),
        title: const Text(
          'Just ask your question...',
          style: TextStyle(color: Colors.grey),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SearchScreen()),
          );
        },
      ),
    );
  }

  Widget _buildTags() {
    const tags = ['JavaScript', 'Web Development', 'WordPress', 'Frontend'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: tags.map((tag) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Chip(
              label: Text(tag),
              backgroundColor: Colors.grey[300],
            ),
          );
        }).toList(),
      ),
    );
  }

  Future<String?> getUsernameById(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        return userDoc['username'] as String?;
      } else {
        print('User document not found');
        return null;
      }
    } catch (e) {
      print('Error fetching username: $e');
      return null;
    }
  }
}

