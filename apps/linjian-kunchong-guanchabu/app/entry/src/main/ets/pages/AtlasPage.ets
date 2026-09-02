import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { Observation, TagPreset } from '../models/ObservationModels'
import { ObservationStore } from '../services/ObservationStore'
import { ObservationCard } from '../components/insect/ObservationCard'
import { InsectMedia } from '../services/InsectMedia'

@Component
export struct AtlasPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop bottomInset: number = 76
  onOpenObs: (id: string) => void = (id: string): void => { id.length }
  onStartObserve: () => void = () => {}
  @State query: string = ''
  @State favoriteOnly: boolean = false
  @State tag: string = ''
  @State items: Observation[] = []
  private presets: string[] = TagPreset.all()

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.items = await ObservationStore.filtered(this.query, this.favoriteOnly, this.tag)
  }

  private setAll(): void {
    this.favoriteOnly = false
    this.tag = ''
    void this.reload()
  }

  private setFav(): void {
    this.favoriteOnly = true
    this.tag = ''
    void this.reload()
  }

  private setTag(t: string): void {
    this.favoriteOnly = false
    this.tag = t
    void this.reload()
  }

  build() {
    Column() {
      Text('我的图鉴')
        .fontSize(Theme.type.title2)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.pageY })

      TextInput({ text: this.query, placeholder: '按名称搜索' })
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })
        .onChange((v: string): void => {
          this.query = v
          void this.reload()
        })

      Scroll() {
        Row({ space: 8 }) {
          this.Chip('全部', !this.favoriteOnly && this.tag.length === 0, (): void => this.setAll())
          this.Chip('收藏', this.favoriteOnly, (): void => this.setFav())
          ForEach(this.presets, (t: string) => {
            this.Chip(t, this.tag === t, (): void => this.setTag(t))
          }, (t: string) => t)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3, bottom: Theme.space.s2 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .height(48)

      if (this.items.length === 0) {
        Column() {
          Image(InsectMedia.cover('empty_notebook'))
            .width('100%')
            .height(140)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.lg)
            .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
          AppEmpty({
            title: '图鉴还是空的',
            description: '去户外走一走，记下遇见的昆虫',
            actionLabel: '开始观察',
            onAction: (): void => this.onStartObserve()
          })
        }
        .layoutWeight(1)
      } else {
        Scroll() {
          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
            ForEach(this.items, (o: Observation) => {
              Column() {
                ObservationCard({ item: o, onTap: (): void => this.onOpenObs(o.id) })
              }
              .width('48%')
              .margin({ bottom: 12 })
            }, (o: Observation) => o.id)
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: this.bottomInset + Theme.space.s6
          })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  Chip(label: string, active: boolean, tap: () => void) {
    Text(label)
      .fontSize(Theme.type.bodyS)
      .fontColor(active ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
      .backgroundColor(active ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick(tap)
  }
}
