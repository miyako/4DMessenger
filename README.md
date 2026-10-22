# TCP通信とデータ交換の手法：メッセージングシステムの作成

TCP Communication, Data Exchange Methods: Creating a Messaging System: Japanese edition.

4Dのテクニカルノート 25-11 の日本語版と、そのデモプロジェクトです。テクニカルノートでは、TCPListener クラスと TCPConnection クラスを使って、ユーザー間でメッセージをやり取りする簡略化したアプリケーションの設計と実装を紹介します。デモ「4D Messenger」は、テキスト、画像、ファイル（64MBまで）を暗号化して送受信し、チャンネルごとに受信者を管理するピアツーピアのメッセージングアプリケーションです。

## Download

| | |
|---|---|
| PDF (Japanese) | [25-11_4DMessenger_ja.pdf](https://github.com/miyako/4DMessenger/releases/latest/download/25-11_4DMessenger_ja.pdf) |
| 4D demo | [4DMessenger.zip](https://github.com/miyako/4DMessenger/releases/latest/download/4DMessenger.zip) |
| Original (English) | `document/25-11_4DMessenger.pdf` |

## Demo

- 4D version: 4D 20 R10 or later (as stated in `Project/readme.txt`).
- Open `demo/4DMessenger/Project/4DMessenger.4DProject`.
- Languages: English, Japanese. The UI follows the 4D language; the XLIFF files are in `Resources/<lang>.lproj/`. Standard menu items and buttons (Quit, Close, ...) use 4D's built-in strings.
- Run the project method `app_messenger_main` to open the main window. Each user needs their own machine: every instance listens on the same port, set in the preferences. In the preferences, add the other machines' IP addresses and user names under Nodes, and a channel with its recipients under Channels.

## Differences from the original

- Screenshots (figures 1-9) retaken from the Japanese demo; the annotations of figures 3, 5 and 7 were transposed from the original.
- Figure 10 (TCP communication diagram): labels translated.
- Errors in the original corrected in the Japanese text (TCPListener / TCPConnection, callContextMenu, requestUnPack, onData, zMessOutput). See `glossary.md`.
- Demo:
  - Japanese UI added (XLIFF), including the errors window, context menus and window titles; menus use 4D's built-in strings.
  - "Messanger" / "Messager" corrected to "4D Messenger".
  - Fixed: dates of received messages showed "undefined NaN" when the system date format was not day/month/year.
  - Fixed: empty messages were sent; the preferences file stored its own path; the errors list did not show the error code.
  - The texts inside the two web areas (input placeholder, message dates) are passed once the pages are loaded, so they follow the UI language.
  - Redesigned (v1.1.0): the TCP listener and the sending of messages run in a background worker (`messenger_net`, class `Lib_Messenger_Service`), not in the window. At most one window opens; closing it keeps the connection, and reopening it shows the messages received meanwhile.
  - Because of this redesign, the demo's code differs from the code excerpts in the note (for example, the callbacks call `cs.Lib_Messenger_Service.me.deliver()` instead of `CALL FORM`, and read the settings from the listener instead of `Form.cs_preferences`).

## Editing and rebuilding

The PDF is generated from plain-text sources. Edit them and run `make`.

| File | What |
|---|---|
| `src/ja.md` | Translated body text. **Don't touch code blocks** (`make check` verifies them). |
| `figures/fig-NN.ja.txt` | Text drawn in figure NN. Line N corresponds to line N of `fig-NN.en.txt`: an identical line keeps the original, an empty line erases it. |
| `figures/layout/fig-NN.json` | Per-label overrides for size, weight, alignment and position; `"replace"` uses a ready-made image |
| `glossary.md` | Terminology |

```sh
make            # check → figures → build/25-11_4DMessenger_ja.pdf
make check      # code blocks unchanged, figure references complete
make review     # contact sheets of the figures (build/contact-N.png)
make release-assets
```

Requirements: Python 3, Google Chrome, CJK fonts, and Tesseract (only needed for re-extraction).
See the [localisation template](https://github.com/miyako/4d-technote-localisation-template) for the full workflow.

## Credits

- Original: Olivier Marolleau, Quality Support Engineer, 4D France (Technical Note 25-11).
- Produced with [4d-technote-localisation-template](https://github.com/miyako/4d-technote-localisation-template) and GitHub Copilot.
