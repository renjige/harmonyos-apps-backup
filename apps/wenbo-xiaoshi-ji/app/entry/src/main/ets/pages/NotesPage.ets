import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { NoteCard, NoteCardBinder } from '../components/moment/NoteCard'
import { MemoryFlashbackCard } from '../components/moment/MemoryFlashbackCard'
import { NoteFilterChips } from '../components/moment/NoteFilterChips'
import { MomentNote, DailyPrompt } from '../models/MomentModels'
import { DateHelper } from '../services/DateHelper'
import { MomentStore } from '../services/MomentStore'
import { MomentNav } from '../services/MomentNav'

@Component
export struct NotesPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('momentDataEpoch') @Watch('onEpoch') dataEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop bottomInset: number = 76
  @State notes: MomentNote[] = []
  @State visible: MomentNote[] = []
  @State echoNotes: MomentNote[] = []
  @State prompt: string = ''
  @State query: string = ''
  @State filterTag: string = ''
  @State onlyStar: boolean = false

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  onEpoch(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.prompt = DailyPrompt.today()
    this.notes = await MomentStore.loadNotes()
    this.echoNotes = await MomentStore.onThisDayNotes(DateHelper.todayKey())
    this.applyFilter()
  }

  private applyFilter(): void {
    const q = this.query.trim()
    const out: MomentNote[] = []
    for (const n of this.notes) {
      if (this.onlyStar && !n.pinned) {
        continue
      }
      if (this.filterTag.length > 0 && n.tags.indexOf(this.filterTag) < 0) {
        continue
      }
      if (q.length > 0 && n.content.indexOf(q) < 0 && n.tags.join('').indexOf(q) < 0) {
        continue
      }
      out.push(n)
    }
    this.visible = out
  }

  private pickTag(label: string): void {
    this.filterTag = this.filterTag === label ? '' : label
    this.applyFilter()
  }

  private openWithPrompt(): void {
    AppStorage.setOrCreate('noteDraftSeed', this.prompt)
    MomentNav.openEditor('')
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      List({ space: 8 }) {
        ListItem() {
          Row() {
            Text('生活记录')
              .fontSize(20)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
            Blank()
            Column() {
              AppIcon({ name: 'search', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
            }
            .width(40)
            .height(40)
            .justifyContent(FlexAlign.Center)
            .onClick((): void => MomentNav.openSearch())
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s5 })
        }
        ListItem() {
          Column({ space: 6 }) {
            Text('今日一句')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
            Text(this.prompt)
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textPrimary)
              .lineHeight(22)
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .padding(14)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(16)
          .onClick((): void => this.openWithPrompt())
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        if (this.notes.length > 0) {
          ListItem() {
            MemoryFlashbackCard({ refreshToken: this.refreshToken })
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }
        ListItem() {
          TextInput({ text: this.query, placeholder: '搜索小事或标签' })
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().textPrimary)
            .placeholderColor(Theme.colors().textTertiary)
            .caretColor(Theme.colors().brandPrimary)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(12)
            .height(40)
            .width('100%')
            .onChange((v: string): void => {
              this.query = v
              this.applyFilter()
            })
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        ListItem() {
          NoteFilterChips({
            filterTag: this.filterTag,
            onlyStar: this.onlyStar,
            onAll: (): void => {
              this.filterTag = ''
              this.onlyStar = false
              this.applyFilter()
            },
            onStar: (): void => {
              this.onlyStar = !this.onlyStar
              this.applyFilter()
            },
            onTag: (label: string): void => this.pickTag(label)
          })
        }
        if (this.echoNotes.length > 0) {
          ListItem() {
            Column({ space: 6 }) {
              Text('同日回响')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
              ForEach(this.echoNotes, (n: MomentNote) => {
                Text(`${DateHelper.displayDate(n.dateKey)}  ${n.preview()}`)
                  .fontSize(Theme.type.bodyS)
                  .fontColor(Theme.colors().brandPrimary)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .width('100%')
                  .onClick((): void => MomentNav.openNote(n.id))
              }, (n: MomentNote) => `echo_${n.id}_${n.updatedAt}`)
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
            .padding(12)
            .backgroundColor(Theme.colors().surfaceSubtle)
            .borderRadius(16)
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }
        if (this.visible.length === 0) {
          ListItem() {
            Column({ space: Theme.space.s4 }) {
              Image($r('app.media.empty_first_note'))
                .width('100%')
                .height(160)
                .objectFit(ImageFit.Cover)
                .borderRadius(16)
              AppEmpty({
                title: this.notes.length === 0 ? '今天还没有记录' : '没有符合筛选的小事',
                description: this.notes.length === 0 ? '点右下角或今日一句，30 秒记下此刻' : '换个标签或清空搜索再试试',
                actionLabel: '记下小事',
                onAction: (): void => MomentNav.openEditor('')
              })
            }
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
          }
        } else {
          ForEach(this.visible, (n: MomentNote) => {
            ListItem() {
              NoteCard({
                noteId: n.id,
                content: n.content,
                tagsText: NoteCardBinder.tagsText(n),
                stripe: n.stripeColor(),
                timeLabel: NoteCardBinder.timeLabel(n),
                pinned: n.pinned,
                onOpen: (): void => MomentNav.openNote(n.id)
              })
            }
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
            .constraintSize({ maxHeight: 148 })
          }, (n: MomentNote) => `${n.id}_${n.pinned ? '1' : '0'}_${n.updatedAt}`)
        }
        ListItem() {
          Row().height(this.bottomInset + 64)
        }
      }
      .width('100%')
      .height('100%')
      .alignListItem(ListItemAlign.Start)
      .edgeEffect(EdgeEffect.Spring)
      .clip(true)

      Column() {
        Blank()
        Row() {
          Blank()
          Column() {
            AppIcon({ name: 'add', iconSize: Theme.icon.xl, color: '#FFFFFF' })
          }
          .width(56)
          .height(56)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
          .shadow({ radius: 12, color: 'rgba(196,74,34,0.35)', offsetY: 4 })
          .onClick((): void => MomentNav.openEditor(''))
        }
        .width('100%')
        .padding({ right: 20, bottom: this.bottomInset + 8 })
      }
      .width('100%')
      .height('100%')
      .hitTestBehavior(HitTestMode.Transparent)
    }
    .width('100%')
    .height('100%')
    .clip(true)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
