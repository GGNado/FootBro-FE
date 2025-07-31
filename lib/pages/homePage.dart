import 'package:flutter/material.dart';
import 'package:foot_bro/pages/widget/joinCampionatoWidget.dart';
import 'package:foot_bro/service/campionatoService.dart';
import '../entity/campionato/campionatoResponse.dart';

import '../entity/user/user.dart';


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  User? user;

  List<CampionatoResponse> campionati = [];

  // Animazioni
  late AnimationController _headerAnimationController;
  late AnimationController _cardsAnimationController;
  late AnimationController _floatingAnimationController;

  late Animation<double> _headerFadeAnimation;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is User) {
      user = arguments;
    } else {
      //TODO: elimina
      // Dati di esempio per demo senza campionati nell'entità User
      user = User(
        id: 1,
        username: 'footbro_user',
        email: 'user@footbro.com',
        firstName: 'Mario',
        lastName: 'Rossi',
        token: '',
      );
    }
    _startAnimations();
    _fetchCampionati();
  }

  Future<void> _fetchCampionati() async {
    try {
      final service = CampionatoService();
      final results = await service.getCampionati(user!.token, user!.id);
      setState(() {
        campionati = results;
      });
    } catch (e) {
      debugPrint('Errore durante il fetch dei campionati: $e');
    }
  }

  void _initAnimations() {
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _cardsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _floatingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _headerFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeInOut,
    ));

    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.elasticOut,
    ));

    _floatingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _floatingAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimations() {
    _headerAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      _cardsAnimationController.forward();
    });
    _floatingAnimationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _cardsAnimationController.dispose();
    _floatingAnimationController.dispose();
    super.dispose();
  }

  void _handleLogout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Sei sicuro di voler uscire?'),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15)
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)
              ),
            ),
            child: const Text(
                'Esci',
                style: TextStyle(color: Colors.white)
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.green[600]!,
              Colors.green[400]!,
              Colors.lightGreen[200]!,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header personalizzato con dati utente
              _buildUserHeader(),

              // Contenuto principale
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      const SizedBox(height: 10),

                      // Quick stats
                      _buildQuickStats(),

                      const SizedBox(height: 30),

                      // Sezione Campionati (ora usando championships)
                      if (campionati.isNotEmpty)
                        _buildChampionshipsSection(),

                      if (campionati.isNotEmpty)
                        const SizedBox(height: 30),

                      Text(
                        'Menu Principale',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Cards menu
                      _buildAnimatedCard(
                        'Partite di oggi',
                        Icons.calendar_today,
                        Colors.blue,
                        '3 partite programmate',
                        0,
                      ),
                      const SizedBox(height: 15),
                      _buildAnimatedCard(
                        'La mia squadra',
                        Icons.group,
                        Colors.orange,
                        '12 giocatori attivi',
                        1,
                      ),
                      const SizedBox(height: 15),
                      _buildAnimatedCard(
                        'Statistiche',
                        Icons.bar_chart,
                        Colors.purple,
                        'Vedi le tue performance',
                        2,
                      ),
                      const SizedBox(height: 15),
                      _buildAnimatedCard(
                        'Tornei',
                        Icons.emoji_events,
                        Colors.amber,
                        '2 tornei disponibili',
                        3,
                      ),
                      const SizedBox(height: 15),
                      _buildAnimatedCard(
                        'Campo vicino',
                        Icons.location_on,
                        Colors.red,
                        'Trova campi nelle vicinanze',
                        4,
                      ),
                      const SizedBox(height: 15),
                      _buildAnimatedCard(
                        'Impostazioni',
                        Icons.settings,
                        Colors.grey,
                        'Personalizza la tua esperienza',
                        5,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // Floating action button animato
      floatingActionButton: AnimatedBuilder(
        animation: _floatingAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: 0.9 + (0.1 * _floatingAnimation.value),
            child: FloatingActionButton.extended(
              onPressed: _showJoinChampionshipDialog, // Cambia questa riga
              backgroundColor: Colors.green[600],
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Entra nel Campionato', // Cambia il testo
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedCard(String title, IconData icon, Color color, String subtitle, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 800 + (index * 100)),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        // Clamp del value per assicurarsi che sia sempre nel range valido
        final safeValue = value.clamp(0.0, 1.0);

        return Transform.scale(
          scale: safeValue,
          child: Opacity(
            opacity: safeValue,
            child: child,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$title - Da implementare'),
                  backgroundColor: color,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(icon, color: color, size: 30),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
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
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey[400],
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserHeader() {
    return AnimatedBuilder(
      animation: _headerFadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _headerFadeAnimation,
          child: SlideTransition(
            position: _headerSlideAnimation,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Avatar utente
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: user != null
                          ? Text(
                        '${user!.firstName[0]}${user!.lastName[0]}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[600],
                        ),
                      )
                          : Icon(
                        Icons.person,
                        size: 35,
                        color: Colors.green[600],
                      ),
                    ),
                  ),

                  const SizedBox(width: 20),

                  // Info utente
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user != null
                              ? 'Ciao, ${user!.firstName}!'
                              : 'Ciao, Utente!',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user != null
                              ? '@${user!.username}'
                              : 'Benvenuto su FootBro',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Menu utente
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)
                    ),
                    onSelected: (value) {
                      switch (value) {
                        case 'profile':
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Profilo - Da implementare')
                            ),
                          );
                          break;
                        case 'logout':
                          _handleLogout();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'profile',
                        child: Row(
                          children: [
                            Icon(Icons.person_outline, color: Colors.green),
                            SizedBox(width: 12),
                            Text('Profilo'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(Icons.logout, color: Colors.red),
                            SizedBox(width: 12),
                            Text('Logout'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
              'Partite', '12', Icons.sports_soccer, Colors.blue
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildStatCard('Goal', '8', Icons.sports, Colors.orange),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildStatCard(
              'Assist', '5', Icons.thumbs_up_down, Colors.green
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      builder: (context, animValue, child) {
        // Clamp dell'animValue per assicurarsi che sia sempre nel range valido
        final safeAnimValue = animValue.clamp(0.0, 1.0);

        return Transform.scale(
          scale: safeAnimValue,
          child: Opacity(
            opacity: safeAnimValue,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Icon(icon, color: color, size: 30),
                  const SizedBox(height: 8),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildChampionshipsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.emoji_events, color: Colors.amber[600], size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'I tuoi Campionati',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount: campionati.length,
            itemBuilder: (context, index) {
              final championship = campionati[index];
              return Container(
                width: 220,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _getChampionshipColor(index),
                      _getChampionshipColor(index).withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: _getChampionshipColor(index).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${championship.nome ?? ''} - Da implementare'),
                          backgroundColor: _getChampionshipColor(index),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header row con icona e posizione
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.emoji_events,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${index + 3}°',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Nome campionato
                          Text(
                            championship.nome ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),

                          // Descrizione
                          Text(
                            championship.descrizione ?? '',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 11,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const Spacer(),

                          // Info footer
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.people,
                                    color: Colors.white.withOpacity(0.8),
                                    size: 12,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${8 + index * 2} squadre',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(
                                    Icons.schedule,
                                    color: Colors.white.withOpacity(0.8),
                                    size: 12,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Dom 15:00',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getChampionshipColor(int index) {
    final colors = [
      Colors.deepPurple,
      Colors.indigo,
      Colors.teal,
      Colors.orange,
      Colors.pink,
      Colors.brown,
    ];
    return colors[index % colors.length];
  }

  Future<void> _handleJoinChampionship(String code) async {
    try {
      final service = CampionatoService();
      final success = await service.joinCampionato(user!.token, user!.id, code);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Iscrizione al campionato completata!'),
            backgroundColor: Colors.green[600],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );

        _fetchCampionati();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

// Metodo per mostrare il dialog
  void _showJoinChampionshipDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => JoinChampionshipDialog(
        onJoinChampionship: _handleJoinChampionship,
      ),
    );
  }
}