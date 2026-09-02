import { webview } from '@kit.ArkWeb'
import { fileUri } from '@kit.CoreFileKit'

@Component
export struct PdfReaderView {
  @Prop filePath: string = ''
  private controller: webview.WebviewController = new webview.WebviewController()

  private src(): string {
    if (this.filePath.length === 0) {
      return ''
    }
    if (this.filePath.startsWith('file://')) {
      return this.filePath
    }
    return fileUri.getUriFromPath(this.filePath)
  }

  build() {
    Web({ src: this.src(), controller: this.controller })
      .width('100%')
      .height('100%')
      .fileAccess(true)
      .domStorageAccess(true)
      .javaScriptAccess(true)
  }
}
