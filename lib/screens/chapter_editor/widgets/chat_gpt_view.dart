import 'package:auto_size_text/auto_size_text.dart';
import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teia/views/misc/tile.dart';
import 'package:teia/views/teia_button.dart';

enum Language {
  english,
  portuguesePortugal;

  String get name {
    switch (this) {
      case Language.english:
        return 'english';
      case Language.portuguesePortugal:
        return 'portuguese from Portugal';
    }
  }

  String get code {
    switch (this) {
      case Language.english:
        return 'EN';
      case Language.portuguesePortugal:
        return 'PT';
    }
  }
}

class ChatGPTView extends StatelessWidget {
  const ChatGPTView({
    super.key,
    required this.idea,
    required this.getIdea,
    required this.loadingPrefs,
    required this.storedLanguage,
    required this.onSelectLanguage,
    required this.accentColor,
  });

  final String idea;
  final Function() getIdea;
  final bool loadingPrefs;
  final Language storedLanguage;
  final Function(Language language) onSelectLanguage;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Tile(
      width: double.infinity,
      radiusAll: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Row(
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 24.0,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: AutoSizeText(
                    'Need inspiration?',
                    minFontSize: 8,
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            loadingPrefs
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : SizedBox(
                    width: double.infinity,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.start,
                      runAlignment: WrapAlignment.start,
                      crossAxisAlignment: WrapCrossAlignment.start,
                      children: [
                        for (final language in Language.values)
                          FilterChip(
                            label: CountryFlag.fromLanguageCode(
                              language.code,
                              width: 24,
                              height: 16,
                            ),
                            selected: storedLanguage == language,
                            onSelected: (value) => onSelectLanguage(language),
                          )
                      ],
                    ),
                  ),
            const SizedBox(height: 12),
            TeiaButton(
              text: 'Get an idea',
              onTap: getIdea,
              color: accentColor,
            ),
            idea.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: SelectableText(
                      idea,
                      style: const TextStyle(color: Colors.black, fontSize: 13),
                      textAlign: TextAlign.start,
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
