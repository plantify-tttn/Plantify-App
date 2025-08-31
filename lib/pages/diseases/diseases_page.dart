import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plantify/l10n/locale_provider.dart';
import 'package:plantify/models/disease_model.dart';
import 'package:plantify/pages/plants/image_carousel.dart';
import 'package:plantify/theme/color.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class DiseasesPage extends StatelessWidget {
  final DiseaseModel disease;
  const DiseasesPage({super.key, required this.disease});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(disease.localizedName(locale)),
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
              if (disease.images.isNotEmpty)
                ImageCarousel(imageUrls: disease.images),
      
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
                  disease.localizedDescription(locale),
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontSize: 16, 
                    height: 1.6,
                  ),
                ),
              ),
      
              const SizedBox(height: 20),
      
              // ☀️ causes
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "🦠 ${AppLocalizations.of(context)!.causes}",
                  style: TextStyle(
                    color: Colors.red.shade400,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildHighlightBox(
                disease.localizedCauses(locale),
                icon: Icons.biotech_rounded,
                backgroundColor: Colors.red.shade50,
              ),
              // ☀️ symptoms
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "🍂 ${AppLocalizations.of(context)!.symptoms}",
                  style: TextStyle(
                    color: Colors.orange.shade400,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildHighlightBox(
                disease.localizedSymptoms(locale),
                icon: Icons.warning_amber_rounded,
                backgroundColor: Colors.orange.shade50,
              ),
              // ☀️ prevention
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "🛡️ ${AppLocalizations.of(context)!.prevention}",
                  style: TextStyle(
                    color: Colors.teal.shade400,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildHighlightBox(
                disease.localizedPrevention(locale),
                icon: Icons.verified_user_rounded,
                backgroundColor: Colors.teal.shade50,
              ),
      
              // ☀️ treatment
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "🧴 ${AppLocalizations.of(context)!.treatment}",
                  style: TextStyle(
                    color: Colors.green.shade400,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildHighlightBox(
                disease.localizedTreatment(locale),
                icon: Icons.healing_rounded,
                backgroundColor: Colors.green.shade50,
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
          return local.height; // "Chiều cao"
        case 'growthDuration':
          return local.growthDuration; // "Thời gian sinh trưởng"
        case 'leafColor':
          return local.leafColor; // "Màu lá"
        case 'rootType':
          return local.rootType; // "Loại rễ"
      }
    } else if (section == 'cultivation') {
      switch (key) {
        case 'soil':
          return local.soil; // "Đất"
        case 'climate':
          return local.climate; // "Khí hậu"
        case 'watering':
          return local.watering; // "Tưới nước"
        case 'fertilizer':
          return local.fertilizer; // "Phân bón"
      }
    }
    return key; // fallback
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
                  color: const Color.fromARGB(255, 33, 105, 0), // ✅ Màu cho key
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
