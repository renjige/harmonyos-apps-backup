import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { YunCraftCard } from '../components/yun/YunCraftCard'
import { YunNoteCard } from '../components/yun/YunNoteCard'
import { YunCraftItem, YunCraftPreset, YunNoteItem } from '../models/YunModels'
import { YunDateHelper, YunLocalStore } from '../services/YunLocalStore'
import { YunCraftStore } from '../services/YunCraftStore'
import { YunDetailNav } from '../services/YunDetailNav'

@Component
export struct JournalHubPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @State segment: number = 0
  @State notes: YunNoteItem[] = []
  @State items: YunCraftItem[] = []
  @State filterKind: string = 'all'
  @State board: string = ''
  @State toast: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.notes = await YunLocalStore.loadNotes()
    this.items = await YunCraftStore.load()
  }

  private shown(): YunCraftItem[] {
    return YunCraftStore.filter(this.items, this.filterKind, this.board)
  }

  private showToast(msg: string): void {
    this.toast = msg
    setTimeout((): void => { this.toast = '' }, 1600)
  }

  private async addPreset(p: YunCraftPreset): Promise<void> {
    const it = YunCraftItem.create(YunDateHelper.newId(), p.kind, p.title)
    it.category = p.category
    it.extra = p.extra
    it.body = p.body
    await YunCraftStore.save(it)
    await this.reload()
    this.showToast('已加入灵感，可点进去完善')
    YunDetailNav.openCraft(it.id)
  }

  private openNew(): void {
    const k = this.filterKind === 'pin' || this.filterKind === 'all' ? 'tip' : this.filterKind
    YunDetailNav.openCraftEditor('', k)
  }

  @Builder
  SegmentBar() {
    Row({ space: Theme.space.s2 }) {
      Text('札记')
        .fontSize(Theme.type.subhead)
        .fontWeight(this.segment === 0 ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.segment === 0 ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
        .padding({ left: 16, right: 16, top: 8, bottom: 8 })
        .backgroundColor(this.segment === 0 ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
        .borderRadius(Theme.radius.pill)
        .onClick((): void => { this.segment = 0 })
      Text('灵感/经验')
        .fontSize(Theme.type.subhead)
        .fontWeight(this.segment === 1 ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.segment === 1 ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
        .padding({ left: 16, right: 16, top: 8, bottom: 8 })
        .backgroundColor(this.segment === 1 ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
        .borderRadius(Theme.radius.pill)
        .onClick((): void => { this.segment = 1 })
    }
    .width('100%')
  }

  @Builder
  NotesSegment() {
    Column({ space: Theme.space.s4 }) {
      if (this.notes.length === 0) {
        AppEmpty({
          title: '还没有札记',
          description: '写下第一条生活片段，或从首页快捷入口开始',
          actionLabel: '写札记',
          onAction: (): void => { YunDetailNav.openNoteEditor('') }
        })
      } else {
        ForEach(this.notes, (note: YunNoteItem) => {
          YunNoteCard({
            note: note,
            onTap: (): void => { YunDetailNav.openNote(note.id) }
          })
        }, (note: YunNoteItem) => note.id)
      }
    }
    .width('100%')
  }

  @Builder
  CraftSegment() {
    Column({ space: Theme.space.s4 }) {
      Text('把经验、问题、目标、方案沉淀下来，变成可复用的生活方法')
        .fontSize(Theme.type.bodyS)
        .fontColor(Theme.colors().textSecondary)
        .lineHeight(20)

      Text('分类看板')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().brandDeep)
      Flex({ wrap: FlexWrap.Wrap }) {
        Text('全部领域')
          .fontSize(Theme.type.caption)
          .fontColor(this.board.length === 0 ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
          .padding({ left: 10, right: 10, top: 6, bottom: 6 })
          .margin({ right: Theme.space.s2, bottom: Theme.space.s1 })
          .backgroundColor(this.board.length === 0 ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
          .borderRadius(Theme.radius.pill)
          .onClick((): void => { this.board = '' })
        ForEach(YunCraftPreset.board(), (c: string) => {
          Text(c)
            .fontSize(Theme.type.caption)
            .fontColor(this.board === c ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
            .padding({ left: 10, right: 10, top: 6, bottom: 6 })
            .margin({ right: Theme.space.s2, bottom: Theme.space.s1 })
            .backgroundColor(this.board === c ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.pill)
            .onClick((): void => { this.board = c })
        }, (c: string) => c)
      }
      .width('100%')

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(YunCraftPreset.kinds(), (k: string) => {
          Text(YunCraftPreset.kindLabel(k))
            .fontSize(Theme.type.caption)
            .fontColor(this.filterKind === k ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
            .padding({ left: 10, right: 10, top: 6, bottom: 6 })
            .margin({ right: Theme.space.s2, bottom: Theme.space.s1 })
            .backgroundColor(this.filterKind === k ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.pill)
            .onClick((): void => { this.filterKind = k })
        }, (k: string) => k)
      }
      .width('100%')

      Text('快捷开始（点一下生成，再自己改）')
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(YunCraftPreset.starters(), (p: YunCraftPreset) => {
          Text(`+ ${p.title}`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().brandPrimary)
            .padding({ left: 10, right: 10, top: 8, bottom: 8 })
            .margin({ right: Theme.space.s2, bottom: Theme.space.s2 })
            .backgroundColor(Theme.colors().brandPrimaryContainer)
            .borderRadius(Theme.radius.pill)
            .onClick((): void => { void this.addPreset(p) })
        }, (p: YunCraftPreset) => `${p.kind}_${p.title}`)
      }
      .width('100%')

      if (this.shown().length === 0) {
        AppEmpty({
          title: '灵感还是空的',
          description: '从经验卡、问题记录或生活目标开始',
          actionLabel: '新建一条',
          onAction: (): void => { this.openNew() }
        })
      } else {
        ForEach(this.shown(), (it: YunCraftItem) => {
          YunCraftCard({
            item: it,
            onTap: (): void => { YunDetailNav.openCraft(it.id) }
          })
        }, (it: YunCraftItem) => `${it.id}_${it.updatedAt}_${it.pinned ? '1' : '0'}_${it.progress}`)
      }
    }
    .width('100%')
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Row() {
            Text('札记与灵感')
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().textPrimary)
              .layoutWeight(1)
            Column() {
              AppIcon({ name: 'search', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
            }
            .width(44)
            .height(44)
            .justifyContent(FlexAlign.Center)
            .onClick((): void => { YunDetailNav.openSearch() })
          }
          .width('100%')

          this.SegmentBar()

          if (this.segment === 0) {
            this.NotesSegment()
          } else {
            this.CraftSegment()
          }
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.s4,
          bottom: Theme.space.s10
        })
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .edgeEffect(EdgeEffect.Spring)

      Column() {
        AppIcon({ name: 'add', iconSize: Theme.icon.lg, color: Theme.colors().brandOnPrimary })
      }
      .width(56)
      .height(56)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Theme.colors().brandPrimary)
      .borderRadius(Theme.radius.pill)
      .margin({ right: Theme.space.pageX, bottom: Theme.space.s8 })
      .onClick((): void => {
        if (this.segment === 0) {
          YunDetailNav.openNoteEditor('')
        } else {
          this.openNew()
        }
      })

      if (this.toast.length > 0) {
        Text(this.toast)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 14, right: 14, top: 8, bottom: 8 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .position({ x: '16%', y: 16 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}
