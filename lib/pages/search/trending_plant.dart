import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plantify/apps/router/router_name.dart';
import 'package:plantify/models/plants_model.dart';
import 'package:plantify/theme/color.dart';

class TrendingPlant extends StatelessWidget {
  final List<PlantModel> listItems;
  const TrendingPlant({super.key, required this.listItems});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: listItems.length,
      itemBuilder: (context, index){
        return trendingCard(context,listItems[index]);
      }
    );
  }
  Widget trendingCard( BuildContext context,PlantModel plant){
    final locale = Localizations.localeOf(context);
    return GestureDetector(
      onTap: () {
        context.goNamed(RouterName.detailPlant, extra: plant);
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Color(MyColor.pr4)
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                      plant.images[1],
                    ),
                    fit: BoxFit.fill
                  )
                ),
              )
            ),
            Container(
              height: 40,
              color: Colors.transparent,
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  plant.localizedName(locale),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Color(MyColor.black)
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}