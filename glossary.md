# 用語集 / Glossary

Keep terminology consistent across `src/<target>.md` and `figures/*.<target>.txt`.
Change an entry here first, then search and replace in both places.

Style (ja): です・ます調. Half-width alphanumerics, no space between Japanese and Latin text (e.g. `4D.Vector型`).
Full-width `（）` and `：` in prose. First occurrence of a technical term: 日本語（English）.

## 4D terms (from the official 4D Japanese documentation)

| English | 日本語 | Notes |
|---|---|---|
| entity / entity selection | エンティティ / エンティティセレクション | |
| datastore | データストア | |
| dataclass | データクラス | |
| attribute | 属性 | |
| computed attribute | 計算属性 | |
| collection | コレクション | |
| object | オブジェクト | |
| method | メソッド | |
| project method | プロジェクトメソッド | |
| function | 関数 | |
| class | クラス | |
| parameter | 引数 | |
| form | フォーム | |
| form object | フォームオブジェクト | |
| list box | リストボックス | |
| web area | Webエリア | |
| 4D Web Server | 4D Webサーバー | |
| worker | ワーカー | |
| process | プロセス | |
| query | クエリ | |
| formula | フォーミュラ | |
| component | コンポーネント | |

## Document-specific terms

| English | 日本語 | Notes |
|---|---|---|
| TCP listener / connection (classes) | TCPListener / TCPConnection | Class names stay in English |
| message | メッセージ | |
| messaging application / system | メッセージングアプリケーション / メッセージングシステム | |
| node | ノード | "nodes" section: 「ノード（nodes）」 |
| channel / broadcast channel | チャンネル / 配信チャンネル | |
| recipient / sender | 受信者 / 送信者 | |
| preferences | 環境設定 | App settings saved as JSON |
| encryption key | 暗号化キー | |
| publication address / port | 公開アドレス / 公開ポート番号 | |
| listen (for connections) | 待ち受ける / 待ち受け | |
| request | リクエスト | |
| routing (way) | ルーティング | |
| cargo | ペイロード（Cargo） | Payload field. Not カーゴ |
| modern 4D environment | 現行バージョンの4D | Not モダンな4D環境 |
| encapsulate / unencapsulate | カプセル化 / カプセル化の解除 | requestPack / requestUnPack |
| encryption / decryption | 暗号化 / 復号 | |
| passphrase | パスフレーズ | |
| padding | パディング | |
| hash | ハッシュ | |
| acknowledgment of receipt | 受信確認 | |
| reception code | 受信コード | 0x1 / 0x2 |
| peer-to-peer | ピアツーピア | First occurrence: ピアツーピア（peer-to-peer） |
| contextual menu | コンテキストメニュー | |
| popup | ポップアップメニュー | mChannel |
| drag-and-drop | ドラッグ＆ドロップ | |
| data folder | データフォルダー | |
| network layer / presentation layer | ネットワーク層 / プレゼンテーション層 | fig-10 |
| 4D command names | English names, e.g. **WA EXECUTE JAVASCRIPT FUNCTION** | As in the 4D Japanese docs; original's French "WA EXÉCUTER FONCTION JAVASCRIPT" corrected |

## Proper nouns in examples

| English | 日本語 | Notes |
|---|---|---|
| Olivier Marolleau | Olivier Marolleau | Author, kept in Latin script |
| 4D France | 4D France | |
| tracteur Lamborghini.png | tracteur Lamborghini.png | Sample file name; demo data not localised |

## Corrections of the original (applied in ja only)

| Original | Correction |
|---|---|
| “CPListener” / “CPConnection” (p21) | TCPListener / TCPConnection |
| callContexteMenu (p13) | callContextMenu |
| resourceUnpack function (p17) | requestUnPack |
| « OnData » (p18) | onData |
| "zMessInput" as the reception display (p7) | zMessOutput (as in the form) |
| La classe … class / l’objet (French leftovers) | translated normally |
