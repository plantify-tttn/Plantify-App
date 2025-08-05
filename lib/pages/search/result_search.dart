import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plantify/apps/router/router_name.dart';
import 'package:plantify/models/plants_model.dart';
import 'package:plantify/theme/color.dart';

class ResultSearch extends StatelessWidget {
  final List<PlantModel> listItems;
  final TextEditingController searchController;
  const ResultSearch({super.key, required this.listItems, required this.searchController});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    if(searchController.text.isEmpty){
      return Container();
    } else{
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 30),
        height: 150,
        child: ListView.separated(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          itemCount: listItems.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10), // spacing nhỏ
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                context.goNamed(RouterName.detailPlant, extra: listItems[index]);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      width: 1,
                      color: Color(MyColor.grey)
                    )
                  )
                ),
                child: Row(
                  children: [
                    Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: NetworkImage(listItems[index].images[0]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5,),
                    Text(
                      listItems[index].localizedName(locale),
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }
  }
}