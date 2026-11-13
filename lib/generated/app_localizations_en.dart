// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get back => '◀  BACK';

  @override
  String get cancel => 'Cancel';

  @override
  String get kmUnit => 'KM';

  @override
  String get kmUnitLower => 'km';

  @override
  String get perKmUnit => '/km';

  @override
  String get zoneChip => 'Zone 1 · Tokyo';

  @override
  String get optionsSemantics => 'Options';

  @override
  String get loadingMap => 'LOADING MAP';

  @override
  String get loadingMapSemantics => 'Loading map';

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
    return '${hours}h ${minutes}m';
  }

  @override
  String durationMinutes(int minutes) {
    return '${minutes}m';
  }

  @override
  String walksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count walks',
      one: '1 walk',
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
      other: '$count places',
      one: '1 place',
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
  String get homeStageLabel => 'STAGE: TOKYO · THIS WEEK';

  @override
  String get goLabel => 'GO!';

  @override
  String get goCaption => 'Record a walk';

  @override
  String get goSemantics => 'Record';

  @override
  String get importLabel => 'Import';

  @override
  String get importCaption => 'Health';

  @override
  String get spotsLabel => 'Spots';

  @override
  String get spotsSemantics => 'Places';

  @override
  String get stagesLabel => 'Stages';

  @override
  String get stagesCaption => 'All walks';

  @override
  String get stageSelect => 'STAGE SELECT';

  @override
  String stagesTitle(int count) {
    return 'TOKYO · $count STAGES';
  }

  @override
  String stageCardTitle(int day) {
    return 'STAGE $day';
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
    return 'Stage $date, $distance, rank $rank';
  }

  @override
  String get stageClear => 'STAGE CLEAR!';

  @override
  String get timeLabel => 'Time';

  @override
  String get paceLabel => 'Pace';

  @override
  String paceValue(String pace) {
    return '$pace /KM';
  }

  @override
  String get newGroundLabel => 'New ground';

  @override
  String newGroundValue(String km, int percent) {
    return '+$km km · $percent%';
  }

  @override
  String get noSpotsOnStage => 'NO SPOTS ON THIS STAGE';

  @override
  String get spotsHeader => 'SPOTS';

  @override
  String get holdToMarkOne => 'Press and hold the map to mark one.';

  @override
  String get backToStageSelect => 'Back to stage select';

  @override
  String get spotCollection => 'SPOT COLLECTION';

  @override
  String spotsTitle(int count) {
    return '$count SPOTS';
  }

  @override
  String get spotsHint =>
      'Press and hold the map to mark a spot. Swipe one away to remove it.';

  @override
  String spotSemantics(String name) {
    return 'Spot $name';
  }

  @override
  String spotMeta(String date, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count walks',
      one: '1 walk',
    );
    return 'Marked $date · visited by $_temp0';
  }

  @override
  String get markASpot => 'MARK A SPOT';

  @override
  String get markASpotBody =>
      'Name this place. Spots are visited by the walks that pass them.';

  @override
  String get spotNameHint => 'Spot name';

  @override
  String get markIt => 'Mark it!';

  @override
  String get addSemantics => 'Add';

  @override
  String get itemBoxHealth => 'ITEM BOX · HEALTH';

  @override
  String get importWalks => 'IMPORT WALKS';

  @override
  String get importIntro =>
      'Walks recorded by your watch become stages. Only routes from supported watches carry a map.';

  @override
  String get healthDenied => 'HEALTH ACCESS DENIED';

  @override
  String get healthDeniedBody =>
      'Allow Giro to read workouts in the Health app, then come back.';

  @override
  String get itemBoxClosed => 'ITEM BOX CLOSED';

  @override
  String get itemBoxClosedBody =>
      'Load your recent walks to pick the ones worth a stage, or import every walk ever recorded in one go.';

  @override
  String get loadWorkouts => 'Load workouts';

  @override
  String get loadWorkoutsCaption => 'The 25 most recent';

  @override
  String get importEverything => 'Import everything';

  @override
  String get importEverythingCaption => 'Every walk in Health';

  @override
  String get importing => 'IMPORTING';

  @override
  String importingBody(int fetched, int added) {
    return '$fetched walks read from Health, $added new stages so far.';
  }

  @override
  String get nothingHere => 'NOTHING HERE';

  @override
  String get noWalksInHealth => 'No walks found in Health.';

  @override
  String get importedLabel => 'Imported';

  @override
  String newStagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count new stages',
      one: '1 new stage',
    );
    return '$_temp0';
  }

  @override
  String get pickWalks => 'Pick walks';

  @override
  String saveWalksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count walks',
      one: '1 walk',
    );
    return 'Save $_temp0';
  }

  @override
  String get tapToSelect => 'Tap a workout to select it';

  @override
  String get addAsStages => 'Add as stages';

  @override
  String get saveWalksSemantics => 'Save walks';

  @override
  String get stageCleared => 'STAGE CLEARED';

  @override
  String workoutSemantics(String date) {
    return '$date workout';
  }

  @override
  String workoutImportedSemantics(String date) {
    return '$date, already a stage';
  }

  @override
  String get actRecording => 'ACT 2 · RECORDING';

  @override
  String get actClear => 'ACT 2 · CLEAR';

  @override
  String get actReady => 'ACT 2 · READY';

  @override
  String get liveLabel => 'LIVE';

  @override
  String get resultLabel => 'RESULT';

  @override
  String get pressGoToStart => 'PRESS GO TO START';

  @override
  String get metresNewUnit => 'm new';

  @override
  String get startRecording => 'Start recording';

  @override
  String get stopLabel => 'Stop';

  @override
  String get finishStage => 'Finish stage';

  @override
  String get stopRecording => 'Stop recording';

  @override
  String get stageClearButton => 'Stage clear!';

  @override
  String get viewResult => 'View result';

  @override
  String get viewFinishedRecording => 'View finished recording';

  @override
  String percentNewGround(int percent) {
    return '$percent percent new ground';
  }

  @override
  String get settingsLabel => 'SETTINGS';

  @override
  String get optionsTitle => 'OPTIONS';

  @override
  String get optionsIntro =>
      'Tune how your walks show on the map. Changes apply everywhere right away.';

  @override
  String get trailWidth => 'TRAIL WIDTH';

  @override
  String get trailWidthCaption => 'How thick each walk is drawn.';

  @override
  String get trailWidthSemantics => 'Trail width';

  @override
  String pxValue(int value) {
    return '$value px';
  }

  @override
  String get revealRadius => 'REVEAL RADIUS';

  @override
  String get revealRadiusCaption =>
      'How far around a walk the fog of war is lifted. Bigger means the city fills in faster.';

  @override
  String get revealRadiusSemantics => 'Reveal radius';

  @override
  String mValue(int value) {
    return '$value m';
  }

  @override
  String get resetToDefaults => 'Reset to defaults';

  @override
  String get mapDataLabel => 'MAP DATA';

  @override
  String get mapDataBody =>
      'Download your city once so the map is instant and works without a connection.';

  @override
  String get downloadMapArea => 'Download map area';

  @override
  String get offlineTiles => 'Offline tiles';

  @override
  String get demoData => 'DEMO DATA';

  @override
  String demoDataBody(int walks, int spots) {
    return 'Preview a Tokyo that is almost fully explored: $walks generated walks across all 23 wards and $spots famous spots. Real walks stay untouched.';
  }

  @override
  String demoDataLoaded(int count) {
    return '$count demo walks loaded. Remove them to get back to your own stages.';
  }

  @override
  String get fillTokyo => 'Fill Tokyo';

  @override
  String get fillTokyoCaption => 'Generated walks and spots';

  @override
  String get removeDemoData => 'Remove demo data';

  @override
  String get removeDemoDataCaption => 'Keeps your real walks';

  @override
  String get skip => 'SKIP';

  @override
  String get frameYourCity => 'Frame your city';

  @override
  String get mapDataOffline => 'MAP DATA · OFFLINE';

  @override
  String get downloadArea => 'DOWNLOAD AREA';

  @override
  String get downloadIntroFirstRun =>
      'Store the city you walk in so the map is instant and works without a signal. You can do this later in Options.';

  @override
  String get downloadIntro =>
      'Tiles inside the gold frame are stored on this phone.';

  @override
  String downloadCancelCaption(int done, int total, String bytes) {
    return '$done / $total tiles · $bytes';
  }

  @override
  String get tilesUnit => 'tiles';

  @override
  String get downloadUnit => 'download';

  @override
  String get storedUnit => 'stored';

  @override
  String get doneLabel => 'Done';

  @override
  String get areaStored => 'Area stored';

  @override
  String get tooBig => 'Too big';

  @override
  String get zoomInALittle => 'Zoom in a little';

  @override
  String get downloadAnotherArea => 'Download another area';

  @override
  String get downloadLabel => 'Download';

  @override
  String get frameSmallerArea => 'Frame a smaller area';

  @override
  String get zoomRangeCaption => 'Zoom 0 to 14 inside the frame';

  @override
  String get downloadAreaSemantics => 'Download area';

  @override
  String areasStored(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count areas stored',
      one: '1 area stored',
    );
    return '$_temp0';
  }

  @override
  String get clearMapData => 'Clear map data';

  @override
  String freesBytes(String bytes) {
    return 'Frees $bytes';
  }

  @override
  String get downloading => 'DOWNLOADING';

  @override
  String get downloadProgressSemantics => 'Download progress';

  @override
  String percentValue(int percent) {
    return '$percent percent';
  }

  @override
  String areaName(int number) {
    return 'Area $number';
  }

  @override
  String get graphicsLabel => 'GRAPHICS';

  @override
  String get graphicsBody =>
      'How the 3D city is drawn. Advanced draws the buildings itself with sun shadows, materials by building type and shadows on the streets. Experimental and heavier on the battery.';

  @override
  String get graphicsClassic => 'Classic';

  @override
  String get graphicsClassicCaption => 'Toy city, light on the GPU';

  @override
  String get graphicsAdvanced => 'Advanced';

  @override
  String get graphicsAdvancedCaption => 'Sun shadows and materials (beta)';

  @override
  String get graphicsSemantics => 'Graphics mode';
}
