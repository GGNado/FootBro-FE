// lib/pages/widget/matchCampionato/formationFieldWidget.dart
import 'package:flutter/material.dart';

class FormationFieldWidget extends StatefulWidget {
  final List<dynamic> teamA;
  final List<dynamic> teamB;

  const FormationFieldWidget({
    Key? key,
    required this.teamA,
    required this.teamB,
  }) : super(key: key);

  @override
  State<FormationFieldWidget> createState() => _FormationFieldWidgetState();
}

class _FormationFieldWidgetState extends State<FormationFieldWidget> {
  late Map<String, Offset> playerPositions;
  late Size fieldSize;

  @override
  void initState() {
    super.initState();
    _initializePositions();
  }

  void _initializePositions() {
    playerPositions = {};
    double topSide = 0.2;
    for (int i = 0; i < widget.teamA.length; i++) {
      String playerId = '${widget.teamA[i].utente.id}_A';
      double x = 0.2 + (i * 0.6 / (widget.teamA.length - 1));
      if (widget.teamA.length == 1) x = 0.5;
      playerPositions[playerId] = Offset(x, topSide);
    }
    double bottomSide = 0.8;
    for (int i = 0; i < widget.teamB.length; i++) {
      String playerId = '${widget.teamB[i].utente.id}_B';
      double x = 0.2 + (i * 0.6 / (widget.teamB.length - 1));
      if (widget.teamB.length == 1) x = 0.5;
      playerPositions[playerId] = Offset(x, bottomSide);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[900],
      appBar: AppBar(
        title: const Text('Campo'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _resetPositions,
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset posizioni',
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          fieldSize = Size(constraints.maxWidth, constraints.maxHeight);
          return Stack(
            children: [
              _buildFootballField(),
              ..._buildPlayers(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFootballField() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.green[600]!,
            Colors.green[500]!,
            Colors.green[600]!,
          ],
        ),
      ),
      child: CustomPaint(
        painter: FootballFieldPainter(),
      ),
    );
  }

  List<Widget> _buildPlayers() {
    List<Widget> players = [];
    for (var player in widget.teamA) {
      String playerId = '${player.utente.id}_A';
      players.add(_buildDraggablePlayer(
        playerId,
        player.utente.username,
        Colors.blue,
      ));
    }
    for (var player in widget.teamB) {
      String playerId = '${player.utente.id}_B';
      players.add(_buildDraggablePlayer(
        playerId,
        player.utente.username,
        Colors.red,
      ));
    }
    return players;
  }

  Widget _buildDraggablePlayer(String playerId, String playerName, Color teamColor) {
    Offset position = playerPositions[playerId] ?? const Offset(0.5, 0.5);
    return Positioned(
      left: position.dx * fieldSize.width - 25,
      top: position.dy * fieldSize.height - 25,
      child: GestureDetector(
        onPanUpdate: (details) {
          double newX = (position.dx * fieldSize.width + details.delta.dx) / fieldSize.width;
          double newY = (position.dy * fieldSize.height + details.delta.dy) / fieldSize.height;
          newX = newX.clamp(0.05, 0.95);
          newY = newY.clamp(0.05, 0.95);
          setState(() {
            playerPositions[playerId] = Offset(newX, newY);
          });
        },
        child: _buildPlayerAvatar(playerName, teamColor),
      ),
    );
  }

  Widget _buildPlayerAvatar(String playerName, Color teamColor, {bool isDragging = false, bool isGhost = false}) {
    double opacity = isGhost ? 0.3 : 1.0;
    double elevation = isDragging ? 8.0 : 4.0;
    String displayName = playerName.length > 8 ? '${playerName.substring(0, 6)}..' : playerName;
    return Material(
      elevation: elevation,
      borderRadius: BorderRadius.circular(25),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: teamColor.withOpacity(opacity),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person,
              color: Colors.white.withOpacity(opacity),
              size: 20,
            ),
            Text(
              displayName,
              style: TextStyle(
                color: Colors.white.withOpacity(opacity),
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _resetPositions() {
    setState(() {
      _initializePositions();
    });
  }
}

// Aggiorna FootballFieldPainter
class FootballFieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Bordo campo
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Linea centrale orizzontale
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );

    // Cerchio centrale
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width * 0.15,
      paint,
    );

    // Porta in alto
    final goalWidth = size.width * 0.3;
    final goalHeight = 12.0;
    canvas.drawRect(
      Rect.fromLTWH(
        (size.width - goalWidth) / 2,
        0,
        goalWidth,
        goalHeight,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}