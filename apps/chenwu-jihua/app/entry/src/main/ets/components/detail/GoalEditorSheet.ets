import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { DetailShell } from './DetailShell'
import { CwGoal, CwGoalCategory } from '../../models/ChenwuModels'
import { ChenwuStore } from '../../services/ChenwuStore'
import { ChenwuDetailNav } from '../../services/ChenwuDetailNav'

@Component
export struct GoalEditorSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('cwGoalId') editId: string = ''
  onChanged: () => void = () => {}
  @State title: string = ''
  @State description: string = ''
  @State categoryKey: string = 'learn'
  @State progress: number = 0
  @State cats: CwGoalCategory[] = []
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.bootstrap()
  }

  private async bootstrap(): Promise<void> {
    this.cats = await ChenwuStore.loadCategories()
    if (this.editId.length > 0) {
      const found = await ChenwuStore.findGoal(this.editId)
      if (found !== undefined) {
        this.title = found.title
        this.description = found.description
        this.categoryKey = found.categoryKey
        this.progress = found.progress
      }
    }
  }

  private async save(): Promise<void> {
    if (this.title.trim().length === 0) {
      this.toastText = '请填写目标标题'
      setTimeout((): void => { this.toastText = '' }, 2200)
      return
    }
    let g = new CwGoal()
    if (this.editId.length > 0) {
      const found = await ChenwuStore.findGoal(this.editId)
      if (found !== undefined) {
        g = found
      }
    } else {
      g = CwGoal.createNew(this.title.trim(), this.categoryKey)
    }
    g.title = this.title.trim()
    g.description = this.description
    g.categoryKey = this.categoryKey
    g.progress = this.progress
    await ChenwuStore.saveGoal(g)
    this.onChanged()
    ChenwuDetailNav.closeGoalEditor()
    ChenwuDetailNav.openGoal(g.id)
  }

  build() {
    Stack() {
      DetailShell({ title: this.editId.length > 0 ? '编辑目标' : '新建目标', onClose: (): void => { ChenwuDetailNav.closeGoalEditor() } }) {
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            TextInput({ text: this.title, placeholder: '目标标题' })
              .onChange((v: string): void => { this.title = v })
              .height(44)
              .backgroundColor(Theme.colors().surfaceCard)
            TextArea({ text: this.description, placeholder: '目标描述（可选）' })
              .onChange((v: string): void => { this.description = v })
              .height(100)
            Text('分类')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.cats, (c: CwGoalCategory) => {
                Text(c.label)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.categoryKey === c.key ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                  .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                  .margin({ right: 8, bottom: 8 })
                  .backgroundColor(this.categoryKey === c.key ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                  .borderRadius(Theme.radius.pill)
                  .onClick((): void => { this.categoryKey = c.key })
              }, (c: CwGoalCategory) => c.key)
            }
            Text(`进度 ${this.progress}%`)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            Slider({ value: this.progress, min: 0, max: 100, step: 5 })
              .onChange((v: number): void => { this.progress = v })
            AppButton({ label: '保存', onTap: (): void => { void this.save() } })
            Column().height(Theme.space.s8)
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
        }
        .width('100%')
        .layoutWeight(1)
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding(12)
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.sm)
          .margin({ top: 16 })
          .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }
}
