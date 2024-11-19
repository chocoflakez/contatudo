import 'package:contatudo/app_config.dart';
import 'package:contatudo/screens/profile_screen.dart';
import 'package:flutter/material.dart';

class MyMainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const MyMainAppBar({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.primaryText,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: AppColors.appBarColor,
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class MyHomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const MyHomeAppBar({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.primaryText,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: AppColors.appBarColor,
      centerTitle: true,
      actions: [
        IconButton(
          icon: CircleAvatar(
            backgroundColor: AppColors.accentColor.withOpacity(0.1),
            child: const Icon(Icons.account_circle_outlined,
                color: AppColors.primaryText),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileScreen()),
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
