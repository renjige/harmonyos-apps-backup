import { picker, fileIo, fileUri } from '@kit.CoreFileKit'
import { util } from '@kit.ArkTS'
import { ReadingDoc } from '../models/FolioModels'
import { FolioStore } from './FolioStore'
import { PdfTextExtract } from './PdfTextExtract'

export class ImportOutcome {
  doc: ReadingDoc = new ReadingDoc()
  ok: boolean = false
  message: string = ''
}

export class DocImportService {
  static async pickLocal(): Promise<ImportOutcome> {
    const out = new ImportOutcome()
    try {
      const options = new picker.DocumentSelectOptions()
      options.maxSelectNumber = 1
      const viewPicker = new picker.DocumentViewPicker()
      const uris: string[] = await viewPicker.select(options)
      if (uris.length === 0) {
        out.message = '未选择文件'
        return out
      }
      const uri = uris[0]
      const name = DocImportService.displayName(uri)
      const format = DocImportService.guessFormat(name)
      const sandboxPath = DocImportService.copyToSandbox(uri, name)
      let body = ''
      if (format === 'pdf') {
        body = DocImportService.readPdfText(sandboxPath.length > 0 ? sandboxPath : uri)
        if (body.length === 0) {
          body = '【PDF 原文请在阅读页翻页查看。需要记住的句子可复制后点「写入摘录」。】'
        }
      } else {
        body = DocImportService.readText(sandboxPath.length > 0 ? sandboxPath : uri)
      }
      if (body.length > 80000) {
        body = body.substring(0, 80000)
      }
      const title = DocImportService.titleFromName(name)
      out.doc = ReadingDoc.create(title, format, body)
      out.doc.filePath = sandboxPath.length > 0 ? sandboxPath : (format === 'pdf' ? uri : '')
      out.ok = true
      out.message = format === 'pdf' ? '已导入 PDF，可在阅读页翻页查看原文' : ''
      return out
    } catch {
      out.message = '无法读取所选文件'
      return out
    }
  }

  private static displayName(uri: string): string {
    try {
      const fu = new fileUri.FileUri(uri)
      if (fu.name.length > 0) {
        return DocImportService.decodeName(fu.name)
      }
    } catch {
    }
    try {
      const opened = fileIo.openSync(uri, fileIo.OpenMode.READ_ONLY)
      try {
        if (opened.name.length > 0) {
          return DocImportService.decodeName(DocImportService.lastSegment(opened.name))
        }
      } finally {
        fileIo.closeSync(opened)
      }
    } catch {
    }
    return DocImportService.decodeName(DocImportService.lastSegment(uri))
  }

  private static lastSegment(raw: string): string {
    let t = raw
    const q = t.indexOf('?')
    if (q >= 0) {
      t = t.substring(0, q)
    }
    const parts = t.split('/')
    if (parts.length === 0) {
      return '未命名文稿'
    }
    return parts[parts.length - 1]
  }

  private static decodeName(raw: string): string {
    let t = raw.replace(/\+/g, ' ')
    try {
      t = decodeURIComponent(t)
    } catch {
      t = raw
    }
    return t
  }

  private static copyToSandbox(uri: string, displayName: string): string {
    const dir = FolioStore.importsDir()
    if (dir.length === 0) {
      return ''
    }
    try {
      fileIo.mkdirSync(dir, true)
    } catch {
    }
    const dest = `${dir}/${Date.now()}_${DocImportService.safeFilePart(displayName)}`
    try {
      fileIo.copyFileSync(uri, dest)
      return dest
    } catch {
    }
    try {
      DocImportService.copyByReadWrite(uri, dest)
      return dest
    } catch {
      return ''
    }
  }

  private static copyByReadWrite(srcUri: string, destPath: string): void {
    const src = fileIo.openSync(srcUri, fileIo.OpenMode.READ_ONLY)
    try {
      const dest = fileIo.openSync(
        destPath,
        fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE | fileIo.OpenMode.TRUNC
      )
      try {
        const stat = fileIo.statSync(src.fd)
        let remaining = stat.size
        const chunk = 262144
        while (remaining > 0) {
          const n = remaining > chunk ? chunk : remaining
          const buf = new ArrayBuffer(n)
          const read = fileIo.readSync(src.fd, buf)
          if (read <= 0) {
            break
          }
          fileIo.writeSync(dest.fd, new Uint8Array(buf, 0, read))
          remaining = remaining - read
        }
      } finally {
        fileIo.closeSync(dest)
      }
    } finally {
      fileIo.closeSync(src)
    }
  }

  private static safeFilePart(name: string): string {
    let out = ''
    for (let i = 0; i < name.length; i++) {
      const ch = name.charAt(i)
      const code = name.charCodeAt(i)
      const ok = (code >= 0x4e00 && code <= 0x9fff) ||
        (ch >= 'a' && ch <= 'z') || (ch >= 'A' && ch <= 'Z') ||
        (ch >= '0' && ch <= '9') || ch === '.' || ch === '-' || ch === '_'
      out += ok ? ch : '_'
    }
    if (out.length === 0) {
      return `doc_${Date.now()}`
    }
    if (out.length > 80) {
      return out.substring(0, 80)
    }
    return out
  }

  private static readText(uri: string): string {
    const file = fileIo.openSync(uri, fileIo.OpenMode.READ_ONLY)
    try {
      const stat = fileIo.statSync(file.fd)
      let size = stat.size
      if (size > 400000) {
        size = 400000
      }
      const buf = new ArrayBuffer(size)
      fileIo.readSync(file.fd, buf)
      return DocImportService.decodeBytes(new Uint8Array(buf))
    } finally {
      fileIo.closeSync(file)
    }
  }

  private static readPdfText(uri: string): string {
    const file = fileIo.openSync(uri, fileIo.OpenMode.READ_ONLY)
    try {
      const stat = fileIo.statSync(file.fd)
      let size = stat.size
      if (size > 2000000) {
        size = 2000000
      }
      const buf = new ArrayBuffer(size)
      fileIo.readSync(file.fd, buf)
      return PdfTextExtract.fromBytes(buf)
    } finally {
      fileIo.closeSync(file)
    }
  }

  private static decodeBytes(bytes: Uint8Array): string {
    if (bytes.length >= 3 && bytes[0] === 0xEF && bytes[1] === 0xBB && bytes[2] === 0xBF) {
      return DocImportService.decodeEnc(bytes, 'utf-8')
    }
    if (bytes.length >= 2 && bytes[0] === 0xFF && bytes[1] === 0xFE) {
      return DocImportService.decodeEnc(bytes, 'utf-16le')
    }
    if (bytes.length >= 2 && bytes[0] === 0xFE && bytes[1] === 0xFF) {
      return DocImportService.decodeEnc(bytes, 'utf-16be')
    }
    const utf8 = DocImportService.decodeEnc(bytes, 'utf-8')
    if (!DocImportService.looksBroken(utf8)) {
      return utf8
    }
    const gbk = DocImportService.tryDecode(bytes, 'gb18030')
    if (gbk.length > 0 && !DocImportService.looksBroken(gbk)) {
      return gbk
    }
    const gbk2 = DocImportService.tryDecode(bytes, 'gbk')
    if (gbk2.length > 0) {
      return gbk2
    }
    return utf8
  }

  private static tryDecode(bytes: Uint8Array, enc: string): string {
    try {
      return DocImportService.decodeEnc(bytes, enc)
    } catch {
      return ''
    }
  }

  private static decodeEnc(bytes: Uint8Array, enc: string): string {
    const decoder = util.TextDecoder.create(enc)
    return decoder.decodeToString(bytes)
  }

  private static looksBroken(s: string): boolean {
    if (s.length === 0) {
      return true
    }
    let bad = 0
    const n = s.length > 4000 ? 4000 : s.length
    for (let i = 0; i < n; i++) {
      if (s.charCodeAt(i) === 0xFFFD) {
        bad++
      }
    }
    return bad * 20 >= n && bad >= 3
  }

  private static guessFormat(name: string): string {
    const lower = name.toLowerCase()
    if (lower.endsWith('.md') || lower.endsWith('.markdown')) {
      return 'md'
    }
    if (lower.endsWith('.pdf')) {
      return 'pdf'
    }
    return 'txt'
  }

  private static titleFromName(name: string): string {
    let t = name
    const q = t.indexOf('?')
    if (q >= 0) {
      t = t.substring(0, q)
    }
    const dot = t.lastIndexOf('.')
    if (dot > 0) {
      t = t.substring(0, dot)
    }
    t = t.trim()
    if (t.length === 0 || DocImportService.looksGarbledTitle(t)) {
      const d = new Date()
      return `导入文稿 ${d.getMonth() + 1}-${d.getDate()}`
    }
    return t
  }

  private static looksGarbledTitle(s: string): boolean {
    for (let i = 0; i + 2 < s.length; i++) {
      if (s.charAt(i) === '%' && DocImportService.isHex(s.charAt(i + 1)) &&
        DocImportService.isHex(s.charAt(i + 2))) {
        return true
      }
    }
    let bad = 0
    for (let i = 0; i < s.length; i++) {
      const c = s.charCodeAt(i)
      if (c === 0xFFFD || c < 32) {
        bad++
      }
    }
    return s.length > 0 && bad * 2 >= s.length
  }

  private static isHex(ch: string): boolean {
    return (ch >= '0' && ch <= '9') || (ch >= 'a' && ch <= 'f') || (ch >= 'A' && ch <= 'F')
  }
}
