import 'package:flutter_cep/model/cep_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_cep/repositories/cep_repository.dart';
import 'package:flutter_cep/ui/widgets/address_widget.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final repository = CepRepository(client: http.Client());
  final cepController = TextEditingController();
  final cepFormatter = MaskTextInputFormatter(
    mask: '#####-###',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );
  String? errorMessage;
  CepModel? cepModel;
  bool isLoading = false;

  Future<void> buscarCep() async {
    FocusScope.of(context).unfocus(); // Fecha o teclado

    final cep = cepController.text.trim();

    // 1. Valide o CEP primeiro, antes de mudar o estado de carregamento.
    if (cep.isEmpty) {
      setState(() {
        errorMessage = 'Por favor, insira um CEP.';
        cepModel = null;
      });
      return;
    }

    // 2. Se a validação passar, mude o estado para "carregando".
    setState(() {
      errorMessage = null;
      cepModel = null;
      isLoading = true;
    });

    // 3. Tente buscar o CEP.
    try {
      final addressModel = await repository.consultarCep(cep);
      setState(() {
        cepModel = addressModel;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      // 4. Finalize o estado de carregamento, independentemente do resultado.
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    cepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consulta de CEP'),
        leading: Icon(Icons.location_city),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 24,
          children: [
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.1),
                    theme.colorScheme.secondary.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                spacing: 24,
                children: [
                  Icon(
                    Icons.search_rounded,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                  Text(
                    'Busque por qualquer CEP',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Text(
                    'Digite o CEP e descubra o endereço completo',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  TextField(
                    controller: cepController,
                    keyboardType: TextInputType.number,
                    maxLength: 9,
                    inputFormatters: [cepFormatter],
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.location_on_rounded),
                      labelText: 'CEP',
                      hintText: 'Digite o CEP (Ex: 01310-100)',
                      counterText: '',
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 200),
                    child: isLoading
                        ? Container(
                            width: 200,
                            height: 50,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,

                                spacing: 12,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  Text(
                                    'Buscando CEP...',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ElevatedButton.icon(
                            onPressed: buscarCep,
                            icon: const Icon(Icons.search_rounded),
                            label: Text('Buscar CEP'),
                          ),
                  ),

                  Visibility(
                    visible: errorMessage != null,
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.error.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            color: theme.colorScheme.error,
                            size: 24,
                          ),
                          SizedBox(
                            width: 12,
                          ),
                          Text(
                            errorMessage ?? '',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.error,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Visibility(
                    visible: cepModel != null,
                    child: AnimatedOpacity(
                      opacity: cepModel != null ? 1.0 : 0.0,
                      duration: Duration(milliseconds: 300),
                      child: AddressWidget(cepModel: cepModel),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
