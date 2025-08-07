import 'package:flutter/material.dart';
import 'package:foot_bro/entity/campionato/campionatoResponse.dart';
import 'package:foot_bro/entity/partita/partita.dart';
import 'package:foot_bro/entity/partita/partitaCreateRequest.dart';
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

    // Listener per aggiornare il FAB quando cambia tab
    _tabController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

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

  // Metodo per aggiungere una nuova partita
  Future<void> _addNewMatch(PartitaCreateRequest partitaCreateRequest) async {
    try {
      final service = CampionatoService();

      final success = await service.addPartita(user!.token, championship!.id, partitaCreateRequest);
      if (success) {
        await _loadUpcomingMatches();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Partita aggiunta con successo'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Errore nell\'aggiungere la partita'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Errore nell\'aggiungere la partita: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Metodo per controllare se l'utente è iscritto a una partita
  bool isUserRegisteredForMatch(Partita match) {
    if (user == null) return false;

    return match.partecipazioni.any(
            (partecipazione) => partecipazione.utente.email == user!.email
    );
  }

  Future<void> toggleMatchRegistration(Partita match) async {
    final isRegistered = isUserRegisteredForMatch(match);

    try {
      final service = CampionatoService();

      if (isRegistered) {
        final success = await service.unregisterFromMatch(user!.token, match.id, user!.id);

        if (success) {
          setState(() {
            match.partecipazioni.removeWhere(
                  (p) => p.utente.email == user!.email,
            );
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ti sei disiscritto dalla partita'),
              backgroundColor: Colors.orange,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Errore nella disiscrizione dalla partita'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        final success = await service.iscrivitiAllaPartita(user!.token, match.id, user!.id);

        if (success) {
          await _loadUpcomingMatches();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ti sei iscritto alla partita'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Errore nell\'iscrizione alla partita'),
              backgroundColor: Colors.red,
            ),
          );
        }
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

  // Metodo per mostrare il form di aggiunta partita
  void _showAddMatchDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddMatchDialog(
          onAddMatch: _addNewMatch,
        );
      },
    );
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
      // Floating Action Button solo nel tab Partite e solo per gli admin
      floatingActionButton: (isUserAdmin && _tabController.index == 1)
          ? FloatingActionButton(
        onPressed: _showAddMatchDialog,
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _chechIfUserIsAdmin() {
    if (user == null || championship == null) return;
    isUserAdmin = user!.email == championship!.creatore.email;
  }
}

// Dialog per aggiungere una nuova partita
class AddMatchDialog extends StatefulWidget {
  final Function(PartitaCreateRequest) onAddMatch;

  const AddMatchDialog({
    Key? key,
    required this.onAddMatch,
  }) : super(key: key);

  @override
  State<AddMatchDialog> createState() => _AddMatchDialogState();
}

class _AddMatchDialogState extends State<AddMatchDialog> {
  final _formKey = GlobalKey<FormState>();
  final _luogoController = TextEditingController();
  DateTime _selectedDateTime = DateTime.now().add(const Duration(days: 1));

  @override
  void dispose() {
    _luogoController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final partitaCreateRequest = PartitaCreateRequest(
        dataOra: _selectedDateTime,
        luogo: _luogoController.text.trim(),
      );

      widget.onAddMatch(partitaCreateRequest);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Aggiungi Nuova Partita',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Campo luogo
            TextFormField(
              controller: _luogoController,
              decoration: const InputDecoration(
                labelText: 'Luogo',
                hintText: 'Inserisci il luogo della partita',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Il luogo è obbligatorio';
                }
                if (value.trim().length < 3) {
                  return 'Il luogo deve contenere almeno 3 caratteri';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Selezione data e ora
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today, color: Colors.deepPurple),
                title: const Text('Data e Ora'),
                subtitle: Text(
                  '${_selectedDateTime.day.toString().padLeft(2, '0')}/${_selectedDateTime.month.toString().padLeft(2, '0')}/${_selectedDateTime.year} - ${_selectedDateTime.hour.toString().padLeft(2, '0')}:${_selectedDateTime.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: _selectDateTime,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annulla'),
        ),
        ElevatedButton(
          onPressed: _submitForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
          ),
          child: const Text('Aggiungi'),
        ),
      ],
    );
  }
}