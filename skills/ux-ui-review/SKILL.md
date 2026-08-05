---
name: ux-ui-review
description: Workflow để opencode TỰ CHỤP màn hình và tự REVIEW UX/UI bằng cách xem ảnh (không cần người dùng gửi ảnh). Use when the user asks to review/improve a UI, verify design looks right, do visual QA, "chụp màn hình", "self-review", "review giao diện", "xem UI", "looks good", or wants to sanity-check a design before finishing. Triggers alongside ui-ux-pro-max, frontend-design, and web-design-guidelines.
---

# UX/UI Self-Review Workflow (Screenshot + Vision)

Skill này giúp opencode **tự nhìn thấy giao diện** bằng cách chụp màn hình (Playwright)
rồi mô tả lại ảnh bằng vision sub-agent, từ đó **tự review** UI/UX mà không cần người
dùng phải gửi ảnh thủ công.

## Khi nào dùng
- Người dùng thiết kế/sửa UI rồi muốn kiểm tra giao diện thực tế
- Người dùng gửi ảnh UI/UX và muốn review (dùng vision agent đọc ảnh)
- Trước khi hoàn thành bất kỳ công việc frontend nào → tự chụp + tự review

## Xử lý ẢNH NGƯỜI DÙNG GỬI
Khi người dùng đính kèm/paste ảnh (mockup, screenshot lỗi, ảnh tham khảo, ảnh chụp màn hình của họ):

1. Nếu model hiện tại đọc được ảnh trực tiếp (đã bật provider override với
   `modalities.input: ["text","image"]`) → xử lý trực tiếp trong luồng hội thoại.
2. **Nếu model không xử lý được hoặc bị lỗi** → dùng vision agent:
   - Ảnh người dùng gửi thường được opencode lưu dưới dạng attachment; nếu cần, yêu
     cầu người dùng lưu ảnh thành file (vd `~/Projects/<project>/reference.png`) hoặc
     tự tìm đường dẫn ảnh gần nhất (glob `**/*.png` trong thư mục làm việc).
   - Triệu hồi vision agent: `task(subagent_type="vision", prompt="Mô tả chi tiết ảnh tại <path>...")`
   - Vision agent (opencode/mimo-v2.5-free, hỗ trợ image input) sẽ trả về mô tả text chi tiết.
3. Dùng mô tả đó làm căn cứ review — và LƯU Ý: người dùng có thể gửi ảnh **tham khảo**
   (reference/mockup) để bắt chước phong cách, hoặc ảnh **lỗi** để sửa, hoặc ảnh **cần
   đánh giá**. Hỏi rõ ý định nếu không chắc.

## Quy trình chuẩn (loop: Chụp → Xem → Review → Sửa → Chụp lại)

### Bước 1 — Chạy app
- Dùng `pty_spawn` (opencode-pty) hoặc `bash` để khởi động dev server.
- Đợi app sẵn sàng (đọc log, chờ port listen).

### Bước 2 — Chụp màn hình (Playwright MCP)
Dùng các tool `playwright_browser_*`:
1. `playwright_browser_navigate` → mở URL của app (vd http://localhost:5173)
2. `playwright_browser_resize` → đặt kích thước cửa sổ thực tế (vd 1280x800)
3. `playwright_browser_take_screenshot` với `type: "png"`, `scale: "css"`,
   `fullPage: true` → chụp toàn trang. Lưu vào đường dẫn rõ ràng, vd
   `~/Projects/<project>/screenshots/review-<timestamp>.png`
4. Chụp thêm ở các trạng thái quan trọng: mobile viewport (vd 390x844), hover,
   empty state, error state, modal... (điều hướng + thao tác rồi chụp từng cái)

### Bước 3 — Xem ảnh (vision sub-agent)
Model chính (deepseek-v4-flash-free) thường không đọc được ảnh, nên:
- **Nếu model hiện tại hỗ trợ ảnh**: đọc trực tiếp bằng tool `read` lên file ảnh.
- **Ngược lại (mặc định)**: triệu hồi vision agent để mô tả ảnh:
  - Dùng `task(subagent_type="vision", prompt="Hãy mô tả chi tiết ảnh tại <path> theo format: overview, layout, colors/contrast, typography, UX/UI issues, suggestions")`
  - Hoặc trong môi trường Arise: `arise_summon` một shadow có model vision (vd tusk/mimo) đọc ảnh.
- Thu được **mô tả text chi tiết** về giao diện → dùng mô tả này để đánh giá.

### Bước 4 — Self-review theo chuẩn
Đối chiếu mô tả ảnh với các skill thiết kế:
- Load **ui-ux-pro-max** (styles, palettes, font pairings, UX guidelines)
- Load **frontend-design** (aesthetic direction, typography)
- Load **web-design-guidelines** (accessibility, best practices)
Check: spacing/alignment, contrast (WCAG AA ≥ 4.5:1 text), typography hierarchy,
consistent colors, visual feedback, empty/loading/error states, responsive breakpoints.

### Bước 5 — Sửa và verify
- Sửa code theo phát hiện.
- Chụp lại màn hình (lặp Bước 2–3) để xác nhận cải thiện.
- Báo cáo: liệt kê issues tìm được, fixes đã làm, ảnh chụp trước/sau (đường dẫn).

## Quy tắc
- LUÔN chụp màn hình trước khi tuyên bố "giao diện đã đẹp/đã xong" — không phán xét mù.
- Lưu screenshot vào thư mục `screenshots/` trong project (không rải lung tung).
- Nếu app không mở được, báo lỗi cụ thể + log thay vì đoán.
- Nếu không có Playwright, dùng `agent-browser` skill hoặc `npx playwright` CLI.
