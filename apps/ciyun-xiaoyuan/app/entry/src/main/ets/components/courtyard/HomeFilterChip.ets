import { Theme } from '../design-system/Theme'

export class HomeChipDef {
  id: string = ''
  label: string = ''
  group: string = ''
  value: string = ''

  static of(id: string, label: string, group: string, value: string): HomeChipDef {
    const row = new HomeChipDef()
    row.id = id
    row.label = label
    row.group = group
    row.value = value
    return row
  }

  static catalog(): HomeChipDef[] {
    const list: HomeChipDef[] = []
    list.push(HomeChipDef.of('all', '全部', 'all', ''))
    list.push(HomeChipDef.of('tang', '唐', 'dynasty', '唐'))
    list.push(HomeChipDef.of('song', '宋', 'dynasty', '宋'))
    list.push(HomeChipDef.of('shi', '诗', 'form', '诗'))
    list.push(HomeChipDef.of('ci', '词', 'form', '词'))
    list.push(HomeChipDef.of('shanshui', '山水', 'theme', '山水'))
    list.push(HomeChipDef.of('bian', '边塞', 'theme', '边塞'))
    list.push(HomeChipDef.of('yong', '咏物', 'theme', '咏物'))
    return list
  }
}

@Component
export struct HomeFilterChip {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop label: string = ''
  @Prop selected: boolean = false
  onPick: () => void = () => {}

  build() {
    Row() {
      Text(this.label)
        .fontSize(Theme.type.caption)
        .fontWeight(this.selected ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.selected ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
    }
    .constraintSize({ minHeight: 40, minWidth: 44 })
    .padding({ left: 14, right: 14, top: 8, bottom: 8 })
    .backgroundColor(this.selected ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.pill)
    .border({
      width: 1,
      color: this.selected ? Theme.colors().brandPrimary : Theme.colors().strokeHairline
    })
    .onClick((): void => { this.onPick() })
    .opacity(this.themeEpoch >= 0 ? 1 : 1)
  }
}
