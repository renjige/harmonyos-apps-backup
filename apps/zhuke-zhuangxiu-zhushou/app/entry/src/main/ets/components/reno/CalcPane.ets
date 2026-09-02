import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { RenoGuide } from '../../models/RenoModels'
import { RenoCalc, RenoCalcResult } from '../../services/RenoCalc'
import { RenoCatalog } from '../../services/RenoCatalog'

@Component
export struct CalcPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State tab: string = 'area'
  @State a: string = ''
  @State b: string = ''
  @State c: string = ''
  @State d: string = ''
  @State result: RenoCalcResult = new RenoCalcResult()
  @State guides: RenoGuide[] = []
  onClose: () => void = () => {}

  aboutToAppear(): void {
    void this.loadGuides()
  }

  private async loadGuides(): Promise<void> {
    this.guides = await RenoCatalog.guides()
  }

  private hint(): string {
    for (const g of this.guides) {
      if (this.tab === 'area' && g.id.indexOf('area') >= 0) {
        return g.body
      }
      if (this.tab === 'wall' && g.id.indexOf('wall') >= 0) {
        return g.body
      }
      if (this.tab === 'tile' && g.id.indexOf('tile') >= 0) {
        return g.body
      }
      if (this.tab === 'paint' && g.id.indexOf('paint') >= 0) {
        return g.body
      }
    }
    return RenoCalc.DISCLAIMER
  }

  private run(): void {
    if (this.tab === 'area') {
      this.result = RenoCalc.area(this.a, this.b)
      return
    }
    if (this.tab === 'wall') {
      this.result = RenoCalc.wall(this.a, this.b)
      return
    }
    if (this.tab === 'tile') {
      this.result = RenoCalc.tiles(this.a, this.b, this.c, this.d.length > 0 ? this.d : '8')
      return
    }
    this.result = RenoCalc.paint(this.a, this.b.length > 0 ? this.b : '2', this.c.length > 0 ? this.c : '10')
  }

  build() {
    Column() {
      Row() {
        Text('计算工具')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
        Text('关闭').fontSize(Theme.type.body).fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary).onClick(() => this.onClose())
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: 16, bottom: 8 })
      Scroll() {
        Column({ space: 12 }) {
          Row({ space: 8 }) {
            this.TabBtn('area', '面积')
            this.TabBtn('wall', '墙面')
            this.TabBtn('tile', '瓷砖')
            this.TabBtn('paint', '涂料')
          }
          .width('100%')
          this.Fields()
          AppButton({ label: '开始计算', onTap: () => this.run() })
          if (this.result.value.length > 0 || this.result.hint.length > 0) {
            Column({ space: 6 }) {
              if (this.result.ok) {
                Text(this.result.value)
                  .fontSize(Theme.type.title2)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                  .width('100%')
              }
              Text(this.result.hint.length > 0 ? this.result.hint : this.hint())
                .fontSize(Theme.type.caption)
                .fontColor(this.result.ok ? Theme.colors().textSecondary : Theme.colors().danger)
                .width('100%')
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
          }
          Text(this.hint())
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textTertiary)
            .width('100%')
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  TabBtn(id: string, label: string) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(this.tab === id ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor(this.tab === id ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.sm)
      .layoutWeight(1)
      .textAlign(TextAlign.Center)
      .onClick(() => {
        this.tab = id
        this.result = new RenoCalcResult()
        this.a = ''
        this.b = ''
        this.c = ''
        this.d = ''
      })
  }

  @Builder
  Fields() {
    if (this.tab === 'area') {
      TextInput({ text: this.a, placeholder: '长度（米）' }).onChange((v: string) => { this.a = v })
        .height(48).backgroundColor(Theme.colors().surfaceSubtle).borderRadius(Theme.radius.sm)
      TextInput({ text: this.b, placeholder: '宽度（米）' }).onChange((v: string) => { this.b = v })
        .height(48).backgroundColor(Theme.colors().surfaceSubtle).borderRadius(Theme.radius.sm)
    } else if (this.tab === 'wall') {
      TextInput({ text: this.a, placeholder: '墙宽（米）' }).onChange((v: string) => { this.a = v })
        .height(48).backgroundColor(Theme.colors().surfaceSubtle).borderRadius(Theme.radius.sm)
      TextInput({ text: this.b, placeholder: '墙高（米）' }).onChange((v: string) => { this.b = v })
        .height(48).backgroundColor(Theme.colors().surfaceSubtle).borderRadius(Theme.radius.sm)
    } else if (this.tab === 'tile') {
      TextInput({ text: this.a, placeholder: '施工面积（㎡）' }).onChange((v: string) => { this.a = v })
        .height(48).backgroundColor(Theme.colors().surfaceSubtle).borderRadius(Theme.radius.sm)
      TextInput({ text: this.b, placeholder: '瓷砖长（厘米）' }).onChange((v: string) => { this.b = v })
        .height(48).backgroundColor(Theme.colors().surfaceSubtle).borderRadius(Theme.radius.sm)
      TextInput({ text: this.c, placeholder: '瓷砖宽（厘米）' }).onChange((v: string) => { this.c = v })
        .height(48).backgroundColor(Theme.colors().surfaceSubtle).borderRadius(Theme.radius.sm)
      TextInput({ text: this.d, placeholder: '损耗比例 %，默认 8' }).onChange((v: string) => { this.d = v })
        .height(48).backgroundColor(Theme.colors().surfaceSubtle).borderRadius(Theme.radius.sm)
    } else {
      TextInput({ text: this.a, placeholder: '墙面面积（㎡）' }).onChange((v: string) => { this.a = v })
        .height(48).backgroundColor(Theme.colors().surfaceSubtle).borderRadius(Theme.radius.sm)
      TextInput({ text: this.b, placeholder: '涂刷遍数，默认 2' }).onChange((v: string) => { this.b = v })
        .height(48).backgroundColor(Theme.colors().surfaceSubtle).borderRadius(Theme.radius.sm)
      TextInput({ text: this.c, placeholder: '每升覆盖㎡，默认 10' }).onChange((v: string) => { this.c = v })
        .height(48).backgroundColor(Theme.colors().surfaceSubtle).borderRadius(Theme.radius.sm)
    }
  }
}
