import { pasteboard } from '@kit.BasicServicesKit'
import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { CreatorProfile } from '../models/PortfolioModels'
import { ProfileStore } from '../services/ProfileStore'
import { PortfolioMedia } from '../services/PortfolioMedia'

@Component
export struct AboutPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onReloadTokenChange') reloadToken: number = 0
  onEditProfile: () => void = () => {}
  @State profile: CreatorProfile = new CreatorProfile()
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.load()
  }

  onReloadTokenChange(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    this.profile = await ProfileStore.load()
  }

  private copyEmail(): void {
    if (this.profile.email.length === 0) {
      return
    }
    const pasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, this.profile.email)
    pasteboard.getSystemPasteboard().setData(pasteData)
    this.toastText = '邮箱已复制'
    setTimeout((): void => { this.toastText = '' }, 2000)
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s5 }) {
          Image(PortfolioMedia.coverResource(this.profile.avatarKey))
            .width(120)
            .height(120)
            .borderRadius(60)
            .objectFit(ImageFit.Cover)
            .margin({ top: Theme.space.s6 })

          Text(this.profile.name)
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)

          Text(this.profile.title)
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .textAlign(TextAlign.Center)

          Text(this.profile.bio)
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .lineHeight(24)
            .textAlign(TextAlign.Start)
            .width('100%')

          AppButton({
            label: '编辑个人资料',
            variant: 'secondary',
            onTap: (): void => { this.onEditProfile() }
          })

          Text('技能标签')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')

          if (this.profile.skills.length === 0) {
            Text('暂无技能标签，点击上方按钮添加')
              .fontSize(Theme.type.bodyS)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
          } else {
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.profile.skills, (skill: string) => {
                Text(skill)
                  .fontSize(Theme.type.bodyS)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                  .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                  .backgroundColor(Theme.colors().brandPrimaryContainer)
                  .borderRadius(Theme.radius.pill)
                  .margin({ right: 8, bottom: 8 })
              }, (skill: string) => skill)
            }
            .width('100%')
          }

          if (this.profile.email.length > 0) {
            Column({ space: Theme.space.s2 }) {
              Text('联系方式')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              Text(this.profile.email)
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .onClick((): void => { this.copyEmail() })
          }
        }
        .width('100%')
        .padding(Theme.space.pageX)
        .padding({ bottom: Theme.space.s4 })
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .position({ x: '10%', y: 48 })
          .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }
}
