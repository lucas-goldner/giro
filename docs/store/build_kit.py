#!/usr/bin/env python3
"""Builds docs/store/index.html: everything for App Store Connect in nine
languages, with copy buttons and character counts.

    python3 docs/store/build_kit.py
    node tool/store_kit.mjs      # the screenshots the page links to

The texts live in this file so a change is one edit and the counts are
recomputed against Apple's limits (name 30, subtitle 30, keywords 100,
promotional text 170, description 4000, what's new 4000)."""
import html
import json
import os

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
VERSION = '1.1.0'

LANGS = [
    ('en', 'English (U.S.)', 'English'),
    ('ja', '日本語', '日本語'),
    ('zh', '简体中文', '简体中文'),
    ('ko', '한국어', '한국어'),
    ('de', 'Deutsch', 'Deutsch'),
    ('fr', 'Français', 'Français'),
    ('es', 'Español (México / España)', 'Español'),
    ('it', 'Italiano', 'Italiano'),
    ('pt', 'Português (Brasil / Portugal)', 'Português'),
]

NAME = {
    'en': 'Giro: Walk & Uncover Your City',
    'ja': 'Giro：歩いて街を塗りつぶす',
    'zh': 'Giro：走遍你的城市',
    'ko': 'Giro: 걸으며 도시를 밝히다',
    'de': 'Giro: Deck deine Stadt auf',
    'fr': 'Giro : Dévoile ta ville à pied',
    'es': 'Giro: Descubre tu ciudad a pie',
    'it': 'Giro: Scopri la città a piedi',
    'pt': 'Giro: Descubra sua cidade a pé',
}
SUBTITLE = {
    'en': 'Fog of war for your walks',
    'ja': '歩いた道だけ色がつく地図',
    'zh': '走过的路才会上色的地图',
    'ko': '걸은 길만 색칠되는 지도',
    'de': 'Lauf deine Stadt frei',
    'fr': 'Dévoile la carte en marchant',
    'es': 'El mapa se pinta al caminar',
    'it': 'La mappa si colora camminando',
    'pt': 'O mapa se pinta ao caminhar',
}
KEYWORDS = {
    'en': 'walk,walking,explore,fog of war,map,tokyo,steps,pedometer,hike,stroll,gps,tracker,route,game',
    'ja': '散歩,ウォーキング,探索,地図,東京,歩数,街歩き,ゲーム,GPS',
    'zh': '散步,步行,探索,地图,东京,步数,记录,游戏,GPS',
    'ko': '산책,걷기,탐험,지도,도쿄,걸음,기록,게임,GPS',
    'de': 'spaziergang,gehen,laufen,erkunden,karte,tokio,schritte,wandern,gps,tracker,route,spiel,stadt',
    'fr': 'marche,marcher,explorer,carte,tokyo,pas,podomètre,balade,randonnée,gps,trajet,jeu,ville',
    'es': 'caminar,paseo,explorar,mapa,tokio,pasos,podómetro,senderismo,gps,ruta,juego,ciudad,andar',
    'it': 'camminare,passeggiata,esplorare,mappa,tokyo,passi,contapassi,trekking,gps,percorso,gioco,città',
    'pt': 'caminhar,caminhada,explorar,mapa,tóquio,passos,pedômetro,trilha,gps,rota,jogo,cidade,andar',
}
PROMO = {
    'en': 'New: the toy city. 3D buildings, trees and landmarks, white clay until you walk them. Offline maps, import every walk from Health, nine languages.',
    'ja': '新登場：トイシティ。3Dの建物、木、ランドマークが歩くまで白い模型のまま。オフライン地図、ヘルスケアからの一括インポート、9言語に対応。',
    'zh': '新功能：玩具城市。3D 建筑、树木和地标在你走过之前都是白色模型。离线地图、一键导入健康中的全部散步、支持九种语言。',
    'ko': '새 기능: 장난감 도시. 3D 건물, 나무, 랜드마크가 걷기 전까지는 하얀 모형. 오프라인 지도, 건강 앱의 모든 산책 가져오기, 9개 언어.',
    'de': 'Neu: die Spielzeugstadt. 3D-Gebäude, Bäume und Wahrzeichen bleiben weißer Ton, bis du dort warst. Offline-Karten, Import aus Health, neun Sprachen.',
    'fr': 'Nouveau : la ville miniature. Immeubles 3D, arbres et monuments restent en argile blanche jusqu’à ton passage. Cartes hors ligne, import depuis Santé, neuf langues.',
    'es': 'Nuevo: la ciudad de juguete. Edificios 3D, árboles y monumentos en arcilla blanca hasta que pases. Mapas sin conexión, importa todo desde Salud, nueve idiomas.',
    'it': 'Novità: la città giocattolo. Edifici 3D, alberi e monumenti restano argilla bianca finché non ci passi. Mappe offline, importa tutto da Salute, nove lingue.',
    'pt': 'Novo: a cidade de brinquedo. Prédios 3D, árvores e marcos ficam em argila branca até você passar. Mapas offline, importe tudo do Saúde, nove idiomas.',
}
DESCRIPTION = {
    'en': """Walk, and the map comes to life.

Giro is a walking game for your city. Every street you walk is painted onto a 3D toy-town map. Everything you have not walked yet stays white clay. The more you explore, the more of the city appears.

EVERY WALK IS A STAGE
Record a walk with GO!, or import the ones your watch already saved. Each walk gets a rank from S to C for how much new ground it covered.

A CITY MADE OF TOYS
Pastel buildings with lit windows, trees in the parks and along the streets, and landmarks you will recognise: Tokyo Tower, the Skytree, torii at shrines, pagodas at temples. All of it white until you walk past.

SPOTS
Press and hold the map to mark a place. Walks that pass it collect it.

WORKS OFFLINE
Download your city once. The map is instant and works without a signal, and every walk is named after where it happened, straight from the offline map.

MADE FOR WALKERS
• Import every walk from Apple Health in one go
• Live timer, pace and a ring that fills with new ground
• Sliders for trail width and reveal radius
• In nine languages
• No account, no ads, no tracking. Your walks stay on your phone.

Map data © OpenStreetMap contributors, tiles by OpenFreeMap.""",
    'ja': """歩けば、地図が色づく。

Giroは、あなたの街を舞台にした散歩ゲームです。歩いた道が3Dのおもちゃのような街に塗られ、まだ歩いていない場所は白い模型のまま。探索するほど、街が姿を現します。

散歩はすべてステージ
GO!で散歩を記録するか、ウォッチに保存済みの散歩をインポート。新しい道をどれだけ歩いたかで、SからCのランクがつきます。

おもちゃの街
窓に明かりのともるパステルカラーの建物、公園や通りの木々、そして東京タワー、スカイツリー、神社の鳥居、お寺の五重塔といったランドマーク。すべて、歩いて通るまでは白いままです。

スポット
地図を長押しして場所を登録。近くを通った散歩がスポットを集めます。

オフラインで動作
街を一度ダウンロードすれば、地図は即座に表示され、電波がなくても使えます。散歩には歩いた場所の名前が、オフライン地図からつけられます。

歩く人のために
・ヘルスケアからすべての散歩を一括インポート
・ライブのタイマー、ペース、新しい道で満ちていくリング
・軌跡の太さと探索範囲のスライダー
・9言語に対応
・アカウント不要、広告なし、トラッキングなし。散歩の記録は端末の中だけに。

地図データ © OpenStreetMap contributors、タイル提供 OpenFreeMap。""",
    'zh': """走起来，地图就活了。

Giro 是属于你城市的散步游戏。你走过的每条街都会被涂到一张 3D 玩具小镇地图上，还没走过的地方则保持白色模型。探索得越多，城市显现得越多。

每次散步都是一关
用 GO! 记录散步，或导入手表已保存的散步。每次散步都按走了多少新路线，评定 S 到 C 级。

玩具做的城市
亮着窗灯的粉彩建筑、公园和街道旁的树木，以及一眼就能认出的地标：东京塔、晴空塔、神社的鸟居、寺庙的佛塔。走过之前，它们都是白色的。

地点
长按地图标记一个地方。经过的散步会把它收集起来。

离线可用
下载一次你的城市，地图即刻显示，没有信号也能用。每次散步都会从离线地图中得到它发生地点的名字。

为走路的人而做
• 一次导入 Apple 健康中的所有散步
• 实时计时、配速，以及被新路线填满的圆环
• 轨迹宽度与探索半径的滑块
• 支持九种语言
• 无账号、无广告、无追踪。你的散步只留在你的手机上。

地图数据 © OpenStreetMap 贡献者，图块来自 OpenFreeMap。""",
    'ko': """걸으면 지도가 살아납니다.

Giro는 내 도시를 무대로 하는 산책 게임입니다. 걸은 거리마다 3D 장난감 마을 지도에 색이 칠해지고, 아직 걷지 않은 곳은 하얀 모형으로 남습니다. 탐험할수록 도시가 더 드러납니다.

모든 산책이 스테이지
GO!로 산책을 기록하거나, 워치에 이미 저장된 산책을 가져오세요. 새로운 길을 얼마나 걸었는지에 따라 S부터 C까지 랭크가 매겨집니다.

장난감으로 만든 도시
창에 불이 켜진 파스텔 건물, 공원과 거리의 나무, 그리고 한눈에 알아볼 랜드마크: 도쿄 타워, 스카이트리, 신사의 도리이, 절의 탑. 걸어서 지나가기 전까지는 모두 하얗습니다.

스팟
지도를 길게 눌러 장소를 표시하세요. 지나가는 산책이 스팟을 모읍니다.

오프라인에서도
도시를 한 번만 다운로드하세요. 지도가 바로 뜨고 신호 없이도 작동하며, 모든 산책에는 오프라인 지도에서 가져온 장소 이름이 붙습니다.

걷는 사람을 위해
• Apple 건강의 모든 산책을 한 번에 가져오기
• 실시간 타이머, 페이스, 새 길로 차오르는 링
• 경로 두께와 탐험 반경 슬라이더
• 9개 언어 지원
• 계정 없음, 광고 없음, 추적 없음. 산책 기록은 내 휴대폰에만.

지도 데이터 © OpenStreetMap 기여자, 타일 제공 OpenFreeMap.""",
    'de': """Geh los, und die Karte erwacht.

Giro ist ein Spaziergang-Spiel für deine Stadt. Jede Straße, die du gehst, wird auf eine 3D-Spielzeugstadt gemalt. Alles, wo du noch nicht warst, bleibt weißer Ton. Je mehr du erkundest, desto mehr Stadt erscheint.

JEDER SPAZIERGANG IST EINE STAGE
Nimm einen Spaziergang mit GO! auf oder importiere die, die deine Uhr schon gespeichert hat. Jeder bekommt einen Rang von S bis C dafür, wie viel neues Terrain er abgedeckt hat.

EINE STADT AUS SPIELZEUG
Pastellfarbene Häuser mit erleuchteten Fenstern, Bäume in Parks und an Straßen, und Wahrzeichen, die du erkennst: Tokyo Tower, Skytree, Torii an Schreinen, Pagoden an Tempeln. Alles weiß, bis du vorbeigehst.

SPOTS
Halte die Karte gedrückt, um einen Ort zu markieren. Spaziergänge, die daran vorbeiführen, sammeln ihn ein.

FUNKTIONIERT OFFLINE
Lade deine Stadt einmal herunter. Die Karte ist sofort da und funktioniert ohne Empfang, und jeder Spaziergang trägt den Namen des Orts, an dem er stattfand, direkt aus der Offline-Karte.

FÜR LEUTE, DIE GEHEN
• Jeden Spaziergang aus Apple Health auf einmal importieren
• Live-Timer, Tempo und ein Ring, der sich mit neuem Terrain füllt
• Regler für Spurbreite und Aufdeck-Radius
• In neun Sprachen
• Kein Konto, keine Werbung, kein Tracking. Deine Spaziergänge bleiben auf deinem Telefon.

Kartendaten © OpenStreetMap-Mitwirkende, Kacheln von OpenFreeMap.""",
    'fr': """Marche, et la carte prend vie.

Giro est un jeu de marche pour ta ville. Chaque rue que tu parcours est peinte sur une carte en 3D, façon ville miniature. Tout ce que tu n’as pas encore marché reste en argile blanche. Plus tu explores, plus la ville apparaît.

CHAQUE MARCHE EST UN STAGE
Enregistre une marche avec GO!, ou importe celles que ta montre a déjà sauvegardées. Chaque marche reçoit un rang de S à C selon le terrain inédit qu’elle a couvert.

UNE VILLE EN JOUETS
Des immeubles pastel aux fenêtres allumées, des arbres dans les parcs et le long des rues, et des monuments que tu reconnaîtras : la tour de Tokyo, la Skytree, les torii des sanctuaires, les pagodes des temples. Tout en blanc jusqu’à ton passage.

SPOTS
Appuie longuement sur la carte pour marquer un lieu. Les marches qui passent à côté le collectent.

FONCTIONNE HORS LIGNE
Télécharge ta ville une fois. La carte est instantanée, fonctionne sans réseau, et chaque marche porte le nom de l’endroit où elle a eu lieu, tiré de la carte hors ligne.

FAIT POUR LES MARCHEURS
• Importe toutes tes marches depuis Apple Santé d’un coup
• Chrono en direct, allure et un anneau qui se remplit de terrain inédit
• Réglages pour l’épaisseur du tracé et le rayon de découverte
• En neuf langues
• Pas de compte, pas de pub, pas de pistage. Tes marches restent sur ton téléphone.

Données cartographiques © contributeurs OpenStreetMap, tuiles par OpenFreeMap.""",
    'es': """Camina y el mapa cobra vida.

Giro es un juego de caminar para tu ciudad. Cada calle que recorres se pinta en un mapa 3D de ciudad de juguete. Todo lo que aún no has caminado sigue en arcilla blanca. Cuanto más exploras, más ciudad aparece.

CADA PASEO ES UNA FASE
Graba un paseo con GO! o importa los que tu reloj ya guardó. Cada paseo recibe un rango de S a C según cuánto terreno nuevo cubrió.

UNA CIUDAD DE JUGUETE
Edificios pastel con ventanas encendidas, árboles en los parques y las calles, y monumentos que reconocerás: la Torre de Tokio, la Skytree, torii en los santuarios, pagodas en los templos. Todo en blanco hasta que pasas por delante.

SPOTS
Mantén pulsado el mapa para marcar un lugar. Los paseos que pasan por ahí lo recogen.

FUNCIONA SIN CONEXIÓN
Descarga tu ciudad una vez. El mapa es instantáneo y funciona sin cobertura, y cada paseo lleva el nombre del lugar donde ocurrió, sacado del mapa sin conexión.

HECHO PARA CAMINANTES
• Importa todos tus paseos de Apple Salud de una vez
• Cronómetro en vivo, ritmo y un anillo que se llena de terreno nuevo
• Ajustes de grosor del trazo y radio de descubrimiento
• En nueve idiomas
• Sin cuenta, sin anuncios, sin rastreo. Tus paseos se quedan en tu teléfono.

Datos del mapa © colaboradores de OpenStreetMap, teselas de OpenFreeMap.""",
    'it': """Cammina, e la mappa prende vita.

Giro è un gioco di camminate per la tua città. Ogni strada che percorri viene dipinta su una mappa 3D a forma di città giocattolo. Tutto ciò che non hai ancora camminato resta argilla bianca. Più esplori, più città appare.

OGNI PASSEGGIATA È UNO STAGE
Registra una passeggiata con GO! o importa quelle che il tuo orologio ha già salvato. Ogni passeggiata riceve un rango da S a C per quanto terreno nuovo ha coperto.

UNA CITTÀ DI GIOCATTOLI
Palazzi pastello con le finestre accese, alberi nei parchi e lungo le strade, e monumenti che riconoscerai: la Tokyo Tower, lo Skytree, i torii dei santuari, le pagode dei templi. Tutto bianco finché non ci passi davanti.

SPOT
Tieni premuta la mappa per segnare un luogo. Le passeggiate che ci passano accanto lo raccolgono.

FUNZIONA OFFLINE
Scarica la tua città una volta sola. La mappa è istantanea, funziona senza segnale, e ogni passeggiata porta il nome del luogo in cui è avvenuta, preso dalla mappa offline.

FATTO PER CHI CAMMINA
• Importa tutte le passeggiate da Apple Salute in un colpo solo
• Timer dal vivo, passo e un anello che si riempie di terreno nuovo
• Regolazioni per spessore della traccia e raggio di scoperta
• In nove lingue
• Nessun account, nessuna pubblicità, nessun tracciamento. Le tue passeggiate restano sul tuo telefono.

Dati della mappa © collaboratori OpenStreetMap, tile di OpenFreeMap.""",
    'pt': """Caminhe, e o mapa ganha vida.

Giro é um jogo de caminhada para a sua cidade. Cada rua que você percorre é pintada em um mapa 3D de cidade de brinquedo. Tudo o que você ainda não caminhou fica em argila branca. Quanto mais você explora, mais cidade aparece.

CADA CAMINHADA É UMA FASE
Grave uma caminhada com GO! ou importe as que seu relógio já salvou. Cada caminhada recebe um rank de S a C conforme quanto terreno novo cobriu.

UMA CIDADE DE BRINQUEDO
Prédios em tons pastel com janelas acesas, árvores nos parques e ao longo das ruas, e marcos que você vai reconhecer: a Torre de Tóquio, a Skytree, torii nos santuários, pagodes nos templos. Tudo branco até você passar por ali.

SPOTS
Toque e segure no mapa para marcar um lugar. As caminhadas que passam por ele o coletam.

FUNCIONA OFFLINE
Baixe sua cidade uma vez. O mapa é instantâneo, funciona sem sinal, e cada caminhada recebe o nome do lugar onde aconteceu, direto do mapa offline.

FEITO PARA QUEM CAMINHA
• Importe todas as caminhadas do Apple Saúde de uma vez
• Cronômetro ao vivo, ritmo e um anel que se enche de terreno novo
• Ajustes de espessura da trilha e raio de descoberta
• Em nove idiomas
• Sem conta, sem anúncios, sem rastreamento. Suas caminhadas ficam no seu telefone.

Dados do mapa © colaboradores do OpenStreetMap, tiles do OpenFreeMap.""",
}
WHATS_NEW = {
    'en': """Version 1.1.0
• The toy city: 3D pastel buildings with lit windows, trees in parks and along streets, and landmark models at your spots. White clay until you walk there.
• Offline maps: download your city once, the map is instant and works without a signal.
• Every walk shows where it happened, named from the offline map.
• Import every walk from Apple Health in one go.
• Sliders for trail width and reveal radius.
• Demo data to preview a fully explored Tokyo.
• Now in Japanese, Chinese, Korean, German, French, Spanish, Italian and Portuguese.""",
    'ja': """バージョン1.1.0
・トイシティ：窓に明かりのともる3Dのパステル建物、公園や通りの木々、スポットのランドマーク模型。歩くまでは白い模型のまま。
・オフライン地図：街を一度ダウンロードすれば、地図は即座に表示され電波なしでも使えます。
・散歩に歩いた場所の名前が、オフライン地図からつきます。
・ヘルスケアからすべての散歩を一括インポート。
・軌跡の太さと探索範囲のスライダー。
・ほぼ探索し尽くした東京をプレビューできるデモデータ。
・日本語、中国語、韓国語、ドイツ語、フランス語、スペイン語、イタリア語、ポルトガル語に対応。""",
    'zh': """版本 1.1.0
• 玩具城市：亮着窗灯的 3D 粉彩建筑、公园和街道旁的树木，以及地点处的地标模型。走过之前都是白色模型。
• 离线地图：下载一次你的城市，地图即刻显示，没有信号也能用。
• 每次散步都会从离线地图得到它发生地点的名字。
• 一次导入 Apple 健康中的所有散步。
• 轨迹宽度与探索半径的滑块。
• 演示数据：预览几乎完全探索的东京。
• 现已支持日语、中文、韩语、德语、法语、西班牙语、意大利语和葡萄牙语。""",
    'ko': """버전 1.1.0
• 장난감 도시: 창에 불이 켜진 3D 파스텔 건물, 공원과 거리의 나무, 스팟의 랜드마크 모형. 걷기 전까지는 하얀 모형.
• 오프라인 지도: 도시를 한 번만 다운로드하면 지도가 바로 뜨고 신호 없이도 작동합니다.
• 모든 산책에 오프라인 지도에서 가져온 장소 이름이 붙습니다.
• Apple 건강의 모든 산책을 한 번에 가져오기.
• 경로 두께와 탐험 반경 슬라이더.
• 거의 다 탐험한 도쿄를 미리 보는 데모 데이터.
• 일본어, 중국어, 한국어, 독일어, 프랑스어, 스페인어, 이탈리아어, 포르투갈어 지원.""",
    'de': """Version 1.1.0
• Die Spielzeugstadt: pastellfarbene 3D-Häuser mit erleuchteten Fenstern, Bäume in Parks und an Straßen und Wahrzeichen-Modelle an deinen Spots. Weißer Ton, bis du dort warst.
• Offline-Karten: lade deine Stadt einmal, die Karte ist sofort da und funktioniert ohne Empfang.
• Jeder Spaziergang zeigt, wo er stattfand, benannt aus der Offline-Karte.
• Jeden Spaziergang aus Apple Health auf einmal importieren.
• Regler für Spurbreite und Aufdeck-Radius.
• Demo-Daten für eine Vorschau auf ein fast vollständig erkundetes Tokio.
• Jetzt auf Japanisch, Chinesisch, Koreanisch, Deutsch, Französisch, Spanisch, Italienisch und Portugiesisch.""",
    'fr': """Version 1.1.0
• La ville miniature : immeubles 3D pastel aux fenêtres allumées, arbres dans les parcs et le long des rues, et modèles de monuments à tes spots. En argile blanche jusqu’à ton passage.
• Cartes hors ligne : télécharge ta ville une fois, la carte est instantanée et fonctionne sans réseau.
• Chaque marche indique où elle a eu lieu, d’après la carte hors ligne.
• Importe toutes tes marches depuis Apple Santé d’un coup.
• Réglages pour l’épaisseur du tracé et le rayon de découverte.
• Données de démo pour prévisualiser un Tokyo presque entièrement exploré.
• Désormais en japonais, chinois, coréen, allemand, français, espagnol, italien et portugais.""",
    'es': """Versión 1.1.0
• La ciudad de juguete: edificios 3D pastel con ventanas encendidas, árboles en parques y calles, y modelos de monumentos en tus spots. Arcilla blanca hasta que pasas.
• Mapas sin conexión: descarga tu ciudad una vez, el mapa es instantáneo y funciona sin cobertura.
• Cada paseo muestra dónde ocurrió, con el nombre sacado del mapa sin conexión.
• Importa todos tus paseos de Apple Salud de una vez.
• Ajustes de grosor del trazo y radio de descubrimiento.
• Datos de demo para ver un Tokio casi totalmente explorado.
• Ahora en japonés, chino, coreano, alemán, francés, español, italiano y portugués.""",
    'it': """Versione 1.1.0
• La città giocattolo: palazzi 3D pastello con finestre accese, alberi nei parchi e lungo le strade, e modelli di monumenti ai tuoi spot. Argilla bianca finché non ci passi.
• Mappe offline: scarica la tua città una volta, la mappa è istantanea e funziona senza segnale.
• Ogni passeggiata mostra dove è avvenuta, con il nome preso dalla mappa offline.
• Importa tutte le passeggiate da Apple Salute in un colpo solo.
• Regolazioni per spessore della traccia e raggio di scoperta.
• Dati demo per un’anteprima di una Tokyo quasi del tutto esplorata.
• Ora in giapponese, cinese, coreano, tedesco, francese, spagnolo, italiano e portoghese.""",
    'pt': """Versão 1.1.0
• A cidade de brinquedo: prédios 3D em tons pastel com janelas acesas, árvores em parques e ruas, e modelos de marcos nos seus spots. Argila branca até você passar.
• Mapas offline: baixe sua cidade uma vez, o mapa é instantâneo e funciona sem sinal.
• Cada caminhada mostra onde aconteceu, com o nome vindo do mapa offline.
• Importe todas as caminhadas do Apple Saúde de uma vez.
• Ajustes de espessura da trilha e raio de descoberta.
• Dados de demo para ver uma Tóquio quase toda explorada.
• Agora em japonês, chinês, coreano, alemão, francês, espanhol, italiano e português.""",
}

HEADLINES = json.load(open(os.path.join(HERE, 'headlines.json')))
SHOT_CAPTION_EN = {
    'city': 'Uncover your city', 'stages': 'Every walk is a stage', 'clear': 'Stage clear!',
    'spots': 'Mark your spots', 'record': 'GO! Record a walk', 'offline': 'Your city, offline',
}

LIMITS = {'name': 30, 'subtitle': 30, 'keywords': 100, 'promo': 170, 'description': 4000, 'whatsnew': 4000}

_id = 0
def field(label, value, limit, bytes_too=False):
    global _id
    _id += 1
    n = len(value)
    warn = n > limit
    count = f'{n}/{limit}'
    if bytes_too:
        b = len(value.encode('utf-8'))
        count += f' · {b} bytes'
    cls = 'count over' if warn else 'count'
    tall = ' tall' if len(value) > 300 else ''
    return (f'<div class="field" data-lang="{{lang}}"><div class="fhead"><span class="flabel">{html.escape(label)}</span>'
            f'<span class="{cls}">{count}</span><button class="copy" data-target="f{_id}">Copy</button></div>'
            f'<pre id="f{_id}" class="val{tall}">{html.escape(value)}</pre></div>')

def pair(label, texts, limit, bytes_too=False):
    out = ['<div class="pair">']
    for code, acc, _ in LANGS:
        out.append(field(f'{label} · {acc}', texts[code], limit, bytes_too).replace('{lang}', code))
    out.append('</div>')
    return '\n'.join(out)

def gallery():
    out = []
    for code, acc, _ in LANGS:
        out.append(f'<div data-lang="{code}"><h4>{html.escape(acc)}</h4><div class="gallery">')
        for i, name in enumerate(HEADLINES['shots'], 1):
            cap = ' '.join(HEADLINES[code][name]['lines'])
            path = f'shots/{code}/iphone/{i:02d}_{name}.png'
            out.append(f'<figure><a href="{path}" target="_blank" rel="noopener"><img loading="lazy" src="{path}" alt="{html.escape(cap)}"></a>'
                       f'<figcaption>{i:02d} · {html.escape(cap)}<br><span class="en">{html.escape(SHOT_CAPTION_EN[name])}</span></figcaption></figure>')
        out.append('</div></div>')
    return '\n'.join(out)

def table(rows):
    body = ''.join(f'<tr><td>{html.escape(k)}</td><td>{v}</td></tr>' for k, v in rows)
    return f'<div class="tablewrap"><table><thead><tr><th>Field</th><th>Value</th></tr></thead><tbody>{body}</tbody></table></div>'

langbar = '<button data-set="all">All</button>' + ''.join(f'<button data-set="{c}">{html.escape(short)}</button>' for c, _, short in LANGS)
loc_list = ', '.join(acc for _, acc, _ in LANGS[1:])
hide_css = ','.join(f'body[data-lang="{c}"] [data-lang]:not([data-lang="{c}"])' for c, _, _ in LANGS) + '{display:none}'

page = f'''<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
<title>Giro Store Kit</title>
<style>
:root{{--bg:#EEF2FF;--card:#FFFFFF;--ink:#0A1D58;--muted:#51608F;--line:#0A1D58;--soft:#D6DEFA;--accent:#FFC400;--accent-ink:#0A1D58;--blue:#1B5BFF;--ok:#2E9E5B;--bad:#EA3A3A;--code:#F4F6FF;--shadow:4px 4px 0 var(--line)}}
*{{box-sizing:border-box}}
html{{scroll-behavior:smooth;scroll-padding-top:64px}}
body{{margin:0;background:var(--bg);color:var(--ink);font:15px/1.55 -apple-system,BlinkMacSystemFont,"Segoe UI","Hiragino Sans","Noto Sans JP","Noto Sans KR","Noto Sans SC",sans-serif;
  background-image:repeating-linear-gradient(-32deg,rgba(27,91,255,.06) 0 14px,transparent 14px 32px)}}
.wrap{{max-width:1080px;margin:0 auto;padding:0 16px 80px}}
header{{padding:40px 0 20px}}
h1{{font-size:clamp(28px,5vw,44px);line-height:1.1;margin:0 0 8px;letter-spacing:-.02em;font-style:italic;font-weight:900}}
h1 mark{{background:var(--accent);color:var(--accent-ink);padding:0 10px;border:3px solid var(--line);box-shadow:var(--shadow);transform:skewX(-8deg);display:inline-block}}
.sub{{color:var(--muted);margin:14px 0 0;max-width:640px}}
nav{{position:sticky;top:0;z-index:5;background:var(--bg);border-bottom:3px solid var(--line);display:flex;gap:6px;overflow-x:auto;padding:10px 0;scrollbar-width:none}}
nav a{{flex:none;color:var(--ink);text-decoration:none;font-weight:700;font-size:13px;padding:5px 10px;border:2px solid var(--line);border-radius:999px;background:var(--card)}}
nav a:hover{{background:var(--accent)}}
section{{margin-top:36px;background:var(--card);border:3px solid var(--line);border-radius:14px;box-shadow:var(--shadow);padding:22px}}
h2{{margin:0 0 6px;font-size:22px;display:flex;align-items:center;gap:10px}}
.num{{font-size:13px;background:var(--accent);color:var(--accent-ink);border:2px solid var(--line);border-radius:8px;padding:1px 7px}}
h3{{margin:26px 0 8px;font-size:17px}} h4{{margin:18px 0 8px;font-size:14px;color:var(--muted);text-transform:uppercase;letter-spacing:.05em}}
.lead{{color:var(--muted);margin:0 0 14px}}
.pair{{display:grid;grid-template-columns:1fr 1fr;gap:12px}}
.field{{border:2px solid var(--soft);border-radius:12px;padding:10px 12px}}
.fhead{{display:flex;align-items:center;gap:8px;margin-bottom:6px}}
.flabel{{font-weight:700;font-size:13px;flex:1}}
.count{{font-size:12px;color:var(--muted);font-variant-numeric:tabular-nums}}
.count.over{{color:#fff;background:var(--bad);border-radius:6px;padding:0 6px;font-weight:700}}
.copy{{font:inherit;cursor:pointer;border:2px solid var(--line);background:var(--accent);color:var(--accent-ink);font-weight:700;font-size:12px;border-radius:8px;padding:3px 10px;box-shadow:2px 2px 0 var(--line)}}
.copy:active{{transform:translate(2px,2px);box-shadow:none}} .copy.done{{background:var(--ok);color:#fff}}
.val{{margin:0;white-space:pre-wrap;word-wrap:break-word;background:var(--code);border:2px solid var(--line);border-radius:10px;padding:10px 12px;font:inherit;font-size:14px}}
.val.tall{{max-height:300px;overflow:auto}}
.tablewrap{{overflow-x:auto;margin-top:14px}} table{{width:100%;border-collapse:collapse;font-size:14px}}
th,td{{text-align:left;padding:8px 10px;border-bottom:2px solid var(--soft);vertical-align:top}}
th{{font-size:12px;color:var(--muted);text-transform:uppercase;letter-spacing:.05em}} td:first-child{{font-weight:700;width:34%}}
.todo{{margin:0;padding-left:20px}} .todo li{{margin:6px 0}} code{{background:var(--code);padding:1px 5px;border-radius:5px}}
.note{{color:var(--muted);font-size:13px;margin-top:12px}}
.gallery{{display:grid;gap:12px;grid-template-columns:repeat(auto-fill,minmax(150px,1fr))}}
figure{{margin:0}} figure img{{width:100%;display:block;border:2px solid var(--line);border-radius:10px;background:var(--soft)}}
figcaption{{font-size:12px;color:var(--ink);margin-top:4px;font-weight:700}} figcaption .en{{color:var(--muted);font-weight:400}}
.toast{{position:fixed;left:50%;bottom:24px;transform:translateX(-50%) translateY(80px);background:var(--ink);color:#fff;padding:8px 16px;border-radius:999px;font-weight:700;font-size:13px;transition:transform .2s;pointer-events:none}}
.toast.show{{transform:translateX(-50%) translateY(0)}}
.langbar{{display:flex;flex-wrap:wrap;gap:8px;margin-top:18px}}
.langbar button{{font:inherit;font-weight:700;font-size:13px;cursor:pointer;border:2px solid var(--line);border-radius:999px;background:var(--card);color:var(--ink);padding:5px 12px;box-shadow:2px 2px 0 var(--line)}}
.langbar button[aria-pressed="true"]{{background:var(--accent)}}
{hide_css}
body:not([data-lang="all"]) .pair{{grid-template-columns:1fr}}
@media (max-width:720px){{.pair{{grid-template-columns:1fr}}section{{padding:16px}}td:first-child{{width:40%}}}}
</style>
</head>
<body data-lang="all">
<div class="wrap">
<header>
<h1><mark>GIRO</mark> Store Kit</h1>
<p class="sub">Everything for App Store Connect in nine languages, in the order you fill it in. Pick a language, hit Copy, paste, done. Character counts are checked against Apple's limits; a red count is over.</p>
<div class="langbar" role="group" aria-label="Language">{langbar}</div>
</header>
<nav><a href="#todo">Fill these in first</a><a href="#info">App Information</a><a href="#age">Age Rating</a><a href="#version">Version page texts</a><a href="#shots">Screenshots</a><a href="#privacy">App Privacy</a><a href="#review">App Review</a></nav>

<section id="todo"><h2><span class="num">01</span>Fill these in first</h2><ul class="todo">
<li><b>Localizations</b>: App Information › language menu (top right) › Add: {html.escape(loc_list)}. English (U.S.) is the primary. Spanish and Portuguese each get the same texts twice (Mexico and Spain; Brazil and Portugal).</li>
<li><b>Privacy Policy URL</b> is required per localization and Giro has none published yet. Suggested home, next to Japanana's: <code>https://apps-privacies-terms-lg.vercel.app/giro/privacy.html</code>. One paragraph is enough: walks, spots and settings stay on the device; HealthKit workouts are read only to import walks and never leave the phone; location is used only while the app is open; map tiles are fetched from OpenFreeMap (which sees your IP address like any website); no accounts, no analytics, no ads.</li>
<li><b>Support URL</b>: <code>https://github.com/lucas-goldner/giro</code> (or the privacy site).</li>
<li><b>HealthKit</b>: the app uses the HealthKit entitlement, so App Review checks the purpose string and that Health data is not used for advertising. The App Review notes below say what it reads.</li>
<li><b>Export compliance</b>: "Does your app use encryption?" → only HTTPS, exempt. Add <code>ITSAppUsesNonExemptEncryption = NO</code> to Info.plist to skip the question on every build.</li>
<li><b>Screenshots</b>: upload the 6.9" set for every language (section 05); it covers every iPhone. Giro is iPhone-only, so no iPad set.</li>
<li><b>Build</b>: pick the latest Codemagic build (the build number comes from TestFlight + 1). Version string <b>{VERSION}</b>.</li>
</ul></section>

<section id="info"><h2><span class="num">02</span>App Information</h2><p class="lead">App Store Connect › your app › App Information. Switch the language menu (top right) for each localization.</p>
{pair('Name', NAME, LIMITS['name'])}
{pair('Subtitle', SUBTITLE, LIMITS['subtitle'])}
{table([
  ('Primary category', 'Health &amp; Fitness'),
  ('Secondary category', 'Navigation <span class="note">(optional; Travel also fits)</span>'),
  ('Copyright', '2026 Lucas Goldner'),
  ('Bundle ID', '<code>com.lucas-goldner.giro</code>'),
  ('SKU', '<code>giro-ios</code> <span class="note">(any unique string, only for you)</span>'),
  ('Localizations', 'English (U.S.) primary, plus ' + html.escape(loc_list)),
  ('Content rights', 'No, it does not contain, show or access third-party content <span class="note">(OpenStreetMap data is openly licensed; the attribution is on the map)</span>'),
  ('Age rating', '4+ (section 03)'),
])}
</section>

<section id="age"><h2><span class="num">03</span>Age Rating</h2>
{table([
  ('Every content question (violence, horror, mature themes, gambling, medical, etc.)', 'None'),
  ('Unrestricted web access', 'No <span class="note">(no browser; the map opens in Apple or Google Maps)</span>'),
  ('User-generated content, messaging or chat', 'No'),
  ('Advertising', 'No'),
  ('Parental controls / age assurance', 'No'),
  ('Result', '<b>4+</b>'),
])}
</section>

<section id="version"><h2><span class="num">04</span>Version page texts</h2><p class="lead">App Store Connect › iOS App › {VERSION}. Pick a language with the buttons above, switch App Store Connect to the same language and paste.</p>
{pair('Promotional text', PROMO, LIMITS['promo'])}
{pair('Description', DESCRIPTION, LIMITS['description'])}
{pair('Keywords', KEYWORDS, LIMITS['keywords'], bytes_too=True)}
{pair("What's New in This Version", WHATS_NEW, LIMITS['whatsnew'])}
<p class="note">Promotional text can be changed any time without a review. Keywords: no spaces after commas; words already in the name and subtitle are left out because Apple indexes those anyway. The Japanese, Chinese and Korean keyword lines stay under 100 bytes as well as 100 characters.</p>
</section>

<section id="shots"><h2><span class="num">05</span>Screenshots</h2><p class="lead">Upload in this order for every localization. iPhone 6.9" · 1290 × 2796; App Store Connect scales it down for every other iPhone. Made by <code>node tool/store_kit.mjs</code> from the web preview in each language (so the map is MapLibre GL JS; the phone renders the same scenes with the GPU toy city, 3D buildings and trees).</p>
{gallery()}
<p class="note">Spanish: upload the same set to Spanish (Mexico) and Spanish (Spain); Portuguese to Brazil and Portugal.</p>
</section>

<section id="privacy"><h2><span class="num">06</span>App Privacy</h2><p class="lead">App Store Connect › App Privacy › Get started.</p>
{table([
  ('Do you or your third-party partners collect data from this app?', '<b>No, we do not collect data from this app</b> → label "Data Not Collected"'),
  ('Why that is right', 'Walks, spots and settings are stored on the device (MMKV). HealthKit workouts are read to import walks and never leave the phone. Location is used only while recording. There is no account, no analytics SDK, no ads, no crash reporter. Map tiles come from OpenFreeMap over HTTPS; its servers see the IP address like any web request, which Apple does not count as collection by the developer.'),
  ('Privacy Policy URL', 'Same URL as in section 01, in every localization'),
])}
</section>

<section id="review"><h2><span class="num">07</span>App Review Information</h2><p class="lead">App Store Connect › iOS App › {VERSION} › App Review Information.</p>
{table([
  ('Sign-in required', 'No. There is no account.'),
  ('Contact', 'Your name, phone and email (the reviewer calls only if something is unclear).'),
  ('Notes', '<pre class="val" id="rn">Giro is a walking game: streets you walk are painted onto a 3D map, the rest stays white.\n\nHealthKit: the app reads walking workouts and their routes only to import past walks as "stages" (Import › Load workouts / Import everything). Nothing is written to Health and no Health data leaves the device.\n\nLocation: used only while recording a walk (GO!), when-in-use authorization.\n\nTo see the app with data on a review device without walking: open Options (the slider icon on the home screen) › Demo data › "Fill Tokyo". This loads generated walks and spots across Tokyo; "Remove demo data" takes them away again. "Download map area" stores the map tiles for offline use (free OpenFreeMap tiles, no account).</pre><button class="copy" data-target="rn" style="margin-top:8px">Copy notes</button>'),
  ('Attachment', 'Optional: a 20-second screen recording of GO! › walk › Stop › Stage clear, if the reviewer cannot walk.'),
])}
</section>
</div>
<div class="toast" id="toast">Copied</div>
<script>
const toast=document.getElementById('toast');let t;
document.querySelectorAll('.copy').forEach(b=>b.addEventListener('click',async()=>{{
  const el=document.getElementById(b.dataset.target);
  await navigator.clipboard.writeText(el.textContent);
  b.classList.add('done');b.textContent='Copied';setTimeout(()=>{{b.classList.remove('done');b.textContent=b.dataset.target==='rn'?'Copy notes':'Copy'}},1200);
  toast.classList.add('show');clearTimeout(t);t=setTimeout(()=>toast.classList.remove('show'),1200);
}}));
const bar=document.querySelector('.langbar');
function setLang(code){{document.body.dataset.lang=code;bar.querySelectorAll('button').forEach(x=>x.setAttribute('aria-pressed',x.dataset.set===code));try{{localStorage.setItem('giro-kit-lang',code)}}catch(e){{}}}}
bar.addEventListener('click',e=>{{if(e.target.dataset.set)setLang(e.target.dataset.set)}});
let saved='all';try{{saved=localStorage.getItem('giro-kit-lang')||'all'}}catch(e){{}}
setLang(saved);
</script>
</body>
</html>
'''

out = os.path.join(HERE, 'index.html')
open(out, 'w').write(page)
for key, texts, limit in [('name', NAME, 30), ('subtitle', SUBTITLE, 30), ('keywords', KEYWORDS, 100), ('promo', PROMO, 170)]:
    for code, _, _ in LANGS:
        n = len(texts[code]); b = len(texts[code].encode())
        flag = ' OVER' if n > limit or (key == 'keywords' and b > 100) else ''
        print(f'{key:9} {code}: {n:3} chars {b:3} bytes{flag}')
print('wrote', out)
