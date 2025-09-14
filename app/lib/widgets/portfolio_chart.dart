import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class CharityInfo {
  final String name;
  final double percentage;
  final String category;

  const CharityInfo({
    required this.name,
    required this.percentage,
    required this.category,
  });
}

class PortfolioChart extends StatelessWidget {
  final List<CharityInfo> charities;

  // Define the color range
  static const Color darkestGreen = Color(0xFF119068);
  static const Color lightestGreen = Color(0xFFCAEEDE);
  static const Color darkGreenText = Color(0xFF119068);

  const PortfolioChart({
    super.key,
    required this.charities,
  });

  // Helper method to generate a color based on percentage rank
  Color _getColorByRank(int rank, int totalRanks) {
    // rank 0 is darkest, last rank is lightest
    final t = rank / (totalRanks - 1);
    return Color.lerp(darkestGreen, lightestGreen, t)!;
  }

  // Helper method to determine if a color is light
  bool _isLightColor(Color color) {
    return color.computeLuminance() > 0.5;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,  // Center the whole row
      children: [
        Expanded(
          flex: 3,
          child: Center(  // Center the pie chart
            child: SizedBox(
              width: 200,  // Fixed width for pie chart
              child: _buildPieChart(),
            ),
          ),
        ),
        const SizedBox(width: 24),  // Increased spacing
        SizedBox(  // Fixed width for legend
          width: 120,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...charities.asMap().entries.map((entry) {
                final charity = entry.value;
                final color = _getColorByRank(entry.key, charities.length);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          charity.name,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF333333),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPieChart() {
    final sections = charities.asMap().entries.map((entry) {
      final charity = entry.value;
      final sectionColor = _getColorByRank(entry.key, charities.length);
      
      return PieChartSectionData(
        value: charity.percentage.toDouble(),
        color: sectionColor,
        radius: 35,
        showTitle: true,
        title: '${charity.percentage}%',  // Only show percentage in pie
        titleStyle: TextStyle(
          color: _isLightColor(sectionColor) ? darkGreenText : Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        titlePositionPercentageOffset: 0.5,
      );
    }).toList();

    return PieChart(
      PieChartData(
        sections: sections,
        sectionsSpace: 0,
        centerSpaceRadius: 55,
        centerSpaceColor: Colors.white,
        startDegreeOffset: 270,
      ),
    );
  }
} 