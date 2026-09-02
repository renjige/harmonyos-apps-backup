import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { DestCard } from '../components/escape/DestCard'
import { CatChip, DestItem } from '../models/EscapeModels'
import { EscapeBizService } from '../services/EscapeBizService'
import { EscapeDetailNav } from '../services/EscapeDetailNav'
import { EscapeMedia } from '../services/EscapeMedia'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '避暑游记'
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State loading: boolean = true
  @State dests: DestItem[] = []
  @State filtered: DestItem[] = []
  @State today: DestItem | undefined = undefined
  @State cat: string = 'all'
  @State query: string = ''
  private chips: CatChip[] = HomePage.makeChips()

  private static makeChips(): CatChip[] {
    const out: CatChip[] = []
    out.push(CatChip.of('all', '全部'))
    out.push(CatChip.of('mountain', '山水'))
    out.push(CatChip.of('sea', '海滨'))
    out.push(CatChip.of('plateau', '高原'))
    out.push(CatChip.of('forest', '森林'))
    return out
  }

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.dests = await EscapeBizService.loadDestinations()
    this.today = EscapeBizService.pickToday(this.dests)
    this.applyFilter()
    this.loading = false
  }

  private applyFilter(): void {
    let list = EscapeBizService.filterByCategory(this.dests, this.cat)
    list = EscapeBizService.searchDest(list, this.query)
    this.filtered = list
  }

  private todayTitle(): string {
    if (this.today === undefined) {
      return ''
    }
    return this.today.title
  }

  private todayCover(): string {
    if (this.today === undefined) {
      return 'hero_cool'
    }
    return this.today.coverKey
  }

  private todayMeta(): string {
    if (this.today === undefined) {
      return ''
    }
    return `${this.today.tempLabel()} · ${this.today.altitude}`
  }

  build() {
    Column() {
      Row() {
        Text(this.appName)
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Blank()
        Text('出行自测')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 12, right: 12, top: 8, bottom: 8 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
          .onClick(() => EscapeDetailNav.openDiagnose())
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: 8, bottom: 4 })

      TextInput({ text: this.query, placeholder: '搜索目的地 / 城市' })
        .onChange((v: string) => {
          this.query = v
          this.applyFilter()
        })
        .height(44)
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 8 })
        .backgroundColor(Theme.colors().surfaceGlass)
        .borderRadius(Theme.radius.pill)
        .padding({ left: 16, right: 16 })

      if (this.loading) {
        AppLoading({ label: '风正在变凉' }).layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Stack({ alignContent: Alignment.BottomStart }) {
              Image(EscapeMedia.resource(this.todayCover()))
                .width('100%')
                .height(220)
                .objectFit(ImageFit.Cover)
              Column()
                .width('100%')
                .height(130)
                .linearGradient({
                  angle: 180,
                  colors: [['rgba(15,23,42,0)', 0], ['rgba(15,23,42,0.78)', 1]]
                })
              Column({ space: 6 }) {
                Text('今日推荐避暑地')
                  .fontSize(Theme.type.caption)
                  .fontColor('#F8FAFC')
                Text(this.todayTitle())
                  .fontSize(28)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#F8FAFC')
                  .width('100%')
                Text(this.todayMeta())
                  .fontSize(Theme.type.body)
                  .fontColor('#F8FAFC')
                Text('看这座山')
                  .fontSize(Theme.type.footnote)
                  .fontColor('#F8FAFC')
                  .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                  .backgroundColor('rgba(74,144,217,0.85)')
                  .borderRadius(Theme.radius.pill)
              }
              .padding(16)
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .height(220)
            .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
            .borderRadius(Theme.radius.lg)
            .clip(true)
            .onClick(() => {
              if (this.today !== undefined) {
                EscapeDetailNav.openDest(this.today.id)
              }
            })

            Scroll() {
              Row({ space: 8 }) {
                ForEach(this.chips, (c: CatChip) => {
                  Text(c.label)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.cat === c.id ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                    .padding({ left: 14, right: 14, top: 8, bottom: 8 })
                    .backgroundColor(this.cat === c.id ? Theme.colors().brandPrimary : Theme.colors().surfaceGlass)
                    .borderRadius(Theme.radius.pill)
                    .onClick(() => {
                      this.cat = c.id
                      this.applyFilter()
                    })
                }, (c: CatChip) => c.id)
              }
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

            if (this.filtered.length === 0) {
              AppEmpty({
                title: '没有匹配的避暑地',
                description: '换个分类或清空搜索',
                actionLabel: '重试',
                onAction: () => { void this.reload() }
              })
            } else {
              Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
                ForEach(this.filtered, (d: DestItem) => {
                  Column() {
                    DestCard({ item: d, onTap: () => EscapeDetailNav.openDest(d.id) })
                  }
                  .width('48%')
                  .margin({ bottom: 12 })
                }, (d: DestItem) => d.id)
              }
              .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
            }
          }
          .padding({ bottom: Theme.space.s10 })
          .width('100%')
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
