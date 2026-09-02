import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { JournalListCard } from '../components/journal/JournalListCard'
import { JournalItem } from '../models/JournalModels'
import { JournalBizService } from '../services/JournalBizService'
import { JournalDetailNav } from '../services/JournalDetailNav'
import { JournalMedia } from '../services/JournalMedia'
import { AuthService } from '../services/AuthService'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop company: string = '智行科技'
  @Prop appName: string = '智行日记'
  @Prop tagline: string = ''
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  onCreateJourney: () => void = () => {}
  @State featured: JournalItem[] = []
  @State recentJourneys: JournalItem[] = []
  @State loading: boolean = true
  @State showFeaturedExamples: boolean = false
  @State featuredLoading: boolean = false
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
      return '早安，今天想记录哪段路'
    }
    if (hour < 17) {
      return '午安，把风景写进智行日记'
    }
    return '晚安，重温今日旅途片段'
  }

  private async reload(): Promise<void> {
    this.loading = true
    if (AuthService.isLoggedIn()) {
      this.recentJourneys = await JournalBizService.loadDiaries(this.currentUsername)
    } else {
      this.recentJourneys = []
    }
    this.loading = false
  }

  private async loadFeaturedExamples(): Promise<void> {
    this.featuredLoading = true
    this.featured = await JournalBizService.loadFeatured()
    this.showFeaturedExamples = true
    this.featuredLoading = false
  }

  @Builder
  JourneyCard(item: JournalItem) {
    Column({ space: 0 }) {
      Stack({ alignContent: Alignment.BottomStart }) {
        Image(JournalMedia.coverMedia(item.coverKey))
          .width('100%')
          .height(120)
          .objectFit(ImageFit.Cover)
          .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
        Column()
          .width('100%')
          .height(120)
          .linearGradient({
            angle: 180,
            colors: [['rgba(26,58,82,0.05)', 0], ['rgba(26,58,82,0.72)', 1]]
          })
          .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
        Column({ space: 4 }) {
          Text(item.subtitle.length > 0 ? item.subtitle : '未设置目的地')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textOnInverse)
            .opacity(0.92)
          Text(item.title)
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textOnInverse)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .padding(Theme.space.s4)
        .alignItems(HorizontalAlign.Start)
        .width('100%')
      }
      Row() {
        Text(item.recordDate)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        Blank()
        Text('查看详情')
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
      }
      .width('100%')
      .padding(Theme.space.s4)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius({ bottomLeft: Theme.radius.xl, bottomRight: Theme.radius.xl })
    }
    .width(220)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .borderRadius(Theme.radius.xl)
    .onClick((): void => {
      if (item.userId.length > 0) {
        JournalDetailNav.openDiary(item.id)
      } else {
        JournalDetailNav.openFeatured(item.id)
      }
    })
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        Row({ space: 12 }) {
          Image($r('app.media.app_icon'))
            .width(48)
            .height(48)
            .borderRadius(12)
            .objectFit(ImageFit.Cover)
          Column({ space: 4 }) {
            Text(this.appName)
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Text(this.greeting())
              .fontSize(Theme.type.subhead)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        Text(this.tagline)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().textTertiary)
          .width('100%')
          .maxLines(2)

        Stack({ alignContent: Alignment.BottomStart }) {
          Image(JournalMedia.coverMedia('hero_travel_home'))
            .width('100%')
            .height(176)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.xl)
          Column()
            .width('100%')
            .height(176)
            .linearGradient({
              angle: 180,
              colors: [['rgba(26,58,82,0.08)', 0], ['rgba(26,58,82,0.78)', 1]]
            })
            .borderRadius(Theme.radius.xl)
          Column({ space: Theme.space.s3 }) {
            Text('记录旅程，收藏风景')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textOnInverse)
            Text('创建旅程 · 添加日记 · 整理相册')
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.colors().textOnInverse)
            AppButton({
              label: '创建旅程',
              onTap: (): void => { this.onCreateJourney() }
            })
          }
          .padding(Theme.space.s5)
          .alignItems(HorizontalAlign.Start)
          .width('100%')
        }
        .width('100%')

        if (this.loading) {
          AppLoading({ variant: 'skeleton' })
        } else {
          Column({ space: Theme.space.s3 }) {
            Text('最近旅行')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            if (this.recentJourneys.length === 0) {
              AppEmpty({
                title: '还没有旅程',
                description: AuthService.isLoggedIn()
                  ? '点击上方「创建旅程」，写下第一段旅途回忆'
                  : '登录后可创建并同步你的旅行记录',
                actionLabel: AuthService.isLoggedIn() ? '创建旅程' : '',
                onAction: (): void => { this.onCreateJourney() }
              })
            } else {
              Scroll() {
                Row({ space: Theme.space.s3 }) {
                  ForEach(this.recentJourneys.slice(0, 8), (item: JournalItem) => {
                    this.JourneyCard(item)
                  }, (item: JournalItem) => item.id)
                }
                .padding({ right: Theme.space.pageX })
              }
              .scrollable(ScrollDirection.Horizontal)
              .scrollBar(BarState.Off)
              .width('100%')
            }
          }
          .width('100%')

          Column({ space: Theme.space.s3 }) {
            Text('旅行灵感')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            if (!this.showFeaturedExamples) {
              Column({ space: Theme.space.s3 }) {
                Text('首次使用暂无个人记录。如需参考写法，可浏览平台提供的旅行灵感示例（非您的数据）。')
                  .fontSize(Theme.type.subhead)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
                AppButton({
                  label: this.featuredLoading ? '加载中…' : '浏览旅行灵感（平台示例）',
                  variant: 'secondary',
                  disabled: this.featuredLoading,
                  onTap: (): void => { void this.loadFeaturedExamples() }
                })
              }
              .width('100%')
            } else {
              Text('以下为平台示例内容，仅供浏览参考')
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                .width('100%')
              ForEach(this.featured.slice(0, 4), (item: JournalItem) => {
                JournalListCard({
                  item: item,
                  compact: false,
                  onTap: (): void => { JournalDetailNav.openFeatured(item.id) }
                })
              }, (item: JournalItem) => item.id)
            }
          }
          .width('100%')
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
  }
}
