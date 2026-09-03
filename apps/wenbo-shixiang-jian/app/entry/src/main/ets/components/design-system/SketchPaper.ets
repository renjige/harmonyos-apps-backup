import { Theme } from './Theme'
import { SketchStyle } from './SketchStyle'

/** 网格纸背景 + 内容区 */
@Component
export struct SketchPaper {
  @BuilderParam content: () => void = this.defaultContent
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
  @State canvasW: number = 0
  @State canvasH: number = 0

  @Builder
  defaultContent() {
  }

  private drawGrid(): void {
    if (this.canvasW <= 0 || this.canvasH <= 0) {
      return
    }
    const ctx = this.context
    ctx.clearRect(0, 0, this.canvasW, this.canvasH)
    ctx.strokeStyle = SketchStyle.gridLine()
    ctx.lineWidth = 1
    const step = 24
    let x = 0
    while (x <= this.canvasW) {
      ctx.beginPath()
      ctx.moveTo(x, 0)
      ctx.lineTo(x, this.canvasH)
      ctx.stroke()
      x += step
    }
    let y = 0
    while (y <= this.canvasH) {
      ctx.beginPath()
      ctx.moveTo(0, y)
      ctx.lineTo(this.canvasW, y)
      ctx.stroke()
      y += step
    }
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Canvas(this.context)
        .width('100%')
        .height('100%')
        .onReady((): void => {
          this.drawGrid()
        })
        .onAreaChange((_old: Area, area: Area): void => {
          this.canvasW = area.width as number
          this.canvasH = area.height as number
          this.drawGrid()
        })
      Column() {
        this.content()
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .layoutWeight(1)
    .backgroundColor(Theme.colors().surfacePage)
  }
}
