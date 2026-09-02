import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { InfoRowCard } from '../components/wanxiang/InfoRowCard'
import { WanXiangStatChip } from '../components/wanxiang/WanXiangStatChip'
import { WanXiangGradients } from '../services/WanXiangGradients'
import { InfoItem } from '../models/InfoModels'
import { InfoRepository } from '../services/InfoRepository'
import { UserDataStore } from '../services/UserDataStore'
import { WanXiangDetailNav } from '../services/WanXiangDetailNav'
import { SettingsPage } from './SettingsPage'
import { StatsOverlayPage } from './StatsOverlayPage'
import { TimelineOverlayPage } from './TimelineOverlayPage'
import { AchievementOverlayPage } from './AchievementOverlayPage'
import { SparkStore } from '../services/SparkStore'
import { KnowledgeStore } from '../services/KnowledgeStore'
import { CheckInStore } from '../services/CheckInStore'
import { CalendarOverlayPage } from './CalendarOverlayPage'
import { TopicPathOverlayPage } from './TopicPathOverlayPage'

@Component
export struct MinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('wanxiangStoreReady') @Watch('onStoreReady') storeReady: boolean = false
  @Prop bottomInset: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  onDataChanged: () => void = () => {}
  @State showFavorites: boolean = false
  @State showHistory: boolean = false
  @State showReadLater: boolean = false
  @State showNotes: boolean = false
  @State showSettings: boolean = false
  @State showStats: boolean = false
  @State showTimeline: boolean = false
  @State showAchievements: boolean = false
  @State showCalendar: boolean = false
  @State showTopicHub: boolean = false
  @State topicHubId: string = ''
  @State favoriteItems: InfoItem[] = []
  @State historyItems: InfoItem[] = []
  @State readLaterItems: InfoItem[] = []
  @State notedItems: InfoItem[] = []
  @State readCount: number = 0
  @State knowledgeCount: number = 0
  @State sparkCount: number = 0
  @State streakDays: number = 0
  @State toastText: string = ''

  onStoreReady(): void {
    if (this.storeReady) {
      void this.reloadLists()
    }
  }

  aboutToAppear(): void {
    void this.reloadLists()
  }

  onRefreshTokenChange(): void {
    void this.reloadLists()
  }

  private async reloadLists(): Promise<void> {
    this.readCount = await UserDataStore.getReadCount()
    this.knowledgeCount = await KnowledgeStore.count()
    this.sparkCount = await SparkStore.count()
    this.streakDays = await CheckInStore.getStreakDays()
    this.favoriteItems = await this.resolveItems(await UserDataStore.getFavoriteIds())
    this.historyItems = await this.resolveItems(await UserDataStore.getHistoryIds())
    this.readLaterItems = await this.resolveItems(await UserDataStore.getReadLaterIds())
    this.notedItems = await this.resolveItems(await UserDataStore.listNotedItemIds())
  }

  private async resolveItems(ids: string[]): Promise<InfoItem[]> {
    const out: InfoItem[] = []
    for (const id of ids) {
      const item = InfoRepository.findById(id)
      if (item !== undefined) {
        out.push(item)
      }
    }
    return out
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout((): void => { this.toastText = '' }, 2800)
  }

  private openDetail(item: InfoItem): void {
    WanXiangDetailNav.open(item.id)
  }

  private openSubPage(show: boolean): void {
    AppStorage.setOrCreate('tabBarHidden', show)
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Column()
              .width('100%')
              .height(168)
              .linearGradient({
                angle: WanXiangGradients.mineHeaderAngle(),
                colors: WanXiangGradients.mineHeaderColors()
              })
              .borderRadius(Theme.radius.lg)

            Column({ space: Theme.space.s3 }) {
              Row({ space: Theme.space.s3 }) {
                Column() {
                  AppIcon({ name: 'user', iconSize: Theme.icon.xl, color: '#FFFFFF' })
                }
                .width(60)
                .height(60)
                .justifyContent(FlexAlign.Center)
                .backgroundColor('rgba(255,255,255,0.24)')
                .borderRadius(Theme.radius.pill)

                Column({ space: 4 }) {
                  Text('阅读空间')
                    .fontSize(Theme.type.title3)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#FFFFFF')
                  Text('收藏 · 知识 · 灵感 · 成长回顾')
                    .fontSize(Theme.type.bodyS)
                    .fontColor('#FFFFFF')
                }
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')

              Row({ space: Theme.space.s2 }) {
                WanXiangStatChip({ label: '已读', value: `${this.readCount}` })
                WanXiangStatChip({ label: '知识', value: `${this.knowledgeCount}` })
                WanXiangStatChip({ label: '灵感', value: `${this.sparkCount}` })
                WanXiangStatChip({ label: '连续', value: `${this.streakDays}天` })
              }
              .width('100%')
            }
            .padding(Theme.space.s4)
            .width('100%')
          }
          .width('100%')

          Column() {
            this.MenuTile('数据统计', '阅读、分类与打卡趋势', 'chart', (): void => {
              this.openSubPage(true)
              this.showStats = true
            })
            this.MenuTile('阅读日历', '按月查看打卡与阅读习惯', 'chart', (): void => {
              this.openSubPage(true)
              this.showCalendar = true
            })
            this.MenuTile('专题路径', '系统化主题阅读与进度', 'biz', (): void => {
              const topics = InfoRepository.topicCollections()
              if (topics.length > 0) {
                this.topicHubId = topics[0].id
                this.openSubPage(true)
                this.showTopicHub = true
              }
            })
            this.MenuTile('成长时间轴', '按时间回顾你的学习轨迹', 'refresh', (): void => {
              this.openSubPage(true)
              this.showTimeline = true
            })
            this.MenuTile('成就墙', '解锁阅读与创作徽章', 'ai', (): void => {
              this.openSubPage(true)
              this.showAchievements = true
            })
            this.MenuTile('我的收藏', '标记值得回看的文章', 'message', (): void => {
              this.openSubPage(true)
              this.showFavorites = true
            })
            this.MenuTile('稍后再读', '建立你的阅读待办队列', 'refresh', (): void => {
              this.openSubPage(true)
              this.showReadLater = true
            })
            this.MenuTile('阅读笔记', '详情页记录的思考与要点', 'biz', (): void => {
              this.openSubPage(true)
              this.showNotes = true
            })
            this.MenuTile('浏览历史', '最近打开过的资讯', 'refresh', (): void => {
              this.openSubPage(true)
              this.showHistory = true
            })
            this.MenuTile('设置与隐私', '主题、协议与撤回', 'user', (): void => {
              this.openSubPage(true)
              this.showSettings = true
            })
          }
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
          .clip(true)
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.s4,
          bottom: this.bottomInset + Theme.space.s8
        })
      }
      .width('100%')
      .height('100%')

      if (this.showFavorites) {
        this.ListOverlay('我的收藏', this.favoriteItems, (): void => {
          this.showFavorites = false
          this.openSubPage(false)
        })
      }

      if (this.showReadLater) {
        this.ListOverlay('稍后再读', this.readLaterItems, (): void => {
          this.showReadLater = false
          this.openSubPage(false)
        })
      }

      if (this.showNotes) {
        this.ListOverlay('阅读笔记', this.notedItems, (): void => {
          this.showNotes = false
          this.openSubPage(false)
        })
      }

      if (this.showHistory) {
        this.ListOverlay('浏览历史', this.historyItems, (): void => {
          this.showHistory = false
          this.openSubPage(false)
        }, true)
      }

      if (this.showSettings) {
        SettingsPage({
          onClose: (): void => {
            this.showSettings = false
            this.openSubPage(false)
          },
          onShowToast: (msg: string): void => this.showToast(msg),
          onThemeChanged: (): void => {
            this.onDataChanged()
          }
        })
      }

      if (this.showStats) {
        StatsOverlayPage({
          refreshToken: this.refreshToken,
          onClose: (): void => {
            this.showStats = false
            this.openSubPage(false)
          }
        })
      }

      if (this.showCalendar) {
        CalendarOverlayPage({
          onClose: (): void => {
            this.showCalendar = false
            this.openSubPage(false)
          }
        })
      }

      if (this.showTopicHub && this.topicHubId.length > 0) {
        TopicPathOverlayPage({
          topicId: this.topicHubId,
          onClose: (): void => {
            this.showTopicHub = false
            this.topicHubId = ''
            this.openSubPage(false)
          }
        })
      }

      if (this.showTimeline) {
        TimelineOverlayPage({
          onClose: (): void => {
            this.showTimeline = false
            this.openSubPage(false)
          }
        })
      }

      if (this.showAchievements) {
        AchievementOverlayPage({
          onClose: (): void => {
            this.showAchievements = false
            this.openSubPage(false)
          }
        })
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor('rgba(15,23,42,0.92)')
          .borderRadius(Theme.radius.pill)
          .position({ x: '8%', y: 52 })
          .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  MenuTile(title: string, subtitle: string, iconName: string, onTap: () => void) {
    Row({ space: Theme.space.s3 }) {
      Column() {
        AppIcon({
          name: iconName === 'message' ? 'message' : iconName === 'refresh' ? 'refresh' :
            iconName === 'biz' ? 'biz' : iconName === 'chart' ? 'chart' :
              iconName === 'ai' ? 'ai' : 'user',
          iconSize: Theme.icon.md,
          color: Theme.colors().brandPrimary
        })
      }
      .width(40)
      .height(40)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Theme.colors().brandPrimaryContainer)
      .borderRadius(Theme.radius.sm)

      Column({ space: 2 }) {
        Text(title)
          .fontSize(Theme.type.body)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
        Text(subtitle)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textPrimary })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .onClick((): void => onTap())
  }

  @Builder
  ListOverlay(title: string, items: InfoItem[], onClose: () => void, allowClear: boolean = false) {
    Column() {
      Row() {
        Text(title)
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
        Blank()
        if (allowClear) {
          Text('清空')
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().brandPrimary)
            .margin({ right: Theme.space.s3 })
            .onClick((): void => {
              void UserDataStore.clearHistory().then(() => {
                void this.reloadLists()
                this.showToast('浏览历史已清空')
              })
            })
        }
        Text('返回')
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().brandPrimary)
          .onClick((): void => onClose())
      }
      .width('100%')
      .padding(Theme.space.pageX)

      if (items.length === 0) {
        AppEmpty({
          title: '暂无记录',
          description: allowClear ? '浏览资讯后将出现在这里' : '在详情页添加收藏、稍后再读或笔记',
          actionLabel: '返回',
          onAction: (): void => onClose()
        }).layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            ForEach(items, (item: InfoItem) => {
              InfoRowCard({
                item: item,
                onTap: (): void => { this.openDetail(item) }
              })
            }, (item: InfoItem) => item.id)
          }
          .padding(Theme.space.pageX)
        }
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .zIndex(20)
  }
}
