import 'package:flutter/material.dart';
import 'package:foot_bro/entity/partita/partita.dart';
import 'package:foot_bro/entity/user/user.dart';

class MatchesTab extends StatelessWidget {
  final List<Partita> upcomingMatches;
  final User user;
  final bool Function(Partita) isUserRegisteredForMatch;
  final Future<void> Function(Partita) toggleMatchRegistration;

  const MatchesTab({
    Key? key,
    required this.upcomingMatches,
    required this.user,
    required this.isUserRegisteredForMatch,
    required this.toggleMatchRegistration,
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

class MatchDetailsSheet extends StatelessWidget {
  final Partita match;
  final User user;
  final bool isUserRegistered;
  final VoidCallback onToggleRegistration;

  const MatchDetailsSheet({
    Key? key,
    required this.match,
    required this.user,
    required this.isUserRegistered,
    required this.onToggleRegistration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final teamA = match.partecipazioni
        .where((p) => p.squadra == 'A')
        .toList();
    final teamB = match.partecipazioni
        .where((p) => p.squadra == 'B')
        .toList();
    final unassigned = match.partecipazioni
        .where((p) => p.squadra == 'DA_ASSEGNARE')
        .toList();

    String formattedDate = '';
    String formattedTime = '';
    if (match.dataOra != null) {
      final dt = match.dataOra!;
      formattedDate = '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
      formattedTime = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle per il drag
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Contenuto scrollabile
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.sports_soccer,
                              color: Colors.deepPurple[700],
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Dettagli Partita',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                Text(
                                  'ID: ${match.id}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Informazioni principali
                      _buildDetailSection(
                        'Informazioni',
                        [
                          _buildDetailItem('Luogo', match.luogo ?? 'Da definire', Icons.location_on),
                          _buildDetailItem('Data', formattedDate, Icons.calendar_today),
                          _buildDetailItem('Orario', formattedTime, Icons.access_time),
                          _buildDetailItem('Partecipanti', '${match.partecipazioni.length}', Icons.people),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Squadre (se assegnate)
                      // Sostituisci la sezione "Squadre" nel MatchDetailsSheet con questo codice

// Squadre (se assegnate) - VERSIONE MIGLIORATA
                      if (teamA.isNotEmpty || teamB.isNotEmpty) ...[
                        _buildDetailSection('Squadre', []),
                        const SizedBox(height: 16),

                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Colors.grey[50]!, Colors.grey[100]!],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Column(
                            children: [
                              // Header "VS" centrale
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Squadra A',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green[700],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 16),
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.deepPurple,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      'VS',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Squadra B',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red[700],
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              // Giocatori delle squadre
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Squadra A
                                  Expanded(
                                    child: Column(
                                      children: [
                                        ...teamA.asMap().entries.map((entry) {
                                          int index = entry.key;
                                          var player = entry.value;
                                          bool isCurrentUser = player.utente.email == user.email;

                                          return Container(
                                            margin: const EdgeInsets.only(bottom: 8),
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: isCurrentUser ? Colors.green[200] : Colors.green[100],
                                              borderRadius: BorderRadius.circular(20),
                                              border: isCurrentUser
                                                  ? Border.all(color: Colors.green[600]!, width: 2)
                                                  : null,
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 24,
                                                  height: 24,
                                                  decoration: BoxDecoration(
                                                    color: Colors.green[600],
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      '${index + 1}',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Flexible(
                                                  child: Text(
                                                    isCurrentUser ? 'Tu' : player.utente.username,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.w500,
                                                      color: Colors.green[800],
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }),

                                        // Se la squadra A ha meno giocatori, mostra slot vuoti
                                        if (teamA.length < teamB.length)
                                          ...List.generate(teamB.length - teamA.length, (index) =>
                                              Container(
                                                margin: const EdgeInsets.only(bottom: 8),
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[200],
                                                  borderRadius: BorderRadius.circular(20),
                                                  border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Container(
                                                      width: 24,
                                                      height: 24,
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey[400],
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                      child: const Icon(
                                                        Icons.person_outline,
                                                        size: 16,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      'Slot libero',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.grey[600],
                                                        fontStyle: FontStyle.italic,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(width: 16),

                                  // Squadra B
                                  Expanded(
                                    child: Column(
                                      children: [
                                        ...teamB.asMap().entries.map((entry) {
                                          int index = entry.key;
                                          var player = entry.value;
                                          bool isCurrentUser = player.utente.email == user.email;

                                          return Container(
                                            margin: const EdgeInsets.only(bottom: 8),
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: isCurrentUser ? Colors.red[200] : Colors.red[100],
                                              borderRadius: BorderRadius.circular(20),
                                              border: isCurrentUser
                                                  ? Border.all(color: Colors.red[600]!, width: 2)
                                                  : null,
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 24,
                                                  height: 24,
                                                  decoration: BoxDecoration(
                                                    color: Colors.red[600],
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      '${index + 1}',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Flexible(
                                                  child: Text(
                                                    isCurrentUser ? 'Tu' : player.utente.username,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.w500,
                                                      color: Colors.red[800],
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }),

                                        // Se la squadra B ha meno giocatori, mostra slot vuoti
                                        if (teamB.length < teamA.length)
                                          ...List.generate(teamA.length - teamB.length, (index) =>
                                              Container(
                                                margin: const EdgeInsets.only(bottom: 8),
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[200],
                                                  borderRadius: BorderRadius.circular(20),
                                                  border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Container(
                                                      width: 24,
                                                      height: 24,
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey[400],
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                      child: const Icon(
                                                        Icons.person_outline,
                                                        size: 16,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      'Slot libero',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.grey[600],
                                                        fontStyle: FontStyle.italic,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              // Footer con statistiche
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Column(
                                      children: [
                                        Text(
                                          '${teamA.length}',
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green[700],
                                          ),
                                        ),
                                        Text(
                                          'Giocatori',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      width: 1,
                                      height: 40,
                                      color: Colors.grey[300],
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          '${teamB.length}',
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red[700],
                                          ),
                                        ),
                                        Text(
                                          'Giocatori',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Giocatori non assegnati
                      if (unassigned.isNotEmpty) ...[
                        _buildDetailSection('Giocatori da Assegnare', []),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: unassigned.map((p) {
                              final isCurrentUser = p.utente.email == user.email;
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isCurrentUser ? Colors.green[100] : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isCurrentUser ? Colors.green : Colors.grey[300]!,
                                    width: isCurrentUser ? 2 : 1,
                                  ),
                                ),
                                child: Text(
                                  isCurrentUser ? 'Tu (${p.utente.username})' : p.utente.username,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                                    color: isCurrentUser ? Colors.green[700] : Colors.grey[700],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Pulsante azione
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: onToggleRegistration,
                          icon: Icon(
                            isUserRegistered ? Icons.person_remove : Icons.person_add,
                            size: 20,
                          ),
                          label: Text(
                            isUserRegistered ? 'Disiscriviti dalla partita' : 'Iscriviti alla partita',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isUserRegistered ? Colors.orange : Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        ...items,
      ],
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.deepPurple, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}