import 'package:flutter/material.dart';

class CreateChampionshipDialog extends StatefulWidget {
  final Function(String nome, String descrizione, String tipologia) onCreateChampionship;

  const CreateChampionshipDialog({
    Key? key,
    required this.onCreateChampionship,
  }) : super(key: key);

  @override
  State<CreateChampionshipDialog> createState() => _CreateChampionshipDialogState();
}

class _CreateChampionshipDialogState extends State<CreateChampionshipDialog>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descrizioneController = TextEditingController();
  String? _selectedChampionshipType; // Variabile per la tipologia
  final List<String> _championshipTypes = ['Calcetto_a_5', 'Calcetto_a_7', 'Calcetto_a_8', 'Calcio_a_11']; // Opzioni

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nomeController.dispose();
    _descrizioneController.dispose();
    super.dispose();
  }

  void _handleCreate() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await widget.onCreateChampionship(
          _nomeController.text.trim(),
          _descrizioneController.text.trim(),
          _selectedChampionshipType!, // Passa la tipologia selezionata
        );
        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Errore durante la creazione: ${e.toString()}'),
              backgroundColor: Colors.red[600],
            ),
          );
        }
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      Colors.green[50]!,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: SingleChildScrollView( // Aggiunto per evitare overflow con più campi
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.green[600]!,
                              Colors.green[500]!,
                            ],
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add_circle,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Crea Nuovo Campionato',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Inserisci i dettagli del tuo campionato',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.8),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      // Form
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // Campo Nome
                              TextFormField(
                                controller: _nomeController,
                                decoration: InputDecoration(
                                  labelText: 'Nome Campionato',
                                  hintText: 'Es. Torneo Primavera 2024',
                                  prefixIcon: Icon(
                                    Icons.emoji_events,
                                    color: Colors.green[600],
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.green[300]!),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.green[600]!, width: 2),
                                  ),
                                  filled: true,
                                  fillColor: Colors.green[50],
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Il nome è obbligatorio';
                                  }
                                  if (value.trim().length < 3) {
                                    return 'Il nome deve avere almeno 3 caratteri';
                                  }
                                  if (value.trim().length > 50) {
                                    return 'Il nome non può superare 50 caratteri';
                                  }
                                  return null;
                                },
                                textCapitalization: TextCapitalization.words,
                                maxLength: 50,
                              ),

                              const SizedBox(height: 20),

                              // Campo Descrizione
                              TextFormField(
                                controller: _descrizioneController,
                                decoration: InputDecoration(
                                  labelText: 'Descrizione (opzionale)',
                                  hintText: 'Descrivi il tuo campionato...',
                                  prefixIcon: Icon(
                                    Icons.description,
                                    color: Colors.green[600],
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.green[300]!),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.green[600]!, width: 2),
                                  ),
                                  filled: true,
                                  fillColor: Colors.green[50],
                                ),
                                validator: (value) {
                                  if (value != null && value.trim().length > 200) {
                                    return 'La descrizione non può superare 200 caratteri';
                                  }
                                  return null;
                                },
                                maxLines: 3,
                                maxLength: 200,
                              ),

                              const SizedBox(height: 20),

                              // Dropdown per la Tipologia di Campionato
                              DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  labelText: 'Tipologia Campionato',
                                  prefixIcon: Icon(
                                    Icons.sports_soccer,
                                    color: Colors.green[600],
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.green[300]!),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.green[600]!, width: 2),
                                  ),
                                  filled: true,
                                  fillColor: Colors.green[50],
                                ),
                                value: _selectedChampionshipType,
                                hint: const Text('Seleziona tipologia'),
                                icon: Icon(Icons.arrow_drop_down, color: Colors.green[700]),
                                items: _championshipTypes.map((String type) {
                                  return DropdownMenuItem<String>(
                                    value: type,
                                    child: Text(type.replaceAll('_', ' ')),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedChampionshipType = newValue;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Seleziona una tipologia';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 24),

                              // Buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: TextButton(
                                      onPressed: _isLoading ? null : () {
                                        Navigator.of(context).pop();
                                      },
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        foregroundColor: Colors.green[700], // Colore testo per annulla
                                      ),
                                      child: const Text(
                                        'Annulla',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    flex: 2,
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null : _handleCreate,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green[600],
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        elevation: _isLoading ? 0 : 2, // Leggera ombra quando attivo
                                      ),
                                      child: _isLoading
                                          ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                          : const Text(
                                        'Crea Campionato',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
