import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { ElementRecord } from '../../data/ElementCatalog'
import { ElementService } from '../../services/ElementService'
import { ElementNav } from '../../services/ElementNav'
import { ProgressStore } from '../../services/ProgressStore'
import { ScenarioBank } from '../../data/ScenarioBank'

@Component
export struct ElementDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('progressRev') progressRev: number = 0
  @Prop @Watch('onSymbolChange') symbol: string = ''
  @State element: ElementRecord = new ElementRecord()
  @State favorited: boolean = false
  @State wishlisted: boolean = false
  onToast: (msg: string) => void = () => {}

  aboutToAppear(): void {
    this.load()
  }

  onSymbolChange(): void {
    this.load()
  }

  private load(): void {
    const found = ElementService.findBySymbol(this.symbol)
    if (found !== undefined) {
      this.element = found
      this.favorited = ProgressStore.isFavoriteElement(this.symbol)
      this.wishlisted = ProgressStore.isWishlist(this.symbol)
      void ProgressStore.exploreSymbol(this.symbol, `${found.nameCn}（${found.symbol}）`)
    }
  }

  private heroColor(): string {
    if (this.element.colorKey.length === 7) {
      return this.element.colorKey
    }
    return Theme.colors().brandPrimary
  }

  private openRelated(sym: string): void {
    ElementNav.openDetail(sym)
  }

  private async toggleFavorite(): Promise<void> {
    const on = await ProgressStore.toggleFavoriteElement(this.symbol)
    this.favorited = on
    this.onToast(on ? '已收藏元素' : '已取消收藏')
  }

  private async toggleWishlist(): Promise<void> {
    const on = await ProgressStore.toggleWishlist(this.symbol)
    this.wishlisted = on
    this.onToast(on ? '已加入待探索' : '已从待探索移除')
  }

  private startScenario(): void {
    const list = ScenarioBank.byElement(this.symbol)
    if (list.length > 0) {
      ElementNav.openScenario(list[0].id)
      return
    }
    ElementNav.openScenarioForSymbol(this.symbol)
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image($r('app.media.ambient_lab'))
            .width('100%')
            .height(200)
            .objectFit(ImageFit.Cover)
            .borderRadius({ topLeft: 0, topRight: 0, bottomLeft: Theme.radius.md, bottomRight: Theme.radius.md })
          Column()
            .width('100%')
            .height(200)
            .backgroundColor(this.heroColor())
            .opacity(0.55)
            .borderRadius({ bottomLeft: Theme.radius.md, bottomRight: Theme.radius.md })
          Column()
            .width('100%')
            .height(200)
            .linearGradient({
              angle: 180,
              colors: [['rgba(0,0,0,0)', 0.0], ['rgba(15,35,55,0.72)', 1.0]]
            })
            .borderRadius({ bottomLeft: Theme.radius.md, bottomRight: Theme.radius.md })
          Column({ space: 4 }) {
            Text(`${this.element.atomicNumber} · ${this.element.symbol}`)
              .fontSize(Theme.type.caption)
              .fontColor('#FFFFFF')
            Text(this.element.nameCn)
              .fontSize(Theme.type.title1)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
            Text(this.element.nameEn)
              .fontSize(Theme.type.subhead)
              .fontColor('#FFFFFF')
          }
          .padding(Theme.space.s5)
          .alignItems(HorizontalAlign.Start)
          .width('100%')
        }
        .width('100%')

        Row({ space: Theme.space.s3 }) {
          this.MetaChip('族', this.element.family)
          this.MetaChip('周期', `第 ${this.element.period} 周期`)
          this.MetaChip('族序', `第 ${this.element.group} 族`)
        }
        .width('100%')

        Row({ space: Theme.space.s3 }) {
          this.MetaChip('状态', this.element.state)
          this.MetaChip('质量', `${this.element.atomicMass}`)
        }
        .width('100%')

        this.InfoSection('认识它', this.element.summary)

        this.InfoSectionApps('它在哪里', this.element.applications)

        Column({ space: Theme.space.s3 }) {
          Text('它和谁有关')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(ElementService.related(this.symbol), (rel: ElementRecord) => {
              Text(`${rel.symbol} ${rel.nameCn}`)
                .fontSize(Theme.type.subhead)
                .fontColor(Theme.colors().brandPrimary)
                .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                .backgroundColor(Theme.colors().brandPrimaryContainer)
                .borderRadius(Theme.radius.pill)
                .margin({ right: 8, bottom: 8 })
                .onClick((): void => { this.openRelated(rel.symbol) })
            }, (rel: ElementRecord) => rel.symbol)
          }
          .width('100%')
        }
        .width('100%')
        .padding(Theme.space.cardPadding)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.md)
        .border({ width: 1, color: Theme.colors().strokeHairline })

        this.InfoSection('智能解读', this.element.insight)

        Column({ space: Theme.space.s3 }) {
          Row({ space: Theme.space.s3 }) {
            AppButton({
              label: '关系探索',
              variant: 'secondary',
              onTap: (): void => { ElementNav.openRelation(this.symbol) }
            })
              .layoutWeight(1)
            AppButton({
              label: '科学推演',
              variant: 'secondary',
              onTap: (): void => { this.startScenario() }
            })
              .layoutWeight(1)
          }
          .width('100%')

          Row({ space: Theme.space.s3 }) {
            AppButton({
              label: this.favorited ? '已收藏' : '收藏',
              variant: 'ghost',
              onTap: (): void => { void this.toggleFavorite() }
            })
              .layoutWeight(1)
            AppButton({
              label: this.wishlisted ? '待探索中' : '待探索',
              variant: 'ghost',
              onTap: (): void => { void this.toggleWishlist() }
            })
              .layoutWeight(1)
          }
          .width('100%')

          AppButton({
            label: '开始挑战',
            onTap: (): void => { ElementNav.openQuiz('identify') }
          })
        }
        .width('100%')
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        bottom: Theme.space.s10
      })
      .width('100%')
    }
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .width('100%')
    .height('100%')
  }

  @Builder
  InfoSection(title: string, body: string) {
    Column({ space: Theme.space.s3 }) {
      Text(title)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      Text(body)
        .fontSize(Theme.type.body)
        .fontColor(Theme.colors().textPrimary)
        .lineHeight(24)
        .width('100%')
    }
    .width('100%')
    .padding(Theme.space.cardPadding)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }

  @Builder
  InfoSectionApps(title: string, apps: string[]) {
    Column({ space: Theme.space.s3 }) {
      Text(title)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      Column({ space: Theme.space.s2 }) {
        ForEach(apps, (app: string) => {
          Row({ space: Theme.space.s2 }) {
            Text('·')
              .fontColor(Theme.colors().brandAccent)
            Text(app)
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textSecondary)
              .layoutWeight(1)
          }
          .width('100%')
        }, (app: string) => app)
      }
      .width('100%')
    }
    .width('100%')
    .padding(Theme.space.cardPadding)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }

  @Builder
  MetaChip(label: string, value: string) {
    Column({ space: 2 }) {
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
      Text(value)
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
    }
    .padding(Theme.space.s3)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.sm)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .layoutWeight(1)
  }
}
