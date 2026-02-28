import 'package:flutter/material.dart';

class LeaderboardPanel extends StatelessWidget {
  final Map<String, int> leaderboard;
  final String localTeamName;

  const LeaderboardPanel({
    super.key,
    required this.leaderboard,
    required this.localTeamName,
  });

  @override
  Widget build(BuildContext context) {
    // Sort and take top 8
    final sortedTeams = leaderboard.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topTeams = sortedTeams.take(8).toList();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: topTeams.length,
      itemBuilder: (context, index) {
        final team = topTeams[index];
        final isLocal = team.key == localTeamName;
        final rank = index + 1;
        final rankLabel = _getRankLabel(rank);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: isLocal
                ? const Color(0xFF00FF88).withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: isLocal
                ? Border.all(
                    color: const Color(0xFF00FF88).withOpacity(0.5),
                    width: 1,
                  )
                : null,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 32,
                child: Text(
                  rankLabel,
                  style: TextStyle(
                    color: _getRankColor(rank),
                    fontSize: 10,
                    fontWeight: rank <= 3 ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  team.key,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isLocal ? const Color(0xFF00FF88) : Colors.white70,
                    fontSize: 11,
                    fontWeight: isLocal ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              Text(
                '${team.value}',
                style: TextStyle(
                  color: isLocal ? Colors.white : Colors.white60,
                  fontSize: 11,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getRankLabel(int rank) {
    if (rank == 1) return '1st';
    if (rank == 2) return '2nd';
    if (rank == 3) return '3rd';
    return '${rank}th';
  }

  Color _getRankColor(int rank) {
    if (rank == 1) return const Color(0xFFFFD700);
    if (rank == 2) return const Color(0xFFC0C0C0);
    if (rank == 3) return const Color(0xFFCD7F32);
    return Colors.white24;
  }
}
