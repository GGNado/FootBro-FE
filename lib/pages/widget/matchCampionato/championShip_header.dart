import 'package:flutter/material.dart';
import 'package:foot_bro/entity/campionato/campionatoResponse.dart';
import 'package:foot_bro/entity/user/user.dart';
import '../../../entity/statistiche/classificaResponse.dart';

class ChampionshipHeader extends StatelessWidget {
  final CampionatoResponse championship;
  final User user;
  final Animation<double> headerAnimation;
  final Partecipazione? currentUserPartecipazione;
  final int? currentUserPosition;

  const ChampionshipHeader({
    Key? key,
    required this.championship,
    required this.user,
    required this.headerAnimation,
    required this.currentUserPartecipazione,
    required this.currentUserPosition,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
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
          animation: headerAnimation,
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
                      scale: headerAnimation.value,
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
                      opacity: headerAnimation,
                      child: Text(
                        championship.nome,
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
                      opacity: headerAnimation,
                      child: Text(
                        championship.descrizione,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ),
                    const Spacer(),

                    // Quick stats
                    FadeTransition(
                      opacity: headerAnimation,
                      child: Row(
                        children: [
                          _buildQuickStat(
                              'Posizione',
                              currentUserPosition != null ? '${currentUserPosition}°' : '-',
                              Icons.emoji_events
                          ),
                          const SizedBox(width: 24),
                          _buildQuickStat(
                              'Punti',
                              currentUserPartecipazione != null ? '${currentUserPartecipazione!.punti}' : '-',
                              Icons.stars
                          ),
                          const SizedBox(width: 24),
                          _buildQuickStat(
                              'Partite',
                              currentUserPartecipazione != null ? '${currentUserPartecipazione!.partiteGiocate}' : '-',
                              Icons.sports
                          ),
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
}