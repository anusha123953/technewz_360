import 'package:flutter/material.dart';

import 'models/news_model.dart';
import 'widgets/news_card.dart';
import 'screens/news_detail_screen.dart';
import 'screens/ai_brief_screen.dart';
import 'services/news_api_service.dart';
import 'services/bookmark_service.dart';

const Color background = Color(0xFF080D18);
const Color surface = Color(0xFF111A2B);
const Color surfaceLight = Color(0xFF17283A);
const Color accent = Color(0xFF00D9FF);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BookmarkService.init();
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
        scaffoldBackgroundColor: background,
        colorScheme: const ColorScheme.dark(
          primary: accent,
          surface: surface,
        ),
        useMaterial3: true,
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

  void changeCategory(int index) {
    setState(() {
      selectedCategory = index;
      searchQuery = '';
    });

    loadNews(query: categoryQueries[index]);
  }

  List<NewsModel> get filteredNews {
    final query = searchQuery.trim().toLowerCase();

    if (query.isEmpty) return news;

    return news.where((article) {
      return article.title.toLowerCase().contains(query) ||
          article.category.toLowerCase().contains(query) ||
          article.source.toLowerCase().contains(query) ||
          article.description.toLowerCase().contains(query);
    }).toList();
  }

  void openArticle(NewsModel article) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NewsDetailScreen(article: article),
      ),
    );
  }

  IconData getCategoryIcon(String category) {
    switch (category.toUpperCase()) {
      case 'PROGRAMMING':
        return Icons.code_rounded;
      case 'CYBERSECURITY':
        return Icons.security_rounded;
      case 'ARTIFICIAL INTELLIGENCE':
        return Icons.smart_toy_rounded;
      case 'STARTUPS':
        return Icons.rocket_launch_rounded;
      default:
        return Icons.article_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: IndexedStack(
          index: selectedIndex,
          children: [
            buildHome(),
            buildExplore(),
            const AiBriefScreen(),
            buildMySpace(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        height: 72,
        backgroundColor: surface,
        indicatorColor: accent.withValues(alpha: 0.15),
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Discover',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore_rounded),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome),
            label: 'AI Brief',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_border_rounded),
            selectedIcon: Icon(Icons.bookmark_rounded),
            label: 'My Space',
          ),
        ],
      ),
    );
  }

  // =====================================================
  // DISCOVER SCREEN
  // =====================================================

  Widget buildHome() {
    final articles = filteredNews;
    final featuredArticle =
        articles.isNotEmpty ? articles.first : null;

    return RefreshIndicator(
      color: accent,
      backgroundColor: surface,
      onRefresh: () => loadNews(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 700;

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? 40 : 20,
              vertical: 22,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 950),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'TECHNEWZ 360',
                              style: TextStyle(
                                color: accent,
                                fontSize: 23,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'YOUR TECHNOLOGY UNIVERSE',
                              style: TextStyle(
                                color: Colors.white.withValues(
                                  alpha: 0.45,
                                ),
                                fontSize: 9,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                        _iconButton(
                          Icons.notifications_none_rounded,
                          () {},
                        ),
                      ],
                    ),

                    const SizedBox(height: 42),

                    const Text(
                      'YOUR DAILY TECH UPDATE',
                      style: TextStyle(
                        color: accent,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),

                    const SizedBox(height: 13),

                    Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(text: 'Explore what\'s\n'),
                          TextSpan(
                            text: 'next.',
                            style: const TextStyle(color: accent),
                          ),
                        ],
                      ),
                      style: TextStyle(
                        fontSize: isWide ? 52 : 42,
                        height: 1.12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.8,
                      ),
                    ),

                    const SizedBox(height: 13),

                    const Text(
                      'Technology moves fast. Stay one step ahead.',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 28),

                    _searchBar(),

                    const SizedBox(height: 35),

                    _sectionHeading('EXPLORE TOPICS'),

                    const SizedBox(height: 17),

                    _categoryList(),

                    const SizedBox(height: 38),

                    _sectionHeading('EDITOR\'S PICK'),

                    const SizedBox(height: 17),

                    if (isLoading)
                      _loadingWidget()
                    else if (errorMessage != null)
                      _errorWidget()
                    else if (featuredArticle == null)
                      _emptyWidget()
                    else
                      _featuredCard(featuredArticle),

                    const SizedBox(height: 38),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        _sectionHeading('TRENDING NOW'),
                        Text(
                          '${articles.length} STORIES',
                          style: const TextStyle(
                            color: accent,
                            fontSize: 10,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    if (!isLoading && errorMessage == null)
                      if (articles.length > 1)
                        ...articles.skip(1).map(
                          (article) => NewsCard(
                            icon: getCategoryIcon(article.category),
                            category: article.category,
                            title: article.title,
                            imageUrl: article.imageUrl,
                            source: article.source,
                            onTap: () => openArticle(article),
                          ),
                        )
                      else if (articles.length == 1)
                        const Text(
                          'You are all caught up!',
                          style: TextStyle(color: Colors.white54),
                        ),

                    const SizedBox(height: 30),

                    _footer(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // =====================================================
  // EXPLORE SCREEN
  // =====================================================

  Widget buildExplore() {
    final exploreCategories = [
      {
        'name': 'Artificial Intelligence',
        'subtitle': 'Discover intelligent technology',
        'icon': Icons.smart_toy_rounded,
        'color': const Color(0xFF00D9FF),
      },
      {
        'name': 'Programming',
        'subtitle': 'Code. Build. Create.',
        'icon': Icons.terminal_rounded,
        'color': const Color(0xFF9B8AFF),
      },
      {
        'name': 'Cybersecurity',
        'subtitle': 'Explore digital security',
        'icon': Icons.security_rounded,
        'color': const Color(0xFFFF9F43),
      },
      {
        'name': 'Startups',
        'subtitle': 'Ideas shaping tomorrow',
        'icon': Icons.rocket_launch_rounded,
        'color': const Color(0xFF57D68D),
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),

          const Text(
            'DISCOVER',
            style: TextStyle(
              color: accent,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'Explore your\ntech universe.',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              height: 1.15,
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            'Choose a topic and discover what is happening.',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 30),

          _searchBar(),

          const SizedBox(height: 32),

          _sectionHeading('POPULAR CATEGORIES'),

          const SizedBox(height: 18),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: exploreCategories.length,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 13,
              mainAxisSpacing: 13,
              childAspectRatio: 0.92,
            ),
            itemBuilder: (context, index) {
              final category = exploreCategories[index];
              final categoryColor = category['color'] as Color;

              return InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: () {
                  changeCategory(index + 1);

                  setState(() {
                    selectedIndex = 0;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(17),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: categoryColor.withValues(alpha: 0.22),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color:
                              categoryColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(
                          category['icon'] as IconData,
                          color: categoryColor,
                          size: 25,
                        ),
                      ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category['name'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            category['subtitle'] as String,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),

                      Align(
                        alignment: Alignment.centerRight,
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          color: categoryColor,
                          size: 19,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 35),

          _sectionHeading('LATEST TECHNOLOGY NEWS'),

          const SizedBox(height: 17),

          if (isLoading)
            _loadingWidget()
          else if (errorMessage != null)
            _errorWidget()
          else if (filteredNews.isEmpty)
            _emptyWidget()
          else
            ...filteredNews.take(5).map(
              (article) => NewsCard(
                icon: getCategoryIcon(article.category),
                category: article.category,
                title: article.title,
                imageUrl: article.imageUrl,
                source: article.source,
                onTap: () => openArticle(article),
              ),
            ),

          const SizedBox(height: 25),

          _footer(),
        ],
      ),
    );
  }

  // =====================================================
  // MY SPACE SCREEN
  // =====================================================

  Widget buildMySpace() {
    return ValueListenableBuilder<List<NewsModel>>(
      valueListenable: BookmarkService.savedArticles,
      builder: (context, savedArticles, child) {
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 25, 20, 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'YOUR PERSONAL LIBRARY',
                      style: TextStyle(
                        color: accent,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      'My Space.',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'Your saved stories, all in one place.',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 25),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF164D68),
                            Color(0xFF172039),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 55,
                            height: 55,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(17),
                            ),
                            child: const Icon(
                              Icons.bookmark_rounded,
                              color: accent,
                              size: 29,
                            ),
                          ),

                          const SizedBox(width: 17),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${savedArticles.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const Text(
                                  'SAVED ARTICLES',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 10,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    _sectionHeading('YOUR BOOKMARKS'),
                  ],
                ),
              ),
            ),

            if (savedArticles.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: surface,
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: const Icon(
                            Icons.bookmark_border_rounded,
                            color: accent,
                            size: 45,
                          ),
                        ),

                        const SizedBox(height: 22),

                        const Text(
                          'Your library is empty',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          'Save interesting articles and find them here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final article = savedArticles[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          decoration: BoxDecoration(
                            color: surface,
                            borderRadius: BorderRadius.circular(17),
                            border: Border.all(
                              color: accent.withValues(alpha: 0.10),
                            ),
                          ),
                          child: ListTile(
                            contentPadding:
                                const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 9,
                            ),
                            leading: const CircleAvatar(
                              backgroundColor: surfaceLight,
                              child: Icon(
                                Icons.article_outlined,
                                color: accent,
                              ),
                            ),
                            title: Text(
                              article.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                article.source,
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            onTap: () => openArticle(article),
                            trailing: IconButton(
                              tooltip: 'Remove bookmark',
                              icon: const Icon(
                                Icons.bookmark_remove_rounded,
                                color: accent,
                              ),
                              onPressed: () {
                                BookmarkService.toggleBookmark(article);
                              },
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: savedArticles.length,
                  ),
                ),
              ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 25),
            ),
          ],
        );
      },
    );
  }

  // =====================================================
  // REUSABLE WIDGETS
  // =====================================================

  Widget _iconButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: accent.withValues(alpha: 0.15),
        ),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: accent),
      ),
    );
  }

  Widget _sectionHeading(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 17,
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _searchBar() {
    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accent.withValues(alpha: 0.15),
        ),
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
        ),
        decoration: InputDecoration(
          hintText: 'Search technology, AI, startups...',
          hintStyle: const TextStyle(
            color: Colors.white38,
            fontSize: 11,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: accent,
          ),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      searchQuery = '';
                    });
                  },
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white54,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 17),
        ),
      ),
    );
  }

  Widget _categoryList() {
    return SizedBox(
      height: 43,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 9),
        itemBuilder: (context, index) {
          final selected = selectedCategory == index;

          return ChoiceChip(
            label: Text(categories[index]),
            selected: selected,
            onSelected: (_) => changeCategory(index),
            backgroundColor: surface,
            selectedColor: accent,
            side: BorderSide(
              color: selected
                  ? accent
                  : Colors.white.withValues(alpha: 0.08),
            ),
            labelStyle: TextStyle(
              color: selected ? background : Colors.white70,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          );
        },
      ),
    );
  }

  Widget _featuredCard(NewsModel article) {
    return GestureDetector(
      onTap: () => openArticle(article),
      child: Container(
        height: 270,
        width: double.infinity,
        decoration: BoxDecoration(
          color: surfaceLight,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: accent.withValues(alpha: 0.20),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (article.imageUrl.trim().isNotEmpty)
                Image.network(
                  article.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      _featuredPlaceholder(),
                )
              else
                _featuredPlaceholder(),

              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.35),
                      Colors.black.withValues(alpha: 0.95),
                    ],
                  ),
                ),
              ),

              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'TOP STORY',
                    style: TextStyle(
                      color: background,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),

              Positioned(
                left: 18,
                right: 18,
                bottom: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.category.toUpperCase(),
                      style: const TextStyle(
                        color: accent,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      article.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        height: 1.3,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.public,
                          color: accent,
                          size: 14,
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            article.source,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: accent,
                          size: 18,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _featuredPlaceholder() {
    return Container(
      color: surfaceLight,
      alignment: Alignment.center,
      child: const Icon(
        Icons.auto_awesome_rounded,
        color: accent,
        size: 60,
      ),
    );
  }

  Widget _loadingWidget() {
    return const SizedBox(
      height: 180,
      child: Center(
        child: CircularProgressIndicator(
          color: accent,
        ),
      ),
    );
  }

  Widget _emptyWidget() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.article_outlined,
            color: accent,
            size: 38,
          ),
          SizedBox(height: 12),
          Text(
            'No articles found',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 7),
          Text(
            'Try another topic or refresh the news.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white54,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorWidget() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            color: accent,
            size: 35,
          ),
          const SizedBox(height: 12),
          const Text(
            'Unable to load news',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => loadNews(),
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _footer() {
    return Center(
      child: Text(
        'POWERED BY TECHNEWZ 360',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.3),
          fontSize: 9,
          letterSpacing: 2,
        ),
      ),
    );
  }
}