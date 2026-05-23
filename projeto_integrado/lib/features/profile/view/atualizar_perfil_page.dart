import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import '../../../core/cnpj_input_formatter.dart';
import '../../../core/phone_input_formatter.dart';
import '../../../core/theme_provider.dart';
import '../../profile/viewmodel/current_user_viewmodel.dart';

class AtualizarPerfilPage extends StatefulWidget {
  const AtualizarPerfilPage({super.key});

  @override
  State<AtualizarPerfilPage> createState() => _AtualizarPerfilPageState();
}

class _AtualizarPerfilPageState extends State<AtualizarPerfilPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _companyController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _positionController = TextEditingController();
  final _sectorController = TextEditingController();
  final _registrationController = TextEditingController();

  File? _selectedImage;
  bool _uploadingImage = false;
  String? _profileImageUrl;
  bool _removeProfileImage = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final viewModel = context.read<CurrentUserViewModel>();
    await viewModel.loadUserData();
    final data = viewModel.userData;
    if (data != null) {
      _nameController.text = data['nome'] as String? ?? '';
      _companyController.text = data['empresa'] as String? ?? 'Copperfio';
      _cnpjController.text = CnpjInputFormatter.format(
        data['cnpj'] as String? ?? '',
      );
      _emailController.text =
          data['email'] as String? ?? viewModel.currentUser?.email ?? '';
      _phoneController.text = PhoneInputFormatter.format(
        data['telefone'] as String? ?? '',
      );
      _positionController.text = data['cargo'] as String? ?? '';
      _sectorController.text =
          data['setor'] as String? ?? data['departamento'] as String? ?? '';
      _registrationController.text =
          data['matricula'] as String? ?? data['idInterno'] as String? ?? '';
      _profileImageUrl = data['fotoPerfil'] as String?;
      setState(() {});
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _removeProfileImage = false;
      });
    }
  }

  void _removeSelectedImage() {
    setState(() {
      _selectedImage = null;
      _profileImageUrl = null;
      _removeProfileImage = true;
    });
  }

  Future<String?> _uploadProfileImage() async {
    if (_selectedImage == null) return null;
    if (!await _selectedImage!.exists()) {
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Arquivo de imagem não encontrado. Tente novamente.'),
        ),
      );
      return null;
    }

    try {
      setState(() {
        _uploadingImage = true;
      });

      // Ler arquivo e converter para base64
      final bytes = await _selectedImage!.readAsBytes();
      final base64Image = base64Encode(bytes);
      final dataUrl = 'data:image/jpeg;base64,$base64Image';

      setState(() {
        _uploadingImage = false;
      });

      return dataUrl;
    } catch (e) {
      setState(() {
        _uploadingImage = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao processar foto: $e')));
      }
      return null;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _cnpjController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _positionController.dispose();
    _sectorController.dispose();
    _registrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFA);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final isGestor =
        context.watch<CurrentUserViewModel>().userType == 'empresa';

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF8C1D18),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Copperfio',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: Colors.white,
            ),
            onPressed: themeProvider.toggleTheme,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.2 : 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isGestor ? 'Perfil Gestor' : 'Perfil',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Atualize os dados de sua conta Copperfio.',
                        style: TextStyle(
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Seção de Foto de Perfil
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.2 : 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Foto de Perfil',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: _uploadingImage ? null : _pickImage,
                        child: Stack(
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF9C1818).withOpacity(0.1),
                                border: Border.all(
                                  color: const Color(0xFF9C1818),
                                  width: 2,
                                ),
                              ),
                              child: _selectedImage != null
                                  ? ClipOval(
                                      child: Image.file(
                                        _selectedImage!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : _profileImageUrl != null
                                  ? _profileImageUrl!.startsWith('data:image')
                                        ? ClipOval(
                                            child: Image.memory(
                                              base64Decode(
                                                _profileImageUrl!
                                                    .split(',')
                                                    .last,
                                              ),
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                    return Icon(
                                                      Icons.person,
                                                      size: 60,
                                                      color: const Color(
                                                        0xFF9C1818,
                                                      ),
                                                    );
                                                  },
                                            ),
                                          )
                                        : ClipOval(
                                            child: Image.network(
                                              _profileImageUrl!,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                    return Icon(
                                                      Icons.person,
                                                      size: 60,
                                                      color: const Color(
                                                        0xFF9C1818,
                                                      ),
                                                    );
                                                  },
                                            ),
                                          )
                                  : Icon(
                                      Icons.person,
                                      size: 60,
                                      color: const Color(0xFF9C1818),
                                    ),
                            ),
                            if (_uploadingImage)
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black.withOpacity(0.3),
                                  ),
                                  child: const Center(
                                    child: SizedBox(
                                      width: 30,
                                      height: 30,
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            if (!_uploadingImage)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF9C1818),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Toque para alterar',
                        style: TextStyle(
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                          fontSize: 12,
                        ),
                      ),
                      if ((_selectedImage != null ||
                              _profileImageUrl != null) &&
                          !_uploadingImage)
                        TextButton.icon(
                          onPressed: _removeSelectedImage,
                          icon: const Icon(
                            Icons.delete_forever,
                            color: Color(0xFF9C1818),
                            size: 18,
                          ),
                          label: const Text(
                            'Remover foto',
                            style: TextStyle(
                              color: Color(0xFF9C1818),
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildField(
                        label: 'Nome Completo',
                        controller: _nameController,
                        textColor: textColor,
                        bgColor: isDark
                            ? const Color(0xFF1E1E1E)
                            : const Color(0xFFF2F2F2),
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        label: 'Empresa',
                        controller: _companyController,
                        textColor: textColor,
                        bgColor: isDark
                            ? const Color(0xFF1E1E1E)
                            : const Color(0xFFF2F2F2),
                        isRequired: false,
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        label: 'Cargo',
                        controller: _positionController,
                        textColor: textColor,
                        bgColor: isDark
                            ? const Color(0xFF1E1E1E)
                            : const Color(0xFFF2F2F2),
                        isRequired: false,
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        label: 'Setor',
                        controller: _sectorController,
                        textColor: textColor,
                        bgColor: isDark
                            ? const Color(0xFF1E1E1E)
                            : const Color(0xFFF2F2F2),
                      ),
                      if (isGestor) ...[
                        const SizedBox(height: 16),
                        _buildField(
                          label: 'Matrícula',
                          controller: _registrationController,
                          textColor: textColor,
                          bgColor: isDark
                              ? const Color(0xFF1E1E1E)
                              : const Color(0xFFF2F2F2),
                          isRequired: false,
                        ),
                      ],
                      const SizedBox(height: 16),
                      _buildField(
                        label: 'Email corporativo',
                        controller: _emailController,
                        textColor: textColor,
                        bgColor: isDark
                            ? const Color(0xFF1E1E1E)
                            : const Color(0xFFF2F2F2),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        label: 'Telefone corporativo',
                        controller: _phoneController,
                        textColor: textColor,
                        bgColor: isDark
                            ? const Color(0xFF1E1E1E)
                            : const Color(0xFFF2F2F2),
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(11),
                          PhoneInputFormatter(),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        label: 'CNPJ',
                        controller: _cnpjController,
                        textColor: textColor,
                        bgColor: isDark
                            ? const Color(0xFF1E1E1E)
                            : const Color(0xFFF2F2F2),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(14),
                          CnpjInputFormatter(),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8C1D18),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState?.validate() ?? false) {
                              String? imageUrl;

                              if (_selectedImage != null) {
                                imageUrl = await _uploadProfileImage();
                                if (imageUrl == null && mounted) {
                                  return;
                                }
                              }

                              final updateData = {
                                'nome': _nameController.text.trim(),
                                'empresa': _companyController.text.trim(),
                                'cargo': _positionController.text.trim(),
                                'setor': _sectorController.text.trim(),
                                'cnpj': CnpjInputFormatter.digitsOnly(
                                  _cnpjController.text,
                                ),
                                'email': _emailController.text.trim(),
                                'email_lower': _emailController.text
                                    .trim()
                                    .toLowerCase(),
                                'telefone': PhoneInputFormatter.digitsOnly(
                                  _phoneController.text,
                                ),
                              };
                              if (isGestor) {
                                updateData['matricula'] =
                                    _registrationController.text.trim();
                              }

                              if (_removeProfileImage) {
                                updateData['fotoPerfil'] = '';
                              } else if (imageUrl != null) {
                                updateData['fotoPerfil'] = imageUrl;
                              }

                              final viewModel = context
                                  .read<CurrentUserViewModel>();
                              await viewModel.updateProfile(updateData);

                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Perfil atualizado com sucesso',
                                    ),
                                  ),
                                );
                                Navigator.pop(context);
                              }
                            }
                          },
                          child: const Text(
                            'Salvar alterações',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required Color textColor,
    required Color bgColor,
    TextInputType keyboardType = TextInputType.text,
    bool isRequired = true,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            filled: true,
            fillColor: bgColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          validator: isRequired
              ? (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Campo obrigatório';
                  }
                  return null;
                }
              : null,
        ),
      ],
    );
  }
}
