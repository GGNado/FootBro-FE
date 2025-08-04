import 'package:flutter/material.dart';
import 'package:foot_bro/entity/campionato/campionatoResponse.dart';

class InfoTab extends StatelessWidget {
  final CampionatoResponse championship;

  const InfoTab({
    Key? key,
    required this.championship,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  _buildInfoItem('Nome', championship.nome ?? 'N/A', Icons.sports_soccer),
                  _buildInfoItem('Descrizione', championship.descrizione ?? 'N/A', Icons.description),
                  _buildInfoItem('Data Inizio', "Serve?" ?? 'N/A', Icons.calendar_today),
                  //_buildInfoItem('Numero Giocatori', '${championship.numeroGiocatori ?? classifica.length}', Icons.people),
                  //_buildInfoItem('Totale Partite', '${championship.totalePartite ?? 'N/A'}', Icons.sports),
                ],
              ),
            ),
          ),
        ],
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
}