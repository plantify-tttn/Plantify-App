import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plantify/l10n/locale_provider.dart';
import 'package:plantify/models/plants_model.dart';
import 'package:plantify/pages/plants/image_carousel.dart';
import 'package:plantify/theme/color.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class PlantDetailPage extends StatelessWidget {
  final PlantModel plant;
  const PlantDetailPage({super.key, required this.plant});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(plant.localizedName(locale)),
          leading: IconButton(
            onPressed: (){
              context.pop();
            }, 
            icon: Icon(Icons.arrow_back)
          ),
          actions: [
          IconButton(
            icon: const Icon(Icons.language),
            tooltip: 'Change Language',
            onPressed: () {
              final localeProvider = context.read<LocaleProvider>();
              final isVietnamese = locale.languageCode == 'vi';
      
              localeProvider.setLocale(Locale(isVietnamese ? 'en' : 'vi'));
            },
          ),
        ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (plant.images.isNotEmpty)
                ImageCarousel(imageUrls: plant.images),
      
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "🌿${AppLocalizations.of(context)!.overview}",
                  style: TextStyle(
                    color: Color(MyColor.pr1),
                    fontSize: 25,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  plant.localizedOverview(locale),
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontSize: 16, 
                    height: 1.6,
                  ),
                ),
              ),
      
              const SizedBox(height: 20),
              if (plant.localizedSeed(locale).isNotEmpty) ...[
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "🌰 ${AppLocalizations.of(context)!.seed}", 
                    style: TextStyle(
                      color: Color(MyColor.pr1),
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildHighlightBox(
                  plant.localizedSeed(locale),
                  icon: Icons.spa, 
                  backgroundColor: Colors.teal.shade100,
                ),
              ],
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "🌱 ${AppLocalizations.of(context)!.characteristics}",
                  style: TextStyle(
                    color: Color(MyColor.pr1),
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildKeyValueCards(
                plant.localizedCharacteristics(locale),
                Colors.green.shade100,
                section: 'characteristics',
                context: context,
              ),
      
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "🧑‍🌾 ${AppLocalizations.of(context)!.cultivation}",
                  style: TextStyle(
                    color: Color(MyColor.pr1),
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildKeyValueCards(
                plant.localizedCultivation(locale),
                Colors.brown.shade100,
                section: 'cultivation',
                context: context,
              ),
      
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "☀️ ${AppLocalizations.of(context)!.season}",
                  style: TextStyle(
                    color: Color(MyColor.pr1),
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildHighlightBox(
                plant.localizedSeason(locale),
                icon: Icons.calendar_month,
                backgroundColor: Colors.orange.shade100,
              ),
      
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "📝 ${AppLocalizations.of(context)!.note}",
                  style: TextStyle(
                    color: Color(MyColor.pr1),
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildHighlightBox(
                plant.localizedNote(locale),
                icon: Icons.info_outline,
                backgroundColor: Colors.blue.shade100,
              ),
      
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHighlightBox(String text, {required IconData icon, required Color backgroundColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 28, color: Color(MyColor.black),),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 16, height: 1.5, color: Color(MyColor.black)),
              ),
            ),
          ],
        ),
      ),
    );
  }
  String getLocalizedKeyLabel(String key, String section, BuildContext context) {
    final local = AppLocalizations.of(context)!;

    if (section == 'characteristics') {
      switch (key) {
        case 'height':
          return local.height; 
        case 'growthDuration':
          return local.growthDuration; 
        case 'leafColor':
          return local.leafColor;
        case 'rootType':
          return local.rootType; 
      }
    } else if (section == 'cultivation') {
      switch (key) {
        case 'soil':
          return local.soil; 
        case 'climate':
          return local.climate; 
        case 'watering':
          return local.watering; 
        case 'fertilizer':
          return local.fertilizer;
      }
    }
    return key;
  }
  Widget _buildKeyValueCards(
      Map<String, String> map, Color backgroundColor,
      {required String section, required BuildContext context}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: map.entries.map((entry) {
          final keyLabel = getLocalizedKeyLabel(entry.key, section, context);
          return Card(
            color: backgroundColor,
            margin: const EdgeInsets.symmetric(vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: Text(
                keyLabel,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 33, 105, 0),
                ),
              ),
              subtitle: Text(
                entry.value,
                style: const TextStyle(color: Color(MyColor.black)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

}
