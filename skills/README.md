# Skills

v1.2 · 28 Okt 2026 · tambah 5 skill untuk challenge BRI: `live-activity-generator`, `auth-flow`, `onboarding-generator`, `announcement-banner`, `foundation-models` (v1.1: `html-ke-swiftui`)

Folder ini **sudah berisi semua skill** yang dipakai di workshop, dari rencana sampai video demo: 45 folder, sekitar 12 MB, hanya teks dan aset kecil. Tidak perlu internet, tidak perlu menjalankan script unduhan. Bagikan folder `tools/` apa adanya.

Skill adalah instruksi untuk agen dalam satu folder berisi `SKILL.md`. Agen membaca deskripsinya, lalu memuat isinya saat relevan. Skill membantu agen, tapi tidak selalu mencakup semuanya. Sisanya ada di `AGENTS.md`, PRD, user flow, dan kepala kalian.

## Cara pakai

**Dengan script** (disarankan, dari folder `tools/`):

```bash
bash apply-to-repo.sh ~/dev/tagih-teman              # rules, MCP, dan 38 skill workshop
bash apply-to-repo.sh ~/dev/tagih-teman --plugin     # rules, MCP, dan seluruh folder skills/ di root repo (plug-in Xcode)
bash apply-to-repo.sh ~/dev/tagih-teman --claude     # tambah .claude/skills dan .mcp.json
bash apply-to-repo.sh ~/dev/tagih-teman --all-skills # tambah grup expert, ship, meta
```

**Manual:** salin folder skill yang dibutuhkan ke folder yang dibaca tool kalian.

| Tool | Folder di repo | Sumber |
| --- | --- | --- |
| Codex, Gemini CLI, Copilot (CLI, VS Code), Antigravity, Cursor | `.agents/skills/` | README `vercel-labs/skills`, docs agent skills Copilot |
| Kiro (IDE dan CLI) | `.kiro/skills/` | [kiro.dev/docs/skills](https://kiro.dev/docs/skills/) |
| Claude Code | `.claude/skills/` | docs Claude Code |
| Agen di Xcode 27 (Claude Agent, Codex, Antigravity) | Tidak dari folder repo. Impor sekali per Mac: Settings > Intelligence > Plug-ins > Add Plug-in > folder lokal `skills/` (lihat `../mcp/xcode-agents.md`) | Apple; diuji di Mac fasilitator 18–19 Okt |
| Copilot for Xcode | Belum membaca `SKILL.md` | Tempel bagian penting `SKILL.md` ke chat, aturan inti ada di `.github/copilot-instructions.md` |

Salin foldernya utuh, bukan hanya `SKILL.md`: banyak skill membawa file referensi di sebelahnya.

## Daftar skill per tahap

Kolom "Default" berarti ikut disalin `apply-to-repo.sh` tanpa flag tambahan.

### 1. Rencana dan teks (`plan`)

| Skill | Untuk apa | Default | Sumber |
| --- | --- | --- | --- |
| `prd-generator` | Menyusun PRD: fitur, user story, kriteria penerimaan, metrik | Ya | [rshankras/claude-code-apple-skills](https://github.com/rshankras/claude-code-apple-skills) `9ffb831` |
| `ux-writing` | Teks antarmuka: tombol, pesan error, empty state, alert | Ya | rshankras/claude-code-apple-skills `9ffb831` |

`prd-generator` mengharapkan rencana produk dari skill lain (`product-agent`) yang tidak ikut. Beri tahu agen: "Tidak ada product plan. Pakai job-story.md, handoff Dana dan template PRD.md." Hasilnya ditulis ke `docs/PRD.md`; pindahkan atau minta agen menulis ke `PRD.md` di root.

### 2. Desain ke kode (`design`)

| Skill | Untuk apa | Default | Sumber |
| --- | --- | --- | --- |
| `html-ke-swiftui` | **Buatan workshop.** Prototype HTML dari sesi Dana (HTML+CSS, Tailwind, React dari v0/Lovable) di `prototype/` jadi layar SwiftUI native: inventaris dan celah, token ke `DESIGN.md` dan `Tokens.swift`, satu layar per loop dengan empat preview, bandingkan dengan screenshot. Tanpa `WKWebView` | Ya | Folder ini |
| `swiftui-ui-patterns` | Pola view SwiftUI: navigasi, TabView, komponen, layout responsif | Ya | [Dimillian/Skills](https://github.com/Dimillian/Skills) `05ba982` |

Prompt siap tempel untuk `html-ke-swiftui` ada di `docs/dari-html-ke-swiftui.md` di repo starter.

Skill Figma resmi (`figma-swiftui`, `figma-design-to-code`) tidak disalin ke sini karena repo-nya tidak mencantumkan lisensi. Skill itu ikut datang otomatis saat agen tersambung ke **Figma MCP**, atau lewat plugin/Power Figma di Claude Code dan Kiro. Lihat `../mcp/README.md`.

### 3. Membangun (`core`, `expert`, `bri`)

| Skill | Grup | Untuk apa | Default | Sumber |
| --- | --- | --- | --- | --- |
| `swiftui-pro` | core | Review SwiftUI: API usang, data flow, navigasi, aksesibilitas, performa | Ya | [twostraws/SwiftUI-Agent-Skill](https://github.com/twostraws/SwiftUI-Agent-Skill) `f980071` |
| `swift-concurrency-pro` | core | async/await, actor, Sendable tanpa jalan pintas | Ya | [twostraws/Swift-Concurrency-Agent-Skill](https://github.com/twostraws/Swift-Concurrency-Agent-Skill) `bee3f69` |
| `swift-testing-pro` | core | Menulis dan mereview test Swift Testing | Ya | [twostraws/Swift-Testing-Agent-Skill](https://github.com/twostraws/Swift-Testing-Agent-Skill) `2d6bba1` |
| `swiftdata-pro` | core | Model dan query SwiftData yang benar | Ya | [twostraws/SwiftData-Agent-Skill](https://github.com/twostraws/SwiftData-Agent-Skill) `922d989` |
| `swiftui-expert-skill` | core | `@Observable`, layout, Liquid Glass, migrasi API usang | Ya | [AvdLee/SwiftUI-Agent-Skill](https://github.com/AvdLee/SwiftUI-Agent-Skill) `204dba7` |
| `supabase-migrasi` | core | **Buatan workshop.** Jalur Supabase opsional: migration bernomor, RLS di setiap tabel, seed dummy, hanya kunci publishable, `apply_migration` + `get_advisors` lewat MCP, dummy dan test ikut disamakan | Ya | Folder ini |
| `swift-concurrency` | expert | Diagnosa error concurrency, migrasi Swift 6 | Tidak | [AvdLee/Swift-Concurrency-Agent-Skill](https://github.com/AvdLee/Swift-Concurrency-Agent-Skill) `d577081` |
| `swift-testing-expert` | expert | `#expect`/`#require`, trait, migrasi dari XCTest | Tidak | [AvdLee/Swift-Testing-Agent-Skill](https://github.com/AvdLee/Swift-Testing-Agent-Skill) `798e9b1` |
| `app-intents` | bri | App Intents dan App Shortcuts (jalur A, Fast Access) | Ya | [n0an/App-Intents-Agent-Skill](https://github.com/n0an/App-Intents-Agent-Skill) `f754f08` |
| `widgets` | bri | Widget dan widget interaktif (jalur A) | Ya | [n0an/Widgets-Agent-Skill](https://github.com/n0an/Widgets-Agent-Skill) `06567e1` |
| `swift-security-expert` | bri | Keychain, Face ID (LAContext), CryptoKit, secret (jalur B) | Ya | [ivan-magda/swift-security-skill](https://github.com/ivan-magda/swift-security-skill) `bda2e0c` |
| `feature-flags` | bri | Feature flag lokal dan remote config (jalur B dan C) | Ya | rshankras/claude-code-apple-skills `9ffb831` |
| `swiftui-liquid-glass` | bri | API Liquid Glass | Ya | Dimillian/Skills `05ba982` |
| `swiftui-view-refactor` | bri | Memecah view besar, data flow yang rapi | Ya | Dimillian/Skills `05ba982` |
| `live-activity-generator` | bri | Live Activity dan Dynamic Island untuk status transaksi (OS-Native Banking Experience) | Ya | rshankras/claude-code-apple-skills `9ffb831` |
| `auth-flow` | bri | Face ID, Keychain, alur login. Bagian Sign in with Apple butuh akun developer berbayar; pakai bagian biometrik dan Keychain (Authentication & Transaction Integrity) | Ya | rshankras/claude-code-apple-skills `9ffb831` |
| `onboarding-generator` | bri | Onboarding yang langsung mengantar ke momen nilai pertama (modul Onboarding) | Ya | rshankras/claude-code-apple-skills `9ffb831` |
| `announcement-banner` | bri | Banner dalam app dari remote config, terjadwal, bisa ditutup (Seamless On The Fly Update) | Ya | rshankras/claude-code-apple-skills `9ffb831` |
| `foundation-models` | bri | AI di perangkat dengan Foundation Models: teks, output terstruktur, tool calling (Tanya Kasir). Butuh Apple Intelligence aktif di Mac build; cadangannya jawaban dari data dummy | Ya | rshankras/claude-code-apple-skills `9ffb831` |

Grup `expert` tumpang tindih dengan `core`. Terlalu banyak skill dengan topik sama membuat agen ragu memilih, jadi tidak ikut default.

### 4. Test, debug dan iterasi (`debug`)

| Skill | Untuk apa | Default | Sumber |
| --- | --- | --- | --- |
| `bug-fix-loop` | **Buatan workshop.** Bug report → test gagal → perbaikan akar masalah → build bersih → entri `DECISIONS.md`. Berhenti setelah 2 kali gagal | Ya | Folder ini |
| `tdd-feature` | Fitur baru dengan red-green-refactor: test dulu | Ya | rshankras/claude-code-apple-skills `9ffb831` |
| `tdd-bug-fix` | Reproduksi bug sebagai test yang gagal, lalu perbaiki | Ya | rshankras/claude-code-apple-skills `9ffb831` |
| `ios-debugger-agent` | Build, jalankan dan debug di simulator lewat MobileBuildMCP | Ya | Dimillian/Skills `05ba982` |
| `mobilebuildmcp` | Cara memakai tool MobileBuildMCP: build/run, `snapshot_ui`, tap, screenshot, rekam video | Ya | [getsentry/MobileBuildMCP](https://github.com/getsentry/MobileBuildMCP) `d13ff0c` (v2.7.1) |
| `swiftui-debugging` | View lambat atau render ulang terus: identity, body, lazy loading | Ya | rshankras/claude-code-apple-skills `9ffb831` |

`swiftui-debugging` menautkan dua skill lain dari repo asalnya (`profiling`, `data-flow`) yang tidak ikut. Isi utamanya tetap lengkap.

### 5. Jalankan di Simulator dan iPhone (`run`)

| Skill | Untuk apa | Default | Sumber |
| --- | --- | --- | --- |
| `run-simulator` | Build, pasang, buka, screenshot di Simulator untuk membuktikan perubahan terlihat | Ya | rshankras/claude-code-apple-skills `9ffb831` |
| `run-device` | Build dan pasang ke iPhone dari terminal (`xcodebuild` + `devicectl`). Bisa dengan Personal Team gratis; app kedaluwarsa 7 hari | Ya | rshankras/claude-code-apple-skills `9ffb831` |

Langkah manual dan troubleshooting Personal Team: `../../05-Runbook-Jalankan-di-iPhone-v1.md`.

### 6. Agen sebagai tester (`qa`)

| Skill | Untuk apa | Default | Sumber |
| --- | --- | --- | --- |
| `flow-walkthrough` | Cek alur pengguna: UI test per alur, screenshot tiap langkah, checklist untuk manusia | Ya | rshankras/claude-code-apple-skills `9ffb831` |
| `ios-simulator` | Agen membuka app, membaca accessibility tree, tap/ketik/scroll | Ya | [callstack/agent-device](https://github.com/callstack/agent-device) `ba7730a` |
| `dogfood` | QA eksploratif: agen mencari bug dan masalah UX, menulis laporan dengan bukti | Ya | callstack/agent-device `ba7730a` |
| `accessibility-audit` | Audit aksesibilitas: XCUITest audit, VoiceOver, Dynamic Type | Ya | rshankras/claude-code-apple-skills `9ffb831` |

Agen melihat yang absolut. Rasa tetap dinilai manusia.

### 7. Screenshot dan video demo (`media`)

| Skill | Untuk apa | Default | Sumber |
| --- | --- | --- | --- |
| `app-demo-media` | **Buatan workshop.** 3 screenshot + video 20–30 detik hanya dengan `xcrun simctl`. Memakai skill di bawah kalau tersedia | Ya | Folder ini |
| `app-store-screenshots` | Editor Next.js untuk screenshot "iklan" App Store: headline, device frame, ekspor PNG | Ya | [ParthJadhav/app-store-screenshots](https://github.com/ParthJadhav/app-store-screenshots) `8b75d86` |
| `screenshot-automation` | Pipeline screenshot murni Swift: XCUITest, caption, frame | Ya | rshankras/claude-code-apple-skills `9ffb831` |
| `asc-shots-pipeline` | Screenshot dengan AXe dan frame dengan Koubou | Ya | [rorkai/app-store-connect-cli-skills](https://github.com/rorkai/app-store-connect-cli-skills) `4b496c5` |
| `remotion-best-practices` | Video dengan kode (React). Router; sub-skill Remotion (create, render, captions, dll.) sudah ada di dalam foldernya | Ya | [remotion-dev/skills](https://github.com/remotion-dev/skills) `7ba4dcf` |

Panduan sesi, perintah siap tempel dan prompt: `../media/README.md`.

### 8. Nanti, setelah ada akun berbayar (`ship`)

| Skill | Untuk apa | Default | Sumber |
| --- | --- | --- | --- |
| `asc-cli-usage` | Dasar pemakaian `asc` CLI | Tidak | rorkai/app-store-connect-cli-skills `4b496c5` |
| `asc-xcode-build` | Archive dan export build | Tidak | sama |
| `asc-signing-setup` | Sertifikat dan profile distribusi | Tidak | sama |
| `asc-testflight-orchestration` | Grup tester TestFlight, distribusi build | Tidak | sama |

Semua butuh Apple Developer Program berbayar dan API key App Store Connect. Tidak dipakai di hari H.

### 9. Membuat skill sendiri (`meta`)

| Skill | Untuk apa | Default | Sumber |
| --- | --- | --- | --- |
| `skill-creator` | Contoh cara skill dibuat dan diuji | Tidak | [anthropics/skills](https://github.com/anthropics/skills) `dbd4588` |

## Yang perlu dipasang untuk skill tertentu

Sebagian besar skill hanya butuh Xcode. Pengecualian:

| Skill | Butuh | Catatan |
| --- | --- | --- |
| `remotion-best-practices` | Node.js dan npm. ffmpeg tidak perlu dipasang terpisah (`npx remotion ffmpeg`). Render memakai Chrome Headless Shell yang diunduh Remotion | **Lisensi.** Remotion License, bukan MIT. Gratis untuk individu, perusahaan sampai 3 karyawan, nonprofit, dan evaluasi. Perusahaan lebih besar butuh [Company License](https://www.remotion.pro/license). Di workshop statusnya evaluasi |
| `app-store-screenshots` | Node.js 20.9+, bun/pnpm/yarn/npm, browser | Paling besar (6,5 MB, template Next.js). Membawa bezel perangkat dari Apple Design Resources; Apple hanya mengizinkannya untuk mock-up app platform Apple. Agen akan `npm install` dan menyalakan dev server lokal |
| `asc-shots-pipeline` | `asc` CLI, AXe (`brew install cameroncooke/axe/axe`), Python dengan `pip install koubou==0.20.0` | Upload butuh API key; di workshop cukup sampai frame. Perintah screenshot lokal `asc` masih eksperimental |
| `screenshot-automation` | Xcode saja | Daftar ukuran layar masih menyebut 6.7"; ukuran wajib sekarang ada di [Screenshot specifications](https://developer.apple.com/help/app-store-connect/reference/screenshot-specifications) |
| `mobilebuildmcp`, `ios-debugger-agent` | Server MobileBuildMCP 2.7.1 (config di `../mcp/`) | Workflow `ui-automation` harus aktif di `.mobilebuildmcp/config.yaml` (sudah aktif). `record_sim_video` butuh AXe; paket npm membawa AXe sendiri |
| `flow-walkthrough` | Target UI test | Menyebut `PLAN.md` dan `/apple:plan` dari plugin asalnya. Kalau tidak ada, agen menulis daftar alur dulu. Satu baris diubah untuk workshop (19 Okt): target UI test ditambah lewat tool Xcode, bukan generator proyek |
| `ios-simulator`, `dogfood` | CLI `agent-device` (`npm install -g agent-device`, Node.js 22.12+) | Skill melarang agen memasang CLI sendiri; peserta memasang dulu. `dogfood` butuh `agent-device` 0.14.0+ |
| `run-device` | iPhone tersambung, Developer Mode aktif, Apple Account login di Xcode | Personal Team: 7 hari, maks. 3 perangkat |

Beberapa skill dari rshankras menyebut tool `AskUserQuestion` milik Claude Code. Agen lain cukup bertanya di chat.

## Lisensi

Semua skill pihak ketiga di sini berlisensi MIT, kecuali `skill-creator` (Apache 2.0, `LICENSE.txt` di foldernya) dan `remotion-best-practices` (Remotion License, lihat `LICENSE.upstream.txt`). Kalau folder skill tidak punya lisensi sendiri, lisensi repo asalnya ada di `LICENSE.upstream`. Empat skill buatan workshop (`bug-fix-loop`, `app-demo-media`, `supabase-migrasi`, `html-ke-swiftui`) bebas dipakai dan diubah.

Versi persis tiap skill tercatat di `SKILLS.lock` (repo, commit, path). Satu perubahan dari aslinya: contoh kunci Stripe palsu di `swift-security-expert/references/compliance-owasp-mapping.md` diganti `sk_live_EXAMPLE_NOT_A_REAL_KEY`, supaya tidak ditandai sebagai rahasia oleh secret scanning GitHub.

## Kandidat yang dicek tapi tidak dimasukkan

- [daetojemax/figma-to-swiftui-skill](https://github.com/daetojemax/figma-to-swiftui-skill): isinya bagus, tapi repo tidak punya lisensi, jadi tidak boleh disalin ulang. Bisa dipasang sendiri dari repo aslinya.
- Skill Figma resmi di [figma/mcp-server-guide](https://github.com/figma/mcp-server-guide) (`figma-swiftui`, `figma-design-to-code`): tidak ada file lisensi. Dipakai lewat Figma MCP atau plugin resmi, bukan disalin.
- Dimillian `review-and-simplify-changes` dan `bug-hunt-swarm`: dirancang untuk sub-agen Codex, kurang cocok untuk Kiro dan Copilot.
- [conorluddy/ios-simulator-skill](https://github.com/conorluddy/ios-simulator-skill) (MIT): butuh Python 3.12+ dan `idb` dari Facebook. Terlalu banyak pemasangan untuk dua hari.
- [AvdLee/rocketsim-agent-skill](https://github.com/AvdLee/rocketsim-agent-skill): tidak berisi `SKILL.md`, lisensi proprietary.
- [framara/app-store-screenshots-skill](https://github.com/framara/app-store-screenshots-skill): namanya bentrok dengan `app-store-screenshots`, butuh `asc` yang sudah login.
- [dpearson2699/swift-ios-skills](https://github.com/dpearson2699/swift-ios-skills): lisensi PolyForm Perimeter, bukan open source.

Indeks komunitas untuk mencari skill lain: [twostraws/Swift-Agent-Skills](https://github.com/twostraws/Swift-Agent-Skills). Masuk indeks bukan berarti direkomendasikan; baca skill sampai habis sebelum memasang. Lihat juga `../marketplace.md`.

## Untuk fasilitator: memperbarui skill

```bash
bash ../fetch-skills.sh             # unduh ulang semua grup sesuai commit di script
bash ../fetch-skills.sh --latest    # ambil versi terbaru, lalu baca diff-nya sebelum dibagikan
bash ../fetch-skills.sh --only media
```

Clone repo disimpan di luar folder ini (`~/.cache/bri-f3-skill-repos`, atau `SKILL_CACHE=/path`). Script tidak menjalankan kode dari repo yang diunduh. Repo asc skills pindah dari `rudrankriyam/` ke `rorkai/`; script memakai URL baru. Repo twostraws menyimpan salinan kedua di `<skill>/skills/<skill>/` untuk plugin Claude Code; script tidak ikut menyalinnya supaya tidak ada dua skill bernama sama.
