// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get back => '◀  返回';

  @override
  String get cancel => '取消';

  @override
  String get kmUnit => 'KM';

  @override
  String get kmUnitLower => 'km';

  @override
  String get perKmUnit => '/km';

  @override
  String get zoneChip => '第1区 · 东京';

  @override
  String get optionsSemantics => '选项';

  @override
  String get loadingMap => '地图加载中';

  @override
  String get loadingMapSemantics => '地图加载中';

  @override
  String get spotMarkerSemantics => '地点';

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
    return '$hours小时$minutes分';
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
      other: '$count次散步',
    );
    return '$_temp0';
  }

  @override
  String spotsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count个地点',
    );
    return '$_temp0';
  }

  @override
  String placesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count个地方',
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
  String get homeStageLabel => '关卡: 东京 · 本周';

  @override
  String get goLabel => 'GO!';

  @override
  String get goCaption => '记录散步';

  @override
  String get goSemantics => '记录';

  @override
  String get importLabel => '导入';

  @override
  String get importCaption => '健康';

  @override
  String get spotsLabel => '地点';

  @override
  String get spotsSemantics => '地方';

  @override
  String get stagesLabel => '关卡';

  @override
  String get stagesCaption => '全部散步';

  @override
  String get stageSelect => '选择关卡';

  @override
  String stagesTitle(int count) {
    return '东京 · $count个关卡';
  }

  @override
  String stageCardTitle(int day) {
    return '关卡 $day';
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
    return '关卡 $date，$distance，评级$rank';
  }

  @override
  String get stageClear => '关卡通过!';

  @override
  String get timeLabel => '时间';

  @override
  String get paceLabel => '配速';

  @override
  String paceValue(String pace) {
    return '$pace /KM';
  }

  @override
  String get newGroundLabel => '新路线';

  @override
  String newGroundValue(String km, int percent) {
    return '+$km km · $percent%';
  }

  @override
  String get noSpotsOnStage => '本关卡没有地点';

  @override
  String get spotsHeader => '地点';

  @override
  String get holdToMarkOne => '长按地图即可标记一个。';

  @override
  String get backToStageSelect => '返回选择关卡';

  @override
  String get spotCollection => '地点收藏';

  @override
  String spotsTitle(int count) {
    return '$count个地点';
  }

  @override
  String get spotsHint => '长按地图标记地点，滑动即可删除。';

  @override
  String spotSemantics(String name) {
    return '地点 $name';
  }

  @override
  String spotMeta(String date, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count次散步',
    );
    return '$date标记 · $_temp0到访';
  }

  @override
  String get markASpot => '标记地点';

  @override
  String get markASpotBody => '给这个地方起个名字。经过它的散步会算作到访。';

  @override
  String get spotNameHint => '地点名称';

  @override
  String get markIt => '标记!';

  @override
  String get addSemantics => '添加';

  @override
  String get itemBoxHealth => '道具箱 · 健康';

  @override
  String get importWalks => '导入散步';

  @override
  String get importIntro => '手表记录的散步会成为关卡。只有受支持的手表路线才带有地图。';

  @override
  String get healthDenied => '健康访问被拒绝';

  @override
  String get healthDeniedBody => '请在“健康”应用中允许Giro读取体能训练，然后返回。';

  @override
  String get itemBoxClosed => '道具箱已关闭';

  @override
  String get itemBoxClosedBody => '加载最近的散步并挑选值得成为关卡的，或一次导入全部记录过的散步。';

  @override
  String get loadWorkouts => '加载体能训练';

  @override
  String get loadWorkoutsCaption => '最近25条';

  @override
  String get importEverything => '全部导入';

  @override
  String get importEverythingCaption => '健康中的每一次散步';

  @override
  String get importing => '导入中';

  @override
  String importingBody(int fetched, int added) {
    return '已从健康读取$fetched次散步，新增关卡$added个。';
  }

  @override
  String get nothingHere => '空空如也';

  @override
  String get noWalksInHealth => '健康中没有找到散步。';

  @override
  String get importedLabel => '已导入';

  @override
  String newStagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count个新关卡',
    );
    return '$_temp0';
  }

  @override
  String get pickWalks => '挑选散步';

  @override
  String saveWalksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '保存$count次散步',
    );
    return '$_temp0';
  }

  @override
  String get tapToSelect => '点按体能训练以选择';

  @override
  String get addAsStages => '添加为关卡';

  @override
  String get saveWalksSemantics => '保存散步';

  @override
  String get stageCleared => '关卡已通过';

  @override
  String workoutSemantics(String date) {
    return '$date的体能训练';
  }

  @override
  String workoutImportedSemantics(String date) {
    return '$date，已是关卡';
  }

  @override
  String get actRecording => 'ACT 2 · 记录中';

  @override
  String get actClear => 'ACT 2 · 通过';

  @override
  String get actReady => 'ACT 2 · 准备';

  @override
  String get liveLabel => '实时';

  @override
  String get resultLabel => '结果';

  @override
  String get pressGoToStart => '按GO开始';

  @override
  String get metresNewUnit => 'm 新路';

  @override
  String get startRecording => '开始记录';

  @override
  String get stopLabel => '停止';

  @override
  String get finishStage => '结束关卡';

  @override
  String get stopRecording => '停止记录';

  @override
  String get stageClearButton => '关卡通过!';

  @override
  String get viewResult => '查看结果';

  @override
  String get viewFinishedRecording => '查看记录结果';

  @override
  String percentNewGround(int percent) {
    return '新路线 $percent%';
  }

  @override
  String get settingsLabel => '设置';

  @override
  String get optionsTitle => '选项';

  @override
  String get optionsIntro => '调整散步在地图上的显示方式。更改会立即生效。';

  @override
  String get trailWidth => '轨迹宽度';

  @override
  String get trailWidthCaption => '每次散步线条的粗细。';

  @override
  String get trailWidthSemantics => '轨迹宽度';

  @override
  String pxValue(int value) {
    return '$value px';
  }

  @override
  String get revealRadius => '探索半径';

  @override
  String get revealRadiusCaption => '散步周围多大范围的迷雾会散去。越大城市填满得越快。';

  @override
  String get revealRadiusSemantics => '探索半径';

  @override
  String mValue(int value) {
    return '$value m';
  }

  @override
  String get resetToDefaults => '恢复默认';

  @override
  String get mapDataLabel => '地图数据';

  @override
  String get mapDataBody => '下载一次你的城市，地图即刻显示并可离线使用。';

  @override
  String get downloadMapArea => '下载地图区域';

  @override
  String get offlineTiles => '离线图块';

  @override
  String get demoData => '演示数据';

  @override
  String demoDataBody(int walks, int spots) {
    return '预览几乎完全探索的东京：23个区共$walks次生成散步和$spots个著名地点。真实散步不受影响。';
  }

  @override
  String demoDataLoaded(int count) {
    return '已加载$count次演示散步。删除后回到你自己的关卡。';
  }

  @override
  String get fillTokyo => '填满东京';

  @override
  String get fillTokyoCaption => '生成的散步与地点';

  @override
  String get removeDemoData => '删除演示数据';

  @override
  String get removeDemoDataCaption => '保留真实散步';

  @override
  String get skip => '跳过';

  @override
  String get frameYourCity => '框住你的城市';

  @override
  String get mapDataOffline => '地图数据 · 离线';

  @override
  String get downloadArea => '下载区域';

  @override
  String get downloadIntroFirstRun => '保存你散步的城市，地图即刻显示且无需信号。之后也可在选项中设置。';

  @override
  String get downloadIntro => '金色框内的图块将保存在此手机上。';

  @override
  String downloadCancelCaption(int done, int total, String bytes) {
    return '$done / $total 图块 · $bytes';
  }

  @override
  String get tilesUnit => '图块';

  @override
  String get downloadUnit => '下载';

  @override
  String get storedUnit => '已保存';

  @override
  String get doneLabel => '完成';

  @override
  String get areaStored => '区域已保存';

  @override
  String get tooBig => '太大了';

  @override
  String get zoomInALittle => '稍微放大';

  @override
  String get downloadAnotherArea => '下载另一个区域';

  @override
  String get downloadLabel => '下载';

  @override
  String get frameSmallerArea => '框选更小的区域';

  @override
  String get zoomRangeCaption => '框内缩放级别0到14';

  @override
  String get downloadAreaSemantics => '下载区域';

  @override
  String areasStored(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已保存$count个区域',
    );
    return '$_temp0';
  }

  @override
  String get clearMapData => '清除地图数据';

  @override
  String freesBytes(String bytes) {
    return '释放$bytes';
  }

  @override
  String get downloading => '下载中';

  @override
  String get downloadProgressSemantics => '下载进度';

  @override
  String percentValue(int percent) {
    return '$percent%';
  }

  @override
  String areaName(int number) {
    return '区域 $number';
  }

  @override
  String get graphicsLabel => '画面';

  @override
  String get graphicsBody =>
      '3D 城市的绘制方式。高级模式由 Giro 自行绘制建筑，带有太阳阴影、按建筑类型区分的材质和街道上的阴影。实验性功能，更耗电。';

  @override
  String get graphicsClassic => '经典';

  @override
  String get graphicsClassicCaption => '玩具城市，GPU 负担小';

  @override
  String get graphicsAdvanced => '高级';

  @override
  String get graphicsAdvancedCaption => '太阳阴影与材质（测试版）';

  @override
  String get graphicsSemantics => '画面模式';
}
