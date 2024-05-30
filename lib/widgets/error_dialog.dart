import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// onTap : default Navigator.pop
class ErrorDialog {
  static void show(BuildContext context, String message,
      {String? secondaryMessage, Function()? onTapFunction}) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (dialogContext) {
        return Dialog(
          child: LayoutBuilder(builder: (context, constraints) {
            final width = constraints.maxWidth;
            return Container(
              width: width,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              constraints: const BoxConstraints(
                maxWidth: 400,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                    width: 1,
                    color: Colors.grey,
                    strokeAlign: BorderSide.strokeAlignCenter),
                borderRadius: const BorderRadius.all(Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    offset: const Offset(0, 5),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Column(
                    children: [
                      Icon(Icons.error),
                      SizedBox(height: 8),
                    ],
                  ),
                  Text(
                    message,
                    style:
                        const TextStyle(color: Colors.blueGrey, fontSize: 24),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        onTapFunction != null ? onTapFunction() : null;
                        Navigator.pop(dialogContext);
                      },
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(24)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              offset: const Offset(0, 2),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                        child: const Center(
                            child: Text('OK',
                                style: TextStyle(color: Colors.white))),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }
}