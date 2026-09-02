import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { ItemRow, ListMiniCard, ProgressTrack, SectionTitle } from '../components/family/FamilyCards'
import { FamilyTask, FamilyList } from '../models/FamilyModels'
import { FamilyService } from '../services/FamilyService'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State lists: FamilyList[] = []
  @State todayItems: FamilyTask[] = []
  @State today: FamilyList = new FamilyList()
  @State hasToday: boolean = false
  @Prop @Watch('onTick') refreshToken: number = 0
  onAddItem: () => void = () => {}
  onOpenList: (id: string) => void = () => {}
  onCreateList: () => void = () => {}
  onOpenLists: () => void = () => {}
  onOpenReminders: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onTick(): void {
    void this.reload()
  }

  async reload(): Promise<void> {
    this.lists = await FamilyService.lists()
    const t = await FamilyService.todayList()
    if (t === undefined) {
      this.hasToday = false
      this.today = new FamilyList()
      this.todayItems = []
      return
    }
    this.hasToday = true
    this.today = t
    this.todayItems = await FamilyService.items(t.id)
  }

  private async toggleToday(it: FamilyTask): Promise<void> {
    await FamilyService.toggleItem(it)
    await this.reload()
  }

  private previewItems(): FamilyTask[] {
    const out: FamilyTask[] = []
    for (const it of this.todayItems) {
      if (out.length >= 8) {
        break
      }
      out.push(it)
    }
    return out
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        this.HeroBlock()
        this.QuickEntryBlock()
        this.TodayBlock()
        this.RecentBlock()
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
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .align(Alignment.Top)
  }

  @Builder
  QuickEntryBlock() {
    Column({ space: 12 }) {
      Row({ space: 12 }) {
        this.QuickChip('添加事项', 'add', (): void => this.onAddItem())
        this.QuickChip('家庭清单', 'biz', (): void => this.onOpenLists())
      }
      .width('100%')
      Row({ space: 12 }) {
        this.QuickChip('提醒', 'bell', (): void => this.onOpenReminders())
        this.QuickChip('模板', 'check', (): void => this.onOpenLists())
      }
      .width('100%')
    }
    .width('100%')
  }

  @Builder
  QuickChip(label: string, iconName: AppIconName, onTap: () => void) {
    Row({ space: 8 }) {
      AppIcon({
        name: iconName,
        iconSize: 18,
        color: Theme.colors().brandPrimary
      })
      Text(label)
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
    }
    .layoutWeight(1)
    .height(52)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .shadow({ radius: 8, color: 'rgba(8,42,90,0.04)', offsetY: 2, offsetX: 0 })
    .onClick(onTap)
  }

  @Builder
  HeroBlock() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image($r('app.media.home_hero'))
        .width('100%')
        .height(200)
        .objectFit(ImageFit.Cover)
        .borderRadius(Theme.radius.xl)
      Column()
        .width('100%')
        .height(200)
        .linearGradient({
          angle: 180,
          colors: [['rgba(8,42,90,0.12)', 0], ['rgba(8,42,90,0.78)', 1]]
        })
        .borderRadius(Theme.radius.xl)
      Column({ space: 8 }) {
        Text('家庭备忘')
          .fontSize(Theme.type.title1)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
        Text('今天有哪些重要事情？')
          .fontSize(Theme.type.subhead)
          .fontColor('#FFFFFF')
        Text('+ 添加事项')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .padding({ left: 18, right: 18, top: 10, bottom: 10 })
          .backgroundColor('#FFFFFF')
          .borderRadius(Theme.radius.pill)
          .onClick(() => this.onAddItem())
      }
      .padding(20)
    }
    .width('100%')
  }

  @Builder
  TodayBlock() {
    Column({ space: 12 }) {
      SectionTitle({ title: '今日事项', action: '查看全部', onAction: () => this.onOpenLists() })
      if (!this.hasToday || this.todayItems.length === 0) {
        AppEmpty({
          title: '还没有今日事项',
          description: '记录家庭任务，进度一目了然',
          actionLabel: '添加事项',
          onAction: () => this.onAddItem()
        })
      } else {
        Column({ space: 10 }) {
          Text(this.today.title)
            .fontSize(Theme.type.subtitleM)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
            .onClick(() => this.onOpenList(this.today.id))
          ProgressTrack({
            done: FamilyService.doneCount(this.todayItems),
            total: this.todayItems.length
          })
          ForEach(this.previewItems(), (it: FamilyTask) => {
            ItemRow({
              title: it.title,
              extra: it.qty,
              done: it.completed,
              onToggle: (): void => { void this.toggleToday(it) }
            })
          }, (it: FamilyTask) => `${it.id}_${it.completed ? '1' : '0'}`)
        }
        .width('100%')
        .padding(18)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.xl)
      }
    }
    .width('100%')
  }

  @Builder
  RecentBlock() {
    Column({ space: 12 }) {
      SectionTitle({ title: '最近家庭清单' })
      if (this.lists.length === 0) {
        Text('创建家庭清单后，会显示在这里')
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
      } else {
        ForEach(this.lists, (row: FamilyList) => {
              ListMiniCard({
                title: row.title,
                meta: row.status === 'done' ? '已完成' : '进行中',
                coverKey: row.coverKey,
                listId: row.id,
                onTap: () => this.onOpenList(row.id)
              })
        }, (row: FamilyList) => `${row.id}_${row.status}`)
      }
    }
    .width('100%')
  }
}
