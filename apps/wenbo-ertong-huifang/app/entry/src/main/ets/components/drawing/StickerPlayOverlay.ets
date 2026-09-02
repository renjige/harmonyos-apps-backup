import { Theme } from '../design-system/Theme'
import { StickerPlacement, StickerDef, ArtworkItem } from '../../models/DrawModels'
import { StickerCatalog } from '../../services/StickerCatalog'
import { StickerCanvasPane } from './StickerCanvasPane'
import { ColorPaletteBar } from './ColorPaletteBar'
import { GalleryStore } from '../../services/GalleryStore'
import { PrivacySaveDialog } from './PrivacySaveDialog'

const TOP_SAFE: number = 44

@Component
export struct StickerPlayOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop visible: boolean = false
  onClose: () => void = () => {}
  onSaved: () => void = () => {}

  @State category: string = 'cute'
  @State pickedStickerId: string = 'st_heart'
  @State pickedColor: string = '#F06292'
  @State sizeKey: string = 'mid'
  @State placements: StickerPlacement[] = []
  @State undoStack: StickerPlacement[][] = []
  @State panelOpen: boolean = true
  @State topToolsOpen: boolean = false
  @State canvasTick: number = 0
  @State showPrivacy: boolean = false
  @State toast: string = ''

  aboutToAppear(): void {
    const first = StickerCatalog.byCategory('cute')
    if (first.length > 0) {
      this.pickedStickerId = first[0].id
      this.pickedColor = first[0].defaultColor
    }
  }

  private showToast(msg: string): void {
    this.toast = msg
    setTimeout(() => { this.toast = '' }, 2600)
  }

  private cloneList(src: StickerPlacement[]): StickerPlacement[] {
    const out: StickerPlacement[] = []
    for (const s of src) {
      const c = new StickerPlacement()
      c.id = s.id
      c.stickerId = s.stickerId
      c.nx = s.nx
      c.ny = s.ny
      c.color = s.color
      c.sizeKey = s.sizeKey
      out.push(c)
    }
    return out
  }

  private pushUndo(): void {
    const snap = this.cloneList(this.placements)
    const next: StickerPlacement[][] = []
    for (const u of this.undoStack) {
      next.push(u)
    }
    next.push(snap)
    if (next.length > 20) {
      next.shift()
    }
    this.undoStack = next
  }

  private handleUndo(): void {
    if (this.undoStack.length === 0) {
      this.showToast('没有可撤销的贴纸')
      return
    }
    const prev = this.undoStack[this.undoStack.length - 1]
    this.placements = this.cloneList(prev)
    const next: StickerPlacement[][] = []
    for (let i = 0; i < this.undoStack.length - 1; i++) {
      next.push(this.undoStack[i])
    }
    this.undoStack = next
    this.canvasTick += 1
    this.showToast('已撤销')
  }

  private handleClear(): void {
    if (this.placements.length === 0) {
      return
    }
    this.pushUndo()
    this.placements = []
    this.canvasTick += 1
    this.showToast('画布已清空')
  }

  private handleTapCanvas(nx: number, ny: number): void {
    if (nx < 0.02 || nx > 0.98 || ny < 0.02 || ny > 0.98) {
      return
    }
    this.pushUndo()
    const p = new StickerPlacement()
    p.id = GalleryStore.newId('stk')
    p.stickerId = this.pickedStickerId
    p.nx = nx
    p.ny = ny
    p.color = this.pickedColor
    p.sizeKey = this.sizeKey
    const next = this.cloneList(this.placements)
    next.push(p)
    this.placements = next
    this.canvasTick += 1
  }

  private pickSticker(def: StickerDef): void {
    this.pickedStickerId = def.id
    this.pickedColor = def.defaultColor
  }

  private stickerLabel(): string {
    const def = StickerCatalog.find(this.pickedStickerId)
    if (def !== null) {
      return def.label
    }
    return '贴纸'
  }

  private trySave(): void {
    if (this.placements.length === 0) {
      this.showToast('先贴几个贴纸再保存吧')
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
    item.id = GalleryStore.newId('stk-art')
    item.title = `贴纸画 ${GalleryStore.todayLabel()}`
    item.kind = 'sticker'
    item.createdAt = GalleryStore.todayLabel()
    item.strokeData = JSON.stringify(this.placements)
    item.accentColor = this.pickedColor
    await GalleryStore.addArtwork(item)
    this.showToast('已保存到画廊')
    this.onSaved()
    setTimeout(() => { this.onClose() }, 600)
  }

  build() {
    if (!this.visible) {
      Column()
    } else {
      Stack({ alignContent: Alignment.Top }) {
        Column() {
          Column({ space: Theme.space.s2 }) {
            Row({ space: Theme.space.s2 }) {
              Button('返回')
                .height(36)
                .fontSize(14)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => { this.onClose() })

              Text('魔法贴纸')
                .fontSize(15)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .layoutWeight(1)
                .textAlign(TextAlign.Center)

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
              Text(`已贴 ${this.placements.length} 个`)
                .fontSize(Theme.type.bodyM)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                .layoutWeight(1)

              Button(this.topToolsOpen ? '收起 ▲' : '编辑 ▼')
                .height(32)
                .fontSize(12)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .backgroundColor(Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => { this.topToolsOpen = !this.topToolsOpen })
            }
            .width('100%')

            if (this.topToolsOpen) {
              Row({ space: Theme.space.s2 }) {
                Button('撤销')
                  .height(36)
                  .fontSize(13)
                  .layoutWeight(1)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                  .borderRadius(Theme.radius.pill)
                  .onClick((): void => { this.handleUndo() })

                Button('清空')
                  .height(36)
                  .fontSize(13)
                  .layoutWeight(1)
                  .fontColor(Theme.colors().danger)
                  .backgroundColor(Theme.colors().dangerContainer)
                  .borderRadius(Theme.radius.pill)
                  .onClick((): void => { this.handleClear() })
              }
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
            StickerCanvasPane({
              items: this.placements,
              reloadTick: this.canvasTick,
              onTapCanvas: (nx: number, ny: number): void => { this.handleTapCanvas(nx, ny) }
            })
          }
          .layoutWeight(1)
          .width('100%')
          .padding({ left: Theme.space.s2, right: Theme.space.s2, bottom: Theme.space.s2 })

          Column({ space: Theme.space.s2 }) {
            if (this.panelOpen) {
              Scroll() {
                Row({ space: Theme.space.s2 }) {
                  ForEach(StickerCatalog.categories(), (cat: string) => {
                    Button(StickerCatalog.categoryLabel(cat))
                      .height(34)
                      .fontSize(13)
                      .fontColor(this.category === cat ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                      .backgroundColor(this.category === cat ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                      .borderRadius(Theme.radius.pill)
                      .onClick((): void => { this.category = cat })
                  })
                }
                .padding({ left: Theme.space.s3, right: Theme.space.s3 })
              }
              .scrollable(ScrollDirection.Horizontal)
              .scrollBar(BarState.Off)
              .height(42)

              Scroll() {
                Row({ space: Theme.space.s2 }) {
                  ForEach(StickerCatalog.byCategory(this.category), (def: StickerDef) => {
                    Button(def.label)
                      .height(36)
                      .fontSize(13)
                      .fontColor(this.pickedStickerId === def.id ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                      .backgroundColor(this.pickedStickerId === def.id ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
                      .borderRadius(Theme.radius.pill)
                      .onClick((): void => { this.pickSticker(def) })
                  })
                }
                .padding({ left: Theme.space.s3, right: Theme.space.s3 })
              }
              .scrollable(ScrollDirection.Horizontal)
              .scrollBar(BarState.Off)
              .height(44)

              Row({ space: Theme.space.s2 }) {
                ForEach(['small', 'mid', 'large'], (k: string) => {
                  Button(k === 'small' ? '小' : (k === 'large' ? '大' : '中'))
                    .height(34)
                    .fontSize(13)
                    .fontColor(this.sizeKey === k ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                    .backgroundColor(this.sizeKey === k ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                    .borderRadius(Theme.radius.pill)
                    .layoutWeight(1)
                    .onClick((): void => { this.sizeKey = k })
                })
              }
              .padding({ left: Theme.space.s3, right: Theme.space.s3 })

              ColorPaletteBar({
                picked: this.pickedColor,
                onPick: (hex: string): void => { this.pickedColor = hex }
              })
            }

            Row({ space: Theme.space.s3 }) {
              Text(this.stickerLabel())
                .fontSize(Theme.type.bodyM)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .layoutWeight(1)

              Text('点画布贴贴纸')
                .fontSize(Theme.type.bodyM)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)

              Button(this.panelOpen ? '收起 ▲' : '贴纸 ▼')
                .height(36)
                .fontSize(13)
                .fontColor(Theme.colors().brandOnPrimary)
                .backgroundColor(Theme.colors().brandPrimary)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => { this.panelOpen = !this.panelOpen })
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
