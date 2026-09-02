import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { RecapPhase } from '../models/CollectModels'
import { RecordStore } from '../services/RecordStore'

@Component
export struct RecapTimelinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop seedId: string = ''
  @State phases: RecapPhase[] = RecapPhase.template()
  @State toastText: string = ''
  onClose: () => void = () => {}
  onSaved: () => void = () => {}

  aboutToAppear(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    const found = await RecordStore.findById(this.seedId)
    if (found !== undefined) {
      this.phases = RecapPhase.unpack(found.recapPhases)
    }
  }

  private updatePhase(id: string, text: string): void {
    const next: RecapPhase[] = []
    for (const p of this.phases) {
      const n = new RecapPhase()
      n.id = p.id
      n.label = p.label
      n.text = p.id === id ? text : p.text
      next.push(n)
    }
    this.phases = next
  }

  private async save(): Promise<void> {
    const found = await RecordStore.findById(this.seedId)
    if (found === undefined) {
      this.toastText = '未找到本场记录'
      setTimeout((): void => { this.toastText = '' }, 2200)
      return
    }
    found.recapPhases = RecapPhase.pack(this.phases)
    await RecordStore.saveRecord(found)
    this.onSaved()
    this.onClose()
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Row() {
            AppIcon({ name: 'close', iconSize: Theme.icon.lg, color: Theme.colors().textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => { this.onClose() })
          Blank()
          Text('比赛复盘时间轴')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Blank()
          Column().width(44)
        }
        .width('100%')
        .padding(Theme.space.pageX)

        Text('开场 → 上半场 → 中场 → 下半场 → 关键时刻 → 结束')
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            ForEach(this.phases, (p: RecapPhase) => {
              Column({ space: 6 }) {
                Text(p.label)
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                TextArea({ text: p.text, placeholder: `记下${p.label}发生了什么` })
                  .height(88)
                  .onChange((v: string) => { this.updatePhase(p.id, v) })
                  .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                  .borderRadius(Theme.radius.md)
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)
            }, (p: RecapPhase) => p.id)
          }
          .width('100%')
          .padding(Theme.space.pageX)
          .padding({ bottom: 100 })
        }
        .layoutWeight(1)

        Column() {
          AppButton({ label: '保存复盘时间轴', variant: 'primary', onTap: (): void => { void this.save() } })
        }
        .width('100%')
        .padding(Theme.space.pageX)
        .padding({ bottom: Theme.space.s4 })
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
          .position({ x: '12%', y: 48 })
          .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
    .zIndex(60)
    .onAppear((): void => { AppStorage.setOrCreate('tabBarHidden', true) })
    .onDisAppear((): void => { AppStorage.setOrCreate('tabBarHidden', false) })
  }
}
