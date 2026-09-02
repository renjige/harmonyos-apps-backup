import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { SeasonGoal } from '../../models/SportExtra'
import { GoalStore } from '../../services/GoalStore'

@Component
export struct GoalSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop goal: SeasonGoal = new SeasonGoal()
  onClose: () => void = () => {}
  onSaved: () => void = () => {}
  @State matchText: string = '12'
  @State minText: string = '600'
  @State toastText: string = ''

  aboutToAppear(): void {
    this.matchText = `${this.goal.targetMatches}`
    this.minText = `${this.goal.targetMinutes}`
  }

  private async save(): Promise<void> {
    const matches = parseInt(this.matchText, 10)
    const minutes = parseInt(this.minText, 10)
    if (!(matches >= 1) || !(minutes >= 1)) {
      this.toastText = '请填写大于 0 的目标数字'
      setTimeout((): void => { this.toastText = '' }, 2200)
      return
    }
    const g = new SeasonGoal()
    g.year = new Date().getFullYear()
    g.targetMatches = matches
    g.targetMinutes = minutes
    await GoalStore.save(g)
    this.onSaved()
    this.onClose()
  }

  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.colors().overlayScrim)
        .onClick((): void => { this.onClose() })

      Column({ space: Theme.space.s4 }) {
        Row() {
          Text('本赛季目标')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Blank()
          AppIcon({ name: 'close', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width('100%')
        .onClick((): void => { this.onClose() })

        Text('用可完成的场次与时长约束自己，而不是只浏览旧记录。')
          .fontSize(Theme.type.bodyS)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)

        Text('目标场次')
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        TextInput({ text: this.matchText, placeholder: '例如 12' })
          .type(InputType.Number)
          .onChange((v: string) => { this.matchText = v })
          .backgroundColor(Theme.colors().surfaceSubtle)
          .borderRadius(Theme.radius.md)
          .padding(Theme.space.s3)

        Text('目标时长（分钟）')
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        TextInput({ text: this.minText, placeholder: '例如 600' })
          .type(InputType.Number)
          .onChange((v: string) => { this.minText = v })
          .backgroundColor(Theme.colors().surfaceSubtle)
          .borderRadius(Theme.radius.md)
          .padding(Theme.space.s3)

        AppButton({
          label: '保存目标',
          variant: 'primary',
          onTap: (): void => { void this.save() }
        })
      }
      .width('88%')
      .padding(Theme.space.s5)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.xl)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .padding(10)
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .position({ x: '16%', y: 40 })
      }
    }
    .width('100%')
    .height('100%')
    .zIndex(70)
    .onAppear((): void => { AppStorage.setOrCreate('tabBarHidden', true) })
    .onDisAppear((): void => { AppStorage.setOrCreate('tabBarHidden', false) })
  }
}
