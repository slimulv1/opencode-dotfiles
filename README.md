# opencode-dotfiles

Tổng hợp toàn bộ thiết lập opencode: config, skills, plugins, MCP servers và memory (bộ role Arisa + kiến thức dự án).

## Cấu trúc

```
├── config/                # cấu hình opencode
│   ├── opencode.jsonc     # config chính: models, agents, 15 plugins, 9 MCP servers
│   ├── opencode-arise.json    # 8 shadow agents (monarch + beru, igris, bellion, tusk, tank, shadow-sovereign, esil-radiru)
│   ├── oh-my-opencode.json    # agents phụ: sisyphus, hephaestus, librarian, oracle
│   ├── review.json        # tiêu chí review code
│   ├── themes/            # theme pywal
│   ├── command/           # command tùy chỉnh
│   └── plugins/           # plugin tự viết (image-vision, context-usage)
├── skills/                # 62 skills (lark, pdf, pptx, xlsx, plannotator, ...)
├── plugins/worktree/      # plugin worktree tự viết
└── memory/                # dữ liệu memory (profile + kiến thức dự án)
```

## Cài đặt

Yêu cầu: `opencode` + `node`/`npm` + `python`/`uvx` (cho MCP), `gh` (tuỳ chọn).

```bash
git clone https://github.com/slimulv1/opencode-dotfiles.git
cd opencode-dotfiles
./install.sh
```

`install.sh` sẽ:
1. Copy `config/` vào `~/.config/opencode/` và tự sửa đường dẫn `/home/magnus` → `$HOME` của máy bạn
2. Copy `skills/` vào `~/.agents/skills/`
3. Copy `plugins/worktree/` vào `~/.opencode/plugins/worktree/`
4. Import `memory/` vào `~/.opencode-mem/data/` (chỉ khi chưa có dữ liệu cũ)

Chạy `opencode` lần đầu — các plugin npm (15 plugins) và MCP servers được cài/khởi động tự động từ config.

> MCP playwright cần browser: `npx playwright install chromium` (nếu chưa có).

## Cách dùng

| Thứ | Cách dùng |
|---|---|
| Mở TUI | `opencode` |
| Shadow agents | `/arise` hoặc @mention: `beru` (trinh sát), `igris` (triển khai), `bellion` (chiến lược), `tusk` (UI/UX), `tank` (nghiên cứu), `shadow-sovereign` (phản biện), `esil-radiru` (trò chuyện) |
| Memory | Plugin `opencode-mem` tự lưu khi trò chuyện; dữ liệu tại `~/.opencode-mem/data/` |
| Skills | Tự động kích hoạt theo yêu cầu (ví dụ: "viết docx", "tạo pptx", "làm slide lark") |
| Review code | Command `/review` (dùng `review.json`) |
| MCP | `deepwiki` (docs GitHub), `context7` (docs thư viện), `fetch`, `filesystem`, `memory`, `sequential-thinking`, `git`, `playwright`, `semgrep` (scan bảo mật) |

## Ghi chú

- `memory/user-prompts.db` (lịch sử prompt cá nhân) **không** được đưa vào repo — chỉ export profile + kiến thức dự án đã làm sạch.
- Các plugin dạng npm được cài tự động; plugin tự viết nằm trong `config/plugins/` và `plugins/worktree/`.
