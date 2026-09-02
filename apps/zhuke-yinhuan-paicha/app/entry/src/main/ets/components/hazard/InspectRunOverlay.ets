import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { CheckItem } from '../../models/HazardModels'
import { HazardBizService } from '../../services/HazardBizService'

@Component
export struct InspectRunOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State items: CheckItem[] = []
  @State location: string = ''
  onClose: () => void = () => {}
  onSubmit: (items: CheckItem[], location: string) => void = () => {}

  aboutToAppear(): void {
    void this.boot()
  }

  private async boot(): Promise<void> {
    try {
      const raw = await HazardBizService.checklist()
      const next: CheckItem[] = []
      for (const row of raw) {
        next.push(CheckItem.from(row))
      }
      this.items = next
    } catch {
      this.items = []
    }
  }

  private setResult(id: string, result: string): void {
    const next: CheckItem[] = []
    for (const row of this.items) {
      const copy = CheckItem.from(row)
      if (copy.id === id) {
        copy.result = result
      }
      next.push(copy)
    }
    this.items = next
  }

  build() {
    Column() {
      Row() {
        Text('取消').fontSize(15).fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary).onClick(() => this.onClose())
        Text('安全检查').fontSize(18).fontWeight(FontWeight.Medium).fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1).textAlign(TextAlign.Center)
        Text('提交').fontSize(15).fontColor(Theme.colors().brandAccent)
          .onClick(() => this.onSubmit(this.items, this.location))
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 8 })

      Scroll() {
        Column({ space: 12 }) {
          Column({ space: 6 }) {
            Text('检查位置（选填）').fontSize(12).fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary).width('100%')
            TextInput({ text: this.location, placeholder: '例如：3号楼二层' })
              .height(42).backgroundColor(Theme.colors().surfaceSubtle)
              .onChange((v: string) => { this.location = v })
          }
          .padding(16).width('100%').alignItems(HorizontalAlign.Start)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard).borderRadius(Theme.radius.card)

          ForEach(this.items, (it: CheckItem) => {
            Column({ space: 8 }) {
              Text(it.groupName)
                .fontSize(12)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
              Text(it.title)
                .fontSize(15)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              Row({ space: 8 }) {
                Column() {
                  Text('正常')
                    .fontSize(13)
                    .fontColor(it.result === 'ok' ? '#FFFFFF' : '#36A269')
                }
                .layoutWeight(1)
                .height(36)
                .justifyContent(FlexAlign.Center)
                .backgroundColor(it.result === 'ok' ? '#36A269' : '#E8F7F0')
                .borderRadius(10)
                .onClick(() => this.setResult(it.id, 'ok'))
                Column() {
                  Text('异常')
                    .fontSize(13)
                    .fontColor(it.result === 'abnormal' ? '#FFFFFF' : '#D94A4A')
                }
                .layoutWeight(1)
                .height(36)
                .justifyContent(FlexAlign.Center)
                .backgroundColor(it.result === 'abnormal' ? '#D94A4A' : '#FDECEC')
                .borderRadius(10)
                .onClick(() => this.setResult(it.id, 'abnormal'))
              }
              .width('100%')
            }
            .padding(16)
            .width('100%')
            .alignItems(HorizontalAlign.Start)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.card)
          }, (it: CheckItem) => `${it.id}_${it.result}`)

          AppButton({ label: '提交检查', onTap: (): void => { this.onSubmit(this.items, this.location) } })
        }
        .padding({ left: 16, right: 16, bottom: 32 })
        .width('100%')
      }
      .layoutWeight(1)
      .align(Alignment.Top)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
