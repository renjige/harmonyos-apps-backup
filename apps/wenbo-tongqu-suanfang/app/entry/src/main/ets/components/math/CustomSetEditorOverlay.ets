import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { CustomExpr, CustomSet } from '../../models/MathModels'
import { MathBizService } from '../../services/MathBizService'
import { MathExprParser } from '../../services/MathExprParser'
import { MathLocalStore } from '../../services/MathLocalStore'

@Component
export struct CustomSetEditorOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop editId: string = ''
  @State title: string = '给孩子的题'
  @State draft: string = ''
  @State createdAt: string = ''
  @State items: CustomExpr[] = []
  @State hint: string = '例：7+8  12-5  3×4  20÷5'
  onClose: () => void = () => {}
  onSaved: (set: CustomSet) => void = (_s: CustomSet) => {}

  aboutToAppear(): void {
    if (this.editId.length === 0) {
      return
    }
    for (const s of MathLocalStore.snapshot().customSets) {
      if (s.id === this.editId) {
        this.title = s.title
        this.items = s.items
        this.createdAt = s.createdAt
      }
    }
  }

  private addLine(): void {
    const parsed = MathExprParser.parse(this.draft)
    if (parsed === null) {
      this.hint = '请写成 7+8、12-5、3×4、20÷5，除法须整除'
      return
    }
    if (this.items.length >= 20) {
      this.hint = '一份题单最多 20 题'
      return
    }
    parsed.id = MathLocalStore.newId('ex')
    const next: CustomExpr[] = []
    for (const it of this.items) {
      next.push(it)
    }
    next.push(parsed)
    this.items = next
    this.draft = ''
    this.hint = '已加入'
  }

  private drop(id: string): void {
    const next: CustomExpr[] = []
    for (const it of this.items) {
      if (it.id !== id) {
        next.push(it)
      }
    }
    this.items = next
  }

  private async save(): Promise<void> {
    if (this.items.length === 0) {
      this.hint = '至少加一题再保存'
      return
    }
    const set = new CustomSet()
    set.id = this.editId.length > 0 ? this.editId : MathLocalStore.newId('set')
    set.title = this.title.trim().length > 0 ? this.title.trim() : '给孩子的题'
    set.createdAt = this.createdAt.length > 0 ? this.createdAt : MathLocalStore.today()
    set.items = this.items
    await MathBizService.saveCustomSet(set)
    this.onSaved(set)
  }

  build() {
    Column() {
      Row() {
        Column() {
          AppIcon({ name: 'close', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(44).height(44).justifyContent(FlexAlign.Center)
        .onClick(() => this.onClose())
        Text('写出题目')
          .fontSize(Theme.type.title3).fontWeight(FontWeight.Medium)
          .layoutWeight(1).textAlign(TextAlign.Center)
        Blank().width(44)
      }
      .width('100%').padding({ left: Theme.space.s2, right: Theme.space.s2, top: Theme.space.s2 })

      Column({ space: Theme.space.s3 }) {
        TextInput({ text: this.title, placeholder: '题单名称' })
          .width('100%').height(44)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .placeholderColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .onChange((v: string) => { this.title = v })
        TextInput({ text: this.draft, placeholder: '输入算式，如 8+7' })
          .width('100%').height(44)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .placeholderColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .onChange((v: string) => { this.draft = v })
        AppButton({ label: '加入题单', onTap: () => this.addLine() })
        Text(this.hint)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
      }
      .padding({ left: Theme.space.s6, right: Theme.space.s6 })
      .width('100%')

      Scroll() {
        Column({ space: Theme.space.s2 }) {
          ForEach(this.items, (it: CustomExpr) => {
            Row() {
              Text(it.expression)
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .layoutWeight(1)
              Text('去掉')
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .onClick(() => this.drop(it.id))
            }
            .width('100%').padding(Theme.space.s3)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)
          }, (it: CustomExpr) => it.id)
        }
        .padding({ left: Theme.space.s6, right: Theme.space.s6, bottom: Theme.space.s4 })
      }
      .layoutWeight(1).scrollBar(BarState.Off)

      Column() {
        AppButton({ label: '保存题单', onTap: (): void => { void this.save() } })
      }
      .padding({ left: Theme.space.s6, right: Theme.space.s6, bottom: Theme.space.s7 })
      .width('100%')
    }
    .width('100%').height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
