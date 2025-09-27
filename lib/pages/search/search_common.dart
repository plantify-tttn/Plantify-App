import 'package:flutter/material.dart';
import 'package:plantify/theme/color.dart';

class ResultContainer extends StatelessWidget {
  final Widget child;
  const ResultContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 0,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: child,
      ),
    );
  }
}

class SearchTile extends StatelessWidget {
  final String title;
  final String query;
  final String? imageUrl;
  final IconData fallbackIcon;
  final VoidCallback onTap;

  const SearchTile({
    super.key,
    required this.title,
    required this.query,
    required this.imageUrl,
    required this.fallbackIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12);

    return InkWell(
      onTap: onTap,
      borderRadius: radius,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: radius,
              child: SizedBox(
                width: 44,
                height: 44,
                child: imageUrl == null
                    ? Container(
                        color: Colors.grey.shade200,
                        child: Icon(fallbackIcon, color: Colors.grey.shade600),
                      )
                    : Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey.shade200,
                          child: Icon(fallbackIcon, color: Colors.grey.shade600),
                        ),
                        loadingBuilder: (ctx, child, progress) {
                          if (progress == null) return child;
                          return Container(color: Colors.grey.shade200);
                        },
                      ),
              ),
            ),
            const SizedBox(width: 10),

            Expanded(
              child: HighlightedText(
                text: title,
                query: query,
                baseStyle: TextStyle(
                  fontSize: 16,
                  height: 1.4,
                  color: Theme.of(context).colorScheme.onSurface, 
                ),
                highlightStyle: TextStyle(
                  color: Color(MyColor.pr1),                  
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  height: 1.4,
                ),
                maxLines: 1,                                   
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: Colors.grey.shade500, size: 22),
          ],
        ),
      ),
    );
  }
}

class HighlightedText extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle baseStyle;
  final TextStyle highlightStyle;
  final int maxLines;
  final TextOverflow overflow;

  const HighlightedText({
    super.key,
    required this.text,
    required this.query,
    required this.baseStyle,
    required this.highlightStyle,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
  });

  @override
  Widget build(BuildContext context) {
    final base = baseStyle.copyWith(
      color: baseStyle.color ?? Theme.of(context).colorScheme.onSurface,
    );
    final hi = highlightStyle.copyWith(
      color: highlightStyle.color ?? Theme.of(context).colorScheme.primary,
    );

    if (query.isEmpty) {
      return Text(text, style: base, maxLines: maxLines, overflow: overflow);
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();

    final spans = <TextSpan>[];
    int start = 0;
    while (true) {
      final index = lowerText.indexOf(lowerQuery, start);
      if (index < 0) {
        spans.add(TextSpan(text: text.substring(start), style: base));
        break;
      }
      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index), style: base));
      }
      spans.add(TextSpan(
        text: text.substring(index, index + lowerQuery.length),
        style: hi,
      ));
      start = index + lowerQuery.length;
    }

    return RichText(
      text: TextSpan(children: spans),
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}


class EmptyState extends StatelessWidget {
  final String text;
  const EmptyState({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      alignment: Alignment.center,
      child: Opacity(
        opacity: 0.75,
        child: Text(
          text,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
      ),
    );
  }
}
