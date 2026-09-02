import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { ActivityEvent } from '../models/LifeGrowthModels'
import { LifeGrowthService } from '../services/LifeGrowthService'
import { LifeHubNav } from '../services/LifeHubNav'
import { JournalDetailNav } from '../services/JournalDetailNav'

@Component
export struct ActivityFeedPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('lifeHubVersion') @Watch('onVer') lifeHubVersion: number = 0
  @StorageLink('diaryDataVersion') @Watch('onVer') diaryDataVersion: number = 0
  @StorageLink('currentUsername') currentUsername: string = ''
  @State items: ActivityEvent[] = []

  aboutToAppear(): void {
    void this.reload()
  }

  onVer(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.items = await LifeGrowthService.loadActivities(this.currentUsername)
  }

  private kindLabel(kind: string): string {
    if (kind === 'diary') {
      return '笺语'
    }
    if (kind === 'mood') {
      return '心情'
    }
    if (kind === 'todo') {
      return '待办'
    }
    if (kind === 'habit') {
      return '打卡'
    }
    if (kind === 'plan') {
      return '计划'
    }
    return '动态'
  }

  private open(row: ActivityEvent): void {
    if (row.kind === 'diary') {
      JournalDetailNav.openDiary(row.refId)
      return
    }
    if (row.kind === 'mood') {
      LifeHubNav.open('mood', true)
      return
    }
    if (row.kind === 'todo') {
      LifeHubNav.open('todos', true)
      return
    }
    if (row.kind === 'habit') {
      LifeHubNav.open('habits', true)
      return
    }
    LifeHubNav.open('plans', true)
  }

  build() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick((): void => { LifeHubNav.backOrClose() })
        Column({ space: 2 }) {
          Text('生活动态')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Text('把写下、完成、打卡的日子串起来')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

      if (this.items.length === 0) {
        Column() {
          AppEmpty({
            title: '还没有动态',
            description: '写一页、记心情或完成待办后，这里会出现你的生活时间轴。',
            actionLabel: '',
            onAction: (): void => {}
          })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            ForEach(this.items, (row: ActivityEvent) => {
              Column({ space: 4 }) {
                Text(row.date)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textTertiary)
                  .width('100%')
                Text(`${this.kindLabel(row.kind)} · ${row.title}`)
                  .fontSize(Theme.type.subhead)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
              }
              .width('100%')
              .padding(Theme.space.s4)
              .alignItems(HorizontalAlign.Start)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)
              .onClick((): void => { this.open(row) })
            }, (row: ActivityEvent) => row.id)
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
