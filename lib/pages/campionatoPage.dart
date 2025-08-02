import 'package:flutter/material.dart';
import 'package:foot_bro/entity/campionato/campionatoResponse.dart';
import 'package:foot_bro/entity/user/user.dart';

import '../entity/statistiche/classificaResponse.dart';
import '../service/campionatoService.dart';
import '../store/storage.dart';

class ChampionshipDetailPage extends StatefulWidget {
  const ChampionshipDetailPage({
    super.key,
  });

  @override
  State<ChampionshipDetailPage> createState() => _ChampionshipDetailPageState();
}

class _ChampionshipDetailPageState extends State<ChampionshipDetailPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _headerAnimationController;
  late Animation<double> _headerAnimation;

  // Dati ricevuti come argomenti
  CampionatoResponse? championship;
  User? user;

  // Classifica ricevuta dal backend
  List<Partecipazione> classifica = [];

  // Prossime partite
  final List<Map<String, dynamic>> upcomingMatches = [
    {
      'date': '2024-08-03',
      'time': '15:00',
      'matchType': 'Calcetto a 5',
      'teamA': ['Tu', 'Marco R.', 'Luca B.', 'Andrea V.', 'Giuseppe N.'],
      'teamB': ['Paolo M.', 'Stefano G.', 'Roberto F.', 'Matteo L.', 'Davide P.'],
      'venue': 'Campo Centrale'
    },
    {
      'date': '2024-08-10',
      'time': '17:30',
      'matchType': 'Calcetto a 7',
      'teamA': ['Tu', 'Marco R.', 'Luca B.', 'Andrea V.', 'Giuseppe N.', 'Paolo M.', 'Stefano G.'],
      'teamB': ['Roberto F.', 'Matteo L.', 'Davide P.', 'Simone T.', 'Francesco C.', 'Alessandro D.', 'Nicola S.'],
      'venue': 'Campo Nord'
    },
  ];

  // Ultime partite giocate
  final List<Map<String, dynamic>> recentMatches = [
    {
      'date': '2024-07-27',
      'matchType': 'Calcetto a 5',
      'teamA': ['Tu', 'Marco R.', 'Luca B.', 'Andrea V.', 'Giuseppe N.'],
      'teamB': ['Paolo M.', 'Stefano G.', 'Roberto F.', 'Matteo L.', 'Davide P.'],
      'scoreA': 5,
      'scoreB': 3,
      'myStats': {
        'goals': 2,
        'assists': 1,
        'rating': 8.5,
        'yellowCards': 0,
        'redCards': 0
      },
      'result': 'W' // W = Win, L = Loss, D = Draw
    },
    {
      'date': '2024-07-20',
      'matchType': 'Calcetto a 7',
      'teamA': ['Roberto F.', 'Matteo L.', 'Davide P.', 'Simone T.', 'Francesco C.', 'Alessandro D.', 'Nicola S.'],
      'teamB': ['Tu', 'Marco R.', 'Luca B.', 'Andrea V.', 'Giuseppe N.', 'Paolo M.', 'Stefano G.'],
      'scoreA': 4,
      'scoreB': 6,
      'myStats': {
        'goals': 1,
        'assists': 2,
        'rating': 7.8,
        'yellowCards': 1,
        'redCards': 0
      },
      'result': 'W'
    },
    {
      'date': '2024-07-13',
      'matchType': 'Calcetto a 5',
      'teamA': ['Tu', 'Marco R.', 'Luca B.', 'Andrea V.', 'Giuseppe N.'],
      'teamB': ['Paolo M.', 'Stefano G.', 'Roberto F.', 'Matteo L.', 'Davide P.'],
      'scoreA': 2,
      'scoreB': 2,
      'myStats': {
        'goals': 0,
        'assists': 1,
        'rating': 7.0,
        'yellowCards': 0,
        'redCards': 0
      },
      'result': 'D'
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // Ridotto a 3 tab
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _headerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerAnimationController, curve: Curves.easeOut),
    );
    _headerAnimationController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (championship == null) {
      // Recupera gli argomenti passati tramite Navigator
      final arguments = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      if (arguments != null) {
        championship = arguments['championship'];
        user = arguments['user'];
        _loadClassifica();
      }
    }
  }

  Future<void> _loadClassifica() async {
    if (championship == null) return;

    try {
      final token = user!.token;
      final service = CampionatoService();
      // Assumendo che l'ID del campionato sia presente nell'oggetto championship
      final championshipId = championship!.id;
      final response = await service.getClassifica(token, int.parse(championshipId.toString()));
      setState(() {
        classifica = response.partecipazioni;
      });
    } catch (e) {
      print('Errore nel recupero classifica: $e');
    }
  }

  // Metodo per trovare la partecipazione dell'utente corrente
  Partecipazione? _getCurrentUserPartecipazione() {
    if (user == null || classifica.isEmpty) return null;

    final userEmail = user!.email;

    try {
      return classifica.firstWhere(
            (partecipazione) => partecipazione.utente.email == userEmail,
      );
    } catch (e) {
      return null;
    }
  }

  // Metodo per ottenere la posizione dell'utente corrente
  int? _getCurrentUserPosition() {
    if (user == null || classifica.isEmpty) return null;

    final userEmail = user!.email;

    for (int i = 0; i < classifica.length; i++) {
      if (classifica[i].utente.email == userEmail) {
        return i + 1; // +1 perché le posizioni partono da 1
      }
    }
    return null;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _headerAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Se non abbiamo ancora ricevuto i dati del campionato, mostra un loading
    if (championship == null || user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Caricamento...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final currentUserPartecipazione = _getCurrentUserPartecipazione();
    final currentUserPosition = _getCurrentUserPosition();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar con header animato
          SliverAppBar(
            expandedHeight: 280,
            floating: false,
            pinned: true,
            backgroundColor: Colors.deepPurple,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () {
                  // Condividi campionato
                },
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onPressed: () {
                  // Menu opzioni
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: AnimatedBuilder(
                animation: _headerAnimation,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.deepPurple,
                          Colors.deepPurple[300]!,
                          Colors.purple[200]!,
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Badge di stato
                          Transform.scale(
                            scale: _headerAnimation.value,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.play_circle_filled, color: Colors.white, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    'In corso',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Nome campionato
                          FadeTransition(
                            opacity: _headerAnimation,
                            child: Text(
                              championship!.nome,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Descrizione
                          FadeTransition(
                            opacity: _headerAnimation,
                            child: Text(
                              championship!.descrizione,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ),
                          const Spacer(),

                          // Quick stats
                          FadeTransition(
                            opacity: _headerAnimation,
                            child: Row(
                              children: [
                                _buildQuickStat('Posizione', currentUserPosition != null ? '${currentUserPosition}°' : '-', Icons.emoji_events),
                                const SizedBox(width: 24),
                                _buildQuickStat('Punti', currentUserPartecipazione != null ? '${currentUserPartecipazione.punti}' : '-', Icons.stars),
                                const SizedBox(width: 24),
                                _buildQuickStat('Partite', currentUserPartecipazione != null ? '${currentUserPartecipazione.partiteGiocate}' : '-', Icons.sports),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Tab Bar
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverTabBarDelegate(
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.deepPurple,
                labelColor: Colors.deepPurple,
                unselectedLabelColor: Colors.grey,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(icon: Icon(Icons.leaderboard), text: 'Classifica'),
                  Tab(icon: Icon(Icons.sports_soccer), text: 'Partite'),
                  Tab(icon: Icon(Icons.info), text: 'Info'),
                ],
              ),
            ),
          ),

          // Tab Content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPlayersStandingsTab(),
                _buildMatchesTab(),
                _buildInfoTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.8), size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // Tab 1: Classifica Giocatori
  Widget _buildPlayersStandingsTab() {
    final currentUserPartecipazione = _getCurrentUserPartecipazione();
    final currentUserPosition = _getCurrentUserPosition();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: classifica.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
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

        final partecipazione = classifica[index - 1];
        final userEmail = user!.email;
        final isMyPlayer = userEmail != null && partecipazione.utente.email == userEmail;

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 300 + (index * 100)),
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
                    color: _getPositionColor(index),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index}',
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
                subtitle: Text('${partecipazione.partiteGiocate} partite • ${partecipazione.golFatti}G ${partecipazione.assist}A • ⭐${partecipazione.mediaVoto?.toStringAsFixed(1) ?? '-'}'),
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
      },
    );
  }

  // Tab 2: Partite
  Widget _buildMatchesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Prossime partite
          _buildSectionHeader('Prossime Partite', Icons.schedule, Colors.blue),
          const SizedBox(height: 12),
          ...upcomingMatches.map((match) => _buildMatchCard(match, isUpcoming: true)),

          const SizedBox(height: 24),

          // Ultime partite
          _buildSectionHeader('Ultime Partite', Icons.history, Colors.orange),
          const SizedBox(height: 12),
          ...recentMatches.map((match) => _buildMatchCard(match, isUpcoming: false)),
        ],
      ),
    );
  }

  // Tab 3: Info
  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informazioni Campionato',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple[700],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildInfoItem('Nome', championship!.nome ?? 'N/A', Icons.sports_soccer),
                  _buildInfoItem('Descrizione', championship!.descrizione ?? 'N/A', Icons.description),
                  _buildInfoItem('Data Inizio', "Serve?" ?? 'N/A', Icons.calendar_today),
                  //_buildInfoItem('Numero Giocatori', '${championship!.numeroGiocatori ?? classifica.length}', Icons.people),
                  //_buildInfoItem('Totale Partite', '${championship!.totalePartite ?? 'N/A'}', Icons.sports),
                ],
              ),
            ),
          ),
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

  Widget _buildMatchCard(Map<String, dynamic> match, {required bool isUpcoming}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header partita
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    match['matchType'],
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  match['date'],
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Squadre
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Squadra A',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ...match['teamA'].take(3).map<Widget>((player) =>
                          Text(
                            player,
                            style: TextStyle(
                              fontSize: 12,
                              color: player == 'Tu' ? Colors.green[700] : Colors.grey[600],
                              fontWeight: player == 'Tu' ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                      ).toList(),
                      if (match['teamA'].length > 3)
                        Text(
                          '+${match['teamA'].length - 3} altri',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ),

                // Punteggio o orario
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isUpcoming
                        ? match['time']
                        : '${match['scoreA']} - ${match['scoreB']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Squadra B',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red[700],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ...match['teamB'].take(3).map<Widget>((player) =>
                          Text(
                            player,
                            style: TextStyle(
                              fontSize: 12,
                              color: player == 'Tu' ? Colors.green[700] : Colors.grey[600],
                              fontWeight: player == 'Tu' ? FontWeight.bold : FontWeight.normal,
                            ),
                            textAlign: TextAlign.end,
                          ),
                      ).toList(),
                      if (match['teamB'].length > 3)
                        Text(
                          '+${match['teamB'].length - 3} altri',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.end,
                        ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (isUpcoming)
                  Text(
                    match['venue'] ?? '',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  )
                else
                // Statistiche della partita giocata
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getResultColor(match['result']),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getResultText(match['result']),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Le tue stats: ${match['myStats']['goals']}G ${match['myStats']['assists']}A ⭐${match['myStats']['rating']}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.deepPurple, size: 20),
          ),
          const SizedBox(width: 16),
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

  Color _getPositionColor(int position) {
    if (position <= 3) return Colors.amber[600]!;
    if (position <= 8) return Colors.green[500]!;
    if (position <= 15) return Colors.blue[500]!;
    return Colors.grey[500]!;
  }

  Color _getResultColor(String result) {
    switch (result) {
      case 'W': return Colors.green;
      case 'D': return Colors.orange;
      case 'L': return Colors.red;
      default: return Colors.grey;
    }
  }

  String _getResultText(String result) {
    switch (result) {
      case 'W': return 'V';
      case 'D': return 'P';
      case 'L': return 'S';
      default: return '-';
    }
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverTabBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset,
      bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}