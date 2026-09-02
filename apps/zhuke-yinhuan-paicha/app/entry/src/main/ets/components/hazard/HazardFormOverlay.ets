import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppDatePickerField } from '../design-system/AppDatePickerField'
import { HazardCatalog } from '../../models/HazardModels'

@Component
export struct HazardFormOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop seedTitle: string = ''
  @Prop seedCategory: string = ''
  @State title: string = ''
  @State location: string = ''
  @State category: string = '临边防护'
  @State riskLevel: string = 'medium'
  @State description: string = ''
  @State suggestion: string = ''
  @State ownerName: string = ''
  @State dueAt: string = ''
  @State errorText: string = ''
  onClose: () => void = () => {}
  onSave: (title: string, location: string, category: string, risk: string, description: string,
    suggestion: string, owner: string, dueAt: string) => void = () => {}

  aboutToAppear(): void {
    if (this.seedTitle.length > 0) {
      this.title = this.seedTitle
    }
    if (this.seedCategory.length > 0) {
      this.category = this.seedCategory
    }
  }

  private submit(): void {
    if (this.title.trim().length === 0) {
      this.errorText = '请输入隐患名称'
      return
    }
    this.errorText = ''
    this.onSave(this.title.trim(), this.location.trim(), this.category, this.riskLevel,
      this.description.trim(), this.suggestion.trim(), this.ownerName.trim(), this.dueAt)
  }

  build() {
    Column() {
      Row() {
        Text('取消').fontSize(15).fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary).onClick(() => this.onClose())
        Text('新增隐患').fontSize(18).fontWeight(FontWeight.Medium).fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1).textAlign(TextAlign.Center)
        Text('保存').fontSize(15).fontColor(Theme.colors().brandAccent).onClick(() => this.submit())
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })

      if (this.errorText.length > 0) {
        Text(this.errorText)
          .fontSize(13).fontColor('#FFFFFF').padding(10)
          .backgroundColor(Theme.colors().danger).borderRadius(8)
          .margin({ left: 16, right: 16, bottom: 8 }).width('100%')
      }

      Scroll() {
        Column({ space: 14 }) {
          Column({ space: 10 }) {
            Text('基础信息').fontSize(15).fontWeight(FontWeight.Medium).fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary).width('100%')
            this.Field('隐患名称', this.title, '请输入隐患名称', (v: string) => { this.title = v })
            this.Field('隐患位置', this.location, '例如：3号楼二层东侧', (v: string) => { this.location = v })
            Text('隐患类别').fontSize(12).fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary).width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(HazardCatalog.titles(), (name: string) => {
                Text(name)
                  .fontSize(13)
                  .fontColor(this.category === name ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                  .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                  .margin({ right: 8, bottom: 8 })
                  .backgroundColor(this.category === name ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                  .borderRadius(10)
                  .onClick(() => { this.category = name })
              }, (name: string) => `${name}_${this.category}`)
            }
            .width('100%')
          }
          .padding(16).width('100%').alignItems(HorizontalAlign.Start)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard).borderRadius(Theme.radius.card)

          Column({ space: 10 }) {
            Text('风险等级').fontSize(15).fontWeight(FontWeight.Medium).fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary).width('100%')
            Row({ space: 8 }) {
              this.RiskBtn('low', '低风险', '#36A269')
              this.RiskBtn('medium', '中风险', '#E9932E')
              this.RiskBtn('high', '高风险', '#D94A4A')
            }.width('100%')
          }
          .padding(16).width('100%').alignItems(HorizontalAlign.Start)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard).borderRadius(Theme.radius.card)

          Column({ space: 8 }) {
            Text('问题描述').fontSize(15).fontWeight(FontWeight.Medium).fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary).width('100%')
            TextArea({ text: this.description, placeholder: '请描述发现的问题' })
              .height(90).backgroundColor(Theme.colors().surfaceSubtle)
              .onChange((v: string) => { this.description = v })
          }
          .padding(16).width('100%').alignItems(HorizontalAlign.Start)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard).borderRadius(Theme.radius.card)

          Column({ space: 8 }) {
            Text('整改信息').fontSize(15).fontWeight(FontWeight.Medium).fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary).width('100%')
            TextArea({ text: this.suggestion, placeholder: '请输入建议措施' })
              .height(72).backgroundColor(Theme.colors().surfaceSubtle)
              .onChange((v: string) => { this.suggestion = v })
            AppDatePickerField({
              label: '整改期限', value: this.dueAt, placeholder: '请选择日期',
              minDaysFromToday: 0, maxDaysFromToday: 60,
              onChange: (v: string) => { this.dueAt = v }
            })
            this.Field('责任人', this.ownerName, '请输入责任人', (v: string) => { this.ownerName = v })
          }
          .padding(16).width('100%').alignItems(HorizontalAlign.Start)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard).borderRadius(Theme.radius.card)

          AppButton({ label: '保存隐患', onTap: (): void => { this.submit() } })
          AppButton({ label: '取消', variant: 'secondary', onTap: (): void => { this.onClose() } })
        }
        .padding({ left: 16, right: 16, bottom: 40 })
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  Field(label: string, value: string, placeholder: string, onChange: (v: string) => void) {
    Column({ space: 6 }) {
      Text(label).fontSize(12).fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary).width('100%')
      TextInput({ text: value, placeholder: placeholder })
        .height(42).backgroundColor(Theme.colors().surfaceSubtle)
        .onChange((v: string) => onChange(v))
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  RiskBtn(id: string, label: string, color: string) {
    Column() {
      Text(label)
        .fontSize(14)
        .fontColor(this.riskLevel === id ? '#FFFFFF' : color)
    }
    .layoutWeight(1)
    .height(40)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.riskLevel === id ? color : this.riskIdle(id))
    .borderRadius(12)
    .onClick(() => { this.riskLevel = id })
  }

  private riskIdle(id: string): string {
    if (id === 'low') {
      return '#E8F7F0'
    }
    if (id === 'high') {
      return '#FDECEC'
    }
    return '#FFF4E5'
  }
}
