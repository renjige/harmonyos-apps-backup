import { common } from '@kit.AbilityKit'
import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { LayoutOption, PuzzlePiece, TravelPuzzle } from '../models/PuzzleModels'
import { PuzzleLayoutGrid } from '../components/puzzle/PuzzleLayoutGrid'
import { PhotoPickService } from '../services/PhotoPickService'
import { PuzzleStore } from '../services/PuzzleStore'
import { PuzzleNav } from '../services/PuzzleNav'

@Component
export struct PuzzleCreatePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop editId: string = ''
  @Prop refreshToken: number = 0
  onToast: (text: string) => void = (text: string) => {}
  onDone: () => void = () => {}

  @State title: string = ''
  @State location: string = ''
  @State layoutType: string = 'grid-4'
  @State pieces: PuzzlePiece[] = []
  @State saving: boolean = false
  @State errorText: string = ''
  private layouts: LayoutOption[] = LayoutOption.all()
  private uiContext: common.UIAbilityContext | null = null

  aboutToAppear(): void {
    if (this.editId.length > 0) {
      const found = PuzzleStore.findPuzzle(this.editId)
      if (found !== null) {
        this.title = found.title
        this.location = found.location
        this.layoutType = found.layoutType
        this.pieces = found.pieces
      }
    }
  }

  private layoutNeed(): number {
    const opt = LayoutOption.find(this.layoutType)
    if (opt !== null) {
      return opt.maxPhotos
    }
    return 4
  }

  private async pickPhotos(): Promise<void> {
    if (this.uiContext === null) {
      return
    }
    const need = this.layoutNeed()
    const uris = await PhotoPickService.pickImages(this.uiContext, need)
    if (uris.length === 0) {
      return
    }
    const list: PuzzlePiece[] = []
    for (let i = 0; i < uris.length; i++) {
      list.push(PuzzleStore.newPiece(uris[i], i))
    }
    this.pieces = list
    this.errorText = ''
  }

  private updateCaption(pieceId: string, value: string): void {
    const trimmed = value.length > 30 ? value.substring(0, 30) : value
    const next: PuzzlePiece[] = []
    for (const p of this.pieces) {
      if (p.id === pieceId) {
        const copy = new PuzzlePiece()
        copy.id = p.id
        copy.imageUri = p.imageUri
        copy.caption = trimmed
        copy.location = p.location
        copy.takenAt = p.takenAt
        next.push(copy)
      } else {
        next.push(p)
      }
    }
    this.pieces = next
  }

  private updatePieceLocation(pieceId: string, value: string): void {
    const next: PuzzlePiece[] = []
    for (const p of this.pieces) {
      if (p.id === pieceId) {
        const copy = new PuzzlePiece()
        copy.id = p.id
        copy.imageUri = p.imageUri
        copy.caption = p.caption
        copy.location = value
        copy.takenAt = p.takenAt
        next.push(copy)
      } else {
        next.push(p)
      }
    }
    this.pieces = next
  }

  private async savePuzzle(): Promise<void> {
    if (this.saving) {
      return
    }
    const need = this.layoutNeed()
    if (this.pieces.length < need) {
      this.errorText = `请为「${LayoutOption.find(this.layoutType)?.label ?? ''}」选择 ${need} 张照片`
      return
    }
    if (this.title.trim().length === 0) {
      this.errorText = '请填写拼图标题'
      return
    }
    this.saving = true
    const puzzle = new TravelPuzzle()
    if (this.editId.length > 0) {
      puzzle.id = this.editId
      const old = PuzzleStore.findPuzzle(this.editId)
      puzzle.favorited = old !== null ? old.favorited : false
      puzzle.createdAt = old !== null ? old.createdAt : Date.now()
      puzzle.tags = old !== null ? old.tags : []
    } else {
      puzzle.id = PuzzleStore.newId()
      puzzle.createdAt = Date.now()
      puzzle.favorited = false
      puzzle.tags = []
    }
    puzzle.title = this.title.trim()
    puzzle.location = this.location.trim()
    puzzle.layoutType = this.layoutType
    puzzle.pieces = this.pieces
    puzzle.updatedAt = Date.now()
    const ok = await PuzzleStore.savePuzzle(puzzle)
    this.saving = false
    if (!ok) {
      this.errorText = '保存失败，请稍后再试'
      return
    }
    this.onToast('拼图已保存到本机')
    PuzzleNav.closeCreate()
    this.onDone()
  }

  build() {
    Column() {
      Row() {
        AppIcon({ name: 'chevron', iconSize: Theme.icon.lg, color: Theme.colors().textPrimary })
          .rotate({ angle: 180 })
          .onClick(() => {
            PuzzleNav.closeCreate()
            this.onDone()
          })
        Text(this.editId.length > 0 ? '编辑拼图' : '创建拼图')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
          .margin({ left: Theme.space.s2 })
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.pageY })

      if (this.errorText.length > 0) {
        Text(this.errorText)
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().danger)
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s2 })
      }

      Scroll() {
        Column() {
          Text('拼图标题')
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          TextInput({ text: this.title, placeholder: '如：夏日海岛之旅' })
            .width('100%')
            .margin({ top: Theme.space.s2 })
            .onChange((v: string) => { this.title = v })

          Text('旅行地点')
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
            .margin({ top: Theme.space.s5 })
          TextInput({ text: this.location, placeholder: '如：厦门 · 鼓浪屿' })
            .width('100%')
            .margin({ top: Theme.space.s2 })
            .onChange((v: string) => { this.location = v })

          Text('布局模板')
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
            .margin({ top: Theme.space.s5 })

          Scroll() {
            Row({ space: Theme.space.s2 }) {
              ForEach(this.layouts, (opt: LayoutOption) => {
                Column() {
                  Text(opt.label)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.layoutType === opt.id ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                  Text(`${opt.maxPhotos} 张`)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.layoutType === opt.id ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                    .margin({ top: 2 })
                }
                .padding({ left: 14, right: 14, top: 10, bottom: 10 })
                .backgroundColor(this.layoutType === opt.id ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.md)
                .onClick(() => {
                  this.layoutType = opt.id
                  if (this.pieces.length > opt.maxPhotos) {
                    const trimmed: PuzzlePiece[] = []
                    for (let i = 0; i < opt.maxPhotos; i++) {
                      trimmed.push(this.pieces[i])
                    }
                    this.pieces = trimmed
                  }
                })
              }, (opt: LayoutOption) => opt.id)
            }
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .width('100%')
          .margin({ top: Theme.space.s2 })

          Row() {
            Text(`已选 ${this.pieces.length} / ${this.layoutNeed()} 张`)
              .fontSize(Theme.type.subhead)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .layoutWeight(1)
            AppButton({
              label: '选择照片',
              variant: 'secondary',
              onTap: (): void => { void this.pickPhotos() }
            })
              .width(120)
          }
          .width('100%')
          .margin({ top: Theme.space.s5 })

          PuzzleLayoutGrid({
            layoutType: this.layoutType,
            pieces: this.pieces,
            compact: false
          })
            .margin({ top: Theme.space.s3 })

          ForEach(this.pieces, (piece: PuzzlePiece) => {
            Column() {
              Row() {
                if (piece.imageUri.length > 0) {
                  Image(piece.imageUri)
                    .width(56)
                    .height(56)
                    .borderRadius(Theme.radius.sm)
                    .objectFit(ImageFit.Cover)
                }
                Text('旅行碎片')
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .margin({ left: Theme.space.s3 })
              }
              .width('100%')
              TextInput({ text: piece.caption, placeholder: '写下这一瞬间（限30字）' })
                .width('100%')
                .margin({ top: Theme.space.s2 })
                .onChange((v: string) => { this.updateCaption(piece.id, v) })
              TextInput({ text: piece.location, placeholder: '地点（可选，默认同上方旅行地点）' })
                .width('100%')
                .margin({ top: Theme.space.s2 })
                .onChange((v: string) => { this.updatePieceLocation(piece.id, v) })
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .margin({ top: Theme.space.s3 })
          }, (piece: PuzzlePiece) => piece.id)

          AppButton({
            label: this.saving ? '保存中…' : '完成拼图',
            disabled: this.saving,
            onTap: (): void => { void this.savePuzzle() }
          })
            .margin({ top: Theme.space.s6, bottom: Theme.space.s10 })
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .onAppear((): void => {
      const host = this.getUIContext().getHostContext()
      if (host !== undefined) {
        this.uiContext = host as common.UIAbilityContext
      }
    })
  }
}
