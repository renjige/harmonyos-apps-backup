import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { common } from '@kit.AbilityKit'
import { FactItem } from '../../models/CommonSenseModels'
import { CommonSenseBizService } from '../../services/CommonSenseBizService'
import { CommonSenseDetailNav } from '../../services/CommonSenseDetailNav'
import { CommonSenseMedia } from '../../services/CommonSenseMedia'
import { ShareService } from '../../services/ShareService'

@Component
export struct ShareCardPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop itemId: string = ''
  @State item: FactItem = new FactItem()
  @State loaded: boolean = false
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    this.loaded = false
    for (const row of CommonSenseBizService.cachedFacts()) {
      if (row.id === this.itemId) {
        this.item = row
        this.loaded = true
        return
      }
    }
    const found = await CommonSenseBizService.findFact(this.itemId)
    if (found !== undefined) {
      this.item = found
      this.loaded = true
    }
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private async copyCard(): Promise<void> {
    if (!this.loaded || this.item.id.length === 0) {
      this.showToast('卡片加载中，请稍候')
      return
    }
    this.showToast(await ShareService.shareFact(this.item))
  }

  private async saveCard(): Promise<void> {
    if (!this.loaded || this.item.id.length === 0) {
      this.showToast('卡片加载中，请稍候')
      return
    }
    const ctx = this.getUIContext().getHostContext() as common.UIAbilityContext
    this.showToast(await ShareService.saveCardFile(this.item, ctx))
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column({ space: Theme.space.s4 }) {
        Row({ space: Theme.space.s2 }) {
          Column() {
            AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .rotate({ angle: 180 })
          .onClick((): void => { CommonSenseDetailNav.close() })
          Text('知识卡片')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

        Stack({ alignContent: Alignment.BottomStart }) {
          Image(CommonSenseMedia.resource(this.item.coverKey))
            .width('100%')
            .height(280)
            .objectFit(ImageFit.Cover)
          Column()
            .width('100%')
            .height(280)
            .linearGradient({
              angle: 180,
              colors: [['rgba(10,37,64,0.1)', 0.2], ['rgba(10,37,64,0.88)', 1]]
            })
          Column({ space: 8 }) {
            Text(this.item.categoryLabel())
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandAccent)
            Text(this.loaded ? this.item.title : '加载卡片中…')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
              .maxLines(3)
            Text(this.loaded ? this.item.summary : '')
              .fontSize(Theme.type.subhead)
              .fontColor('#E8ECF1')
              .maxLines(4)
            Text('常识集')
              .fontSize(Theme.type.caption)
              .fontColor('#F5F7FA')
          }
          .padding(Theme.space.s5)
          .width('100%')
          .alignItems(HorizontalAlign.Start)
        }
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
        .borderRadius(Theme.radius.card)
        .clip(true)

        Column({ space: Theme.space.s3 }) {
          AppButton({
            label: this.loaded ? '复制卡片文案' : '加载中…',
            onTap: (): void => { void this.copyCard() }
          })
          AppButton({
            label: this.loaded ? '保存到本机文件' : '加载中…',
            variant: 'secondary',
            onTap: (): void => { void this.saveCard() }
          })
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
          .margin({ top: Theme.space.s6 })
      }
    }
    .width('100%')
    .height('100%')
  }
}
