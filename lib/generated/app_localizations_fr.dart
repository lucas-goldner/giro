// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get back => '◀  RETOUR';

  @override
  String get cancel => 'Annuler';

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
  String get loadingMap => 'CHARGEMENT DE LA CARTE';

  @override
  String get loadingMapSemantics => 'Chargement de la carte';

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
      other: '$count marches',
      one: '1 marche',
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
      other: '$count lieux',
      one: '1 lieu',
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
  String get homeStageLabel => 'STAGE : TOKYO · CETTE SEMAINE';

  @override
  String get goLabel => 'GO!';

  @override
  String get goCaption => 'Enregistrer une marche';

  @override
  String get goSemantics => 'Enregistrer';

  @override
  String get importLabel => 'Importer';

  @override
  String get importCaption => 'Santé';

  @override
  String get spotsLabel => 'Spots';

  @override
  String get spotsSemantics => 'Lieux';

  @override
  String get stagesLabel => 'Stages';

  @override
  String get stagesCaption => 'Toutes les marches';

  @override
  String get stageSelect => 'CHOIX DU STAGE';

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
    return 'Stage $date, $distance, rang $rank';
  }

  @override
  String get stageClear => 'STAGE TERMINÉ !';

  @override
  String get timeLabel => 'Temps';

  @override
  String get paceLabel => 'Allure';

  @override
  String paceValue(String pace) {
    return '$pace /KM';
  }

  @override
  String get newGroundLabel => 'Terrain inédit';

  @override
  String newGroundValue(String km, int percent) {
    return '+$km km · $percent %';
  }

  @override
  String get noSpotsOnStage => 'AUCUN SPOT SUR CE STAGE';

  @override
  String get spotsHeader => 'SPOTS';

  @override
  String get holdToMarkOne =>
      'Appuyez longuement sur la carte pour en marquer un.';

  @override
  String get backToStageSelect => 'Retour au choix du stage';

  @override
  String get spotCollection => 'COLLECTION DE SPOTS';

  @override
  String spotsTitle(int count) {
    return '$count SPOTS';
  }

  @override
  String get spotsHint =>
      'Appuyez longuement sur la carte pour marquer un spot. Balayez-en un pour le retirer.';

  @override
  String spotSemantics(String name) {
    return 'Spot $name';
  }

  @override
  String spotMeta(String date, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count marches',
      one: '1 marche',
    );
    return 'Marqué le $date · visité par $_temp0';
  }

  @override
  String get markASpot => 'MARQUER UN SPOT';

  @override
  String get markASpotBody =>
      'Nommez ce lieu. Les spots sont visités par les marches qui passent à côté.';

  @override
  String get spotNameHint => 'Nom du spot';

  @override
  String get markIt => 'Marquer !';

  @override
  String get addSemantics => 'Ajouter';

  @override
  String get itemBoxHealth => 'ITEM BOX · SANTÉ';

  @override
  String get importWalks => 'IMPORTER DES MARCHES';

  @override
  String get importIntro =>
      'Les marches enregistrées par votre montre deviennent des stages. Seuls les parcours des montres compatibles ont une carte.';

  @override
  String get healthDenied => 'ACCÈS À SANTÉ REFUSÉ';

  @override
  String get healthDeniedBody =>
      'Autorisez Giro à lire les entraînements dans l’app Santé, puis revenez.';

  @override
  String get itemBoxClosed => 'ITEM BOX FERMÉE';

  @override
  String get itemBoxClosedBody =>
      'Chargez vos marches récentes pour choisir celles qui méritent un stage, ou importez toutes les marches jamais enregistrées d’un coup.';

  @override
  String get loadWorkouts => 'Charger les entraînements';

  @override
  String get loadWorkoutsCaption => 'Les 25 plus récents';

  @override
  String get importEverything => 'Tout importer';

  @override
  String get importEverythingCaption => 'Chaque marche dans Santé';

  @override
  String get importing => 'IMPORTATION';

  @override
  String importingBody(int fetched, int added) {
    return '$fetched marches lues depuis Santé, $added nouveaux stages pour l’instant.';
  }

  @override
  String get nothingHere => 'RIEN ICI';

  @override
  String get noWalksInHealth => 'Aucune marche trouvée dans Santé.';

  @override
  String get importedLabel => 'Importé';

  @override
  String newStagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nouveaux stages',
      one: '1 nouveau stage',
    );
    return '$_temp0';
  }

  @override
  String get pickWalks => 'Choisir des marches';

  @override
  String saveWalksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Enregistrer $count marches',
      one: 'Enregistrer 1 marche',
    );
    return '$_temp0';
  }

  @override
  String get tapToSelect => 'Touchez un entraînement pour le sélectionner';

  @override
  String get addAsStages => 'Ajouter comme stages';

  @override
  String get saveWalksSemantics => 'Enregistrer les marches';

  @override
  String get stageCleared => 'STAGE TERMINÉ';

  @override
  String workoutSemantics(String date) {
    return 'Entraînement du $date';
  }

  @override
  String workoutImportedSemantics(String date) {
    return '$date, déjà un stage';
  }

  @override
  String get actRecording => 'ACTE 2 · ENREGISTREMENT';

  @override
  String get actClear => 'ACTE 2 · TERMINÉ';

  @override
  String get actReady => 'ACTE 2 · PRÊT';

  @override
  String get liveLabel => 'EN DIRECT';

  @override
  String get resultLabel => 'RÉSULTAT';

  @override
  String get pressGoToStart => 'APPUYEZ SUR GO POUR COMMENCER';

  @override
  String get metresNewUnit => 'm inédits';

  @override
  String get startRecording => 'Démarrer l’enregistrement';

  @override
  String get stopLabel => 'Stop';

  @override
  String get finishStage => 'Terminer le stage';

  @override
  String get stopRecording => 'Arrêter l’enregistrement';

  @override
  String get stageClearButton => 'Stage terminé !';

  @override
  String get viewResult => 'Voir le résultat';

  @override
  String get viewFinishedRecording => 'Voir l’enregistrement terminé';

  @override
  String percentNewGround(int percent) {
    return '$percent pour cent de terrain inédit';
  }

  @override
  String get settingsLabel => 'RÉGLAGES';

  @override
  String get optionsTitle => 'OPTIONS';

  @override
  String get optionsIntro =>
      'Réglez l’affichage de vos marches sur la carte. Les changements s’appliquent partout immédiatement.';

  @override
  String get trailWidth => 'ÉPAISSEUR DU TRACÉ';

  @override
  String get trailWidthCaption => 'Épaisseur de chaque marche dessinée.';

  @override
  String get trailWidthSemantics => 'Épaisseur du tracé';

  @override
  String pxValue(int value) {
    return '$value px';
  }

  @override
  String get revealRadius => 'RAYON DE DÉCOUVERTE';

  @override
  String get revealRadiusCaption =>
      'Jusqu’où le brouillard se lève autour d’une marche. Plus grand, la ville se remplit plus vite.';

  @override
  String get revealRadiusSemantics => 'Rayon de découverte';

  @override
  String mValue(int value) {
    return '$value m';
  }

  @override
  String get resetToDefaults => 'Rétablir les valeurs par défaut';

  @override
  String get mapDataLabel => 'DONNÉES CARTO';

  @override
  String get mapDataBody =>
      'Téléchargez votre ville une fois pour que la carte soit instantanée et fonctionne sans connexion.';

  @override
  String get downloadMapArea => 'Télécharger une zone';

  @override
  String get offlineTiles => 'Tuiles hors ligne';

  @override
  String get demoData => 'DONNÉES DE DÉMO';

  @override
  String demoDataBody(int walks, int spots) {
    return 'Aperçu d’un Tokyo presque entièrement exploré : $walks marches générées dans les 23 arrondissements et $spots spots célèbres. Les vraies marches restent intactes.';
  }

  @override
  String demoDataLoaded(int count) {
    return '$count marches de démo chargées. Retirez-les pour retrouver vos propres stages.';
  }

  @override
  String get fillTokyo => 'Remplir Tokyo';

  @override
  String get fillTokyoCaption => 'Marches et spots générés';

  @override
  String get removeDemoData => 'Retirer les données de démo';

  @override
  String get removeDemoDataCaption => 'Conserve vos vraies marches';

  @override
  String get skip => 'PASSER';

  @override
  String get frameYourCity => 'Cadrez votre ville';

  @override
  String get mapDataOffline => 'DONNÉES CARTO · HORS LIGNE';

  @override
  String get downloadArea => 'TÉLÉCHARGER LA ZONE';

  @override
  String get downloadIntroFirstRun =>
      'Stockez la ville où vous marchez pour que la carte soit instantanée et fonctionne sans réseau. Vous pourrez le faire plus tard dans les options.';

  @override
  String get downloadIntro =>
      'Les tuiles dans le cadre doré sont stockées sur ce téléphone.';

  @override
  String downloadCancelCaption(int done, int total, String bytes) {
    return '$done / $total tuiles · $bytes';
  }

  @override
  String get tilesUnit => 'tuiles';

  @override
  String get downloadUnit => 'téléchargement';

  @override
  String get storedUnit => 'stocké';

  @override
  String get doneLabel => 'Terminé';

  @override
  String get areaStored => 'Zone stockée';

  @override
  String get tooBig => 'Trop grand';

  @override
  String get zoomInALittle => 'Zoomez un peu';

  @override
  String get downloadAnotherArea => 'Télécharger une autre zone';

  @override
  String get downloadLabel => 'Télécharger';

  @override
  String get frameSmallerArea => 'Cadrez une zone plus petite';

  @override
  String get zoomRangeCaption => 'Zoom 0 à 14 dans le cadre';

  @override
  String get downloadAreaSemantics => 'Télécharger la zone';

  @override
  String areasStored(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count zones stockées',
      one: '1 zone stockée',
    );
    return '$_temp0';
  }

  @override
  String get clearMapData => 'Effacer les données carto';

  @override
  String freesBytes(String bytes) {
    return 'Libère $bytes';
  }

  @override
  String get downloading => 'TÉLÉCHARGEMENT';

  @override
  String get downloadProgressSemantics => 'Progression du téléchargement';

  @override
  String percentValue(int percent) {
    return '$percent pour cent';
  }

  @override
  String areaName(int number) {
    return 'Zone $number';
  }
}
