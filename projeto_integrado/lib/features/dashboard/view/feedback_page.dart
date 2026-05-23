import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/theme_provider.dart';
import '../viewmodel/feedbacks_viewmodel.dart';
import 'feedback_success_page.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _formKey = GlobalKey<FormState>();
  final _loteController = TextEditingController();
  final _moodController = TextEditingController();
  final _feedbackController = TextEditingController();
  final _logisticsController = TextEditingController();
  final _supportObservationsController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _photoFile;
  int _currentStep = 1;
  int _satisfaction = 0;
  int _productQuality = 9;
  int _deliveryPunctuality = 8;
  int _technicalKnowledge = 9;
  int _cordialityEmpathy = 10;
  int _supportQuality = 8;
  int _supportSatisfaction = 9;
  bool? _packagingAdequate;
  final List<String> _selectedTags = [];

  double get _progress {
    if (_currentStep == 1) {
      return 0.25;
    }

    if (_currentStep == 2) {
      int answeredFields = 0;
      if (_productQuality > 0) answeredFields++;
      if (_packagingAdequate != null) answeredFields++;
      if (_feedbackController.text.trim().isNotEmpty) answeredFields++;
      return 0.25 + (answeredFields / 3) * 0.25;
    }

    if (_currentStep == 3) {
      int answeredFields = 0;
      if (_deliveryPunctuality > 0) answeredFields++;
      if (_technicalKnowledge > 0) answeredFields++;
      if (_cordialityEmpathy > 0) answeredFields++;
      if (_logisticsController.text.trim().isNotEmpty) answeredFields++;
      return 0.5 + (answeredFields / 4) * 0.25;
    }

    int answeredFields = 0;
    if (_supportQuality > 0) answeredFields++;
    if (_supportSatisfaction > 0) answeredFields++;
    if (_supportObservationsController.text.trim().isNotEmpty) answeredFields++;
    return 0.75 + (answeredFields / 3) * 0.25;
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedImage = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1200,
      );
      if (pickedImage == null) return;

      final file = File(pickedImage.path);
      if (!await file.exists()) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Não foi possível acessar a imagem capturada. Tente novamente.',
            ),
          ),
        );
        return;
      }

      if (!mounted) return;
      setState(() {
        _photoFile = file;
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível selecionar a imagem: $error')),
      );
    }
  }

  Future<void> _showPhotoOptions() async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Tirar foto'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Escolher da galeria'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _goToNextStep() async {
    if (_formKey.currentState?.validate() != true) return;
    if (_currentStep == 1) {
      if (_satisfaction == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecione sua satisfação geral.')),
        );
        return;
      }
      setState(() => _currentStep = 2);
      return;
    }

    if (_currentStep == 2) {
      if (_packagingAdequate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Informe se a embalagem está adequada.'),
          ),
        );
        return;
      }
      if (_feedbackController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Escreva seu feedback por favor.')),
        );
        return;
      }
      if (_packagingAdequate == false) {
        // Photo is optional, but encouraged when packaging is irregular.
        // continue to next step even without a photo.
      }
      setState(() => _currentStep = 3);
      return;
    }

    if (_currentStep == 3) {
      setState(() => _currentStep = 4);
      return;
    }

    if (_currentStep == 4) {
      await _submitFeedback();
      return;
    }
  }

  void _goToPreviousStep() {
    if (_currentStep > 1) {
      setState(() => _currentStep -= 1);
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _submitFeedback() async {
    final vm = Provider.of<FeedbacksViewModel>(context, listen: false);
    final embalagemStatus = _packagingAdequate == true
        ? 'Adequada'
        : 'Irregular';
    final mensagemParts = <String>[];
    if (_feedbackController.text.trim().isNotEmpty) {
      mensagemParts.add('Feedback livre: ${_feedbackController.text.trim()}');
    }
    if (_logisticsController.text.trim().isNotEmpty) {
      mensagemParts.add(
        'Observações da Logística: ${_logisticsController.text.trim()}',
      );
    }
    if (_supportObservationsController.text.trim().isNotEmpty) {
      mensagemParts.add(
        'Observações do suporte: ${_supportObservationsController.text.trim()}',
      );
    }
    final mensagem = mensagemParts.join('\n\n');
    final lote = _loteController.text.trim();
    final packagingScore = _packagingAdequate == true
        ? 10
        : (_packagingAdequate == false ? 1 : 0);
    final itemScores = [
      _satisfaction,
      _productQuality,
      packagingScore,
      _deliveryPunctuality,
      _technicalKnowledge,
      _cordialityEmpathy,
      _supportQuality,
      _supportSatisfaction,
    ];
    final questionResponses = {
      'avaliacaoCopperfio': _satisfaction,
      'qualidadeProduto': _productQuality,
      'embalagemAdequada': _packagingAdequate,
      'embalagemScore': packagingScore,
      'prazoEntrega': _deliveryPunctuality,
      'conhecimentoTecnico': _technicalKnowledge,
      'cordialidadeEmpatia': _cordialityEmpathy,
      'qualidadeSuporteTecnico': _supportQuality,
      'satisfacaoSuporte': _supportSatisfaction,
      'feedbackLivre': _feedbackController.text.trim(),
      'observacoesLogistica': _logisticsController.text.trim(),
      'observacoesSuporte': _supportObservationsController.text.trim(),
    };

    try {
      await vm.enviarFeedback(
        mensagem: mensagem,
        lote: lote,
        itemScores: itemScores,
        generalRating: _satisfaction,
        atendimentoMood: embalagemStatus,
        tags: _selectedTags,
        photoFile: _photoFile,
        questionResponses: questionResponses,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feedback enviado com sucesso!')),
      );

      Future.delayed(const Duration(milliseconds: 900), () {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const FeedbackSuccessPage()),
        );
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar feedback: $error')),
      );
    }
  }

  Widget _buildHeader(String title, String subtitle, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(Icons.cable, color: Colors.white, size: 24),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.white),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  color: const Color(0xFFF9A825),
                  backgroundColor: const Color(0xFFFFE0B2),
                ),
              ),
            ),
            if (progress == 1.0) ...[
              const SizedBox(width: 12),
              const Text(
                '100%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildStars() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final value = index + 1;
        return IconButton(
          padding: EdgeInsets.zero,
          iconSize: 38,
          icon: Icon(
            value <= _satisfaction ? Icons.star : Icons.star_border,
            color: value <= _satisfaction
                ? const Color(0xFFDD7632)
                : Colors.black26,
          ),
          onPressed: () {
            setState(() => _satisfaction = value);
          },
        );
      }),
    );
  }

  Widget _buildRatingRow(
    String title,
    String subtitle,
    int currentValue,
    ValueChanged<double> onChanged,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              '$currentValue',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(color: Colors.black54, fontSize: 12),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 140),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF9C1818), Color(0xFFFFB300), Color(0xFF8CC63F)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Icon(
                    Icons.sentiment_very_dissatisfied,
                    color: Colors.white70,
                    size: 20,
                  ),
                  Icon(
                    Icons.sentiment_very_satisfied,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 5,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 10,
                  ),
                ),
                child: Slider(
                  value: currentValue.toDouble(),
                  min: 0,
                  max: 10,
                  divisions: 10,
                  activeColor: Colors.white,
                  inactiveColor: Colors.white38,
                  label: '$currentValue',
                  onChanged: onChanged,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'INACEITÁVEL',
                    style: TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                  Text(
                    'EXCEPCIONAL',
                    style: TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScoreCard(
    int currentValue,
    ValueChanged<double> onChanged,
    Color color,
  ) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 78),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF9C1818), Color(0xFFFFB300), Color(0xFF8CC63F)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Nota:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '$currentValue',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Icon(
                Icons.sentiment_very_dissatisfied,
                color: Colors.white70,
                size: 18,
              ),
              Icon(
                Icons.sentiment_very_satisfied,
                color: Colors.white,
                size: 18,
              ),
            ],
          ),
          const SizedBox(height: 5),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: currentValue.toDouble(),
              min: 0,
              max: 10,
              divisions: 10,
              activeColor: Colors.white,
              inactiveColor: Colors.white38,
              label: '$currentValue',
              onChanged: onChanged,
            ),
          ),
          const SizedBox(height: 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('0', style: TextStyle(color: Colors.white70, fontSize: 9)),
              Text('5', style: TextStyle(color: Colors.white70, fontSize: 9)),
              Text('10', style: TextStyle(color: Colors.white70, fontSize: 9)),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final scaffoldBg = isDark
        ? const Color(0xFF121212)
        : const Color(0xFFF7F3F1);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final fieldBg = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF7F3F1);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: const Color(0xFF9C1818),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: const Text(
          'COPPERFIO',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.nightlight_round, color: Colors.white),
            tooltip: 'Alternar tema',
            onPressed: themeProvider.toggleTheme,
          ),
        ],
      ),
      body: SafeArea(
        child: DefaultTextStyle(
          style: TextStyle(color: textColor),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFFD54F),
                          Color(0xFFFFB300),
                          Color(0xFFEF6C00),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha((0.18 * 255).round()),
                          blurRadius: 18,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'COPPERFIO',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (_currentStep == 1) ...[
                          const Text(
                            'Identificação e início',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          const SizedBox(height: 12),
                        ] else if (_currentStep == 2) ...[
                          const Text(
                            'Aprofundamento do Lote',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          const SizedBox(height: 12),
                        ] else if (_currentStep == 3) ...[
                          const Text(
                            'Logística e Comercial',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          const SizedBox(height: 12),
                        ] else ...[
                          const Text(
                            'Suporte Técnico Especializado',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          const SizedBox(height: 12),
                        ],
                        _buildHeader(
                          _currentStep == 1
                              ? 'Etapa 1: Início do lote'
                              : _currentStep == 2
                              ? 'Etapa 2: Bloco Produto'
                              : _currentStep == 3
                              ? 'Etapa 3: Logística e Comercial'
                              : 'Etapa 4: Bloco Suporte',
                          _currentStep == 1
                              ? 'Insira o código e faça sua avaliação da Copperfio.'
                              : _currentStep == 2
                              ? 'Avalie especificamente os itens de qualidade e embalagem.'
                              : _currentStep == 3
                              ? 'Sua opinião sobre nosso atendimento ajuda a forjar parcerias mais sólidas.'
                              : 'Avalie nosso suporte técnico e atendimento humano.',
                          _progress,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  if (_currentStep == 1) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: isDark
                              ? Colors.grey[800]!
                              : const Color(0xFFE9E5E2),
                        ),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Identificação do Lote',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _loteController,
                              style: TextStyle(color: textColor),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: fieldBg,
                                hintText: 'Digite o código',
                                hintStyle: TextStyle(
                                  color: isDark
                                      ? Colors.white54
                                      : Colors.grey[600],
                                ),
                                suffixIcon: const Icon(Icons.qr_code),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Informe o código do lote';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 18),
                            const Text(
                              'Qual sua satisfação com a Copperfio?',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 14),
                            _buildStars(),
                            const SizedBox(height: 8),
                            Text(
                              _satisfaction == 0
                                  ? 'Avalie a experiência da empresa.'
                                  : 'Sua avaliação da Copperfio: $_satisfaction estrelas',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: textColor.withAlpha(
                                  (0.75 * 255).round(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            SizedBox(
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _goToNextStep,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF9C1818),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text(
                                  'PRÓXIMA ETAPA',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else if (_currentStep == 2) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: isDark
                              ? Colors.grey[800]!
                              : const Color(0xFFE9E5E2),
                        ),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              'Aprofundamento do Lote',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Avalie especificamente os itens de qualidade e embalagem.',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? Colors.white54 : Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Qual a qualidade do produto?',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildScoreCard(
                              _productQuality,
                              (value) => setState(
                                () => _productQuality = value.round(),
                              ),
                              const Color(0xFF9C1818),
                            ),
                            const SizedBox(height: 22),
                            Row(
                              children: const [
                                Icon(
                                  Icons.inventory_2,
                                  color: Color(0xFF9C1818),
                                  size: 18,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Embalagem',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF9C1818),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Como avalia a integridade da embalagem?',
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      setState(() => _packagingAdequate = true);
                                    },
                                    icon: const Icon(Icons.thumb_up),
                                    label: const Text('Adequada'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor:
                                          _packagingAdequate == true
                                          ? Colors.white
                                          : const Color(0xFF9C1818),
                                      backgroundColor:
                                          _packagingAdequate == true
                                          ? const Color(0xFF9C1818)
                                          : null,
                                      side: const BorderSide(
                                        color: Color(0xFF9C1818),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      setState(
                                        () => _packagingAdequate = false,
                                      );
                                    },
                                    icon: const Icon(Icons.thumb_down),
                                    label: const Text('Irregular'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor:
                                          _packagingAdequate == false
                                          ? Colors.white
                                          : const Color(0xFF9C1818),
                                      backgroundColor:
                                          _packagingAdequate == false
                                          ? const Color(0xFF9C1818)
                                          : null,
                                      side: const BorderSide(
                                        color: Color(0xFF9C1818),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (_packagingAdequate == false) ...[
                              const SizedBox(height: 18),
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF3E0),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFFF57C00),
                                  ),
                                ),
                                padding: const EdgeInsets.all(16),
                                child: const Text(
                                  'Detectamos uma irregularidade. Se quiser, anexe uma foto para ajudar nossa equipe a analisar o problema.',
                                  style: TextStyle(color: Color(0xFFBF360C)),
                                ),
                              ),
                            ],
                            const SizedBox(height: 22),
                            Text(
                              'Detalhes adicionais',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _feedbackController,
                              style: TextStyle(color: textColor),
                              maxLines: 5,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: fieldBg,
                                hintText:
                                    'Conte o que aconteceu e o que podemos melhorar...',
                                hintStyle: TextStyle(
                                  color: isDark
                                      ? Colors.white54
                                      : Colors.grey[600],
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Escreva seu feedback.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 22),
                            if (_photoFile != null) ...[
                              ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: Image.file(
                                  _photoFile!,
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                            SizedBox(
                              height: 52,
                              child: ElevatedButton.icon(
                                onPressed: _showPhotoOptions,
                                icon: const Icon(Icons.camera_alt),
                                label: const Text('Adicionar Foto'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF9C1818),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: _goToNextStep,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF9C1818),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: const Text(
                                      'PRÓXIMA ETAPA',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  height: 52,
                                  child: OutlinedButton(
                                    onPressed: _goToPreviousStep,
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFF9C1818),
                                      side: const BorderSide(
                                        color: Color(0xFF9C1818),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: const Text(
                                      'VOLTAR',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else if (_currentStep == 3) ...[
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: isDark
                              ? Colors.grey[800]!
                              : const Color(0xFFE9E5E2),
                        ),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              'Logística e Comercial',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildRatingRow(
                              '4. Prazo de entrega',
                              'Como você avalia a pontualidade da entrega?',
                              _deliveryPunctuality,
                              (value) => setState(
                                () => _deliveryPunctuality = value.round(),
                              ),
                              const Color(0xFF9C1818),
                            ),
                            const SizedBox(height: 16),
                            _buildRatingRow(
                              '5. Conhecimento Técnico',
                              'Nossa equipe comercial domina as especificações dos fios?',
                              _technicalKnowledge,
                              (value) => setState(
                                () => _technicalKnowledge = value.round(),
                              ),
                              const Color(0xFF9C1818),
                            ),
                            const SizedBox(height: 16),
                            _buildRatingRow(
                              '6. Cordialidade e Empatia',
                              'Qual sua percepção sobre o tratamento recebido?',
                              _cordialityEmpathy,
                              (value) => setState(
                                () => _cordialityEmpathy = value.round(),
                              ),
                              const Color(0xFF9C1818),
                            ),
                            const SizedBox(height: 22),
                            Text(
                              'Observações da Logística',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _logisticsController,
                              style: TextStyle(color: textColor),
                              maxLines: 5,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: fieldBg,
                                hintText:
                                    'Algo específico sobre a entrega ou atendimento comercial?',
                                hintStyle: TextStyle(
                                  color: isDark
                                      ? Colors.white54
                                      : Colors.grey[600],
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: _goToNextStep,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF9C1818),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: const Text(
                                      'PRÓXIMA ETAPA',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  height: 52,
                                  child: OutlinedButton(
                                    onPressed: _goToPreviousStep,
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFF9C1818),
                                      side: const BorderSide(
                                        color: Color(0xFF9C1818),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: const Text(
                                      'VOLTAR',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else if (_currentStep == 4) ...[
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: isDark
                              ? Colors.grey[800]!
                              : const Color(0xFFE9E5E2),
                        ),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              'Avaliação do Suporte',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildRatingRow(
                              '7. Qualidade do suporte técnico',
                              'Nossos especialistas resolveram suas dúvidas com precisão?',
                              _supportQuality,
                              (value) => setState(
                                () => _supportQuality = value.round(),
                              ),
                              const Color(0xFF9C1818),
                            ),
                            const SizedBox(height: 16),
                            _buildRatingRow(
                              '8. Satisfação Geral',
                              'De forma geral, quão satisfeito está com nossos colaboradores?',
                              _supportSatisfaction,
                              (value) => setState(
                                () => _supportSatisfaction = value.round(),
                              ),
                              const Color(0xFF9C1818),
                            ),
                            const SizedBox(height: 22),
                            Text(
                              'Observações do Suporte',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _supportObservationsController,
                              style: TextStyle(color: textColor),
                              maxLines: 5,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: fieldBg,
                                hintText:
                                    'Algo específico sobre o suporte técnico ou atendimento humano?',
                                hintStyle: TextStyle(
                                  color: isDark
                                      ? Colors.white54
                                      : Colors.grey[600],
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: _submitFeedback,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF9C1818),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: const Text(
                                      'FINALIZAR AVALIAÇÃO',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  height: 52,
                                  child: OutlinedButton(
                                    onPressed: _goToPreviousStep,
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFF9C1818),
                                      side: const BorderSide(
                                        color: Color(0xFF9C1818),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: const Text(
                                      'VOLTAR',
                                      style: TextStyle(fontSize: 16),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
