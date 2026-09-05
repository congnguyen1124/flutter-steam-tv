import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

final class StreamTvQrCode extends StatelessWidget {
  const StreamTvQrCode({
    required this.content,
    required this.size,
    required this.semanticLabel,
    super.key,
  });

  final String content;
  final double size;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: semanticLabel,
      child: Container(
        width: size,
        height: size,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: content.isEmpty
            ? const SizedBox.expand()
            : PrettyQrView.data(
                data: content,
                errorCorrectLevel: QrErrorCorrectLevel.M,
                decoration: const PrettyQrDecoration(
                  quietZone: PrettyQrQuietZone.zero,
                  shape: PrettyQrSquaresSymbol(),
                ),
                errorBuilder: (_, _, _) => const SizedBox.expand(),
              ),
      ),
    );
  }
}
