import 'package:flutter/material.dart';


class LoadingSpinner extends StatelessWidget {
  final String? message;
  final double spinnerSize;
  final bool fullScreen;

  const LoadingSpinner({
    super.key,
    this.message,
    this.spinnerSize = 50,
    this.fullScreen = true,
  });

  @override
  Widget build(BuildContext context) {
    final widget = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: spinnerSize,
            height: spinnerSize,
            child: const CircularProgressIndicator(
              strokeWidth: 3,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                message!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ],
      ),
    );

    return fullScreen
        ? Scaffold(
            body: widget,
          )
        : widget;
  }
}
