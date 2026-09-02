import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { FieldRecord, ExploreQuest, GewuPlan, GewuTopic } from '../models/FieldModels'
import { FieldStore } from '../services/FieldStore'
import { GewuDetailNav } from '../services/GewuDetailNav'
import { GewuMedia } from '../services/GewuMedia'
import { ObservationArchiveSection } from '../components/gewu/ObservationArchiveSection'

@Component
export struct PracticePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop bottomInset: number = 76
  @StorageLink('themeRevision') themeRevision: number = 0
  @State plans: GewuPlan[] = []
  @State topics: GewuTopic[] = []
  @State checkedToday: boolean = false
  @State checkinNote: string = ''
  @State planDone: number[] = []
  @State records: FieldRecord[] = []
  @State quests: ExploreQuest[] = []
  @StorageLink('recordDateFilter') @Watch('onDateFilter') recordDateFilter: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  onDateFilter(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.records = await FieldStore.loadRecords()
    this.quests = await FieldStore.todayQuests()
    this.plans = await FieldStore.loadPlans()
    this.topics = await FieldStore.loadTopics()
    const cin = await FieldStore.todayCheckin()
    this.checkedToday = cin !== undefined
    this.checkinNote = cin !== undefined ? cin.note : ''
    const counts: number[] = []
    for (const p of this.plans) {
      counts.push(FieldStore.planDoneCount(p, this.records))
    }
    this.planDone = counts
  }

  private doneAt(index: number): number {
    let i = 0
    for (const n of this.planDone) {
      if (i === index) {
        return n
      }
      i++
    }
    return 0
  }

  private planIndex(id: string): number {
    let i = 0
    for (const p of this.plans) {
      if (p.id === id) {
        return i
      }
      i++
    }
    return 0
  }

  build() {
    Column() {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Column({ space: Theme.space.s1 }) {
            Text('格物功课')
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Text('物候打卡、周期计划、专题册与图鉴观察札')
              .fontSize(Theme.type.subhead)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          Image(GewuMedia.coverResource('banner_lattice'))
            .width('100%')
            .height(80)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.lg)

          if (this.quests.length > 0) {
            Column({ space: Theme.space.s2 }) {
              Text('今日探索任务')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              ForEach(this.quests, (q: ExploreQuest) => {
                Row({ space: Theme.space.s2 }) {
                  AppIcon({
                    name: q.done ? 'check' : 'empty',
                    iconSize: Theme.icon.sm,
                    color: q.done ? Theme.colors().success : Theme.colors().textTertiary
                  })
                  Column({ space: 2 }) {
                    Text(q.title)
                      .fontSize(Theme.type.bodyS)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    Text(q.hint)
                      .fontSize(Theme.type.caption)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textTertiary : Theme.colors().textTertiary)
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)
                }
                .width('100%')
                .padding(10)
                .backgroundColor(Theme.colors().surfaceSubtle)
                .borderRadius(12)
                .onClick((): void => {
                  if (q.id === 'read') {
                    AppStorage.setOrCreate('switchTabIndex', 0)
                  } else if (q.id === 'record' || q.id === 'plant') {
                    AppStorage.setOrCreate('folioListMode', 'all')
                    if (q.id === 'plant') {
                      AppStorage.setOrCreate('folioAtlasFilter', '植物图鉴')
                    }
                    AppStorage.setOrCreate('switchTabIndex', 1)
                  } else if (q.id === 'collect') {
                    AppStorage.setOrCreate('folioListMode', 'favorite')
                    AppStorage.setOrCreate('switchTabIndex', 1)
                  }
                })
              }, (q: ExploreQuest) => q.id)
            }
            .width('100%')
          }

          Column({ space: Theme.space.s2 }) {
            Text('今日物候')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Text(this.checkedToday ?
              `已打卡 · ${this.checkinNote.length > 0 ? this.checkinNote : '无补充说明'}` :
              '还没有记下今日物候')
              .fontSize(Theme.type.bodyS)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            AppButton({
              label: this.checkedToday ? '补充今日打卡' : '完成今日打卡',
              variant: 'primary',
              onTap: (): void => { GewuDetailNav.openPractice('checkin', '') }
            })
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)

          Row() {
            Text('我的功课')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .layoutWeight(1)
            Text('新建')
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().brandPrimary)
              .onClick((): void => { GewuDetailNav.openPractice('plan', 'new') })
          }
          .width('100%')

          if (this.plans.length === 0) {
            AppEmpty({
              title: '还没有功课',
              description: '立一个周期目标，例如本周写下 5 则植物观察。进度随记录自动增加。',
              actionLabel: '创建第一份功课',
              onAction: (): void => { GewuDetailNav.openPractice('plan', 'new') }
            })
          } else {
            Column({ space: Theme.space.s3 }) {
              ForEach(this.plans, (p: GewuPlan) => {
                Column({ space: Theme.space.s2 }) {
                  Text(p.title)
                    .fontSize(Theme.type.body)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .width('100%')
                  Text(`${p.startKey} — ${p.endKey} · ${p.atlasKind === 'all' ? '不限图鉴' : p.atlasKind}`)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .width('100%')
                  Text(`已完成 ${this.doneAt(this.planIndex(p.id))} / ${p.targetCount}`)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().brandPrimary)
                    .width('100%')
                }
                .width('100%')
                .padding(Theme.space.s4)
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.md)
                .onClick((): void => { GewuDetailNav.openPractice('planView', p.id) })
              }, (p: GewuPlan) => p.id)
            }
            .width('100%')
          }

          Row() {
            Text('专题册')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .layoutWeight(1)
            Text('新建')
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().brandPrimary)
              .onClick((): void => { GewuDetailNav.openPractice('topic', 'new') })
          }
          .width('100%')

          if (this.topics.length === 0) {
            AppEmpty({
              title: '还没有专题',
              description: '把图鉴编成「庭院植物」「案头器物」等主题，方便反复对照。',
              actionLabel: '创建专题册',
              onAction: (): void => { GewuDetailNav.openPractice('topic', 'new') }
            })
          } else {
            Column({ space: Theme.space.s3 }) {
              ForEach(this.topics, (t: GewuTopic) => {
                Row() {
                  Column({ space: 4 }) {
                    Text(t.title)
                      .fontSize(Theme.type.body)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    Text(`${t.objectIds.length} 件知识物`)
                      .fontSize(Theme.type.caption)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)
                  AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
                }
                .width('100%')
                .padding(Theme.space.s4)
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.md)
                .onClick((): void => { GewuDetailNav.openPractice('topicView', t.id) })
              }, (t: GewuTopic) => t.id)
            }
            .width('100%')
          }

          ObservationArchiveSection({ records: this.records })

          Row().height(this.bottomInset)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.pageY })
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.pageBg())
  }

  private pageBg(): string {
    if (this.themeRevision < 0) {
      return Theme.colors().surfacePage
    }
    return Theme.colors().surfacePage
  }
}
