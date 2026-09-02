import { pasteboard } from '@kit.BasicServicesKit'
import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppCard } from '../design-system/AppCard'
import { PortfolioProject } from '../../models/PortfolioModels'
import { PortfolioMedia } from '../../services/PortfolioMedia'
import { DetailShell } from './DetailShell'

@Component
export struct ProjectDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop project: PortfolioProject = new PortfolioProject()
  onClose: () => void = () => {}
  onEdit: () => void = () => {}
  @State toastText: string = ''

  private copyDescription(): void {
    const text = this.project.description.length > 0 ? this.project.description : '暂无描述'
    const pasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text)
    pasteboard.getSystemPasteboard().setData(pasteData)
    this.toastText = '描述已复制'
    setTimeout((): void => { this.toastText = '' }, 2000)
  }

  build() {
    Stack() {
      DetailShell({
        title: this.project.title,
        onClose: (): void => { this.onClose() },
        body: (): void => { this.BodyContent() }
      })

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .position({ x: '10%', y: 56 })
          .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  BodyContent() {
    Stack({ alignContent: Alignment.BottomStart }) {
      if (this.project.imageKeys.length > 0) {
        Swiper() {
          ForEach(this.project.imageKeys, (key: string) => {
            Image(PortfolioMedia.coverResource(key))
              .width('100%')
              .aspectRatio(16 / 9)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.md)
          }, (key: string) => key)
        }
        .width('100%')
        .indicator(true)
        .loop(false)
      } else {
        Image(PortfolioMedia.coverResource(this.project.coverKey))
          .width('100%')
          .aspectRatio(16 / 9)
          .objectFit(ImageFit.Cover)
          .borderRadius(Theme.radius.md)
      }

      Column()
        .width('100%')
        .height(80)
        .linearGradient({
          angle: 180,
          colors: [['rgba(0,0,0,0)', 0], ['rgba(13,13,13,0.72)', 1]]
        })
        .borderRadius({ bottomLeft: Theme.radius.md, bottomRight: Theme.radius.md })
    }
    .width('100%')
    .borderRadius(Theme.radius.md)
    .clip(true)

    Row({ space: Theme.space.s2 }) {
      Text(PortfolioMedia.categoryLabel(this.project.category))
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
        .padding({ left: 10, right: 10, top: 4, bottom: 4 })
        .backgroundColor(Theme.colors().brandPrimaryContainer)
        .borderRadius(Theme.radius.pill)
      Text(`创作于 ${this.project.createdAt}`)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
    }

    AppCard() {
      Text(this.project.description.length > 0 ? this.project.description : '暂无描述')
        .fontSize(Theme.type.body)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .lineHeight(24)
        .width('100%')
    }

    if (this.project.tags.length > 0) {
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.project.tags, (tag: string) => {
          Text(`#${tag}`)
            .fontSize(Theme.type.bodyS)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .padding({ left: 10, right: 10, top: 6, bottom: 6 })
            .backgroundColor(Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.pill)
            .margin({ right: 8, bottom: 8 })
        }, (tag: string) => tag)
      }
      .width('100%')
    }

    Row({ space: Theme.space.s3 }) {
      AppButton({
        label: '复制描述',
        variant: 'secondary',
        onTap: (): void => { this.copyDescription() }
      }).layoutWeight(1)
      AppButton({
        label: '编辑作品',
        variant: 'primary',
        onTap: (): void => { this.onEdit() }
      }).layoutWeight(1)
    }
    .width('100%')
  }
}
