import 'package:flutter/material.dart';

class HighlightedText extends StatelessWidget {
  final String fullText;
  final String query;
  final TextStyle style;
  final Color highlightColor;

  const HighlightedText({
    super.key,
    required this.fullText,
    required this.query,
    this.style = const TextStyle(color: Colors.black, fontSize: 16),
    this.highlightColor = Colors.yellow,
  });

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty || !fullText.toLowerCase().contains(query.toLowerCase())) {
      return Text(fullText, style: style.copyWith(fontWeight: FontWeight.bold));
    }

    final List<TextSpan> spans = [];
    final String lowercaseFull = fullText.toLowerCase();
    final String lowercaseQuery = query.toLowerCase();

    int start = 0;
    int indexOfMatch;

    // Loop to find all occurrences of the query
    while ((indexOfMatch = lowercaseFull.indexOf(lowercaseQuery, start)) != -1) {
      // 1. Add text before the match
      if (indexOfMatch > start) {
        spans.add(TextSpan(text: fullText.substring(start, indexOfMatch)));
      }

      // 2. Add the highlighted match
      spans.add(
        TextSpan(
          text: fullText.substring(indexOfMatch, indexOfMatch + query.length),
          style: style.copyWith(
            backgroundColor: highlightColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

      start = indexOfMatch + query.length;
    }

    // 3. Add any remaining text after the last match
    if (start < fullText.length) {
      spans.add(TextSpan(text: fullText.substring(start)));
    }

    return RichText(
      text: TextSpan(style: style, children: spans),
    );
  }
}