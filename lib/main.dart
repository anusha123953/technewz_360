
import 'package:flutter/material.dart';

import 'models/news_model.dart';
import 'widgets/news_card.dart';
import 'screens/news_detail_screen.dart';
import 'services/news_api_service.dart';

void main() {
  runApp(const TechNewzApp());
}

class TechNewzApp extends StatelessWidget {
  const TechNewzApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TECHNEWZ 360',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF080D18),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00D9FF),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;
  int selectedCategory = 0;

  String searchQuery = '';

  final NewsApiService newsApiService = NewsApiService();

  List<NewsModel> news = [];

  bool isLoading = true;
  String? errorMessage;

  final List<String> categories = [
    'All',
    'AI',
    'Programming',
    'Cybersecurity',
    'Startups',
  ];

  final List<String> categoryQueries = [
    'technology',
    'artificial intelligence OR machine learning OR ChatGPT',
    'programming OR software development OR coding',
    'cybersecurity OR hacking OR ransomware OR data breach',
    'startups OR startup funding OR entrepreneurship',
  ];

  @override
  void initState() {
    super.initState();
    loadNews();
  }

  // FETCH NEWS FROM BACKEND
  Future<void> loadNews({String? query}) async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final articles = await newsApiService.fetchNews(
        query: query ?? categoryQueries[selectedCategory],
      );

      if (!mounted) return;

      setState(() {
        news = articles;
        isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = error.toString();
        isLoading = false;
      });
    }
  }

  // CHANGE CATEGORY
  void changeCategory(int index) {
    setState(() {
      selectedCategory = index;
      searchQuery = '';
    });

    loadNews(query: categoryQueries[index]);
  }

  // SEARCH NEWS
  List<NewsModel> get filteredNews {
    List<NewsModel> result = news;

    final query = searchQuery.trim().toLowerCase();

    if (query.isNotEmpty) {
      result = result.where((article) {
        return article.title.toLowerCase().contains(query) ||
            article.category.toLowerCase().contains(query) ||
            article.source.toLowerCase().contains(query) ||
            article.description.toLowerCase().contains(query);
      }).toList();
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080D18),
      body: SafeArea(
        child: IndexedStack(
          index: selectedIndex,
          children: [
            buildHome(),
            buildPlaceholder('Explore', Icons.explore),
            buildPlaceholder('AI Brief', Icons.auto_awesome),
            buildPlaceholder('My Space', Icons.person),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF111A2B),
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'Discover',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            label: 'AI Brief',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'My Space',
          ),
        ],
      ),
    );
  }

  // DISCOVER SCREEN
  Widget buildHome() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding =
            constraints.maxWidth < 350 ? 14.0 : 20.0;

        return SingleChildScrollView(
          padding: EdgeInsets.all(horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // APP HEADER
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            'TECHNEWZ 360',
                            style: TextStyle(
                              color: Color(0xFF00D9FF),
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'YOUR TECHNOLOGY UNIVERSE',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 10,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const CircleAvatar(
                    radius: 21,
                    backgroundColor: Color(0xFF17283A),
                    child: Icon(
                      Icons.notifications_none,
                      color: Color(0xFF00D9FF),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 35),

              const Text(
                'STAY AHEAD.',
                style: TextStyle(
                  color: Color(0xFF00D9FF),
                  letterSpacing: 3,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Explore the future.',
                style: TextStyle(
                  fontSize: 29,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 22),

              // SEARCH BAR
              TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search your tech universe...',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF00D9FF),
                  ),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              searchQuery = '';
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: const Color(0xFF111A2B),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                'EXPLORE TOPICS',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),

              const SizedBox(height: 15),

              // CATEGORY FILTERS
              SizedBox(
                height: 50,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    return ChoiceChip(
                      label: Text(categories[index]),
                      selected: selectedCategory == index,
                      selectedColor: const Color(0xFF00D9FF),
                      backgroundColor: const Color(0xFF172033),
                      labelStyle: TextStyle(
                        color: selectedCategory == index
                            ? Colors.black
                            : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                      onSelected: (_) {
                        changeCategory(index);
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                'TODAY\'S SPOTLIGHT',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),

              const SizedBox(height: 15),

              // SPOTLIGHT CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF164D68),
                      Color(0xFF172039),
                      Color(0xFF111A2B),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Icon(
                      Icons.auto_awesome,
                      color: Color(0xFF00D9FF),
                      size: 35,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'THE FUTURE IS HERE',
                      style: TextStyle(
                        color: Color(0xFF00D9FF),
                        letterSpacing: 2,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Artificial Intelligence is changing the world.',
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Discover what is happening in technology.',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // TRENDING HEADER
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 8,
                children: [
                  const Text(
                    'TRENDING NOW',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    '${filteredNews.length} ARTICLES',
                    style: const TextStyle(
                      color: Color(0xFF00D9FF),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // LOADING
              if (isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: CircularProgressIndicator(
                      color: Color(0xFF00D9FF),
                    ),
                  ),
                )

              // ERROR
              else if (errorMessage != null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.wifi_off,
                          color: Color(0xFF00D9FF),
                          size: 40,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Unable to load news.',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 15),
                        ElevatedButton.icon(
                          onPressed: () => loadNews(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )

              // EMPTY
              else if (filteredNews.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'No articles found. Try another topic.',
                      style: TextStyle(color: Colors.white54),
                    ),
                  ),
                )

              // NEWS CARDS WITH REAL IMAGES AND SOURCES
              else
                ...filteredNews.map((article) {
                  return NewsCard(
                    icon: getCategoryIcon(article.category),
                    category: article.category,
                    title: article.title,
                    imageUrl: article.imageUrl,
                    source: article.source,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return NewsDetailScreen(
                              article: article,
                            );
                          },
                        ),
                      );
                    },
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  // CATEGORY ICONS
  IconData getCategoryIcon(String category) {
    switch (category) {
      case 'PROGRAMMING':
        return Icons.code;
      case 'CYBERSECURITY':
        return Icons.security;
      case 'ARTIFICIAL INTELLIGENCE':
        return Icons.smart_toy;
      case 'STARTUPS':
        return Icons.business;
      default:
        return Icons.article;
    }
  }

  // PLACEHOLDER SCREENS
  Widget buildPlaceholder(String title, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: const Color(0xFF00D9FF),
            size: 60,
          ),
          const SizedBox(height: 15),
          Text(
            title,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Coming soon...',
            style: TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }
}
