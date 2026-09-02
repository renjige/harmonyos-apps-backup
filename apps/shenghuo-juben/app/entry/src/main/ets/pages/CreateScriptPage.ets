import { common } from '@kit.AbilityKit'
import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppDatePickerField } from '../components/design-system/AppDatePickerField'
import { LifeScript, MoodOption } from '../models/ScriptModels'
import { DateHelper } from '../services/DateHelper'
import { PrologueService } from '../services/PrologueService'
import { ScriptStore } from '../services/ScriptStore'
import { PhotoPickService } from '../services/PhotoPickService'

@Component
export struct CreateScriptPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop editingId: string = ''
  @State title: string = ''
  @State sceneDescription: string = ''
  @State prologue: string = ''
  @State moodTag: string = '平静'
  @State imagePaths: string[] = []
  @State toastText: string = ''
  @State dateKey: string = DateHelper.todayKey()
  onClose: () => void = () => {}
  onSaved: () => void = () => {}
  private moods: MoodOption[] = MoodOption.all()

  aboutToAppear(): void {
    void this.loadEditing()
  }

  private async loadEditing(): Promise<void> {
    if (this.editingId.length === 0) {
      this.dateKey = DateHelper.todayKey()
      return
    }
    const existing = await ScriptStore.findById(this.editingId)
    if (existing === undefined) {
      return
    }
    this.title = existing.title
    this.sceneDescription = existing.sceneDescription
    this.prologue = existing.prologue
    this.moodTag = existing.moodTag
    this.imagePaths = existing.imagePaths
    this.dateKey = existing.dateKey
  }

  private isEditing(): boolean {
    return this.editingId.length > 0
  }

  private sceneCharCount(): number {
    return this.sceneDescription.length
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout((): void => { this.toastText = '' }, 2600)
  }

  private generatePrologue(): void {
    this.prologue = PrologueService.generate(this.title, this.sceneDescription, this.moodTag)
    this.showToast('已生成开场白')
  }

  private removePhoto(path: string): void {
    const next: string[] = []
    for (const p of this.imagePaths) {
      if (p !== path) {
        next.push(p)
      }
    }
    this.imagePaths = next
  }

  private async pickPhotos(): Promise<void> {
    const remain = 3 - this.imagePaths.length
    if (remain <= 0) {
      this.showToast('最多添加 3 张配图')
      return
    }
    const ctx = getContext(this) as common.UIAbilityContext
    const picked = await PhotoPickService.pickImages(ctx, remain)
    if (picked.length === 0) {
      this.showToast('未选择图片或读取失败')
      return
    }
    const merged: string[] = []
    for (const p of this.imagePaths) {
      merged.push(p)
    }
    for (const p of picked) {
      if (merged.length < 3) {
        merged.push(p)
      }
    }
    this.imagePaths = merged
  }

  private async saveScript(): Promise<void> {
    if (this.title.trim().length === 0) {
      this.showToast('请填写剧本标题')
      return
    }
    if (this.sceneDescription.length > 500) {
      this.showToast('场景描述不超过 500 字')
      return
    }
    let script: LifeScript
    if (this.isEditing()) {
      const existing = await ScriptStore.findById(this.editingId)
      if (existing === undefined) {
        script = LifeScript.createNew(this.dateKey)
      } else {
        script = existing
      }
    } else {
      script = LifeScript.createNew(this.dateKey)
    }
    script.title = this.title.trim()
    script.sceneDescription = this.sceneDescription.trim()
    script.prologue = this.prologue.trim()
    script.moodTag = this.moodTag
    script.imagePaths = this.imagePaths
    script.dateKey = this.dateKey
    await ScriptStore.saveScript(script)
    this.onSaved()
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
          Text(this.isEditing() ? '编辑剧本' : '新剧本')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Blank()
          Column().width(44)
        }
        .width('100%')
        .padding(Theme.space.pageX)

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Text('剧本标题')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            TextInput({ text: this.title, placeholder: '如：清晨的第一幕' })
              .onChange((v: string) => { this.title = v })
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
              .padding(Theme.space.s3)

            AppDatePickerField({
              label: '剧本日期',
              value: this.dateKey,
              placeholder: '请选择日期',
              minDaysFromToday: -1825,
              maxDaysFromToday: 0,
              onChange: (v: string): void => { this.dateKey = v }
            })

            Row() {
              Text('场景描述（500字以内）')
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              Blank()
              Text(`${this.sceneCharCount()}/500`)
                .fontSize(Theme.type.caption)
                .fontColor(this.sceneCharCount() > 500 ?
                  Theme.colors().danger : Theme.colors().textTertiary)
            }
            .width('100%')

            TextArea({ text: this.sceneDescription, placeholder: '写下这一天的场景与感受…' })
              .height(120)
              .onChange((v: string) => {
                this.sceneDescription = v.length > 500 ? v.substring(0, 500) : v
              })
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
              .padding(Theme.space.s3)

            Text('心情标签')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.moods, (m: MoodOption) => {
                Text(m.label)
                  .fontSize(Theme.type.bodyS)
                  .fontColor(this.moodTag === m.label ?
                    Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                  .padding({ left: 14, right: 14, top: 8, bottom: 8 })
                  .backgroundColor(this.moodTag === m.label ?
                    Theme.colors().brandPrimary : Theme.colors().surfaceCard)
                  .borderRadius(Theme.radius.pill)
                  .margin({ right: 8, bottom: 8 })
                  .onClick((): void => { this.moodTag = m.label })
              }, (m: MoodOption) => m.key)
            }
            .width('100%')

            AppButton({
              label: '智慧生成开场白',
              variant: 'secondary',
              onTap: (): void => { this.generatePrologue() }
            })

            Column({ space: Theme.space.s2 }) {
              Text('开场白（可编辑）')
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              TextArea({ text: this.prologue, placeholder: '可点击上方按钮智慧生成，也可自行撰写…' })
                .height(100)
                .onChange((v: string) => { this.prologue = v })
                .backgroundColor(Theme.colors().brandPrimaryContainer)
                .borderRadius(Theme.radius.md)
                .padding(Theme.space.s3)
            }
            .width('100%')

            Row({ space: Theme.space.s2 }) {
              AppButton({
                label: '添加配图',
                variant: 'secondary',
                onTap: (): void => { void this.pickPhotos() }
              }).layoutWeight(1)
              Text(`${this.imagePaths.length}/3`)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textTertiary)
            }
            .width('100%')

            if (this.imagePaths.length > 0) {
              Scroll() {
                Row({ space: Theme.space.s2 }) {
                  ForEach(this.imagePaths, (path: string) => {
                    Stack({ alignContent: Alignment.TopEnd }) {
                      Image(path)
                        .width(88)
                        .height(88)
                        .objectFit(ImageFit.Cover)
                        .borderRadius(Theme.radius.sm)
                      Row() {
                        AppIcon({ name: 'close', iconSize: 14, color: '#FFFFFF' })
                      }
                      .width(22)
                      .height(22)
                      .justifyContent(FlexAlign.Center)
                      .backgroundColor('rgba(44,62,80,0.72)')
                      .borderRadius(Theme.radius.pill)
                      .margin(4)
                      .onClick((): void => { this.removePhoto(path) })
                    }
                  }, (path: string) => path)
                }
              }
              .scrollable(ScrollDirection.Horizontal)
              .scrollBar(BarState.Off)
              .width('100%')
            }

            AppButton({
              label: this.isEditing() ? '保存修改' : '完成',
              variant: 'primary',
              onTap: (): void => { void this.saveScript() }
            })
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
        }
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor('rgba(44,62,80,0.92)')
          .borderRadius(Theme.radius.pill)
          .position({ x: '50%', y: 48 })
          .translate({ x: '-50%' })
          .zIndex(50)
      }
    }
    .width('100%')
    .height('100%')
    .zIndex(40)
  }
}
