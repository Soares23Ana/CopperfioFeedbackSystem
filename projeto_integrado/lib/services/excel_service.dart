import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ExcelService {
  // Cache para CNPJs já consultados
  static final Map<String, String> _cnpjCache = {};

  // Buscar CNPJ do usuário com cache
  static Future<String> _buscarCnpjUsuario(String userId) async {
    if (userId.isEmpty) return '';

    // Verificar cache primeiro
    if (_cnpjCache.containsKey(userId)) {
      return _cnpjCache[userId] ?? '';
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final cnpj = userDoc.data()?['cnpj']?.toString() ?? '';
        _cnpjCache[userId] = cnpj; // Guardar no cache
        return cnpj;
      }
    } catch (e) {
      print('⚠️ Erro ao buscar CNPJ do usuário $userId: $e');
    }

    _cnpjCache[userId] = ''; // Cache vazio para não tentar novamente
    return '';
  }

  static String _formatFeedbackDate(dynamic rawDate) {
    if (rawDate == null) return '';

    if (rawDate is DateTime) {
      return '${rawDate.day.toString().padLeft(2, '0')}/${rawDate.month.toString().padLeft(2, '0')}/${rawDate.year}';
    }

    if (rawDate is Timestamp) {
      final date = rawDate.toDate();
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }

    if (rawDate is int) {
      final date = DateTime.fromMillisecondsSinceEpoch(rawDate);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }

    final parsed = DateTime.tryParse(rawDate.toString());
    if (parsed != null) {
      return '${parsed.day.toString().padLeft(2, '0')}/${parsed.month.toString().padLeft(2, '0')}/${parsed.year}';
    }

    return rawDate.toString();
  }

  static Future<void> gerarExcel({
    List<Map<String, dynamic>>? feedbacks,
  }) async {
    try {
      // Limpar cache para nova geração
      _cnpjCache.clear();

      // 1. BUSCANDO OS DADOS DO FIREBASE (ou usando os feedbacks passados)
      List<Map<String, dynamic>> dadosJson;
      if (feedbacks != null) {
        dadosJson = feedbacks;
      } else {
        var snapshot = await FirebaseFirestore.instance
            .collection('feedbacks')
            .get();
        if (snapshot.docs.isEmpty) {
          print("Nenhum dado encontrado no Firebase.");
          return;
        }

        dadosJson = snapshot.docs.map((doc) => doc.data()).toList();
      }

      // 2. CRIANDO A PLANILHA EXCEL
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Planilha1'];

      if (excel.getDefaultSheet() != 'Planilha1') {
        excel.delete('Sheet1');
      }

      // Estilos Visuais baseados no modelo da Copperfio
      CellStyle estiloPainelGeral = CellStyle(
        backgroundColorHex: ExcelColor.fromHexString('#FFFF00'), // Amarelo
        bold: true,
        horizontalAlign: HorizontalAlign.Center,
      );

      CellStyle estiloCabecalho = CellStyle(
        backgroundColorHex: ExcelColor.fromHexString(
          '#C5E1A5',
        ), // Tom pastel/cinza-esverdeado do modelo
        fontColorHex: ExcelColor.fromHexString('#000000'),
        bold: true,
        horizontalAlign: HorizontalAlign.Center,
        fontFamily: getFontFamily(FontFamily.Arial),
      );

      CellStyle estiloBordasComum = CellStyle(
        horizontalAlign: HorizontalAlign.Center,
        fontFamily: getFontFamily(FontFamily.Arial),
      );

      // 3. ADICIONANDO O PAINEL DE MÉDIA GERAL (Linha superior)
      // Mescla as células para fazer o bloco "MÉDIA GERAL: 9,9%" igual ao modelo
      sheetObject.merge(
        CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: 1),
        CellIndex.indexByColumnRow(columnIndex: 11, rowIndex: 1),
        customValue: TextCellValue('MÉDIA GERAL:'),
      );

      // Coloca a fórmula da média geral na célula L2 (coluna 11, linha 1) que calcula tudo automaticamente
      // O cálculo final será injetado dinamicamente dependendo de quantas linhas houverem
      int totalDeRegistros = dadosJson.length;
      int ultimaLinhaDados =
          totalDeRegistros + 4; // Os dados vão começar na linha 4 (index 3)

      var celulaMediaTexto = sheetObject.cell(
        CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: 1),
      );
      var celulaMediaValor = sheetObject.cell(
        CellIndex.indexByColumnRow(columnIndex: 11, rowIndex: 1),
      );

      // Fórmula do excel que tira a média de todas as médias dos clientes (Coluna L)
      celulaMediaValor.value = FormulaCellValue(
        '=AVERAGE(L5:L$ultimaLinhaDados)',
      );

      celulaMediaTexto.cellStyle = estiloPainelGeral;
      celulaMediaValor.cellStyle = estiloPainelGeral;

      // 4. DEFININDO OS CABEÇALHOS EXATOS DO MODELO (Fica na linha 4 / Index 3)
      List<String> colunasModelo = [
        'Cliente',
        'CNPJ',
        'Data',
        'Item 1',
        'Item 2',
        'Item 3',
        'Item 4',
        'Item 5',
        'Item 6',
        'Item 7',
        'Item 8',
        'média\n(cliente)',
        'Plano de Ação',
        'Ação tomada (Gerência Vendas)',
        'Retorno ao cliente',
        'Cliente satisfeito (eficaz)',
      ];

      // Pula algumas linhas para dar o espaçamento do topo e insere o cabeçalho
      sheetObject.appendRow(
        colunasModelo.map((e) => TextCellValue(e)).toList(),
      ); // Linha index 3

      // Aplica o estilo cinza/verde nos cabeçalhos
      for (int col = 0; col < colunasModelo.length; col++) {
        var cell = sheetObject.cell(
          CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 3),
        );
        cell.cellStyle = estiloCabecalho;
      }

      // 5. PREENCHENDO AS LINHAS COM OS MAPEAMENTOS DO FIREBASE
      int numeroDaLinhaAtual = 5; // No Excel visual, começará na linha 5

      for (var documento in dadosJson) {
        // Extrai com segurança os valores numéricos dos itens do seu Firebase
        // Caso o Firebase venha nulo ou texto, ele converte com segurança para double
        // Suporta chaves com lowercase ('item1') e legacy ('Item1')
        double item1 =
            double.tryParse(
              documento['item1']?.toString() ??
                  documento['Item1']?.toString() ??
                  '0',
            ) ??
            0.0;
        double item2 =
            double.tryParse(
              documento['item2']?.toString() ??
                  documento['Item2']?.toString() ??
                  '0',
            ) ??
            0.0;
        double item3 =
            double.tryParse(
              documento['item3']?.toString() ??
                  documento['Item3']?.toString() ??
                  '0',
            ) ??
            0.0;
        double item4 =
            double.tryParse(
              documento['item4']?.toString() ??
                  documento['Item4']?.toString() ??
                  '0',
            ) ??
            0.0;
        double item5 =
            double.tryParse(
              documento['item5']?.toString() ??
                  documento['Item5']?.toString() ??
                  '0',
            ) ??
            0.0;
        double item6 =
            double.tryParse(
              documento['item6']?.toString() ??
                  documento['Item6']?.toString() ??
                  '0',
            ) ??
            0.0;
        double item7 =
            double.tryParse(
              documento['item7']?.toString() ??
                  documento['Item7']?.toString() ??
                  '0',
            ) ??
            0.0;
        double item8 =
            double.tryParse(
              documento['item8']?.toString() ??
                  documento['Item8']?.toString() ??
                  '0',
            ) ??
            0.0;

        // Média do feedback vinda do Firebase
        double notaMedia =
            double.tryParse(documento['notaMedia']?.toString() ?? '0') ?? 0.0;

        // Nome da empresa cliente vindo do Firebase
        String cliente =
            documento['userEmpresa']?.toString() ??
            documento['empresa']?.toString() ??
            '';

        // Tenta usar o CNPJ direto do documento, se houver
        String cnpj =
            documento['cnpj']?.toString() ??
            documento['CNPJ']?.toString() ??
            '';
        cnpj = cnpj.trim();

        // Se o CNPJ não estiver no documento de feedback, busca pelo userId
        final userId =
            documento['userId']?.toString() ??
            documento['userID']?.toString() ??
            '';
        if (cnpj.isEmpty && userId.isNotEmpty) {
          cnpj = await _buscarCnpjUsuario(userId);
          print('✅ CNPJ do usuário $userId: $cnpj (Cliente: $cliente)');
        } else if (cnpj.isNotEmpty) {
          print('✅ CNPJ encontrado no feedback: $cnpj (Cliente: $cliente)');
        } else {
          print(
            '⚠️ CNPJ não encontrado para cliente: $cliente | userId: $userId',
          );
        }

        String dataFeedback = _formatFeedbackDate(
          documento['data'] ?? documento['Data'] ?? documento['createdAt'],
        );

        // Monta a linha exatamente na estrutura da Copperfio
        List<CellValue> valoresColunas = [
          TextCellValue(cliente), // A: Cliente
          TextCellValue(cnpj), // B: CNPJ
          TextCellValue(dataFeedback), // C: Data
          DoubleCellValue(item1), // D: Item 1
          DoubleCellValue(item2), // E: Item 2
          DoubleCellValue(item3), // F: Item 3
          DoubleCellValue(item4), // G: Item 4
          DoubleCellValue(item5), // H: Item 5
          DoubleCellValue(item6), // I: Item 6
          DoubleCellValue(item7), // J: Item 7
          DoubleCellValue(item8), // K: Item 8
          // L: média (cliente) -> Usa a notaMedia já calculada e salva no Firebase
          DoubleCellValue(notaMedia),

          TextCellValue(
            'Sim [  ]  Não [  ]',
          ), // M: Plano de Ação estruturado para checagem
          TextCellValue('Não aplicável'), // N: Ação tomada
          TextCellValue('Sim [  ]  Não [  ]'), // O: Retorno ao cliente
          TextCellValue('Sim [  ]  Não [  ]'), // P: Cliente satisfeito
        ];

        sheetObject.appendRow(valoresColunas);

        // Aplica alinhamento centralizado nos dados inseridos
        for (int col = 0; col < valoresColunas.length; col++) {
          var cell = sheetObject.cell(
            CellIndex.indexByColumnRow(
              columnIndex: col,
              rowIndex: numeroDaLinhaAtual - 1,
            ),
          );
          cell.cellStyle = estiloBordasComum;
        }

        numeroDaLinhaAtual++;
      }

      // 6. AJUSTANDO A LARGURA DAS COLUNAS PARA FICAR LEGÍVEL
      sheetObject.setColumnWidth(0, 30.0); // Coluna do nome do cliente maior
      sheetObject.setColumnWidth(1, 18.0); // CNPJ
      sheetObject.setColumnWidth(2, 14.0); // Data do feedback
      for (int i = 3; i <= 10; i++) {
        sheetObject.setColumnWidth(
          i,
          10.0,
        ); // Tamanho ideal para as notas dos Itens 1 a 8
      }
      sheetObject.setColumnWidth(11, 15.0); // Média do cliente
      sheetObject.setColumnWidth(12, 20.0); // Plano de ação
      sheetObject.setColumnWidth(
        13,
        32.0,
      ); // Ação tomada (campo de texto maior)
      sheetObject.setColumnWidth(14, 22.0); // Retorno ao cliente
      sheetObject.setColumnWidth(15, 25.0); // Cliente satisfeito

      // 7. SALVANDO E COMPARTILHANDO O ARQUIVO CORRIGIDO
      var fileBytes = excel.save();

      if (fileBytes != null) {
        Directory directory = await getTemporaryDirectory();
        String filePath = '${directory.path}/pesquisa_satisfacao_clientes.xlsx';

        File file = File(filePath);
        await file.writeAsBytes(fileBytes);

        await Share.shareXFiles(
          [XFile(filePath)],
          text:
              'Segue em anexo o relatório de Pesquisa de Satisfação de Clientes atualizado no modelo da empresa.',
        );
      }
    } catch (e) {
      print("Erro crítico ao gerar o Excel Formatado: $e");
    }
  }
}
