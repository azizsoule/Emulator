import 'package:flutter/material.dart';

class EmulatorItemWidget extends StatelessWidget {
  final void Function() onTap;
  final String image;

  const EmulatorItemWidget({
    super.key,
    required this.onTap,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 100,
        width: double.infinity,
        child: ClipRRect(
          borderRadius: const BorderRadius.all(
            Radius.circular(
              16,
            ),
          ),
          child: Image.asset(
            image,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
