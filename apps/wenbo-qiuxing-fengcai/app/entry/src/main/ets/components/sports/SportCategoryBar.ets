import { Theme } from '../design-system/Theme'

export type SportCategoryKey = 'all' | 'football' | 'basketball' | 'tennis' | 'racing' | 'other'

export class SportCategoryOption {
  key: SportCategoryKey = 'all'
  label: string = '全部'

  static all(): SportCategoryOption[] {
    const options: SportCategoryOption[] = []
    const o0 = new SportCategoryOption()
    o0.key = 'all'
    o0.label = '全部'
    options.push(o0)
    const o1 = new SportCategoryOption()
    o1.key = 'football'
    o1.label = '足球'
    options.push(o1)
    const o2 = new SportCategoryOption()
    o2.key = 'basketball'
    o2.label = '篮球'
    options.push(o2)
    const o3 = new SportCategoryOption()
    o3.key = 'tennis'
    o3.label = '网球'
    options.push(o3)
    const o4 = new SportCategoryOption()
    o4.key = 'racing'
    o4.label = '赛车'
    options.push(o4)
    const o5 = new SportCategoryOption()
    o5.key = 'other'
    o5.label = '其他'
    options.push(o5)
    return options
  }
}

@Component
export struct SportCategoryBar {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop selected: SportCategoryKey = 'all'
  onSelect: (key: SportCategoryKey) => void = () => {}
  private options: SportCategoryOption[] = SportCategoryOption.all()

  build() {
    Scroll() {
      Row({ space: Theme.space.s2 }) {
        ForEach(this.options, (opt: SportCategoryOption) => {
          Text(opt.label)
            .fontSize(Theme.type.caption)
            .fontWeight(this.selected === opt.key ? FontWeight.Medium : FontWeight.Normal)
            .fontColor(this.selected === opt.key ?
              Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
            .padding({ left: 14, right: 14, top: 8, bottom: 8 })
            .backgroundColor(this.selected === opt.key ?
              Theme.colors().brandPrimary : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.pill)
            .border({
              width: 1,
              color: this.selected === opt.key ?
                Theme.colors().brandPrimary : Theme.colors().strokeHairline
            })
            .onClick((): void => { this.onSelect(opt.key) })
        }, (opt: SportCategoryOption) => opt.key)
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .width('100%')
    .opacity(this.themeEpoch >= 0 ? 1 : 1)
  }
}
