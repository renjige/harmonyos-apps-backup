import { Theme } from '../design-system/Theme'
import { DrawStroke, DrawPoint, ArtworkItem, DotPoint } from '../../models/DrawModels'
import { GalleryStore } from '../../services/GalleryStore'
import { WorkshopDotLinkPane } from './WorkshopDotLinkPane'
import { WorkshopThumbPane } from './WorkshopThumbPane'
import { WorkshopShapePane } from './WorkshopShapePane'
import { WorkshopMarblePane } from './WorkshopMarblePane'
import { ColorPaletteBar } from './ColorPaletteBar'
import { PrivacySaveDialog } from './PrivacySaveDialog'

const TOP_SAFE: number = 44

enum WorkshopMode {
  Hub = 0,
  DotLink = 1,
  Thumb = 2,
  Shape = 3,
  Marble = 4
}

@Component
export struct WorkshopOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop visible: boolean = false
  onClose: () => void = () => {}
  onSaved: () => void = () => {}

  @State mode: WorkshopMode = WorkshopMode.Hub
  @State strokes: DrawStroke[] = []
  @State dots: DotPoint[] = []
  @State dotIndex: number = 0
  @State dotComplete: boolean = false
  @State dotLayoutW: number = 320
  @State dotLayoutH: number = 360
  @State color: string = '#4FC3F7'
  @State shapeId: string = 'circle'
  @State showPrivacy: boolean = false
  @State canvasTick: number = 0
  @State toast: string = ''
  @State kindTag: string = 'workshop'

  aboutToAppear(): void {
    this.resetDots()
  }

  private showToast(msg: string): void {
    this.toast = msg
    setTimeout(() => { this.toast = '' }, 2600)
  }

  private resetDots(): void {
    const list: DotPoint[] = []
    // 归一化坐标：小鱼轮廓，全部落在安全边距内
    const coords: number[][] = [
      [0.22, 0.78],
      [0.38, 0.48],
      [0.52, 0.62],
      [0.68, 0.32],
      [0.78, 0.72]
    ]
    for (let i = 0; i < coords.length; i++) {
      const d = new DotPoint()
      d.id = i + 1
      d.nx = coords[i][0]
      d.ny = coords[i][1]
      d.linked = false
      list.push(d)
    }
    this.dots = list
    this.dotIndex = 0
    this.dotComplete = false
    this.strokes = []
    this.canvasTick += 1
  }

  private dotPixelX(nx: number): number {
    const margin = 36
    return margin + nx * (this.dotLayoutW - margin * 2)
  }

  private dotPixelY(ny: number): number {
    const margin = 36
    return margin + ny * (this.dotLayoutH - margin * 2)
  }

  private enterMode(m: WorkshopMode, tag: string): void {
    this.mode = m
    this.kindTag = tag
    this.strokes = []
    this.canvasTick += 1
    if (m === WorkshopMode.DotLink) {
      this.resetDots()
    }
  }

  private trySave(): void {
    if (this.strokes.length === 0) {
      this.showToast('先完成一点创作再保存')
      return
    }
    if (!GalleryStore.privacyAccepted()) {
      this.showPrivacy = true
      return
    }
    void this.persistWork()
  }

  private async persistWork(): Promise<void> {
    const item = new ArtworkItem()
    item.id = GalleryStore.newId('ws')
    item.title = `${this.modeTitle()} ${GalleryStore.todayLabel()}`
    item.kind = this.kindTag
    item.createdAt = GalleryStore.todayLabel()
    item.strokeData = JSON.stringify(this.strokes)
    item.accentColor = this.color
    await GalleryStore.addArtwork(item)
    this.showToast('已保存到画廊')
    this.onSaved()
    setTimeout(() => {
      this.mode = WorkshopMode.Hub
      this.strokes = []
      this.onClose()
    }, 500)
  }

  private modeTitle(): string {
    if (this.mode === WorkshopMode.DotLink) {
      return '点对点画作'
    }
    if (this.mode === WorkshopMode.Thumb) {
      return '拇指画'
    }
    if (this.mode === WorkshopMode.Shape) {
      return '形状拼贴'
    }
    if (this.mode === WorkshopMode.Marble) {
      return '滚珠轨迹'
    }
    return '工坊作品'
  }

  private markDotLinked(dotId: number): void {
    const next: DotPoint[] = []
    for (const d of this.dots) {
      const c = new DotPoint()
      c.id = d.id
      c.nx = d.nx
      c.ny = d.ny
      c.linked = d.linked || d.id === dotId
      next.push(c)
    }
    this.dots = next
  }

  private addLineStroke(from: DotPoint, to: DotPoint): void {
    const line = new DrawStroke()
    line.tool = 'marker'
    line.color = '#FF8A65'
    line.width = 6
    const p1 = new DrawPoint()
    p1.x = this.dotPixelX(from.nx)
    p1.y = this.dotPixelY(from.ny)
    const p2 = new DrawPoint()
    p2.x = this.dotPixelX(to.nx)
    p2.y = this.dotPixelY(to.ny)
    line.points = [p1, p2]
    const next: DrawStroke[] = []
    for (const s of this.strokes) {
      next.push(s)
    }
    next.push(line)
    this.strokes = next
    this.canvasTick += 1
  }

  private handleDotTap(dotId: number): void {
    if (dotId > 1) {
      this.addLineStroke(this.dots[dotId - 2], this.dots[dotId - 1])
    }
    this.markDotLinked(dotId)
    this.dotIndex = dotId
    if (dotId >= this.dots.length) {
      this.dotComplete = true
      this.showToast('太棒了！连线完成，可以保存啦')
    } else {
      this.showToast(`很好！接下来点击 ${dotId + 1}`)
    }
  }

  private bumpCanvas(): void {
    this.canvasTick += 1
  }

  @Builder
  hubCard(title: string, sub: string, bg: string, action: string) {
    Column({ space: Theme.space.s2 }) {
      Text(title)
        .fontSize(Theme.type.bodyL)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      Text(sub)
        .fontSize(Theme.type.bodyM)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .height(128)
    .justifyContent(FlexAlign.Center)
    .padding(Theme.space.s3)
    .backgroundColor(bg)
    .borderRadius(Theme.radius.xl)
    .shadow({ radius: 8, color: 'rgba(74,74,74,0.08)', offsetY: 3, offsetX: 0 })
    .onClick((): void => {
      if (action === 'dot') {
        this.enterMode(WorkshopMode.DotLink, 'dotlink')
      } else if (action === 'thumb') {
        this.enterMode(WorkshopMode.Thumb, 'thumb')
      } else if (action === 'shape') {
        this.enterMode(WorkshopMode.Shape, 'shape')
      } else if (action === 'marble') {
        this.enterMode(WorkshopMode.Marble, 'marble')
      }
    })
  }

  build() {
    if (!this.visible) {
      Column()
    } else {
      Stack({ alignContent: Alignment.TopStart }) {
        Column() {
          if (this.mode === WorkshopMode.Hub) {
            Column({ space: Theme.space.s4 }) {
              Row() {
                Row() {
                  Text('返回').fontSize(14)
                }
                .height(44)
                .padding({ left: 14, right: 14 })
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => { this.onClose() })

                Text('创意工坊')
                  .fontSize(Theme.type.titleM)
                  .fontWeight(FontWeight.Bold)
                  .layoutWeight(1)
                  .textAlign(TextAlign.Center)
              }
              .padding({ left: Theme.space.s4, right: Theme.space.s4, top: TOP_SAFE })

              Grid() {
                GridItem() { this.hubCard('点对点作画', '按 1→2→3 顺序连数字', '#E3F2FD', 'dot') }
                GridItem() { this.hubCard('拇指画', '每次按压留一个圆点', '#FCE4EC', 'thumb') }
                GridItem() { this.hubCard('形状拼贴', '选形状点一点贴上去', '#E8F5E9', 'shape') }
                GridItem() { this.hubCard('滚珠轨迹', '拖动滚珠留彩线', '#FFF3E0', 'marble') }
              }
              .columnsTemplate('1fr 1fr')
              .rowsGap(Theme.space.s4)
              .columnsGap(Theme.space.s4)
              .padding(Theme.space.s4)
              .layoutWeight(1)
            }
          } else {
            Column() {
              Column({ space: Theme.space.s2 }) {
                Row({ space: Theme.space.s2 }) {
                  Button('返回')
                    .height(40)
                    .fontSize(14)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                    .borderRadius(Theme.radius.pill)
                    .onClick((): void => { this.mode = WorkshopMode.Hub; this.strokes = [] })

                  Blank().layoutWeight(1)

                  Button('保存')
                    .height(40)
                    .fontSize(14)
                    .fontColor(Theme.colors().brandOnPrimary)
                    .backgroundColor(Theme.colors().brandPrimary)
                    .borderRadius(Theme.radius.pill)
                    .onClick((): void => { this.trySave() })
                }
                .width('100%')
              }
              .width('100%')
              .padding({
                left: Theme.space.s4,
                right: Theme.space.s4,
                top: TOP_SAFE,
                bottom: Theme.space.s2
              })

              if (this.mode === WorkshopMode.DotLink) {
                Text(this.dotComplete ? '连线完成！' : `请按顺序点击数字 ${this.dotIndex + 1}`)
                  .fontSize(Theme.type.bodyL)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                  .fontWeight(FontWeight.Medium)
                  .padding({ left: Theme.space.s4, bottom: Theme.space.s2 })

                Column() {
                  WorkshopDotLinkPane({
                    strokes: this.strokes,
                    reloadTick: this.canvasTick,
                    dots: this.dots,
                    nextDotId: this.dotIndex + 1,
                    onDotTap: (id: number): void => { this.handleDotTap(id) },
                    onWrongTap: (): void => { this.showToast(`请先点击 ${this.dotIndex + 1}`) },
                    onCanvasLayout: (w: number, h: number): void => {
                      this.dotLayoutW = w
                      this.dotLayoutH = h
                    }
                  })
                }
                .layoutWeight(1)
                .width('100%')
                .padding({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s3 })
              } else if (this.mode === WorkshopMode.Thumb) {
                Column() {
                  WorkshopThumbPane({
                    strokes: $strokes,
                    reloadTick: this.canvasTick,
                    color: this.color,
                    canvasW: 360,
                    canvasH: 440,
                    onStamp: (): void => { this.bumpCanvas() }
                  })
                }
                .layoutWeight(1)
                .padding(Theme.space.s4)

                ColorPaletteBar({
                  picked: this.color,
                  onPick: (hex: string): void => { this.color = hex }
                })
              } else if (this.mode === WorkshopMode.Shape) {
                Scroll() {
                  Row({ space: Theme.space.s2 }) {
                    ForEach(['circle', 'square', 'triangle', 'star'], (sid: string) => {
                      Row() {
                        Text(sid === 'circle' ? '圆' : (sid === 'square' ? '方' : (sid === 'triangle' ? '三角' : '星')))
                          .fontSize(14)
                          .fontColor(this.shapeId === sid ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                      }
                      .height(40)
                      .padding({ left: 14, right: 14 })
                      .backgroundColor(this.shapeId === sid ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                      .borderRadius(Theme.radius.pill)
                      .onClick((): void => { this.shapeId = sid })
                    })
                  }
                  .padding({ left: Theme.space.s4, right: Theme.space.s4 })
                }
                .scrollable(ScrollDirection.Horizontal)
                .scrollBar(BarState.Off)

                Column() {
                  WorkshopShapePane({
                    strokes: $strokes,
                    reloadTick: this.canvasTick,
                    color: this.color,
                    shapeId: this.shapeId,
                    canvasW: 360,
                    canvasH: 400,
                    onStamp: (): void => { this.bumpCanvas() }
                  })
                }
                .layoutWeight(1)
                .padding(Theme.space.s4)

                ColorPaletteBar({
                  picked: this.color,
                  onPick: (hex: string): void => { this.color = hex }
                })
              } else {
                Column() {
                  WorkshopMarblePane({
                    strokes: $strokes,
                    reloadTick: this.canvasTick,
                    color: this.color,
                    canvasW: 360,
                    canvasH: 440
                  })
                }
                .layoutWeight(1)
                .padding(Theme.space.s4)

                ColorPaletteBar({
                  picked: this.color,
                  onPick: (hex: string): void => { this.color = hex }
                })
              }
            }
            .layoutWeight(1)
          }
        }
        .width('100%')
        .height('100%')
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

        PrivacySaveDialog({
          visible: this.showPrivacy,
          onAccepted: (): void => { void this.persistWork(); this.showPrivacy = false },
          onCancel: (): void => { this.showPrivacy = false }
        })

        if (this.toast.length > 0) {
          Text(this.toast)
            .fontSize(14)
            .fontColor('#FFFFFF')
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandDeep)
            .borderRadius(Theme.radius.pill)
            .margin({ top: TOP_SAFE + 52 })
            .zIndex(80)
        }
      }
      .width('100%')
      .height('100%')
    }
  }
}
