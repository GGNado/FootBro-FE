import 'package:flutter/material.dart';
import 'package:foot_bro/entity/partita/partita.dart';
import 'package:foot_bro/entity/user/user.dart';

import 'matchDetailsSheet.dart';

class MatchesTab extends StatelessWidget {
  final List<Partita> upcomingMatches;
  final User user;
  final bool isUserAdmin;
  final bool Function(Partita) isUserRegisteredForMatch;
  final Future<void> Function(Partita) toggleMatchRegistration;

  const MatchesTab({
    Key? key,
    required this.upcomingMatches,
    required this.user,
    required this.isUserRegisteredForMatch,
    required this.toggleMatchRegistration,
    required this.isUserAdmin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Prossime Partite', Icons.schedule, Colors.blue),
          const SizedBox(height: 12),
          if (upcomingMatches.isEmpty)
            _buildEmptyState()
          else
            ...upcomingMatches.map((match) => MatchCard(
              match: match,
              user: user,
              isUserRegistered: isUserRegisteredForMatch(match),
              onToggleRegistration: () => toggleMatchRegistration(match),
              onShowDetails: () => _showMatchDetails(context, match),
            )),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.calendar_today, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 8),
              Text(
                'Nessuna partita programmata',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMatchDetails(BuildContext context, Partita match) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MatchDetailsSheet(
        match: match,
        user: user,
        isUserAdmin: isUserAdmin,
        isUserRegistered: isUserRegisteredForMatch(match),
        onToggleRegistration: () {
          Navigator.pop(context);
          toggleMatchRegistration(match);
        },
      ),
    );
  }
}

class MatchCard extends StatelessWidget {
  final Partita match;
  final User user;
  final bool isUserRegistered;
  final VoidCallback onToggleRegistration;
  final VoidCallback onShowDetails;

  const MatchCard({
    Key? key,
    required this.match,
    required this.user,
    required this.isUserRegistered,
    required this.onToggleRegistration,
    required this.onShowDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final unassigned = match.partecipazioni
        .where((p) => p.squadra == 'DA_ASSEGNARE')
        .map((p) => p.utente.username)
        .toList();

    String formattedDate = '';
    String formattedTime = '';
    if (match.dataOra != null) {
      final dt = match.dataOra!;
      formattedDate = '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
      formattedTime = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isUserRegistered ? 6 : 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onShowDetails,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: isUserRegistered
                ? Border.all(color: Colors.green, width: 2)
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con luogo e data
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.blue[600], size: 20),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              match.luogo ?? 'Luogo da definire',
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        formattedDate,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Orario centrale
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple[50],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.deepPurple[200]!),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.access_time, color: Colors.deepPurple[600], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          formattedTime.isNotEmpty ? formattedTime : 'Orario da definire',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.deepPurple[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Partecipanti
                Row(
                  children: [
                    Icon(Icons.people, color: Colors.grey[600], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Iscritti: ${match.partecipazioni.length}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),

                if (unassigned.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: unassigned.take(5).map((username) {
                      final isCurrentUser = username == user.username;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isCurrentUser ? Colors.green[100] : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          border: isCurrentUser
                              ? Border.all(color: Colors.green, width: 1.5)
                              : null,
                        ),
                        child: Text(
                          isCurrentUser ? 'Tu' : username,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                            color: isCurrentUser ? Colors.green[700] : Colors.grey[700],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  if (unassigned.length > 5)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '+${unassigned.length - 5} altri',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],

                const SizedBox(height: 16),

                // Pulsante Iscriviti/Disiscriviti
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onToggleRegistration,
                    icon: Icon(
                      isUserRegistered ? Icons.person_remove : Icons.person_add,
                      size: 20,
                    ),
                    label: Text(
                      isUserRegistered ? 'Disiscriviti' : 'Iscriviti',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isUserRegistered ? Colors.orange : Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Indicatore "Tocca per dettagli"
                Center(
                  child: Text(
                    'Tocca per vedere i dettagli',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}