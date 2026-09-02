import { Theme } from '../components/design-system/Theme'
import { ActionCategory, LibraryAction } from '../models/TrainingModels'
import { FitMedia } from '../services/FitMedia'
import { TrainingStore } from '../services/TrainingStore'

@Component
export struct AtlasPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop bottomInset: number = 76
  onOpenAction: (id: string) => void = () => {}
  @State cat: string = 'warm'
  @State items: LibraryAction[] = []

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    await TrainingStore.ensureTemplates()
    const all = await TrainingStore.loadActions()
    const out: LibraryAction[] = []
    for (const a of all) {
      if (a.category === this.cat) {
        out.push(a)
      }
    }
    this.items = out
  }

  private async pick(key: string): Promise<void> {
    this.cat = key
    await this.reload()
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Text('动作图鉴')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Text('内置动作说明，不调用相机或传感器。点进详情可收藏并记入日志。')
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')

        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(ActionCategory.all(), (c: ActionCategory) => {
            Text(c.label)
              .fontSize(Theme.type.bodyS)
              .fontColor(this.cat === c.key ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
              .padding({ left: 12, right: 12, top: 8, bottom: 8 })
              .margin({ right: 8, bottom: 8 })
              .backgroundColor(this.cat === c.key ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.pill)
              .onClick((): void => { void this.pick(c.key) })
          }, (c: ActionCategory) => c.key)
        }
        .width('100%')

        ForEach(this.items, (a: LibraryAction) => {
          Row({ space: Theme.space.s3 }) {
            Image(FitMedia.cover(a.coverKey.length > 0 ? a.coverKey : TrainingStore.coverForCategory(a.category)))
              .width(72)
              .height(72)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.md)
            Column({ space: 4 }) {
              Text(a.name)
                .fontSize(Theme.type.body)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
              Text(a.desc)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
                .maxLines(2)
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .padding(Theme.space.s3)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
          .onClick((): void => { this.onOpenAction(a.id) })
        }, (a: LibraryAction) => a.id)

        Row().height(this.bottomInset)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.pageY })
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
  }
}
