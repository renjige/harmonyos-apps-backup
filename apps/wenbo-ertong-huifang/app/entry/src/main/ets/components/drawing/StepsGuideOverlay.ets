import { Theme } from '../design-system/Theme'
import { DrawStepItem, DrawGuideStep, DrawStroke } from '../../models/DrawModels'
import { LineArtCatalog } from '../../services/LineArtCatalog'
import { BrushRenderer } from '../../services/BrushRenderer'

enum GuideStage {
  List = 0,
  Play = 1
}

@Component
export struct StepsGuideOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop visible: boolean = false
  onClose: () => void = () => {}

  @State stage: GuideStage = GuideStage.List
  @State picked: DrawStepItem = new DrawStepItem()
  @State steps: DrawGuideStep[] = []
  @State stepIndex: number = 0
  @State canvasTick: number = 0

  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
  private canvasW: number = 360
  private canvasH: number = 360

  private openGuide(item: DrawStepItem): void {
    this.picked = item
    this.steps = LineArtCatalog.guideSteps(item.id)
    this.stepIndex = 0
    this.stage = GuideStage.Play
    this.canvasTick += 1
    this.redrawGuide()
  }

  private cumulativeStrokes(): DrawStroke[] {
    const out: DrawStroke[] = []
    for (let i = 0; i <= this.stepIndex && i < this.steps.length; i++) {
      for (const s of this.steps[i].strokes) {
        out.push(s)
      }
    }
    return out
  }

  private redrawGuide(): void {
    this.context.clearRect(0, 0, this.canvasW, this.canvasH)
    this.context.fillStyle = '#FFFFFF'
    this.context.fillRect(0, 0, this.canvasW, this.canvasH)
    const strokes = this.cumulativeStrokes()
    for (const s of strokes) {
      BrushRenderer.paint(this.context, s, this.canvasW, this.canvasH)
    }
  }

  build() {
    if (!this.visible) {
      Column()
    } else {
      Column() {
        Row({ space: Theme.space.s2 }) {
          Row() {
            Text('返回')
              .fontSize(14)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          }
          .height(44)
          .padding({ left: 14, right: 14 })
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.pill)
          .onClick((): void => {
            if (this.stage === GuideStage.Play) {
              this.stage = GuideStage.List
            } else {
              this.onClose()
            }
          })

          Text(this.stage === GuideStage.List ? '智慧引导' : this.picked.title)
            .fontSize(Theme.type.titleM)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .padding(Theme.space.s4)

        if (this.stage === GuideStage.List) {
          List({ space: Theme.space.s3 }) {
            ForEach(LineArtCatalog.drawSteps(), (step: DrawStepItem) => {
              ListItem() {
                Row({ space: Theme.space.s4 }) {
                  Image(LineArtCatalog.mediaResource(step.coverKey))
                    .width(72)
                    .height(72)
                    .borderRadius(Theme.radius.md)
                    .objectFit(ImageFit.Cover)
                  Column({ space: Theme.space.s1 }) {
                    Text(step.title)
                      .fontSize(Theme.type.bodyL)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    Text(`${step.summary} · 共 ${step.stepCount} 步`)
                      .fontSize(Theme.type.bodyM)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)
                }
                .width('100%')
                .padding(Theme.space.s4)
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.lg)
                .onClick((): void => { this.openGuide(step) })
              }
            })
          }
          .layoutWeight(1)
          .padding(Theme.space.s4)
        } else {
          Column({ space: Theme.space.s4 }) {
            Text(`第 ${this.stepIndex + 1} / ${this.steps.length} 步`)
              .fontSize(Theme.type.bodyL)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              .fontWeight(FontWeight.Medium)

            Text(this.steps.length > 0 ? this.steps[this.stepIndex].instruction : '')
              .fontSize(Theme.type.titleM)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')

            Canvas(this.context)
              .width('100%')
              .height(this.canvasH)
              .backgroundColor('#FFFFFF')
              .borderRadius(Theme.radius.lg)
              .onReady((): void => {
                this.redrawGuide()
              })

            Row({ space: Theme.space.s3 }) {
              Row() {
                Text('上一步')
                  .fontSize(15)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              }
              .height(48)
              .layoutWeight(1)
              .justifyContent(FlexAlign.Center)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.pill)
              .opacity(this.stepIndex > 0 ? 1 : 0.4)
              .onClick((): void => {
                if (this.stepIndex > 0) {
                  this.stepIndex -= 1
                  this.redrawGuide()
                }
              })

              Row() {
                Text(this.stepIndex >= this.steps.length - 1 ? '完成' : '下一步')
                  .fontSize(15)
                  .fontColor(Theme.colors().brandOnPrimary)
              }
              .height(48)
              .layoutWeight(1)
              .justifyContent(FlexAlign.Center)
              .backgroundColor(Theme.colors().brandPrimary)
              .borderRadius(Theme.radius.pill)
              .onClick((): void => {
                if (this.stepIndex < this.steps.length - 1) {
                  this.stepIndex += 1
                  this.redrawGuide()
                } else {
                  this.stage = GuideStage.List
                }
              })
            }
            .width('100%')
          }
          .layoutWeight(1)
          .padding(Theme.space.s4)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    }
  }
}
