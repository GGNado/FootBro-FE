import 'package:flutter/material.dart';
import 'package:foot_bro/entity/campionato/campionatoResponse.dart';
import 'package:foot_bro/entity/partita/partita.dart';
import 'package:foot_bro/entity/user/user.dart';
import 'package:foot_bro/pages/widget/matchCampionato/championShip_header.dart';
import 'package:foot_bro/pages/widget/matchCampionato/info_tab.dart';
import 'package:foot_bro/pages/widget/matchCampionato/matches.dart';
import 'package:foot_bro/pages/widget/matchCampionato/player_standings.dart';
import 'package:foot_bro/pages/widget/matchCampionato/silver_tab.dart';
import '../entity/partita/partitaSmall.dart';
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
  bool isUserAdmin = false;

  // Classifica ricevuta dal backend
  List<Partecipazione> classifica = [];

  // Prossime partite
  List<Partita> upcomingMatches = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
      final arguments = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      if (arguments != null) {
        championship = arguments['championship'];
        user = arguments['user'];
        _loadClassifica();
        _loadUpcomingMatches();
        _chechIfUserIsAdmin();
      }
    }
  }

  Future<void> _loadUpcomingMatches() async {
    if (championship == null) return;

    try {
      final token = user!.token;
      final service = CampionatoService();
      final response = await service.getPartiteProgrammateDetails(token, championship!.id);
      setState(() {
        upcomingMatches = response;
      });
    } catch (e) {
      print('Errore nel recupero partite programmate: $e');
    }
  }

  Future<void> _loadClassifica() async {
    if (championship == null) return;

    try {
      final token = user!.token;
      final service = CampionatoService();
      final championshipId = championship!.id;
      final response = await service.getClassifica(token, int.parse(championshipId.toString()));
      setState(() {
        classifica = response.partecipazioni;
      });
    } catch (e) {
      print('Errore nel recupero classifica: $e');
    }
  }

  // Metodo per controllare se l'utente è iscritto a una partita
  bool isUserRegisteredForMatch(Partita match) {
    if (user == null) return false;

    return match.partecipazioni.any(
            (partecipazione) => partecipazione.utente.email == user!.email
    );
  }

  // Metodo per iscriversi/disiscriversi da una partita
  Future<void> toggleMatchRegistration(Partita match) async {
    final isRegistered = isUserRegisteredForMatch(match);

    try {
      final service = CampionatoService();

      if (isRegistered) {
        // await service.unregisterFromMatch(user!.token, match.id);

        setState(() {
          match.partecipazioni.removeWhere(
                  (p) => p.utente.email == user!.email
          );
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ti sei disiscritto dalla partita'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        // await service.registerForMatch(user!.token, match.id);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ti sei iscritto alla partita'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Errore: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Metodo per trovare la partecipazione dell'utente corrente
  Partecipazione? getCurrentUserPartecipazione() {
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
  int? getCurrentUserPosition() {
    if (user == null || classifica.isEmpty) return null;

    final userEmail = user!.email;

    for (int i = 0; i < classifica.length; i++) {
      if (classifica[i].utente.email == userEmail) {
        return i + 1;
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
    if (championship == null || user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Caricamento...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header animato
          ChampionshipHeader(
            championship: championship!,
            user: user!,
            headerAnimation: _headerAnimation,
            currentUserPartecipazione: getCurrentUserPartecipazione(),
            currentUserPosition: getCurrentUserPosition(),
          ),

          // Tab Bar
          SliverPersistentHeader(
            pinned: true,
            delegate: SliverTabBarDelegate(
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
                PlayersStandingsTab(
                  classifica: classifica,
                  user: user!,
                  getCurrentUserPartecipazione: getCurrentUserPartecipazione,
                  getCurrentUserPosition: getCurrentUserPosition,
                ),
                MatchesTab(
                  upcomingMatches: upcomingMatches,
                  user: user!,
                  isUserAdmin: isUserAdmin,
                  isUserRegisteredForMatch: isUserRegisteredForMatch,
                  toggleMatchRegistration: toggleMatchRegistration,
                  reloadUpcomingMatches: _loadUpcomingMatches,
                ),
                InfoTab(championship: championship!),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _chechIfUserIsAdmin() {
    if (user == null || championship == null) return;
    isUserAdmin = user!.email == championship!.creatore.email;

  }
}