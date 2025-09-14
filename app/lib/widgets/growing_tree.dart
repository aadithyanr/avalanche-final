import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_svg/flutter_svg.dart';

class Branch {
  final Offset start;
  final Offset end;
  final int depth;
  double progress; // 0.0 to 1.0 for animation
  bool painted = false;

  Branch(this.start, this.end, this.depth) : progress = 0.0;

  Offset get currentEnd {
    return Offset.lerp(start, end, progress)!;
  }
}

class FlowerData {
  final Offset position;
  final double rotation;
  final AnimationController controller;
  late final Animation<double> scaleAnimation;

  FlowerData(this.position, TickerProvider vsync) : 
    rotation = math.Random().nextDouble() * math.pi * 2,
    controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: vsync,
    ) {
      scaleAnimation = CurvedAnimation(
        parent: controller,
        curve: Curves.elasticOut,
      );
      controller.forward();
    }

  void dispose() {
    controller.dispose();
  }
}

class GrowingTree extends StatefulWidget {
  const GrowingTree({
    super.key,
  });

  @override
  State<GrowingTree> createState() => GrowingTreeState();
}

class GrowingTreeState extends State<GrowingTree> with TickerProviderStateMixin {
  int currentDepth = 1;
  static const maxDepth = 5;
  List<Branch> branches = [];
  List<int> branchesAtDepth = [0];
  static const baseLength = 170.0;
  static const baseBranchAngle = math.pi / 9;
  static const lengthFactor = 0.60;
  final _random = math.Random();
  late AnimationController _animationController;
  late AnimationController _swayController;
  Branch? _growingBranch;
  List<FlowerData> flowers = [];
  bool isFullyGrown = false;
  Map<int, Map<Offset, Offset>> swayedEnds = {};  // Add this to track swayed positions
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addListener(() {
      if (_growingBranch != null) {
        setState(() {
          _growingBranch!.progress = _animationController.value;
        });
      }
    });
    
    _swayController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    
    final startPoint = const Offset(150, 400);
    final endPoint = Offset(150, 400 - baseLength);
    final trunk = Branch(startPoint, endPoint, 0);
    trunk.progress = 1.0;
    branches.add(trunk);
  }

  @override
  void dispose() {
    for (final flower in flowers) {
      flower.dispose();
    }
    _animationController.dispose();
    _swayController.dispose();
    super.dispose();
  }

  double _randomize(double value, double factor) {
    return value * (1 + factor * (_random.nextDouble() - 0.5) * 2);
  }

  double _getBranchLength(int depth) {
    double baseLen = baseLength * math.pow(lengthFactor, depth);
    if (depth <= 2) {
      baseLen *= 1.5; // Increase length for shallow branches
    }
    return _randomize(baseLen, 0.2);
  }

  void addBranch() {
    if (currentDepth <= maxDepth) {
      final currentBranchCount = branchesAtDepth[currentDepth - 1];
      final parentDepth = currentDepth - 1;
      final parentBranches = branches.where((b) => b.depth == parentDepth).toList();
      
      if (parentBranches.isEmpty) {
        return;
      }
      
      final parentBranch = parentBranches[currentBranchCount ~/ 2];
      final length = _getBranchLength(currentDepth);
      final baseAngle = math.atan2(
        parentBranch.end.dy - parentBranch.start.dy,
        parentBranch.end.dx - parentBranch.start.dx
      );
      
      final isRightBranch = currentBranchCount % 2 == 0;
      final randomizedBranchAngle = _randomize(baseBranchAngle, 0.3);
      final angle = baseAngle + (isRightBranch ? randomizedBranchAngle : -randomizedBranchAngle);
      
      final newEnd = Offset(
        parentBranch.end.dx + length * math.cos(angle),
        parentBranch.end.dy + length * math.sin(angle),
      );
      
      final newBranch = Branch(parentBranch.end, newEnd, currentDepth);
      _growingBranch = newBranch;
      
      setState(() {
        branches = List.from(branches)..add(newBranch);
        branchesAtDepth[currentDepth - 1]++;
        
        if (branchesAtDepth[currentDepth - 1] >= parentBranches.length * 2) {
          currentDepth++;
          branchesAtDepth.add(0);
        }
        
        if (currentDepth > maxDepth && !isFullyGrown) {
          isFullyGrown = true;
        }
      });

      _animationController.forward(from: 0.0).then((_) {
        _growingBranch = null;
      });
    }
    
    if (isFullyGrown) {
      setState(() {
        final eligibleBranches = branches.where((b) => b.depth > 1).toList();
        if (eligibleBranches.isNotEmpty) {
          final randomBranch = eligibleBranches[_random.nextInt(eligibleBranches.length)];
          if (!flowers.any((f) => f.position == randomBranch.end)) {
            flowers.add(FlowerData(randomBranch.end, this));
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 400,
      child: AnimatedBuilder(
        animation: _swayController,
        builder: (context, child) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              CustomPaint(
                size: const Size(300, 400),
                painter: TreePainter(
                  branches: branches,
                  swayTime: _swayController.value,
                  flowerPositions: flowers.map((f) => f.position).toList(),
                  onSwayedPositionsUpdated: (positions) {
                    swayedEnds = positions;
                  },
                ),
              ),
              ...flowers.map((flower) {
                final swayedPosition = swayedEnds[branches
                    .firstWhere((b) => b.end == flower.position).depth]?[flower.position] 
                    ?? flower.position;
                
                return Positioned(
                  left: swayedPosition.dx - 10,
                  top: swayedPosition.dy - 10,
                  child: ScaleTransition(
                    scale: flower.scaleAnimation,
                    child: Transform.rotate(
                      angle: flower.rotation,
                      child: SvgPicture.asset(
                        'assets/images/flower.svg',
                        width: 20,
                        height: 20,
                      ),
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

class TreePainter extends CustomPainter {
  final List<Branch> branches;
  final double swayTime;
  final List<Offset> flowerPositions;
  final Function(Map<int, Map<Offset, Offset>>) onSwayedPositionsUpdated;
  static const baseWidth = 28.0;
  static const widthFactor = 0.6;
  static const branchColor = Color(0xFF934E53);

  TreePainter({
    required this.branches,
    required this.swayTime,
    required this.flowerPositions,
    required this.onSwayedPositionsUpdated,
  });

  double _getEndWidth(double startWidth, int depth) {
    final taperFactor = math.max(0.5, 0.5 - depth * 0.1);
    return startWidth * taperFactor;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = branchColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill;

    final Map<int, Map<Offset, Offset>> swayedEnds = {};

    final sortedBranches = List<Branch>.from(branches)
      ..sort((a, b) => a.depth.compareTo(b.depth));

    for (final branch in sortedBranches) {
      Offset startPoint = branch.start;
      if (branch.depth > 0) {
        startPoint = swayedEnds[branch.depth - 1]?[branch.start] ?? branch.start;
      }

      double swayAngle = (3 / (branch.depth + 1)) * 
          (math.cos(swayTime * 2 * math.pi) * 0.05 +
           math.sin(swayTime * 2 * math.pi) * 0.03);
      
      Offset swayedEnd = branch.end;
      if (branch.depth > 0) {
        final dx = branch.end.dx - branch.start.dx;
        final dy = branch.end.dy - branch.start.dy;
        final angle = math.atan2(dy, dx) + swayAngle;
        final length = math.sqrt(dx * dx + dy * dy);
        swayedEnd = Offset(
          startPoint.dx + length * math.cos(angle),
          startPoint.dy + length * math.sin(angle),
        );
      }

      swayedEnds.putIfAbsent(branch.depth, () => {});
      swayedEnds[branch.depth]![branch.end] = swayedEnd;

      final currentEnd = Offset.lerp(startPoint, swayedEnd, branch.progress)!;
      
      final startWidth = baseWidth * math.pow(widthFactor, branch.depth);
      final endWidth = _getEndWidth(startWidth, branch.depth);
      final angle = math.atan2(
        currentEnd.dy - startPoint.dy,
        currentEnd.dx - startPoint.dx,
      );
      final perpendicular = angle + math.pi / 2;

      final startLeft = Offset(
        startPoint.dx + math.cos(perpendicular) * startWidth / 2,
        startPoint.dy + math.sin(perpendicular) * startWidth / 2,
      );
      final startRight = Offset(
        startPoint.dx - math.cos(perpendicular) * startWidth / 2,
        startPoint.dy - math.sin(perpendicular) * startWidth / 2,
      );
      final endLeft = Offset(
        currentEnd.dx + math.cos(perpendicular) * endWidth / 2,
        currentEnd.dy + math.sin(perpendicular) * endWidth / 2,
      );
      final endRight = Offset(
        currentEnd.dx - math.cos(perpendicular) * endWidth / 2,
        currentEnd.dy - math.sin(perpendicular) * endWidth / 2,
      );

      final path = Path()
        ..moveTo(startLeft.dx, startLeft.dy)
        ..lineTo(endLeft.dx, endLeft.dy)
        ..lineTo(endRight.dx, endRight.dy)
        ..lineTo(startRight.dx, startRight.dy)
        ..close();

      canvas.drawPath(path, paint);
    }

    onSwayedPositionsUpdated(swayedEnds);
  }

  @override
  bool shouldRepaint(TreePainter oldDelegate) {
    return oldDelegate.branches != branches || oldDelegate.swayTime != swayTime;
  }
} 