import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { ImportPreview } from '../../models/AppointmentModels'
import { AppointmentTools } from '../../services/AppointmentTools'

@Component
export struct ImportPasteOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State raw: string = ''
  @State previews: ImportPreview[] = []
  onClose: () => void = () => {}
  onCreateAll: (rows: ImportPreview[]) => void = () => {}

  private parseNow(): void {
    this.previews = AppointmentTools.parseImport(this.raw)
  }

  build() {
    Column() {
      Row() {
        Text('返回')
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().brandPrimary)
          .onClick((): void => { this.onClose() })
        Blank()
        Text('粘贴导入')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
        Blank()
        Text(' ')
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 12, bottom: 8 })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text('每行一件。支持「明天 09:00 标题 @地点 与相关人」')
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
          TextArea({ text: this.raw, placeholder: '粘贴或输入多行约定' })
            .height(120)
            .onChange((v: string) => { this.raw = v })
          Row({ space: 8 }) {
            Text('填入示例')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandPrimary)
              .padding({ left: 12, right: 12, top: 8, bottom: 8 })
              .backgroundColor(Theme.colors().brandPrimaryContainer)
              .borderRadius(Theme.radius.pill)
              .onClick((): void => {
                this.raw = AppointmentTools.sampleImport()
                this.parseNow()
              })
            Text('解析')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandOnPrimary)
              .padding({ left: 12, right: 12, top: 8, bottom: 8 })
              .backgroundColor(Theme.colors().brandPrimary)
              .borderRadius(Theme.radius.pill)
              .onClick((): void => { this.parseNow() })
          }
          .width('100%')

          if (this.previews.length > 0) {
            Text(`将创建 ${this.previews.length} 件`)
              .fontSize(Theme.type.subhead)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            ForEach(this.previews, (row: ImportPreview) => {
              Text(`${row.whenLabel}  ${row.title}`)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
                .padding(10)
                .backgroundColor(Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.lg)
            }, (row: ImportPreview) => `${row.whenLabel}_${row.title}`)
            AppButton({
              label: '确认导入',
              onTap: (): void => { this.onCreateAll(this.previews) }
            })
          }
        }
        .padding({ left: 20, right: 20, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}
