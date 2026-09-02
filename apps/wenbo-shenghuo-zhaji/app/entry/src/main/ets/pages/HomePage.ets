import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppCard } from '../components/design-system/AppCard'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppStatCard } from '../components/design-system/AppStatCard'
import { JournalListCard } from '../components/journal/JournalListCard'
import { MomentCaptureSheet } from '../components/journal/MomentCaptureSheet'
import { JournalItem, AnnualStatsData } from '../models/JournalModels'
import { JournalBizService } from '../services/JournalBizService'
import { JournalDetailNav } from '../services/JournalDetailNav'
import { AuthService } from '../services/AuthService'
import { JournalTemplate, JournalTemplateCatalog } from '../services/JournalTemplateCatalog'
import { InspirationPage } from './InspirationPage'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop company: string = '魏文波'
  @Prop appName: string = '生活札记'
  @Prop tagline: string = ''
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  onWriteToday: () => void = () => {}
  onRequireAuth: () => void = () => {}
  onPickTemplate: (key: string) => void = (_k: string) => {}
  onOpenTool: (name: string) => void = (_n: string) => {}
  @State recentDiaries: JournalItem[] = []
  @State loading: boolean = true
  @State yearStats: AnnualStatsData = new AnnualStatsData()
  @State showMoment: boolean = false
  @State showInspiration: boolean = false
  @StorageLink('currentUsername') currentUsername: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private greeting(): string {
    const hour = new Date().getHours()
    if (hour < 11) {
      return '早安，愿你今日温柔'
    }
    if (hour < 17) {
      return '午安，记录此刻心情'
    }
    return '晚安，把今天收进札记'
  }

  private todayLabel(): string {
    const d = new Date()
    const month = d.getMonth() + 1
    const day = d.getDate()
    const weekdays: string[] = ['日', '一', '二', '三', '四', '五', '六']
    return `${month}月${day}日 · 星期${weekdays[d.getDay()]}`
  }

  private weekDiaryCount(): number {
    const now = new Date()
    const weekStart = new Date(now)
    weekStart.setDate(now.getDate() - 6)
    const startIso = weekStart.toISOString().slice(0, 10)
    let count = 0
    for (let i = 0; i < this.recentDiaries.length; i++) {
      const d = this.recentDiaries[i]
      if (d.recordDate.length > 0 && d.recordDate >= startIso) {
        count++
      }
    }
    return count
  }

  private async reload(): Promise<void> {
    this.loading = true
    if (AuthService.isLoggedIn()) {
      this.recentDiaries = await JournalBizService.loadDiaries(this.currentUsername)
      const year = new Date().getFullYear()
      this.yearStats = await JournalBizService.loadAnnualStats(this.currentUsername, year)
    } else {
      this.recentDiaries = []
      this.yearStats = new AnnualStatsData()
    }
    this.loading = false
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s5 }) {
          Column({ space: 6 }) {
            Text(this.greeting())
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Text(this.todayLabel())
              .fontSize(Theme.type.subhead)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            Text(this.tagline)
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          if (AuthService.isLoggedIn() && !this.loading) {
            Row({ space: Theme.space.s3 }) {
              AppStatCard({
                label: '今年札记',
                value: `${this.yearStats.diaryCount}`,
                trend: '篇',
                positive: true
              }).layoutWeight(1)
              AppStatCard({
                label: '配图',
                value: `${this.yearStats.imageCount}`,
                trend: '张',
                positive: true
              }).layoutWeight(1)
              AppStatCard({
                label: '记录日',
                value: `${this.yearStats.writingDays}`,
                trend: '天',
                positive: true
              }).layoutWeight(1)
            }
            .width('100%')

            AppCard({ title: '本周小结', variant: 'plain' }) {
              Text(this.weekDiaryCount() > 0
                ? `近 7 天已记录 ${this.weekDiaryCount()} 篇札记，继续用「生活瞬间」留住日常。`
                : '本周还没有札记，试试从相册选一张今日照片，写下此刻心情。')
                .fontSize(Theme.type.callout)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
                .lineHeight(22)
            }
          }

          Stack({ alignContent: Alignment.BottomStart }) {
            Image($r('app.media.hero_morning_coffee'))
              .width('100%')
              .height(160)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.xl)
            Column()
              .width('100%')
              .height(160)
              .linearGradient({
                angle: 180,
                colors: [['rgba(92,107,115,0.1)', 0], ['rgba(92,107,115,0.75)', 1]]
              })
              .borderRadius(Theme.radius.xl)
            Column({ space: Theme.space.s3 }) {
              Text('开始记录')
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textOnInverse)
              Row({ space: Theme.space.s2 }) {
                AppButton({
                  label: '写札记',
                  onTap: (): void => { this.onWriteToday() }
                }).layoutWeight(1)
                AppButton({
                  label: '生活瞬间',
                  variant: 'secondary',
                  onTap: (): void => {
                    if (!AuthService.requireAuth('create_diary')) {
                      this.onRequireAuth()
                      return
                    }
                    this.showMoment = true
                    AppStorage.setOrCreate('tabBarHidden', true)
                  }
                }).layoutWeight(1)
              }
              .width('100%')
            }
            .padding(Theme.space.s5)
            .alignItems(HorizontalAlign.Start)
            .width('100%')
          }
          .width('100%')

          Column({ space: Theme.space.s2 }) {
            Text('生活主题 · 快速记录')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(JournalTemplateCatalog.all(), (tpl: JournalTemplate) => {
                Text(tpl.label)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().brandDeep)
                  .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                  .backgroundColor(Theme.colors().surfaceCard)
                  .border({ width: 1, color: Theme.colors().strokeStrong })
                  .borderRadius(Theme.radius.pill)
                  .margin({ right: 8, bottom: 8 })
                  .onClick((): void => { this.onPickTemplate(tpl.key) })
              }, (tpl: JournalTemplate) => tpl.key)
            }
            .width('100%')
            Row({ space: Theme.space.s2 }) {
              AppButton({
                label: '心情轨迹',
                variant: 'secondary',
                onTap: (): void => { this.onOpenTool('mood') }
              }).layoutWeight(1)
              AppButton({
                label: '每日打卡',
                variant: 'secondary',
                onTap: (): void => { this.onOpenTool('habit') }
              }).layoutWeight(1)
            }
            .width('100%')
            Row({ space: Theme.space.s2 }) {
              AppButton({
                label: '生活日历',
                variant: 'secondary',
                onTap: (): void => { this.onOpenTool('calendar') }
              }).layoutWeight(1)
              AppButton({
                label: '生活清单',
                variant: 'secondary',
                onTap: (): void => { this.onOpenTool('list') }
              }).layoutWeight(1)
            }
            .width('100%')
            AppButton({
              label: '生活洞察 · 月度成长摘要',
              variant: 'secondary',
              onTap: (): void => { this.onOpenTool('insight') }
            })
              .width('100%')
          }
          .width('100%')

          if (this.loading) {
            AppLoading({ variant: 'skeleton' })
          } else {
            Column({ space: Theme.space.s3 }) {
              Text('最近动态')
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              if (this.recentDiaries.length === 0) {
                AppEmpty({
                  title: AuthService.isLoggedIn() ? '还没有札记' : '登录后开始记录',
                  description: AuthService.isLoggedIn()
                    ? '写札记或从相册记录生活瞬间，这里会展示你的个人内容'
                    : '首次进入为空，登录后仅展示您创建的内容，不含测试数据',
                  actionLabel: AuthService.isLoggedIn() ? '写札记' : '',
                  onAction: (): void => { this.onWriteToday() }
                })
              } else {
                ForEach(this.recentDiaries.slice(0, 5), (item: JournalItem) => {
                  JournalListCard({
                    item: item,
                    compact: true,
                    onTap: (): void => { JournalDetailNav.openDiary(item.id) }
                  })
                }, (item: JournalItem) => item.id)
              }
            }
            .width('100%')

            AppButton({
              label: '手账灵感（官方示例）',
              variant: 'secondary',
              onTap: (): void => {
                this.showInspiration = true
                AppStorage.setOrCreate('tabBarHidden', true)
              }
            })

            Image($r('app.media.hero_rain_walk'))
              .width('100%')
              .height(96)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.lg)
              .opacity(0.92)
          }
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.pageY,
          bottom: Theme.space.s10
        })
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)

      if (this.showMoment) {
        MomentCaptureSheet({
          onClose: (): void => {
            this.showMoment = false
            AppStorage.setOrCreate('tabBarHidden', false)
          },
          onSaved: (): void => { void this.reload() },
          onRequireAuth: (): void => this.onRequireAuth()
        })
          .width('100%')
          .height('100%')
      }

      if (this.showInspiration) {
        InspirationPage({
          onClose: (): void => {
            this.showInspiration = false
            AppStorage.setOrCreate('tabBarHidden', false)
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }
}
