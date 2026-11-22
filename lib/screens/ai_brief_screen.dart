import 'package:flutter/material.dart';
import '../services/ai_brief_service.dart';

class AiBriefScreen extends StatefulWidget {
  const AiBriefScreen({super.key});

  @override
  State<AiBriefScreen> createState() => _AiBriefScreenState();
}

class _AiBriefScreenState extends State<AiBriefScreen> {
  final AiBriefService _service = AiBriefService();

  String selectedCategory = 'all';
  String brief = '';
  bool isLoading = false;
  String? errorMessage;
  String? generatedAt;

  final List<Map<String, String>> categories = [
    {'name': 'All', 'value': 'all'},
    {'name': 'Technology', 'value': 'technology'},
    {'name': 'AI', 'value': 'ai'},
    {'name': 'Cybersecurity', 'value': 'cybersecurity'},
    {'name': 'Business', 'value': 'business'},
    {'name': 'Science', 'value': 'science'},
  ];

  @override
  void initState() {
    super.initState();
    generateBrief();
  }

  Future<void> generateBrief() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      brief = '';
    });

    try {
      final result = await _service.fetchBrief(selectedCategory);

      if (!mounted) return;

      setState(() {
        brief = result['brief']?.toString() ?? '';
        generatedAt = result['generatedAt']?.toString();
        isLoading = false;

        if (brief.isEmpty) {
          errorMessage = 'No AI Brief was generated.';
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF10121A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF10121A),
        elevation: 0,
        title: const Text(
          'AI Brief',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF252B50),
                      Color(0xFF171D35),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: Color(0xFF9C9FFF),
                      size: 32,
                    ),
                    SizedBox(height: 14),
                    Text(
                      'Your Daily Tech Intelligence',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Understand important news with AI-powered summaries.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                'Choose Category',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 14),

              Wrap(
                spacing: 9,
                runSpacing: 10,
                children: categories.map((category) {
                  final isSelected =
                      selectedCategory == category['value'];

                  return ChoiceChip(
                    label: Text(category['name']!),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        selectedCategory = category['value']!;
                      });
                      generateBrief();
                    },
                    selectedColor: const Color(0xFF777BFF),
                    backgroundColor: const Color(0xFF222536),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : Colors.white70,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 25),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Generated Brief',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: isLoading ? null : generateBrief,
                    icon: const Icon(
                      Icons.refresh,
                      color: Color(0xFF9C9FFF),
                    ),
                    tooltip: 'Refresh brief',
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1E2B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white12,
                  ),
                ),
                child: buildBriefContent(),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildBriefContent() {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(30),
        child: Center(
          child: Column(
            children: [
              CircularProgressIndicator(
                color: Color(0xFF9C9FFF),
              ),
              SizedBox(height: 15),
              Text(
                'Generating your AI Brief...',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      );
    }

    if (errorMessage != null) {
      return Column(
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.orangeAccent,
            size: 40,
          ),
          const SizedBox(height: 12),
          Text(
            errorMessage!,
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: generateBrief,
            child: const Text('Try Again'),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (generatedAt != null)
          Text(
            'Generated: $generatedAt',
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 11,
            ),
          ),
        const SizedBox(height: 15),
        SelectableText(
          brief,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            height: 1.7,
          ),
        ),
      ],
    );
  }
}