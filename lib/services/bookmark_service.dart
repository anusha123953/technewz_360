
import 'package:flutter/foundation.dart';
import '../models/news_model.dart';

class BookmarkService {
  static final ValueNotifier<List<NewsModel>> savedArticles =
      ValueNotifier<List<NewsModel>>([]);

  static bool isSaved(NewsModel article) {
    return savedArticles.value.any(
      (item) => item.id == article.id,
    );
  }

  static void toggleBookmark(NewsModel article) {
    final updatedList = List<NewsModel>.from(savedArticles.value);

    if (isSaved(article)) {
      updatedList.removeWhere((item) => item.id == article.id);
    } else {
      updatedList.add(article);
    }

    savedArticles.value = updatedList;
  }
}
