---
description: Tự chụp màn hình app đang chạy và self-review UX/UI bằng vision agent (chỉ định URL hoặc để trống để tự tìm dev server)
argument-hint: [url] — URL của app (vd http://localhost:5173). Để trống = tự phát hiện dev server đang chạy.
agent: monarch
---

Bạn đang ở chế độ UX/UI SELF-REVIEW. Thực hiện theo skill `ux-ui-review`:

1. LOAD skill `ux-ui-review` và thực hiện đúng workflow trong đó.
2. Xác định app đang chạy: URL được truyền là $ARGUMENTS; nếu để trống, tìm dev server
   (kiểm tra pty_list / processes / common ports 3000, 4173, 5173, 8080).
3. Chụp màn hình bằng Playwright MCP:
   - navigate đến URL
   - resize 1280x800 (desktop) rồi chụp fullPage PNG
   - resize 390x844 (mobile) rồi chụp thêm
   - thao tác vài trạng thái chính (hover, modal, empty/error state nếu có) và chụp
   - lưu vào <project>/screenshots/review-*.png
4. XEM ảnh: dùng vision sub-agent (task subagent_type="vision" hoặc shadow model vision)
   để mô tả chi tiết từng ảnh theo format: overview / layout / colors+contrast / typography / issues / suggestions.
5. REVIEW theo ui-ux-pro-max + frontend-design + web-design-guidelines: spacing, contrast WCAG AA,
   typography hierarchy, consistent colors, states (loading/empty/error), responsive.
6. Báo cáo: danh sách issues (kèm mức độ) + đề xuất sửa + đường dẫn ảnh chụp.
   Nếu có issues → hỏi người dùng có muốn sửa ngay không, rồi sửa và chụp lại verify.
