// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get back => '◀  VOLTAR';

  @override
  String get cancel => 'Cancelar';

  @override
  String get kmUnit => 'KM';

  @override
  String get kmUnitLower => 'km';

  @override
  String get perKmUnit => '/km';

  @override
  String get zoneChip => 'Zona 1 · Tóquio';

  @override
  String get optionsSemantics => 'Opções';

  @override
  String get loadingMap => 'CARREGANDO MAPA';

  @override
  String get loadingMapSemantics => 'Carregando mapa';

  @override
  String get spotMarkerSemantics => 'Spot';

  @override
  String distanceKm(String km) {
    return '$km km';
  }

  @override
  String distanceM(int m) {
    return '$m m';
  }

  @override
  String durationHoursMinutes(int hours, String minutes) {
    return '${hours}h ${minutes}min';
  }

  @override
  String durationMinutes(int minutes) {
    return '${minutes}min';
  }

  @override
  String walksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count caminhadas',
      one: '1 caminhada',
    );
    return '$_temp0';
  }

  @override
  String spotsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count spots',
      one: '1 spot',
    );
    return '$_temp0';
  }

  @override
  String placesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lugares',
      one: '1 lugar',
    );
    return '$_temp0';
  }

  @override
  String dotSeparated(String a, String b, String c) {
    return '$a · $b · $c';
  }

  @override
  String dotSeparatedTwo(String a, String b) {
    return '$a · $b';
  }

  @override
  String get homeStageLabel => 'FASE: TÓQUIO · ESTA SEMANA';

  @override
  String get goLabel => 'GO!';

  @override
  String get goCaption => 'Gravar uma caminhada';

  @override
  String get goSemantics => 'Gravar';

  @override
  String get importLabel => 'Importar';

  @override
  String get importCaption => 'Saúde';

  @override
  String get spotsLabel => 'Spots';

  @override
  String get spotsSemantics => 'Lugares';

  @override
  String get stagesLabel => 'Fases';

  @override
  String get stagesCaption => 'Todas as caminhadas';

  @override
  String get stageSelect => 'SELEÇÃO DE FASE';

  @override
  String stagesTitle(int count) {
    return 'TÓQUIO · $count FASES';
  }

  @override
  String stageCardTitle(int day) {
    return 'FASE $day';
  }

  @override
  String stageCardMeta(
    String date,
    String distance,
    String duration,
    String spots,
  ) {
    return '$date · $distance · $duration · $spots';
  }

  @override
  String stageSemantics(String date, String distance, String rank) {
    return 'Fase $date, $distance, rank $rank';
  }

  @override
  String get stageClear => 'FASE CONCLUÍDA!';

  @override
  String get timeLabel => 'Tempo';

  @override
  String get paceLabel => 'Ritmo';

  @override
  String paceValue(String pace) {
    return '$pace /KM';
  }

  @override
  String get newGroundLabel => 'Terreno novo';

  @override
  String newGroundValue(String km, int percent) {
    return '+$km km · $percent%';
  }

  @override
  String get noSpotsOnStage => 'NENHUM SPOT NESTA FASE';

  @override
  String get spotsHeader => 'SPOTS';

  @override
  String get holdToMarkOne => 'Toque e segure no mapa para marcar um.';

  @override
  String get backToStageSelect => 'Voltar à seleção de fase';

  @override
  String get spotCollection => 'COLEÇÃO DE SPOTS';

  @override
  String spotsTitle(int count) {
    return '$count SPOTS';
  }

  @override
  String get spotsHint =>
      'Toque e segure no mapa para marcar um spot. Deslize um para removê-lo.';

  @override
  String spotSemantics(String name) {
    return 'Spot $name';
  }

  @override
  String spotMeta(String date, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count caminhadas',
      one: '1 caminhada',
    );
    return 'Marcado em $date · visitado por $_temp0';
  }

  @override
  String get markASpot => 'MARCAR UM SPOT';

  @override
  String get markASpotBody =>
      'Dê um nome a este lugar. As caminhadas que passarem perto contam como visita.';

  @override
  String get spotNameHint => 'Nome do spot';

  @override
  String get markIt => 'Marcar!';

  @override
  String get addSemantics => 'Adicionar';

  @override
  String get itemBoxHealth => 'ITEM BOX · SAÚDE';

  @override
  String get importWalks => 'IMPORTAR CAMINHADAS';

  @override
  String get importIntro =>
      'Caminhadas gravadas pelo seu relógio viram fases. Só rotas de relógios compatíveis trazem mapa.';

  @override
  String get healthDenied => 'ACESSO AO SAÚDE NEGADO';

  @override
  String get healthDeniedBody =>
      'Permita que o Giro leia treinos no app Saúde e volte aqui.';

  @override
  String get itemBoxClosed => 'ITEM BOX FECHADA';

  @override
  String get itemBoxClosedBody =>
      'Carregue suas caminhadas recentes para escolher as que merecem uma fase, ou importe de uma vez todas as caminhadas já gravadas.';

  @override
  String get loadWorkouts => 'Carregar treinos';

  @override
  String get loadWorkoutsCaption => 'Os 25 mais recentes';

  @override
  String get importEverything => 'Importar tudo';

  @override
  String get importEverythingCaption => 'Cada caminhada no Saúde';

  @override
  String get importing => 'IMPORTANDO';

  @override
  String importingBody(int fetched, int added) {
    return '$fetched caminhadas lidas do Saúde, $added fases novas até agora.';
  }

  @override
  String get nothingHere => 'NADA AQUI';

  @override
  String get noWalksInHealth => 'Nenhuma caminhada encontrada no Saúde.';

  @override
  String get importedLabel => 'Importado';

  @override
  String newStagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fases novas',
      one: '1 fase nova',
    );
    return '$_temp0';
  }

  @override
  String get pickWalks => 'Escolher caminhadas';

  @override
  String saveWalksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Salvar $count caminhadas',
      one: 'Salvar 1 caminhada',
    );
    return '$_temp0';
  }

  @override
  String get tapToSelect => 'Toque em um treino para selecioná-lo';

  @override
  String get addAsStages => 'Adicionar como fases';

  @override
  String get saveWalksSemantics => 'Salvar caminhadas';

  @override
  String get stageCleared => 'FASE CONCLUÍDA';

  @override
  String workoutSemantics(String date) {
    return 'Treino de $date';
  }

  @override
  String workoutImportedSemantics(String date) {
    return '$date, já é uma fase';
  }

  @override
  String get actRecording => 'ATO 2 · GRAVANDO';

  @override
  String get actClear => 'ATO 2 · CONCLUÍDO';

  @override
  String get actReady => 'ATO 2 · PRONTO';

  @override
  String get liveLabel => 'AO VIVO';

  @override
  String get resultLabel => 'RESULTADO';

  @override
  String get pressGoToStart => 'APERTE GO PARA COMEÇAR';

  @override
  String get metresNewUnit => 'm novos';

  @override
  String get startRecording => 'Começar a gravar';

  @override
  String get stopLabel => 'Parar';

  @override
  String get finishStage => 'Terminar fase';

  @override
  String get stopRecording => 'Parar gravação';

  @override
  String get stageClearButton => 'Fase concluída!';

  @override
  String get viewResult => 'Ver resultado';

  @override
  String get viewFinishedRecording => 'Ver gravação concluída';

  @override
  String percentNewGround(int percent) {
    return '$percent por cento de terreno novo';
  }

  @override
  String get settingsLabel => 'CONFIGURAÇÕES';

  @override
  String get optionsTitle => 'OPÇÕES';

  @override
  String get optionsIntro =>
      'Ajuste como suas caminhadas aparecem no mapa. As mudanças valem em todo lugar na hora.';

  @override
  String get trailWidth => 'ESPESSURA DA TRILHA';

  @override
  String get trailWidthCaption =>
      'Espessura com que cada caminhada é desenhada.';

  @override
  String get trailWidthSemantics => 'Espessura da trilha';

  @override
  String pxValue(int value) {
    return '$value px';
  }

  @override
  String get revealRadius => 'RAIO DE DESCOBERTA';

  @override
  String get revealRadiusCaption =>
      'Até onde a névoa se dissipa ao redor de uma caminhada. Quanto maior, mais rápido a cidade se preenche.';

  @override
  String get revealRadiusSemantics => 'Raio de descoberta';

  @override
  String mValue(int value) {
    return '$value m';
  }

  @override
  String get resetToDefaults => 'Restaurar padrões';

  @override
  String get mapDataLabel => 'DADOS DO MAPA';

  @override
  String get mapDataBody =>
      'Baixe sua cidade uma vez para o mapa ser instantâneo e funcionar sem conexão.';

  @override
  String get downloadMapArea => 'Baixar área do mapa';

  @override
  String get offlineTiles => 'Tiles offline';

  @override
  String get demoData => 'DADOS DE DEMO';

  @override
  String demoDataBody(int walks, int spots) {
    return 'Prévia de uma Tóquio quase toda explorada: $walks caminhadas geradas pelos 23 distritos e $spots spots famosos. As caminhadas reais ficam intactas.';
  }

  @override
  String demoDataLoaded(int count) {
    return '$count caminhadas de demo carregadas. Remova-as para voltar às suas próprias fases.';
  }

  @override
  String get fillTokyo => 'Preencher Tóquio';

  @override
  String get fillTokyoCaption => 'Caminhadas e spots gerados';

  @override
  String get removeDemoData => 'Remover dados de demo';

  @override
  String get removeDemoDataCaption => 'Mantém suas caminhadas reais';

  @override
  String get skip => 'PULAR';

  @override
  String get frameYourCity => 'Enquadre sua cidade';

  @override
  String get mapDataOffline => 'DADOS DO MAPA · OFFLINE';

  @override
  String get downloadArea => 'BAIXAR ÁREA';

  @override
  String get downloadIntroFirstRun =>
      'Guarde a cidade onde você caminha para o mapa ser instantâneo e funcionar sem sinal. Dá para fazer isso depois em Opções.';

  @override
  String get downloadIntro =>
      'Os tiles dentro da moldura dourada ficam guardados neste telefone.';

  @override
  String downloadCancelCaption(int done, int total, String bytes) {
    return '$done / $total tiles · $bytes';
  }

  @override
  String get tilesUnit => 'tiles';

  @override
  String get downloadUnit => 'download';

  @override
  String get storedUnit => 'guardado';

  @override
  String get doneLabel => 'Pronto';

  @override
  String get areaStored => 'Área guardada';

  @override
  String get tooBig => 'Grande demais';

  @override
  String get zoomInALittle => 'Aproxime um pouco';

  @override
  String get downloadAnotherArea => 'Baixar outra área';

  @override
  String get downloadLabel => 'Baixar';

  @override
  String get frameSmallerArea => 'Enquadre uma área menor';

  @override
  String get zoomRangeCaption => 'Zoom 0 a 14 dentro da moldura';

  @override
  String get downloadAreaSemantics => 'Baixar área';

  @override
  String areasStored(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count áreas guardadas',
      one: '1 área guardada',
    );
    return '$_temp0';
  }

  @override
  String get clearMapData => 'Apagar dados do mapa';

  @override
  String freesBytes(String bytes) {
    return 'Libera $bytes';
  }

  @override
  String get downloading => 'BAIXANDO';

  @override
  String get downloadProgressSemantics => 'Progresso do download';

  @override
  String percentValue(int percent) {
    return '$percent por cento';
  }

  @override
  String areaName(int number) {
    return 'Área $number';
  }
}
