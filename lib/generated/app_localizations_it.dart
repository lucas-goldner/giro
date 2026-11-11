// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get back => '◀  INDIETRO';

  @override
  String get cancel => 'Annulla';

  @override
  String get kmUnit => 'KM';

  @override
  String get kmUnitLower => 'km';

  @override
  String get perKmUnit => '/km';

  @override
  String get zoneChip => 'Zona 1 · Tokyo';

  @override
  String get optionsSemantics => 'Opzioni';

  @override
  String get loadingMap => 'CARICAMENTO MAPPA';

  @override
  String get loadingMapSemantics => 'Caricamento mappa';

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
      other: '$count passeggiate',
      one: '1 passeggiata',
    );
    return '$_temp0';
  }

  @override
  String spotsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count spot',
      one: '1 spot',
    );
    return '$_temp0';
  }

  @override
  String placesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count luoghi',
      one: '1 luogo',
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
  String get homeStageLabel => 'STAGE: TOKYO · QUESTA SETTIMANA';

  @override
  String get goLabel => 'GO!';

  @override
  String get goCaption => 'Registra una passeggiata';

  @override
  String get goSemantics => 'Registra';

  @override
  String get importLabel => 'Importa';

  @override
  String get importCaption => 'Salute';

  @override
  String get spotsLabel => 'Spot';

  @override
  String get spotsSemantics => 'Luoghi';

  @override
  String get stagesLabel => 'Stage';

  @override
  String get stagesCaption => 'Tutte le passeggiate';

  @override
  String get stageSelect => 'SCELTA STAGE';

  @override
  String stagesTitle(int count) {
    return 'TOKYO · $count STAGE';
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
    return 'Stage $date, $distance, rango $rank';
  }

  @override
  String get stageClear => 'STAGE COMPLETATO!';

  @override
  String get timeLabel => 'Tempo';

  @override
  String get paceLabel => 'Passo';

  @override
  String paceValue(String pace) {
    return '$pace /KM';
  }

  @override
  String get newGroundLabel => 'Terreno nuovo';

  @override
  String newGroundValue(String km, int percent) {
    return '+$km km · $percent%';
  }

  @override
  String get noSpotsOnStage => 'NESSUNO SPOT IN QUESTO STAGE';

  @override
  String get spotsHeader => 'SPOT';

  @override
  String get holdToMarkOne => 'Tieni premuta la mappa per segnarne uno.';

  @override
  String get backToStageSelect => 'Torna alla scelta stage';

  @override
  String get spotCollection => 'COLLEZIONE SPOT';

  @override
  String spotsTitle(int count) {
    return '$count SPOT';
  }

  @override
  String get spotsHint =>
      'Tieni premuta la mappa per segnare uno spot. Scorri per rimuoverlo.';

  @override
  String spotSemantics(String name) {
    return 'Spot $name';
  }

  @override
  String spotMeta(String date, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count passeggiate',
      one: '1 passeggiata',
    );
    return 'Segnato il $date · visitato da $_temp0';
  }

  @override
  String get markASpot => 'SEGNA UNO SPOT';

  @override
  String get markASpotBody =>
      'Dai un nome a questo luogo. Le passeggiate che ci passano accanto lo contano come visitato.';

  @override
  String get spotNameHint => 'Nome dello spot';

  @override
  String get markIt => 'Segna!';

  @override
  String get addSemantics => 'Aggiungi';

  @override
  String get itemBoxHealth => 'ITEM BOX · SALUTE';

  @override
  String get importWalks => 'IMPORTA PASSEGGIATE';

  @override
  String get importIntro =>
      'Le passeggiate registrate dal tuo orologio diventano stage. Solo i percorsi degli orologi supportati hanno una mappa.';

  @override
  String get healthDenied => 'ACCESSO A SALUTE NEGATO';

  @override
  String get healthDeniedBody =>
      'Consenti a Giro di leggere gli allenamenti nell’app Salute, poi torna qui.';

  @override
  String get itemBoxClosed => 'ITEM BOX CHIUSA';

  @override
  String get itemBoxClosedBody =>
      'Carica le passeggiate recenti per scegliere quelle degne di uno stage, oppure importa in un colpo solo tutte quelle mai registrate.';

  @override
  String get loadWorkouts => 'Carica allenamenti';

  @override
  String get loadWorkoutsCaption => 'I 25 più recenti';

  @override
  String get importEverything => 'Importa tutto';

  @override
  String get importEverythingCaption => 'Ogni passeggiata in Salute';

  @override
  String get importing => 'IMPORTAZIONE';

  @override
  String importingBody(int fetched, int added) {
    return '$fetched passeggiate lette da Salute, $added nuovi stage finora.';
  }

  @override
  String get nothingHere => 'NIENTE QUI';

  @override
  String get noWalksInHealth => 'Nessuna passeggiata trovata in Salute.';

  @override
  String get importedLabel => 'Importato';

  @override
  String newStagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nuovi stage',
      one: '1 nuovo stage',
    );
    return '$_temp0';
  }

  @override
  String get pickWalks => 'Scegli passeggiate';

  @override
  String saveWalksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Salva $count passeggiate',
      one: 'Salva 1 passeggiata',
    );
    return '$_temp0';
  }

  @override
  String get tapToSelect => 'Tocca un allenamento per selezionarlo';

  @override
  String get addAsStages => 'Aggiungi come stage';

  @override
  String get saveWalksSemantics => 'Salva passeggiate';

  @override
  String get stageCleared => 'STAGE COMPLETATO';

  @override
  String workoutSemantics(String date) {
    return 'Allenamento del $date';
  }

  @override
  String workoutImportedSemantics(String date) {
    return '$date, già uno stage';
  }

  @override
  String get actRecording => 'ATTO 2 · REGISTRAZIONE';

  @override
  String get actClear => 'ATTO 2 · COMPLETATO';

  @override
  String get actReady => 'ATTO 2 · PRONTO';

  @override
  String get liveLabel => 'LIVE';

  @override
  String get resultLabel => 'RISULTATO';

  @override
  String get pressGoToStart => 'PREMI GO PER INIZIARE';

  @override
  String get metresNewUnit => 'm nuovi';

  @override
  String get startRecording => 'Avvia registrazione';

  @override
  String get stopLabel => 'Stop';

  @override
  String get finishStage => 'Termina stage';

  @override
  String get stopRecording => 'Ferma registrazione';

  @override
  String get stageClearButton => 'Stage completato!';

  @override
  String get viewResult => 'Vedi risultato';

  @override
  String get viewFinishedRecording => 'Vedi registrazione terminata';

  @override
  String percentNewGround(int percent) {
    return '$percent per cento di terreno nuovo';
  }

  @override
  String get settingsLabel => 'IMPOSTAZIONI';

  @override
  String get optionsTitle => 'OPZIONI';

  @override
  String get optionsIntro =>
      'Regola come le tue passeggiate appaiono sulla mappa. Le modifiche valgono subito ovunque.';

  @override
  String get trailWidth => 'SPESSORE TRACCIA';

  @override
  String get trailWidthCaption => 'Quanto spessa è disegnata ogni passeggiata.';

  @override
  String get trailWidthSemantics => 'Spessore traccia';

  @override
  String pxValue(int value) {
    return '$value px';
  }

  @override
  String get revealRadius => 'RAGGIO DI SCOPERTA';

  @override
  String get revealRadiusCaption =>
      'Fin dove si dirada la nebbia attorno a una passeggiata. Più grande, più in fretta si riempie la città.';

  @override
  String get revealRadiusSemantics => 'Raggio di scoperta';

  @override
  String mValue(int value) {
    return '$value m';
  }

  @override
  String get resetToDefaults => 'Ripristina predefiniti';

  @override
  String get mapDataLabel => 'DATI MAPPA';

  @override
  String get mapDataBody =>
      'Scarica la tua città una volta sola: la mappa sarà istantanea e funzionerà senza connessione.';

  @override
  String get downloadMapArea => 'Scarica area della mappa';

  @override
  String get offlineTiles => 'Tile offline';

  @override
  String get demoData => 'DATI DEMO';

  @override
  String demoDataBody(int walks, int spots) {
    return 'Anteprima di una Tokyo quasi del tutto esplorata: $walks passeggiate generate in tutti i 23 quartieri e $spots spot famosi. Le passeggiate vere restano intatte.';
  }

  @override
  String demoDataLoaded(int count) {
    return '$count passeggiate demo caricate. Rimuovile per tornare ai tuoi stage.';
  }

  @override
  String get fillTokyo => 'Riempi Tokyo';

  @override
  String get fillTokyoCaption => 'Passeggiate e spot generati';

  @override
  String get removeDemoData => 'Rimuovi dati demo';

  @override
  String get removeDemoDataCaption => 'Mantiene le passeggiate vere';

  @override
  String get skip => 'SALTA';

  @override
  String get frameYourCity => 'Inquadra la tua città';

  @override
  String get mapDataOffline => 'DATI MAPPA · OFFLINE';

  @override
  String get downloadArea => 'SCARICA AREA';

  @override
  String get downloadIntroFirstRun =>
      'Salva la città in cui cammini: la mappa sarà istantanea e funzionerà senza segnale. Puoi farlo anche più tardi dalle Opzioni.';

  @override
  String get downloadIntro =>
      'Le tile dentro la cornice dorata vengono salvate su questo telefono.';

  @override
  String downloadCancelCaption(int done, int total, String bytes) {
    return '$done / $total tile · $bytes';
  }

  @override
  String get tilesUnit => 'tile';

  @override
  String get downloadUnit => 'download';

  @override
  String get storedUnit => 'salvato';

  @override
  String get doneLabel => 'Fatto';

  @override
  String get areaStored => 'Area salvata';

  @override
  String get tooBig => 'Troppo grande';

  @override
  String get zoomInALittle => 'Avvicina un po’';

  @override
  String get downloadAnotherArea => 'Scarica un’altra area';

  @override
  String get downloadLabel => 'Scarica';

  @override
  String get frameSmallerArea => 'Inquadra un’area più piccola';

  @override
  String get zoomRangeCaption => 'Zoom da 0 a 14 nella cornice';

  @override
  String get downloadAreaSemantics => 'Scarica area';

  @override
  String areasStored(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count aree salvate',
      one: '1 area salvata',
    );
    return '$_temp0';
  }

  @override
  String get clearMapData => 'Cancella dati mappa';

  @override
  String freesBytes(String bytes) {
    return 'Libera $bytes';
  }

  @override
  String get downloading => 'DOWNLOAD IN CORSO';

  @override
  String get downloadProgressSemantics => 'Avanzamento download';

  @override
  String percentValue(int percent) {
    return '$percent per cento';
  }

  @override
  String areaName(int number) {
    return 'Area $number';
  }
}
