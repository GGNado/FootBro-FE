import 'package:flutter/material.dart';
import 'package:foot_bro/entity/partita/SalvaSquadraRequest.dart';
import 'package:foot_bro/service/campionatoService.dart';
import 'package:foot_bro/store/storage.dart';
import '../../../entity/partita/partita.dart';
import '../../../entity/user/user.dart';
import 'formationFieldWidget.dart';

class MatchDetailsSheet extends StatefulWidget {
  final Partita match;
  final User user;
  final bool isUserRegistered;
  final VoidCallback onToggleRegistration;
  final bool isUserAdmin;

  const MatchDetailsSheet({
    Key? key,
    required this.match,
    required this.user,
    required this.isUserRegistered,
    required this.onToggleRegistration,
    required this.isUserAdmin,
  }) : super(key: key);

  @override
  State<MatchDetailsSheet> createState() => _MatchDetailsSheetState();
}

class _MatchDetailsSheetState extends State<MatchDetailsSheet> {
  late List<dynamic> teamA;
  late List<dynamic> teamB;
  late List<dynamic> unassigned;

  @override
  void initState() {
    super.initState();
    _initTeams();
  }

  void _initTeams() {
    teamA = widget.match.partecipazioni.where((p) => p.squadra == 'A').toList();
    teamB = widget.match.partecipazioni.where((p) => p.squadra == 'B').toList();
    unassigned = widget.match.partecipazioni.where((p) => p.squadra == 'DA_ASSEGNARE').toList();
  }

  void _movePlayerToTeam(int playerId, String newTeam) {
    setState(() {
      print("Moving player $playerId to team $newTeam from match ${widget.match.id}");
      var player = widget.match.partecipazioni.firstWhere((p) => p.utente.id == playerId);
      if (newTeam == 'A') {
        teamA.add(player);
        teamB.remove(player);
        unassigned.remove(player);
      } else if (newTeam == 'B') {
        teamB.add(player);
        teamA.remove(player);
        unassigned.remove(player);
      } else {
        unassigned.add(player);
        teamA.remove(player);
        teamB.remove(player);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = '';
    String formattedTime = '';
    if (widget.match.dataOra != null) {
      final dt = widget.match.dataOra!;
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
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                                  'ID: ${widget.match.id}',
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
                      _buildDetailSection(
                        'Informazioni',
                        [
                          _buildDetailItem('Luogo', widget.match.luogo ?? 'Da definire', Icons.location_on),
                          _buildDetailItem('Data', formattedDate, Icons.calendar_today),
                          _buildDetailItem('Orario', formattedTime, Icons.access_time),
                          _buildDetailItem('Partecipanti', '${widget.match.partecipazioni.length}', Icons.people),
                        ],
                      ),
                      const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: _buildDetailSection('Squadre', [])),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FormationFieldWidget(
                                      teamA: teamA,
                                      teamB: teamB,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.sports_football),
                              label: const Text('Schiera Formazione'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                            ),
                          ],
                        ),
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
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        ...teamA.asMap().entries.map((entry) {
                                          int index = entry.key;
                                          var player = entry.value;
                                          bool isCurrentUser = player.utente.email == widget.user.email;
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
                                  Expanded(
                                    child: Column(
                                      children: [
                                        ...teamB.asMap().entries.map((entry) {
                                          int index = entry.key;
                                          var player = entry.value;
                                          bool isCurrentUser = player.utente.email == widget.user.email;
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
                        if (widget.isUserAdmin) ...[
                          const SizedBox(height: 24),
                          _buildAdminSection(context),
                          const SizedBox(height: 24),
                        ],
                        const SizedBox(height: 24),
                      if (unassigned.isNotEmpty) ...[
                        const SizedBox(height: 12),
                      ],
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: widget.onToggleRegistration,
                          icon: Icon(
                            widget.isUserRegistered ? Icons.person_remove : Icons.person_add,
                            size: 20,
                          ),
                          label: Text(
                            widget.isUserRegistered ? 'Disiscriviti dalla partita' : 'Iscriviti alla partita',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.isUserRegistered ? Colors.orange : Colors.green,
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

  Widget _buildAdminSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.amber[50]!, Colors.orange[100]!],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.admin_panel_settings,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Pannello Admin',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[800],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showEditMatchDialog(context),
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text(
                    'Modifica',
                    style: TextStyle(fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _autoAssignTeams(),
                  icon: const Icon(Icons.shuffle, size: 18),
                  label: const Text(
                    'Auto',
                    style: TextStyle(fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: (){
                CampionatoService service = CampionatoService();
                SalvaSquadraRequest salvaSquadraA = SalvaSquadraRequest(
                  idUtenti: teamA.map((p) => p.utente.id as int).toList(),
                  squadra: 'A',
                );

                SalvaSquadraRequest salvaSquadraB = SalvaSquadraRequest(
                  idUtenti: teamB.map((p) => p.utente.id as int).toList(),
                  squadra: 'B',
                );

                SalvaSquadraRequest salvaSquadraDaAssegnare = SalvaSquadraRequest(
                  idUtenti: unassigned.map((p) => p.utente.id as int).toList(),
                  squadra: 'DA_ASSEGNARE',
                );
                service.salvaSquadra(widget.user.token, widget.match.id, salvaSquadraA);
                service.salvaSquadra(widget.user.token, widget.match.id, salvaSquadraB);
                service.salvaSquadra(widget.user.token, widget.match.id, salvaSquadraDaAssegnare);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Squadre salvate con successo! Aggiorna per vedere le modifiche.')),
                );
              }, //_saveTeams,
              icon: const Icon(Icons.save, size: 18),
              label: const Text(
                'Salva Squadre',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
          Text(
            'Gestione Squadre',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.orange[800],
            ),
          ),
          Text(
            '(trascina i giocatori)',
            style: TextStyle(
              fontSize: 12,
              color: Colors.orange[600],
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 12),
          _buildDragDropTeams(),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => _buildMatchStatsDialog(context, widget.match, widget.user.token),
              );
            },
            label: const Text(
              'Concludi Partita',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDragDropTeams() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildTeamDropZone('A', teamA, Colors.green),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTeamDropZone('B', teamB, Colors.red),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTeamDropZone('DA_ASSEGNARE', unassigned, Colors.grey),
      ],
    );
  }

  Widget _buildTeamDropZone(String teamId, List<dynamic> players, MaterialColor color) {
    String teamName = teamId == 'A' ? 'Squadra A' :
    teamId == 'B' ? 'Squadra B' : 'Non Assegnati';

    return DragTarget<Map<String, dynamic>>(
      onWillAccept: (data) => true,
      onAccept: (data) {
        _movePlayerToTeam(data['playerId'], teamId);
      },
      builder: (context, candidateData, rejectedData) {
        bool isHighlighted = candidateData.isNotEmpty;

        return Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 100),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isHighlighted ? color[100] : color[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isHighlighted ? color[400]! : color[200]!,
              width: isHighlighted ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    teamId == 'A' ? Icons.group :
                    teamId == 'B' ? Icons.group : Icons.people_outline,
                    color: color[600],
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '$teamName (${players.length})',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: color[700],
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (players.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'Trascina qui i giocatori',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: color[400],
                      fontStyle: FontStyle.italic,
                      fontSize: 12,
                    ),
                  ),
                )
              else
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: players.map((player) => _buildDraggablePlayer(player, teamId, color)).toList(),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDraggablePlayer(dynamic player, String currentTeam, MaterialColor color) {
    bool isCurrentUser = player.utente.email == widget.user.email;
    String displayName = isCurrentUser ? 'Tu' : player.utente.username;

    if (displayName.length > 10) {
      displayName = '${displayName.substring(0, 8)}..';
    }

    return Draggable<Map<String, dynamic>>(
      data: {
        'playerId': player.utente.id,
        'currentTeam': currentTeam,
      },
      feedback: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 100),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color[200],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color[600]!, width: 2),
          ),
          child: Text(
            displayName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color[800],
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ),
      childWhenDragging: Container(
        constraints: const BoxConstraints(maxWidth: 100),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          displayName,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
          ),
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 100),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isCurrentUser ? color[200] : color[100],
          borderRadius: BorderRadius.circular(20),
          border: isCurrentUser ? Border.all(color: color[600]!, width: 2) : null,
        ),
        child: Text(
          displayName,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
            color: color[800],
          ),
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void _showEditMatchDialog(BuildContext context) {
    final TextEditingController luogoController = TextEditingController(text: widget.match.luogo ?? '');
    DateTime? selectedDate = widget.match.dataOra;
    TimeOfDay? selectedTime = widget.match.dataOra != null ? TimeOfDay.fromDateTime(widget.match.dataOra!) : null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Modifica Partita'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: luogoController,
                  decoration: const InputDecoration(
                    labelText: 'Luogo',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text(selectedDate != null
                      ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                      : 'Seleziona data'),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() => selectedDate = date);
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: Text(selectedTime != null
                      ? '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}'
                      : 'Seleziona orario'),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: selectedTime ?? TimeOfDay.now(),
                    );
                    if (time != null) {
                      setState(() => selectedTime = time);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annulla'),
            ),
            ElevatedButton(
              onPressed: () {
                _updateMatch(
                  luogoController.text,
                  selectedDate,
                  selectedTime,
                );
                Navigator.pop(context);
              },
              child: const Text('Salva'),
            ),
          ],
        ),
      ),
    );
  }

  void _updateMatch(String luogo, DateTime? date, TimeOfDay? time) {
    DateTime? newDateTime;
    if (date != null && time != null) {
      newDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    }
    print('Updating match: $luogo, $newDateTime');
  }

  void _autoAssignTeams() {
    // Implementa la logica per assegnare automaticamente le squadre
    print('Auto assigning teams');
  }
}

Widget _buildMatchStatsDialog(BuildContext context, Partita match, String userToken) {
  return StatefulBuilder(
    builder: (context, setState) {
      // Raggruppa le partecipazioni per squadra
      final Map<String, List<PartecipazionePartita>> teamsBySquadra = {};

      for (var partecipazione in match.partecipazioni) {
        if (!teamsBySquadra.containsKey(partecipazione.squadra)) {
          teamsBySquadra[partecipazione.squadra] = [];
        }
        teamsBySquadra[partecipazione.squadra]!.add(partecipazione);
      }

      return AlertDialog(
        title: const Text('Statistiche Partita'),
        content: SizedBox(
          width: double.maxFinite,
          height: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: teamsBySquadra.entries.map((teamEntry) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          teamEntry.key,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...teamEntry.value.map((partecipazione) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  partecipazione.utente.username ?? 'Nome non disponibile',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Column(
                                  children: [
                                    // Prima riga: Goal e Assist
                                    Row(
                                      children: [
                                        // Goal
                                        Expanded(
                                          child: Column(
                                            children: [
                                              const Text('Goal', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                                              const SizedBox(height: 4),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      if (partecipazione.golSegnati > 0) {
                                                        setState(() {
                                                          _updatePartecipazione(match, partecipazione,
                                                              golSegnati: partecipazione.golSegnati - 1);
                                                        });
                                                      }
                                                    },
                                                    child: Container(
                                                      width: 24,
                                                      height: 24,
                                                      decoration: BoxDecoration(
                                                        color: Colors.red.shade100,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: const Icon(Icons.remove, size: 14, color: Colors.red),
                                                    ),
                                                  ),
                                                  Container(
                                                    width: 30,
                                                    alignment: Alignment.center,
                                                    child: Text('${partecipazione.golSegnati}',
                                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        _updatePartecipazione(match, partecipazione,
                                                            golSegnati: partecipazione.golSegnati + 1);
                                                      });
                                                    },
                                                    child: Container(
                                                      width: 24,
                                                      height: 24,
                                                      decoration: BoxDecoration(
                                                        color: Colors.green.shade100,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: const Icon(Icons.add, size: 14, color: Colors.green),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        // Assist
                                        Expanded(
                                          child: Column(
                                            children: [
                                              const Text('Assist', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                                              const SizedBox(height: 4),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      if (partecipazione.assist > 0) {
                                                        setState(() {
                                                          _updatePartecipazione(match, partecipazione,
                                                              assist: partecipazione.assist - 1);
                                                        });
                                                      }
                                                    },
                                                    child: Container(
                                                      width: 24,
                                                      height: 24,
                                                      decoration: BoxDecoration(
                                                        color: Colors.red.shade100,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: const Icon(Icons.remove, size: 14, color: Colors.red),
                                                    ),
                                                  ),
                                                  Container(
                                                    width: 30,
                                                    alignment: Alignment.center,
                                                    child: Text('${partecipazione.assist}',
                                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        _updatePartecipazione(match, partecipazione,
                                                            assist: partecipazione.assist + 1);
                                                      });
                                                    },
                                                    child: Container(
                                                      width: 24,
                                                      height: 24,
                                                      decoration: BoxDecoration(
                                                        color: Colors.green.shade100,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: const Icon(Icons.add, size: 14, color: Colors.green),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    // Seconda riga: Voto (centrato)
                                    Column(
                                      children: [
                                        const Text('Voto', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                                        const SizedBox(height: 4),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                if (partecipazione.voto > 1.0) {
                                                  setState(() {
                                                    _updatePartecipazione(match, partecipazione,
                                                        voto: (partecipazione.voto - 0.5).clamp(1.0, 10.0));
                                                  });
                                                }
                                              },
                                              child: Container(
                                                width: 28,
                                                height: 28,
                                                decoration: BoxDecoration(
                                                  color: Colors.red.shade100,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(Icons.remove, size: 16, color: Colors.red),
                                              ),
                                            ),
                                            Container(
                                              width: 50,
                                              alignment: Alignment.center,
                                              child: Text(
                                                '${partecipazione.voto.toStringAsFixed(1)}',
                                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                if (partecipazione.voto < 10.0) {
                                                  setState(() {
                                                    _updatePartecipazione(match, partecipazione,
                                                        voto: (partecipazione.voto + 0.5).clamp(1.0, 10.0));
                                                  });
                                                }
                                              },
                                              child: Container(
                                                width: 28,
                                                height: 28,
                                                decoration: BoxDecoration(
                                                  color: Colors.green.shade100,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(Icons.add, size: 16, color: Colors.green),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () {
              // Qui puoi salvare le statistiche aggiornate
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Partita conclusa con statistiche salvate!')),
              );
              CampionatoService campionatoService = CampionatoService();
              campionatoService.concludiPartita(userToken, match);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Salva e Concludi'),
          ),
        ],
      );
    },
  );
}

// Funzione helper per aggiornare una partecipazione
void _updatePartecipazione(Partita match, PartecipazionePartita partecipazione, {
  int? golSegnati,
  int? assist,
  double? voto,
}) {
  final index = match.partecipazioni.indexOf(partecipazione);
  if (index != -1) {
    match.partecipazioni[index] = PartecipazionePartita(
      utente: partecipazione.utente,
      golSegnati: golSegnati ?? partecipazione.golSegnati,
      assist: assist ?? partecipazione.assist,
      voto: voto ?? partecipazione.voto,
      squadra: partecipazione.squadra,
    );
  }
}