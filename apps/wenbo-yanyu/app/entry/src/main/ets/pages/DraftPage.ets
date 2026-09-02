import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { DraftTemplate, StyleChip } from '../models/LanguageCraftModels'
import { LanguageDraftService } from '../services/LanguageDraftService'
import { LanguageCraftNav } from '../services/LanguageCraftNav'
import { OptionPickGrid } from '../components/polish/OptionPickGrid'

@Component
export struct DraftPage {
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @StorageLink('draftTemplateKey') @Watch('onDraftKey') draftTemplateKey: string = ''
  @State templateKey: string = 'email'
  @State fieldA: string = ''
  @State fieldB: string = ''
  @State fieldC: string = ''
  @State preview: string = ''
  @State toastText: string = ''
  private templateChips: StyleChip[] = []

  aboutToAppear(): void {
    this.templateChips = []
    const list = LanguageDraftService.templates()
    for (const row of list) {
      this.templateChips.push(StyleChip.of(row.key, row.title, row.fieldA))
    }
    this.consumeDraftKey()
  }

  onDraftKey(): void {
    this.consumeDraftKey()
  }

  private consumeDraftKey(): void {
    if (this.draftTemplateKey.length === 0) {
      return
    }
    this.templateKey = this.draftTemplateKey
    this.preview = ''
    AppStorage.setOrCreate('draftTemplateKey', '')
  }

  private pickTemplate(key: string): void {
    this.templateKey = key
    this.preview = ''
    this.showToast(`已切换为「${LanguageDraftService.find(key).title}」，填三栏后生成`)
  }

  private current(): DraftTemplate {
    return LanguageDraftService.find(this.templateKey)
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout((): void => {
      this.toastText = ''
    }, 2000)
  }

  private buildDraft(): void {
    const text = LanguageDraftService.build(this.templateKey, this.fieldA, this.fieldB, this.fieldC)
    if (text.length === 0) {
      this.showToast('请填完三栏后再生成')
      return
    }
    this.preview = text
  }

  private applyDraft(): void {
    if (this.preview.length === 0) {
      this.buildDraft()
    }
    if (this.preview.length === 0) {
      return
    }
    LanguageCraftNav.applyToPolish(this.preview)
  }

  build() {
    Stack() {
      Column() {
        Row({ space: Theme.space.s2 }) {
          Column() {
            AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.of(this.darkModeOn).textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .rotate({ angle: 180 })
          .onClick((): void => { LanguageCraftNav.closeDraft() })
          Text('场景成稿')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.of(this.darkModeOn).textPrimary)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Text('24 类职场/学术/研究场景：填空生成完整草稿，再一键送到润色台改语气。')
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.of(this.darkModeOn).textSecondary)
              .width('100%')

            OptionPickGrid({
              title: '成稿类型（点选后填空）',
              selectedKey: this.templateKey,
              chips: this.templateChips,
              onPick: (key: string): void => { this.pickTemplate(key) }
            })

            this.FieldBlock(this.current().fieldA, this.fieldA, (v: string): void => { this.fieldA = v })
            this.FieldBlock(this.current().fieldB, this.fieldB, (v: string): void => { this.fieldB = v })
            this.FieldBlock(this.current().fieldC, this.fieldC, (v: string): void => { this.fieldC = v })

            AppButton({
              label: '生成草稿',
              onTap: (): void => { this.buildDraft() }
            })

            if (this.preview.length > 0) {
              Column({ space: 8 }) {
                Text('草稿预览')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.of(this.darkModeOn).textSecondary)
                  .width('100%')
                Text(this.preview)
                  .fontSize(Theme.type.body)
                  .fontColor(Theme.of(this.darkModeOn).textPrimary)
                  .lineHeight(24)
                  .width('100%')
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(Theme.of(this.darkModeOn).surfaceCard)
              .borderRadius(Theme.radius.lg)

              AppButton({
                label: '送到润色台',
                onTap: (): void => { this.applyDraft() }
              })
            }
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.of(this.darkModeOn).surfacePage)

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.of(this.darkModeOn).brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.of(this.darkModeOn).brandPrimary)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding({ top: Theme.space.s6 })
        .alignItems(HorizontalAlign.Center)
        .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  FieldBlock(label: string, value: string, onChange: (v: string) => void) {
    Column({ space: Theme.space.s2 }) {
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.of(this.darkModeOn).textSecondary)
        .width('100%')
      TextArea({ text: value, placeholder: `填写${label}` })
        .height(72)
        .fontSize(Theme.type.body)
        .fontColor(Theme.of(this.darkModeOn).textPrimary)
        .backgroundColor(Theme.of(this.darkModeOn).surfaceCard)
        .borderRadius(Theme.radius.lg)
        .onChange((v: string): void => { onChange(v) })
    }
    .width('100%')
  }
}
