import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppNavBar } from '../design-system/AppNavBar'
import { VitalityNote, VitalityTagOption } from '../../models/VitalityModels'
import { DateHelper } from '../../services/DateHelper'

@Component
export struct NoteDetailOverlay {
  @Prop note: VitalityNote = new VitalityNote()
  onClose: () => void = () => {}
  onToggleFavorite: () => void = () => {}
  onSave: (title: string, body: string, tagKeys: string) => void = () => {}
  onDelete: () => void = () => {}

  @State editing: boolean = false
  @State confirmDelete: boolean = false
  @State titleText: string = ''
  @State bodyText: string = ''
  @State selectedTags: string = ''

  aboutToAppear(): void {
    this.titleText = this.note.title
    this.bodyText = this.note.body
    this.selectedTags = this.note.tagKeys
  }

  private toggleTag(key: string): void {
    const parts = this.selectedTags.length === 0 ? [] : this.selectedTags.split(',')
    const next: string[] = []
    let found = false
    for (const p of parts) {
      if (p.length === 0) {
        continue
      }
      if (p === key) {
        found = true
      } else {
        next.push(p)
      }
    }
    if (!found) {
      next.push(key)
    }
    this.selectedTags = next.join(',')
  }

  private hasTag(key: string): boolean {
    const parts = this.selectedTags.split(',')
    for (const p of parts) {
      if (p === key) {
        return true
      }
    }
    return false
  }

  private formatTagLabels(): string {
    const parts = this.selectedTags.split(',')
    const labels: string[] = []
    for (const p of parts) {
      if (p.length === 0) {
        continue
      }
      labels.push(VitalityTagOption.labelFor(p))
    }
    return labels.join('、')
  }

  build() {
    Column() {
      AppNavBar({ title: '纪行笔记', onBack: (): void => this.onClose() })
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image($r('app.media.hero_ambient'))
              .width('100%')
              .height(120)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.lg)
            Column()
              .width('100%')
              .height(120)
              .linearGradient({
                angle: 180,
                colors: [['rgba(26,42,58,0.08)', 0], ['rgba(26,42,58,0.72)', 1]]
              })
              .borderRadius(Theme.radius.lg)
            Text(DateHelper.displayDate(this.note.dateKey))
              .fontSize(Theme.type.bodyS)
              .fontColor('#FFFFFF')
              .padding({ left: Theme.space.s4, bottom: Theme.space.s3 })
          }
          .width('100%')

          if (this.editing) {
            TextInput({ text: this.titleText, placeholder: '标题' })
              .onChange((v: string): void => { this.titleText = v })
            TextArea({ text: this.bodyText, placeholder: '正文' })
              .height(140)
              .onChange((v: string): void => { this.bodyText = v })
            Row({ space: Theme.space.s2 }) {
              ForEach(VitalityTagOption.all(), (t: VitalityTagOption) => {
                Text(t.label)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.hasTag(t.key) ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                  .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                  .backgroundColor(this.hasTag(t.key) ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                  .borderRadius(Theme.radius.pill)
                  .onClick((): void => { this.toggleTag(t.key) })
              }, (t: VitalityTagOption) => t.key)
            }
            .width('100%')
            Column() {
              AppButton({
                label: '保存修改',
                variant: 'primary',
                onTap: (): void => {
                  this.onSave(this.titleText, this.bodyText, this.selectedTags)
                  this.editing = false
                }
              })
            }
            .width('100%')
          } else {
            Text(this.note.title)
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            Text(this.bodyText)
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textSecondary)
              .lineHeight(24)
              .width('100%')
            if (this.selectedTags.length > 0) {
              Text(`标签：${this.formatTagLabels()}`)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().brandPrimary)
                .width('100%')
            }
            Row({ space: Theme.space.s2 }) {
              Column() {
                AppButton({
                  label: this.note.favorite ? '已收藏' : '收藏',
                  variant: 'secondary',
                  onTap: (): void => this.onToggleFavorite()
                })
              }
              .layoutWeight(1)
              Column() {
                AppButton({ label: '编辑', variant: 'secondary', onTap: (): void => { this.editing = true } })
              }
              .layoutWeight(1)
            }
            .width('100%')
            Column() {
              AppButton({
                label: this.confirmDelete ? '确认删除笔记？' : '删除笔记',
                variant: 'secondary',
                onTap: (): void => {
                  if (!this.confirmDelete) {
                    this.confirmDelete = true
                    return
                  }
                  this.onDelete()
                }
              })
            }
            .width('100%')
          }
          Row().height(Theme.space.s10)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
    .zIndex(55)
  }
}
