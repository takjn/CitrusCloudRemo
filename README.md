# CitrusCloudRemo
GR-CITRUSを使ったクラウドリモコンのデモです。
httpsのGETに対応しているクラウドサーバーからコマンド文字列を受け取り、コマンド文字列に応じた処理を行います。

クラウドサーバー側は、httpレスポンスとして１行のコマンド文字列を返すことを想定しています。（例: "ON March 25, 2018 at 05:38PM"）
GR-CITRUSは、サーバーをポーリングしながら監視し、そのコマンド文字列に応じた処理を行います。

## WIP
- メモリ不足のため、安定的に動作しません。
- 「NoMemoryError: Out of memory」がでたり、プログラム実行開始後にハングアップした場合、GR-CITRUSのケーブルを抜き差ししてから、もう一度実行をしてみてください。

## 事前準備
Google HomeやAmazon Echoと言った音声アシスタントとIFTTT、Google Firebaseを組み合わせることで、音声アシスタントからGR-CITRUSを操作することができます。

### Google Firebaseの設定
1. [Google Firebase コンソール](https://console.firebase.google.com/)にログインします
2. プロジェクトを追加します。
    - プロジェクト名:任意の名称を入力　(例：xxxx-cloudremo)
    - 国/地域:日本　を選択
3. 認証トークンを取得します。
    - Settingsアイコン（ギアアイコン）を押し、プロジェクトの設定を選択します。
    - 設定画面から、サービスアカウントタブを選択します。
    - データベースのシークレットを選択します。
    - 伏せ字となっているため、"表示する"リンクを押して表示します。
    - 表示されたシークレットをメモします。
    - シークレットは秘密情報なため、GitHubなどに公開しないように注意します。
3. Develop - Database を選択します。
    - Databaseの選択画面で、RealTime Database を選択します。
    - URLが表示されているため、そのURLをメモします。(例：https://xxxx-cloudremo.firebaseio.com/)

### IFTTTの設定
ここではGoogle Assistantの場合を例としますが、Amazon Alexaも同様です。

1. New Appletを選択します。
2. "this"にて、Google Assistantを選択します。
    - Say a simple phrase を選択します。
    - What do you want to say? に音声コマンドを登録します。
        - 例） ライトをつけて
    - What's another way to say it? と And another way? にも別の言い回しでコマンドを登録しておくことができます。
        - 例) シトラスのライトをつけて
        - 例） 電気をつけて
    - What do you want the Assistant to say in response? に適当な応答文を設定します
        - 例) つけます
    - LanguageはJapaneseを選択します。
3. "that"にて、Webhooksを選択します。
    - URLに、Firebaseの設定にて取得したURLを設定します。その際、word.jsonとauth=シークレットをつなげてください。
        - 例） https://xxxx-citrus.firebaseio.com/word.json?auth=aaaaaaa
    - Method は PUTを選択してください。
    - Content Type は application/json を選択してください。
    - Body は 任意のコマンド文字列を入力してください。ダブルコーテーションで囲むことを忘れずにおこなってください。
        - 例） "ON {{CreatedAt}}"
        - 例） "OFF {{CreatedAt}}"
4. 同様に、他の音声コマンド（例：ライトを消して）も登録してください。

### 動作確認
1. 音声アシスト端末でコマンドを実行します。
    - 例) OK Google、ライトをつけて
    - 例） Alexa、ライトをつけて、をトリガー
2. ブラウザで、FirebaseのURL(IFTTTで設定したURLと同じURL)にアクセスします。
    - 例） https://xxxx-citrus.firebaseio.com/word.json?auth=aaaaaaa
3. 音声認識した結果のコマンド文字列がブラウザに表示されたことを確認します。


## 使い方
### 必要なもの
- GR-CITRUS
- WA-MIKAN
- LED　：　動作確認用。１７ピンとGNDに接続してください。

### WA-MIKANのファームウェアの更新
がじぇるね工房「GR-CITRUSでTwitter」の記事を参考に、ESP8266のfirmwareの更新を行ってください。

### GR-CITRUSのファームウェアの書き込み
SSL通信に対応するためカスタマイズしたファームウェアを使います。GR-CITRUSのリセットボタンを押し、このリポジトリ内に含まれるcitrus_sketch.binを書き込んでください。

このファームウェアはオリジナルのv.2.42をベースに、上記がじぇるね工房の筆者の方のソースファイルを参考にSSL通信機能を追加しています。
また、メモリ使用量削減のためMP3、Servo、I2CクラスとWifiクラスの一部のメソッドを削除しています。それらの機能を使うことはできません。

### 接続先の修正
main.rbを開き、wifiのアクセスポイントやクラウドの接続先情報を各自の環境にあわせて修正してください。

- SSID : wifiのSSIDを設定
- PASS : wifiのパスワードを設定
- SERVER : 接続先のクラウドのURL。
    - プロトコル文字列(https://)をつける必要はありません。
    - 例） xxxx-citrus.firebaseio.com/word.json?auth=aaaaaaa

### 実行
main.rbを指定して実行してください。Visual Studio Code の Rubicプラグインを利用すると便利です。
