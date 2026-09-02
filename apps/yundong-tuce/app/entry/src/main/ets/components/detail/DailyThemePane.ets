import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { TuceStore } from '../../services/TuceStore'
import { TuceNav } from '../../services/TuceNav'
import { TuceEngine } from '../../services/TuceEngine'

@Component
export struct DailyThemePane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State word: string = ''
  @State hint: string = ''

  aboutToAppear(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    this.word = await TuceStore.dailyThemeWord()
    if (this.word.length === 0) {
      this.word = await TuceEngine.dailyTheme()
      this.hint = '系统推荐主题，可修改后保存为今日专属词'
    } else {
      this.hint = '这是你为今天设定的训练主题'
    }
  }

  private async save(): Promise<void> {
    if (this.word.trim().length === 0) {
      return
    }
    await TuceStore.saveDailyTheme(this.word.trim())
    TuceNav.bump()
    TuceNav.close()
  }

  build() {
    Column({ space: Theme.space.s4 }) {
      Text('今日训练主题')
        .fontSize(Theme.type.title2)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Text(this.hint)
        .fontSize(Theme.type.bodyS)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      TextInput({ text: this.word, placeholder: '如：专注、恢复、突破' })
        .onChange((v: string): void => { this.word = v })
      Text('一句话主题会显示在首页 Hero，提醒自己今天的训练状态。')
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      AppButton({ label: '保存今日主题', variant: 'primary', onTap: (): void => { void this.save() } })
    }
    .width('100%')
    .height('100%')
    .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
  }
}
