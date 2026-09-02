import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppNavBar } from '../design-system/AppNavBar'
import { AppEmpty } from '../design-system/AppEmpty'
import { SportFollow } from '../../models/SaituSportModels'
import { SaituSportStore } from '../../services/SaituSportStore'
import { SaituDetailNav } from '../../services/SaituDetailNav'

@Component
export struct SportFollowSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onChanged: () => void = () => {}
  @State items: SportFollow[] = []
  @State name: string = ''
  @State note: string = ''
  @State role: string = 'team'
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.items = await SaituSportStore.loadFollows()
  }

  private async save(): Promise<void> {
    if (this.name.trim().length === 0) {
      this.toastText = '请填写球队或选手名称'
      setTimeout((): void => { this.toastText = '' }, 2200)
      return
    }
    const f = SportFollow.create()
    f.name = this.name.trim()
    f.note = this.note.trim()
    f.role = this.role
    await SaituSportStore.saveFollow(f)
    this.name = ''
    this.note = ''
    await this.reload()
    this.onChanged()
    this.toastText = '已加入关注列表'
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private async remove(id: string): Promise<void> {
    await SaituSportStore.deleteFollow(id)
    await this.reload()
    this.onChanged()
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        AppNavBar({
          title: '球队与选手关注',
          onBack: (): void => SaituDetailNav.closeFollow()
        })
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            Text('本机收藏关注对象，可写备注，不拉取实时赛况。')
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            TextInput({ text: this.name, placeholder: '球队或选手名称' })
              .onChange((v: string): void => { this.name = v })
            TextInput({ text: this.note, placeholder: '个人备注，如：经典后卫组合' })
              .onChange((v: string): void => { this.note = v })
            Row({ space: Theme.space.s2 }) {
              Text('球队')
                .fontSize(Theme.type.bodyS)
                .fontColor(this.role === 'team' ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .backgroundColor(this.role === 'team' ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => { this.role = 'team' })
              Text('选手')
                .fontSize(Theme.type.bodyS)
                .fontColor(this.role === 'player' ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .backgroundColor(this.role === 'player' ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => { this.role = 'player' })
            }
            AppButton({ label: '加入关注', variant: 'primary', onTap: (): void => { void this.save() } })
            if (this.items.length === 0) {
              AppEmpty({ title: '还没有关注', description: '记下喜欢的球队或运动员' })
            } else {
              ForEach(this.items, (f: SportFollow) => {
                Row() {
                  Column({ space: 4 }) {
                    Text(`${f.roleLabel()} · ${f.name}`)
                      .fontSize(Theme.type.body)
                      .fontColor(Theme.colors().textPrimary)
                    if (f.note.length > 0) {
                      Text(f.note)
                        .fontSize(Theme.type.caption)
                        .fontColor(Theme.colors().textSecondary)
                    }
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)
                  Text('详情')
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().brandPrimary)
                    .onClick((): void => SaituDetailNav.openFollowDetail(f.id))
                  Text('移除')
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().danger)
                    .margin({ left: 8 })
                    .onClick((): void => { void this.remove(f.id) })
                }
                .width('100%')
                .padding(Theme.space.cardPadding)
                .backgroundColor(Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.lg)
                .onClick((): void => SaituDetailNav.openFollowDetail(f.id))
              }, (f: SportFollow) => f.id)
            }
            Blank().height(Theme.space.s10)
          }
          .padding(Theme.space.pageX)
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().surfaceInverse)
          .borderRadius(Theme.radius.pill)
          .margin({ top: Theme.space.s8 })
      }
    }
    .width('100%')
    .height('100%')
  }
}
