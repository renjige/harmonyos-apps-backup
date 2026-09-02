import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { ZhaConfirmDialog } from '../zha/ZhaConfirmDialog'
import { ZhaNoteItem } from '../../models/ZhaModels'
import { ZhaDateHelper, ZhaLocalStore } from '../../services/ZhaLocalStore'
import { ZhaDetailNav } from '../../services/ZhaDetailNav'

@Component
export struct NoteDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onNoteIdChange') noteId: string = ''
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @State note: ZhaNoteItem = new ZhaNoteItem()
  @State convertHint: string = ''
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
    const item = await ZhaLocalStore.findNote(this.noteId)
    if (item !== undefined) {
      this.note = item
    }
  }

  private formatTime(ts: number): string {
    const d = new Date(ts)
    const hh = d.getHours()
    const mm = d.getMinutes()
    const hs = hh < 10 ? `0${hh}` : `${hh}`
    const ms = mm < 10 ? `0${mm}` : `${mm}`
    return `${d.getFullYear()}-${d.getMonth() + 1}-${d.getDate()} ${hs}:${ms}`
  }

  private async convertToTodo(): Promise<void> {
    const text = this.note.title.length > 0 ? this.note.title : this.note.body.substring(0, 40)
    if (text.length === 0) {
      this.convertHint = '正文为空，无法转为待办'
      setTimeout(() => { this.convertHint = '' }, 2000)
      return
    }
    await ZhaLocalStore.createTodo(text, 'medium', ZhaDateHelper.todayKey())
    this.convertHint = '已加入待办清单'
    this.onChanged()
    setTimeout(() => { this.convertHint = '' }, 2000)
  }

  private async doDelete(): Promise<void> {
    this.confirmDelete = false
    await ZhaLocalStore.deleteNote(this.noteId)
    this.onChanged()
    ZhaDetailNav.closeNote()
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image($r('app.media.cover_note_01'))
              .width('100%')
              .height(180)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.lg)
            Column({ space: 4 }) {
              Text(this.note.title.length > 0 ? this.note.title : '无标题笔记')
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
              Text(this.formatTime(this.note.updatedAt))
                .fontSize(Theme.type.footnote)
                .fontColor('#FFFFFF')
            }
            .width('100%')
            .padding(Theme.space.s5)
            .linearGradient({
              angle: 180,
              colors: [['rgba(0,0,0,0)', 0], ['rgba(45,90,74,0.82)', 1]]
            })
          }
          .width('100%')
          .height(180)
          .clip(true)
          .borderRadius(Theme.radius.lg)

          if (this.note.tags.length > 0) {
            Row({ space: Theme.space.s2 }) {
              ForEach(this.note.tags, (tag: string) => {
                Text(tag)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                  .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                  .backgroundColor(Theme.colors().brandPrimaryContainer)
                  .borderRadius(Theme.radius.pill)
              }, (tag: string) => tag)
            }
            .width('100%')
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

          Row({ space: Theme.space.s3 }) {
            Column() {
              AppButton({
                label: '编辑笔记',
                variant: 'primary',
                onTap: () => ZhaDetailNav.openNoteEditor(this.noteId)
              })
            }
            .layoutWeight(1)
            Column() {
              AppButton({
                label: '转为待办',
                variant: 'secondary',
                onTap: () => { void this.convertToTodo() }
              })
            }
            .layoutWeight(1)
          }
          .width('100%')

          AppButton({
            label: '删除笔记',
            variant: 'danger',
            onTap: () => { this.confirmDelete = true }
          })

          if (this.convertHint.length > 0) {
            Text(this.convertHint)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().success)
          }
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
        ZhaConfirmDialog({
          title: '删除笔记',
          message: '删除后无法恢复。是否继续？',
          confirmLabel: '确认删除',
          danger: true,
          onConfirm: () => { void this.doDelete() },
          onCancel: () => { this.confirmDelete = false }
        })
      }
    }
    .width('100%')
    .height('100%')
  }
}
