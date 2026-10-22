# TCP通信とデータ交換の手法：メッセージングシステムの作成

Olivier Marolleau（4D France 品質サポートエンジニア）

## 概要

TCP（Transmission Control Protocol）は、ネットワーク通信において重要な役割を果たすプロトコルです。とくに、データ交換の信頼性が欠かせないクライアント／サーバー環境で重要です。

4Dデータベースでは、オートメーションシステムやサードパーティ製ソフトウェアとの低レベルなやり取りに特に役立ちます。通信チャンネルの管理にも利用できます。ただし、実装が複雑になることがあります。

このテクニカルノートでは、簡略化したアプリケーション例を通じて、ユーザー間通信を題材に通信管理の手法を紹介します。

## はじめに

TCPコマンドと4D Internet Commandsプラグインが非推奨となったことを受けて、4Dには次の2つのモダンなクラスが導入されました：

- **TCPListener**：データの受信用
- **TCPConnection**：データの送信用

この更新は、TCP通信の最適化を目的としています。このテクニカルノートでは、簡略化したメッセージングアプリケーションの開発を通じて、これらのクラスの実践的な実装を紹介します。

目的は、更新されたTCPフレームワークを使ったアーキテクチャの具体例を示し、TCPListenerとTCPConnectionでユーザー間の通信をどのように管理できるかを説明することです。

## 前提条件

このアプリケーションは、4D 20 R10以降のプロジェクトモードで動作するように設計されています。

あらかじめ、次のドキュメントに目を通しておくことをお勧めします：

- TCPListener
- TCPConnection

## アプリケーションの概要

このメッセージングアプリケーションは簡略版のため、機能は限られています。たとえば、プロキシやネットワーク探索には対応しません。

一般的なメッセージングアプリケーションと同様に、もちろんメッセージを送信できます。さらに、一定のサイズ制限内であれば、画像、動画、あらゆる種類のファイルも送信できます。

やり取りを保護するために、暗号化キーを設定します。

メッセージの受信者候補は「ノード（nodes）」セクションに登録し、それぞれのアドレスを記憶しておきます。

次に、チャンネルを使ってメッセージ受信者の有効なリストを指定します。これにより、送信先を絞り込めます。

基本的な識別子にはユーザー名を使います。これにより、設定が簡単になります。たとえば、2人のユーザーAとBがこのメッセージングシステムを設定するとします。各ユーザーはアプリケーションを起動し、自分の名前とアドレスを確認して相手に伝えます。そして、それぞれがノードのリストに相手のアドレスとユーザー名を追加します。

あとは、デフォルトのチャンネルに、登録したユーザーをメッセージの送信先として追加するだけです。

以下の図の例を参照してください。

![](fig-01)

![](fig-02)

## インターフェースの概要

ここでは、主な機能について詳しく説明します。

### 1. メッセージの入力

アプリケーションでは、テキストメッセージを入力できる必要があります。

ただし、同時に動画や画像なども入力できるようにする必要があるため、事情が複雑になります。

上記の表示条件をすべて満たせるオブジェクトタイプは、Webエリアだけです。そのため、このアプリケーションでは、下図のようにWebエリア「zMessInput」をメッセージの入力に使います：

![](fig-03)

入力エリアは次の要素で構成されます：

1. Webエリア「zMessInput」：前述のとおり、作成するメッセージの入力エリアとして使います。
2. ポップアップメニュー「mChannel」：配信チャンネルを選択できます。
3. 「bClear」ボタン：メッセージ履歴を消去できます。
4. 「bSend」ボタン：メッセージを送信できます。

送信は「bSend」ボタン（4）で行います：

```4d
If (FORM Event.code=On Clicked)
    Form.cs_interface.actioSendMessage()
End if
```

配信チャンネル（2）では、メッセージの受信者となるユーザーのリストをあらかじめ定義して選択します。

メッセージを入力し（1）、ドラッグ＆ドロップで要素を追加できます。サイズの上限は64MBです。

この上限は、主に開発を簡単にするために設けています。

ファイルサイズを制限することでデータ転送時間を抑え、やり取りの進捗という複雑な管理を避けています。進捗ウィンドウでユーザーを待たせる処理も不要になります。

ただし、この値は次の場所にある **「input.js」** ファイルで変更できます：

```text
Resources / frames / input.js
```

MAX_SIZEの値は、次のように変更できます：

```js
// mem target
const message_container = document.getElementById('message_container');
const message_cargo = document.getElementById('message_cargo');
const message_text = document.getElementById('message_text');

const MAX_SIZE = 64 * 1024 * 1024;
```

下図の例では、テキストと画像が送信できる状態になっています。さらにファイルをエリアにドラッグできます。

![](fig-04)

### 2. メッセージの受信

メッセージの受信でも、テキスト、画像、動画などを表示できる必要があります。つまり、入力で表示できるものは受信でも表示できなければなりません。

さらに、受信履歴を表示し続け、送信したメッセージと受信したメッセージをはっきり区別できるようにする必要があります。

考え方は同じです。下図のように、**「zMessOutput」** Webエリアを表示の土台として使います：

![](fig-05)

送受信したメッセージは、WebページへのHTMLの挿入によってこのエリアに描画されます。

これは、**WA EXECUTE JAVASCRIPT FUNCTION** を使って、次のファイルで定義されているJavaScript関数「drawMessage」を呼び出すことで行います：

```text
Resources / frames / output.js
```

この関数がHTMLコードを組み立てます。レイアウトは、割り当てたCSSクラスで制御します。

CSSクラスは次のファイルで定義されています：

```text
Resources / frames / output.css
```

慣例に従い、受信したメッセージは左寄せ、送信したメッセージは右寄せで表示します。下図の例を参照してください：

![](fig-06)

### 3. 環境設定

起動のたびに値を入力し直さなくて済むように、アプリケーションはユーザー名や受信者候補のリストなどのパラメーターを保存する必要があります。

パラメーターは、環境設定としてJSONファイルに保存します。

デフォルトでは、ファイル名はマシン名になり、カレントのデータフォルダー内の **Messenger** フォルダーに保存されます。例：

```text
Data / Messenger / MyComputerName.json
```

環境設定はLib_Messenger_Preferencesクラスが管理し、Form.cs_preferencesに保持されます。環境設定は、アプリケーションの起動時に読み込まれ、初期化されます：

```4d
// init prefs
Form.cs_preferences:=cs.Lib_Messenger_Preferences.new()
Form.cs_preferences.load()
```

環境設定のセクションは次のとおりです：

![](fig-07)

環境設定には次の項目があります：

1. **通信の暗号化キー**（comm > key）  
   アプリケーションが送信するデータの暗号化に使います。
2. **公開アドレス**（comm > address）  
   アプリケーションを公開するアドレス、つまり、メッセージの着信を待ち受けるアドレスです。
3. **公開ポート番号**（comm > port）
4. **ユーザーのアバター**（user > avatar）
5. **ユーザー名**（user > name）
6. **ユーザーノードのリスト**（comm > nodes）  
   登録済みのユーザーと、そのユーザーノードのIPアドレスを保持します。メッセージを送信するには、相手のユーザーが正しく登録されている必要があります。メッセージを送信する前に、受信者候補をすべてリストに追加しておかなければなりません。
7. **チャンネルのリスト**（comm > channels）  
   チャンネルごとに、受信者となるユーザーのリストをカンマ区切りで保持します。
8. **環境設定の保存ボタン**

設定例：

![](fig-08)

### 4. Webエリアとのやり取り

前述のとおり、画像、動画、テキストなどのコンテンツを表示する必要があるため、受信側のインターフェースの表示にはWebエリアを使います。

さらに、よく設計されたCSSクラスを使うことで、インターフェースを効率よく、最小限の負荷で描画できます。

そこで、WebエリアのHTMLページ専用の次のCSSファイルでレイアウトを制御します：

```text
Resources / frames / common.css
Resources / frames / input.css
Resources / frames / output.css
```

やり取りのほぼすべては、**WA EXECUTE JAVASCRIPT FUNCTION** を通じて行います。

状況に応じて特定の関数を呼び出し、Webページ上の処理を実行します。たとえば「bClear」をクリックすると、Form.cs_interface.actioClearHistory()が呼び出され、次のコードが実行されます：

```4d
WA EXECUTE JAVASCRIPT FUNCTION(*; "zMessOutput"; "clearOutput"; *)
```

JavaScript関数「clearOutput」は、ブラウザー側で履歴を消去します。

### 5. 4DメニューとWebエリア

Webエリアでは、メッセージ履歴と入力のどちらでも、たとえば画像をダウンロードするためにコンテキストメニューがあると便利です。

![](fig-09)

メニューはJavaScriptだけでは管理できません。表示が途中で切れてしまうためです。

代わりに **Dynamic pop up menu** コマンドを使います。

このコマンドとWebエリアを連携させるため、一部の要素にはあらかじめリンクを設定しておきます。たとえば、メッセージを構成する画像やファイルです。これらのリンクは **WA SET EXTERNAL LINKS FILTERS** でインターセプトします。

「Lib_Messenger_Interface」クラス（「Form.cs_interface」オブジェクトに保持）には「callContextMenu」関数があり、状況に応じて表示するメニューを選択します。

リンクにはオブジェクトの内部的な説明情報が含まれているため、状況に応じてあらかじめ定義した処理を実行できます。

たとえば、メッセージ内の画像には次のようなURLが設定されています：

```html
<a data-hash="aaaf16a19f63816f5cc23db905e6ed9c891b9f4d228f57425242e85052cdf7a8"
class="ss_message_crate" href="callContextMenu?{&quot;title&quot;:&quot;tracteur
Lamborghini.png&quot;,&quot;hash&quot;:&quot;aaaf16a19f63816f5cc23db905e6ed9c891b9f
4d228f57425242e85052cdf7a8&quot;}" data-codex="3"><img
src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUg….
```

読みやすくすると次のようになります：

```text
callContextMenu ? {
  "title" : "tracteur Lamborghini.png ",
  "hash" : " aaaf16a19f63816f5cc23db905e6ed9c891b9f4d228f57425242e85052cdf7a8"}
```

ここから、HTMLページ内の要素を簡単に特定できます。data-codex属性はコンテンツの種類を示しており、これによって画像の保存オプションを提供できます。

### 6. 処理の集約

「Lib_Messenger_Interface」クラス（「Form.cs_interface」に保持）は、インターフェース固有の処理を集約する役割を持ちます。処理を共通化することで、さまざまな状況から実行できます。

例：

- **actioListenMessage**：Lib_Messenger_Net_Inputを使って待ち受けを開始します。→ 読み込み時、または環境設定の保存後に実行されます。
- **actioSendMessage**：Lib_Messenger_Net_Outputを使ってメッセージを送信します。→ 受信者が複数の場合はループ処理になります。

## ユーザー（ノード）間の通信

通信のために、このプロジェクトのアーキテクチャはピアツーピア（peer-to-peer）アーキテクチャを強く意識しています。これは、接続やデータを管理する中央サーバーを持たない分散型のネットワークモデルです。

各参加者は、リソースの要求者であると同時に提供者でもあります。

**動作の原理：**

- 各ユーザーは、1つ以上のノードに直接接続します。
- データやリクエストは、中央の拠点を経由せずにノードからノードへ送られます。

**動作の仕組みを下図に示します：**

![](fig-10)

**TCPListener** はデータの受信に使います。Form.cs_net_inputに保持される専用クラスLib_Messenger_Net_Inputを通じて受信します。

**TCPConnection** はデータの送信に使います。Form.cs_net_outputオブジェクトに保持されるLib_Messenger_Net_Outputクラスを通じて送信します。

### 1. やり取りする内容

リクエストでやり取りするデータは、標準化され、できるだけコンパクトである必要があります。そのため、やり取りにはバイナリ形式を採用しています。これにより、その後のデータ処理が大幅に簡単になります。

データは、定義された構造に従ってBLOBに順番に格納されます。

**リクエストの構造：**

| フィールド | サイズ（バイト） | 説明 |
|---|---|---|
| リクエストのサイズ | 4 | データの整合性と正しい受信を保証します |
| 構造のハッシュ | 32 | データのデコードを検証します |
| 暗号化されたデータ | ∞ | 次の構造に従ってデコードされる内容 |

**デコードされたデータ：**

| 説明 | サイズ（バイト） | コメント |
|---|---|---|
| 構造のサイズ | 4 | 構造を検証して復元します |
| ルーティング | 3 | リクエストの種類（送信、受信など）を定義します |
| 送信者 | ∞ | 送信者の名前 |
| 受信者 | ∞ | 受信者の名前 |
| 受信者リスト | ∞ | チャンネルの受信者のリスト |
| 送信日 | 8 | |
| 送信時刻 | 4 | |
| ID | ∞ | メッセージの識別子 |
| ペイロード（Cargo） | ∞ | JSON形式のデータ |

バイナリ形式の処理を一箇所にまとめ、今後の更新を簡単にするため、データのカプセル化（requestPack）とカプセル化の解除（requestUnPack）には「Lib_Messenger_Net_Request」クラスを使います。

requestPackの抜粋：

```4d
Function requestPack($key : Text)->$requestRaw : Blob
    // declare vars
    var $offset : Integer:=0
    var $salt; $originSize : Integer
    var $encrypted : Boolean
    var $originHash : Text
    // timestamp
    This.date:=Current date
    This.time:=Current time

    // define way
    INTEGER TO BLOB(This.way; $requestRaw; PC byte ordering; *)

    // define sender
    TEXT TO BLOB(This.sender; $requestRaw; UTF8 text with length; *)
```

requestUnPackの抜粋：

```4d
Function requestUnPack($key : Text; $requestRaw : Blob)->$success : Boolean
    // declare vars
    var $offset : Integer:=0
    var $salt : Integer
    var $originSize : Integer
    var $dateRaw : Text
    var $originHash : Text
    var $decrypted : Boolean
    // primary control
    $success:=False
    ASSERT(BLOB size($requestRaw)>37; "4D Messenger : Request bad format")

    // read length request
    $originSize:=BLOB to longint($requestRaw; PC byte ordering)
    ASSERT(BLOB size($requestRaw)=$originSize; "4D Messenger : Request corrupted")
    DELETE FROM BLOB($requestRaw; 0; 4)
```

このクラスは、暗号化とデータの品質検証も管理します。

### 2. リクエストの暗号化と復号

データの暗号化は、**Encrypt data BLOB** と **Decrypt data BLOB** コマンドで行います。これらのコマンドは使い方は簡単ですが、2つの問題があります：

パスフレーズ（passPhrase）が間違っていても、復号に失敗したことを知る手段がありません。コマンドはそのままアルゴリズムを適用し、何であれ復号してしまいます。そのため、復号したデータを検証するためのハッシュを追加する必要があります。

また、データを保護するために追加されたパディングは復号後も残るため、検証が正しく行えません。

この問題に対処するため、暗号化の前に構造のサイズを含めておき、パディングを取り除いてデータを正しく復元できるようにしています。

requestUnPack関数の抜粋を次に示します：

```4d
SET BLOB SIZE($requestRaw; $originSize+4)
If ($originHash=Generate digest($requestRaw; MD5 digest))
```

### 3. メッセージの取得

メッセージを最初に受け取るのはLib_Messenger_Net_Inputクラスです。このクラスは、次のプロパティを中心に構成されています：

```4d
property listener : 4D.TCPListener
property window : Integer
property settings : Object
```

- **listener**：4DのTCPListenerクラスを保持します
- **window**：メッセージングウィンドウの参照を保存します
- **settings**：待ち受けのパラメーターを保存します

「Lib_Messenger_Net_Input」で重要なのは「onConnection」関数です。

```4d
If (This.settings.comm.nodes.query("address = :1 or address = :2"; $event.address; Replace string($event.address; "::ffff:"; ""; 1)).length=1)
    $result:=cs.Lib_Messenger_Stream.new(This)
End if
```

この関数は、アドレスが環境設定に正しく登録されていることを確認したうえで、受信処理を「Lib_Messenger_Stream」クラスに委ねます：

```4d
$result:=cs.Lib_Messenger_Stream.new(This)
```

この仕組みでは、想定したサイズに達するまで、受信したデータをBLOBに連結します。

受信が完了すると、データは「Lib_Messenger_Net_Request」でカプセル化を解除され、定義されたルーティングに従って振り分けられます。

```4d
If ($request.way=x Messenger Get user icon)
    DOCUMENT TO BLOB(Get 4D folder(Data folder)+"Messenger"+Folder separator+Form.cs_preferences.user.name+".png"; $binBuffer)
    INSERT IN BLOB($binBuffer; 0; 1; 0x0002)
    $connection.send($binBuffer)
Else
```

「Lib_Messenger_Stream」クラスの重要な要素は「onData」関数です。この関数はデータを取得するだけでなく、1バイトの受信確認を返します。これにより、メッセージの送信者はインターフェースを更新できます。次のコードを参照してください：

```4d
$request.way:=x Messenger Receive
SET BLOB SIZE($binBuffer; 0)
INSERT IN BLOB($binBuffer; 0; 1; 0x0001)
$connection.send($binBuffer)
```

受信コードは次のとおりです：

| コード | 説明 |
|---|---|
| 0x1 | メッセージを正常に受信しました |
| 0x2 | アイコンのリクエストを正常に受信しました |

さらに「Lib_Messenger_Stream」クラスの「onData」関数では、次のブロックで、各ノードからまだ持っていないユーザーアイコンを取得します。キャッシュされたアイコンは、インターフェースの更新に使われます：

```4d
$requestDraw:=cs.Lib_Messenger_Net_Request.new()
$requestDraw.sender:=Form.cs_preferences.user.name

For each ($user; Split string($request.recipient_list+","+$request.sender; ","; sk ignore empty strings))

    $requestDraw.recipient_list:=$user

    $userIconPath:=Get 4D folder(Data folder)+"Messenger"+Folder separator+$user+".png"
    If (Test path name($userIconPath)#Is a document)

        $requestDraw.way:=x Messenger Get user icon
        $requestDraw.recipient:=$user
        $requestPack:=$requestDraw.requestPack(Form.cs_preferences.comm.key)

        $sender:=cs.Lib_Messenger_Net_Output.new(Form.cs_preferences)

        If ($user=Form.cs_preferences.user.name)
            $sender.connect(Form.cs_preferences.comm.address)
            $sender.send(OB Copy($requestDraw); $requestPack)
        Else
            If (Form.cs_preferences.comm.nodes.query("user = :1"; $user).length>0)

                $sender.connect(Form.cs_preferences.comm.nodes.query("user = :1"; $user)[0].address)
                $sender.send(OB Copy($requestDraw); $requestPack)
            End if
        End if
    End if
End for each
// update interface
CALL FORM(This.listener.window; "app_messenger_main"; False; $request)
```

### 4. メッセージの送信

メッセージの送信はLib_Messenger_Net_Outputクラスが担当します。このクラスは、次のプロパティを中心に構成されています：

```4d
This.connection:=Null
This.settings:=$settings
This.requestDraw:=Create object()
This.requestPack:=$bin
```

- **connection**：TCPConnectionクラスを保持します
- **settings**：待ち受けのパラメーターを保存します
- **requestDraw**：オブジェクト形式のメッセージを格納します（送信先はWebエリア）
- **requestPack**：送信するバイナリ形式のメッセージを格納します（送信先はTCP）

「onData」関数のコードは次のとおりです：

```4d
// var
var $bin : Blob
// blob contain somthings
If (BLOB size($event.data)>=1)
    $bin:=$event.data
    Case of
        : ($bin{0}=0x0001)
            // update interface
            CALL FORM(Current form window; "app_messenger_main"; False; This.requestDraw)
            WA EXECUTE JAVASCRIPT FUNCTION(*; "zMessInput"; "clearInput"; *)
            GOTO OBJECT(*; "zMessInput")

        : ($bin{0}=0x0002)
            DELETE FROM BLOB($bin; 0; 1)
            BLOB TO DOCUMENT(Get 4D folder(Data folder)+"Messenger"+Folder separator+Form.cs_preferences.comm.nodes.query("address = :1"; $connection.address)[0].user+".png"; $bin)

    End case
    SET BLOB SIZE($bin; 0)
End if
```

この部分では、相手から返された受信コードを処理します：

- 0x1 → メッセージを受信しました。インターフェースを更新します。
- 0x2 → アイコンのリクエストに対する肯定的な応答です。アイコンを取得します。

## まとめ

このアプリケーションは、4Dに新たに導入された「TCPListener」クラスと「TCPConnection」クラスを活用したユーザー間通信の実装例です。ピアツーピアのアーキテクチャを採用することで、各ユーザーが送信者と受信者の両方の役割を同時に果たします。中央サーバーへの依存がなくなり、システムの柔軟性、耐障害性、導入のしやすさが向上します。

専用のクラス（「Lib_Messenger_Net_Input」「Lib_Messenger_Net_Output」「Lib_Messenger_Net_Request」など）によって、構造化された保守しやすいコードを実現し、安全なデータのやり取りを確保し、システムを無理なく発展させることができます。

全体として、このテクニカルノートは、現行バージョンの4Dで高度なリアルタイムメッセージングシステムを設計するための体系的な手法を示しています。TCPプロトコルの機能と堅牢性を最大限に活かすことができます。
