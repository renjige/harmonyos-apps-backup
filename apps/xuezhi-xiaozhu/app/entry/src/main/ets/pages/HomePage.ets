import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppError } from '../components/design-system/AppError'
import { AppIcon } from '../components/design-system/AppIcon'
import { PathListCard } from '../components/cottage/CottageCards'
import { CottagePlazaTail } from '../components/cottage/CottagePlazaTail'
import { CottageItem } from '../models/CottageModels'
import { CottageBizService } from '../services/CottageBizService'
import { CottageMedia } from '../services/CottageMedia'
import { CottageNav } from '../services/CottageNav'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '学知小筑'
  @State paths: CottageItem[] = []
  @State cards: CottageItem[] = []
  @State daily: CottageItem[] = []
  @State today: CottageItem = new CottageItem()
  @State loading: boolean = true
  @State failed: boolean = false
  @StorageLink('cottageTick') tick: number = 0

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.failed = false
    const pathList = await CottageBizService.loadPaths()
    const cardList = await CottageBizService.loadCards()
    const dailyList = await CottageBizService.loadDaily()
    this.paths = pathList
    this.cards = cardList
    this.daily = dailyList
    this.today = CottageBizService.pickToday(dailyList.length > 0 ? dailyList : cardList)
    this.loading = false
    this.failed = pathList.length === 0 && cardList.length === 0
  }

  private dateLabel(): string {
    const d = new Date()
    const wdays: string[] = ['日', '一', '二', '三', '四', '五', '六']
    return `${d.getMonth() + 1}月${d.getDate()}日 · 周${wdays[d.getDay()]}`
  }

  private greeting(): string {
    const h = new Date().getHours()
    if (h < 11) {
      return '晨光正好，筑一块知识砖'
    }
    if (h < 18) {
      return '选一条路径，继续往前走'
    }
    return '晚间回顾今日智慧'
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        Row() {
          Row({ space: Theme.space.s3 }) {
            Image($r('app.media.app_logo'))
              .width(44)
              .height(44)
              .borderRadius(12)
              .objectFit(ImageFit.Cover)
            Column({ space: 4 }) {
              Text(this.appName)
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              Text(this.dateLabel())
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                .fontWeight(FontWeight.Medium)
              Text(this.greeting())
                .fontSize(Theme.type.footnote)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
          }
          .layoutWeight(1)
          Column() {
            AppIcon({ name: 'message', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(Theme.colors().brandPrimaryContainer)
          .borderRadius(Theme.radius.pill)
          .onClick((): void => { CottageNav.openMessages() })
        }
        .width('100%')

        if (this.failed && !this.loading) {
          AppError({
            title: '暂时无法加载内容',
            message: '请检查网络后重试。',
            retryLabel: '重试',
            onRetry: (): void => { void this.reload() }
          })
        } else if (this.loading) {
          Text('正在打开学习广场…')
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        } else {
          this.HeroBlock()
          this.PathBanner()
          this.TodayWisdom()
          CottagePlazaTail({ cards: this.cards })
        }
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.s3,
        bottom: Theme.space.s10
      })
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .align(Alignment.Top)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .edgeEffect(EdgeEffect.Spring)
  }

  @Builder
  HeroBlock() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image($r('app.media.hero_plaza'))
        .width('100%')
        .height(168)
        .objectFit(ImageFit.Cover)
      Column()
        .width('100%')
        .height(168)
        .linearGradient({
          angle: 180,
          colors: [['rgba(18,32,58,0.08)', 0.22], ['rgba(18,32,58,0.78)', 1]]
        })
      Column({ space: 6 }) {
        Text('学习广场')
          .fontSize(Theme.type.caption)
          .fontColor('#F8FAFC')
        Text('选一个领域，按路径把知识一点点筑进日常。')
          .fontSize(Theme.type.subtitleL)
          .fontWeight(FontWeight.Medium)
          .fontColor('#F8FAFC')
          .maxLines(2)
      }
      .padding({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s4 })
    }
    .width('100%')
    .borderRadius(Theme.radius.xl)
    .clip(true)
  }

  @Builder
  PathBanner() {
    Column({ space: Theme.space.s3 }) {
      Stack({ alignContent: Alignment.BottomStart }) {
        Image($r('app.media.banner_path'))
          .width('100%')
          .height(132)
          .objectFit(ImageFit.Cover)
        Column()
          .width('100%')
          .height(132)
          .linearGradient({
            angle: 180,
            colors: [['rgba(18,32,58,0.05)', 0.3], ['rgba(18,32,58,0.80)', 1]]
          })
        Column({ space: 4 }) {
          Text('智慧学习路径')
            .fontSize(Theme.type.caption)
            .fontColor('#F8FAFC')
          Text('从领域到课时，一次只筑一块砖')
            .fontSize(Theme.type.subtitleL)
            .fontWeight(FontWeight.Medium)
            .fontColor('#F8FAFC')
        }
        .padding({ left: 16, right: 16, bottom: 14 })
      }
      .width('100%')
      .borderRadius(Theme.radius.xl)
      .clip(true)
      .onClick((): void => {
        if (this.paths.length > 0) {
          CottageNav.openPath(this.paths[0].id)
        }
      })

      if (this.paths.length === 0) {
        AppEmpty({ title: '路径准备中', description: '稍后再来看看' })
      } else {
        Column({ space: Theme.space.s3 }) {
          ForEach(this.paths.slice(0, 3), (p: CottageItem) => {
            PathListCard({
              title: p.title,
              summary: p.summary,
              meta: `${p.categoryLabel} · ${p.days} 日`,
              coverKey: p.coverKey,
              onOpen: (): void => { CottageNav.openPath(p.id) }
            })
          }, (p: CottageItem) => p.id)
        }
        .width('100%')
      }
    }
    .width('100%')
  }

  @Builder
  TodayWisdom() {
    if (this.today.id.length === 0) {
      AppEmpty({ title: '今日智慧准备中', description: '稍后再来看看' })
    } else {
      Column({ space: Theme.space.s3 }) {
        Text('今日智慧')
          .fontSize(Theme.type.subtitleL)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Stack({ alignContent: Alignment.BottomStart }) {
          Image(CottageMedia.resource(this.today.coverKey.length > 0 ?
            this.today.coverKey : 'banner_daily'))
            .width('100%')
            .height(160)
            .objectFit(ImageFit.Cover)
          Column()
            .width('100%')
            .height(160)
            .linearGradient({
              angle: 180,
              colors: [['rgba(18,32,58,0.08)', 0.25], ['rgba(18,32,58,0.82)', 1]]
            })
          Column({ space: 6 }) {
            Text(this.today.categoryLabel.length > 0 ? this.today.categoryLabel : '每日新知')
              .fontSize(Theme.type.caption)
              .fontColor('#F8FAFC')
            Text(this.today.title)
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor('#F8FAFC')
              .maxLines(2)
          }
          .padding({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s4 })
        }
        .width('100%')
        .borderRadius(Theme.radius.xl)
        .clip(true)
        .onClick((): void => { CottageNav.openDaily(this.today.id) })
        Text(this.today.summary)
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .lineHeight(24)
          .maxLines(3)
          .width('100%')
        AppButton({
          label: '阅读今日智慧',
          variant: 'secondary',
          onTap: (): void => { CottageNav.openDaily(this.today.id) }
        })
      }
      .width('100%')
    }
  }
}
