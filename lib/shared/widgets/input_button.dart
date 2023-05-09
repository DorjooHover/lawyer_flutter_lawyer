import 'package:flutter/material.dart';
import 'package:frontend/shared/index.dart';

class InputButton extends StatelessWidget {
  const InputButton(
      {Key? key,
      required this.onPressed,
      required this.icon,
      required this.text,
      this.disabled = false})
      : super(key: key);

  final String text;

  final void Function() onPressed;
  final IconData icon;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
            elevation: 0,
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: line))),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: Theme.of(context)
                  .textTheme
                  .displayMedium!
                  .copyWith(color: gray),
            ),
            const Icon(
              Icons.arrow_drop_down,
              color: gray,
            )
          ],
        ));
  }
}
