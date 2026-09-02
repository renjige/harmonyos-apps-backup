import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { InsectCatalog, InsectWikiItem } from '../models/InsectCatalog'
import { Observation } from '../models/ObservationModels'
import { InsectMedia } from '../services/InsectMedia'
import { ObservationStore } from '../services/ObservationStore'
import { ObservationCard } from '../components/insect/ObservationCard'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop bottomInset: number = 76
  onStartObserve: () => void = () => {}
  onOpenWiki: (id: string) => void = (id: string): void => { id.length }
  onOpenWikiList: () => void = () => {}
  onOpenObs: (id: string) => void = (id: string): void => { id.length }
  @State today: InsectWikiItem = InsectCatalog.today()
  @State recent: Observation[] = []
  @State dateLabel: string = HomePage.todayLabel()

  aboutToAppear(): void {
    this.today = InsectCatalog.today()
    this.dateLabel = HomePage.todayLabel()
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.recent = await ObservationStore.recent(2)
  }

  private static todayLabel(): string {
    const d = new Date()
    return `${d.getFullYear()}年${d.getMonth() + 1}月${d.getDate()}日`
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Row() {
          Text('昆虫观察簿')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
          Text(this.dateLabel)
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        }
        .width('100%')

        Stack({ alignContent: Alignment.BottomStart }) {
          Image(InsectMedia.cover(this.today.coverKey))
            .width('100%')
            .height(200)
            .objectFit(ImageFit.Cover)
          Column({ space: 4 }) {
            Text('今日发现')
              .fontSize(Theme.type.caption)
              .fontColor('#FFFFFF')
            Text(this.today.name)
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
            Text(this.today.habit)
              .fontSize(Theme.type.bodyS)
              .fontColor('#FFFFFF')
              .maxLines(2)
          }
          .width('100%')
          .padding(16)
          .linearGradient({
            angle: 180,
            colors: [['rgba(0,0,0,0)', 0], ['rgba(16,32,24,0.82)', 1]]
          })
        }
        .width('100%')
        .borderRadius(Theme.radius.xl)
        .clip(true)
        .onClick((): void => this.onOpenWiki(this.today.id))

        Image(InsectMedia.cover('banner_season'))
          .width('100%')
          .height(96)
          .objectFit(ImageFit.Cover)
          .borderRadius(Theme.radius.lg)
          .onClick((): void => this.onOpenWikiList())

        AppButton({ label: '开始观察', onTap: (): void => this.onStartObserve() })

        Row() {
          Text('最近观察')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
          Text('知识库')
            .fontSize(Theme.type.bodyS)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .onClick((): void => this.onOpenWikiList())
        }
        .width('100%')

        if (this.recent.length === 0) {
          AppEmpty({
            title: '还没有观察记录',
            description: '点「开始观察」，记下今天遇见的昆虫',
            actionLabel: '开始观察',
            onAction: (): void => this.onStartObserve()
          })
        } else {
          ForEach(this.recent, (o: Observation) => {
            ObservationCard({ item: o, onTap: (): void => this.onOpenObs(o.id) })
          }, (o: Observation) => o.id)
        }
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.pageY,
        bottom: this.bottomInset + Theme.space.s6
      })
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .align(Alignment.Top)
  }
}
