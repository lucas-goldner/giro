// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get back => '◀  뒤로';

  @override
  String get cancel => '취소';

  @override
  String get kmUnit => 'KM';

  @override
  String get kmUnitLower => 'km';

  @override
  String get perKmUnit => '/km';

  @override
  String get zoneChip => '존 1 · 도쿄';

  @override
  String get optionsSemantics => '옵션';

  @override
  String get loadingMap => '지도 불러오는 중';

  @override
  String get loadingMapSemantics => '지도 불러오는 중';

  @override
  String get spotMarkerSemantics => '스팟';

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
    return '$hours시간 $minutes분';
  }

  @override
  String durationMinutes(int minutes) {
    return '$minutes분';
  }

  @override
  String walksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '산책 $count회',
    );
    return '$_temp0';
  }

  @override
  String spotsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '스팟 $count개',
    );
    return '$_temp0';
  }

  @override
  String placesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count곳',
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
  String get homeStageLabel => '스테이지: 도쿄 · 이번 주';

  @override
  String get goLabel => 'GO!';

  @override
  String get goCaption => '산책 기록';

  @override
  String get goSemantics => '기록';

  @override
  String get importLabel => '가져오기';

  @override
  String get importCaption => '건강';

  @override
  String get spotsLabel => '스팟';

  @override
  String get spotsSemantics => '장소';

  @override
  String get stagesLabel => '스테이지';

  @override
  String get stagesCaption => '모든 산책';

  @override
  String get stageSelect => '스테이지 선택';

  @override
  String stagesTitle(int count) {
    return '도쿄 · 스테이지 $count개';
  }

  @override
  String stageCardTitle(int day) {
    return '스테이지 $day';
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
    return '스테이지 $date, $distance, 랭크 $rank';
  }

  @override
  String get stageClear => '스테이지 클리어!';

  @override
  String get timeLabel => '시간';

  @override
  String get paceLabel => '페이스';

  @override
  String paceValue(String pace) {
    return '$pace /KM';
  }

  @override
  String get newGroundLabel => '새로운 길';

  @override
  String newGroundValue(String km, int percent) {
    return '+$km km · $percent%';
  }

  @override
  String get noSpotsOnStage => '이 스테이지에는 스팟이 없습니다';

  @override
  String get spotsHeader => '스팟';

  @override
  String get holdToMarkOne => '지도를 길게 눌러 표시하세요.';

  @override
  String get backToStageSelect => '스테이지 선택으로';

  @override
  String get spotCollection => '스팟 컬렉션';

  @override
  String spotsTitle(int count) {
    return '스팟 $count개';
  }

  @override
  String get spotsHint => '지도를 길게 눌러 스팟을 표시하고, 밀어서 삭제하세요.';

  @override
  String spotSemantics(String name) {
    return '스팟 $name';
  }

  @override
  String spotMeta(String date, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '산책 $count회',
    );
    return '$date 표시 · $_temp0 방문';
  }

  @override
  String get markASpot => '스팟 표시';

  @override
  String get markASpotBody => '이 장소의 이름을 지어 주세요. 지나가는 산책이 스팟을 방문한 것으로 기록됩니다.';

  @override
  String get spotNameHint => '스팟 이름';

  @override
  String get markIt => '표시!';

  @override
  String get addSemantics => '추가';

  @override
  String get itemBoxHealth => '아이템 박스 · 건강';

  @override
  String get importWalks => '산책 가져오기';

  @override
  String get importIntro => '워치로 기록한 산책이 스테이지가 됩니다. 지원되는 워치의 경로만 지도가 있습니다.';

  @override
  String get healthDenied => '건강 접근이 거부됨';

  @override
  String get healthDeniedBody => '건강 앱에서 Giro가 운동을 읽도록 허용한 뒤 돌아오세요.';

  @override
  String get itemBoxClosed => '아이템 박스가 닫혀 있음';

  @override
  String get itemBoxClosedBody =>
      '최근 산책을 불러와 스테이지로 만들 것을 고르거나, 기록된 모든 산책을 한 번에 가져오세요.';

  @override
  String get loadWorkouts => '운동 불러오기';

  @override
  String get loadWorkoutsCaption => '최근 25개';

  @override
  String get importEverything => '전부 가져오기';

  @override
  String get importEverythingCaption => '건강의 모든 산책';

  @override
  String get importing => '가져오는 중';

  @override
  String importingBody(int fetched, int added) {
    return '건강에서 $fetched개를 읽었고, 새 스테이지 $added개.';
  }

  @override
  String get nothingHere => '아무것도 없음';

  @override
  String get noWalksInHealth => '건강에서 산책을 찾지 못했습니다.';

  @override
  String get importedLabel => '가져옴';

  @override
  String newStagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '새 스테이지 $count개',
    );
    return '$_temp0';
  }

  @override
  String get pickWalks => '산책 고르기';

  @override
  String saveWalksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개 저장',
    );
    return '$_temp0';
  }

  @override
  String get tapToSelect => '운동을 탭하여 선택';

  @override
  String get addAsStages => '스테이지로 추가';

  @override
  String get saveWalksSemantics => '산책 저장';

  @override
  String get stageCleared => '스테이지 클리어됨';

  @override
  String workoutSemantics(String date) {
    return '$date 운동';
  }

  @override
  String workoutImportedSemantics(String date) {
    return '$date, 이미 스테이지임';
  }

  @override
  String get actRecording => 'ACT 2 · 기록 중';

  @override
  String get actClear => 'ACT 2 · 클리어';

  @override
  String get actReady => 'ACT 2 · 준비';

  @override
  String get liveLabel => '라이브';

  @override
  String get resultLabel => '결과';

  @override
  String get pressGoToStart => 'GO를 눌러 시작';

  @override
  String get metresNewUnit => 'm 새 길';

  @override
  String get startRecording => '기록 시작';

  @override
  String get stopLabel => '정지';

  @override
  String get finishStage => '스테이지 종료';

  @override
  String get stopRecording => '기록 정지';

  @override
  String get stageClearButton => '스테이지 클리어!';

  @override
  String get viewResult => '결과 보기';

  @override
  String get viewFinishedRecording => '기록 결과 보기';

  @override
  String percentNewGround(int percent) {
    return '새로운 길 $percent퍼센트';
  }

  @override
  String get settingsLabel => '설정';

  @override
  String get optionsTitle => '옵션';

  @override
  String get optionsIntro => '지도에 산책이 표시되는 방식을 조정합니다. 변경은 즉시 모든 곳에 적용됩니다.';

  @override
  String get trailWidth => '경로 두께';

  @override
  String get trailWidthCaption => '각 산책 선의 두께.';

  @override
  String get trailWidthSemantics => '경로 두께';

  @override
  String pxValue(int value) {
    return '$value px';
  }

  @override
  String get revealRadius => '탐험 반경';

  @override
  String get revealRadiusCaption =>
      '산책 주변 얼마나 멀리까지 안개가 걷히는지. 클수록 도시가 빨리 채워집니다.';

  @override
  String get revealRadiusSemantics => '탐험 반경';

  @override
  String mValue(int value) {
    return '$value m';
  }

  @override
  String get resetToDefaults => '기본값으로 되돌리기';

  @override
  String get mapDataLabel => '지도 데이터';

  @override
  String get mapDataBody => '도시를 한 번 다운로드하면 지도가 즉시 뜨고 오프라인에서도 됩니다.';

  @override
  String get downloadMapArea => '지도 영역 다운로드';

  @override
  String get offlineTiles => '오프라인 타일';

  @override
  String get demoData => '데모 데이터';

  @override
  String demoDataBody(int walks, int spots) {
    return '거의 다 탐험한 도쿄 미리보기: 23개 구 전체에 생성된 산책 $walks회와 유명 스팟 $spots곳. 실제 산책은 그대로입니다.';
  }

  @override
  String demoDataLoaded(int count) {
    return '데모 산책 $count회 로드됨. 삭제하면 내 스테이지로 돌아갑니다.';
  }

  @override
  String get fillTokyo => '도쿄 채우기';

  @override
  String get fillTokyoCaption => '생성된 산책과 스팟';

  @override
  String get removeDemoData => '데모 데이터 삭제';

  @override
  String get removeDemoDataCaption => '실제 산책은 유지';

  @override
  String get skip => '건너뛰기';

  @override
  String get frameYourCity => '도시를 틀에 맞추기';

  @override
  String get mapDataOffline => '지도 데이터 · 오프라인';

  @override
  String get downloadArea => '영역 다운로드';

  @override
  String get downloadIntroFirstRun =>
      '걷는 도시를 저장하면 지도가 즉시 뜨고 신호 없이도 됩니다. 나중에 옵션에서도 할 수 있습니다.';

  @override
  String get downloadIntro => '금색 틀 안의 타일이 이 휴대폰에 저장됩니다.';

  @override
  String downloadCancelCaption(int done, int total, String bytes) {
    return '$done / $total 타일 · $bytes';
  }

  @override
  String get tilesUnit => '타일';

  @override
  String get downloadUnit => '다운로드';

  @override
  String get storedUnit => '저장됨';

  @override
  String get doneLabel => '완료';

  @override
  String get areaStored => '영역 저장됨';

  @override
  String get tooBig => '너무 큼';

  @override
  String get zoomInALittle => '조금 확대하세요';

  @override
  String get downloadAnotherArea => '다른 영역 다운로드';

  @override
  String get downloadLabel => '다운로드';

  @override
  String get frameSmallerArea => '더 작은 영역을 잡으세요';

  @override
  String get zoomRangeCaption => '틀 안의 줌 0~14';

  @override
  String get downloadAreaSemantics => '영역 다운로드';

  @override
  String areasStored(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '영역 $count개 저장됨',
    );
    return '$_temp0';
  }

  @override
  String get clearMapData => '지도 데이터 삭제';

  @override
  String freesBytes(String bytes) {
    return '$bytes 확보';
  }

  @override
  String get downloading => '다운로드 중';

  @override
  String get downloadProgressSemantics => '다운로드 진행률';

  @override
  String percentValue(int percent) {
    return '$percent퍼센트';
  }

  @override
  String areaName(int number) {
    return '영역 $number';
  }

  @override
  String get graphicsLabel => '그래픽';

  @override
  String get graphicsBody =>
      '3D 도시를 그리는 방식. 고급 모드는 Giro가 직접 건물을 그려 태양 그림자, 건물 종류별 재질, 거리 위 그림자를 표현합니다. 실험적 기능이며 배터리를 더 씁니다.';

  @override
  String get graphicsClassic => '클래식';

  @override
  String get graphicsClassicCaption => '장난감 도시, GPU 부담 적음';

  @override
  String get graphicsAdvanced => '고급';

  @override
  String get graphicsAdvancedCaption => '태양 그림자와 재질(베타)';

  @override
  String get graphicsSemantics => '그래픽 모드';
}
