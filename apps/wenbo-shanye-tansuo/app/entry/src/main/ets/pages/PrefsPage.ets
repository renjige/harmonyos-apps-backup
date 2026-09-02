import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { DetailShell } from '../components/detail/DetailShell'
import { MxDetailNav } from '../services/MxDetailNav'

@Component
export struct PrefsPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('prefDifficulty') prefDifficulty: string = '中级'
  @StorageLink('prefInterest') prefInterest: string = '地质'
  @StorageLink('prefDuration') prefDuration: string = 'half'

  private setDifficulty(v: string): void {
    this.prefDifficulty = v
    AppStorage.setOrCreate('prefDifficulty', v)
  }

  private setInterest(v: string): void {
    this.prefInterest = v
    AppStorage.setOrCreate('prefInterest', v)
  }

  private setDuration(v: string): void {
    this.prefDuration = v
    AppStorage.setOrCreate('prefDuration', v)
  }

  build() {
    DetailShell({ title: '难度与兴趣', onClose: () => MxDetailNav.close() }) {
      Column({ space: Theme.space.s4 }) {
        Text('首页「智慧匹配」按这里的选择筛路线。只保存在本机，随时可改。')
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')

        Text('难度')
          .fontSize(Theme.type.subtitleS)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Row({ space: Theme.space.s2 }) {
          this.DiffChip('初级', '初级')
          this.DiffChip('中级', '中级')
          this.DiffChip('高级', '高级')
        }
        .width('100%')

        Text('兴趣')
          .fontSize(Theme.type.subtitleS)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Row({ space: Theme.space.s2 }) {
          this.InterestChip('植物', '植物')
          this.InterestChip('动物', '动物')
          this.InterestChip('地质', '地质')
          this.InterestChip('天文', '天文')
        }
        .width('100%')

        Text('时长')
          .fontSize(Theme.type.subtitleS)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Row({ space: Theme.space.s2 }) {
          this.DurChip('短线', 'short')
          this.DurChip('半日', 'half')
          this.DurChip('长线', 'long')
        }
        .width('100%')

        AppButton({
          label: '去看匹配路线',
          onTap: (): void => {
            MxDetailNav.close()
          }
        })
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      .width('100%')
    }
  }

  @Builder
  DiffChip(label: string, value: string) {
    Text(label)
      .fontSize(Theme.type.footnote)
      .fontColor(this.prefDifficulty === value ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor(this.prefDifficulty === value ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.pill)
      .onClick(() => this.setDifficulty(value))
  }

  @Builder
  InterestChip(label: string, value: string) {
    Text(label)
      .fontSize(Theme.type.footnote)
      .fontColor(this.prefInterest === value ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor(this.prefInterest === value ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.pill)
      .onClick(() => this.setInterest(value))
  }

  @Builder
  DurChip(label: string, value: string) {
    Text(label)
      .fontSize(Theme.type.footnote)
      .fontColor(this.prefDuration === value ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor(this.prefDuration === value ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.pill)
      .onClick(() => this.setDuration(value))
  }
}
