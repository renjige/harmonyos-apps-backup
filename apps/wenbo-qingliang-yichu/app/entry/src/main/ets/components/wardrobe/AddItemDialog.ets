import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { AppButton } from '../design-system/AppButton'
import { WardrobeItemModel } from '../../models/WardrobeModels'
import { WardrobeMedia, PresetColor } from '../../services/WardrobeMedia'

@Component
export struct AddItemDialog {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop isEdit: boolean = false
  @Prop editItem: WardrobeItemModel = new WardrobeItemModel()
  onSave: (item: WardrobeItemModel) => void = () => {}
  onCancel: () => void = () => {}

  @State name: string = ''
  @State category: string = '上装'
  @State color: string = '浅蓝'
  @State season: string = '夏季'
  @State scene: string = '日常'
  @State remark: string = ''
  @State errorMessage: string = ''

  aboutToAppear(): void {
    if (this.isEdit && this.editItem) {
      this.name = this.editItem.name
      this.category = this.editItem.category
      this.color = this.editItem.color
      this.season = this.editItem.season
      this.scene = this.editItem.scene
      this.remark = this.editItem.remark
    }
  }

  private handleSave(): void {
    const trimmed = this.name.trim()
    if (trimmed.length === 0) {
      this.errorMessage = '请输入衣物名称'
      return
    }
    this.errorMessage = ''

    const id = this.isEdit && this.editItem && this.editItem.id.length > 0 ? this.editItem.id : ''
    const wearCount = this.isEdit && this.editItem ? this.editItem.wearCount : 0
    const lastWornAt = this.isEdit && this.editItem ? this.editItem.lastWornAt : ''
    const colorHex = WardrobeMedia.resolveColorHex(this.color)

    const item = new WardrobeItemModel(
      id,
      trimmed,
      this.category,
      this.color,
      colorHex,
      this.season,
      this.scene,
      this.remark.trim(),
      'shirt_blue',
      wearCount,
      lastWornAt
    )
    this.onSave(item)
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      // Background mask
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.colors().surfaceMask)
        .onClick(() => this.onCancel())

      // Form container
      Column() {
        // Drag handle & Header
        Row() {
          Column() {
            Text(this.isEdit ? '编辑衣物' : '＋ 添加新衣物')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)

            Text('轻量记录，让每次搭配都有迹可循')
              .fontSize(Theme.type.caption1)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .margin({ top: 2 })
          }
          .alignItems(HorizontalAlign.Start)

          Blank()

          Row() {
            AppIcon({ name: 'close', iconSize: Theme.icon.md, color: Theme.colors().textSecondary })
          }
          .padding(8)
          .onClick(() => this.onCancel())
        }
        .width('100%')
        .margin({ bottom: Theme.space.s4 })

        if (this.errorMessage.length > 0) {
          Row({ space: 6 }) {
            AppIcon({ name: 'alert', iconSize: 14, color: Theme.colors().semanticError })
            Text(this.errorMessage)
              .fontSize(Theme.type.caption1)
              .fontColor(Theme.colors().semanticError)
          }
          .width('100%')
          .padding({ left: 10, right: 10, top: 6, bottom: 6 })
          .backgroundColor('#FEE2E2')
          .borderRadius(Theme.radius.xs)
          .margin({ bottom: Theme.space.s3 })
        }

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            // 1. Name input
            Column({ space: 6 }) {
              Text('衣物名称')
                .fontSize(Theme.type.callout)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)

              TextInput({ text: this.name, placeholder: '例如：浅蓝亚麻衬衫 / 米白直筒裤' })
                .fontSize(Theme.type.body)
                .backgroundColor(Theme.isDark() ? '#22302D' : '#F2F6F4')
                .borderRadius(Theme.radius.sm)
                .padding(Theme.space.s3)
                .onChange((v: string) => {
                  this.name = v
                  if (this.errorMessage.length > 0) this.errorMessage = ''
                })
            }
            .alignItems(HorizontalAlign.Start)
            .width('100%')

            // 2. Category selection
            Column({ space: 6 }) {
              Text('类别')
                .fontSize(Theme.type.callout)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)

              Flex({ wrap: FlexWrap.Wrap, space: { main: { value: 8, unit: 0 }, cross: { value: 8, unit: 0 } } }) {
                ForEach(WardrobeMedia.CATEGORIES, (cat: string) => {
                  Text(cat)
                    .fontSize(Theme.type.subheadline)
                    .fontColor(this.category === cat ? '#FFFFFF' : Theme.colors().textPrimary)
                    .padding({ left: 14, right: 14, top: 7, bottom: 7 })
                    .backgroundColor(this.category === cat ? Theme.colors().brandPrimary : (Theme.isDark() ? '#22302D' : '#EEF5F2'))
                    .borderRadius(Theme.radius.pill)
                    .onClick(() => { this.category = cat })
                }, (cat: string) => cat)
              }
            }
            .alignItems(HorizontalAlign.Start)
            .width('100%')

            // 3. Color selection
            Column({ space: 6 }) {
              Text('颜色')
                .fontSize(Theme.type.callout)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)

              Flex({ wrap: FlexWrap.Wrap, space: { main: { value: 8, unit: 0 }, cross: { value: 8, unit: 0 } } }) {
                ForEach(WardrobeMedia.PRESET_COLORS, (c: PresetColor) => {
                  Row({ space: 4 }) {
                    Circle({ width: 10, height: 10 })
                      .fill(c.hex)
                      .stroke(Theme.colors().strokeHairline)
                      .strokeWidth(1)

                    Text(c.name)
                      .fontSize(Theme.type.caption1)
                      .fontColor(this.color === c.name ? Theme.colors().brandPrimary : Theme.colors().textPrimary)
                      .fontWeight(this.color === c.name ? FontWeight.Bold : FontWeight.Normal)
                  }
                  .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                  .backgroundColor(this.color === c.name ? (Theme.isDark() ? '#1B3B32' : '#DDF2EB') : (Theme.isDark() ? '#22302D' : '#EEF5F2'))
                  .borderRadius(Theme.radius.pill)
                  .border({
                    width: this.color === c.name ? 1 : 0,
                    color: Theme.colors().brandPrimary
                  })
                  .onClick(() => { this.color = c.name })
                }, (c: PresetColor) => c.name)
              }
            }
            .alignItems(HorizontalAlign.Start)
            .width('100%')

            // 4. Season selection
            Column({ space: 6 }) {
              Text('适用季节')
                .fontSize(Theme.type.callout)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)

              Flex({ wrap: FlexWrap.Wrap, space: { main: { value: 8, unit: 0 }, cross: { value: 8, unit: 0 } } }) {
                ForEach(WardrobeMedia.SEASONS, (s: string) => {
                  Text(s)
                    .fontSize(Theme.type.caption1)
                    .fontColor(this.season === s ? '#FFFFFF' : Theme.colors().textPrimary)
                    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                    .backgroundColor(this.season === s ? Theme.colors().brandPrimary : (Theme.isDark() ? '#22302D' : '#EEF5F2'))
                    .borderRadius(Theme.radius.pill)
                    .onClick(() => { this.season = s })
                }, (s: string) => s)
              }
            }
            .alignItems(HorizontalAlign.Start)
            .width('100%')

            // 5. Scene selection
            Column({ space: 6 }) {
              Text('穿着场景')
                .fontSize(Theme.type.callout)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)

              Flex({ wrap: FlexWrap.Wrap, space: { main: { value: 8, unit: 0 }, cross: { value: 8, unit: 0 } } }) {
                ForEach(WardrobeMedia.SCENES, (sc: string) => {
                  Text(sc)
                    .fontSize(Theme.type.caption1)
                    .fontColor(this.scene === sc ? '#FFFFFF' : Theme.colors().textPrimary)
                    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                    .backgroundColor(this.scene === sc ? Theme.colors().brandPrimary : (Theme.isDark() ? '#22302D' : '#EEF5F2'))
                    .borderRadius(Theme.radius.pill)
                    .onClick(() => { this.scene = sc })
                }, (sc: string) => sc)
              }
            }
            .alignItems(HorizontalAlign.Start)
            .width('100%')

            // 6. Remark input
            Column({ space: 6 }) {
              Text('备注说明 (选填)')
                .fontSize(Theme.type.callout)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)

              TextInput({ text: this.remark, placeholder: '例如：亚麻透气 / 垂坠免烫 / 适合搭配浅色下装' })
                .fontSize(Theme.type.subheadline)
                .backgroundColor(Theme.isDark() ? '#22302D' : '#F2F6F4')
                .borderRadius(Theme.radius.sm)
                .padding(Theme.space.s3)
                .onChange((v: string) => { this.remark = v })
            }
            .alignItems(HorizontalAlign.Start)
            .width('100%')
          }
          .padding({ bottom: Theme.space.s6 })
        }
        .layoutWeight(1)

        // Actions
        Row({ space: Theme.space.s3 }) {
          AppButton({
            label: '取消',
            variant: 'secondary',
            onTap: () => this.onCancel()
          }).layoutWeight(1)

          AppButton({
            label: this.isEdit ? '保存修改' : '确认添加',
            variant: 'primary',
            onTap: () => this.handleSave()
          }).layoutWeight(1)
        }
        .width('100%')
        .padding({ top: Theme.space.s3 })
      }
      .width('100%')
      .constraintSize({ maxHeight: '82%' })
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius({
        topLeft: Theme.radius.xl,
        topRight: Theme.radius.xl
      })
      .padding(Theme.space.cardPadding)
      .shadow({ radius: 24, color: 'rgba(0,0,0,0.18)', offsetY: -4 })
    }
    .width('100%')
    .height('100%')
  }
}
