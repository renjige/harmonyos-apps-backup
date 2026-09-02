import { Theme } from '../design-system/Theme'
import { AppIcon, AppIconName } from '../design-system/AppIcon'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppRingChart } from '../design-system/AppChart'
import { ChoiceChip } from './TravelCards'
import {
  AchievementItem,
  ActivityEvent,
  TravelFavorite,
  TravelStatsSnapshot,
  TripRecapItem
} from '../../models/TravelGrowthModels'

@Component
export struct GrowthHubOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop segment: string = 'stats'
  @Prop stats: TravelStatsSnapshot = new TravelStatsSnapshot()
  @Prop achievements: AchievementItem[] = []
  @Prop favorites: TravelFavorite[] = []
  @Prop activities: ActivityEvent[] = []
  @Prop recaps: TripRecapItem[] = []
  onClose: () => void = () => {}
  onSegment: (seg: string) => void = () => {}

  aboutToAppear(): void {
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private close(): void {
    AppStorage.setOrCreate('tabBarHidden', false)
    this.onClose()
  }

  private checklistRate(): number {
    if (this.stats.checklistTotal <= 0) {
      return 0
    }
    return (this.stats.checklistDone * 100) / this.stats.checklistTotal
  }

  private iconName(key: string): AppIconName {
    if (key === 'biz' || key === 'home' || key === 'chart' || key === 'message' ||
      key === 'check' || key === 'refresh' || key === 'star') {
      return key as AppIconName
    }
    return 'check'
  }

  build() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        Row() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick(() => this.close())
        Text('出行成长')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textPrimary)
      }
      .width('100%')
      .padding({ left: 8, right: Theme.space.pageX, top: Theme.space.s2 })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Row({ space: Theme.space.s2 }) {
            ChoiceChip({ label: '统计', selected: this.segment === 'stats',
              onTap: () => this.onSegment('stats') })
            ChoiceChip({ label: '成就', selected: this.segment === 'achievements',
              onTap: () => this.onSegment('achievements') })
            ChoiceChip({ label: '收藏', selected: this.segment === 'favorites',
              onTap: () => this.onSegment('favorites') })
          }
          Row({ space: Theme.space.s2 }) {
            ChoiceChip({ label: '动态', selected: this.segment === 'activity',
              onTap: () => this.onSegment('activity') })
            ChoiceChip({ label: '回顾', selected: this.segment === 'recap',
              onTap: () => this.onSegment('recap') })
          }

          if (this.segment === 'stats') {
            AppRingChart({ title: '清单完成率', percent: this.checklistRate() / 100 })
            Row({ space: Theme.space.s3 }) {
              this.StatTile('行程', `${this.stats.tripCount}`)
              this.StatTile('已完成', `${this.stats.completedTrips}`)
            }
            Row({ space: Theme.space.s3 }) {
              this.StatTile('收藏', `${this.stats.favoriteCount}`)
              this.StatTile('连续准备', `${this.stats.prepStreakDays}天`)
            }
            Row({ space: Theme.space.s3 }) {
              this.StatTile('目的地', `${this.stats.destinationCount}`)
              this.StatTile('待办提醒', `${this.stats.reminderPending}`)
            }
          } else if (this.segment === 'achievements') {
            if (this.achievements.length === 0) {
              AppEmpty({ title: '暂无成就', description: '创建行程并完成清单即可解锁徽章' })
            } else {
              ForEach(this.achievements, (item: AchievementItem) => {
                Row({ space: Theme.space.s3 }) {
                  Row() {
                    AppIcon({
                      name: this.iconName(item.iconKey),
                      iconSize: Theme.icon.md,
                      color: item.unlocked ? Theme.colors().brandPrimary : Theme.colors().textSecondary
                    })
                  }
                  .width(44)
                  .height(44)
                  .justifyContent(FlexAlign.Center)
                  .backgroundColor(item.unlocked ? Theme.colors().brandPrimaryContainer :
                    Theme.colors().surfaceSubtle)
                  .borderRadius(Theme.radius.lg)
                  Column({ space: 4 }) {
                    Text(item.title)
                      .fontSize(Theme.type.subhead)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(item.unlocked ? Theme.colors().textPrimary : Theme.colors().textSecondary)
                    Text(item.description)
                      .fontSize(Theme.type.caption)
                      .fontColor(Theme.colors().textSecondary)
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)
                  Text(item.unlocked ? '已解锁' : '未解锁')
                    .fontSize(Theme.type.caption)
                    .fontColor(item.unlocked ? Theme.colors().brandPrimary : Theme.colors().textSecondary)
                }
                .width('100%')
                .padding(Theme.space.s4)
                .backgroundColor(Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.xl)
              }, (item: AchievementItem) => item.key)
            }
          } else if (this.segment === 'favorites') {
            if (this.favorites.length === 0) {
              AppEmpty({
                title: '还没有收藏',
                description: '在模板或贴士详情页点击收藏，建立个人内容库'
              })
            } else {
              ForEach(this.favorites, (item: TravelFavorite) => {
                Row({ space: Theme.space.s2 }) {
                  AppIcon({ name: 'star', iconSize: Theme.icon.sm, color: Theme.colors().brandPrimary })
                  Column({ space: 4 }) {
                    Text(item.title)
                      .fontSize(Theme.type.subhead)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(Theme.colors().textPrimary)
                    Text(item.entityType)
                      .fontSize(Theme.type.caption)
                      .fontColor(Theme.colors().textSecondary)
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)
                }
                .width('100%')
                .padding(Theme.space.s4)
                .backgroundColor(Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.xl)
              }, (item: TravelFavorite) => item.id)
            }
          } else if (this.segment === 'activity') {
            if (this.activities.length === 0) {
              AppEmpty({ title: '暂无动态', description: '创建行程、完成清单或收藏内容后会出现在这里' })
            } else {
              ForEach(this.activities, (item: ActivityEvent) => {
                Row({ space: Theme.space.s3 }) {
                  Column()
                    .width(8)
                    .height(8)
                    .backgroundColor(Theme.colors().brandPrimary)
                    .borderRadius(4)
                  Column({ space: 4 }) {
                    Text(item.title)
                      .fontSize(Theme.type.subhead)
                      .fontColor(Theme.colors().textPrimary)
                    Text(item.subtitle)
                      .fontSize(Theme.type.caption)
                      .fontColor(Theme.colors().textSecondary)
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)
                }
                .width('100%')
                .padding(Theme.space.s4)
                .backgroundColor(Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.lg)
              }, (item: ActivityEvent) => item.id)
            }
          } else if (this.recaps.length === 0) {
            AppEmpty({
              title: '暂无行程回顾',
              description: '已结束的行程会在这里生成回顾摘要'
            })
          } else {
            ForEach(this.recaps, (item: TripRecapItem) => {
              Column({ space: Theme.space.s2 }) {
                Text(item.title)
                  .fontSize(Theme.type.subtitleM)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colors().textPrimary)
                  .width('100%')
                Text(`${item.destination} · ${item.startDate} 至 ${item.endDate}`)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textSecondary)
                  .width('100%')
                Text(`清单 ${item.checklistDone}/${item.checklistTotal} · 安排 ${item.itineraryCount} 项 · 备忘 ${item.noteCount} 条`)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().brandPrimary)
                  .width('100%')
              }
              .width('100%')
              .padding(Theme.space.s4)
              .alignItems(HorizontalAlign.Start)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.xl)
            }, (item: TripRecapItem) => item.tripId)
          }
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }

  @Builder
  StatTile(label: string, value: string) {
    Column({ space: 4 }) {
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
      Text(value)
        .fontSize(Theme.type.title2)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.colors().brandPrimary)
    }
    .layoutWeight(1)
    .padding(Theme.space.s4)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
  }
}
