// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get back => '◀  ATRÁS';

  @override
  String get cancel => 'Cancelar';

  @override
  String get kmUnit => 'KM';

  @override
  String get kmUnitLower => 'km';

  @override
  String get perKmUnit => '/km';

  @override
  String get zoneChip => 'Zona 1 · Tokio';

  @override
  String get optionsSemantics => 'Opciones';

  @override
  String get loadingMap => 'CARGANDO MAPA';

  @override
  String get loadingMapSemantics => 'Cargando mapa';

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
      other: '$count paseos',
      one: '1 paseo',
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
  String get homeStageLabel => 'FASE: TOKIO · ESTA SEMANA';

  @override
  String get goLabel => 'GO!';

  @override
  String get goCaption => 'Grabar un paseo';

  @override
  String get goSemantics => 'Grabar';

  @override
  String get importLabel => 'Importar';

  @override
  String get importCaption => 'Salud';

  @override
  String get spotsLabel => 'Spots';

  @override
  String get spotsSemantics => 'Lugares';

  @override
  String get stagesLabel => 'Fases';

  @override
  String get stagesCaption => 'Todos los paseos';

  @override
  String get stageSelect => 'SELECCIÓN DE FASE';

  @override
  String stagesTitle(int count) {
    return 'TOKIO · $count FASES';
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
    return 'Fase $date, $distance, rango $rank';
  }

  @override
  String get stageClear => '¡FASE SUPERADA!';

  @override
  String get timeLabel => 'Tiempo';

  @override
  String get paceLabel => 'Ritmo';

  @override
  String paceValue(String pace) {
    return '$pace /KM';
  }

  @override
  String get newGroundLabel => 'Terreno nuevo';

  @override
  String newGroundValue(String km, int percent) {
    return '+$km km · $percent%';
  }

  @override
  String get noSpotsOnStage => 'SIN SPOTS EN ESTA FASE';

  @override
  String get spotsHeader => 'SPOTS';

  @override
  String get holdToMarkOne => 'Mantén pulsado el mapa para marcar uno.';

  @override
  String get backToStageSelect => 'Volver a la selección de fase';

  @override
  String get spotCollection => 'COLECCIÓN DE SPOTS';

  @override
  String spotsTitle(int count) {
    return '$count SPOTS';
  }

  @override
  String get spotsHint =>
      'Mantén pulsado el mapa para marcar un spot. Desliza uno para quitarlo.';

  @override
  String spotSemantics(String name) {
    return 'Spot $name';
  }

  @override
  String spotMeta(String date, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count paseos',
      one: '1 paseo',
    );
    return 'Marcado el $date · visitado por $_temp0';
  }

  @override
  String get markASpot => 'MARCAR UN SPOT';

  @override
  String get markASpotBody =>
      'Ponle nombre a este lugar. Los paseos que pasen cerca lo darán por visitado.';

  @override
  String get spotNameHint => 'Nombre del spot';

  @override
  String get markIt => '¡Marcar!';

  @override
  String get addSemantics => 'Añadir';

  @override
  String get itemBoxHealth => 'ITEM BOX · SALUD';

  @override
  String get importWalks => 'IMPORTAR PASEOS';

  @override
  String get importIntro =>
      'Los paseos grabados por tu reloj se convierten en fases. Solo las rutas de relojes compatibles traen mapa.';

  @override
  String get healthDenied => 'ACCESO A SALUD DENEGADO';

  @override
  String get healthDeniedBody =>
      'Permite a Giro leer entrenamientos en la app Salud y vuelve.';

  @override
  String get itemBoxClosed => 'ITEM BOX CERRADA';

  @override
  String get itemBoxClosedBody =>
      'Carga tus paseos recientes para elegir los que merecen una fase, o importa de golpe todos los paseos grabados.';

  @override
  String get loadWorkouts => 'Cargar entrenamientos';

  @override
  String get loadWorkoutsCaption => 'Los 25 más recientes';

  @override
  String get importEverything => 'Importar todo';

  @override
  String get importEverythingCaption => 'Cada paseo en Salud';

  @override
  String get importing => 'IMPORTANDO';

  @override
  String importingBody(int fetched, int added) {
    return '$fetched paseos leídos de Salud, $added fases nuevas por ahora.';
  }

  @override
  String get nothingHere => 'NADA POR AQUÍ';

  @override
  String get noWalksInHealth => 'No hay paseos en Salud.';

  @override
  String get importedLabel => 'Importado';

  @override
  String newStagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fases nuevas',
      one: '1 fase nueva',
    );
    return '$_temp0';
  }

  @override
  String get pickWalks => 'Elegir paseos';

  @override
  String saveWalksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Guardar $count paseos',
      one: 'Guardar 1 paseo',
    );
    return '$_temp0';
  }

  @override
  String get tapToSelect => 'Toca un entrenamiento para seleccionarlo';

  @override
  String get addAsStages => 'Añadir como fases';

  @override
  String get saveWalksSemantics => 'Guardar paseos';

  @override
  String get stageCleared => 'FASE SUPERADA';

  @override
  String workoutSemantics(String date) {
    return 'Entrenamiento del $date';
  }

  @override
  String workoutImportedSemantics(String date) {
    return '$date, ya es una fase';
  }

  @override
  String get actRecording => 'ACTO 2 · GRABANDO';

  @override
  String get actClear => 'ACTO 2 · SUPERADO';

  @override
  String get actReady => 'ACTO 2 · LISTO';

  @override
  String get liveLabel => 'EN VIVO';

  @override
  String get resultLabel => 'RESULTADO';

  @override
  String get pressGoToStart => 'PULSA GO PARA EMPEZAR';

  @override
  String get metresNewUnit => 'm nuevos';

  @override
  String get startRecording => 'Empezar a grabar';

  @override
  String get stopLabel => 'Parar';

  @override
  String get finishStage => 'Terminar fase';

  @override
  String get stopRecording => 'Parar la grabación';

  @override
  String get stageClearButton => '¡Fase superada!';

  @override
  String get viewResult => 'Ver resultado';

  @override
  String get viewFinishedRecording => 'Ver grabación terminada';

  @override
  String percentNewGround(int percent) {
    return '$percent por ciento de terreno nuevo';
  }

  @override
  String get settingsLabel => 'AJUSTES';

  @override
  String get optionsTitle => 'OPCIONES';

  @override
  String get optionsIntro =>
      'Ajusta cómo se ven tus paseos en el mapa. Los cambios se aplican en todas partes al momento.';

  @override
  String get trailWidth => 'GROSOR DEL TRAZO';

  @override
  String get trailWidthCaption => 'Grosor con el que se dibuja cada paseo.';

  @override
  String get trailWidthSemantics => 'Grosor del trazo';

  @override
  String pxValue(int value) {
    return '$value px';
  }

  @override
  String get revealRadius => 'RADIO DE DESCUBRIMIENTO';

  @override
  String get revealRadiusCaption =>
      'Hasta dónde se levanta la niebla alrededor de un paseo. Cuanto mayor, antes se llena la ciudad.';

  @override
  String get revealRadiusSemantics => 'Radio de descubrimiento';

  @override
  String mValue(int value) {
    return '$value m';
  }

  @override
  String get resetToDefaults => 'Restablecer valores';

  @override
  String get mapDataLabel => 'DATOS DEL MAPA';

  @override
  String get mapDataBody =>
      'Descarga tu ciudad una vez para que el mapa sea instantáneo y funcione sin conexión.';

  @override
  String get downloadMapArea => 'Descargar zona del mapa';

  @override
  String get offlineTiles => 'Teselas sin conexión';

  @override
  String get demoData => 'DATOS DE DEMO';

  @override
  String demoDataBody(int walks, int spots) {
    return 'Vista previa de un Tokio casi totalmente explorado: $walks paseos generados por los 23 distritos y $spots spots famosos. Los paseos reales no se tocan.';
  }

  @override
  String demoDataLoaded(int count) {
    return '$count paseos de demo cargados. Quítalos para volver a tus propias fases.';
  }

  @override
  String get fillTokyo => 'Llenar Tokio';

  @override
  String get fillTokyoCaption => 'Paseos y spots generados';

  @override
  String get removeDemoData => 'Quitar datos de demo';

  @override
  String get removeDemoDataCaption => 'Conserva tus paseos reales';

  @override
  String get skip => 'SALTAR';

  @override
  String get frameYourCity => 'Encuadra tu ciudad';

  @override
  String get mapDataOffline => 'DATOS DEL MAPA · SIN CONEXIÓN';

  @override
  String get downloadArea => 'DESCARGAR ZONA';

  @override
  String get downloadIntroFirstRun =>
      'Guarda la ciudad por la que caminas para que el mapa sea instantáneo y funcione sin cobertura. Puedes hacerlo más tarde en Opciones.';

  @override
  String get downloadIntro =>
      'Las teselas dentro del marco dorado se guardan en este teléfono.';

  @override
  String downloadCancelCaption(int done, int total, String bytes) {
    return '$done / $total teselas · $bytes';
  }

  @override
  String get tilesUnit => 'teselas';

  @override
  String get downloadUnit => 'descarga';

  @override
  String get storedUnit => 'guardado';

  @override
  String get doneLabel => 'Hecho';

  @override
  String get areaStored => 'Zona guardada';

  @override
  String get tooBig => 'Demasiado grande';

  @override
  String get zoomInALittle => 'Acerca un poco';

  @override
  String get downloadAnotherArea => 'Descargar otra zona';

  @override
  String get downloadLabel => 'Descargar';

  @override
  String get frameSmallerArea => 'Encuadra una zona más pequeña';

  @override
  String get zoomRangeCaption => 'Zoom 0 a 14 dentro del marco';

  @override
  String get downloadAreaSemantics => 'Descargar zona';

  @override
  String areasStored(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count zonas guardadas',
      one: '1 zona guardada',
    );
    return '$_temp0';
  }

  @override
  String get clearMapData => 'Borrar datos del mapa';

  @override
  String freesBytes(String bytes) {
    return 'Libera $bytes';
  }

  @override
  String get downloading => 'DESCARGANDO';

  @override
  String get downloadProgressSemantics => 'Progreso de la descarga';

  @override
  String percentValue(int percent) {
    return '$percent por ciento';
  }

  @override
  String areaName(int number) {
    return 'Zona $number';
  }
}
