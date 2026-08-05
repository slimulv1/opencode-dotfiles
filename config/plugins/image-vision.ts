import type { Plugin } from "@opencode-ai/plugin"

let analyzing = false
const VISION_TIMEOUT_MS = 90000

function extractDescription(parts: any[]): string {
  return parts
    .filter((p: any) => p.type === "text")
    .map((p: any) => p.text)
    .join("\n")
}

/**
 * ImageVision plugin — khi người dùng gửi ảnh, gọi vision agent (mimo-v2.5-free)
 * để phân tích ảnh ngay lập tức, rồi thay part ảnh bằng part text mô tả
 * (model chính text-only không đọc được ảnh trực tiếp).
 *
 * Chống đệ quy: cờ `analyzing` + bỏ qua khi `input.agent === "vision"`
 * + session tạm riêng biệt (tạo → prompt → xóa).
 * Nếu vision model lỗi/không khả dụng: giữ nguyên part ảnh gốc, không phá message.
 */
export const ImageVision: Plugin = async ({ client, directory }) => {
  return {
    "chat.message": async (input: any, output: any) => {
      if (analyzing || input.agent === "vision") return

      const imgs = output.parts.filter(
        (p: any) =>
          p.type === "file" &&
          p.mime?.startsWith("image/") &&
          typeof p.url === "string"
      )
      if (imgs.length === 0) return

      analyzing = true
      let desc = ""
      let tmpId = ""
      try {
        const created = await client.session.create({ query: { directory } })
        if (created.error || !created.data?.id) throw new Error("cannot create session")
        tmpId = created.data.id
        const res: any = await Promise.race([
          client.session.prompt({
            path: { id: tmpId },
            body: {
              agent: "vision",
              parts: imgs.map((p: any) => ({
                type: "file",
                mime: p.mime,
                filename: p.filename,
                url: p.url,
              })),
            },
          }),
          new Promise((_, rej) =>
            setTimeout(() => rej(new Error("vision timeout")), VISION_TIMEOUT_MS)
          ),
        ])
        if (res.error) throw res.error
        desc = extractDescription(res.data?.parts ?? [])
      } catch {
        // giữ nguyên part gốc khi vision thất bại
      } finally {
        if (tmpId) client.session.delete({ path: { id: tmpId } }).catch(() => {})
        analyzing = false
      }

      if (desc) {
        const rest = output.parts.filter((p: any) => !imgs.includes(p))
        output.parts = [
          ...rest,
          {
            type: "text",
            text: `[Vision analysis của ảnh đính kèm]\n${desc}`,
            synthetic: true,
          },
        ]
      }
    },
  }
}
