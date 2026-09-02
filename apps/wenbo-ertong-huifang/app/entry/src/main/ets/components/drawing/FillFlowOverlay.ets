import { Theme } from '../design-system/Theme'
import { LineArtItem, FillRegion, ArtworkItem } from '../../models/DrawModels'
import { LineArtCatalog } from '../../services/LineArtCatalog'
import { FillCanvasPane } from './FillCanvasPane'
import { ColorPaletteBar } from './ColorPaletteBar'
import { GalleryStore } from '../../services/GalleryStore'
import { PrivacySaveDialog } from './PrivacySaveDialog'

const TOP_SAFE: number = 44

enum FillStage {
  List = 0,
  Detail = 1,
  Canvas = 2
}

@Component
export struct FillFlowOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop visible: boolean = false
  onClose: () => void = () => {}
  onSaved: () => void = () => {}

  @State stage: FillStage = FillStage.List
  @State category: string = 'animal'
  @State pickedArt: LineArtItem = new LineArtItem()
  @State regions: FillRegion[] = []
  @State undoStack: FillRegion[][] = []
  @State color: string = '#FF8A65'
  @State hint: string = ''
  @State showPrivacy: boolean = false
  @State canvasTick: number = 0
  @State toast: string = ''
  @State topToolsOpen: boolean = false
  @State bottomToolsOpen: boolean = false

  private showToast(msg: string): void {
    this.toast = msg
    setTimeout(() => { this.toast = '' }, 2600)
  }

  private cloneRegions(src: FillRegion[]): FillRegion[] {
    const out: FillRegion[] = []
    for (const r of src) {
      const c = new FillRegion()
      c.id = r.id
      c.x = r.x
      c.y = r.y
      c.w = r.w
      c.h = r.h
      c.shape = r.shape
      c.fillColor = r.fillColor
      c.colorHintZh = r.colorHintZh
      c.colorHintEn = r.colorHintEn
      out.push(c)
    }
    return out
  }

  private filledCount(): number {
    let n = 0
    for (const r of this.regions) {
      if (r.fillColor !== '#FFFFFF' && r.fillColor.length > 0) {
        n += 1
      }
    }
    return n
  }

  private pushUndo(): void {
    const snap = this.cloneRegions(this.regions)
    const next: FillRegion[][] = []
    for (const u of this.undoStack) {
      next.push(u)
    }
    next.push(snap)
    if (next.length > 15) {
      next.shift()
    }
    this.undoStack = next
  }

  private handleUndo(): void {
    if (this.undoStack.length === 0) {
      this.showToast('没有可撤销的步骤')
      return
    }
    const prev = this.undoStack[this.undoStack.length - 1]
    this.regions = this.cloneRegions(prev)
    const next: FillRegion[][] = []
    for (let i = 0; i < this.undoStack.length - 1; i++) {
      next.push(this.undoStack[i])
    }
    this.undoStack = next
    this.canvasTick += 1
    this.showToast('已撤销')
  }

  private trySave(): void {
    if (this.filledCount() === 0) {
      this.showToast('请先给线稿涂上颜色')
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
    item.id = GalleryStore.newId('fill')
    item.title = this.pickedArt.title
    item.kind = 'fill'
    item.createdAt = GalleryStore.todayLabel()
    item.lineArtId = this.pickedArt.id
    item.fillData = JSON.stringify(this.regions)
    item.accentColor = this.color
    await GalleryStore.addArtwork(item)
    this.showToast('已保存到画廊')
    this.onSaved()
    setTimeout(() => {
      this.stage = FillStage.List
      this.onClose()
    }, 500)
  }

  @Builder
  listPane() {
    Column({ space: Theme.space.s3 }) {
      Row({ space: Theme.space.s2 }) {
        Row() {
          Text('返回').fontSize(14)
        }
        .height(44)
        .padding({ left: 14, right: 14 })
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.pill)
        .onClick((): void => { this.onClose() })

        Text('趣味填色')
          .fontSize(Theme.type.titleM)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
      }
      .width('100%')
      .padding({ left: Theme.space.s4, right: Theme.space.s4, top: TOP_SAFE })

      Scroll() {
        Row({ space: Theme.space.s2 }) {
          ForEach(LineArtCatalog.categories(), (cat: string) => {
            Row() {
              Text(LineArtCatalog.categoryLabel(cat))
                .fontSize(14)
                .fontColor(this.category === cat ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
            }
            .height(40)
            .padding({ left: 14, right: 14 })
            .backgroundColor(this.category === cat ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.pill)
            .onClick((): void => { this.category = cat })
          })
        }
        .padding({ left: Theme.space.s4, right: Theme.space.s4 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)

      List({ space: Theme.space.s3 }) {
        ForEach(LineArtCatalog.byCategory(this.category), (item: LineArtItem) => {
          ListItem() {
            Row({ space: Theme.space.s4 }) {
              Image(LineArtCatalog.mediaResource(item.coverKey))
                .width(72)
                .height(72)
                .borderRadius(Theme.radius.md)
                .objectFit(ImageFit.Cover)
              Column({ space: Theme.space.s1 }) {
                Text(item.title)
                  .fontSize(Theme.type.bodyL)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                Text(item.summary)
                  .fontSize(Theme.type.bodyM)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .maxLines(2)
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)
            .onClick((): void => {
              this.pickedArt = item
              this.stage = FillStage.Detail
            })
          }
        })
      }
      .layoutWeight(1)
      .padding(Theme.space.s4)
    }
  }

  @Builder
  detailPane() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Row() {
          Text('返回列表').fontSize(14)
        }
        .height(40)
        .padding({ left: 12, right: 12 })
        .backgroundColor(Theme.colors().surfaceSubtle)
        .borderRadius(Theme.radius.pill)
        .alignSelf(ItemAlign.Start)
        .onClick((): void => { this.stage = FillStage.List })

        Image(LineArtCatalog.mediaResource(this.pickedArt.coverKey))
          .width('100%')
          .height(200)
          .borderRadius(Theme.radius.lg)
          .objectFit(ImageFit.Cover)
        Text(this.pickedArt.title)
          .fontSize(Theme.type.titleL)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Text(this.pickedArt.description)
          .fontSize(Theme.type.bodyL)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        Row() {
          Text('开始填色')
            .fontSize(16)
            .fontColor(Theme.colors().brandOnPrimary)
        }
        .width('100%')
        .height(48)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Theme.colors().brandPrimary)
        .borderRadius(Theme.radius.pill)
        .onClick((): void => {
          this.regions = this.cloneRegions(this.pickedArt.regions)
          this.undoStack = []
          this.canvasTick += 1
          this.stage = FillStage.Canvas
        })
      }
      .padding(Theme.space.s4)
    }
  }

  @Builder
  canvasPane() {
    Column() {
      Column({ space: Theme.space.s2 }) {
        Row({ space: Theme.space.s2 }) {
          Button('返回')
            .height(36)
            .fontSize(14)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.pill)
            .onClick((): void => { this.stage = FillStage.Detail })

          Text(this.pickedArt.title)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
            .maxLines(1)

          Button('保存')
            .height(36)
            .fontSize(14)
            .fontColor(Theme.colors().brandOnPrimary)
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
            .onClick((): void => { this.trySave() })
        }
        .width('100%')

        Row({ space: Theme.space.s2 }) {
          Text(`已涂 ${this.filledCount()}/${this.regions.length} 块`)
            .fontSize(Theme.type.bodyM)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .layoutWeight(1)

          Button(this.topToolsOpen ? '收起 ▲' : '撤销 ▼')
            .height(32)
            .fontSize(12)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .backgroundColor(Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.pill)
            .onClick((): void => { this.topToolsOpen = !this.topToolsOpen })
        }
        .width('100%')

        if (this.topToolsOpen) {
          Button('撤销上一步')
            .height(36)
            .fontSize(14)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.pill)
            .width('100%')
            .onClick((): void => { this.handleUndo() })
        }

        if (this.hint.length > 0) {
          Text(this.hint)
            .fontSize(Theme.type.bodyM)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
        }
      }
      .width('100%')
      .padding({
        left: Theme.space.s3,
        right: Theme.space.s3,
        top: TOP_SAFE,
        bottom: Theme.space.s2
      })
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      Column() {
        FillCanvasPane({
          regions: this.regions,
          lineArtId: this.pickedArt.id,
          reloadTick: this.canvasTick,
          pickedColor: this.color,
          onRegionsChange: (next: FillRegion[]): void => {
            this.pushUndo()
            this.regions = next
            this.canvasTick += 1
          },
          onColorHint: (zh: string, en: string): void => { this.hint = `推荐：${zh} · ${en}` }
        })
      }
      .layoutWeight(1)
      .width('100%')
      .padding({ left: Theme.space.s2, right: Theme.space.s2, bottom: Theme.space.s2 })

      Column({ space: Theme.space.s2 }) {
        if (this.bottomToolsOpen) {
          ColorPaletteBar({
            picked: this.color,
            onPick: (hex: string): void => { this.color = hex }
          })
        }

        Row({ space: Theme.space.s3 }) {
          Circle()
            .width(28)
            .height(28)
            .fill(this.color)
            .stroke(Theme.colors().strokeHairline)
            .strokeWidth(1)

          Text('点区域填色')
            .fontSize(Theme.type.bodyM)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .layoutWeight(1)

          Button(this.bottomToolsOpen ? '收起色板 ▲' : '色板 ▼')
            .height(36)
            .fontSize(13)
            .fontColor(Theme.colors().brandOnPrimary)
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
            .onClick((): void => { this.bottomToolsOpen = !this.bottomToolsOpen })
        }
        .width('100%')
        .padding({
          left: Theme.space.s3,
          right: Theme.space.s3,
          top: Theme.space.s2,
          bottom: Theme.space.s3
        })
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
      }
    }
    .width('100%')
    .height('100%')
  }

  build() {
    if (!this.visible) {
      Column()
    } else {
      Stack({ alignContent: Alignment.TopStart }) {
        Column() {
          if (this.stage === FillStage.List) {
            this.listPane()
          } else if (this.stage === FillStage.Detail) {
            this.detailPane()
          } else {
            this.canvasPane()
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
