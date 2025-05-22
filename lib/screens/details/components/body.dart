import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:plantapp/constants.dart';
import 'package:plantapp/screens/details/components/icon_card.dart';
import 'package:plantapp/screens/details/components/images_and_icons.dart';

class Body extends StatelessWidget {
  const Body({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
        children: [
          ImagesAndIcons(size: size),
          TitleAndPrice(title: "Angelica", country: "Russia", price: 440),
        ],
      ),
    );
  }
}

class TitleAndPrice extends StatelessWidget {
  const TitleAndPrice({
    super.key,
    required this.title,
    required this.country,
    required this.price,
  });

  final String title, country;
  final int price;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
      child: Row(
        children: <Widget>[
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "$title\n",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: kTextColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: country,
                  style: TextStyle(
                    fontSize: 20,
                    color: kPrimaryColor,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
          Spacer(),
          Text(
            "\$$price",
            style: Theme.of(
              context,
            ).textTheme.headlineLarge?.copyWith(color: kPrimaryColor),
          ),
        ],
      ),
    );
  }
}
