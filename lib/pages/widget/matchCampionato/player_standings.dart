import 'package:flutter/material.dart';
import 'package:foot_bro/entity/user/user.dart';
import '../../../entity/statistiche/classificaResponse.dart';

class PlayersStandingsTab extends StatelessWidget {
  final List<Partecipazione> classifica;
  final User user;
  final Partecipazione? Function() getCurrentUserPartecipazione;
  final int? Function() getCurrentUserPosition;

  const PlayersStandingsTab({
    Key? key,
    required this.classifica,
    required this.user,
    required this.getCurrentUserPartecipazione,
    required this.getCurrentUserPosition,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUserPartecipazione = getCurrentUserPartecipazione();
    final currentUserPosition = getCurrentUserPosition();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: classifica.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildUserSummaryCard(currentUserPartecipazione, currentUserPosition);
        }

        final partecipazione = classifica[index - 1];
        final isMyPlayer = partecipazione.utente.email == user.email;

        return _buildPlayerCard(partecipazione, index, isMyPlayer);
      },
    );
  }

  Widget _buildUserSummaryCard(Partecipazione? currentUserPartecipazione, int? currentUserPosition) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple[50]!, Colors.purple[50]!],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.emoji_events, color: Colors.amber[600], size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'La tua posizione',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      currentUserPosition != null ? '${currentUserPosition}° posto' : 'Non in classifica',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  currentUserPartecipazione != null ? '${currentUserPartecipazione.punti} punti' : '- punti',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerCard(Partecipazione partecipazione, int position, bool isMyPlayer) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (position * 100)),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(50 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        elevation: isMyPlayer ? 8 : 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: isMyPlayer
                ? LinearGradient(
              colors: [Colors.green[50]!, Colors.green[100]!],
            )
                : null,
            border: isMyPlayer
                ? Border.all(color: Colors.green, width: 2)
                : null,
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getPositionColor(position),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${position}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            title: Text(
              isMyPlayer ? 'Tu (${partecipazione.utente.username})' : partecipazione.utente.username,
              style: TextStyle(
                fontWeight: isMyPlayer ? FontWeight.bold : FontWeight.w600,
                color: isMyPlayer ? Colors.green[700] : Colors.black87,
              ),
            ),
            subtitle: Text(
                '${partecipazione.partiteGiocate} partite • ${partecipazione.golFatti}G ${partecipazione.assist}A • ⭐${partecipazione.mediaVoto?.toStringAsFixed(1) ?? '-'}'
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isMyPlayer ? Colors.green : Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${partecipazione.punti}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isMyPlayer ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getPositionColor(int position) {
    if (position <= 3) return Colors.amber[600]!;
    if (position <= 8) return Colors.green[500]!;
    if (position <= 15) return Colors.blue[500]!;
    return Colors.grey[500]!;
  }
}