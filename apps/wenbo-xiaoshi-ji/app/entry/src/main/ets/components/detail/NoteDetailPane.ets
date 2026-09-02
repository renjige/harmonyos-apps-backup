import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppCard } from '../design-system/AppCard'
import { DetailShell } from './DetailShell'
import { MomentNote } from '../../models/MomentModels'
import { DateHelper } from '../../services/DateHelper'
import { MomentStore } from '../../services/MomentStore'
import { MomentNav } from '../../services/MomentNav'
import { NoteCardBinder } from '../moment/NoteCard'

@Component
export struct NoteDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('momentDataEpoch') @Watch('onEpoch') dataEpoch: number = 0
  @Prop @Watch('onNoteChange') noteId: string = ''
  onChanged: () => void = () => {}
  @State note: MomentNote = new MomentNote()
  @State related: MomentNote[] = []
  @State confirmDelete: boolean = false
  @State toast: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onNoteChange(): void {
    void this.reload()
  }

  onEpoch(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const found = await MomentStore.findNote(this.noteId)
    if (found !== undefined) {
      this.note = found
      this.related = await MomentStore.relatedNotes(this.noteId)
    }
  }

  private showToast(msg: string): void {
    this.toast = msg
    setTimeout((): void => { this.toast = '' }, 2200)
  }

  private async doDelete(): Promise<void> {
    await MomentStore.deleteNote(this.note.id)
    this.confirmDelete = false
    this.onChanged()
    MomentNav.close()
  }

  private async togglePin(): Promise<void> {
    const pinned = await MomentStore.togglePin(this.note.id)
    await this.reload()
    this.onChanged()
    this.showToast(pinned ? '已加星标' : '已取消星标')
  }

  private async toTodo(): Promise<void> {
    const ok = await MomentStore.convertNoteToTodo(this.note.id)
    this.onChanged()
    this.showToast(ok ? '已加入今日待办' : '转换失败')
  }

  private async splitTodos(): Promise<void> {
    const n = await MomentStore.splitNoteToTodos(this.note.id)
    this.onChanged()
    this.showToast(n > 0 ? `已拆成 ${n} 条今日待办` : '拆分失败')
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      DetailShell({
        title: '小事见解',
        onClose: (): void => MomentNav.close()
      }) {
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Stack({ alignContent: Alignment.BottomStart }) {
              Image($r('app.media.hero_warm_desk'))
                .width('100%')
                .height(180)
                .objectFit(ImageFit.Cover)
                .borderRadius(16)
              Column()
                .width('100%')
                .height(90)
                .linearGradient({
                  angle: 180,
                  colors: [['rgba(0,0,0,0)', 0], ['rgba(45,45,45,0.72)', 1]]
                })
                .borderRadius({ bottomLeft: 16, bottomRight: 16 })
              Text(DateHelper.displayLong(this.note.dateKey))
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
                .padding({ left: 16, right: 16, bottom: 14 })
            }
            .width('100%')
            .clip(true)
            .borderRadius(16)

            Row({ space: 8 }) {
              Text(NoteCardBinder.tagsText(this.note).length > 0 ? NoteCardBinder.tagsText(this.note) : '未添加标签')
                .fontSize(Theme.type.bodyS)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              if (this.note.pinned) {
                Text('星标')
                  .fontSize(11)
                  .fontColor('#FFFFFF')
                  .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                  .backgroundColor(Theme.colors().brandPrimary)
                  .borderRadius(Theme.radius.pill)
              }
            }
            .width('100%')

            AppCard() {
              Text(this.note.content)
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .lineHeight(24)
                .width('100%')
            }

            Text(`写下于 ${DateHelper.timeLabel(this.note.createdAt)}`)
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')

            if (this.related.length > 0) {
              Column({ space: Theme.space.s2 }) {
                Text('同标签的其他小事')
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colors().textPrimary)
                  .width('100%')
                ForEach(this.related, (rel: MomentNote) => {
                  Row() {
                    Text(rel.preview())
                      .fontSize(Theme.type.body)
                      .fontColor(Theme.colors().brandPrimary)
                      .layoutWeight(1)
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                    Text(DateHelper.displayDate(rel.dateKey))
                      .fontSize(Theme.type.caption)
                      .fontColor(Theme.colors().textSecondary)
                  }
                  .width('100%')
                  .padding(Theme.space.s3)
                  .backgroundColor(Theme.colors().surfaceSubtle)
                  .borderRadius(12)
                  .onClick((): void => { MomentNav.openNote(rel.id) })
                }, (rel: MomentNote) => rel.id)
              }
              .width('100%')
            }

            AppButton({
              label: '编辑这件事',
              onTap: (): void => MomentNav.openEditor(this.note.id)
            })
            AppButton({
              label: this.note.pinned ? '取消星标' : '星标这条小事',
              variant: 'secondary',
              onTap: (): void => { void this.togglePin() }
            })
            AppButton({
              label: '转为今日待办',
              variant: 'secondary',
              onTap: (): void => { void this.toTodo() }
            })
            AppButton({
              label: '拆成 1～3 条今日待办',
              variant: 'secondary',
              onTap: (): void => { void this.splitTodos() }
            })

            if (!this.confirmDelete) {
              AppButton({
                label: '删除',
                variant: 'ghost',
                onTap: (): void => { this.confirmDelete = true }
              })
            } else {
              Column({ space: Theme.space.s2 }) {
                Text('确定删除这条小事？删除后无法恢复')
                  .fontSize(Theme.type.bodyS)
                  .fontColor(Theme.colors().danger)
                  .width('100%')
                Row({ space: Theme.space.s2 }) {
                  Column() {
                    AppButton({
                      label: '取消',
                      variant: 'secondary',
                      onTap: (): void => { this.confirmDelete = false }
                    })
                  }.layoutWeight(1)
                  Column() {
                    AppButton({
                      label: '确认删除',
                      variant: 'danger',
                      onTap: (): void => { void this.doDelete() }
                    })
                  }.layoutWeight(1)
                }
                .width('100%')
              }
              .width('100%')
            }

            Row().height(Theme.space.s10)
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s2 })
        }
        .width('100%')
        .layoutWeight(1)
      }

      if (this.toast.length > 0) {
        Text(this.toast)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 48 })
      }
    }
    .width('100%')
    .height('100%')
  }
}
