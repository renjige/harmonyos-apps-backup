import { Theme } from '../components/design-system/Theme'
import { ElementRecord } from '../data/ElementCatalog'
import { ElementService } from '../services/ElementService'
import { ElementNav } from '../services/ElementNav'
import { DetailShell } from '../components/detail/DetailShell'

@Component
export struct RelationOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop symbol: string = ''
  @State element: ElementRecord = new ElementRecord()
  @State sameGroup: ElementRecord[] = []
  @State samePeriod: ElementRecord[] = []
  @State related: ElementRecord[] = []

  aboutToAppear(): void {
    this.load()
  }

  private load(): void {
    const found = ElementService.findBySymbol(this.symbol)
    if (found !== undefined) {
      this.element = found
    }
    this.sameGroup = ElementService.sameGroup(this.symbol)
    this.samePeriod = ElementService.samePeriod(this.symbol)
    this.related = ElementService.related(this.symbol)
  }

  build() {
    DetailShell({
      title: '关系探索',
      onClose: (): void => { ElementNav.closeRelation() }
    }) {
      Scroll() {
        Column({ space: Theme.space.s5 }) {
          Text(`${this.element.symbol} ${this.element.nameCn}`)
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')

          this.Section('同族（第 ' + `${this.element.group}` + ' 族）', this.sameGroup)
          this.Section('同周期（第 ' + `${this.element.period}` + ' 周期）', this.samePeriod)
          this.Section('关联元素链', this.related)
          this.LifeChain()
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
  }

  @Builder
  Section(title: string, items: ElementRecord[]) {
    Column({ space: Theme.space.s3 }) {
      Text(title)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(items, (el: ElementRecord) => {
          Text(`${el.symbol} ${el.nameCn}`)
            .fontSize(Theme.type.subhead)
            .fontColor(el.symbol === this.symbol ? Theme.colors().brandOnPrimary : Theme.colors().brandPrimary)
            .padding({ left: 10, right: 10, top: 6, bottom: 6 })
            .backgroundColor(el.symbol === this.symbol ? Theme.colors().brandPrimary : Theme.colors().brandPrimaryContainer)
            .borderRadius(Theme.radius.pill)
            .margin({ right: 8, bottom: 8 })
            .onClick((): void => {
              if (el.symbol !== this.symbol) {
                ElementNav.closeRelation()
                ElementNav.openDetail(el.symbol)
              }
            })
        }, (el: ElementRecord) => el.symbol)
      }
      .width('100%')
    }
    .width('100%')
  }

  @Builder
  LifeChain() {
    Column({ space: Theme.space.s3 }) {
      Text('生活应用链')
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      ForEach(this.element.applications, (app: string, idx: number) => {
        Row({ space: Theme.space.s3 }) {
          Text(`${idx + 1}`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().brandOnPrimary)
            .width(24)
            .height(24)
            .textAlign(TextAlign.Center)
            .backgroundColor(Theme.colors().brandAccent)
            .borderRadius(Theme.radius.pill)
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
}
