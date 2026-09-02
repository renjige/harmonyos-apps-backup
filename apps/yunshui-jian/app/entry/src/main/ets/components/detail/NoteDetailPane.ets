import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { YunConfirmDialog } from '../yun/YunConfirmDialog'
import { YunTagChips } from '../yun/YunTagChips'
import { YunSandboxImage } from '../yun/YunSandboxImage'
import { ImagePathUtil } from '../../services/ImagePathUtil'
import { YunNoteItem } from '../../models/YunModels'
import { YunDateHelper, YunLocalStore } from '../../services/YunLocalStore'
import { YunDetailNav } from '../../services/YunDetailNav'

@Component
export struct NoteDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('yunNoteDetailId') @Watch('onNoteIdChange') noteId: string = ''
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @State note: YunNoteItem = new YunNoteItem()
  @State confirmDelete: boolean = false
  onChanged: () => void = () => {}

  aboutToAppear(): void {
    void this.load()
  }

  onNoteIdChange(): void {
    void this.load()
  }

  onRefreshChange(): void {
    if (this.refreshToken > 0) {
      void this.load()
    }
  }

  private async load(): Promise<void> {
    if (this.noteId.length === 0) {
      return
    }
    const item = await YunLocalStore.findNote(this.noteId)
    if (item !== undefined) {
      this.note = item
    }
  }

  private displayTitle(): string {
    if (this.note.title.length > 0) {
      return this.note.title
    }
    if (this.note.body.length > 0) {
      return this.note.summary(16)
    }
    return '札记详情'
  }

  private displayTime(): string {
    const ts = YunDateHelper.effectiveTs(this.note.createdAt, this.note.updatedAt, this.note.id)
    return YunDateHelper.formatDateTime(ts)
  }

  private async doDelete(): Promise<void> {
    this.confirmDelete = false
    await YunLocalStore.deleteNote(this.noteId)
    this.onChanged()
    YunDetailNav.closeNote()
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            if (this.note.imagePaths.length > 0) {
              Image(ImagePathUtil.toDisplayUri(this.note.imagePaths[0]))
                .width('100%')
                .height(200)
                .objectFit(ImageFit.Cover)
                .borderRadius(Theme.radius.lg)
            } else {
              Image($r('app.media.hero_mist_life'))
                .width('100%')
                .height(200)
                .objectFit(ImageFit.Cover)
                .borderRadius(Theme.radius.lg)
            }
            Column({ space: 4 }) {
              Text(this.displayTitle())
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
              Text(this.displayTime())
                .fontSize(Theme.type.footnote)
                .fontColor('#FFFFFF')
              if (this.note.category.length > 0 || this.note.mood.length > 0) {
                Text(`${this.note.category}${this.note.mood.length > 0 ? ' · ' + this.note.mood : ''}`)
                  .fontSize(Theme.type.caption)
                  .fontColor('#FFF8F0')
              }
            }
            .width('100%')
            .padding(Theme.space.s5)
            .linearGradient({
              angle: 180,
              colors: [['rgba(0,0,0,0)', 0], ['rgba(196,120,74,0.85)', 1]]
            })
          }
          .width('100%')
          .height(200)
          .clip(true)
          .borderRadius(Theme.radius.lg)

          if (this.note.tags.length > 0) {
            YunTagChips({ tags: this.note.tags })
          }

          Column({ space: Theme.space.s2 }) {
            Text('摘要')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Text(this.note.summary(120))
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .lineHeight(22)
          }
          .width('100%')
          .padding(Theme.space.cardPadding)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)
          .border({ width: 1, color: Theme.colors().strokeHairline })

          Column({ space: Theme.space.s2 }) {
            Text('正文')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Text(this.note.body.length > 0 ? this.note.body : '（暂无正文）')
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .lineHeight(24)
          }
          .width('100%')
          .padding(Theme.space.cardPadding)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)

          if (this.note.imagePaths.length > 0) {
            Column({ space: Theme.space.s2 }) {
              Text('照片')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(this.note.imagePaths, (path: string) => {
                  YunSandboxImage({
                    srcPath: path,
                    imgWidth: 96,
                    imgHeight: 96,
                    squareFill: false,
                    radius: Theme.radius.sm
                  })
                    .margin({ right: Theme.space.s2, bottom: Theme.space.s2 })
                }, (path: string) => path)
              }
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
          }

          Row({ space: Theme.space.s3 }) {
            Column() {
              AppButton({
                label: '编辑札记',
                variant: 'primary',
                onTap: (): void => { YunDetailNav.openNoteEditor(this.noteId) }
              })
            }
            .layoutWeight(1)
          }
          .width('100%')

          AppButton({
            label: '删除札记',
            variant: 'danger',
            onTap: (): void => { this.confirmDelete = true }
          })
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.s2,
          bottom: Theme.space.s10
        })
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)

      if (this.confirmDelete) {
        YunConfirmDialog({
          title: '删除札记',
          message: '删除后无法恢复。是否继续？',
          confirmLabel: '确认删除',
          danger: true,
          onConfirm: (): void => { void this.doDelete() },
          onCancel: (): void => { this.confirmDelete = false }
        })
      }
    }
    .width('100%')
    .height('100%')
  }
}
