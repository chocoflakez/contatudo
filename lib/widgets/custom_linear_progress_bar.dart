import 'package:flutter/material.dart';

class CustomLinearProgressBar extends StatefulWidget {
  final double progress; // Valor do progresso (entre 0.0 e 1.0)
  final Color progressColor; // Cor do progresso

  const CustomLinearProgressBar({
    Key? key,
    required this.progress,
    required this.progressColor,
  }) : super(key: key);

  @override
  _CustomLinearProgressBarState createState() =>
      _CustomLinearProgressBarState();
}

class _CustomLinearProgressBarState extends State<CustomLinearProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress.clamp(0.0, 1.0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant CustomLinearProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.progress != oldWidget.progress) {
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: widget.progress.clamp(0.0, 1.0),
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth; // Largura da barra
        return AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return Container(
              height: 20.0,
              decoration: BoxDecoration(
                color: Colors.grey[1000], // Fundo da barra
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Stack(
                children: [
                  // Fundo cinza
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  // Barra de progresso animada
                  Container(
                    width: _progressAnimation.value * maxWidth,
                    decoration: BoxDecoration(
                      color: widget.progressColor, // Usa a cor do progresso
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  // Indicador de texto
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        '${(_progressAnimation.value * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
