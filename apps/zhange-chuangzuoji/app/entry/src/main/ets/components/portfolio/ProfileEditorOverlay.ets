import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { CreatorProfile } from '../../models/PortfolioModels'
import { ProfileStore } from '../../services/ProfileStore'
import { PortfolioMedia } from '../../services/PortfolioMedia'

@Component
export struct ProfileEditorOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop profile: CreatorProfile = new CreatorProfile()
  onClose: () => void = () => {}
  onSaved: () => void = () => {}
  @State name: string = ''
  @State title: string = ''
  @State bio: string = ''
  @State email: string = ''
  @State skillsText: string = ''
  @State avatarKey: string = 'hero_studio'
  @State toastText: string = ''
  private avatarKeys: string[] = PortfolioMedia.coverKeys()

  aboutToAppear(): void {
    this.name = this.profile.name
    this.title = this.profile.title
    this.bio = this.profile.bio
    this.email = this.profile.email
    this.skillsText = this.profile.skills.join('、')
    this.avatarKey = this.profile.avatarKey.length > 0 ? this.profile.avatarKey : 'hero_studio'
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2400)
  }

  private parseSkills(): string[] {
    const raw = this.skillsText.split('、')
    const skills: string[] = []
    for (const part of raw) {
      const s = part.trim()
      if (s.length > 0) {
        skills.push(s)
      }
    }
    return skills
  }

  private async save(): Promise<void> {
    if (this.name.trim().length === 0) {
      this.showToast('请填写姓名')
      return
    }
    const next = new CreatorProfile()
    next.name = this.name.trim()
    next.title = this.title.trim()
    next.bio = this.bio.trim()
    next.email = this.email.trim()
    next.skills = this.parseSkills()
    next.avatarKey = this.avatarKey
    await ProfileStore.save(next)
    this.onSaved()
    this.onClose()
  }

  build() {
    Stack() {
      Column() {
        Row({ space: Theme.space.s3 }) {
          Row() {
            AppIcon({ name: 'close', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
          }
          .width(40)
          .height(40)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => { this.onClose() })
          Text('编辑个人资料')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Text('头像')
              .fontSize(Theme.type.bodyS)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')

            Image(PortfolioMedia.coverResource(this.avatarKey))
              .width(88)
              .height(88)
              .borderRadius(44)
              .objectFit(ImageFit.Cover)

            Scroll() {
              Row({ space: Theme.space.s2 }) {
                ForEach(this.avatarKeys, (key: string) => {
                  Image(PortfolioMedia.coverResource(key))
                    .width(56)
                    .height(56)
                    .borderRadius(28)
                    .objectFit(ImageFit.Cover)
                    .border({
                      width: this.avatarKey === key ? 2 : 1,
                      color: this.avatarKey === key ? Theme.colors().brandPrimary : Theme.colors().strokeHairline
                    })
                    .onClick((): void => { this.avatarKey = key })
                }, (key: string) => key)
              }
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)
            .width('100%')

            TextInput({ text: this.name, placeholder: '姓名' })
              .height(44).fontSize(Theme.type.body)
              .onChange((v: string) => { this.name = v })
            TextInput({ text: this.title, placeholder: '一句话介绍' })
              .height(44).fontSize(Theme.type.body)
              .onChange((v: string) => { this.title = v })
            TextArea({ text: this.bio, placeholder: '详细个人介绍…' })
              .height(140).fontSize(Theme.type.bodyS)
              .onChange((v: string) => { this.bio = v })
            TextInput({ text: this.email, placeholder: '联系邮箱' })
              .height(44).fontSize(Theme.type.body)
              .onChange((v: string) => { this.email = v })
            TextInput({ text: this.skillsText, placeholder: '技能标签，用顿号分隔' })
              .height(44).fontSize(Theme.type.bodyS)
              .onChange((v: string) => { this.skillsText = v })
            AppButton({
              label: '保存资料',
              variant: 'primary',
              onTap: (): void => { void this.save() }
            })
          }
          .width('100%')
          .padding(Theme.space.pageX)
          .padding({ bottom: Theme.space.s6 })
        }
        .layoutWeight(1)
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
          .position({ x: '10%', y: 56 })
          .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }
}
