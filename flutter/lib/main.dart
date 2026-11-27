import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/curriculum.dart';
import 'core/ocr_service.dart';
import 'core/sync_contract.dart';
import 'core/travia_model.dart';

void main() => runApp(
      MaterialApp(
        title: 'Travia',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff315c52)),
          useMaterial3: true,
        ),
        home: const TraviaApp(),
      ),
    );

class TraviaApp extends StatefulWidget {
  const TraviaApp({super.key});
  @override
  State<TraviaApp> createState() => _TraviaAppState();
}

class _TraviaAppState extends State<TraviaApp> {
  TraviaState data = TraviaState();
  SharedPreferences? prefs;
  int selectedCourse = 0;
  int page = 0;
  bool loading = true;
  bool syncing = false;
  String syncMessage = '';
  String syncToken = '';
  int syncRevision = 0;
  Timer? focusTimer;
  int focusSeconds = 0;
  bool ocrProcessing = false;
  int ocrCurrent = 0;
  int ocrTotal = 1;
  String ocrMessage = '';
  final imagePicker = ImagePicker();
  final ocrService = OcrService();
  final note = TextEditingController();
  final question = TextEditingController();
  final endpoint = TextEditingController();
  final model = TextEditingController();
  final apiKey = TextEditingController();
  final server = TextEditingController(text: 'http://10.0.2.2:4173');
  final email = TextEditingController();
  final password = TextEditingController();
  final pages = const <String>[
    'Início',
    'Graduação',
    'Caderno',
    'Calendário',
    'Materiais',
    'Estudar',
    'Laboratório',
    'Tutor',
    'Configurações'
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    focusTimer?.cancel();
    for (final c in [
      note,
      question,
      endpoint,
      model,
      apiKey,
      server,
      email,
      password
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    prefs = await SharedPreferences.getInstance();
    final raw = prefs!.getString('travia-data-v1');
    if (raw != null) {
      try {
        data = TraviaState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      } catch (_) {
        data = TraviaState(
            courses: cloneCurriculum(), materials: <Map<String, dynamic>>[]);
      }
    }
    if (data.courses.isEmpty) {
      data = TraviaState(
          courses: cloneCurriculum(), materials: <Map<String, dynamic>>[]);
    }
    endpoint.text = data.tutor['endpoint']?.toString() ?? '';
    model.text = data.tutor['model']?.toString() ?? '';
    _selectCourse(data.courses.first['id'] as int);
    if (mounted) setState(() => loading = false);
    await _recoverLostImage();
  }

  Future<void> _save() async {
    await prefs?.setString('travia-data-v1', jsonEncode(data.toJson()));
    if (mounted) setState(() {});
  }

  Map<String, dynamic> get current =>
      data.courses[selectedCourse.clamp(0, data.courses.length - 1).toInt()];
  void _selectCourse(int id) {
    final index = data.courses.indexWhere((course) => course['id'] == id);
    if (index < 0) return;
    selectedCourse = index;
    note.text = data.notes['$id']?.toString() ?? '';
    if (mounted) setState(() {});
  }

  Future<void> _backup() async => FilePicker.saveFile(
      fileName: 'travia-backup.json',
      bytes: Uint8List.fromList(utf8.encode(jsonEncode(data.toJson()))));
  Future<void> _restore() async {
    final files = await FilePicker.pickFiles(
        type: FileType.custom, allowedExtensions: ['json']);
    final file = files.isEmpty ? null : files.single;
    final bytes = file == null ? null : await file.readAsBytes();
    if (bytes == null) return;
    try {
      data = TraviaState.fromJson(
          jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>);
      if (data.courses.isEmpty) data = TraviaState(courses: cloneCurriculum());
      _selectCourse(data.courses.first['id'] as int);
      await _save();
    } catch (_) {
      _message('Backup inválido.');
    }
  }

  void _message(String value) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(value)));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final wide = MediaQuery.sizeOf(context).width >= 820;
    return Scaffold(
      appBar: AppBar(title: Text(pages[page]), actions: [
        IconButton(
            onPressed: _backup,
            tooltip: 'Backup',
            icon: const Icon(Icons.download))
      ]),
      body: Row(children: [
        if (wide)
          NavigationRail(
              selectedIndex: page,
              labelType: NavigationRailLabelType.all,
              onDestinationSelected: (value) => setState(() => page = value),
              destinations: pages
                  .map((label) => NavigationRailDestination(
                      icon: Icon(_icon(label)), label: Text(label)))
                  .toList()),
        Expanded(child: _screen())
      ]),
      drawer: wide
          ? null
          : Drawer(
              child: ListView(children: [
              const DrawerHeader(
                  child: Text('Travia', style: TextStyle(fontSize: 28))),
              for (var i = 0; i < pages.length; i++)
                ListTile(
                    selected: page == i,
                    leading: Icon(_icon(pages[i])),
                    title: Text(pages[i]),
                    onTap: () {
                      setState(() => page = i);
                      Navigator.pop(context);
                    })
            ])),
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: page.clamp(0, 4).toInt(),
              onDestinationSelected: (value) => setState(() => page = value),
              destinations: pages
                  .take(5)
                  .map((label) => NavigationDestination(
                      icon: Icon(_icon(label)), label: label))
                  .toList()),
    );
  }

  IconData _icon(String label) =>
      {
        'Início': Icons.home,
        'Graduação': Icons.school,
        'Caderno': Icons.menu_book,
        'Calendário': Icons.calendar_month,
        'Materiais': Icons.folder,
        'Estudar': Icons.timer,
        'Laboratório': Icons.science,
        'Tutor': Icons.chat,
        'Configurações': Icons.settings
      }[label] ??
      Icons.circle;
  Widget _screen() {
    switch (pages[page]) {
      case 'Graduação':
        return _matrix();
      case 'Caderno':
        return _notebook();
      case 'Calendário':
        return _calendar();
      case 'Materiais':
        return _materials();
      case 'Estudar':
        return _study();
      case 'Laboratório':
        return _lab();
      case 'Tutor':
        return _tutor();
      case 'Configurações':
        return _settings();
      default:
        return _dashboard();
    }
  }

  Widget _dashboard() {
    final approved =
        data.courses.where((c) => c['status'] == 'Aprovado').length;
    final active = data.courses
        .where((c) =>
            c['status'] == 'Em andamento' || c['status'] == 'Matriculado')
        .length;
    return ListView(padding: const EdgeInsets.all(20), children: [
      Text('Olá! Vamos avançar um pouco hoje.',
          style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 16),
      _statCard(
          'Progresso',
          '$approved/${data.courses.length} disciplinas aprovadas',
          Icons.school),
      _statCard('Em andamento', '$active disciplinas', Icons.trending_up),
      _statCard('Agenda', '${data.events.length} eventos', Icons.event),
      _statCard('Materiais', '${data.materials.length} arquivos locais',
          Icons.folder),
      const Card(
          child: ListTile(
              leading: Icon(Icons.offline_bolt),
              title: Text('Modo offline ativo'),
              subtitle:
                  Text('O estado acadêmico é mantido neste dispositivo.')))
    ]);
  }

  Widget _statCard(String title, String value, IconData icon) => Card(
      child: ListTile(
          leading: Icon(icon), title: Text(title), subtitle: Text(value)));
  Future<void> _editGrade(int index) async {
    final controller = TextEditingController(
        text: data.courses[index]['grade']?.toString() ?? '');
    final accepted = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('Nota: ${data.courses[index]['name']}'),
              content: TextField(
                  controller: controller,
                  autofocus: true,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                      labelText: 'Nota (opcional)', hintText: 'Ex.: 8,5')),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancelar')),
                FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Salvar'))
              ],
            ));
    if (accepted == true) {
      final value = controller.text.trim();
      data.courses[index]['grade'] = value;
      await _save();
    }
    controller.dispose();
  }

  Widget _matrix() => ListView(padding: const EdgeInsets.all(12), children: [
        for (var i = 0; i < data.courses.length; i++)
          Card(
              child: ListTile(
                  onTap: () => _editGrade(i),
                  title: Text(data.courses[i]['name'].toString()),
                  subtitle: Text(
                      '${data.courses[i]['hours']} h · ${data.courses[i]['period']}º período · Nota ${data.courses[i]['grade'] ?? '-'}'),
                  trailing: DropdownButton<String>(
                      value: data.courses[i]['status']?.toString() ??
                          'Não cursada',
                      items: [
                        'Não cursada',
                        'Planejada',
                        'Matriculado',
                        'Em andamento',
                        'Aprovado',
                        'Reprovado'
                      ]
                          .map(
                              (s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          data.courses[i]['status'] = value;
                          _save();
                        }
                      })))
      ]);
  Widget _coursePicker() => DropdownButton<int>(
      value: current['id'] as int,
      isExpanded: true,
      items: data.courses
          .map((c) => DropdownMenuItem(
              value: c['id'] as int, child: Text(c['name'].toString())))
          .toList(),
      onChanged: (id) {
        if (id != null) _selectCourse(id);
      });
  Widget _notebook() => Padding(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        _coursePicker(),
        Expanded(
            child: TextField(
                controller: note,
                expands: true,
                maxLines: null,
                decoration: const InputDecoration(
                    labelText: 'Anotações', border: OutlineInputBorder()))),
        const SizedBox(height: 12),
        FilledButton(
            onPressed: () {
              data.notes['${current['id']}'] = note.text;
              _save();
              _message('Caderno salvo.');
            },
            child: const Text('Salvar caderno'))
      ]));

  Future<void> _addEvent() async {
    final title = TextEditingController();
    DateTime? date = DateTime.now();
    final accepted = await showDialog<bool>(
        context: context,
        builder: (context) => StatefulBuilder(
            builder: (context, setDialog) => AlertDialog(
                    title: const Text('Novo evento'),
                    content: Column(mainAxisSize: MainAxisSize.min, children: [
                      TextField(
                          controller: title,
                          autofocus: true,
                          decoration:
                              const InputDecoration(labelText: 'Título')),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                          onPressed: () async {
                            final selected = await showDatePicker(
                                context: context,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2100),
                                initialDate: date!);
                            if (selected != null) {
                              setDialog(() => date = selected);
                            }
                          },
                          icon: const Icon(Icons.date_range),
                          label:
                              Text('${date!.day}/${date!.month}/${date!.year}'))
                    ]),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancelar')),
                      FilledButton(
                          onPressed: () => Navigator.pop(
                              context, title.text.trim().isNotEmpty),
                          child: const Text('Salvar'))
                    ])));
    if (accepted == true) {
      data.events.add({
        'id': DateTime.now().millisecondsSinceEpoch,
        'title': title.text.trim(),
        'date': date!.toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String()
      });
      await _save();
    }
    title.dispose();
  }

  Widget _calendar() => ListView(padding: const EdgeInsets.all(16), children: [
        FilledButton.icon(
            onPressed: _addEvent,
            icon: const Icon(Icons.add),
            label: const Text('Adicionar evento')),
        for (final event in data.events)
          Card(
              child: ListTile(
                  leading: const Icon(Icons.event),
                  title: Text(event['title'].toString()),
                  subtitle: Text(event['date'].toString()),
                  trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {
                        data.events.remove(event);
                        _save();
                      })))
      ]);

  Future<void> _importMaterial() async {
    final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg']);
    final file = files.isEmpty ? null : files.single;
    if (file == null) return;
    if (file.path == null) {
      _message('Não foi possível acessar o arquivo selecionado.');
      return;
    }
    data.materials.add({
      'id': DateTime.now().millisecondsSinceEpoch,
      'name': file.name,
      'size': await file.length(),
      'path': await _copyMaterialFile(file.path!, file.name),
      'updatedAt': DateTime.now().toIso8601String()
    });
    await _save();
  }

  Future<String> _copyMaterialFile(String sourcePath, String name) async {
    final directory = await getApplicationDocumentsDirectory();
    final safeName = name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final target = File(
        '${directory.path}${Platform.pathSeparator}${DateTime.now().microsecondsSinceEpoch}_$safeName');
    await File(sourcePath).copy(target.path);
    return target.path;
  }

  Widget _materials() => ListView(padding: const EdgeInsets.all(16), children: [
        FilledButton.icon(
            onPressed: _showMaterialImportMenu,
            icon: const Icon(Icons.upload_file),
            label: const Text('Importar PDF ou imagem')),
        if (ocrProcessing) ...[
          const SizedBox(height: 16),
          LinearProgressIndicator(value: ocrCurrent / ocrTotal),
          const SizedBox(height: 6),
          Text(ocrMessage, textAlign: TextAlign.center),
        ],
        const SizedBox(height: 12),
        for (final material in data.materials)
          Card(
              child: ListTile(
                  title: Text(material['name'].toString()),
                  subtitle: Text(
                      '${material['size'] ?? 0} bytes · arquivo local${material['ocrText'] != null ? ' · OCR salvo' : ''}'),
                  onTap: () => _previewMaterial(material),
                  trailing: material['path'].toString().isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.text_snippet),
                          tooltip: 'Executar OCR',
                          onPressed:
                              ocrProcessing ? null : () => _runOcr(material))))
      ]);

  Future<void> _showMaterialImportMenu() async {
    final choice = await showModalBottomSheet<String>(
        context: context,
        builder: (sheetContext) => SafeArea(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                ListTile(
                    leading: const Icon(Icons.camera_alt),
                    title: const Text('Capturar com câmera'),
                    onTap: () => Navigator.pop(sheetContext, 'camera')),
                ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Escolher imagem da galeria'),
                    onTap: () => Navigator.pop(sheetContext, 'gallery')),
                ListTile(
                    leading: const Icon(Icons.picture_as_pdf),
                    title: const Text('Escolher PDF ou imagem'),
                    onTap: () => Navigator.pop(sheetContext, 'file')),
              ]),
            ));
    if (choice == 'camera') {
      await _importImage(ImageSource.camera);
    } else if (choice == 'gallery') {
      await _importImage(ImageSource.gallery);
    } else if (choice == 'file') {
      await _importMaterial();
    }
  }

  Future<void> _importImage(ImageSource source) async {
    try {
      final image = await imagePicker.pickImage(
          source: source, maxWidth: 2000, maxHeight: 2000, imageQuality: 88);
      if (image == null) return;
      await _saveImageMaterial(image);
      _message('Imagem salva somente neste dispositivo.');
    } catch (_) {
      _message('Não foi possível abrir a câmera ou galeria.');
    }
  }

  Future<void> _recoverLostImage() async {
    try {
      final lost = await imagePicker.retrieveLostData();
      if (lost.isEmpty || lost.files == null || lost.files!.isEmpty) return;
      await _saveImageMaterial(lost.files!.first);
      _message('Imagem recuperada após a retomada do aplicativo.');
    } catch (_) {
      // A recuperação é opcional e não deve impedir a inicialização.
    }
  }

  Future<void> _saveImageMaterial(XFile image) async {
    final source = File(image.path);
    if (!await source.exists() || await source.length() == 0) {
      throw const FormatException('Imagem inexistente ou vazia.');
    }
    data.materials.add({
      'id': DateTime.now().millisecondsSinceEpoch,
      'name': image.name,
      'size': await source.length(),
      'path': await _copyMaterialFile(image.path, image.name),
      'updatedAt': DateTime.now().toIso8601String()
    });
    await _save();
  }

  void _setOcrProgress(int current, int total, String message) {
    if (!mounted) return;
    setState(() {
      ocrCurrent = current;
      ocrTotal = total == 0 ? 1 : total;
      ocrMessage = message;
    });
  }

  Future<OcrPageSelection?> _choosePdfPages(int count) async {
    final controller = TextEditingController(text: '1-$count');
    final selection = await showDialog<OcrPageSelection>(
        context: context,
        builder: (dialogContext) => AlertDialog(
              title: Text('Selecionar páginas ($count)'),
              content: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                      labelText: 'Páginas', hintText: 'Ex.: 1-3, 5'),
                  keyboardType: TextInputType.text),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Cancelar')),
                FilledButton(
                    onPressed: () {
                      final result =
                          OcrPageSelection.parse(controller.text, count);
                      if (result.pages.isNotEmpty) {
                        Navigator.pop(dialogContext, result);
                      }
                    },
                    child: const Text('Continuar'))
              ],
            ));
    controller.dispose();
    return selection;
  }

  Future<void> _runOcr(Map<String, dynamic> material) async {
    if (ocrProcessing) return;
    final path = material['path']?.toString() ?? '';
    final name = material['name']?.toString().toLowerCase() ?? '';
    if (path.isEmpty) return;
    setState(() {
      ocrProcessing = true;
      ocrCurrent = 0;
      ocrTotal = 1;
      ocrMessage = 'Preparando OCR...';
    });
    try {
      final OcrDocumentResult result;
      if (name.endsWith('.pdf')) {
        final pageCount = await ocrService.pdfPageCount(path);
        final selection = await _choosePdfPages(pageCount);
        if (selection == null) return;
        result = await ocrService.recognizePdf(path,
            selection: selection, onProgress: _setOcrProgress);
      } else {
        result =
            await ocrService.recognizeImage(path, onProgress: _setOcrProgress);
      }
      material['ocrText'] = result.text;
      material['ocrPages'] = result.pages.map((page) => page.toJson()).toList();
      material['ocrSource'] = result.source;
      material['ocrUpdatedAt'] = DateTime.now().toIso8601String();
      material['updatedAt'] = DateTime.now().toIso8601String();
      await _save();
      if (mounted) await _showOcrResult(material);
    } on FormatException catch (error) {
      _message(error.message);
    } catch (_) {
      _message(
          'Não foi possível processar este arquivo. Ele pode estar protegido, inválido ou grande demais.');
    } finally {
      if (mounted) setState(() => ocrProcessing = false);
    }
  }

  Future<void> _showOcrResult(Map<String, dynamic> material) async {
    final controller = TextEditingController(
        text: material['ocrText']?.toString() ?? 'Nenhum texto reconhecido.');
    await showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
              title: Text('OCR · ${material['name']}'),
              content: SizedBox(
                  width: 560,
                  child: TextField(
                      controller: controller,
                      minLines: 8,
                      maxLines: 16,
                      decoration: const InputDecoration(
                          labelText: 'Texto extraído',
                          border: OutlineInputBorder()))),
              actions: [
                TextButton.icon(
                    onPressed: () async {
                      await Clipboard.setData(
                          ClipboardData(text: controller.text));
                      if (dialogContext.mounted) {
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                            const SnackBar(content: Text('Texto copiado.')));
                      }
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('Copiar')),
                FilledButton(
                    onPressed: () async {
                      material['ocrText'] = controller.text;
                      material['ocrUpdatedAt'] =
                          DateTime.now().toIso8601String();
                      material['updatedAt'] = DateTime.now().toIso8601String();
                      await _save();
                      if (dialogContext.mounted) Navigator.pop(dialogContext);
                      _message('Resultado do OCR salvo no material.');
                    },
                    child: const Text('Salvar'))
              ],
            ));
    controller.dispose();
  }

  Future<void> _previewMaterial(Map<String, dynamic> material) async {
    final path = material['path']?.toString() ?? '';
    final name = material['name']?.toString().toLowerCase() ?? '';
    if (material['ocrText'] != null) {
      await _showOcrResult(material);
      return;
    }
    if (name.endsWith('.pdf')) {
      _message(
          'PDF selecionado: escolha Executar OCR para selecionar as páginas.');
      return;
    }
    if (!mounted || path.isEmpty) return;
    await showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text(material['name'].toString()),
              content: Image.file(File(path), fit: BoxFit.contain),
              actions: [
                FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Fechar'))
              ],
            ));
  }

  void _toggleFocus() {
    if (focusTimer != null) {
      focusTimer!.cancel();
      focusTimer = null;
    } else {
      if (focusSeconds == 0) focusSeconds = 25 * 60;
      focusTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (focusSeconds <= 1) {
          focusTimer?.cancel();
          focusTimer = null;
          focusSeconds = 0;
          _message('Sessão de foco concluída.');
        } else {
          focusSeconds--;
        }
        setState(() {});
      });
    }
    setState(() {});
  }

  Future<void> _addTask() async {
    final text = TextEditingController();
    final ok = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
                title: const Text('Nova tarefa'),
                content: TextField(
                    controller: text,
                    autofocus: true,
                    decoration: const InputDecoration(labelText: 'Tarefa')),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar')),
                  FilledButton(
                      onPressed: () =>
                          Navigator.pop(context, text.text.trim().isNotEmpty),
                      child: const Text('Adicionar'))
                ]));
    if (ok == true) {
      data.tasks.add({
        'id': DateTime.now().millisecondsSinceEpoch,
        'text': text.text.trim(),
        'done': false,
        'updatedAt': DateTime.now().toIso8601String()
      });
      await _save();
    }
    text.dispose();
  }

  Widget _study() => ListView(padding: const EdgeInsets.all(20), children: [
        Text(
            'Foco: ${focusSeconds ~/ 60}:${(focusSeconds % 60).toString().padLeft(2, '0')}',
            style: Theme.of(context).textTheme.headlineMedium),
        FilledButton.icon(
            onPressed: _toggleFocus,
            icon: Icon(focusTimer == null ? Icons.play_arrow : Icons.pause),
            label: Text(focusTimer == null ? 'Iniciar 25 minutos' : 'Pausar')),
        const SizedBox(height: 20),
        FilledButton.icon(
            onPressed: _addTask,
            icon: const Icon(Icons.add_task),
            label: const Text('Adicionar tarefa')),
        for (var i = 0; i < data.tasks.length; i++)
          CheckboxListTile(
              value: data.tasks[i]['done'] == true,
              onChanged: (value) {
                data.tasks[i]['done'] = value == true;
                _save();
              },
              title: Text(data.tasks[i]['text']?.toString() ?? 'Tarefa'),
              secondary: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    data.tasks.removeAt(i);
                    _save();
                  }))
      ]);

  Future<void> _showSimulator(String type) async {
    final a = TextEditingController(),
        b = TextEditingController(),
        c = TextEditingController();
    String result = 'Informe os valores e calcule.';
    final labels = {
      'axial': ['Força F (N)', 'Área A (m²)'],
      'viga': ['Carga P (N)', 'Vão L (m)'],
      'equilíbrio': ['Fx (N)', 'Fy (N)'],
      'vazão': ['Velocidade v (m/s)', 'Área A (m²)'],
      'pressão': ['Densidade ρ (kg/m³)', 'Altura h (m)']
    };
    final fields = labels[type]!;
    await showDialog(
        context: context,
        builder: (_) => StatefulBuilder(
            builder: (context, setDialog) => AlertDialog(
                    title: Text(type[0].toUpperCase() + type.substring(1)),
                    content: Column(mainAxisSize: MainAxisSize.min, children: [
                      TextField(
                          controller: a,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(labelText: fields[0])),
                      TextField(
                          controller: b,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(labelText: fields[1])),
                      if (type == 'pressão')
                        TextField(
                            controller: c,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                labelText: 'Gravidade g (m/s²)',
                                hintText: '9,81')),
                      const SizedBox(height: 12),
                      Text(result)
                    ]),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Fechar')),
                      FilledButton(
                          onPressed: () {
                            final x =
                                double.tryParse(a.text.replaceAll(',', '.')) ??
                                    0;
                            final y =
                                double.tryParse(b.text.replaceAll(',', '.')) ??
                                    0;
                            final z =
                                double.tryParse(c.text.replaceAll(',', '.')) ??
                                    9.81;
                            final value = switch (type) {
                              'axial' => y == 0 ? double.nan : x / y,
                              'viga' => x * y / 4,
                              'equilíbrio' => sqrtValue(x * x + y * y),
                              'vazão' => x * y,
                              _ => x * z * y
                            };
                            setDialog(() => result =
                                'Resultado: ${value.isNaN ? 'área inválida' : value.toStringAsFixed(4)} ${type == 'axial' ? 'Pa' : type == 'vazão' ? 'm³/s' : type == 'pressão' ? 'Pa' : 'unidade SI'}');
                          },
                          child: const Text('Calcular'))
                    ])));
    a.dispose();
    b.dispose();
    c.dispose();
  }

  Widget _lab() => ListView(padding: const EdgeInsets.all(20), children: [
        Text('Laboratório de Engenharia',
            style: Theme.of(context).textTheme.headlineMedium),
        const Text(
            'Estimativas educativas: confira unidades, hipóteses e normas antes de usar em projeto real.'),
        for (final item in {
          'axial': 'Tensão axial σ = F/A',
          'viga': 'Momento de viga biapoiada M = PL/4',
          'equilíbrio': 'Resultante R = √(Fx² + Fy²)',
          'vazão': 'Vazão Q = vA',
          'pressão': 'Pressão hidrostática p = ρgh'
        }.entries)
          Card(
              child: ListTile(
                  title:
                      Text(item.key[0].toUpperCase() + item.key.substring(1)),
                  subtitle: Text(item.value),
                  trailing: FilledButton(
                      onPressed: () => _showSimulator(item.key),
                      child: const Text('Abrir'))))
      ]);

  List<Map<String, dynamic>> _conversation() {
    final all = data.tutor['conversations'];
    final raw = all is Map ? all['${current['id']}'] : null;
    return raw is List
        ? raw.map((item) => Map<String, dynamic>.from(item as Map)).toList()
        : [];
  }

  Future<void> _askTutor() async {
    final text = question.text.trim();
    if (text.isEmpty) return;
    final history = _conversation();
    history.add({'role': 'user', 'text': text});
    question.clear();
    final endpointUrl = endpoint.text.trim();
    if (endpointUrl.isEmpty) {
      history.add({
        'role': 'assistant',
        'text':
            'Pergunta registrada offline. Configure um endpoint compatível para obter respostas online.'
      });
    } else {
      try {
        final response =
            await http.post(Uri.parse('${server.text.trim()}/api/tutor'),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({
                  'endpoint': endpointUrl,
                  'model': model.text.trim(),
                  'apiKey': apiKey.text,
                  'messages': history
                      .map((m) => {'role': m['role'], 'content': m['text']})
                      .toList()
                }));
        final payload = jsonDecode(response.body);
        final answer = response.statusCode >= 200 && response.statusCode < 300
            ? (payload['choices']?[0]?['message']?['content'] ??
                'Resposta sem texto.')
            : 'Falha no tutor: ${payload['error'] ?? response.statusCode}';
        history.add({'role': 'assistant', 'text': answer});
      } catch (_) {
        history.add({
          'role': 'assistant',
          'text':
              'Não foi possível acessar o tutor. A pergunta foi mantida no histórico local.'
        });
      }
    }
    final conversations =
        Map<String, dynamic>.from((data.tutor['conversations'] as Map?) ?? {});
    conversations['${current['id']}'] = history;
    data.tutor['conversations'] = conversations;
    await _save();
  }

  Widget _tutor() => Padding(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        _coursePicker(),
        Expanded(
            child: ListView(children: [
          const Text('Histórico por disciplina'),
          ..._conversation().map((m) => ListTile(
              title: Text(m['role'] == 'user' ? 'Você' : 'Tutor'),
              subtitle: Text(m['text'].toString())))
        ])),
        TextField(
            controller: question,
            decoration: const InputDecoration(labelText: 'Pergunta')),
        FilledButton(onPressed: _askTutor, child: const Text('Enviar'))
      ]));

  Future<void> _authenticate(bool register) async {
    if (email.text.trim().isEmpty || password.text.isEmpty) {
      _message('Informe e-mail e senha.');
      return;
    }
    try {
      final path = register ? '/api/auth/register' : '/api/auth/login';
      final response = await http.post(Uri.parse('${server.text.trim()}$path'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(
              {'email': email.text.trim(), 'password': password.text}));
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
            jsonDecode(response.body)['error'] ?? response.statusCode);
      }
      syncToken = jsonDecode(response.body)['token'].toString();
      _message(
          register ? 'Conta criada e sessão iniciada.' : 'Sessão iniciada.');
    } catch (error) {
      _message('Falha de autenticação: $error');
    }
  }

  List<Map<String, dynamic>> _mergeItems(
      List<Map<String, dynamic>> local, List<Map<String, dynamic>> remote) {
    final merged = <String, Map<String, dynamic>>{
      for (final item in local) '${item['id']}': item
    };
    for (final item in remote) {
      final key = '${item['id']}';
      final current = merged[key];
      if (current == null ||
          '${item['updatedAt'] ?? ''}'
                  .compareTo('${current['updatedAt'] ?? ''}') >
          0) {
        merged[key] = item;
      }
    }
    return merged.values.toList();
  }

  TraviaState _mergeRemote(TraviaState remote) => TraviaState(
        courses: data.courses.isNotEmpty ? data.courses : remote.courses,
        tasks: _mergeItems(data.tasks, remote.tasks),
        settings: {...remote.settings, ...data.settings},
        notes: {...remote.notes, ...data.notes},
        events: _mergeItems(data.events, remote.events),
        materials: _mergeItems(data.materials, remote.materials),
        scenarios: _mergeItems(data.scenarios, remote.scenarios),
        tutor: {
          ...remote.tutor,
          ...data.tutor,
          'conversations': {
            ...(remote.tutor['conversations'] as Map? ?? {}),
            ...(data.tutor['conversations'] as Map? ?? {})
          }
        },
      );

  Future<void> _sync(bool push, {bool retryAfterConflict = false}) async {
    if (email.text.trim().isEmpty || password.text.isEmpty) {
      _message('Informe e-mail e senha.');
      return;
    }
    setState(() {
      syncing = true;
      syncMessage = 'Sincronizando...';
    });
    try {
      final base = server.text.trim();
      if (syncToken.isEmpty) {
        final response = await http.post(Uri.parse('$base/api/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(
                {'email': email.text.trim(), 'password': password.text}));
        if (response.statusCode != 200) {
          throw Exception('login ${response.statusCode}');
        }
        syncToken = jsonDecode(response.body)['token'].toString();
      }
      if (push) {
        final envelope = SyncEnvelope(
            deviceId: 'android-${Platform.localHostname}',
            updatedAt: DateTime.now().toUtc().toIso8601String(),
            payload: data,
            baseRevision: syncRevision);
        final response = await http.put(Uri.parse('$base/api/sync'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $syncToken'
            },
            body: jsonEncode(
                {'envelope': envelope.toJson(), 'baseRevision': syncRevision}));
        if (response.statusCode == 409) {
          if (retryAfterConflict) throw Exception('conflito_persistente');
          await _sync(false);
          await _sync(true, retryAfterConflict: true);
          return;
        }
        if (response.statusCode != 200) {
          throw Exception('envio ${response.statusCode}');
        }
        syncRevision = jsonDecode(response.body)['revision'] as int;
      } else {
        final response = await http.get(Uri.parse('$base/api/sync'),
            headers: {'Authorization': 'Bearer $syncToken'});
        if (response.statusCode != 200) {
          throw Exception('recebimento ${response.statusCode}');
        }
        final remote = jsonDecode(response.body);
        if (remote['envelope'] != null) {
          final remoteState = TraviaState.fromJson(
              Map<String, dynamic>.from(remote['envelope']['payload'] as Map));
          data = _mergeRemote(remoteState);
          syncRevision = remote['revision'] as int;
          await _save();
        }
      }
      setState(() =>
          syncMessage = 'Sincronização concluída. Revisão $syncRevision.');
    } catch (error) {
      setState(() => syncMessage = 'Sincronização indisponível: $error');
    } finally {
      if (mounted) setState(() => syncing = false);
    }
  }

  Widget _settings() => ListView(padding: const EdgeInsets.all(20), children: [
        FilledButton.icon(
            onPressed: _backup,
            icon: const Icon(Icons.download),
            label: const Text('Backup JSON')),
        OutlinedButton.icon(
            onPressed: _restore,
            icon: const Icon(Icons.restore),
            label: const Text('Restaurar backup')),
        const Divider(height: 32),
        TextField(
            controller: server,
            decoration: const InputDecoration(labelText: 'Servidor Travia')),
        TextField(
            controller: email,
            decoration: const InputDecoration(labelText: 'E-mail')),
        TextField(
            controller: password,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Senha')),
        Row(children: [
          Expanded(
              child: OutlinedButton(
                  onPressed: syncing ? null : () => _authenticate(true),
                  child: const Text('Criar conta'))),
          const SizedBox(width: 8),
          Expanded(
              child: OutlinedButton(
                  onPressed: syncing ? null : () => _authenticate(false),
                  child: const Text('Entrar')))
        ]),
        Row(children: [
          Expanded(
              child: FilledButton(
                  onPressed: syncing ? null : () => _sync(false),
                  child: const Text('Receber dados'))),
          const SizedBox(width: 8),
          Expanded(
              child: OutlinedButton(
                  onPressed: syncing ? null : () => _sync(true),
                  child: const Text('Enviar dados')))
        ]),
        Text(syncMessage),
        const Divider(height: 32),
        TextField(
            controller: endpoint,
            decoration: const InputDecoration(labelText: 'Endpoint do tutor')),
        TextField(
            controller: model,
            decoration: const InputDecoration(labelText: 'Modelo')),
        TextField(
            controller: apiKey,
            obscureText: true,
            decoration: const InputDecoration(
                labelText: 'Chave da API (somente nesta sessão)')),
        FilledButton(
            onPressed: () {
              data.tutor['endpoint'] = endpoint.text.trim();
              data.tutor['model'] = model.text.trim();
              _save();
              _message('Configuração salva; nenhuma chave foi armazenada.');
            },
            child: const Text('Salvar tutor'))
      ]);
}

double sqrtValue(double value) {
  if (value <= 0) return 0;
  var result = value;
  for (var i = 0; i < 12; i++) {
    result = (result + value / result) / 2;
  }
  return result;
}
