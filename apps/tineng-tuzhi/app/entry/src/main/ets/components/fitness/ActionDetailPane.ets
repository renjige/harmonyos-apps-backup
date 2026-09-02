import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { DetailShell } from '../detail/DetailShell'
import { LibraryAction } from '../../models/TrainingModels'
import { FitMedia } from '../../services/FitMedia'
import { TrainingStore } from '../../services/TrainingStore'

@Component
export struct ActionDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop actionId: string = ''
  onClose: () => void = () => {}
  onLog: () => void = () => {}
  @State nameText: string = ''
  @State catText: string = ''
  @State descText: string = ''
  @State purposeText: string = ''
  @State cautionText: string = ''
  @State coverKey: string = 'atlas_warm'
  @State favorited: boolean = false

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const a = await TrainingStore.findAction(this.actionId)
    if (a === undefined) {
      return
    }
    this.apply(a)
  }

  private apply(a: LibraryAction): void {
    this.nameText = a.name
    this.catText = TrainingStore.categoryLabel(a.category)
    this.descText = a.desc
    this.purposeText = a.purpose
    this.cautionText = a.caution
    this.coverKey = a.coverKey.length > 0 ? a.coverKey : TrainingStore.coverForCategory(a.category)
    this.favorited = a.favorited
  }

  private async toggleFav(): Promise<void> {
    await TrainingStore.toggleActionFav(this.actionId)
    await this.reload()
  }

  build() {
    Column() {
      DetailShell({
        title: '动作图鉴',
        onClose: (): void => this.onClose()
      })
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(FitMedia.cover(this.coverKey))
              .width('100%')
              .height(180)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.lg)
            Column()
              .width('100%')
              .height(180)
              .borderRadius(Theme.radius.lg)
              .linearGradient({
                angle: 180,
                colors: [['rgba(26,35,50,0.05)', 0], ['rgba(26,35,50,0.78)', 1]]
              })
            Column({ space: 4 }) {
              Text(this.catText)
                .fontSize(Theme.type.caption)
                .fontColor('#FFFFFF')
              Text(this.nameText)
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
            }
            .padding(Theme.space.s4)
          }
          .width('100%')

          Column({ space: Theme.space.s2 }) {
            Text('简介')
              .fontSize(Theme.type.subhead)
              .fontColor(Theme.colors().textPrimary)
            Text(this.descText)
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textPrimary)
              .lineHeight(22)
          }
          .width('100%')
          .padding(Theme.space.cardPadding)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)

          Column({ space: Theme.space.s2 }) {
            Text('训练目的')
              .fontSize(Theme.type.subhead)
              .fontColor(Theme.colors().textPrimary)
            Text(this.purposeText.length > 0 ? this.purposeText : '打好基础动作质量')
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textPrimary)
          }
          .width('100%')
          .padding(Theme.space.cardPadding)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)

          Column({ space: Theme.space.s2 }) {
            Text('注意事项')
              .fontSize(Theme.type.subhead)
              .fontColor(Theme.colors().textPrimary)
            Text(this.cautionText.length > 0 ? this.cautionText : '不适即停，不追求极限幅度。')
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textPrimary)
          }
          .width('100%')
          .padding(Theme.space.cardPadding)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)

          AppButton({
            label: this.favorited ? '已收藏到训练库' : '收藏这个动作',
            variant: this.favorited ? 'secondary' : 'primary',
            onTap: (): void => { void this.toggleFav() }
          })
          AppButton({
            label: '记入今日训练日志',
            variant: 'secondary',
            onTap: (): void => this.onLog()
          })
          Row().height(Theme.space.s10)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s2 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
