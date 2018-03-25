# CitrusCloudRemo
GR-CITRUSを使ったクラウドリモコンのデモです。
httpsのGETに対応しているクラウドサーバーからコマンド文字列を受け取り、コマンド文字列に応じた処理を行います。

クラウドサーバー側は、httpsレスポンスとして１行のコマンド文字列（例: "ON March 25, 2018 at 05:38PM"）を返すことを想定しています。
GR-CITRUSは、サーバーをポーリングしながら監視し、そのコマンド文字列に応じた処理を行います。

## WIP
- メモリ不足のため、安定的に動作しません。
- 「NoMemoryError: Out of memory」がでたり、プログラム実行開始後にハングアップした場合、GR-CITRUSのケーブルを抜き差ししてから、もう一度実行をしてみてください。

## 事前準備
Google HomeやAmazon Echoなどの音声アシスタントとIFTTTとGoogle Firebaseを組み合わせることで、音声アシスタントからGR-CITRUSを操作することができます。

### Google Firebaseの設定
1. [Google Firebase コンソール](https://console.firebase.google.com/)にログインします
2. プロジェクトを追加します。
    - プロジェクト名:任意の名称を入力 (例:xxxx-cloudremo)
    - 国/地域:"日本"を選択
3. 認証トークンを取得します。
    - Settingsアイコン（ギアアイコン）を押し、プロジェクトの設定を選択します。
    - 設定画面から、サービスアカウントタブを選択します。
    - データベースのシークレットを選択します。
    - 伏せ字となっているため、"表示する"リンクを押して表示します。
    - 表示されたシークレットをメモします。
    - シークレットは秘密情報なため、GitHubなどに公開しないように注意します。
3. Develop - Database を選択します。
    - Databaseの選択画面で、RealTime Database を選択します。
    - 画面内に表示されているURLをメモします。(例:https://xxxx-cloudremo.firebaseio.com/)

### IFTTTの設定
ここではGoogle Assistantの場合を例としますが、Amazon Alexaも同様です。

1. New Appletを選択します。
2. "this"にて、"Google Assistant"を選択します。
    - "Say a simple phrase"を選択します。
    - "What do you want to say?"に音声コマンドを登録します。
        - 例） ライトをつけて
    - "What's another way to say it?"と"And another way?"にも別の言い回しでコマンドを登録しておくことができます。
        - 例) シトラスのライトをつけて
        - 例） 電気をつけて
    - "What do you want the Assistant to say in response?"に適当な応答文を設定します
        - 例) つけます
    - "Language"は"Japanese"を選択します。
3. "that"にて、"Webhooks"を選択します。
    - "URL"にFirebaseの設定にて取得したURLを設定します。その際、word.jsonとauth=シークレットをつなげてください。
        - 例） https://xxxx-cloudremo.firebaseio.com/word.json?auth=aaaaaaa
    - "Method"は"PUT"を選択してください。
    - "Content Type"は"application/json"を選択してください。
    - "Body"は任意のコマンド文字列を入力してください。文字列はダブルコーテーションで囲んでください。
        - 例） "ON {{CreatedAt}}"
        - 例） "OFF {{CreatedAt}}"
4. 同様に、他の音声コマンド（例:ライトを消して）も別のAppletとして登録してください。

### 動作確認
1. 音声アシスト端末でコマンドを実行します。
    - 例) OK Google、ライトをつけて
    - 例） Alexa、ライトをつけて、をトリガー
2. ブラウザで、FirebaseのURL(IFTTTで設定したURLと同じURL)にアクセスします。
    - 例） https://xxxx-cloudremo.firebaseio.com/word.json?auth=aaaaaaa
3. 音声認識した結果のコマンド文字列がブラウザに表示されたことを確認します。


## 使い方
### 必要なもの
- GR-CITRUS
- WA-MIKAN
- microSD
- LED　:　動作確認用。１７ピンとGNDに接続してください。

### WA-MIKANのファームウェアの更新
[がじぇるね工房「GR-CITRUSでTwitter」](https://tool-cloud.renesas.com/ja/atelier/detail.php?id=78)の記事を参考に、ESP8266のfirmwareの更新を行ってください。

### GR-CITRUSのファームウェアの書き込み
SSL通信に対応するためカスタマイズしたファームウェアを使います。GR-CITRUSのリセットボタンを押し、このリポジトリ内に含まれるcitrus_sketch.binを書き込んでください。

このファームウェアはオリジナルのv.2.42をベースに、上記がじぇるね工房の筆者の方のソースファイルを参考にSSL通信機能を追加しています。
また、メモリ使用量削減のためMP3クラスとWifiクラスの一部のメソッドなどを削除しています。それらの機能を使うことはできません。ソースコードは[こちら](https://github.com/takjn/wrbb-v2lib-firm/tree/ssl_support_experimental)にあります。

### 接続先の修正
main.rbを開き、wifiのアクセスポイントやクラウドの接続先情報を各自の環境にあわせて修正してください。

- SSID : wifiのSSIDを設定
- PASS : wifiのパスワードを設定
- SERVER : 接続先のクラウドのURL。
    - プロトコル文字列(https://)をつける必要はありません。
    - 例） xxxx-cloudremo.firebaseio.com/word.json?auth=aaaaaaa

### 実行
main.rbを指定して実行してください。Visual Studio Code の Rubicプラグインを利用すると便利です。
