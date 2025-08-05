import 'package:flutter/material.dart';
import 'package:plantify/models/plants_model.dart';
import 'package:plantify/theme/color.dart';

class ResultSearch extends StatelessWidget {
  final List<PlantModel> listItems;
  const ResultSearch({super.key, required this.listItems});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30),
      height: 150,
      child: ListView.separated(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        itemCount: listItems.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10), // spacing nhỏ
        itemBuilder: (context, index) {
          return Container(
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
                  listItems[index].name,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}