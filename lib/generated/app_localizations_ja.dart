// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get back => '◀  戻る';

  @override
  String get cancel => 'キャンセル';

  @override
  String get kmUnit => 'KM';

  @override
  String get kmUnitLower => 'km';

  @override
  String get perKmUnit => '/km';

  @override
  String get zoneChip => 'ゾーン1 · 東京';

  @override
  String get optionsSemantics => 'オプション';

  @override
  String get loadingMap => '地図を読み込み中';

  @override
  String get loadingMapSemantics => '地図を読み込み中';

  @override
  String get spotMarkerSemantics => 'スポット';

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
    return '$hours時間$minutes分';
  }

  @override
  String durationMinutes(int minutes) {
    return '$minutes分';
  }

  @override
  String walksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count回の散歩',
    );
    return '$_temp0';
  }

  @override
  String spotsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'スポット$count件',
    );
    return '$_temp0';
  }

  @override
  String placesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countか所',
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
  String get homeStageLabel => 'ステージ: 東京 · 今週';

  @override
  String get goLabel => 'GO!';

  @override
  String get goCaption => '散歩を記録';

  @override
  String get goSemantics => '記録';

  @override
  String get importLabel => 'インポート';

  @override
  String get importCaption => 'ヘルスケア';

  @override
  String get spotsLabel => 'スポット';

  @override
  String get spotsSemantics => '場所';

  @override
  String get stagesLabel => 'ステージ';

  @override
  String get stagesCaption => 'すべての散歩';

  @override
  String get stageSelect => 'ステージセレクト';

  @override
  String stagesTitle(int count) {
    return '東京 · $countステージ';
  }

  @override
  String stageCardTitle(int day) {
    return 'ステージ $day';
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
    return 'ステージ $date、$distance、ランク$rank';
  }

  @override
  String get stageClear => 'ステージクリア!';

  @override
  String get timeLabel => '時間';

  @override
  String get paceLabel => 'ペース';

  @override
  String paceValue(String pace) {
    return '$pace /KM';
  }

  @override
  String get newGroundLabel => '新しい道';

  @override
  String newGroundValue(String km, int percent) {
    return '+$km km · $percent%';
  }

  @override
  String get noSpotsOnStage => 'このステージにスポットはありません';

  @override
  String get spotsHeader => 'スポット';

  @override
  String get holdToMarkOne => '地図を長押しして登録できます。';

  @override
  String get backToStageSelect => 'ステージセレクトへ戻る';

  @override
  String get spotCollection => 'スポットコレクション';

  @override
  String spotsTitle(int count) {
    return 'スポット $count件';
  }

  @override
  String get spotsHint => '地図を長押しでスポットを登録。スワイプで削除できます。';

  @override
  String spotSemantics(String name) {
    return 'スポット $name';
  }

  @override
  String spotMeta(String date, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count回の散歩',
    );
    return '$dateに登録 · $_temp0で訪問';
  }

  @override
  String get markASpot => 'スポットを登録';

  @override
  String get markASpotBody => 'この場所に名前をつけましょう。近くを通った散歩がスポットを訪問したことになります。';

  @override
  String get spotNameHint => 'スポット名';

  @override
  String get markIt => '登録!';

  @override
  String get addSemantics => '追加';

  @override
  String get itemBoxHealth => 'アイテムボックス · ヘルスケア';

  @override
  String get importWalks => '散歩をインポート';

  @override
  String get importIntro => 'ウォッチで記録した散歩がステージになります。対応ウォッチのルートのみ地図付きです。';

  @override
  String get healthDenied => 'ヘルスケアへのアクセスが拒否されました';

  @override
  String get healthDeniedBody => 'ヘルスケアアプリでGiroにワークアウトの読み取りを許可してから戻ってきてください。';

  @override
  String get itemBoxClosed => 'アイテムボックスは閉じています';

  @override
  String get itemBoxClosedBody =>
      '最近の散歩を読み込んでステージにしたいものを選ぶか、記録したすべての散歩を一度にインポートします。';

  @override
  String get loadWorkouts => 'ワークアウトを読み込む';

  @override
  String get loadWorkoutsCaption => '最新の25件';

  @override
  String get importEverything => 'すべてインポート';

  @override
  String get importEverythingCaption => 'ヘルスケアの全散歩';

  @override
  String get importing => 'インポート中';

  @override
  String importingBody(int fetched, int added) {
    return 'ヘルスケアから$fetched件を読み込み、新しいステージは$added件。';
  }

  @override
  String get nothingHere => '何もありません';

  @override
  String get noWalksInHealth => 'ヘルスケアに散歩が見つかりません。';

  @override
  String get importedLabel => 'インポート済み';

  @override
  String newStagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '新しいステージ$count件',
    );
    return '$_temp0';
  }

  @override
  String get pickWalks => '散歩を選ぶ';

  @override
  String saveWalksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count件を保存',
    );
    return '$_temp0';
  }

  @override
  String get tapToSelect => 'タップして選択';

  @override
  String get addAsStages => 'ステージとして追加';

  @override
  String get saveWalksSemantics => '散歩を保存';

  @override
  String get stageCleared => 'ステージクリア済み';

  @override
  String workoutSemantics(String date) {
    return '$dateのワークアウト';
  }

  @override
  String workoutImportedSemantics(String date) {
    return '$date、ステージ登録済み';
  }

  @override
  String get actRecording => 'ACT 2 · 記録中';

  @override
  String get actClear => 'ACT 2 · クリア';

  @override
  String get actReady => 'ACT 2 · 準備完了';

  @override
  String get liveLabel => 'ライブ';

  @override
  String get resultLabel => 'リザルト';

  @override
  String get pressGoToStart => 'GOを押してスタート';

  @override
  String get metresNewUnit => 'm 新規';

  @override
  String get startRecording => '記録を開始';

  @override
  String get stopLabel => 'ストップ';

  @override
  String get finishStage => 'ステージ終了';

  @override
  String get stopRecording => '記録を停止';

  @override
  String get stageClearButton => 'ステージクリア!';

  @override
  String get viewResult => '結果を見る';

  @override
  String get viewFinishedRecording => '記録結果を見る';

  @override
  String percentNewGround(int percent) {
    return '新しい道 $percentパーセント';
  }

  @override
  String get settingsLabel => '設定';

  @override
  String get optionsTitle => 'オプション';

  @override
  String get optionsIntro => '地図での散歩の見え方を調整します。変更はすぐにすべてに反映されます。';

  @override
  String get trailWidth => '軌跡の太さ';

  @override
  String get trailWidthCaption => '散歩の線の太さ。';

  @override
  String get trailWidthSemantics => '軌跡の太さ';

  @override
  String pxValue(int value) {
    return '$value px';
  }

  @override
  String get revealRadius => '探索範囲';

  @override
  String get revealRadiusCaption => '散歩の周りでどこまで霧が晴れるか。大きいほど街が早く埋まります。';

  @override
  String get revealRadiusSemantics => '探索範囲';

  @override
  String mValue(int value) {
    return '$value m';
  }

  @override
  String get resetToDefaults => '初期設定に戻す';

  @override
  String get mapDataLabel => '地図データ';

  @override
  String get mapDataBody => '街を一度ダウンロードすれば、地図は即座に表示されオフラインでも使えます。';

  @override
  String get downloadMapArea => '地図エリアをダウンロード';

  @override
  String get offlineTiles => 'オフラインタイル';

  @override
  String get demoData => 'デモデータ';

  @override
  String demoDataBody(int walks, int spots) {
    return 'ほぼ探索し尽くした東京をプレビュー: 23区すべてに$walks件の生成散歩と$spots件の有名スポット。実際の散歩はそのままです。';
  }

  @override
  String demoDataLoaded(int count) {
    return 'デモ散歩$count件を読み込み中。削除すると自分のステージに戻ります。';
  }

  @override
  String get fillTokyo => '東京を埋める';

  @override
  String get fillTokyoCaption => '生成した散歩とスポット';

  @override
  String get removeDemoData => 'デモデータを削除';

  @override
  String get removeDemoDataCaption => '実際の散歩は残ります';

  @override
  String get skip => 'スキップ';

  @override
  String get frameYourCity => '街を枠に収める';

  @override
  String get mapDataOffline => '地図データ · オフライン';

  @override
  String get downloadArea => 'エリアをダウンロード';

  @override
  String get downloadIntroFirstRun =>
      '歩く街を保存すると、地図が即座に表示され電波がなくても使えます。あとでオプションからも設定できます。';

  @override
  String get downloadIntro => '金色の枠内のタイルがこの端末に保存されます。';

  @override
  String downloadCancelCaption(int done, int total, String bytes) {
    return '$done / $total タイル · $bytes';
  }

  @override
  String get tilesUnit => 'タイル';

  @override
  String get downloadUnit => 'ダウンロード';

  @override
  String get storedUnit => '保存済み';

  @override
  String get doneLabel => '完了';

  @override
  String get areaStored => 'エリアを保存しました';

  @override
  String get tooBig => '大きすぎます';

  @override
  String get zoomInALittle => '少しズームイン';

  @override
  String get downloadAnotherArea => '別のエリアをダウンロード';

  @override
  String get downloadLabel => 'ダウンロード';

  @override
  String get frameSmallerArea => 'もっと狭い範囲にしてください';

  @override
  String get zoomRangeCaption => '枠内のズーム0〜14';

  @override
  String get downloadAreaSemantics => 'エリアをダウンロード';

  @override
  String areasStored(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countエリアを保存済み',
    );
    return '$_temp0';
  }

  @override
  String get clearMapData => '地図データを削除';

  @override
  String freesBytes(String bytes) {
    return '$bytesを解放';
  }

  @override
  String get downloading => 'ダウンロード中';

  @override
  String get downloadProgressSemantics => 'ダウンロードの進行状況';

  @override
  String percentValue(int percent) {
    return '$percentパーセント';
  }

  @override
  String areaName(int number) {
    return 'エリア $number';
  }
}
