import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { PuzzlePiece, TravelPuzzle } from '../../models/PuzzleModels'
import { PuzzleLayoutGrid } from '../puzzle/PuzzleLayoutGrid'
import { PuzzleStore } from '../../services/PuzzleStore'
import { PuzzleNav } from '../../services/PuzzleNav'

@Component
export struct PuzzleDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop puzzleId: string = ''
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  onToast: (text: string) => void = (text: string) => {}
  onBack: () => void = () => {}

  @State puzzle: TravelPuzzle = new TravelPuzzle()
  @State tagInput: string = ''

  aboutToAppear(): void {
    this.reload()
  }

  onRefreshChange(): void {
    this.reload()
  }

  private reload(): void {
    const found = PuzzleStore.findPuzzle(this.puzzleId)
    if (found !== null) {
      this.puzzle = found
    }
  }

  private dateText(ts: number): string {
    if (ts <= 0) {
      return ''
    }
    const d = new Date(ts)
    const m = d.getMonth() + 1
    const day = d.getDate()
    const h = d.getHours()
    const min = d.getMinutes()
    return `${d.getFullYear()}-${m < 10 ? '0' + m : m}-${day < 10 ? '0' + day : day} ${h < 10 ? '0' + h : h}:${min < 10 ? '0' + min : min}`
  }

  private async toggleFavorite(): Promise<void> {
    const ok = await PuzzleStore.toggleFavorite(this.puzzle.id)
    if (!ok) {
      this.onToast('操作失败，请稍后再试')
      return
    }
    this.reload()
    this.onToast(this.puzzle.favorited ? '已加入收藏' : '已取消收藏')
  }

  private async addTag(): Promise<void> {
    const name = this.tagInput.trim()
    if (name.length === 0) {
      return
    }
    await PuzzleStore.addTag(name)
    const tags: string[] = []
    for (const t of this.puzzle.tags) {
      tags.push(t)
    }
    let exists = false
    for (const t of tags) {
      if (t === name) {
        exists = true
        break
      }
    }
    if (!exists) {
      tags.push(name)
    }
    this.puzzle.tags = tags
    this.puzzle.updatedAt = Date.now()
    await PuzzleStore.savePuzzle(this.puzzle)
    this.tagInput = ''
    this.reload()
    this.onToast('标签已添加')
  }

  private async deletePuzzle(): Promise<void> {
    const ok = await PuzzleStore.deletePuzzle(this.puzzle.id)
    if (!ok) {
      this.onToast('删除失败，请稍后再试')
      return
    }
    this.onToast('拼图已删除')
    PuzzleNav.closeDetail()
    this.onBack()
  }

  build() {
    Column() {
      Row() {
        AppIcon({ name: 'chevron', iconSize: Theme.icon.lg, color: Theme.colors().textPrimary })
          .rotate({ angle: 180 })
          .onClick(() => {
            PuzzleNav.closeDetail()
            this.onBack()
          })
        Text('拼图详情')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
          .margin({ left: Theme.space.s2 })
        AppIcon({
          name: 'heart',
          iconSize: Theme.icon.lg,
          color: this.puzzle.favorited ? Theme.colors().brandPrimary : Theme.colors().textSecondary,
          active: this.puzzle.favorited
        })
          .onClick((): void => { void this.toggleFavorite() })
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.pageY })

      Scroll() {
        Column() {
          Stack({ alignContent: Alignment.BottomStart }) {
            if (this.puzzle.pieces.length > 0 && this.puzzle.pieces[0].imageUri.length > 0) {
              Image(this.puzzle.pieces[0].imageUri)
                .width('100%')
                .height(200)
                .objectFit(ImageFit.Cover)
                .borderRadius(Theme.radius.lg)
            } else {
              Image($r('app.media.hero_bg'))
                .width('100%')
                .height(200)
                .objectFit(ImageFit.Cover)
                .borderRadius(Theme.radius.lg)
            }
            Column()
              .width('100%')
              .height(200)
              .borderRadius(Theme.radius.lg)
              .linearGradient({
                angle: 180,
                colors: [['rgba(0,0,0,0)', 0], ['rgba(45,58,74,0.72)', 1]]
              })
            Column() {
              Text(this.puzzle.title.length > 0 ? this.puzzle.title : '旅行拼图')
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
              Text(this.puzzle.location.length > 0 ? this.puzzle.location : '地点未填写')
                .fontSize(Theme.type.subhead)
                .fontColor('#FFFFFF')
                .margin({ top: Theme.space.s1 })
            }
            .padding(Theme.space.s4)
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .margin({ bottom: Theme.space.s4 })

          Text('拼图预览')
            .fontSize(Theme.type.subtitleM)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          PuzzleLayoutGrid({
            layoutType: this.puzzle.layoutType,
            pieces: this.puzzle.pieces,
            compact: false
          })
            .margin({ top: Theme.space.s3, bottom: Theme.space.s5 })

          Text('时间轴碎片')
            .fontSize(Theme.type.subtitleM)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')

          ForEach(this.puzzle.pieces, (piece: PuzzlePiece) => {
            Row() {
              if (piece.imageUri.length > 0) {
                Image(piece.imageUri)
                  .width(72)
                  .height(72)
                  .borderRadius(Theme.radius.sm)
                  .objectFit(ImageFit.Cover)
              }
              Column() {
                Text(piece.caption.length > 0 ? piece.caption : '（无文字）')
                  .fontSize(Theme.type.subhead)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .maxLines(2)
                Text(piece.location.length > 0 ? piece.location : this.puzzle.location)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .margin({ top: Theme.space.s1 })
                Text(this.dateText(piece.takenAt))
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textTertiary)
                  .margin({ top: Theme.space.s1 })
              }
              .layoutWeight(1)
              .margin({ left: Theme.space.s3 })
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .padding(Theme.space.s3)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .margin({ top: Theme.space.s3 })
          }, (piece: PuzzlePiece) => piece.id)

          if (this.puzzle.tags.length > 0) {
            Text('标签')
              .fontSize(Theme.type.subtitleM)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
              .margin({ top: Theme.space.s5 })
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.puzzle.tags, (tag: string) => {
                Text(tag)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                  .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                  .backgroundColor(Theme.colors().brandPrimaryContainer)
                  .borderRadius(Theme.radius.tag)
                  .margin({ right: Theme.space.s2, top: Theme.space.s2 })
              }, (tag: string) => tag)
            }
            .width('100%')
          }

          Row() {
            TextInput({ text: this.tagInput, placeholder: '添加标签，如海岛' })
              .layoutWeight(1)
              .onChange((v: string) => { this.tagInput = v })
            AppButton({
              label: '添加',
              variant: 'secondary',
              onTap: (): void => { void this.addTag() }
            })
              .width(88)
              .margin({ left: Theme.space.s2 })
          }
          .width('100%')
          .margin({ top: Theme.space.s4 })

          AppButton({
            label: '删除此拼图',
            variant: 'danger',
            onTap: (): void => { void this.deletePuzzle() }
          })
            .margin({ top: Theme.space.s6, bottom: Theme.space.s10 })
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
