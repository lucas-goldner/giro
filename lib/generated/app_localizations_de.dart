// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get back => '◀  ZURÜCK';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get kmUnit => 'KM';

  @override
  String get kmUnitLower => 'km';

  @override
  String get perKmUnit => '/km';

  @override
  String get zoneChip => 'Zone 1 · Tokio';

  @override
  String get optionsSemantics => 'Optionen';

  @override
  String get loadingMap => 'KARTE LÄDT';

  @override
  String get loadingMapSemantics => 'Karte lädt';

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
      other: '$count Spaziergänge',
      one: '1 Spaziergang',
    );
    return '$_temp0';
  }

  @override
  String spotsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Spots',
      one: '1 Spot',
    );
    return '$_temp0';
  }

  @override
  String placesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Orte',
      one: '1 Ort',
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
  String get homeStageLabel => 'STAGE: TOKIO · DIESE WOCHE';

  @override
  String get goLabel => 'GO!';

  @override
  String get goCaption => 'Spaziergang aufnehmen';

  @override
  String get goSemantics => 'Aufnehmen';

  @override
  String get importLabel => 'Import';

  @override
  String get importCaption => 'Health';

  @override
  String get spotsLabel => 'Spots';

  @override
  String get spotsSemantics => 'Orte';

  @override
  String get stagesLabel => 'Stages';

  @override
  String get stagesCaption => 'Alle Spaziergänge';

  @override
  String get stageSelect => 'STAGE-AUSWAHL';

  @override
  String stagesTitle(int count) {
    return 'TOKIO · $count STAGES';
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
    return 'Stage $date, $distance, Rang $rank';
  }

  @override
  String get stageClear => 'STAGE CLEAR!';

  @override
  String get timeLabel => 'Zeit';

  @override
  String get paceLabel => 'Tempo';

  @override
  String paceValue(String pace) {
    return '$pace /KM';
  }

  @override
  String get newGroundLabel => 'Neues Terrain';

  @override
  String newGroundValue(String km, int percent) {
    return '+$km km · $percent%';
  }

  @override
  String get noSpotsOnStage => 'KEINE SPOTS AUF DIESER STAGE';

  @override
  String get spotsHeader => 'SPOTS';

  @override
  String get holdToMarkOne => 'Karte gedrückt halten, um einen zu markieren.';

  @override
  String get backToStageSelect => 'Zurück zur Stage-Auswahl';

  @override
  String get spotCollection => 'SPOT-SAMMLUNG';

  @override
  String spotsTitle(int count) {
    return '$count SPOTS';
  }

  @override
  String get spotsHint =>
      'Karte gedrückt halten, um einen Spot zu markieren. Zum Entfernen wegwischen.';

  @override
  String spotSemantics(String name) {
    return 'Spot $name';
  }

  @override
  String spotMeta(String date, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Spaziergängen',
      one: '1 Spaziergang',
    );
    return 'Markiert am $date · besucht von $_temp0';
  }

  @override
  String get markASpot => 'SPOT MARKIEREN';

  @override
  String get markASpotBody =>
      'Gib diesem Ort einen Namen. Spots gelten als besucht, wenn ein Spaziergang daran vorbeiführt.';

  @override
  String get spotNameHint => 'Name des Spots';

  @override
  String get markIt => 'Markieren!';

  @override
  String get addSemantics => 'Hinzufügen';

  @override
  String get itemBoxHealth => 'ITEM BOX · HEALTH';

  @override
  String get importWalks => 'SPAZIERGÄNGE IMPORTIEREN';

  @override
  String get importIntro =>
      'Spaziergänge von deiner Uhr werden zu Stages. Nur Routen unterstützter Uhren haben eine Karte.';

  @override
  String get healthDenied => 'HEALTH-ZUGRIFF VERWEIGERT';

  @override
  String get healthDeniedBody =>
      'Erlaube Giro in der Health-App, Trainings zu lesen, und komm dann zurück.';

  @override
  String get itemBoxClosed => 'ITEM BOX GESCHLOSSEN';

  @override
  String get itemBoxClosedBody =>
      'Lade deine letzten Spaziergänge und wähle die aus, die eine Stage wert sind, oder importiere alle je aufgezeichneten auf einmal.';

  @override
  String get loadWorkouts => 'Trainings laden';

  @override
  String get loadWorkoutsCaption => 'Die 25 neuesten';

  @override
  String get importEverything => 'Alles importieren';

  @override
  String get importEverythingCaption => 'Jeder Spaziergang in Health';

  @override
  String get importing => 'IMPORT LÄUFT';

  @override
  String importingBody(int fetched, int added) {
    return '$fetched Spaziergänge aus Health gelesen, bisher $added neue Stages.';
  }

  @override
  String get nothingHere => 'NICHTS HIER';

  @override
  String get noWalksInHealth => 'Keine Spaziergänge in Health gefunden.';

  @override
  String get importedLabel => 'Importiert';

  @override
  String newStagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count neue Stages',
      one: '1 neue Stage',
    );
    return '$_temp0';
  }

  @override
  String get pickWalks => 'Spaziergänge wählen';

  @override
  String saveWalksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Spaziergänge speichern',
      one: '1 Spaziergang speichern',
    );
    return '$_temp0';
  }

  @override
  String get tapToSelect => 'Tippe auf ein Training, um es auszuwählen';

  @override
  String get addAsStages => 'Als Stages hinzufügen';

  @override
  String get saveWalksSemantics => 'Spaziergänge speichern';

  @override
  String get stageCleared => 'STAGE GESCHAFFT';

  @override
  String workoutSemantics(String date) {
    return 'Training vom $date';
  }

  @override
  String workoutImportedSemantics(String date) {
    return '$date, bereits eine Stage';
  }

  @override
  String get actRecording => 'AKT 2 · AUFNAHME';

  @override
  String get actClear => 'AKT 2 · CLEAR';

  @override
  String get actReady => 'AKT 2 · BEREIT';

  @override
  String get liveLabel => 'LIVE';

  @override
  String get resultLabel => 'ERGEBNIS';

  @override
  String get pressGoToStart => 'GO DRÜCKEN ZUM START';

  @override
  String get metresNewUnit => 'm neu';

  @override
  String get startRecording => 'Aufnahme starten';

  @override
  String get stopLabel => 'Stopp';

  @override
  String get finishStage => 'Stage beenden';

  @override
  String get stopRecording => 'Aufnahme stoppen';

  @override
  String get stageClearButton => 'Stage clear!';

  @override
  String get viewResult => 'Ergebnis ansehen';

  @override
  String get viewFinishedRecording => 'Fertige Aufnahme ansehen';

  @override
  String percentNewGround(int percent) {
    return '$percent Prozent neues Terrain';
  }

  @override
  String get settingsLabel => 'EINSTELLUNGEN';

  @override
  String get optionsTitle => 'OPTIONEN';

  @override
  String get optionsIntro =>
      'Stelle ein, wie deine Spaziergänge auf der Karte erscheinen. Änderungen gelten sofort überall.';

  @override
  String get trailWidth => 'SPURBREITE';

  @override
  String get trailWidthCaption => 'Wie dick jeder Spaziergang gezeichnet wird.';

  @override
  String get trailWidthSemantics => 'Spurbreite';

  @override
  String pxValue(int value) {
    return '$value px';
  }

  @override
  String get revealRadius => 'AUFDECK-RADIUS';

  @override
  String get revealRadiusCaption =>
      'Wie weit um einen Spaziergang der Nebel verschwindet. Größer heißt, die Stadt füllt sich schneller.';

  @override
  String get revealRadiusSemantics => 'Aufdeck-Radius';

  @override
  String mValue(int value) {
    return '$value m';
  }

  @override
  String get resetToDefaults => 'Auf Standard zurücksetzen';

  @override
  String get mapDataLabel => 'KARTENDATEN';

  @override
  String get mapDataBody =>
      'Lade deine Stadt einmal herunter, damit die Karte sofort da ist und ohne Verbindung funktioniert.';

  @override
  String get downloadMapArea => 'Kartenbereich laden';

  @override
  String get offlineTiles => 'Offline-Kacheln';

  @override
  String get demoData => 'DEMO-DATEN';

  @override
  String demoDataBody(int walks, int spots) {
    return 'Vorschau auf ein fast vollständig erkundetes Tokio: $walks generierte Spaziergänge in allen 23 Bezirken und $spots berühmte Spots. Echte Spaziergänge bleiben unberührt.';
  }

  @override
  String demoDataLoaded(int count) {
    return '$count Demo-Spaziergänge geladen. Entferne sie, um zu deinen eigenen Stages zurückzukehren.';
  }

  @override
  String get fillTokyo => 'Tokio füllen';

  @override
  String get fillTokyoCaption => 'Generierte Spaziergänge und Spots';

  @override
  String get removeDemoData => 'Demo-Daten entfernen';

  @override
  String get removeDemoDataCaption => 'Echte Spaziergänge bleiben';

  @override
  String get skip => 'ÜBERSPRINGEN';

  @override
  String get frameYourCity => 'Deine Stadt einrahmen';

  @override
  String get mapDataOffline => 'KARTENDATEN · OFFLINE';

  @override
  String get downloadArea => 'BEREICH LADEN';

  @override
  String get downloadIntroFirstRun =>
      'Speichere die Stadt, in der du gehst, damit die Karte sofort da ist und ohne Empfang funktioniert. Das geht später auch in den Optionen.';

  @override
  String get downloadIntro =>
      'Kacheln im goldenen Rahmen werden auf diesem Telefon gespeichert.';

  @override
  String downloadCancelCaption(int done, int total, String bytes) {
    return '$done / $total Kacheln · $bytes';
  }

  @override
  String get tilesUnit => 'Kacheln';

  @override
  String get downloadUnit => 'Download';

  @override
  String get storedUnit => 'gespeichert';

  @override
  String get doneLabel => 'Fertig';

  @override
  String get areaStored => 'Bereich gespeichert';

  @override
  String get tooBig => 'Zu groß';

  @override
  String get zoomInALittle => 'Etwas hineinzoomen';

  @override
  String get downloadAnotherArea => 'Weiteren Bereich laden';

  @override
  String get downloadLabel => 'Herunterladen';

  @override
  String get frameSmallerArea => 'Kleineren Bereich einrahmen';

  @override
  String get zoomRangeCaption => 'Zoom 0 bis 14 im Rahmen';

  @override
  String get downloadAreaSemantics => 'Bereich laden';

  @override
  String areasStored(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Bereiche gespeichert',
      one: '1 Bereich gespeichert',
    );
    return '$_temp0';
  }

  @override
  String get clearMapData => 'Kartendaten löschen';

  @override
  String freesBytes(String bytes) {
    return 'Gibt $bytes frei';
  }

  @override
  String get downloading => 'LÄDT HERUNTER';

  @override
  String get downloadProgressSemantics => 'Download-Fortschritt';

  @override
  String percentValue(int percent) {
    return '$percent Prozent';
  }

  @override
  String areaName(int number) {
    return 'Bereich $number';
  }
}
