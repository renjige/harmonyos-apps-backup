import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { DetailShell } from '../detail/DetailShell'
import { AtlasKind, GewuPlan } from '../../models/FieldModels'
import { FieldStore } from '../../services/FieldStore'
import { GewuDetailNav } from '../../services/GewuDetailNav'
import { DateHelper } from '../../services/DateHelper'

@Component
export struct PlanEditorSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('practiceFocusId') @Watch('onFocusChange') focusId: string = ''
  onSaved: () => void = () => {}
  @State title: string = ''
  @State atlasKind: string = 'all'
  @State days: number = 7
  @State targetCount: number = 5
  @State note: string = ''
  @State toastText: string = ''
  @State loadedId: string = ''

  aboutToAppear(): void {
    void this.hydrate()
  }

  onFocusChange(): void {
    void this.hydrate()
  }

  private async hydrate(): Promise<void> {
    if (this.focusId.length === 0 || this.focusId === 'new') {
      this.title = ''
      this.atlasKind = 'all'
      this.days = 7
      this.targetCount = 5
      this.note = ''
      this.loadedId = ''
      return
    }
    const p = await FieldStore.findPlan(this.focusId)
    if (p === undefined) {
      this.loadedId = ''
      return
    }
    this.loadedId = p.id
    this.title = p.title
    this.atlasKind = p.atlasKind
    this.targetCount = p.targetCount
    this.note = p.note
    this.days = 7
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private async save(): Promise<void> {
    const plan = new GewuPlan()
    plan.id = this.loadedId
    plan.title = this.title
    plan.atlasKind = this.atlasKind
    plan.targetCount = this.targetCount
    plan.note = this.note
    plan.startKey = DateHelper.todayKey()
    plan.endKey = DateHelper.addDays(plan.startKey, this.days - 1)
    const ok = await FieldStore.savePlan(plan)
    if (!ok) {
      this.showToast('请填写功课名称')
      return
    }
    this.onSaved()
    this.showToast('功课已保存')
    setTimeout((): void => { GewuDetailNav.closePractice() }, 400)
  }

  build() {
    Stack() {
      DetailShell({
        title: this.loadedId.length > 0 ? '编辑功课' : '新建功课',
        onClose: (): void => { GewuDetailNav.closePractice() },
        body: (): void => { this.Body() }
      })
      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
          .position({ x: '50%', y: 48 })
          .translate({ x: '-50%' })
          .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  Body() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Text('给这段日子起一个功课名，例如「本周认五种植物」。进度按期内观察条数计算。')
          .fontSize(Theme.type.bodyS)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        TextInput({ text: this.title, placeholder: '功课名称' })
          .width('100%')
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .placeholderColor(Theme.colors().textTertiary)
          .backgroundColor(Theme.colors().surfaceSubtle)
          .borderRadius(Theme.radius.md)
          .padding(12)
          .onChange((v: string): void => { this.title = v })
        Text('周期')
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        Row({ space: Theme.space.s2 }) {
          this.DayChip('本周 7 日', 7)
          this.DayChip('三十日', 30)
        }
        .width('100%')
        Text('目标则数')
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        Row({ space: Theme.space.s2 }) {
          this.TargetChip(3)
          this.TargetChip(5)
          this.TargetChip(7)
          this.TargetChip(10)
        }
        .width('100%')
        Text('图鉴范围')
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        Flex({ wrap: FlexWrap.Wrap }) {
          this.AtlasChip('不限', 'all')
          ForEach(AtlasKind.all(), (k: string) => {
            this.AtlasChip(k, k)
          }, (k: string) => k)
        }
        .width('100%')
        TextInput({ text: this.note, placeholder: '选填：为何立这一课' })
          .width('100%')
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .placeholderColor(Theme.colors().textTertiary)
          .backgroundColor(Theme.colors().surfaceSubtle)
          .borderRadius(Theme.radius.md)
          .padding(12)
          .onChange((v: string): void => { this.note = v })
        AppButton({
          label: '保存功课',
          variant: 'primary',
          onTap: (): void => { void this.save() }
        })
        Row().height(Theme.space.s10)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
    }
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }

  @Builder
  DayChip(label: string, n: number) {
    Text(label)
      .fontSize(Theme.type.bodyS)
      .fontColor(this.days === n ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor(this.days === n ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { this.days = n })
  }

  @Builder
  TargetChip(n: number) {
    Text(`${n} 则`)
      .fontSize(Theme.type.bodyS)
      .fontColor(this.targetCount === n ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor(this.targetCount === n ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { this.targetCount = n })
  }

  @Builder
  AtlasChip(label: string, key: string) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(this.atlasKind === key ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 10, right: 10, top: 6, bottom: 6 })
      .margin({ right: 8, bottom: 8 })
      .backgroundColor(this.atlasKind === key ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { this.atlasKind = key })
  }
}
