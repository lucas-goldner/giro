import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('de'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('pt'),
    Locale('zh'),
  ];

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'◀  BACK'**
  String get back;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @kmUnit.
  ///
  /// In en, this message translates to:
  /// **'KM'**
  String get kmUnit;

  /// No description provided for @kmUnitLower.
  ///
  /// In en, this message translates to:
  /// **'km'**
  String get kmUnitLower;

  /// No description provided for @perKmUnit.
  ///
  /// In en, this message translates to:
  /// **'/km'**
  String get perKmUnit;

  /// No description provided for @zoneChip.
  ///
  /// In en, this message translates to:
  /// **'Zone 1 · Tokyo'**
  String get zoneChip;

  /// No description provided for @optionsSemantics.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get optionsSemantics;

  /// No description provided for @loadingMap.
  ///
  /// In en, this message translates to:
  /// **'LOADING MAP'**
  String get loadingMap;

  /// No description provided for @loadingMapSemantics.
  ///
  /// In en, this message translates to:
  /// **'Loading map'**
  String get loadingMapSemantics;

  /// No description provided for @spotMarkerSemantics.
  ///
  /// In en, this message translates to:
  /// **'Spot'**
  String get spotMarkerSemantics;

  /// No description provided for @distanceKm.
  ///
  /// In en, this message translates to:
  /// **'{km} km'**
  String distanceKm(String km);

  /// No description provided for @distanceM.
  ///
  /// In en, this message translates to:
  /// **'{m} m'**
  String distanceM(int m);

  /// No description provided for @durationHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String durationHoursMinutes(int hours, String minutes);

  /// No description provided for @durationMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m'**
  String durationMinutes(int minutes);

  /// No description provided for @walksCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 walk} other{{count} walks}}'**
  String walksCount(int count);

  /// No description provided for @spotsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 spot} other{{count} spots}}'**
  String spotsCount(int count);

  /// No description provided for @placesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 place} other{{count} places}}'**
  String placesCount(int count);

  /// Three facts joined by middle dots
  ///
  /// In en, this message translates to:
  /// **'{a} · {b} · {c}'**
  String dotSeparated(String a, String b, String c);

  /// No description provided for @dotSeparatedTwo.
  ///
  /// In en, this message translates to:
  /// **'{a} · {b}'**
  String dotSeparatedTwo(String a, String b);

  /// No description provided for @homeStageLabel.
  ///
  /// In en, this message translates to:
  /// **'STAGE: TOKYO · THIS WEEK'**
  String get homeStageLabel;

  /// No description provided for @goLabel.
  ///
  /// In en, this message translates to:
  /// **'GO!'**
  String get goLabel;

  /// No description provided for @goCaption.
  ///
  /// In en, this message translates to:
  /// **'Record a walk'**
  String get goCaption;

  /// No description provided for @goSemantics.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get goSemantics;

  /// No description provided for @importLabel.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importLabel;

  /// No description provided for @importCaption.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get importCaption;

  /// No description provided for @spotsLabel.
  ///
  /// In en, this message translates to:
  /// **'Spots'**
  String get spotsLabel;

  /// No description provided for @spotsSemantics.
  ///
  /// In en, this message translates to:
  /// **'Places'**
  String get spotsSemantics;

  /// No description provided for @stagesLabel.
  ///
  /// In en, this message translates to:
  /// **'Stages'**
  String get stagesLabel;

  /// No description provided for @stagesCaption.
  ///
  /// In en, this message translates to:
  /// **'All walks'**
  String get stagesCaption;

  /// No description provided for @stageSelect.
  ///
  /// In en, this message translates to:
  /// **'STAGE SELECT'**
  String get stageSelect;

  /// No description provided for @stagesTitle.
  ///
  /// In en, this message translates to:
  /// **'TOKYO · {count} STAGES'**
  String stagesTitle(int count);

  /// No description provided for @stageCardTitle.
  ///
  /// In en, this message translates to:
  /// **'STAGE {day}'**
  String stageCardTitle(int day);

  /// No description provided for @stageCardMeta.
  ///
  /// In en, this message translates to:
  /// **'{date} · {distance} · {duration} · {spots}'**
  String stageCardMeta(
    String date,
    String distance,
    String duration,
    String spots,
  );

  /// No description provided for @stageSemantics.
  ///
  /// In en, this message translates to:
  /// **'Stage {date}, {distance}, rank {rank}'**
  String stageSemantics(String date, String distance, String rank);

  /// No description provided for @stageClear.
  ///
  /// In en, this message translates to:
  /// **'STAGE CLEAR!'**
  String get stageClear;

  /// No description provided for @timeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get timeLabel;

  /// No description provided for @paceLabel.
  ///
  /// In en, this message translates to:
  /// **'Pace'**
  String get paceLabel;

  /// No description provided for @paceValue.
  ///
  /// In en, this message translates to:
  /// **'{pace} /KM'**
  String paceValue(String pace);

  /// No description provided for @newGroundLabel.
  ///
  /// In en, this message translates to:
  /// **'New ground'**
  String get newGroundLabel;

  /// No description provided for @newGroundValue.
  ///
  /// In en, this message translates to:
  /// **'+{km} km · {percent}%'**
  String newGroundValue(String km, int percent);

  /// No description provided for @noSpotsOnStage.
  ///
  /// In en, this message translates to:
  /// **'NO SPOTS ON THIS STAGE'**
  String get noSpotsOnStage;

  /// No description provided for @spotsHeader.
  ///
  /// In en, this message translates to:
  /// **'SPOTS'**
  String get spotsHeader;

  /// No description provided for @holdToMarkOne.
  ///
  /// In en, this message translates to:
  /// **'Press and hold the map to mark one.'**
  String get holdToMarkOne;

  /// No description provided for @backToStageSelect.
  ///
  /// In en, this message translates to:
  /// **'Back to stage select'**
  String get backToStageSelect;

  /// No description provided for @spotCollection.
  ///
  /// In en, this message translates to:
  /// **'SPOT COLLECTION'**
  String get spotCollection;

  /// No description provided for @spotsTitle.
  ///
  /// In en, this message translates to:
  /// **'{count} SPOTS'**
  String spotsTitle(int count);

  /// No description provided for @spotsHint.
  ///
  /// In en, this message translates to:
  /// **'Press and hold the map to mark a spot. Swipe one away to remove it.'**
  String get spotsHint;

  /// No description provided for @spotSemantics.
  ///
  /// In en, this message translates to:
  /// **'Spot {name}'**
  String spotSemantics(String name);

  /// No description provided for @spotMeta.
  ///
  /// In en, this message translates to:
  /// **'Marked {date} · visited by {count, plural, =1{1 walk} other{{count} walks}}'**
  String spotMeta(String date, int count);

  /// No description provided for @markASpot.
  ///
  /// In en, this message translates to:
  /// **'MARK A SPOT'**
  String get markASpot;

  /// No description provided for @markASpotBody.
  ///
  /// In en, this message translates to:
  /// **'Name this place. Spots are visited by the walks that pass them.'**
  String get markASpotBody;

  /// No description provided for @spotNameHint.
  ///
  /// In en, this message translates to:
  /// **'Spot name'**
  String get spotNameHint;

  /// No description provided for @markIt.
  ///
  /// In en, this message translates to:
  /// **'Mark it!'**
  String get markIt;

  /// No description provided for @addSemantics.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addSemantics;

  /// No description provided for @itemBoxHealth.
  ///
  /// In en, this message translates to:
  /// **'ITEM BOX · HEALTH'**
  String get itemBoxHealth;

  /// No description provided for @importWalks.
  ///
  /// In en, this message translates to:
  /// **'IMPORT WALKS'**
  String get importWalks;

  /// No description provided for @importIntro.
  ///
  /// In en, this message translates to:
  /// **'Walks recorded by your watch become stages. Only routes from supported watches carry a map.'**
  String get importIntro;

  /// No description provided for @healthDenied.
  ///
  /// In en, this message translates to:
  /// **'HEALTH ACCESS DENIED'**
  String get healthDenied;

  /// No description provided for @healthDeniedBody.
  ///
  /// In en, this message translates to:
  /// **'Allow Giro to read workouts in the Health app, then come back.'**
  String get healthDeniedBody;

  /// No description provided for @itemBoxClosed.
  ///
  /// In en, this message translates to:
  /// **'ITEM BOX CLOSED'**
  String get itemBoxClosed;

  /// No description provided for @itemBoxClosedBody.
  ///
  /// In en, this message translates to:
  /// **'Load your recent walks to pick the ones worth a stage, or import every walk ever recorded in one go.'**
  String get itemBoxClosedBody;

  /// No description provided for @loadWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Load workouts'**
  String get loadWorkouts;

  /// No description provided for @loadWorkoutsCaption.
  ///
  /// In en, this message translates to:
  /// **'The 25 most recent'**
  String get loadWorkoutsCaption;

  /// No description provided for @importEverything.
  ///
  /// In en, this message translates to:
  /// **'Import everything'**
  String get importEverything;

  /// No description provided for @importEverythingCaption.
  ///
  /// In en, this message translates to:
  /// **'Every walk in Health'**
  String get importEverythingCaption;

  /// No description provided for @importing.
  ///
  /// In en, this message translates to:
  /// **'IMPORTING'**
  String get importing;

  /// No description provided for @importingBody.
  ///
  /// In en, this message translates to:
  /// **'{fetched} walks read from Health, {added} new stages so far.'**
  String importingBody(int fetched, int added);

  /// No description provided for @nothingHere.
  ///
  /// In en, this message translates to:
  /// **'NOTHING HERE'**
  String get nothingHere;

  /// No description provided for @noWalksInHealth.
  ///
  /// In en, this message translates to:
  /// **'No walks found in Health.'**
  String get noWalksInHealth;

  /// No description provided for @importedLabel.
  ///
  /// In en, this message translates to:
  /// **'Imported'**
  String get importedLabel;

  /// No description provided for @newStagesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 new stage} other{{count} new stages}}'**
  String newStagesCount(int count);

  /// No description provided for @pickWalks.
  ///
  /// In en, this message translates to:
  /// **'Pick walks'**
  String get pickWalks;

  /// No description provided for @saveWalksCount.
  ///
  /// In en, this message translates to:
  /// **'Save {count, plural, =1{1 walk} other{{count} walks}}'**
  String saveWalksCount(int count);

  /// No description provided for @tapToSelect.
  ///
  /// In en, this message translates to:
  /// **'Tap a workout to select it'**
  String get tapToSelect;

  /// No description provided for @addAsStages.
  ///
  /// In en, this message translates to:
  /// **'Add as stages'**
  String get addAsStages;

  /// No description provided for @saveWalksSemantics.
  ///
  /// In en, this message translates to:
  /// **'Save walks'**
  String get saveWalksSemantics;

  /// No description provided for @stageCleared.
  ///
  /// In en, this message translates to:
  /// **'STAGE CLEARED'**
  String get stageCleared;

  /// No description provided for @workoutSemantics.
  ///
  /// In en, this message translates to:
  /// **'{date} workout'**
  String workoutSemantics(String date);

  /// No description provided for @workoutImportedSemantics.
  ///
  /// In en, this message translates to:
  /// **'{date}, already a stage'**
  String workoutImportedSemantics(String date);

  /// No description provided for @actRecording.
  ///
  /// In en, this message translates to:
  /// **'ACT 2 · RECORDING'**
  String get actRecording;

  /// No description provided for @actClear.
  ///
  /// In en, this message translates to:
  /// **'ACT 2 · CLEAR'**
  String get actClear;

  /// No description provided for @actReady.
  ///
  /// In en, this message translates to:
  /// **'ACT 2 · READY'**
  String get actReady;

  /// No description provided for @liveLabel.
  ///
  /// In en, this message translates to:
  /// **'LIVE'**
  String get liveLabel;

  /// No description provided for @resultLabel.
  ///
  /// In en, this message translates to:
  /// **'RESULT'**
  String get resultLabel;

  /// No description provided for @pressGoToStart.
  ///
  /// In en, this message translates to:
  /// **'PRESS GO TO START'**
  String get pressGoToStart;

  /// No description provided for @metresNewUnit.
  ///
  /// In en, this message translates to:
  /// **'m new'**
  String get metresNewUnit;

  /// No description provided for @startRecording.
  ///
  /// In en, this message translates to:
  /// **'Start recording'**
  String get startRecording;

  /// No description provided for @stopLabel.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stopLabel;

  /// No description provided for @finishStage.
  ///
  /// In en, this message translates to:
  /// **'Finish stage'**
  String get finishStage;

  /// No description provided for @stopRecording.
  ///
  /// In en, this message translates to:
  /// **'Stop recording'**
  String get stopRecording;

  /// No description provided for @stageClearButton.
  ///
  /// In en, this message translates to:
  /// **'Stage clear!'**
  String get stageClearButton;

  /// No description provided for @viewResult.
  ///
  /// In en, this message translates to:
  /// **'View result'**
  String get viewResult;

  /// No description provided for @viewFinishedRecording.
  ///
  /// In en, this message translates to:
  /// **'View finished recording'**
  String get viewFinishedRecording;

  /// No description provided for @percentNewGround.
  ///
  /// In en, this message translates to:
  /// **'{percent} percent new ground'**
  String percentNewGround(int percent);

  /// No description provided for @settingsLabel.
  ///
  /// In en, this message translates to:
  /// **'SETTINGS'**
  String get settingsLabel;

  /// No description provided for @optionsTitle.
  ///
  /// In en, this message translates to:
  /// **'OPTIONS'**
  String get optionsTitle;

  /// No description provided for @optionsIntro.
  ///
  /// In en, this message translates to:
  /// **'Tune how your walks show on the map. Changes apply everywhere right away.'**
  String get optionsIntro;

  /// No description provided for @trailWidth.
  ///
  /// In en, this message translates to:
  /// **'TRAIL WIDTH'**
  String get trailWidth;

  /// No description provided for @trailWidthCaption.
  ///
  /// In en, this message translates to:
  /// **'How thick each walk is drawn.'**
  String get trailWidthCaption;

  /// No description provided for @trailWidthSemantics.
  ///
  /// In en, this message translates to:
  /// **'Trail width'**
  String get trailWidthSemantics;

  /// No description provided for @pxValue.
  ///
  /// In en, this message translates to:
  /// **'{value} px'**
  String pxValue(int value);

  /// No description provided for @revealRadius.
  ///
  /// In en, this message translates to:
  /// **'REVEAL RADIUS'**
  String get revealRadius;

  /// No description provided for @revealRadiusCaption.
  ///
  /// In en, this message translates to:
  /// **'How far around a walk the fog of war is lifted. Bigger means the city fills in faster.'**
  String get revealRadiusCaption;

  /// No description provided for @revealRadiusSemantics.
  ///
  /// In en, this message translates to:
  /// **'Reveal radius'**
  String get revealRadiusSemantics;

  /// No description provided for @mValue.
  ///
  /// In en, this message translates to:
  /// **'{value} m'**
  String mValue(int value);

  /// No description provided for @resetToDefaults.
  ///
  /// In en, this message translates to:
  /// **'Reset to defaults'**
  String get resetToDefaults;

  /// No description provided for @mapDataLabel.
  ///
  /// In en, this message translates to:
  /// **'MAP DATA'**
  String get mapDataLabel;

  /// No description provided for @mapDataBody.
  ///
  /// In en, this message translates to:
  /// **'Download your city once so the map is instant and works without a connection.'**
  String get mapDataBody;

  /// No description provided for @downloadMapArea.
  ///
  /// In en, this message translates to:
  /// **'Download map area'**
  String get downloadMapArea;

  /// No description provided for @offlineTiles.
  ///
  /// In en, this message translates to:
  /// **'Offline tiles'**
  String get offlineTiles;

  /// No description provided for @demoData.
  ///
  /// In en, this message translates to:
  /// **'DEMO DATA'**
  String get demoData;

  /// No description provided for @demoDataBody.
  ///
  /// In en, this message translates to:
  /// **'Preview a Tokyo that is almost fully explored: {walks} generated walks across all 23 wards and {spots} famous spots. Real walks stay untouched.'**
  String demoDataBody(int walks, int spots);

  /// No description provided for @demoDataLoaded.
  ///
  /// In en, this message translates to:
  /// **'{count} demo walks loaded. Remove them to get back to your own stages.'**
  String demoDataLoaded(int count);

  /// No description provided for @fillTokyo.
  ///
  /// In en, this message translates to:
  /// **'Fill Tokyo'**
  String get fillTokyo;

  /// No description provided for @fillTokyoCaption.
  ///
  /// In en, this message translates to:
  /// **'Generated walks and spots'**
  String get fillTokyoCaption;

  /// No description provided for @removeDemoData.
  ///
  /// In en, this message translates to:
  /// **'Remove demo data'**
  String get removeDemoData;

  /// No description provided for @removeDemoDataCaption.
  ///
  /// In en, this message translates to:
  /// **'Keeps your real walks'**
  String get removeDemoDataCaption;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'SKIP'**
  String get skip;

  /// No description provided for @frameYourCity.
  ///
  /// In en, this message translates to:
  /// **'Frame your city'**
  String get frameYourCity;

  /// No description provided for @mapDataOffline.
  ///
  /// In en, this message translates to:
  /// **'MAP DATA · OFFLINE'**
  String get mapDataOffline;

  /// No description provided for @downloadArea.
  ///
  /// In en, this message translates to:
  /// **'DOWNLOAD AREA'**
  String get downloadArea;

  /// No description provided for @downloadIntroFirstRun.
  ///
  /// In en, this message translates to:
  /// **'Store the city you walk in so the map is instant and works without a signal. You can do this later in Options.'**
  String get downloadIntroFirstRun;

  /// No description provided for @downloadIntro.
  ///
  /// In en, this message translates to:
  /// **'Tiles inside the gold frame are stored on this phone.'**
  String get downloadIntro;

  /// No description provided for @downloadCancelCaption.
  ///
  /// In en, this message translates to:
  /// **'{done} / {total} tiles · {bytes}'**
  String downloadCancelCaption(int done, int total, String bytes);

  /// No description provided for @tilesUnit.
  ///
  /// In en, this message translates to:
  /// **'tiles'**
  String get tilesUnit;

  /// No description provided for @downloadUnit.
  ///
  /// In en, this message translates to:
  /// **'download'**
  String get downloadUnit;

  /// No description provided for @storedUnit.
  ///
  /// In en, this message translates to:
  /// **'stored'**
  String get storedUnit;

  /// No description provided for @doneLabel.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get doneLabel;

  /// No description provided for @areaStored.
  ///
  /// In en, this message translates to:
  /// **'Area stored'**
  String get areaStored;

  /// No description provided for @tooBig.
  ///
  /// In en, this message translates to:
  /// **'Too big'**
  String get tooBig;

  /// No description provided for @zoomInALittle.
  ///
  /// In en, this message translates to:
  /// **'Zoom in a little'**
  String get zoomInALittle;

  /// No description provided for @downloadAnotherArea.
  ///
  /// In en, this message translates to:
  /// **'Download another area'**
  String get downloadAnotherArea;

  /// No description provided for @downloadLabel.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get downloadLabel;

  /// No description provided for @frameSmallerArea.
  ///
  /// In en, this message translates to:
  /// **'Frame a smaller area'**
  String get frameSmallerArea;

  /// No description provided for @zoomRangeCaption.
  ///
  /// In en, this message translates to:
  /// **'Zoom 0 to 14 inside the frame'**
  String get zoomRangeCaption;

  /// No description provided for @downloadAreaSemantics.
  ///
  /// In en, this message translates to:
  /// **'Download area'**
  String get downloadAreaSemantics;

  /// No description provided for @areasStored.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 area stored} other{{count} areas stored}}'**
  String areasStored(int count);

  /// No description provided for @clearMapData.
  ///
  /// In en, this message translates to:
  /// **'Clear map data'**
  String get clearMapData;

  /// No description provided for @freesBytes.
  ///
  /// In en, this message translates to:
  /// **'Frees {bytes}'**
  String freesBytes(String bytes);

  /// No description provided for @downloading.
  ///
  /// In en, this message translates to:
  /// **'DOWNLOADING'**
  String get downloading;

  /// No description provided for @downloadProgressSemantics.
  ///
  /// In en, this message translates to:
  /// **'Download progress'**
  String get downloadProgressSemantics;

  /// No description provided for @percentValue.
  ///
  /// In en, this message translates to:
  /// **'{percent} percent'**
  String percentValue(int percent);

  /// No description provided for @areaName.
  ///
  /// In en, this message translates to:
  /// **'Area {number}'**
  String areaName(int number);

  /// No description provided for @graphicsLabel.
  ///
  /// In en, this message translates to:
  /// **'GRAPHICS'**
  String get graphicsLabel;

  /// No description provided for @graphicsBody.
  ///
  /// In en, this message translates to:
  /// **'How the 3D city is drawn. Advanced draws the buildings itself with sun shadows, materials by building type and shadows on the streets. Experimental and heavier on the battery.'**
  String get graphicsBody;

  /// No description provided for @graphicsClassic.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get graphicsClassic;

  /// No description provided for @graphicsClassicCaption.
  ///
  /// In en, this message translates to:
  /// **'Toy city, light on the GPU'**
  String get graphicsClassicCaption;

  /// No description provided for @graphicsAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get graphicsAdvanced;

  /// No description provided for @graphicsAdvancedCaption.
  ///
  /// In en, this message translates to:
  /// **'Sun shadows and materials (beta)'**
  String get graphicsAdvancedCaption;

  /// No description provided for @graphicsSemantics.
  ///
  /// In en, this message translates to:
  /// **'Graphics mode'**
  String get graphicsSemantics;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'it',
    'ja',
    'ko',
    'pt',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'pt':
      return AppLocalizationsPt();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
