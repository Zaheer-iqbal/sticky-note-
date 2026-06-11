import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onLinkTap;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.onLinkTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Styled 3D Notebook & Pen Representation
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Shadow under notebook
                  Positioned(
                    bottom: 30,
                    child: Container(
                      width: 100,
                      height: 10,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(26),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // The Notebook Pages stack
                  Positioned(
                    bottom: 40,
                    child: Container(
                      width: 90,
                      height: 85,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFC7C4D8), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(13),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(width: 50, height: 4, color: Colors.grey.shade300, margin: const EdgeInsets.only(bottom: 6)),
                          Container(width: 40, height: 4, color: Colors.grey.shade300, margin: const EdgeInsets.only(bottom: 6)),
                          Container(width: 60, height: 4, color: Colors.grey.shade300, margin: const EdgeInsets.only(bottom: 6)),
                          Container(width: 30, height: 4, color: Colors.grey.shade300),
                        ],
                      ),
                    ),
                  ),
                  // Purple binding details
                  Positioned(
                    bottom: 40,
                    left: 45,
                    child: Column(
                      children: List.generate(4, (index) => Container(
                        width: 8,
                        height: 6,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7C3AED),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      )),
                    ),
                  ),
                  // Pen drawing
                  Positioned(
                    bottom: 30,
                    right: 30,
                    child: Transform.rotate(
                      angle: -0.5,
                      child: Container(
                        width: 10,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0B1C30),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(51),
                              blurRadius: 4,
                              offset: const Offset(2, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(height: 10, color: const Color(0xFFF59E0B)),
                            const Spacer(),
                            Container(
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.vertical(bottom: Radius.circular(4)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0B1C30),
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 12),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 14,
                  color: Color(0xFF64748B),
                  height: 1.5,
                ),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  actionLabel!,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
            if (onLinkTap != null) ...[
              const SizedBox(height: 16),
              GestureDetector(
                onTap: onLinkTap,
                child: const Text(
                  'Import existing notes',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4F46E5),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
