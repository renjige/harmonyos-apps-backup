import { Theme } from '../design-system/Theme'
import { DetailShell } from '../detail/DetailShell'
import { AppButton } from '../design-system/AppButton'
import { AdvancedFilter } from '../../models/GrowthModels'

@Component
export struct AdvancedFilterSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop filter: AdvancedFilter = new AdvancedFilter()
  onClose: () => void = () => {}
  onApply: (f: AdvancedFilter) => void = (_f: AdvancedFilter) => {}
  @State keyword: string = ''
  @State starredOnly: boolean = false
  @State frameKind: string = ''
  @State verdict: string = ''

  aboutToAppear(): void {
    this.keyword = this.filter.keyword
    this.starredOnly = this.filter.starredOnly
    this.frameKind = this.filter.frameKind
    this.verdict = this.filter.verdict
  }

  build() {
    Column() {
      DetailShell({ title: '高级筛选', onClose: (): void => { this.onClose() } })
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          TextInput({ text: this.keyword, placeholder: '关键词' })
            .width('100%')
            .onChange((v: string) => { this.keyword = v })
          Row({ space: 8 }) {
            this.Chip('仅星标', this.starredOnly, (): void => { this.starredOnly = !this.starredOnly })
            this.Chip('判断类', this.frameKind === 'judge', (): void => {
              this.frameKind = this.frameKind === 'judge' ? '' : 'judge'
            })
            this.Chip('待验收', this.verdict === 'pending', (): void => {
              this.verdict = this.verdict === 'pending' ? '' : 'pending'
            })
          }
          .width('100%')
          AppButton({
            label: '应用筛选',
            variant: 'primary',
            onTap: (): void => {
              const f = new AdvancedFilter()
              f.keyword = this.keyword.trim()
              f.starredOnly = this.starredOnly
              f.frameKind = this.frameKind
              f.verdict = this.verdict
              this.onApply(f)
            }
          })
          AppButton({
            label: '重置',
            variant: 'secondary',
            onTap: (): void => {
              const f = new AdvancedFilter()
              this.onApply(f)
            }
          })
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.s4,
          bottom: Theme.space.s10
        })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }

  @Builder
  Chip(label: string, active: boolean, action: () => void) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(active ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor(active ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { action() })
  }
}
