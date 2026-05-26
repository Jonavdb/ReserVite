import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_f03/models/manager/table.dart';
import '../../providers/manager/manager_state_provider.dart';

class EditTable extends ConsumerStatefulWidget {
  final int restaurantId;
  final RestaurantTable? table;

  const EditTable({super.key, required this.restaurantId, this.table});

  @override
  ConsumerState<EditTable> createState() => _EditTableState();
}

class _EditTableState extends ConsumerState<EditTable> {
  late int _capacity;
  int? _number;
  String? _errorMessage;
  String? _numberError;

  @override
  void initState() {
    super.initState();
    _capacity = widget.table?.capacity ?? 2;
    _number = widget.table?.number;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final simulatedTime = DateTime(2024, 12, 4, 16, 0);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: Text(widget.table != null ? 'Modifier la table' : 'Nouvelle table'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Enregistrer',
            onPressed: _numberError == null
                ? (widget.table != null ? () => _update(context) : () => _insert(context))
                : null,
            icon: const Icon(Icons.save),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir les données',
            onPressed: () {
              ref.read(managerStateProvider.notifier).loadRestaurantTables(widget.restaurantId);
            },
          ),
        ],
        elevation: 2,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        surfaceTintColor: Colors.transparent,
        flexibleSpace: Align(
          alignment: Alignment.topCenter,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Tooltip(
                message: 'Date/heure simulée utilisée pour les tests.\nCliquez pour modifier.',
                child: Text(
                  DateFormat('EEEE dd/MM/yyyy HH:mm', 'fr_FR').format(simulatedTime),
                  style: TextStyle(fontSize: 10, color: Colors.grey[400], fontWeight: FontWeight.normal),
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  initialValue: _number?.toString(),
                  decoration: InputDecoration(
                    labelText: 'Numéro de table',
                    hintText: 'Numéro de table', // Fait office de placeholder si le champ est vide
                    border: OutlineInputBorder(),
                    errorText: _numberError,
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final parsedNumber = int.tryParse(value);

                    // si l'utilisateur efface tout le texte, on remet à null
                    if (value.isEmpty) {
                      setState(() {
                        _number = null;
                        _numberError = 'Le numéro de table est obligatoire.';
                      });
                      return;
                    }

                    if (parsedNumber == null) return;

                    // récupère la liste actuelle des tables
                    final currentState = ref.read(managerStateProvider).value;
                    final tables = currentState?.availableTables ?? [];

                    // vérifie si ce numéro existe déjà (en excluant la table qu'on modifie)
                    final isUsed = tables.any((t) => t.number == parsedNumber && t.id != widget.table?.id);

                    setState(() {
                      _number = parsedNumber;
                      _numberError = isUsed ? 'Ce numéro de table est déjà utilisé pour ce restaurant.' : null;
                    });
                  },
                ),
                const SizedBox(height: 16),
                const Text('Capacité'),
                Row(
                  children: [
                    IconButton(icon: const Icon(Icons.remove), onPressed: _handleDecrease),
                    Text('$_capacity personnes', style: const TextStyle(fontSize: 18)),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          _capacity++;
                          _errorMessage = null;
                        });
                      },
                    ),
                  ],
                ),

                // Info-bulle qui affiche le msg d'erreur
                if (_errorMessage != null)
                  Container(
                    margin: const EdgeInsets.only(top: 8.0),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(color: Colors.grey[600], borderRadius: BorderRadius.circular(4)),
                    child: Text(_errorMessage!, style: const TextStyle(color: Colors.white, fontSize: 13)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _update(BuildContext context) async {
    final notifier = ref.read(managerStateProvider.notifier);
    await notifier.updateTable(widget.table!, _capacity, _number!);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Table mise à jour avec succès')));

      notifier.loadRestaurantTables(widget.restaurantId);
      Navigator.of(context).pop();
    }
  }

  void _insert(BuildContext context) async {
    final notifier = ref.read(managerStateProvider.notifier);
    await notifier.createTable(_capacity, _number!);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Table créée avec succès')));

      notifier.loadRestaurantTables(widget.restaurantId);
      Navigator.of(context).pop();
    }
  }

  Future<void> _handleDecrease() async {
    // efface l'erreur précédente s'il y en a une
    setState(() => _errorMessage = null);

    // erreur : on ne peut pas descendre en dessous de 1
    if (_capacity <= 1) {
      setState(() => _errorMessage = 'Capacité minimale (1 personne)');
      return;
    }

    final newCapacity = _capacity - 1;

    // CREATE : diminue sans contacter la BDD
    if (widget.table == null) {
      setState(() => _capacity = newCapacity);
      return;
    }

    // UPDATE : demande à la BDD
    final isValid = await ref.read(managerStateProvider.notifier).validateTableCapacity(widget.table!.id, newCapacity);

    if (isValid) {
      setState(() => _capacity = newCapacity);
    } else {
      setState(() {
        _errorMessage =
            'Impossible de diminuer la capacité : une ou plusieurs réservations utilisent cette table et nécessitent au moins cette capacité.';
      });
    }
  }
}
