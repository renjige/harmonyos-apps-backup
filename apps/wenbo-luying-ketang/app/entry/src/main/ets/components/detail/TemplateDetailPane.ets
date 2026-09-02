import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { AuthService } from '../../services/AuthService'
import { CampBizService } from '../../services/CampBizService'
import { CampDetailNav } from '../../services/CampDetailNav'
import { CampMedia } from '../../services/CampMedia'
import { CampWriteRequest, CatalogItem, GearLine } from '../../models/CampModels'
import { DetailShell } from './DetailShell'

@Component
export struct TemplateDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onIdChange') itemId: string = ''
  @Prop @Watch('onIdChange') refreshToken: number = 0
  @State item: CatalogItem | undefined = undefined
  @State lines: GearLine[] = []
  @State loading: boolean = true
  @State toastText: string = ''
  onRequireAuth: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onIdChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.item = await CampBizService.findTemplate(this.itemId)
    this.lines = this.item !== undefined ? this.item.parseLines() : []
    this.loading = false
  }

  private async applyTemplate(): Promise<void> {
    if (!AuthService.requireAuth('manage_gear')) {
      this.onRequireAuth()
      return
    }
    if (this.item === undefined) {
      return
    }
    for (const line of this.lines) {
      const body = new CampWriteRequest()
      body.title = line.name
      body.category = this.item.scene
      body.weightG = line.weightG
      await CampBizService.create('gear', body)
    }
    this.toastText = '已加入我的装备库'
    setTimeout(() => {
      this.toastText = ''
    }, 2200)
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      if (this.loading) {
        Column() {
          AppLoading({ label: '打开套装' })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else if (this.item === undefined) {
        DetailShell({ title: '模板', onClose: () => CampDetailNav.close() }) {
          AppEmpty({ title: '模板不存在', actionLabel: '返回', onAction: () => CampDetailNav.close() })
        }
      } else {
        DetailShell({ title: this.item.title, onClose: () => CampDetailNav.close() }) {
          Column({ space: Theme.space.s5 }) {
            Stack({ alignContent: Alignment.BottomStart }) {
              Image(CampMedia.resource(this.item.coverKey))
                .width('100%')
                .height(180)
                .objectFit(ImageFit.Cover)
              Column()
                .width('100%')
                .height(80)
                .linearGradient({
                  angle: 180,
                  colors: [['rgba(22,51,24,0)', 0.0], ['rgba(22,51,24,0.72)', 1.0]]
                })
              Text(this.item.title)
                .fontSize(Theme.type.subtitleL)
                .fontWeight(FontWeight.Bold)
                .fontColor('#F5F0E8')
                .padding(16)
                .width('100%')
            }
            .width('100%')
            .height(180)
            .clip(true)
            .borderRadius(Theme.radius.card)
            .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
            Column({ space: 8 }) {
              Text(this.item.scene)
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                .width('100%')
              Text(this.item.summary)
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              Text(`合计 ${this.item.weightLabel()}`)
                .fontSize(Theme.type.subtitleS)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
            }
            .padding(Theme.space.s4)
            .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.card)

            Text(this.item.body)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
              .width('100%')

            ForEach(this.lines, (line: GearLine) => {
              Row() {
                Text(line.name)
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .layoutWeight(1)
                Text(`${line.weightG} g`)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              }
              .width('100%')
              .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: 8, bottom: 8 })
            }, (line: GearLine) => line.name)

            AppButton({
              label: '套用到我的装备库',
              onTap: () => { void this.applyTemplate() }
            }).margin({ left: Theme.space.pageX, right: Theme.space.pageX })
          }
        }
      }
      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 56 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
